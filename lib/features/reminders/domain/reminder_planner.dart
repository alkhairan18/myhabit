import '../../habits/data/habit_repository.dart';
import '../../habits/domain/habit.dart';

class PlannedNotification {
  const PlannedNotification({
    required this.id,
    required this.habitId,
    required this.weekday,
    required this.time,
    required this.title,
  });

  final int id;
  final int habitId;
  final int weekday;
  final ReminderTime time;
  final String title;
}

List<PlannedNotification> planNotifications(
  List<Habit> activeHabits,
  List<ReminderRow> reminders,
) {
  final byId = {
    for (final h in activeHabits)
      if (h.archivedAt == null) h.id: h
  };
  final out = <PlannedNotification>[];
  for (final r in reminders) {
    final h = byId[r.habitId];
    if (h == null) continue;
    final days = h.frequencyType == FrequencyType.specificDays
        ? (h.frequencyDays.toList()..sort())
        : [1, 2, 3, 4, 5, 6, 7];
    final mins = r.time.hour * 60 + r.time.minute;
    for (final wd in days) {
      // Deterministic 31-bit id from (habitId, weekday, minutes).
      final id = ((h.id * 10080) + (wd * 1440) + mins) & 0x7fffffff;
      out.add(PlannedNotification(
          id: id, habitId: h.id, weekday: wd, time: r.time, title: h.name));
    }
  }
  return out;
}
