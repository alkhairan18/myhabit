import 'package:flutter/material.dart';

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
  });

  final Habit habit;
  final bool completed;
  final VoidCallback onToggle;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = Color(habit.color);
    return Card(
      child: ListTile(
        onTap: onOpen,
        leading: CircleAvatar(
          backgroundColor: color,
          foregroundColor: ThemeData.estimateBrightnessForColor(color) == Brightness.dark
              ? Colors.white
              : Colors.black,
          child: Icon(iconFor(habit.icon)),
        ),
        title: Text(
          habit.name,
          style: completed ? const TextStyle(decoration: TextDecoration.lineThrough) : null,
        ),
        trailing: Semantics(
          key: Key('toggle-${habit.id}'),
          button: true,
          checked: completed,
          label: completed ? l10n.markUndone(habit.name) : l10n.markDone(habit.name),
          excludeSemantics: true,
          child: InkResponse(
            onTap: onToggle,
            radius: 28,
            child: SizedBox(
              width: 48,
              height: 48,
              child: AnimatedSwitcher(
                duration: animFast,
                child: Icon(
                  completed ? Icons.check_circle : Icons.radio_button_unchecked,
                  key: ValueKey(completed),
                  color: completed ? color : null,
                  size: 32,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
