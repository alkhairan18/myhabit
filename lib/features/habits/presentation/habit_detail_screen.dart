import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/tokens.dart';
import '../application/providers.dart';
import '../domain/habit.dart';
import '../domain/stats.dart';
import '../domain/streak.dart';
import 'heatmap.dart';

class HabitDetailScreen extends ConsumerWidget {
  const HabitDetailScreen({super.key, required this.habitId});
  final int habitId;

  int _safeWeekStart(WidgetRef ref) {
    try {
      return ref.watch(weekStartsOnProvider);
    } catch (_) {
      return DateTime.monday;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final habit = ref.watch(habitByIdProvider(habitId));
    if (habit == null) return const Scaffold(body: SizedBox.shrink());
    final today = ref.watch(todayProvider);
    final weekStartsOn = _safeWeekStart(ref);
    final done = <DateTime>{
      for (final l in ref.watch(logsProvider(habitId)).value ?? const [])
        if (l.completed) l.date
    };
    final streak = calculateStreak(habit, done, today, weekStartsOn: weekStartsOn);
    final stats = calculateStats(habit, done, today, weekStartsOn: weekStartsOn);
    final cs = Theme.of(context).colorScheme;
    final color = Color(habit.color);
    final unit = habit.frequencyType == FrequencyType.timesPerWeek
        ? l10n.streakUnitWeeks
        : l10n.streakUnitDays;
    String pct(double r) => '${(r * 100).round()}%';

    Widget rateColumn(String key, String label, double rate) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
              const SizedBox(height: 4),
              Text(
                pct(rate),
                key: Key(key),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(rMicro),
                child: LinearProgressIndicator(
                  value: rate.clamp(0.0, 1.0),
                  minHeight: 5,
                  backgroundColor: cs.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ],
          ),
        );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(iconFor(habit.icon), color: color, size: 22),
            const SizedBox(width: 10),
            Flexible(child: Text(habit.name)),
            if (habit.archivedAt != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(rControl),
                ),
                child: Text(l10n.archivedBadge, style: const TextStyle(fontSize: 11)),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            tooltip: l10n.edit,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/habit/$habitId/edit'),
          ),
        ],
      ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.currentStreak,
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 4),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  children: [
                    Icon(
                      Icons.local_fire_department_rounded,
                      color: streak.current > 0 ? cs.secondary : cs.onSurfaceVariant,
                      size: 28,
                    ),
                    Text(
                      '${streak.current}',
                      key: const Key('stat-current'),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                    ),
                    Text(unit, style: TextStyle(color: cs.onSurfaceVariant)),
                  ],
                ),
                Divider(height: 24, color: cs.outlineVariant),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.bestStreak,
                              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                          const SizedBox(height: 4),
                          Text(
                            '${streak.best}',
                            key: const Key('stat-best'),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.totalDone,
                              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                          const SizedBox(height: 4),
                          Text(
                            '${stats.totalCompleted}',
                            key: const Key('stat-total'),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(rCard),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Row(
              children: [
                rateColumn('stat-rate7', l10n.success7, stats.rate7),
                const SizedBox(width: 16),
                rateColumn('stat-rate30', l10n.success30, stats.rate30),
                const SizedBox(width: 16),
                rateColumn('stat-rateAll', l10n.successAll, stats.rateAll),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.heatmapTitle,
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
            child: Heatmap(
              habit: habit,
              completed: done,
              today: today,
              weekStartsOn: weekStartsOn,
            ),
          ),
        ],
      ),
    );
  }
}
