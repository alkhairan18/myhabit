import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rutin/app.dart';
import 'package:rutin/features/habits/application/providers.dart';
import 'package:rutin/features/settings/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('RutinApp builds a MaterialApp', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(SettingsRepository(prefs)),
        activeHabitsProvider.overrideWith((ref) => Stream.value([])),
        logsOnDateProvider.overrideWith((ref, d) => Stream.value([])),
      ],
      child: const RutinApp(),
    ));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
