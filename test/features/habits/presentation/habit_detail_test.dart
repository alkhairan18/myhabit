import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rutin/core/l10n/app_localizations.dart';
import 'package:rutin/features/habits/application/providers.dart';
import 'package:rutin/features/habits/domain/habit.dart';
import 'package:rutin/features/habits/domain/habit_log.dart';
import 'package:rutin/features/habits/presentation/habit_detail_screen.dart';
import 'package:rutin/features/habits/presentation/heatmap.dart';

DateTime d(int y, int m, int day) => DateTime.utc(y, m, day);

final habit = Habit(id: 3, name: 'Baca', icon: 'book', color: 0xFF1E88E5,
    frequencyType: FrequencyType.daily, sortOrder: 0, createdAt: d(2026, 11, 1));

Widget wrap(Widget child, {List overrides = const []}) => ProviderScope(
      overrides: [
        clockProvider.overrideWithValue(() => DateTime(2026, 11, 15, 10)),
        ...overrides,
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );

String? txt(WidgetTester t, String key) => t.widget<Text>(find.byKey(Key(key))).data;

void main() {
  final today = d(2026, 11, 15);
  final logs = [for (final day in [13, 14, 15])
    HabitLog(habitId: 3, date: d(2026, 11, day), completed: true)];

  testWidgets('heatmap renders a cell for every day of the last 3 months', (t) async {
    await t.pumpWidget(wrap(Heatmap(habit: habit, completed: {d(2026, 11, 15)}, today: today)));
    final start = DateTime.utc(2026, 8, 15);
    final expected = today.difference(start).inDays + 1;
    final cells = find.byWidgetPredicate(
        (w) => w.key is ValueKey<String> && (w.key as ValueKey<String>).value.startsWith('cell-'));
    expect(cells, findsNWidgets(expected));
  });

  testWidgets('completed cell is announced with date and status', (t) async {
    final h = t.ensureSemantics();
    await t.pumpWidget(wrap(Heatmap(habit: habit, completed: {d(2026, 11, 15)}, today: today)));
    final s = t.getSemantics(find.byKey(const ValueKey('cell-2026-11-15')));
    expect(s.label, contains('2026-11-15'));
    expect(s.label, contains('done'));
    h.dispose();
  });

  testWidgets('detail shows streaks, rates and total', (t) async {
    await t.pumpWidget(wrap(const HabitDetailScreen(habitId: 3), overrides: [
      activeHabitsProvider.overrideWith((ref) => Stream.value([habit])),
      archivedHabitsProvider.overrideWith((ref) => Stream.value([])),
      logsProvider.overrideWith((ref, id) => Stream.value(logs)),
    ]));
    await t.pumpAndSettle();
    expect(txt(t, 'stat-current'), '3');
    expect(txt(t, 'stat-best'), '3');
    expect(txt(t, 'stat-rate7'), '43%');
    expect(txt(t, 'stat-rateAll'), '20%');
    expect(txt(t, 'stat-total'), '3');
  });

  testWidgets('archived habit is still viewable', (t) async {
    await t.pumpWidget(wrap(const HabitDetailScreen(habitId: 3), overrides: [
      activeHabitsProvider.overrideWith((ref) => Stream.value([])),
      archivedHabitsProvider.overrideWith((ref) => Stream.value([habit])),
      logsProvider.overrideWith((ref, id) => Stream.value(logs)),
    ]));
    await t.pumpAndSettle();
    expect(find.text('Baca'), findsOneWidget);
    expect(txt(t, 'stat-total'), '3');
  });

  testWidgets('detail renders milestone badges for 7, 30, and 100 days (FR-25)', (t) async {
    final sevenDayLogs = [
      for (var day = 9; day <= 15; day++)
        HabitLog(habitId: 3, date: d(2026, 11, day), completed: true),
    ];
    await t.pumpWidget(wrap(const HabitDetailScreen(habitId: 3), overrides: [
      activeHabitsProvider.overrideWith((ref) => Stream.value([habit])),
      archivedHabitsProvider.overrideWith((ref) => Stream.value([])),
      logsProvider.overrideWith((ref, id) => Stream.value(sevenDayLogs)),
    ]));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('badge-7')), findsOneWidget);
    expect(find.byKey(const Key('badge-30')), findsOneWidget);
    expect(find.byKey(const Key('badge-100')), findsOneWidget);
  });
}


