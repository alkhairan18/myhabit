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
  });
  final String name;
  final String? description;
  final String icon;
  final int color;
  final FrequencyType frequencyType;
  final Set<int> frequencyDays;
  final int? targetPerWeek;
}

class HabitRepository {
  HabitRepository(this._db);
  final AppDatabase _db;

  Habit _toHabit(HabitRow r) => Habit(
        id: r.id,
        name: r.name,
        description: r.description,
        icon: r.icon,
        color: r.color,
        frequencyType: FrequencyType.values.byName(r.frequencyType),
        frequencyDays: r.frequencyDays.isEmpty
            ? {}
            : r.frequencyDays.split(',').map(int.parse).toSet(),
        targetPerWeek: r.targetPerWeek,
        sortOrder: r.sortOrder,
        createdAt: parseIso(r.createdAt),
        archivedAt: r.archivedAt == null ? null : parseIso(r.archivedAt!),
      );

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
        frequencyType: Value(d.frequencyType.name),
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

