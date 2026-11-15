import 'package:flutter_test/flutter_test.dart';
import 'package:rutin/features/habits/domain/habit.dart';
import 'package:rutin/features/habits/domain/stats.dart';

DateTime d(int y, int m, int day) => DateTime.utc(y, m, day);
Habit h(DateTime created, {FrequencyType t = FrequencyType.daily, int? target}) =>
    Habit(id: 1, name: 'x', icon: 'i', color: 0, frequencyType: t,
        targetPerWeek: target, sortOrder: 0, createdAt: created);

void main() {
  final today = d(2026, 11, 15);
  test('3 of 4 scheduled days -> rate7 0.75', () {
    final s = calculateStats(h(d(2026, 11, 12)), {d(2026, 11, 12), d(2026, 11, 13), d(2026, 11, 15)}, today);
    expect(s.rate7, 0.75);
    expect(s.totalCompleted, 3);
  });
  test('no scheduled days -> 0.0 not NaN', () {
    expect(calculateStats(h(d(2026, 11, 16)), {}, today).rateAll, 0.0);
  });
  test('timesPerWeek rate capped per week', () {
    final s = calculateStats(h(d(2026, 11, 9), t: FrequencyType.timesPerWeek, target: 3),
        {d(2026, 11, 9), d(2026, 11, 10)}, today);
    expect(s.rateAll, closeTo(2 / 3, 1e-9));
  });
  test('todayProgress counts done vs scheduled', () {
    final hs = [for (var i = 1; i <= 5; i++) Habit(id: i, name: 'x', icon: 'i', color: 0,
        frequencyType: FrequencyType.daily, sortOrder: i, createdAt: d(2026, 1, 1))];
    expect(todayProgress(hs, {1, 2, 3}), (done: 3, target: 5));
  });
  test('unlockedBadges returns reached milestones from [7, 30, 100]', () {
    expect(unlockedBadges(0), isEmpty);
    expect(unlockedBadges(6), isEmpty);
    expect(unlockedBadges(7), [7]);
    expect(unlockedBadges(45), [7, 30]);
    expect(unlockedBadges(120), [7, 30, 100]);
  });
  test('calculateWeeklyRecap summarizes completed, scheduled, perfectDays, and topHabitName', () {
    final h1 = Habit(
      id: 1,
      name: 'Minum air',
      icon: 'water',
      color: 0,
      frequencyType: FrequencyType.daily,
      sortOrder: 0,
      createdAt: d(2026, 11, 1),
    );
    final h2 = Habit(
      id: 2,
      name: 'Membaca',
      icon: 'book',
      color: 0,
      frequencyType: FrequencyType.daily,
      sortOrder: 1,
      createdAt: d(2026, 11, 1),
    );
    // Week starting Monday 2026-11-09 through Wednesday 2026-11-11 (3 days, 6 scheduled total).
    final recap = calculateWeeklyRecap(
      [h1, h2],
      {
        1: {d(2026, 11, 9), d(2026, 11, 10), d(2026, 11, 11)},
        2: {d(2026, 11, 9)},
      },
      d(2026, 11, 11),
    );
    expect(recap.completedCheckIns, 4);
    expect(recap.scheduledCheckIns, 6);
    expect(recap.perfectDays, 1);
    expect(recap.topHabitName, 'Minum air');
  });
}
