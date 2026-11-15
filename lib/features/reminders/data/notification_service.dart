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
}

class NotificationService {
  NotificationService(this._gateway);
  final NotificationGateway _gateway;

  Future<ReminderSyncResult> sync(
      List<Habit> activeHabits, List<ReminderRow> reminders) async {
    await _gateway.cancelAll();
    final planned = planNotifications(activeHabits, reminders);
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

  static Future<FlutterLocalNotificationsGateway> init() async {
    tz.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // Fallback to UTC when host/test has no platform timezone channel.
    }
    final p = FlutterLocalNotificationsPlugin();
    await p.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    return FlutterLocalNotificationsGateway(p);
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
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails('rutin_reminders', 'Reminders',
            importance: Importance.high, priority: Priority.high),
      ),
      androidScheduleMode: exact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }
}
