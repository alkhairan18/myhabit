import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/tokens.dart';
import '../habits/application/providers.dart';
import 'settings_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final current = ref.watch(themeModeProvider);
    final options = [
      (AppThemeMode.system, 'theme-system', Icons.brightness_auto_outlined, l10n.themeSystem),
      (AppThemeMode.light, 'theme-light', Icons.light_mode_outlined, l10n.themeLight),
      (AppThemeMode.dark, 'theme-dark', Icons.dark_mode_outlined, l10n.themeDark),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              l10n.themeLabel,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          Material(
            color: cs.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(rCard),
              side: BorderSide(color: cs.outlineVariant),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < options.length; i++) ...[
                  if (i > 0) Divider(height: 1, color: cs.outlineVariant),
                  ListTile(
                    key: Key(options[i].$2),
                    leading: Icon(options[i].$3, color: cs.primary),
                    title: Text(options[i].$4),
                    trailing: current == options[i].$1
                        ? Icon(Icons.check_circle_rounded, color: cs.primary)
                        : null,
                    onTap: () => ref.read(themeModeProvider.notifier).set(options[i].$1),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Icon(Icons.shield_outlined, size: 18, color: cs.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.privacyNote,
                  style: TextStyle(fontSize: 12.5, color: cs.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
