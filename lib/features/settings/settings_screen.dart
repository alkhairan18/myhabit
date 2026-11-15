import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/tokens.dart';
import '../habits/application/providers.dart';
import 'settings_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _exportJson(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final jsonStr = await ref.read(habitRepositoryProvider).exportJson();
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l10n.exportJson),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(
              jsonStr,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton(
            key: const Key('export-copy'),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: jsonStr));
              if (c.mounted) {
                Navigator.pop(c);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.exportCopied)),
                );
              }
            },
            child: Text(l10n.exportCopy),
          ),
          TextButton(
            key: const Key('close-export'),
            onPressed: () => Navigator.pop(c),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAll(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l10n.clearAllTitle),
        content: Text(l10n.clearAllBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l10n.cancel)),
          TextButton(
            key: const Key('confirm-clear-all'),
            onPressed: () => Navigator.pop(c, true),
            child: Text(l10n.delete, style: TextStyle(color: Theme.of(c).colorScheme.error)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(habitRepositoryProvider).clearAll();
      await syncReminders(ref);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.clearAllDone)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final currentTheme = ref.watch(themeModeProvider);
    final currentWeek = ref.watch(weekStartsOnProvider);
    final currentLang = ref.watch(localeCodeProvider);

    Widget sectionTitle(String text) => Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            text,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        );

    Widget groupCard(List<Widget> tiles) => Material(
          color: cs.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(rCard),
            side: BorderSide(color: cs.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < tiles.length; i++) ...[
                if (i > 0) Divider(height: 1, color: cs.outlineVariant),
                tiles[i],
              ],
            ],
          ),
        );

    final themeOptions = [
      (AppThemeMode.system, 'theme-system', Icons.brightness_auto_outlined, l10n.themeSystem),
      (AppThemeMode.light, 'theme-light', Icons.light_mode_outlined, l10n.themeLight),
      (AppThemeMode.dark, 'theme-dark', Icons.dark_mode_outlined, l10n.themeDark),
    ];
    final weekOptions = [
      (DateTime.monday, 'week-monday', l10n.weekStartMonday),
      (DateTime.sunday, 'week-sunday', l10n.weekStartSunday),
    ];
    final langOptions = [
      (null, 'lang-system', l10n.langSystem),
      ('id', 'lang-id', l10n.langId),
      ('en', 'lang-en', l10n.langEn),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          sectionTitle(l10n.themeLabel),
          groupCard([
            for (final o in themeOptions)
              ListTile(
                key: Key(o.$2),
                leading: Icon(o.$3, color: cs.primary),
                title: Text(o.$4),
                trailing: currentTheme == o.$1
                    ? Icon(Icons.check_circle_rounded, color: cs.primary)
                    : null,
                onTap: () => ref.read(themeModeProvider.notifier).set(o.$1),
              ),
          ]),
          sectionTitle(l10n.weekStartLabel),
          groupCard([
            for (final w in weekOptions)
              ListTile(
                key: Key(w.$2),
                leading: Icon(Icons.calendar_today_outlined, color: cs.primary),
                title: Text(w.$3),
                trailing: currentWeek == w.$1
                    ? Icon(Icons.check_circle_rounded, color: cs.primary)
                    : null,
                onTap: () => ref.read(weekStartsOnProvider.notifier).set(w.$1),
              ),
          ]),
          sectionTitle(l10n.languageLabel),
          groupCard([
            for (final l in langOptions)
              ListTile(
                key: Key(l.$2),
                leading: Icon(Icons.language_outlined, color: cs.primary),
                title: Text(l.$3),
                trailing: currentLang == l.$1
                    ? Icon(Icons.check_circle_rounded, color: cs.primary)
                    : null,
                onTap: () => ref.read(localeCodeProvider.notifier).set(l.$1),
              ),
          ]),
          sectionTitle(l10n.dataSectionLabel),
          groupCard([
            ListTile(
              key: const Key('export-json'),
              leading: Icon(Icons.download_outlined, color: cs.primary),
              title: Text(l10n.exportJson),
              onTap: () => _exportJson(context, ref, l10n),
            ),
            ListTile(
              key: const Key('clear-all'),
              leading: Icon(Icons.delete_forever_outlined, color: cs.error),
              title: Text(l10n.clearAllData, style: TextStyle(color: cs.error)),
              onTap: () => _clearAll(context, ref, l10n),
            ),
          ]),
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
