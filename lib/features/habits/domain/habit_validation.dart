import 'habit.dart';

enum HabitError { nameEmpty, nameTooLong, noDaysSelected, invalidWeeklyTarget }

Set<HabitError> validateHabit({
  required String name,
  required FrequencyType type,
  Set<int> days = const {},
  int? target,
}) {
  final n = name.trim();
  return {
    if (n.isEmpty) HabitError.nameEmpty,
    if (n.length > 40) HabitError.nameTooLong,
    if (type == FrequencyType.specificDays && days.isEmpty) HabitError.noDaysSelected,
    if (type == FrequencyType.timesPerWeek && (target == null || target < 1 || target > 7))
      HabitError.invalidWeeklyTarget,
  };
}
