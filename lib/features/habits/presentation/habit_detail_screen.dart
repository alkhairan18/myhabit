import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../application/providers.dart';
import '../domain/stats.dart';
import '../domain/streak.dart';
import 'heatmap.dart';

class HabitDetailScreen extends ConsumerWidget {
  const HabitDetailScreen({super.key, required this.habitId});
  final int habitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final habit = ref.watch(habitByIdProvider(habitId));
    if (habit == null) return const Scaffold(body: SizedBox.shrink());
    final today = ref.watch(todayProvider);
    final done = <DateTime>{
      for (final l in ref.watch(logsProvider(habitId)).value ?? const [])
        if (l.completed) l.date
    };
    final streak = calculateStreak(habit, done, today);
    final stats = calculateStats(habit, done, today);
    String pct(double r) => '${(r * 100).round()}%';

    Widget stat(String key, String label, String value) => Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(value, key: Key(key), style: Theme.of(context).textTheme.headlineSmall),
              Text(label),
            ]),
          ),
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(habit.name),
        actions: [
          IconButton(
            tooltip: l10n.edit,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/habit/$habitId/edit'),
          ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Wrap(spacing: 8, runSpacing: 8, children: [
          stat('stat-current', l10n.currentStreak, '${streak.current}'),
          stat('stat-best', l10n.bestStreak, '${streak.best}'),
          stat('stat-rate7', l10n.success7, pct(stats.rate7)),
          stat('stat-rate30', l10n.success30, pct(stats.rate30)),
          stat('stat-rateAll', l10n.successAll, pct(stats.rateAll)),
          stat('stat-total', l10n.totalDone, '${stats.totalCompleted}'),
        ]),
        const SizedBox(height: 24),
        Heatmap(habit: habit, completed: done, today: today),
      ]),
    );
  }
}

