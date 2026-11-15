import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'features/habits/application/providers.dart';
import 'features/reminders/data/notification_service.dart';
import 'features/settings/settings_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final gateway = await FlutterLocalNotificationsGateway.init();
  final notifService = NotificationService(gateway);
  final container = ProviderContainer(
    overrides: [
      settingsRepositoryProvider.overrideWithValue(SettingsRepository(prefs)),
      notificationServiceProvider.overrideWithValue(notifService),
    ],
  );
  // Reschedule active reminders on startup / after device reboot.
  unawaitedSync(container);
  runApp(UncontrolledProviderScope(
    container: container,
    child: const RutinApp(),
  ));
}

Future<void> unawaitedSync(ProviderContainer c) async {
  final repo = c.read(habitRepositoryProvider);
  final active = await repo.getActive();
  final reminders = await repo.allEnabledReminders();
  await c.read(notificationServiceProvider).sync(active, reminders);
}
