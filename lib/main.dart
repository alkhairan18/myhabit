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
  final repo = container.read(habitRepositoryProvider);
  repo.watchActive().first.then((active) async => container
      .read(notificationServiceProvider)
      .sync(active, await repo.allEnabledReminders()));
  runApp(UncontrolledProviderScope(
    container: container,
    child: const RutinApp(),
  ));
}
