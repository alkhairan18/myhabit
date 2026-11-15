import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/tokens.dart';
import '../domain/habit.dart';

class HabitCard extends StatelessWidget {
  const HabitCard({
    super.key,
    required this.habit,
    required this.completed,
    required this.onToggle,
    required this.onOpen,
    this.note,
    this.onNote,
  });

  final Habit habit;
  final bool completed;
  final VoidCallback onToggle;
  final VoidCallback onOpen;
  final String? note;
  final VoidCallback? onNote;

  String _subtitle(BuildContext context, AppLocalizations l10n) {
    final freq = switch (habit.frequencyType) {
      FrequencyType.daily => l10n.freqDaily,
      FrequencyType.timesPerWeek => l10n.freqWeeklySummary(habit.targetPerWeek ?? 1),
      FrequencyType.specificDays => () {
          final locale = Localizations.localeOf(context).toString();
          final days = habit.frequencyDays.toList()..sort();
          return days
              .map((wd) => DateFormat.E(locale).format(DateTime.utc(2026, 11, 8 + wd)))
              .join(', ');
        }(),
    };
    final desc = habit.description;
    return (desc != null && desc.isNotEmpty) ? '$freq · $desc' : freq;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = Color(habit.color);
    final bg = completed ? color.withAlpha(isDark ? 36 : 20) : cs.surface;
    final border = completed ? color.withAlpha(120) : cs.outlineVariant;
    final hasNote = note != null && note!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rCard),
          side: BorderSide(color: border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withAlpha(isDark ? 48 : 30),
                    borderRadius: BorderRadius.circular(rControl),
                  ),
                  child: Icon(iconFor(habit.icon), color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: completed ? cs.onSurfaceVariant : cs.onSurface,
                          decoration: completed ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _subtitle(context, l10n),
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      if (hasNote) ...[
                        const SizedBox(height: 4),
                        Text(
                          note!,
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: cs.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (onNote != null)
                  IconButton(
                    key: Key('note-${habit.id}'),
                    tooltip: l10n.dailyNoteTitle,
                    icon: Icon(
                      hasNote ? Icons.sticky_note_2_rounded : Icons.note_add_outlined,
                      size: 20,
                      color: hasNote ? cs.primary : cs.onSurfaceVariant,
                    ),
                    onPressed: onNote,
                  ),
                const SizedBox(width: 4),
                Semantics(
                  key: Key('toggle-${habit.id}'),
                  button: true,
                  checked: completed,
                  label: completed
                      ? l10n.markUndone(habit.name)
                      : l10n.markDone(habit.name),
                  excludeSemantics: true,
                  child: InkResponse(
                    onTap: onToggle,
                    radius: 28,
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: AnimatedSwitcher(
                        duration: animFast,
                        switchInCurve: Curves.easeOutCubic,
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: Icon(
                          completed
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          key: ValueKey(completed),
                          color: completed ? color : cs.onSurfaceVariant,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
