import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rutin/core/l10n/app_localizations.dart';
import 'package:rutin/features/habits/application/providers.dart';
import 'package:rutin/features/habits/data/database.dart';
import 'package:rutin/features/habits/data/habit_repository.dart';
import 'package:rutin/features/habits/domain/habit.dart';
import 'package:rutin/features/habits/domain/habit_log.dart';
import 'package:rutin/features/habits/presentation/archive_screen.dart';
import 'package:rutin/features/habits/presentation/habit_form_screen.dart';
import 'package:rutin/features/reminders/data/notification_service.dart';
import 'package:rutin/features/reminders/domain/reminder_planner.dart';

DateTime d(int y, int m, int day) => DateTime.utc(y, m, day);

class SpyRepo extends HabitRepository {
  SpyRepo() : super(AppDatabase(NativeDatabase.memory()));
  final created = <HabitDraft>[];
  final updated = <HabitDraft>[];
  final deleted = <int>[];
  final archived = <int>[];
  final restored = <int>[];
  @override
  Future<int> create(HabitDraft dr, {required DateTime createdAt, List<ReminderTime> reminders = const []}) async {
    created.add(dr);
    return 1;
  }
  @override
  Future<void> update(int id, HabitDraft dr, {List<ReminderTime>? reminders}) async => updated.add(dr);
  @override
  Future<void> delete(int id) async => deleted.add(id);
  @override
  Future<void> archive(int id, DateTime on) async => archived.add(id);
  @override
  Future<void> unarchive(int id) async => restored.add(id);
  @override
  Future<Habit?> getHabit(int id) async => existing;
  @override
  Future<List<ReminderTime>> remindersFor(int habitId) async => [];
  @override
  Stream<List<Habit>> watchActive() => Stream.value(const []);
  @override
  Stream<List<HabitLog>> watchLogsOn(DateTime date) => Stream.value(const []);
  @override
  Future<List<ReminderRow>> allEnabledReminders() async => const [];
}

final existing = Habit(id: 7, name: 'Baca', icon: 'book', color: 0xFF1E88E5,
    frequencyType: FrequencyType.daily, sortOrder: 0, createdAt: d(2026, 1, 1));

Widget app(SpyRepo spy, String start, {List<Habit> archived = const []}) => ProviderScope(
      overrides: [
        clockProvider.overrideWithValue(() => DateTime(2026, 11, 15)),
        habitRepositoryProvider.overrideWithValue(spy),
        archivedHabitsProvider.overrideWith((ref) => Stream.value(archived)),
      ],
      child: MaterialApp.router(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: GoRouter(initialLocation: start, routes: [
          GoRoute(path: '/', builder: (_, _) => const Text('home')),
          GoRoute(path: '/habit/new', builder: (_, _) => const HabitFormScreen()),
          GoRoute(path: '/habit/:id/edit', builder: (_, s) => HabitFormScreen(habitId: int.parse(s.pathParameters['id']!))),
          GoRoute(path: '/archive', builder: (_, _) => const ArchiveScreen()),
        ]),
      ),
    );

