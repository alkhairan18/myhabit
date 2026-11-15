import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/app_localizations.dart';
import 'core/router.dart';
import 'core/theme/app_theme.dart';
import 'features/habits/application/providers.dart';

class RutinApp extends ConsumerWidget {
  const RutinApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = ref.watch(localeCodeProvider);
    return MaterialApp.router(
      onGenerateTitle: (c) => AppLocalizations.of(c).appName,
      routerConfig: ref.watch(routerProvider),
      theme: lightTheme(),
      darkTheme: darkTheme(),
      themeMode: ThemeMode.values.byName(ref.watch(themeModeProvider).name),
      locale: code == null ? null : Locale(code),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
