import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:rutin/core/l10n/app_localizations.dart';
import 'package:rutin/features/habits/application/providers.dart';
import 'package:rutin/features/habits/data/database.dart';
import 'package:rutin/features/habits/data/habit_repository.dart';
import 'package:rutin/features/habits/domain/habit.dart';
import 'package:rutin/features/habits/domain/habit_log.dart';
import 'package:rutin/features/habits/presentation/home_screen.dart';
import 'package:rutin/features/habits/presentation/week_strip.dart';

DateTime d(int y, int m, int day) => DateTime.utc(y, m, day);

class SpyRepo extends HabitRepository {
  SpyRepo() : super(AppDatabase(NativeDatabase.memory()));
  final calls = <(int, DateTime, bool)>[];
  @override
  Future<void> setCompletion(int habitId, DateTime date, bool completed,
      {required DateTime today}) async {
    calls.add((habitId, date, completed));
  }
}

Habit habit(int id, {String name = 'Minum air'}) => Habit(
    id: id, name: name, icon: 'water', color: 0xFF1E88E5,
    frequencyType: FrequencyType.daily, sortOrder: id, createdAt: d(2026, 1, 1));

Widget app(List<Habit> habits, List<HabitLog> logs, SpyRepo spy, DateTime Function() clock) =>
    ProviderScope(
      overrides: [
        clockProvider.overrideWithValue(clock),
        habitRepositoryProvider.overrideWithValue(spy),
        activeHabitsProvider.overrideWith((ref) => Stream.value(habits)),
        logsOnDateProvider.overrideWith((ref, date) => Stream.value(logs)),
      ],
      child: MaterialApp.router(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: GoRouter(routes: [
          GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
          GoRoute(path: '/habit/new', builder: (_, _) => const Scaffold(body: Text('new'))),
        ]),
      ),
    );

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final now = DateTime(2026, 11, 15, 14);

  testWidgets('no habits -> empty state', (t) async {
    await t.pumpWidget(app([], [], SpyRepo(), () => now));
    await t.pump();
    expect(find.text('No habits yet'), findsOneWidget);
    expect(find.text('Add habit'), findsOneWidget);
  });

  testWidgets('progress shows 3/5', (t) async {
    final hs = [for (var i = 1; i <= 5; i++) habit(i, name: 'H$i')];
    final logs = [for (var i = 1; i <= 3; i++)
      HabitLog(habitId: i, date: d(2026, 11, 15), completed: true)];
    await t.pumpWidget(app(hs, logs, SpyRepo(), () => now));
    await t.pump();
    expect(find.text('3/5'), findsOneWidget);
  });

  testWidgets('tap toggles completion with haptic; tap again undoes', (t) async {
    final spy = SpyRepo();
    var haptics = 0;
    t.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (c) async {
      if (c.method == 'HapticFeedback.vibrate') haptics++;
      return null;
    });
    await t.pumpWidget(app([habit(1), habit(2, name: 'Baca')],
        [HabitLog(habitId: 2, date: d(2026, 11, 15), completed: true)], spy, () => now));
    await t.pump();
    await t.tap(find.byKey(const Key('toggle-1')));
    await t.tap(find.byKey(const Key('toggle-2')));
    expect(spy.calls, [(1, d(2026, 11, 15), true), (2, d(2026, 11, 15), false)]);
    expect(haptics, greaterThan(0));
  });

  testWidgets('rapid double tap does not throw', (t) async {
    final spy = SpyRepo();
    await t.pumpWidget(app([habit(1)], [], spy, () => now));
    await t.pump();
    await t.tap(find.byKey(const Key('toggle-1')));
    await t.tap(find.byKey(const Key('toggle-1')));
    expect(spy.calls.length, 2);
    expect(t.takeException(), isNull);
  });

  testWidgets('toggle is accessible: label, >=48dp', (t) async {
    final h = t.ensureSemantics();
    await t.pumpWidget(app([habit(1)], [], SpyRepo(), () => now));
    await t.pump();
    expect(t.getSemantics(find.byKey(const Key('toggle-1'))).label, contains('Minum air'));
    final s = t.getSize(find.byKey(const Key('toggle-1')));
    expect(s.width, greaterThanOrEqualTo(48));
    expect(s.height, greaterThanOrEqualTo(48));
    h.dispose();
  });

  testWidgets('rolls over at midnight without restart', (t) async {
    var clock = now;
    await t.pumpWidget(app([habit(1)], [], SpyRepo(), () => clock));
    await t.pump();
    expect(find.text('Sunday, 15 November'), findsOneWidget);
    clock = DateTime(2026, 11, 16, 0, 0, 5);
    await t.pump(const Duration(hours: 11));
    await t.pump();
    expect(find.text('Monday, 16 November'), findsOneWidget);
  });

  testWidgets('WeekStrip: future days disabled, past selectable, full date semantics', (t) async {
    final h = t.ensureSemantics();
    final picked = <DateTime>[];
    await t.pumpWidget(MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: WeekStrip(selected: d(2026, 11, 11), today: d(2026, 11, 11), onSelect: picked.add),
      ),
    ));
    expect(
      t.getSemantics(find.byKey(const Key('day-2026-11-11'))).label,
      contains('November 11, 2026'),
    );
    await t.tap(find.byKey(const Key('day-2026-11-12')));
    await t.tap(find.byKey(const Key('day-2026-11-10')));
    expect(picked, [d(2026, 11, 10)]);
    h.dispose();
  });
}

