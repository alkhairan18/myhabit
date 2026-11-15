import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/date_utils.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/tokens.dart';
import '../application/providers.dart';
import '../domain/schedule.dart';
import '../domain/stats.dart';

class OverallStatsScreen extends ConsumerWidget {
  const OverallStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final today = ref.watch(todayProvider);
    final habits = ref.watch(activeHabitsProvider).value ?? const [];
    final locale = Localizations.localeOf(context).toString();

    final logsByHabit = <int, Set<DateTime>>{};
    var sum7 = 0.0, sum30 = 0.0;
    for (final h in habits) {
      final done = <DateTime>{
        for (final l in ref.watch(logsProvider(h.id)).value ?? const [])
          if (l.completed) l.date
      };
      logsByHabit[h.id] = done;
      final st = calculateStats(h, done, today);
      sum7 += st.rate7;
      sum30 += st.rate30;
    }
    final avg7 = habits.isEmpty ? 0.0 : sum7 / habits.length;
    final avg30 = habits.isEmpty ? 0.0 : sum30 / habits.length;
    final weekStartsOn = ref.watch(weekStartsOnProvider);
    final recap = calculateWeeklyRecap(
      habits,
      logsByHabit,
      today,
      weekStartsOn: weekStartsOn,
    );
    String pct(double r) => '${(r * 100).round()}%';

    double dayRatio(DateTime day) {
      final scheduled = [for (final h in habits) if (isScheduledOn(h, day)) h];
      if (scheduled.isEmpty) return 0.0;
      final doneCount =
          scheduled.where((h) => (logsByHabit[h.id] ?? const {}).contains(day)).length;
      return doneCount / scheduled.length;
    }

    final last7Days = [
      for (var i = 6; i >= 0; i--) today.subtract(Duration(days: i))
    ];
    final curWeek = weekStart(today);
    final last4Weeks = [
      for (var i = 3; i >= 0; i--) curWeek.subtract(Duration(days: i * 7))
    ];

    double weekRatio(DateTime wStart) {
      var total = 0.0;
      var count = 0;
      for (var i = 0; i < 7; i++) {
        final d = wStart.add(Duration(days: i));
        if (d.isAfter(today)) break;
        total += dayRatio(d);
        count++;
      }
      return count == 0 ? 0.0 : total / count;
    }

    Widget statCol(String label, String val, {Key? key, Color? color}) =>
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
              const SizedBox(height: 4),
              Text(
                val,
                key: key,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: color,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
              ),
            ],
          ),
        );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.statsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(rCard),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Row(
              children: [
                statCol(l10n.overallActiveHabits, '${habits.length}',
                    key: const Key('overall-active')),
                statCol(l10n.success7, pct(avg7),
                    key: const Key('overall-rate7'), color: cs.primary),
                statCol(l10n.success30, pct(avg30),
                    key: const Key('overall-rate30')),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.weeklyRecapTitle,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Container(
            key: const Key('weekly-recap-card'),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(rCard),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.weeklyRecapCheckIns,
                        style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.progressLabel(
                          recap.completedCheckIns,
                          recap.scheduledCheckIns,
                        ),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: cs.primary,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.weeklyRecapPerfectDays,
                        style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${recap.perfectDays}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.weeklyRecapTopHabit,
                        style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        recap.topHabitName ?? l10n.weeklyRecapNoTop,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.overallWeeklyTrend,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(rCard),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final day in last7Days)
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 80,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: 18,
                              height: (dayRatio(day) * 72).clamp(4.0, 72.0),
                              decoration: BoxDecoration(
                                color: dayRatio(day) > 0
                                    ? cs.primary
                                    : cs.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(rMicro),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          DateFormat.E(locale).format(day).characters.first,
                          style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.overallMonthlyTrend,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(rCard),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final w in last4Weeks)
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 80,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: 28,
                              height: (weekRatio(w) * 72).clamp(4.0, 72.0),
                              decoration: BoxDecoration(
                                color: weekRatio(w) > 0
                                    ? cs.secondary
                                    : cs.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(rMicro),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          DateFormat('d/M', locale).format(w),
                          style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurfaceVariant,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
