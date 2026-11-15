import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rutin/app.dart';
import 'package:rutin/features/habits/application/providers.dart';
import 'package:rutin/features/settings/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget buildApp(SharedPreferences prefs) => ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(SettingsRepository(prefs)),
        activeHabitsProvider.overrideWith((ref) => Stream.value([])),
        logsOnDateProvider.overrideWith((ref, d) => Stream.value([])),
      ],
      child: const RutinApp(),
    );

void main() {
  testWidgets('first launch redirects to onboarding; Start marks onboarding done and goes home', (t) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await t.pumpWidget(buildApp(prefs));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('start-onboarding')), findsOneWidget);
    await t.tap(find.byKey(const Key('start-onboarding')));
    await t.pumpAndSettle();
    expect(SettingsRepository(prefs).onboardingDone, true);
    expect(find.byKey(const Key('open-settings')), findsOneWidget);
  });

  testWidgets('selecting Dark updates MaterialApp.themeMode and persists across restart', (t) async {
    SharedPreferences.setMockInitialValues({'onboardingDone': true});
    final prefs = await SharedPreferences.getInstance();
    await t.pumpWidget(buildApp(prefs));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('open-settings')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('theme-dark')));
    await t.pumpAndSettle();
    expect(t.widget<MaterialApp>(find.byType(MaterialApp)).themeMode, ThemeMode.dark);
    expect(SettingsRepository(prefs).themeMode, AppThemeMode.dark);

    await t.pumpWidget(UniqueKeyWidget(child: buildApp(prefs)));
    await t.pumpAndSettle();
    expect(t.widget<MaterialApp>(find.byType(MaterialApp)).themeMode, ThemeMode.dark);
  });
}

class UniqueKeyWidget extends StatelessWidget {
  const UniqueKeyWidget({required this.child}) : super(key: const ValueKey('rebuilt'));
  final Widget child;
  @override
  Widget build(BuildContext context) => child;
}
