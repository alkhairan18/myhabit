import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rutin/core/l10n/app_localizations.dart';
import 'package:rutin/features/habits/application/providers.dart';
import 'package:rutin/features/habits/domain/habit.dart';
import 'package:rutin/features/habits/domain/habit_log.dart';
import 'package:rutin/features/habits/presentation/overall_stats_screen.dart';
import 'package:rutin/features/settings/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

DateTime d(int y, int m, int day) => DateTime.utc(y, m, day);

void main() {
  testWidgets('OverallStatsScreen shows active habits count, 7d/30d rates, and charts (FR-23)', (t) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final h1 = Habit(
      id: 1,
      name: 'Minum air',
      icon: 'water',
      color: 0xFF1E88E5,
      frequencyType: FrequencyType.daily,
      sortOrder: 0,
      createdAt: d(2026, 11, 1),
    );
    final logs = [
      for (final day in [13, 14, 15])
        HabitLog(habitId: 1, date: d(2026, 11, day), completed: true),
    ];

    await t.pumpWidget(ProviderScope(
      overrides: [
        clockProvider.overrideWithValue(() => DateTime(2026, 11, 15, 10)),
        settingsRepositoryProvider.overrideWithValue(SettingsRepository(prefs)),
        activeHabitsProvider.overrideWith((ref) => Stream.value([h1])),
        logsProvider.overrideWith((ref, id) => Stream.value(logs)),
      ],
      child: const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: OverallStatsScreen(),
      ),
    ));
    await t.pumpAndSettle();

    expect(t.widget<Text>(find.byKey(const Key('overall-active'))).data, '1');
    expect(t.widget<Text>(find.byKey(const Key('overall-rate7'))).data, '43%');
    expect(find.byKey(const Key('weekly-recap-card')), findsOneWidget);
    expect(find.text('3/7'), findsOneWidget);
    expect(find.text('Last 7 days performance'), findsOneWidget);
    expect(find.text('Last 4 weeks performance'), findsOneWidget);
  });
}
