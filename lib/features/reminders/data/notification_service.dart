import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../habits/data/habit_repository.dart';
import '../../habits/domain/habit.dart';
import '../domain/reminder_planner.dart';

enum ReminderSyncResult { ok, permissionDenied, exactAlarmDenied }

abstract class NotificationGateway {
  Future<bool> requestPermission();
  Future<bool> canScheduleExact();
  Future<void> cancelAll();
  Future<void> schedule(PlannedNotification n, {bool exact = true});
  Future<void> scheduleSnooze(int habitId, String title, Duration delay);
}

class NotificationService {
  NotificationService(this._gateway, {this.onMarkDone});
  final NotificationGateway _gateway;
  final Future<void> Function(int habitId)? onMarkDone;

  Future<void> handleAction(String? actionId, String? payload) async {
    if (payload == null || payload.isEmpty) return;
    final sep = payload.indexOf(':');
    final idStr = sep == -1 ? payload : payload.substring(0, sep);
    final title = sep == -1 ? 'Rutin' : payload.substring(sep + 1);
    final habitId = int.tryParse(idStr);
    if (habitId == null) return;
    if (actionId == 'mark_done') {
      await onMarkDone?.call(habitId);
    } else if (actionId == 'snooze') {
      await _gateway.scheduleSnooze(
          habitId, title, const Duration(minutes: 15));
    }
  }

  Future<ReminderSyncResult> sync(
    List<Habit> activeHabits,
    List<ReminderRow> reminders, {
    int? todayWeekday,
    Set<int> completedTodayHabitIds = const {},
  }) async {
    await _gateway.cancelAll();
    final planned = planNotifications(
      activeHabits,
      reminders,
      todayWeekday: todayWeekday,
      completedTodayHabitIds: completedTodayHabitIds,
    );
    if (planned.isEmpty) return ReminderSyncResult.ok;
    if (!await _gateway.requestPermission()) {
      return ReminderSyncResult.permissionDenied;
    }
    final exact = await _gateway.canScheduleExact();
    for (final n in planned) {
      await _gateway.schedule(n, exact: exact);
    }
    return exact ? ReminderSyncResult.ok : ReminderSyncResult.exactAlarmDenied;
  }
}

class FlutterLocalNotificationsGateway implements NotificationGateway {
  FlutterLocalNotificationsGateway(this._plugin);
  final FlutterLocalNotificationsPlugin _plugin;
  Future<void> Function(String? actionId, String? payload)? onAction;

  static Future<FlutterLocalNotificationsGateway> init() async {
    tz.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // Fallback to UTC when host/test has no platform timezone channel.
    }
    final p = FlutterLocalNotificationsPlugin();
    final gateway = FlutterLocalNotificationsGateway(p);
    await p.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (resp) {
        gateway.onAction?.call(resp.actionId, resp.payload);
      },
    );
    return gateway;
  }

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  @override
  Future<bool> requestPermission() async =>
      await _android?.requestNotificationsPermission() ?? true;

  @override
  Future<bool> canScheduleExact() async =>
      await _android?.canScheduleExactNotifications() ?? false;

  @override
  Future<void> cancelAll() => _plugin.cancelAll();

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'rutin_reminders',
      'Reminders',
      importance: Importance.high,
      priority: Priority.high,
      actions: [
        AndroidNotificationAction(
          'mark_done',
          'Tandai selesai',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'snooze',
          'Tunda 15 mnt',
          showsUserInterface: true,
        ),
      ],
    ),
  );

  @override
  Future<void> schedule(PlannedNotification n, {bool exact = true}) async {
    final now = tz.TZDateTime.now(tz.local);
    var d = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, n.time.hour, n.time.minute);
    while (d.weekday != n.weekday || !d.isAfter(now)) {
      d = d.add(const Duration(days: 1));
    }
    await _plugin.zonedSchedule(
      id: n.id,
      title: n.title,
      scheduledDate: d,
      notificationDetails: _details,
      payload: '${n.habitId}:${n.title}',
      androidScheduleMode: exact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  @override
  Future<void> scheduleSnooze(int habitId, String title, Duration delay) async {
    final exact = await canScheduleExact();
    final d = tz.TZDateTime.now(tz.local).add(delay);
    await _plugin.zonedSchedule(
      id: (habitId * 100000 + 99999) & 0x7fffffff,
      title: title,
      scheduledDate: d,
      notificationDetails: _details,
      payload: '$habitId:$title',
      androidScheduleMode: exact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}
