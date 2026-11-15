import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/app_localizations.dart';
import '../application/providers.dart';
import '../domain/schedule.dart';
import '../domain/stats.dart';
import 'habit_card.dart';
import 'week_strip.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final today = ref.watch(todayProvider);
    final selected = ref.watch(selectedDateProvider);
    final habitsAsync = ref.watch(activeHabitsProvider);
    final done = (ref.watch(logsOnDateProvider(selected)).value ?? [])
        .where((l) => l.completed)
        .map((l) => l.habitId)
        .toSet();
    final habits = habitsAsync.value ?? const [];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appName), actions: [
        IconButton(
          tooltip: l10n.archiveTitle,
          icon: const Icon(Icons.archive_outlined),
          onPressed: () => context.push('/archive'),
        ),
        IconButton(
          key: const Key('open-settings'),
          tooltip: l10n.settingsTitle,
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => context.push('/settings'),
        ),
      ]),
      floatingActionButton: habits.isEmpty
          ? null
          : FloatingActionButton(
              tooltip: l10n.addHabit,
              onPressed: () => context.push('/habit/new'),
              child: const Icon(Icons.add),
            ),
      body: habitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (all) => all.isEmpty
            ? _Empty(l10n: l10n)
            : _body(context, ref, l10n, all, today, selected, done),
      ),
    );
  }

  Widget _body(BuildContext context, WidgetRef ref, AppLocalizations l10n,
      List all, DateTime today, DateTime selected, Set<int> done) {
    final scheduled = [for (final h in all) if (isScheduledOn(h, selected)) h];
    final p = todayProgress(scheduled.cast(), done);
    final locale = Localizations.localeOf(context).toString();
    return Column(
      children: [
        WeekStrip(
          selected: selected,
          today: today,
          onSelect: ref.read(selectedDateProvider.notifier).select,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(DateFormat('EEEE, d MMMM', locale).format(selected),
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              if (selected == today) Text(l10n.todayLabel),
              const SizedBox(width: 12),
              Text(l10n.progressLabel(p.done, p.target),
                  style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
        Expanded(
          child: scheduled.isEmpty
              ? Center(child: Text(l10n.nothingScheduled))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 88),
                  children: [
                    for (final h in scheduled)
                      HabitCard(
                        habit: h,
                        completed: done.contains(h.id),
                        onOpen: () => context.push('/habit/${h.id}'),
                        onToggle: () {
                          HapticFeedback.lightImpact();
                          ref.read(habitRepositoryProvider).setCompletion(
                              h.id, selected, !done.contains(h.id),
                              today: today);
                        },
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.checklist, size: 64),
              const SizedBox(height: 16),
              Text(l10n.emptyTitle, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(l10n.emptyBody, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.push('/habit/new'),
                child: Text(l10n.addHabit),
              ),
            ],
          ),
        ),
      );
}


