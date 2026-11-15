import 'habit.dart';

bool isScheduledOn(Habit h, DateTime day) {
  if (day.isBefore(h.createdAt)) return false;
  return h.frequencyType == FrequencyType.specificDays
      ? h.frequencyDays.contains(day.weekday)
      : true;
}
