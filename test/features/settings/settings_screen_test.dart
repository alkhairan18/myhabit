import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rutin/app.dart';
import 'package:rutin/features/habits/application/providers.dart';
import 'package:rutin/features/habits/data/database.dart';
import 'package:rutin/features/habits/data/habit_repository.dart';
import 'package:rutin/features/habits/domain/habit.dart';
import 'package:rutin/features/habits/domain/habit_log.dart';
import 'package:rutin/features/settings/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpyRepo extends HabitRepository {
  SpyRepo() : super(AppDatabase(NativeDatabase.memory()));
  final created = <HabitDraft>[];
  bool cleared = false;

  @override
  Future<int> create(HabitDraft d,
      {required DateTime createdAt, List<ReminderTime> reminders = const []}) async {
    created.add(d);
    return created.length;
  }

  @override
  Stream<List<Habit>> watchActive() => Stream.value(const []);

  @override
  Stream<List<HabitLog>> watchLogsOn(DateTime date) => Stream.value(const []);

  @override
  Future<List<ReminderRow>> allEnabledReminders() async => const [];

  @override
  Future<String> exportJson() async => '{"habits":[{"name":"Baca"}]}';

  @override
  Future<void> clearAll() async {
    cleared = true;
  }
}

Widget buildApp(SharedPreferences prefs, {SpyRepo? repo}) => ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(SettingsRepository(prefs)),
        if (repo != null) habitRepositoryProvider.overrideWithValue(repo),
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

  testWidgets('onboarding supports 3 steps, skip, and starter habits creation (FR-50, FR-51)', (t) async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repo = SpyRepo();

    await t.pumpWidget(buildApp(prefs, repo: repo));
    await t.pumpAndSettle();

    await t.tap(find.byKey(const Key('next-onboarding')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('next-onboarding')));
    await t.pumpAndSettle();

    await t.tap(find.byKey(const Key('starter-water')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('start-onboarding')));
    await t.pumpAndSettle();

    expect(repo.created.length, 1);
    expect(repo.created.single.icon, 'water');
  });

  testWidgets('settings: week start, language, export JSON, and clear all data (FR-41, FR-42, FR-44, FR-45)', (t) async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    SharedPreferences.setMockInitialValues({'onboardingDone': true});
    final prefs = await SharedPreferences.getInstance();
    final repo = SpyRepo();

    await t.pumpWidget(buildApp(prefs, repo: repo));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('open-settings')));
    await t.pumpAndSettle();

    await t.ensureVisible(find.byKey(const Key('week-sunday')));
    await t.tap(find.byKey(const Key('week-sunday')));
    await t.pumpAndSettle();
    expect(SettingsRepository(prefs).weekStartsOn, DateTime.sunday);

    await t.ensureVisible(find.byKey(const Key('lang-id')));
    await t.tap(find.byKey(const Key('lang-id')));
    await t.pumpAndSettle();
    expect(SettingsRepository(prefs).localeCode, 'id');

    await t.ensureVisible(find.byKey(const Key('export-json')));
    await t.tap(find.byKey(const Key('export-json')));
    await t.pumpAndSettle();
    expect(find.textContaining('"Baca"'), findsOneWidget);
    await t.tap(find.byKey(const Key('close-export')));
    await t.pumpAndSettle();

    await t.ensureVisible(find.byKey(const Key('clear-all')));
    await t.tap(find.byKey(const Key('clear-all')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('confirm-clear-all')));
    await t.pumpAndSettle();
    expect(repo.cleared, true);
  });
}

class UniqueKeyWidget extends StatelessWidget {
  const UniqueKeyWidget({required this.child}) : super(key: const ValueKey('rebuilt'));
  final Widget child;
  @override
  Widget build(BuildContext context) => child;
}
