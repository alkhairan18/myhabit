import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rutin/app.dart';
import 'package:rutin/features/habits/application/providers.dart';
import 'package:rutin/features/habits/data/database.dart';
import 'package:rutin/features/settings/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  runHabitFlowTests();
}

void runHabitFlowTests() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('onboarding -> create habit -> complete -> detail stats & 200% text scale', (t) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await t.pumpWidget(MediaQuery(
      data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
      child: ProviderScope(
        overrides: [
          clockProvider.overrideWithValue(() => DateTime(2026, 11, 15, 9)),
          appDatabaseProvider.overrideWithValue(db),
          settingsRepositoryProvider.overrideWithValue(SettingsRepository(prefs)),
        ],
        child: const RutinApp(),
      ),
    ));
    await t.pumpAndSettle();

    await t.tap(find.byKey(const Key('start-onboarding')));
    await t.pumpAndSettle();

    await t.tap(find.text('Add habit'));
    await t.pumpAndSettle();
    await t.enterText(find.byKey(const Key('name')), 'Minum air');
    await t.ensureVisible(find.byKey(const Key('save')));
    await t.tap(find.byKey(const Key('save')));
    await t.pumpAndSettle();

    expect(find.text('0/1'), findsOneWidget);
    await t.tap(find.byKey(const Key('toggle-1')));
    await t.pumpAndSettle();
    expect(find.text('1/1'), findsOneWidget);

    await t.tap(find.text('Minum air'));
    await t.pumpAndSettle();
    expect(t.widget<Text>(find.byKey(const Key('stat-current'))).data, '1');
    expect(t.widget<Text>(find.byKey(const Key('stat-total'))).data, '1');
    expect(t.takeException(), isNull);
  });
}
