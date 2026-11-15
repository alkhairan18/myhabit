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
  late final ProviderContainer container;
  final notifService = NotificationService(
    gateway,
    onMarkDone: (habitId) async {
      final repo = container.read(habitRepositoryProvider);
      final today = container.read(todayProvider);
      try {
        await repo.setCompletion(habitId, today, true, today: today);
      } catch (_) {}
    },
  );
  gateway.onAction = notifService.handleAction;
  container = ProviderContainer(
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
