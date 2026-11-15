import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/date_utils.dart';
import '../domain/habit.dart';
import '../domain/habit_log.dart';
import 'database.dart';

class FutureDateError extends Error {}

class BeforeCreationError extends Error {}

class ReminderTime {
  const ReminderTime(this.hour, this.minute);
  final int hour;
  final int minute;

  factory ReminderTime.fromHm(String s) {
    final p = s.split(':');
    return ReminderTime(int.parse(p[0]), int.parse(p[1]));
  }

  String toHm() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

class ReminderRow {
  const ReminderRow(this.habitId, this.time);
  final int habitId;
  final ReminderTime time;
}

class HabitDraft {
  const HabitDraft({
    required this.name,
    this.description,
    required this.icon,
    required this.color,
    required this.frequencyType,
    this.frequencyDays = const {},
    this.targetPerWeek,
    this.timeOfDay = TimeOfDaySlot.anytime,
  });
  final String name;
  final String? description;
  final String icon;
  final int color;
  final FrequencyType frequencyType;
  final Set<int> frequencyDays;
  final int? targetPerWeek;
  final TimeOfDaySlot timeOfDay;
}

class HabitRepository {
  HabitRepository(this._db);
  final AppDatabase _db;

  static (FrequencyType, TimeOfDaySlot) _parseFreqAndSlot(String raw) {
    final parts = raw.split(':');
    final freq = FrequencyType.values.byName(parts[0]);
    final slot = parts.length > 1
        ? TimeOfDaySlot.values.firstWhere(
            (s) => s.name == parts[1],
            orElse: () => TimeOfDaySlot.anytime,
          )
        : TimeOfDaySlot.anytime;
    return (freq, slot);
  }

  static String _encodeFreqAndSlot(FrequencyType f, TimeOfDaySlot s) =>
      s == TimeOfDaySlot.anytime ? f.name : '${f.name}:${s.name}';

  Habit _toHabit(HabitRow r) {
    final (freq, slot) = _parseFreqAndSlot(r.frequencyType);
    return Habit(
      id: r.id,
      name: r.name,
      description: r.description,
      icon: r.icon,
      color: r.color,
      frequencyType: freq,
      frequencyDays: r.frequencyDays.isEmpty
          ? {}
          : r.frequencyDays.split(',').map(int.parse).toSet(),
      targetPerWeek: r.targetPerWeek,
      timeOfDay: slot,
      sortOrder: r.sortOrder,
      createdAt: parseIso(r.createdAt),
      archivedAt: r.archivedAt == null ? null : parseIso(r.archivedAt!),
    );
  }

  Stream<List<Habit>> _watch(Expression<bool> Function($HabitsTable) where) {
    final q = _db.select(_db.habits)
      ..where(where)
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);
    return q.watch().map((rs) => rs.map(_toHabit).toList());
  }

  Stream<List<Habit>> watchActive() => _watch((t) => t.archivedAt.isNull());
  Stream<List<Habit>> watchArchived() => _watch((t) => t.archivedAt.isNotNull());

  Future<Habit?> getHabit(int id) async {
    final r = await (_db.select(_db.habits)..where((t) => t.id.equals(id))).getSingleOrNull();
    return r == null ? null : _toHabit(r);
  }

  HabitsCompanion _companion(HabitDraft d) => HabitsCompanion(
        name: Value(d.name.trim()),
        description: Value(d.description),
        icon: Value(d.icon),
        color: Value(d.color),
        frequencyType: Value(_encodeFreqAndSlot(d.frequencyType, d.timeOfDay)),
        frequencyDays: Value((d.frequencyDays.toList()..sort()).join(',')),
        targetPerWeek: Value(d.targetPerWeek),
      );

  Future<void> _setReminders(int habitId, List<ReminderTime> rs) async {
    await (_db.delete(_db.reminders)..where((t) => t.habitId.equals(habitId))).go();
    for (final r in rs) {
      await _db.into(_db.reminders).insert(
          RemindersCompanion.insert(habitId: habitId, time: r.toHm()));
    }
  }

  Future<int> create(HabitDraft d,
      {required DateTime createdAt, List<ReminderTime> reminders = const []}) {
    return _db.transaction(() async {
      final maxExp = _db.habits.sortOrder.max();
      final maxOrder = await (_db.selectOnly(_db.habits)..addColumns([maxExp]))
          .map((r) => r.read(maxExp))
          .getSingle();
      final id = await _db.into(_db.habits).insert(_companion(d).copyWith(
            sortOrder: Value(maxOrder == null ? 0 : maxOrder + 1),
            createdAt: Value(toIso(createdAt)),
          ));
      await _setReminders(id, reminders);
      return id;
    });
  }

