import 'package:flutter/material.dart';

import '../../../core/date_utils.dart';
import '../../../core/l10n/app_localizations.dart';
import '../domain/habit.dart';
import '../domain/schedule.dart';

class Heatmap extends StatelessWidget {
  const Heatmap({
    super.key,
    required this.habit,
    required this.completed,
    required this.today,
    this.months = 3,
    this.weekStartsOn = DateTime.monday,
  });

  final Habit habit;
  final Set<DateTime> completed;
  final DateTime today;
  final int months;
  final int weekStartsOn;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final color = Color(habit.color);
    final start = DateTime.utc(today.year, today.month - months, today.day);
    var week = weekStart(start, weekStartsOn: weekStartsOn);

    Widget cell(DateTime day) {
      final inRange = !day.isBefore(start) && !day.isAfter(today);
      if (!inRange) return const SizedBox(width: 18, height: 18);
      final done = completed.contains(day);
      final scheduled = isScheduledOn(habit, day);
      return Semantics(
        key: ValueKey('cell-${toIso(day)}'),
        label: '${toIso(day)}: ${done ? l10n.heatDone : l10n.heatNotDone}',
        excludeSemantics: true,
        child: Container(
          width: 16,
          height: 16,
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: done
                ? color
                : scheduled
                    ? cs.surfaceContainerHighest
                    : null,
            border: scheduled ? null : Border.all(color: cs.outlineVariant),
            borderRadius: BorderRadius.circular(3),
          ),
          child: done
              ? const Icon(Icons.check, size: 11, color: Colors.white)
              : null,
        ),
      );
    }

    final columns = <Widget>[];
    while (!week.isAfter(today)) {
      columns.add(Column(children: [
        for (var i = 0; i < 7; i++) cell(week.add(Duration(days: i))),
      ]));
      week = week.add(const Duration(days: 7));
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Row(children: columns),
    );
  }
}
