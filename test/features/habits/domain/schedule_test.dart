import 'package:flutter_test/flutter_test.dart';
import 'package:rutin/features/habits/domain/habit.dart';
import 'package:rutin/features/habits/domain/habit_validation.dart';
import 'package:rutin/features/habits/domain/schedule.dart';

Habit h(FrequencyType t, {Set<int> days = const {}, int? target}) => Habit(
      id: 1, name: 'x', icon: 'i', color: 0, frequencyType: t,
      frequencyDays: days, targetPerWeek: target, sortOrder: 0,
      createdAt: DateTime.utc(2026, 11, 10));

void main() {
  test('daily not scheduled before createdAt', () {
    expect(isScheduledOn(h(FrequencyType.daily), DateTime.utc(2026, 11, 9)), false);
    expect(isScheduledOn(h(FrequencyType.daily), DateTime.utc(2026, 11, 10)), true);
    // Local DateTime on creation day (e.g. UTC+8 midnight = previous UTC day) is still scheduled.
    expect(isScheduledOn(h(FrequencyType.daily), DateTime(2026, 11, 10)), true);
  });
  test('specificDays Mon/Wed/Fri: Tue no, Wed yes', () {
    final x = h(FrequencyType.specificDays, days: {1, 3, 5});
    expect(isScheduledOn(x, DateTime.utc(2026, 11, 17)), false); // Tue
    expect(isScheduledOn(x, DateTime.utc(2026, 11, 18)), true); // Wed
  });
  test('timesPerWeek scheduled any day from createdAt', () {
    expect(isScheduledOn(h(FrequencyType.timesPerWeek, target: 3), DateTime.utc(2026, 11, 14)), true);
  });
  test('blank name -> nameEmpty', () {
    expect(validateHabit(name: '   ', type: FrequencyType.daily), contains(HabitError.nameEmpty));
  });
  test('name 41 chars -> nameTooLong, 40 ok', () {
    expect(validateHabit(name: 'a' * 41, type: FrequencyType.daily), contains(HabitError.nameTooLong));
    expect(validateHabit(name: 'a' * 40, type: FrequencyType.daily), isEmpty);
  });
  test('specificDays without days -> noDaysSelected', () {
    expect(validateHabit(name: 'a', type: FrequencyType.specificDays), contains(HabitError.noDaysSelected));
  });
  test('timesPerWeek target 0 and 8 invalid, 3 valid', () {
    for (final t in [0, 8]) {
      expect(validateHabit(name: 'a', type: FrequencyType.timesPerWeek, target: t), contains(HabitError.invalidWeeklyTarget));
    }
    expect(validateHabit(name: 'a', type: FrequencyType.timesPerWeek, target: 3), isEmpty);
  });
}