Future<void> save(WidgetTester t) async {
  await t.ensureVisible(find.byKey(const Key('save')));
  await t.tap(find.byKey(const Key('save')));
  await t.pumpAndSettle();
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('blank name is rejected', (t) async {
    final spy = SpyRepo();
    await t.pumpWidget(app(spy, '/habit/new'));
    await t.pumpAndSettle();
    await t.enterText(find.byKey(const Key('name')), '   ');
    await save(t);
    expect(find.text('Name is required'), findsOneWidget);
    expect(spy.created, isEmpty);
  });

  testWidgets('name field limited to 40 chars', (t) async {
    await t.pumpWidget(app(SpyRepo(), '/habit/new'));
    await t.pumpAndSettle();
    expect(t.widget<TextField>(find.byKey(const Key('name'))).maxLength, 40);
  });

  testWidgets('specific days without a day is rejected', (t) async {
    final spy = SpyRepo();
    await t.pumpWidget(app(spy, '/habit/new'));
    await t.pumpAndSettle();
    await t.enterText(find.byKey(const Key('name')), 'Lari');
    await t.tap(find.text('Specific days'));
    await t.pumpAndSettle();
    await save(t);
    expect(find.text('Pick at least one day'), findsOneWidget);
    expect(spy.created, isEmpty);
  });

  testWidgets('weekly target 0 and 8 rejected', (t) async {
    final spy = SpyRepo();
    await t.pumpWidget(app(spy, '/habit/new'));
    await t.pumpAndSettle();
    await t.enterText(find.byKey(const Key('name')), 'Lari');
    await t.tap(find.text('Times per week'));
    await t.pumpAndSettle();
    for (final v in ['0', '8']) {
      await t.enterText(find.byKey(const Key('target')), v);
      await save(t);
      expect(find.text('Enter 1 to 7'), findsOneWidget, reason: v);
    }
    expect(spy.created, isEmpty);
  });

  testWidgets('valid input creates habit and leaves screen', (t) async {
    final spy = SpyRepo();
    await t.pumpWidget(app(spy, '/habit/new'));
    await t.pumpAndSettle();
    await t.enterText(find.byKey(const Key('name')), '  Minum air ');
    await t.enterText(find.byKey(const Key('description')), '  Agar segar ');
    await save(t);
    expect(spy.created.single.name, 'Minum air');
    expect(spy.created.single.description, 'Agar segar');
    expect(spy.created.single.frequencyType, FrequencyType.daily);
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('edit mode loads values and calls update', (t) async {
    final spy = SpyRepo();
    await t.pumpWidget(app(spy, '/habit/7/edit'));
    await t.pumpAndSettle();
    expect(find.text('Baca'), findsOneWidget);
    await t.enterText(find.byKey(const Key('name')), 'Baca buku');
    await save(t);
    expect(spy.updated.single.name, 'Baca buku');
  });

  testWidgets('delete needs confirmation', (t) async {
    final spy = SpyRepo();
    await t.pumpWidget(app(spy, '/habit/7/edit'));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('delete')));
    await t.pumpAndSettle();
    await t.tap(find.text('Cancel'));
    await t.pumpAndSettle();
    expect(spy.deleted, isEmpty);
    await t.tap(find.byKey(const Key('delete')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('confirm-delete')));
    await t.pumpAndSettle();
    expect(spy.deleted, [7]);
  });

  testWidgets('delete after pushing from detail navigates to home instead of popping to detail', (t) async {
    final spy = SpyRepo();
    final router = GoRouter(initialLocation: '/habit/7', routes: [
      GoRoute(path: '/', builder: (_, _) => const Text('home')),
      GoRoute(path: '/habit/:id', builder: (c, _) => ElevatedButton(
        onPressed: () => c.push('/habit/7/edit'),
        child: const Text('detail'),
      )),
      GoRoute(path: '/habit/:id/edit', builder: (_, s) => HabitFormScreen(habitId: int.parse(s.pathParameters['id']!))),
    ]);
    await t.pumpWidget(ProviderScope(
      overrides: [
        clockProvider.overrideWithValue(() => DateTime(2026, 11, 15)),
        habitRepositoryProvider.overrideWithValue(spy),
      ],
      child: MaterialApp.router(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ));
    await t.pumpAndSettle();
    await t.tap(find.text('detail'));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('delete')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('confirm-delete')));
    await t.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('shows explanation snackbar when exact alarm permission is denied', (t) async {
    final spy = SpyRepo();
    await t.pumpWidget(ProviderScope(
      overrides: [
        clockProvider.overrideWithValue(() => DateTime(2026, 11, 15)),
        habitRepositoryProvider.overrideWithValue(spy),
        notificationServiceProvider.overrideWithValue(_ExactDeniedService()),
      ],
      child: MaterialApp.router(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: GoRouter(initialLocation: '/habit/new', routes: [
          GoRoute(path: '/', builder: (_, _) => const Scaffold(body: Text('home'))),
          GoRoute(path: '/habit/new', builder: (_, _) => const HabitFormScreen()),
        ]),
      ),
    ));
    await t.pumpAndSettle();
    await t.enterText(find.byKey(const Key('name')), 'Minum air');
    await save(t);
    expect(find.textContaining('Exact alarm'), findsOneWidget);
  });

  testWidgets('archive from edit; archive screen lists and restores', (t) async {
    final spy = SpyRepo();
    await t.pumpWidget(app(spy, '/habit/7/edit'));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('archive')));
    await t.pumpAndSettle();
    expect(spy.archived, [7]);

    final spy2 = SpyRepo();
    await t.pumpWidget(app(spy2, '/archive', archived: [existing]));
    await t.pumpAndSettle();
    expect(find.text('Baca'), findsOneWidget);
    await t.tap(find.byKey(const Key('restore-7')));
    expect(spy2.restored, [7]);
  });

  testWidgets('editing an archived habit unarchives when archive button is tapped', (t) async {
    final spy = _ArchivedHabitSpyRepo();
    await t.pumpWidget(app(spy, '/habit/7/edit'));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('archive')));
    await t.pumpAndSettle();
    expect(spy.restored, [7]);
    expect(spy.archived, isEmpty);
  });
}

class _ArchivedHabitSpyRepo extends SpyRepo {
  @override
  Future<Habit?> getHabit(int id) async => Habit(
        id: 7,
        name: 'Baca',
        icon: 'book',
        color: 0xFF1E88E5,
        frequencyType: FrequencyType.daily,
        sortOrder: 0,
        createdAt: d(2026, 1, 1),
        archivedAt: d(2026, 11, 10),
      );
}

class _DummyGateway implements NotificationGateway {
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<bool> canScheduleExact() async => false;
  @override
  Future<void> cancelAll() async {}
  @override
  Future<void> schedule(PlannedNotification n, {bool exact = true}) async {}
}

class _ExactDeniedService extends NotificationService {
  _ExactDeniedService() : super(_DummyGateway());
  @override
  Future<ReminderSyncResult> sync(
    List<Habit> activeHabits,
    List<ReminderRow> reminders, {
    int? todayWeekday,
    Set<int> completedTodayHabitIds = const {},
  }) async =>
      ReminderSyncResult.exactAlarmDenied;
}
