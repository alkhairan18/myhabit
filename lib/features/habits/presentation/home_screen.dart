import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/tokens.dart';
import '../application/providers.dart';
import '../domain/habit.dart';
import '../domain/schedule.dart';
import '../domain/stats.dart';
import 'habit_card.dart';
import 'week_strip.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _editNote(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    Habit habit,
    DateTime selected,
    DateTime today,
    String? currentNote,
  ) async {
    final ctrl = TextEditingController(text: currentNote ?? '');
    final saved = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l10n.dailyNoteTitle),
        content: TextField(
          key: const Key('note-input'),
          controller: ctrl,
          maxLength: 120,
          decoration: InputDecoration(hintText: l10n.dailyNoteHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            key: const Key('save-note'),
            onPressed: () => Navigator.pop(c, ctrl.text),
            child: Text(l10n.saveNote),
          ),
        ],
      ),
    );
    if (saved != null) {
      await ref
          .read(habitRepositoryProvider)
          .setNote(habit.id, selected, saved, today: today);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final today = ref.watch(todayProvider);
    final selected = ref.watch(selectedDateProvider);
    final habitsAsync = ref.watch(activeHabitsProvider);
    final logs = ref.watch(logsOnDateProvider(selected)).value ?? [];
    final done = {
      for (final l in logs)
        if (l.completed) l.habitId
    };
    final notes = {
      for (final l in logs)
        if (l.note != null && l.note!.isNotEmpty) l.habitId: l.note!
    };
    final habits = habitsAsync.value ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        actions: [
          IconButton(
            key: const Key('open-stats'),
            tooltip: l10n.statsTitle,
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: () => context.push('/stats'),
          ),
          IconButton(
            tooltip: l10n.archiveTitle,
            icon: const Icon(Icons.inventory_2_outlined),
            onPressed: () => context.push('/archive'),
          ),
          IconButton(
            key: const Key('open-settings'),
            tooltip: l10n.settingsTitle,
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      floatingActionButton: habits.isEmpty
          ? null
          : FloatingActionButton.extended(
              tooltip: l10n.addHabit,
              onPressed: () => context.push('/habit/new'),
              icon: const Icon(Icons.add),
              label: Text(l10n.addHabit),
            ),
      body: habitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (all) => all.isEmpty
            ? _Empty(l10n: l10n)
            : _body(context, ref, l10n, all, today, selected, done, notes),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    List<Habit> all,
    DateTime today,
    DateTime selected,
    Set<int> done,
    Map<int, String> notes,
  ) {
    final scheduled = [for (final h in all) if (isScheduledOn(h, selected)) h];
    final p = todayProgress(scheduled, done);
    final ratio = p.target == 0 ? 0.0 : p.done / p.target;
    final allDone = p.target > 0 && p.done == p.target;
    final locale = Localizations.localeOf(context).toString();
    final cs = Theme.of(context).colorScheme;
    final weekStartsOn = ref.watch(weekStartsOnProvider);

    return Column(
      children: [
        WeekStrip(
          selected: selected,
          today: today,
          weekStartsOn: weekStartsOn,
          onSelect: ref.read(selectedDateProvider.notifier).select,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: allDone ? cs.secondary.withAlpha(24) : cs.surface,
              borderRadius: BorderRadius.circular(rCard),
              border: Border.all(
                color: allDone ? cs.secondary.withAlpha(140) : cs.outlineVariant,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEEE, d MMMM', locale).format(selected),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            allDone ? l10n.dailyGoalDone : l10n.dailyGoalPartial,
                            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    if (selected == today) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(rControl),
                        ),
                        child: Text(
                          l10n.todayLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Text(
                      l10n.progressLabel(p.done, p.target),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: allDone ? cs.secondary : cs.primary,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(rMicro),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: ratio),
                    duration: animFast,
                    curve: Curves.easeOutCubic,
                    builder: (_, v, _) => LinearProgressIndicator(
                      value: v,
                      minHeight: 7,
                      backgroundColor: cs.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(
                        allDone ? cs.secondary : cs.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: scheduled.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      l10n.nothingScheduled,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  ),
                )
              : ReorderableListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                  itemCount: scheduled.length,
                  onReorderItem: (oldIndex, newIndex) {
                    final ids = [for (final h in scheduled) h.id];
                    final moved = ids.removeAt(oldIndex);
                    ids.insert(newIndex, moved);
                    ref.read(habitRepositoryProvider).reorder(ids);
                  },
                  itemBuilder: (context, index) {
                    final h = scheduled[index];
                    return HabitCard(
                      key: ValueKey('habit-card-${h.id}'),
                      habit: h,
                      completed: done.contains(h.id),
                      note: notes[h.id],
                      onOpen: () => context.push('/habit/${h.id}'),
                      onNote: () => _editNote(
                          context, ref, l10n, h, selected, today, notes[h.id]),
                      onToggle: () async {
                        HapticFeedback.lightImpact();
                        await ref.read(habitRepositoryProvider).setCompletion(
                            h.id, selected, !done.contains(h.id),
                            today: today);
                        if (selected == today && context.mounted) {
                          await syncReminders(ref);
                        }
                      },
                    );
                  },
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
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(rCard),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: cs.primary.withAlpha(24),
                  borderRadius: BorderRadius.circular(rControl),
                ),
                child: Icon(Icons.spa_outlined, size: 28, color: cs.primary),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.emptyTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.emptyBody,
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurfaceVariant, height: 1.4),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.push('/habit/new'),
                icon: const Icon(Icons.add),
                label: Text(l10n.addHabit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
