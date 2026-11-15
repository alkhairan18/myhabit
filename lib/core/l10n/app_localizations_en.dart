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

  @override
  String get newHabit => 'New habit';

  @override
  String get editHabit => 'Edit habit';

  @override
  String get nameLabel => 'Name';

  @override
  String get errNameEmpty => 'Name is required';

  @override
  String get errNameTooLong => 'Max 40 characters';

  @override
  String get freqDaily => 'Daily';

  @override
  String get freqDays => 'Specific days';

  @override
  String get freqWeekly => 'Times per week';

  @override
  String get errNoDays => 'Pick at least one day';

  @override
  String get targetLabel => 'Target per week';

  @override
  String get errTarget => 'Enter 1 to 7';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get deleteTitle => 'Delete habit?';

  @override
  String get deleteBody => 'All history and reminders will be deleted.';

  @override
  String get cancel => 'Cancel';

  @override
  String get archive => 'Archive';

  @override
  String get unarchive => 'Restore';

  @override
  String get archiveTitle => 'Archive';

  @override
  String get addReminder => 'Add reminder';

  @override
  String get reminders => 'Reminders';

  @override
  String get noArchived => 'No archived habits.';

  @override
  String get currentStreak => 'Current streak';

  @override
  String get bestStreak => 'Best streak';

  @override
  String get success7 => 'Success, 7 days';

  @override
  String get success30 => 'Success, 30 days';

  @override
  String get successAll => 'All time';

  @override
  String get totalDone => 'Total completed';

  @override
  String get heatDone => 'done';

  @override
  String get heatNotDone => 'not done';

  @override
  String get edit => 'Edit';
}
