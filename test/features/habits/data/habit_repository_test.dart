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
}
