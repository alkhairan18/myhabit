// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Rutin';

  @override
  String get todayLabel => 'Today';

  @override
  String progressLabel(int done, int total) {
    return '$done/$total';
  }

  @override
  String get emptyTitle => 'No habits yet';

  @override
  String get emptyBody =>
      'Create your first habit and check it off in one tap.';

  @override
  String get addHabit => 'Add habit';

  @override
  String markDone(String name) {
    return 'Mark $name as done';
  }

  @override
  String markUndone(String name) {
    return 'Mark $name as not done';
  }

  @override
  String get nothingScheduled => 'Nothing scheduled for this day.';
}
