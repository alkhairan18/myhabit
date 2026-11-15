import 'package:flutter_test/flutter_test.dart';
import 'package:rutin/features/habits/data/habit_repository.dart';
import 'package:rutin/features/habits/domain/habit.dart';
import 'package:rutin/features/reminders/data/notification_service.dart';
import 'package:rutin/features/reminders/domain/reminder_planner.dart';

Habit h(int id, FrequencyType t, {Set<int> days = const {}, DateTime? archived}) => Habit(
    id: id, name: 'H$id', icon: 'water', color: 0, frequencyType: t,
    frequencyDays: days, sortOrder: id, createdAt: DateTime.utc(2026, 1, 1), archivedAt: archived);

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
}

void main() {
  test('specificDays {1,3,5} with one reminder plans 3 notifications on weekdays 1,3,5', () {
    final res = planNotifications(
      [h(1, FrequencyType.specificDays, days: {1, 3, 5})],
      [const ReminderRow(1, ReminderTime(7, 30))],
    );
    expect(res.map((n) => n.weekday).toList(), [1, 3, 5]);
  });

  test('archived habit produces no notifications', () {
    final res = planNotifications(
      [h(1, FrequencyType.daily, archived: DateTime.utc(2026, 11, 1))],
      [const ReminderRow(1, ReminderTime(8, 0))],
    );
    expect(res, isEmpty);
  });

  test('ids are deterministic and unique across 20 habit/day/time combos', () {
    final habits = [for (var i = 1; i <= 5; i++) h(i, FrequencyType.daily)];
    final reminders = [
      for (var i = 1; i <= 5; i++) ...[
        ReminderRow(i, const ReminderTime(7, 0)),
        ReminderRow(i, const ReminderTime(20, 30)),
      ]
    ];
    final res = planNotifications(habits, reminders);
    expect(res.length, 70);
    expect(res.map((n) => n.id).toSet().length, 70);
  });

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

  test('sync after habit deleted no longer schedules that habit', () async {
    final g = FakeGateway();
    final svc = NotificationService(g);
    await svc.sync([h(1, FrequencyType.daily)], [const ReminderRow(1, ReminderTime(8, 0))]);
    g.scheduled.clear();
    await svc.sync([], []);
    expect(g.cancels, 2);
    expect(g.scheduled, isEmpty);
  });

  test('completedTodayHabitIds skips todayWeekday notification for completed habit (FR-32)', () {
    final res = planNotifications(
      [h(1, FrequencyType.daily)],
      [const ReminderRow(1, ReminderTime(8, 0))],
      todayWeekday: DateTime.wednesday,
      completedTodayHabitIds: {1},
    );
    expect(res.map((n) => n.weekday).toList(), [1, 2, 4, 5, 6, 7]);
  });
}
