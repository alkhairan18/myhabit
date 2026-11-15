import '../../reminders/data/notification_service.dart';
import 'dart:async';

import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/date_utils.dart';
import '../../settings/settings_repository.dart';
import '../data/database.dart';
import '../data/habit_repository.dart';
import '../domain/habit.dart';
import '../domain/habit_log.dart';

final clockProvider = Provider<Clock>((_) => DateTime.now);

/// Local date; rebuilds itself shortly after local midnight.
class TodayNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = ref.watch(clockProvider)();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final t = Timer(midnight.difference(now) + const Duration(seconds: 1),
        ref.invalidateSelf);
    ref.onDispose(t.cancel);
    return dateOnly(now);
  }
}

final todayProvider = NotifierProvider<TodayNotifier, DateTime>(TodayNotifier.new);

/// Follows today until the user picks another day.
class SelectedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    ref.listen(todayProvider, (prev, next) {
      if (state == prev) state = next;
    });
    return ref.read(todayProvider);
  }

  void select(DateTime d) => state = d;
}

final selectedDateProvider =
    NotifierProvider<SelectedDateNotifier, DateTime>(SelectedDateNotifier.new);

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(driftDatabase(name: 'rutin'));
  ref.onDispose(db.close);
  return db;
});

final habitRepositoryProvider =
    Provider((ref) => HabitRepository(ref.watch(appDatabaseProvider)));

final activeHabitsProvider = StreamProvider<List<Habit>>(
    (ref) => ref.watch(habitRepositoryProvider).watchActive());

final archivedHabitsProvider = StreamProvider<List<Habit>>(
    (ref) => ref.watch(habitRepositoryProvider).watchArchived());

final logsOnDateProvider = StreamProvider.family<List<HabitLog>, DateTime>(
    (ref, date) => ref.watch(habitRepositoryProvider).watchLogsOn(date));

final logsProvider = StreamProvider.family<List<HabitLog>, int>(
    (ref, id) => ref.watch(habitRepositoryProvider).watchLogs(id));

/// Overridden in main() with a preloaded instance.
final settingsRepositoryProvider =
    Provider<SettingsRepository>((_) => throw UnimplementedError());

class ThemeModeNotifier extends Notifier<AppThemeMode> {
  @override
  AppThemeMode build() => ref.read(settingsRepositoryProvider).themeMode;

  Future<void> set(AppThemeMode m) async {
    state = m;
    await ref.read(settingsRepositoryProvider).setThemeMode(m);
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, AppThemeMode>(ThemeModeNotifier.new);

/// Looks in active and archived lists so archived habits stay viewable.
final habitByIdProvider = Provider.family<Habit?, int>((ref, id) {
  final all = [
    ...?ref.watch(activeHabitsProvider).value,
    ...?ref.watch(archivedHabitsProvider).value,
  ];
  for (final h in all) {
    if (h.id == id) return h;
  }
  return null;
});

class _NoopGateway implements NotificationGateway {
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<bool> canScheduleExact() async => true;
  @override
  Future<void> cancelAll() async {}
  @override
  Future<void> schedule(n, {bool exact = true}) async {}
}

final notificationServiceProvider =
    Provider<NotificationService>((_) => NotificationService(_NoopGateway()));

Future<ReminderSyncResult> syncReminders(WidgetRef ref) async {
  final repo = ref.read(habitRepositoryProvider);
  final active = await repo.getActive();
  final reminders = await repo.allEnabledReminders();
  return ref.read(notificationServiceProvider).sync(active, reminders);
}
