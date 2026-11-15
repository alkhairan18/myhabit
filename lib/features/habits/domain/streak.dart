import 'dart:math';

import '../../../core/date_utils.dart';
import 'habit.dart';
import 'schedule.dart';

class Streak {
  const Streak(this.current, this.best);
  final int current;
  final int best;
}

const _day = Duration(days: 1);

/// Days for daily/specificDays habits, calendar weeks for timesPerWeek.
Streak calculateStreak(Habit h, Set<DateTime> completed, DateTime today,
    {int weekStartsOn = DateTime.monday}) {
  var run = 0, best = 0;
  if (h.frequencyType == FrequencyType.timesPerWeek) {
    final target = h.targetPerWeek ?? 1;
    final last = weekStart(today, weekStartsOn: weekStartsOn);
    for (var w = weekStart(h.createdAt, weekStartsOn: weekStartsOn);
        !w.isAfter(last);
        w = w.add(const Duration(days: 7))) {
      final end = w.add(const Duration(days: 7));
      final n = completed
          .where((x) => !x.isBefore(w) && x.isBefore(end) && !x.isBefore(h.createdAt))
          .length;
      if (n >= target) {
        best = max(best, ++run);
      } else if (w != last) {
        run = 0;
      }
    }
  } else {
    for (var d = h.createdAt; !d.isAfter(today); d = d.add(_day)) {
      if (!isScheduledOn(h, d)) continue;
      if (completed.contains(d)) {
        best = max(best, ++run);
      } else if (d != today) {
        run = 0;
      }
    }
  }
  return Streak(run, best);
}