  Future<void> update(int id, HabitDraft d, {List<ReminderTime>? reminders}) {
    return _db.transaction(() async {
      await (_db.update(_db.habits)..where((t) => t.id.equals(id))).write(_companion(d));
      if (reminders != null) await _setReminders(id, reminders);
    });
  }

  Future<void> archive(int id, DateTime on) =>
      (_db.update(_db.habits)..where((t) => t.id.equals(id)))
          .write(HabitsCompanion(archivedAt: Value(toIso(on))));

  Future<void> unarchive(int id) =>
      (_db.update(_db.habits)..where((t) => t.id.equals(id)))
          .write(const HabitsCompanion(archivedAt: Value(null)));

  Future<void> delete(int id) =>
      (_db.delete(_db.habits)..where((t) => t.id.equals(id))).go();

  Future<void> reorder(List<int> habitIds) => _db.transaction(() async {
        for (var i = 0; i < habitIds.length; i++) {
          await (_db.update(_db.habits)..where((t) => t.id.equals(habitIds[i])))
              .write(HabitsCompanion(sortOrder: Value(i)));
        }
      });

  Future<void> setCompletion(int habitId, DateTime date, bool completed,
      {required DateTime today}) async {
    final d = dateOnly(date);
    final t = dateOnly(today);
    if (d.isAfter(t)) throw FutureDateError();
    final habit = await getHabit(habitId);
    if (habit == null || d.isBefore(habit.createdAt)) throw BeforeCreationError();
    await _db.into(_db.habitLogs).insert(
          HabitLogsCompanion.insert(
              habitId: habitId, date: toIso(d), completed: completed),
          onConflict: DoUpdate((_) => HabitLogsCompanion(completed: Value(completed)),
              target: [_db.habitLogs.habitId, _db.habitLogs.date]),
        );
  }

  Future<void> setNote(int habitId, DateTime date, String? note,
      {required DateTime today}) async {
    final d = dateOnly(date);
    final t = dateOnly(today);
    if (d.isAfter(t)) throw FutureDateError();
    final habit = await getHabit(habitId);
    if (habit == null || d.isBefore(habit.createdAt)) throw BeforeCreationError();
    final trimmed = note?.trim();
    final val = (trimmed == null || trimmed.isEmpty) ? null : trimmed;
    await _db.into(_db.habitLogs).insert(
          HabitLogsCompanion.insert(
              habitId: habitId, date: toIso(d), completed: false, note: Value(val)),
          onConflict: DoUpdate((_) => HabitLogsCompanion(note: Value(val)),
              target: [_db.habitLogs.habitId, _db.habitLogs.date]),
        );
  }

  Future<String> exportJson() async {
    final habits = await _db.select(_db.habits).get();
    final logs = await _db.select(_db.habitLogs).get();
    final reminders = await _db.select(_db.reminders).get();
    return const JsonEncoder.withIndent('  ').convert({
      'habits': [
        for (final h in habits)
          () {
            final (freq, slot) = _parseFreqAndSlot(h.frequencyType);
            return {
              'id': h.id,
              'name': h.name,
              'description': h.description,
              'icon': h.icon,
              'color': h.color,
              'frequencyType': freq.name,
              'timeOfDay': slot.name,
              'frequencyDays': h.frequencyDays,
              'targetPerWeek': h.targetPerWeek,
              'sortOrder': h.sortOrder,
              'createdAt': h.createdAt,
              'archivedAt': h.archivedAt,
            };
          }()
      ],
      'logs': [
        for (final l in logs)
          {
            'habitId': l.habitId,
            'date': l.date,
            'completed': l.completed,
            'note': l.note,
          }
      ],
      'reminders': [
        for (final r in reminders)
          {
            'habitId': r.habitId,
            'time': r.time,
            'enabled': r.enabled,
          }
      ],
    });
  }

  static String _csvCell(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final safe = RegExp(r'^[=+\-@]').hasMatch(raw) ? "'$raw" : raw;
    if (safe.contains(',') || safe.contains('"') || safe.contains('\n')) {
      return '"${safe.replaceAll('"', '""')}"';
    }
    return safe;
  }

  Future<String> exportCsv() async {
    final habits = await _db.select(_db.habits).get();
    final logs = await _db.select(_db.habitLogs).get();
    final byId = {for (final h in habits) h.id: h};
    final buf = StringBuffer(
      'habit_id,habit_name,frequency_type,time_of_day,date,completed,note\n',
    );
    for (final l in logs) {
      final h = byId[l.habitId];
      if (h == null) continue;
      final (freq, slot) = _parseFreqAndSlot(h.frequencyType);
      buf.writeln([
        '${h.id}',
        _csvCell(h.name),
        freq.name,
        slot.name,
        l.date,
        '${l.completed}',
        _csvCell(l.note),
      ].join(','));
    }
    return buf.toString();
  }

