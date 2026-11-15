import '../../../core/date_utils.dart';
import 'habit.dart';

bool isScheduledOn(Habit h, DateTime day) {
  final d = dateOnly(day);
  if (d.isBefore(h.createdAt)) return false;
  return h.frequencyType == FrequencyType.specificDays
      ? h.frequencyDays.contains(d.weekday)
      : true;
}
