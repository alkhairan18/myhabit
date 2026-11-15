import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/date_utils.dart';
import '../../../core/theme/tokens.dart';

class WeekStrip extends StatelessWidget {
  const WeekStrip({
    super.key,
    required this.selected,
    required this.today,
    required this.onSelect,
    this.weekStartsOn = DateTime.monday,
  });

  final DateTime selected;
  final DateTime today;
  final ValueChanged<DateTime> onSelect;
  final int weekStartsOn;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final start = weekStart(selected, weekStartsOn: weekStartsOn);
    final nextStart = start.add(const Duration(days: 7));
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => onSelect(selected.subtract(const Duration(days: 7))),
          ),
          for (var i = 0; i < 7; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _day(context, locale, start.add(Duration(days: i)), cs),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: nextStart.isAfter(today)
                ? null
                : () {
                    final n = selected.add(const Duration(days: 7));
                    onSelect(n.isAfter(today) ? today : n);
                  },
          ),
        ],
      ),
    );
  }

  Widget _day(BuildContext context, String locale, DateTime day, ColorScheme cs) {
    final enabled = !day.isAfter(today);
    final isSel = day == selected;
    final isToday = day == today;
    final fg = isSel ? cs.onPrimary : cs.onSurface;
    return Semantics(
      label: DateFormat.yMMMMEEEEd(locale).format(day),
      selected: isSel,
      enabled: enabled,
      button: true,
      excludeSemantics: true,
      child: InkWell(
        key: Key('day-${toIso(day)}'),
        onTap: enabled ? () => onSelect(day) : null,
        borderRadius: BorderRadius.circular(rControl),
        child: AnimatedContainer(
          duration: animFast,
          curve: Curves.easeOutCubic,
          constraints: const BoxConstraints(minHeight: 60),
          decoration: BoxDecoration(
            color: isSel ? cs.primary : cs.surface,
            borderRadius: BorderRadius.circular(rControl),
            border: Border.all(
              color: isSel
                  ? cs.primary
                  : isToday
                      ? cs.primary.withAlpha(140)
                      : cs.outlineVariant,
            ),
          ),
          child: Opacity(
            opacity: enabled ? 1 : 0.35,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat.E(locale).format(day).characters.first.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSel ? cs.onPrimary.withAlpha(220) : cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${day.day}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSel || isToday ? FontWeight.w700 : FontWeight.w500,
                    color: fg,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 3),
                // Real state marker: marks today's date in the calendar strip (R-31).
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isToday
                        ? (isSel ? cs.onPrimary : cs.primary)
                        : Colors.transparent,
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
