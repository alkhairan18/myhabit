import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/date_utils.dart';

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
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => onSelect(selected.subtract(const Duration(days: 7))),
        ),
        for (var i = 0; i < 7; i++)
          Expanded(child: _day(context, locale, start.add(Duration(days: i)), cs)),
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
    );
  }

  Widget _day(BuildContext context, String locale, DateTime day, ColorScheme cs) {
    final enabled = !day.isAfter(today);
    final isSel = day == selected;
    return Semantics(
      selected: isSel,
      enabled: enabled,
      button: true,
      child: InkWell(
        key: Key('day-${toIso(day)}'),
        onTap: enabled ? () => onSelect(day) : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          decoration: BoxDecoration(
            color: isSel ? cs.primaryContainer : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Opacity(
            opacity: enabled ? 1 : 0.38,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(DateFormat.E(locale).format(day).characters.first.toUpperCase()),
                Text('${day.day}',
                    style: TextStyle(fontWeight: isSel ? FontWeight.bold : null)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
