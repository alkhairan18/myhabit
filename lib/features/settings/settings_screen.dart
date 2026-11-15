import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../habits/application/providers.dart';
import 'settings_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final current = ref.watch(themeModeProvider);
    final options = [
      (AppThemeMode.system, 'theme-system', l10n.themeSystem),
      (AppThemeMode.light, 'theme-light', l10n.themeLight),
      (AppThemeMode.dark, 'theme-dark', l10n.themeDark),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(l10n.themeLabel,
                style: Theme.of(context).textTheme.titleSmall),
          ),
          for (final (mode, key, label) in options)
            ListTile(
              key: Key(key),
              title: Text(label),
              trailing: current == mode ? const Icon(Icons.check) : null,
              onTap: () => ref.read(themeModeProvider.notifier).set(mode),
            ),
        ],
      ),
    );
  }
}