  Future<int> importJson(String rawJson) async {
    final Object? decoded = jsonDecode(rawJson);
    if (decoded is! Map<String, dynamic> || decoded['habits'] is! List) {
      throw const FormatException('Invalid backup JSON');
    }
    final rawHabits = decoded['habits'] as List;
    final rawLogs = (decoded['logs'] as List?) ?? const [];
    final rawReminders = (decoded['reminders'] as List?) ?? const [];

    return _db.transaction(() async {
      await clearAll();
      final idMap = <int, int>{};
      for (var i = 0; i < rawHabits.length; i++) {
        final item = rawHabits[i];
        if (item is! Map<String, dynamic>) {
          throw const FormatException('Invalid habit entry');
        }
        final oldId = (item['id'] as num?)?.toInt() ?? (i + 1);
        final name = (item['name'] as String?)?.trim() ?? '';
        if (name.isEmpty || name.length > 40) {
          throw const FormatException('Invalid habit name');
        }
        final rawFreq = (item['frequencyType'] as String?) ?? 'daily';
        final (freq, legacySlot) = _parseFreqAndSlot(rawFreq);
        final slotName = item['timeOfDay'] as String?;
        final slot = slotName != null
            ? TimeOfDaySlot.values.firstWhere(
                (s) => s.name == slotName,
                orElse: () => TimeOfDaySlot.anytime,
              )
            : legacySlot;
        final createdIso = (item['createdAt'] as String?) ?? '2026-01-01';
        parseIso(createdIso);
        final archivedIso = item['archivedAt'] as String?;
        if (archivedIso != null) parseIso(archivedIso);

        final newId = await _db.into(_db.habits).insert(
              HabitsCompanion.insert(
                name: name,
                description: Value(item['description'] as String?),
                icon: (item['icon'] as String?) ?? 'check',
                color: (item['color'] as num?)?.toInt() ?? 0xFF2E6F40,
                frequencyType: _encodeFreqAndSlot(freq, slot),
                frequencyDays: Value((item['frequencyDays'] as String?) ?? ''),
                targetPerWeek: Value((item['targetPerWeek'] as num?)?.toInt()),
                sortOrder: (item['sortOrder'] as num?)?.toInt() ?? i,
                createdAt: createdIso,
                archivedAt: Value(archivedIso),
              ),
            );
        idMap[oldId] = newId;
      }

      for (final item in rawLogs) {
        if (item is! Map<String, dynamic>) continue;
        final newHabitId = idMap[(item['habitId'] as num?)?.toInt()];
        final dateIso = item['date'] as String?;
        if (newHabitId == null || dateIso == null) continue;
        parseIso(dateIso);
        await _db.into(_db.habitLogs).insert(
              HabitLogsCompanion.insert(
                habitId: newHabitId,
                date: dateIso,
                completed: (item['completed'] as bool?) ?? false,
                note: Value(item['note'] as String?),
              ),
              mode: InsertMode.insertOrReplace,
            );
      }

      for (final item in rawReminders) {
        if (item is! Map<String, dynamic>) continue;
        final newHabitId = idMap[(item['habitId'] as num?)?.toInt()];
        final timeStr = item['time'] as String?;
        if (newHabitId == null || timeStr == null) continue;
        ReminderTime.fromHm(timeStr);
        await _db.into(_db.reminders).insert(
              RemindersCompanion.insert(
                habitId: newHabitId,
                time: timeStr,
                enabled: Value((item['enabled'] as bool?) ?? true),
              ),
            );
      }
      return idMap.length;
    });
  }

  Future<void> clearAll() => _db.transaction(() async {
        await _db.delete(_db.habitLogs).go();
        await _db.delete(_db.reminders).go();
        await _db.delete(_db.habits).go();
      });

  HabitLog _toLog(HabitLogRow r) => HabitLog(
      habitId: r.habitId, date: parseIso(r.date), completed: r.completed, note: r.note);

  Stream<List<HabitLog>> watchLogs(int habitId) =>
      (_db.select(_db.habitLogs)..where((t) => t.habitId.equals(habitId)))
          .watch()
          .map((rs) => rs.map(_toLog).toList());

  Stream<List<HabitLog>> watchLogsOn(DateTime date) =>
      (_db.select(_db.habitLogs)..where((t) => t.date.equals(toIso(date))))
          .watch()
          .map((rs) => rs.map(_toLog).toList());

  Future<List<ReminderTime>> remindersFor(int habitId) async {
    final rs = await (_db.select(_db.reminders)..where((t) => t.habitId.equals(habitId))).get();
    return rs.map((r) => ReminderTime.fromHm(r.time)).toList();
  }

  Future<List<ReminderRow>> allEnabledReminders() async {
    final rs = await (_db.select(_db.reminders)..where((t) => t.enabled.equals(true))).get();
    return rs.map((r) => ReminderRow(r.habitId, ReminderTime.fromHm(r.time))).toList();
  }
}

