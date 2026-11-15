import 'package:flutter_test/flutter_test.dart';
import 'package:rutin/features/habits/domain/habit.dart';
import 'package:rutin/features/habits/domain/streak.dart';

DateTime d(int y, int m, int day) => DateTime.utc(y, m, day);
Set<DateTime> run(DateTime from, int n) =>
    {for (var i = 0; i < n; i++) from.add(Duration(days: i))};

Habit h(DateTime created, {FrequencyType t = FrequencyType.daily, Set<int> days = const {}, int? target}) =>
    Habit(id: 1, name: 'x', icon: 'i', color: 0, frequencyType: t,
        frequencyDays: days, targetPerWeek: target, sortOrder: 0, createdAt: created);

void main() {
  final today = d(2026, 11, 15);
  test('daily 3 consecutive up to today', () {
    final s = calculateStreak(h(d(2026, 11, 1)), run(d(2026, 11, 13), 3), today);
    expect((s.current, s.best), (3, 3));
  });
  test('today pending keeps streak alive', () {
    final s = calculateStreak(h(d(2026, 11, 1)), run(d(2026, 11, 12), 3), today);
    expect(s.current, 3);
  });
  test('yesterday missed -> current 0', () {
    final s = calculateStreak(h(d(2026, 11, 1)), run(d(2026, 11, 10), 3), today);
    expect(s.current, 0);
  });
  test('best survives a break', () {
    final done = {...run(d(2026, 11, 1), 5), ...run(d(2026, 11, 14), 2)};
    final s = calculateStreak(h(d(2026, 11, 1)), done, today);
    expect((s.current, s.best), (2, 5));
  });
  test('specificDays skips unscheduled days', () {
    // Mon 9, Wed 11, Fri 13 done; Tue/Thu skipped. today Sat 14
    final done = {d(2026, 11, 9), d(2026, 11, 11), d(2026, 11, 13)};
    final s = calculateStreak(h(d(2026, 11, 9), t: FrequencyType.specificDays, days: {1, 3, 5}), done, d(2026, 11, 14));
    expect(s.current, 3);
  });
  test('crosses month boundary', () {
    final s = calculateStreak(h(d(2026, 1, 20)), run(d(2026, 1, 30), 4), d(2026, 2, 2));
    expect(s.current, 4);
  });
  test('crosses year boundary', () {
    final s = calculateStreak(h(d(2025, 12, 20)), run(d(2025, 12, 30), 4), d(2026, 1, 2));
    expect(s.current, 4);
  });
  test('timesPerWeek target 3: 2 weeks met + current week 1/3', () {
    // weeks start Mon 2026-10-26, 2026-11-02, current 2026-11-09
    final done = {...run(d(2026, 10, 26), 3), ...run(d(2026, 11, 2), 3), d(2026, 11, 9)};
    final s = calculateStreak(h(d(2026, 10, 26), t: FrequencyType.timesPerWeek, target: 3), done, today);
    expect(s.current, 2);
  });
  test('logs before createdAt ignored; empty -> 0/0', () {
    final s = calculateStreak(h(d(2026, 11, 14)), run(d(2026, 11, 10), 3), today);
    expect((s.current, s.best), (0, 0));
    expect(calculateStreak(h(d(2026, 11, 1)), {}, today).best, 0);
  });
}
