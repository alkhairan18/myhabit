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
  String get dailyGoalDone => 'All habits completed for today';

  @override
  String get dailyGoalPartial => 'Tap a circle to log completion';

  @override
  String get emptyTitle => 'No habits yet';

  @override
  String get emptyBody =>
      'Start with one small daily habit and check it off in a single tap.';

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
  String get nameLabel => 'Habit name';

  @override
  String get nameHint => 'e.g. Drink 8 glasses of water';

  @override
  String get descriptionLabel => 'Motivation note (optional)';

  @override
  String get descriptionHint => 'e.g. Stay energized throughout the day';

  @override
  String get iconSectionLabel => 'Icon';

  @override
  String get colorSectionLabel => 'Accent color';

  @override
  String get frequencySectionLabel => 'Schedule';

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
  String freqWeeklySummary(int count) {
    return '${count}x per week';
  }

  @override
  String get errNoDays => 'Pick at least one day';

  @override
  String get targetLabel => 'Target per week';

  @override
  String get errTarget => 'Enter 1 to 7';

  @override
  String get save => 'Save habit';

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
  String get archivedBadge => 'Archived';

  @override
  String get addReminder => 'Add reminder';

  @override
  String get reminders => 'Reminders';

  @override
  String get noArchived =>
      'No archived habits. Habits you archive stay here along with their completion history.';

  @override
  String get currentStreak => 'Current streak';

  @override
  String get bestStreak => 'Best streak';

  @override
  String get streakUnitDays => 'days';

  @override
  String get streakUnitWeeks => 'weeks';

  @override
  String get success7 => '7 days';

  @override
  String get success30 => '30 days';

  @override
  String get successAll => 'All time';

  @override
  String get totalDone => 'Total completed';

  @override
  String get heatmapTitle => 'Last 3 months';

  @override
  String get heatDone => 'done';

  @override
  String get heatNotDone => 'not done';

  @override
  String get edit => 'Edit';

  @override
  String get dailyNoteTitle => 'Daily note';

  @override
  String get dailyNoteHint => 'Write a short note for this day...';

  @override
  String get saveNote => 'Save note';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get overallActiveHabits => 'Active habits';

  @override
  String get overallWeeklyTrend => 'Last 7 days performance';

  @override
  String get overallMonthlyTrend => 'Last 4 weeks performance';

  @override
  String get permTitle => 'Enable reminders?';

  @override
  String get permBody =>
      'Rutin uses local notifications to remind you at the times you choose.';

  @override
  String get permAllow => 'Allow';

  @override
  String get permDenied =>
      'Notification permission denied; reminders will not fire.';

  @override
  String get permExactDenied =>
      'Exact alarm permission denied; reminders may be slightly delayed.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get themeLabel => 'Appearance';

  @override
  String get themeSystem => 'Follow system';

  @override
  String get themeLight => 'Light (Warm paper)';

  @override
  String get themeDark => 'Dark (Deep pine)';

  @override
  String get weekStartLabel => 'Start of week';

  @override
  String get weekStartMonday => 'Monday';

  @override
  String get weekStartSunday => 'Sunday';

  @override
  String get languageLabel => 'Language';

  @override
  String get langSystem => 'System';

  @override
  String get langId => 'Bahasa Indonesia';

  @override
  String get langEn => 'English';

  @override
  String get dataSectionLabel => 'Data & backup';

  @override
  String get exportJson => 'Export data (JSON)';

  @override
  String get exportCopy => 'Copy JSON';

  @override
  String get exportCopied => 'JSON data copied to clipboard';

  @override
  String get clearAllData => 'Delete all data';

  @override
  String get clearAllTitle => 'Delete all data?';

  @override
  String get clearAllBody =>
      'All habits, completion logs, and reminders will be permanently deleted.';

  @override
  String get clearAllDone => 'All data deleted';

  @override
  String get privacyNote =>
      '100% stored on this device. No account, no trackers.';

  @override
  String get onboardingTitle => 'Log your daily rituals in one tap';

  @override
  String get onboardingBody =>
      'Build consistency with flexible schedules, honest streak math, and a 3-month activity heatmap stored privately on your phone.';

  @override
  String get onboardingPillar1 =>
      'One tap to check off today or catch up on past days';

  @override
  String get onboardingPillar2 =>
      'Streaks and rates computed directly from your log history';

  @override
  String get onboardingPillar3 =>
      'Works completely offline with no account required';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStep2Title => 'Spot patterns and stay consistent';

  @override
  String get onboardingStep2Body =>
      'Track daily or weekly streaks, review your 3-month heatmap, and set local reminders on your schedule.';

  @override
  String get onboardingStep3Title => 'Start with starter habits';

  @override
  String get onboardingStep3Body =>
      'Pick any starter habits below to add them right away, or start with a clean slate.';

  @override
  String get starterWater => 'Drink 8 glasses of water';

  @override
  String get starterRead => 'Read 20 minutes';

  @override
  String get starterExercise => 'Light exercise';

  @override
  String get onboardingStart => 'Start tracking habits';
}
