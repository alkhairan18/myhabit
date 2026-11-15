import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rutin/features/habits/data/database.dart';
import 'package:rutin/features/habits/data/habit_repository.dart';
import 'package:rutin/features/habits/domain/habit.dart';

DateTime d(int y, int m, int day) => DateTime.utc(y, m, day);
const draft = HabitDraft(
    name: 'Minum air', icon: 'water', color: 0xFF2196F3, frequencyType: FrequencyType.daily);

void main() {
  late AppDatabase db;
  late HabitRepository repo;
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = HabitRepository(db);
  });
  tearDown(() => db.close());

  test('create then watchActive emits habit with increasing sortOrder', () async {
    await repo.create(draft, createdAt: d(2026, 11, 1));
    await repo.create(draft, createdAt: d(2026, 11, 1));
    final hs = await repo.watchActive().first;
    expect(hs.map((h) => h.sortOrder).toList(), [0, 1]);
  });

  test('setCompletion twice same day keeps one log', () async {
    final id = await repo.create(draft, createdAt: d(2026, 11, 1));
    await repo.setCompletion(id, d(2026, 11, 5), true, today: d(2026, 11, 5));
    await repo.setCompletion(id, d(2026, 11, 5), true, today: d(2026, 11, 5));
    expect((await repo.watchLogs(id).first).length, 1);
  });

  test('future date throws FutureDateError', () async {
    final id = await repo.create(draft, createdAt: d(2026, 11, 1));
    expect(() => repo.setCompletion(id, d(2026, 11, 6), true, today: d(2026, 11, 5)),
        throwsA(isA<FutureDateError>()));
  });

  test('date before createdAt throws BeforeCreationError; local creation date succeeds', () async {
    final id = await repo.create(draft, createdAt: d(2026, 11, 3));
    expect(() => repo.setCompletion(id, d(2026, 11, 2), true, today: d(2026, 11, 5)),
        throwsA(isA<BeforeCreationError>()));
    await repo.setCompletion(id, DateTime(2026, 11, 3), true, today: DateTime(2026, 11, 5));
    expect((await repo.watchLogs(id).first).length, 1);
  });

  test('archive moves habit, keeps logs', () async {
    final id = await repo.create(draft, createdAt: d(2026, 11, 1));
    await repo.setCompletion(id, d(2026, 11, 2), true, today: d(2026, 11, 5));
    await repo.archive(id, d(2026, 11, 5));
    expect(await repo.watchActive().first, isEmpty);
    expect((await repo.watchArchived().first).length, 1);
    expect((await repo.watchLogs(id).first).length, 1);
  });

  test('delete cascades logs and reminders', () async {
    final id = await repo.create(draft,
        createdAt: d(2026, 11, 1), reminders: [const ReminderTime(7, 30)]);
    await repo.setCompletion(id, d(2026, 11, 2), true, today: d(2026, 11, 5));
    await repo.delete(id);
    expect(await db.select(db.habitLogs).get(), isEmpty);
    expect(await db.select(db.reminders).get(), isEmpty);
  });

  test('reminders round-trip as HH:mm', () async {
    final id = await repo.create(draft,
        createdAt: d(2026, 11, 1), reminders: [const ReminderTime(7, 5)]);
    expect((await repo.remindersFor(id)).single.toHm(), '07:05');
  });

  test('reorder updates sortOrder in watchActive', () async {
    final id1 = await repo.create(draft, createdAt: d(2026, 11, 1));
    final id2 = await repo.create(draft, createdAt: d(2026, 11, 1));
    final id3 = await repo.create(draft, createdAt: d(2026, 11, 1));
    await repo.reorder([id3, id1, id2]);
    final hs = await repo.watchActive().first;
    expect(hs.map((h) => h.id).toList(), [id3, id1, id2]);
  });

  test('setNote stores daily note and preserves completion state', () async {
    final id = await repo.create(draft, createdAt: d(2026, 11, 1));
    await repo.setCompletion(id, d(2026, 11, 5), true, today: d(2026, 11, 5));
    await repo.setNote(id, d(2026, 11, 5), 'Segar sekali', today: d(2026, 11, 5));
    final log = (await repo.watchLogs(id).first).single;
    expect(log.completed, true);
    expect(log.note, 'Segar sekali');
  });

  test('exportJson produces valid JSON with habits, logs, and reminders', () async {
    final id = await repo.create(draft,
        createdAt: d(2026, 11, 1), reminders: [const ReminderTime(8, 0)]);
    await repo.setCompletion(id, d(2026, 11, 5), true, today: d(2026, 11, 5));
    final jsonStr = await repo.exportJson();
    final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
    expect((decoded['habits'] as List).length, 1);
    expect((decoded['logs'] as List).length, 1);
    expect((decoded['reminders'] as List).length, 1);
  });

  test('clearAll deletes all habits, logs, and reminders', () async {
    final id = await repo.create(draft,
        createdAt: d(2026, 11, 1), reminders: [const ReminderTime(8, 0)]);
    await repo.setCompletion(id, d(2026, 11, 5), true, today: d(2026, 11, 5));
    await repo.clearAll();
    expect(await repo.watchActive().first, isEmpty);
    expect(await db.select(db.habitLogs).get(), isEmpty);
    expect(await db.select(db.reminders).get(), isEmpty);
  });

  test('timeOfDay round-trips on create and update', () async {
    const morningDraft = HabitDraft(
      name: 'Lari pagi',
      icon: 'run',
      color: 0xFF2E6F40,
      frequencyType: FrequencyType.daily,
      timeOfDay: TimeOfDaySlot.morning,
    );
    final id = await repo.create(morningDraft, createdAt: d(2026, 11, 1));
    expect((await repo.getHabit(id))!.timeOfDay, TimeOfDaySlot.morning);
    await repo.update(
      id,
      const HabitDraft(
        name: 'Lari sore',
        icon: 'run',
        color: 0xFF2E6F40,
        frequencyType: FrequencyType.daily,
        timeOfDay: TimeOfDaySlot.evening,
      ),
    );
    expect((await repo.getHabit(id))!.timeOfDay, TimeOfDaySlot.evening);
  });

  test('exportCsv formats habits and logs and sanitizes formula prefixes', () async {
    final id = await repo.create(draft, createdAt: d(2026, 11, 1));
    await repo.setCompletion(id, d(2026, 11, 5), true, today: d(2026, 11, 5));
    await repo.setNote(id, d(2026, 11, 5), '=SUM(1,2)', today: d(2026, 11, 5));
    final csv = await repo.exportCsv();
    expect(csv, contains('habit_id,habit_name,frequency_type,time_of_day,date,completed,note'));
    expect(csv, contains('Minum air'));
    expect(csv, contains("'=SUM(1,2)"));
  });

  test('importJson restores exported habits, logs, and reminders and rejects bad input', () async {
    final id = await repo.create(
      const HabitDraft(
        name: 'Meditasi',
        icon: 'self',
        color: 0xFF2E6F40,
        frequencyType: FrequencyType.specificDays,
        frequencyDays: {1, 3, 5},
        timeOfDay: TimeOfDaySlot.morning,
      ),
      createdAt: d(2026, 11, 1),
      reminders: [const ReminderTime(6, 30)],
    );
    await repo.setCompletion(id, d(2026, 11, 2), true, today: d(2026, 11, 5));
    await repo.setNote(id, d(2026, 11, 2), 'Tenang', today: d(2026, 11, 5));
    final backup = await repo.exportJson();

    await repo.clearAll();
    expect(await repo.watchActive().first, isEmpty);

    final count = await repo.importJson(backup);
    expect(count, 1);
    final restored = (await repo.watchActive().first).single;
    expect(restored.name, 'Meditasi');
    expect(restored.timeOfDay, TimeOfDaySlot.morning);
    expect(restored.frequencyDays, {1, 3, 5});
    final logs = await repo.watchLogs(restored.id).first;
    expect(logs.single.completed, true);
    expect(logs.single.note, 'Tenang');
    expect((await repo.remindersFor(restored.id)).single.toHm(), '06:30');

    expect(() => repo.importJson('not-json'), throwsFormatException);
  });
}
