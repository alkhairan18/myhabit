import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rutin/core/l10n/app_localizations.dart';
import 'package:rutin/features/habits/data/habit_repository.dart';
import 'package:rutin/features/habits/domain/habit.dart';
import 'package:rutin/features/reminders/data/notification_service.dart';
import 'package:rutin/features/reminders/domain/reminder_planner.dart';
import 'package:rutin/features/reminders/presentation/reminder_permission_sheet.dart';

Habit h(int id, FrequencyType t, {Set<int> days = const {}}) => Habit(
    id: id, name: 'H$id', icon: 'water', color: 0, frequencyType: t,
    frequencyDays: days, sortOrder: id, createdAt: DateTime.utc(2026, 1, 1));

class FakeGateway implements NotificationGateway {
  FakeGateway({this.perm = true, this.exact = true});
  bool perm;
  bool exact;
  int cancels = 0;
  final scheduled = <(PlannedNotification, bool)>[];
  @override
  Future<bool> requestPermission() async => perm;
  @override
  Future<bool> canScheduleExact() async => exact;
  @override
  Future<void> cancelAll() async => cancels++;
  @override
  Future<void> schedule(PlannedNotification n, {bool exact = true}) async => scheduled.add((n, exact));
  @override
  Future<void> scheduleSnooze(int habitId, String title, Duration delay) async {}
}

void main() {
  test('sync returns permissionDenied without scheduling when permission denied', () async {
    final g = FakeGateway(perm: false);
    final svc = NotificationService(g);
    final r = await svc.sync([h(1, FrequencyType.daily)], [const ReminderRow(1, ReminderTime(8, 0))]);
    expect(r, ReminderSyncResult.permissionDenied);
    expect(g.scheduled, isEmpty);
  });

  test('sync falls back to inexact when exact alarm denied', () async {
    final g = FakeGateway(exact: false);
    final svc = NotificationService(g);
    final r = await svc.sync(
      [h(1, FrequencyType.specificDays, days: {1})],
      [const ReminderRow(1, ReminderTime(8, 0))],
    );
    expect(r, ReminderSyncResult.exactAlarmDenied);
    expect(g.scheduled.single.$2, false);
  });

  testWidgets('showReminderPermissionSheet explains context and returns user choice', (t) async {
    bool? chosen;
    await t.pumpWidget(MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (c) => Scaffold(
          body: ElevatedButton(
            onPressed: () async => chosen = await showReminderPermissionSheet(c),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    expect(find.text('Enable reminders?'), findsOneWidget);
    await t.tap(find.text('Allow'));
    await t.pumpAndSettle();
    expect(chosen, true);
  });
}
