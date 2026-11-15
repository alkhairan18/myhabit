import 'dart:math';

import '../../../core/date_utils.dart';
import 'habit.dart';
import 'schedule.dart';

class HabitStats {
  const HabitStats(this.rate7, this.rate30, this.rateAll, this.totalCompleted);
  final double rate7;
  final double rate30;
  final double rateAll;
  final int totalCompleted;
}

const _day = Duration(days: 1);

double _rate(Habit h, Set<DateTime> done, DateTime from, DateTime today, int weekStartsOn) {
  final start = from.isBefore(h.createdAt) ? h.createdAt : from;
  var num = 0, den = 0;
  if (h.frequencyType == FrequencyType.timesPerWeek) {
    final x = h.targetPerWeek ?? 1;
    for (var w = weekStart(start, weekStartsOn: weekStartsOn);
        !w.isAfter(today);
        w = w.add(const Duration(days: 7))) {
      final n = done
          .where((d) => !d.isBefore(w) && !d.isBefore(start) && !d.isAfter(today) &&
              d.isBefore(w.add(const Duration(days: 7))))
          .length;
      num += min(n, x);
      den += x;
    }
  } else {
    for (var d = start; !d.isAfter(today); d = d.add(_day)) {
      if (!isScheduledOn(h, d)) continue;
      den++;
      if (done.contains(d)) num++;
    }
  }
  return den == 0 ? 0.0 : num / den;
}

HabitStats calculateStats(Habit h, Set<DateTime> completed, DateTime today,
    {int weekStartsOn = DateTime.monday}) {
  double r(int days) =>
      _rate(h, completed, today.subtract(Duration(days: days - 1)), today, weekStartsOn);
  return HabitStats(r(7), r(30), _rate(h, completed, h.createdAt, today, weekStartsOn),
      completed.length);
}

({int done, int target}) todayProgress(List<Habit> scheduledToday, Set<int> completedHabitIds) =>
    (done: scheduledToday.where((h) => completedHabitIds.contains(h.id)).length,
        target: scheduledToday.length);

const badgeMilestones = [7, 30, 100];

List<int> unlockedBadges(int bestStreak) =>
    [for (final m in badgeMilestones) if (bestStreak >= m) m];

class WeeklyRecap {
  const WeeklyRecap({
    required this.completedCheckIns,
    required this.scheduledCheckIns,
    required this.perfectDays,
    this.topHabitName,
  });

  final int completedCheckIns;
  final int scheduledCheckIns;
  final int perfectDays;
  final String? topHabitName;
}

WeeklyRecap calculateWeeklyRecap(
  List<Habit> habits,
  Map<int, Set<DateTime>> logsByHabit,
  DateTime today, {
  int weekStartsOn = DateTime.monday,
}) {
  final start = weekStart(today, weekStartsOn: weekStartsOn);
  var completed = 0;
  var scheduled = 0;
  var perfectDays = 0;
  final countsByHabit = <int, int>{};

  for (var d = start; !d.isAfter(today); d = d.add(_day)) {
    final due = [
      for (final h in habits)
        if (!d.isBefore(h.createdAt) && isScheduledOn(h, d)) h
    ];
    if (due.isEmpty) continue;
    var doneOnDay = 0;
    for (final h in due) {
      scheduled++;
      if ((logsByHabit[h.id] ?? const {}).contains(d)) {
        completed++;
        doneOnDay++;
        countsByHabit[h.id] = (countsByHabit[h.id] ?? 0) + 1;
      }
    }
    if (doneOnDay == due.length) perfectDays++;
  }

  String? topName;
  var topCount = 0;
  for (final h in habits) {
    final c = countsByHabit[h.id] ?? 0;
    if (c > topCount) {
      topCount = c;
      topName = h.name;
    }
  }

  return WeeklyRecap(
    completedCheckIns: completed,
    scheduledCheckIns: scheduled,
    perfectDays: perfectDays,
    topHabitName: topName,
  );
}
