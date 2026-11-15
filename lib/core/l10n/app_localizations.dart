import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appName.
  ///
  /// In id, this message translates to:
  /// **'Rutin'**
  String get appName;

  /// No description provided for @todayLabel.
  ///
  /// In id, this message translates to:
  /// **'Hari ini'**
  String get todayLabel;

  /// No description provided for @progressLabel.
  ///
  /// In id, this message translates to:
  /// **'{done}/{total}'**
  String progressLabel(int done, int total);

  /// No description provided for @emptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada kebiasaan'**
  String get emptyTitle;

  /// No description provided for @emptyBody.
  ///
  /// In id, this message translates to:
  /// **'Buat kebiasaan pertamamu dan centang dengan satu ketukan.'**
  String get emptyBody;

  /// No description provided for @addHabit.
  ///
  /// In id, this message translates to:
  /// **'Tambah kebiasaan'**
  String get addHabit;

  /// No description provided for @markDone.
  ///
  /// In id, this message translates to:
  /// **'Tandai {name} selesai'**
  String markDone(String name);

  /// No description provided for @markUndone.
  ///
  /// In id, this message translates to:
  /// **'Batalkan tanda selesai {name}'**
  String markUndone(String name);

  /// No description provided for @nothingScheduled.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada jadwal di hari ini.'**
  String get nothingScheduled;

  /// No description provided for @newHabit.
  ///
  /// In id, this message translates to:
  /// **'Kebiasaan baru'**
  String get newHabit;

  /// No description provided for @editHabit.
  ///
  /// In id, this message translates to:
  /// **'Ubah kebiasaan'**
  String get editHabit;

  /// No description provided for @nameLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama'**
  String get nameLabel;

  /// No description provided for @errNameEmpty.
  ///
  /// In id, this message translates to:
  /// **'Nama wajib diisi'**
  String get errNameEmpty;

  /// No description provided for @errNameTooLong.
  ///
  /// In id, this message translates to:
  /// **'Maksimal 40 karakter'**
  String get errNameTooLong;

  /// No description provided for @freqDaily.
  ///
  /// In id, this message translates to:
  /// **'Harian'**
  String get freqDaily;

  /// No description provided for @freqDays.
  ///
  /// In id, this message translates to:
  /// **'Hari tertentu'**
  String get freqDays;

  /// No description provided for @freqWeekly.
  ///
  /// In id, this message translates to:
  /// **'X kali/minggu'**
  String get freqWeekly;

  /// No description provided for @errNoDays.
  ///
  /// In id, this message translates to:
  /// **'Pilih minimal satu hari'**
  String get errNoDays;

  /// No description provided for @targetLabel.
  ///
  /// In id, this message translates to:
  /// **'Target per minggu'**
  String get targetLabel;

  /// No description provided for @errTarget.
  ///
  /// In id, this message translates to:
  /// **'Isi 1 sampai 7'**
  String get errTarget;

  /// No description provided for @save.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get delete;

  /// No description provided for @deleteTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus kebiasaan?'**
  String get deleteTitle;

  /// No description provided for @deleteBody.
  ///
  /// In id, this message translates to:
  /// **'Seluruh riwayat dan pengingat ikut terhapus.'**
  String get deleteBody;

  /// No description provided for @cancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get cancel;

  /// No description provided for @archive.
  ///
  /// In id, this message translates to:
  /// **'Arsipkan'**
  String get archive;

  /// No description provided for @unarchive.
  ///
  /// In id, this message translates to:
  /// **'Pulihkan'**
  String get unarchive;

  /// No description provided for @archiveTitle.
  ///
  /// In id, this message translates to:
  /// **'Arsip'**
  String get archiveTitle;

  /// No description provided for @addReminder.
  ///
  /// In id, this message translates to:
  /// **'Tambah pengingat'**
  String get addReminder;

  /// No description provided for @reminders.
  ///
  /// In id, this message translates to:
  /// **'Pengingat'**
  String get reminders;

  /// No description provided for @noArchived.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada kebiasaan terarsip.'**
  String get noArchived;

  /// No description provided for @currentStreak.
  ///
  /// In id, this message translates to:
  /// **'Streak saat ini'**
  String get currentStreak;

  /// No description provided for @bestStreak.
  ///
  /// In id, this message translates to:
  /// **'Streak terbaik'**
  String get bestStreak;

  /// No description provided for @success7.
  ///
  /// In id, this message translates to:
  /// **'Berhasil 7 hari'**
  String get success7;

  /// No description provided for @success30.
  ///
  /// In id, this message translates to:
  /// **'Berhasil 30 hari'**
  String get success30;

  /// No description provided for @successAll.
  ///
  /// In id, this message translates to:
  /// **'Sepanjang waktu'**
  String get successAll;

  /// No description provided for @totalDone.
  ///
  /// In id, this message translates to:
  /// **'Total selesai'**
  String get totalDone;

  /// No description provided for @heatDone.
  ///
  /// In id, this message translates to:
  /// **'selesai'**
  String get heatDone;

  /// No description provided for @heatNotDone.
  ///
  /// In id, this message translates to:
  /// **'belum selesai'**
  String get heatNotDone;

  /// No description provided for @edit.
  ///
  /// In id, this message translates to:
  /// **'Ubah'**
  String get edit;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
