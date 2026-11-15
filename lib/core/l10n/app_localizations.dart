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

  /// No description provided for @dailyGoalDone.
  ///
  /// In id, this message translates to:
  /// **'Semua kebiasaan hari ini tuntas'**
  String get dailyGoalDone;

  /// No description provided for @dailyGoalPartial.
  ///
  /// In id, this message translates to:
  /// **'Ketuk lingkaran untuk mencatat selesai'**
  String get dailyGoalPartial;

  /// No description provided for @emptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada kebiasaan'**
  String get emptyTitle;

  /// No description provided for @emptyBody.
  ///
  /// In id, this message translates to:
  /// **'Mulai dari satu kebiasaan kecil setiap hari dan catat selesai dalam satu ketukan.'**
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
  /// **'Tidak ada kebiasaan terjadwal di hari ini.'**
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
  /// **'Nama kebiasaan'**
  String get nameLabel;

  /// No description provided for @nameHint.
  ///
  /// In id, this message translates to:
  /// **'Mis. Minum air 8 gelas'**
  String get nameHint;

  /// No description provided for @descriptionLabel.
  ///
  /// In id, this message translates to:
  /// **'Catatan motivasi (opsional)'**
  String get descriptionLabel;

  /// No description provided for @descriptionHint.
  ///
  /// In id, this message translates to:
  /// **'Mis. Supaya tubuh tetap bugar sepanjang hari'**
  String get descriptionHint;

  /// No description provided for @iconSectionLabel.
  ///
  /// In id, this message translates to:
  /// **'Ikon'**
  String get iconSectionLabel;

  /// No description provided for @colorSectionLabel.
  ///
  /// In id, this message translates to:
  /// **'Warna penanda'**
  String get colorSectionLabel;

  /// No description provided for @frequencySectionLabel.
  ///
  /// In id, this message translates to:
  /// **'Jadwal pengulangan'**
  String get frequencySectionLabel;

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

  /// No description provided for @freqWeeklySummary.
  ///
  /// In id, this message translates to:
  /// **'{count}x per minggu'**
  String freqWeeklySummary(int count);

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
  /// **'Simpan kebiasaan'**
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

  /// No description provided for @archivedBadge.
  ///
  /// In id, this message translates to:
  /// **'Diarsipkan'**
  String get archivedBadge;

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
  /// **'Tidak ada kebiasaan terarsip. Kebiasaan yang Anda arsipkan akan tersimpan di sini beserta riwayatnya.'**
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

  /// No description provided for @streakUnitDays.
  ///
  /// In id, this message translates to:
  /// **'hari'**
  String get streakUnitDays;

  /// No description provided for @streakUnitWeeks.
  ///
  /// In id, this message translates to:
  /// **'minggu'**
  String get streakUnitWeeks;

  /// No description provided for @success7.
  ///
  /// In id, this message translates to:
  /// **'7 hari'**
  String get success7;

  /// No description provided for @success30.
  ///
  /// In id, this message translates to:
  /// **'30 hari'**
  String get success30;

  /// No description provided for @successAll.
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get successAll;

  /// No description provided for @totalDone.
  ///
  /// In id, this message translates to:
  /// **'Total selesai'**
  String get totalDone;

  /// No description provided for @heatmapTitle.
  ///
  /// In id, this message translates to:
  /// **'Riwayat 3 bulan terakhir'**
  String get heatmapTitle;

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

  /// No description provided for @dailyNoteTitle.
  ///
  /// In id, this message translates to:
  /// **'Catatan harian'**
  String get dailyNoteTitle;

  /// No description provided for @dailyNoteHint.
  ///
  /// In id, this message translates to:
  /// **'Tulis catatan singkat untuk hari ini...'**
  String get dailyNoteHint;

  /// No description provided for @saveNote.
  ///
  /// In id, this message translates to:
  /// **'Simpan catatan'**
  String get saveNote;

  /// No description provided for @statsTitle.
  ///
  /// In id, this message translates to:
  /// **'Statistik'**
  String get statsTitle;

  /// No description provided for @overallActiveHabits.
  ///
  /// In id, this message translates to:
  /// **'Kebiasaan aktif'**
  String get overallActiveHabits;

  /// No description provided for @overallWeeklyTrend.
  ///
  /// In id, this message translates to:
  /// **'Performa 7 hari terakhir'**
  String get overallWeeklyTrend;

  /// No description provided for @overallMonthlyTrend.
  ///
  /// In id, this message translates to:
  /// **'Performa 4 minggu terakhir'**
  String get overallMonthlyTrend;

  /// No description provided for @permTitle.
  ///
  /// In id, this message translates to:
  /// **'Aktifkan pengingat?'**
  String get permTitle;

  /// No description provided for @permBody.
  ///
  /// In id, this message translates to:
  /// **'Rutin memakai notifikasi lokal agar kamu diingatkan tepat pada jam yang kamu pilih.'**
  String get permBody;

  /// No description provided for @permAllow.
  ///
  /// In id, this message translates to:
  /// **'Izinkan'**
  String get permAllow;

  /// No description provided for @permDenied.
  ///
  /// In id, this message translates to:
  /// **'Izin notifikasi ditolak; pengingat tidak akan berbunyi.'**
  String get permDenied;

  /// No description provided for @permExactDenied.
  ///
  /// In id, this message translates to:
  /// **'Izin alarm presisi ditolak; pengingat mungkin sedikit terlambat.'**
  String get permExactDenied;

  /// No description provided for @settingsTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get settingsTitle;

  /// No description provided for @themeLabel.
  ///
  /// In id, this message translates to:
  /// **'Tampilan tema'**
  String get themeLabel;

  /// No description provided for @themeSystem.
  ///
  /// In id, this message translates to:
  /// **'Mengikuti sistem'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In id, this message translates to:
  /// **'Terang (Kertas hangat)'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In id, this message translates to:
  /// **'Gelap (Pinus pekat)'**
  String get themeDark;

  /// No description provided for @weekStartLabel.
  ///
  /// In id, this message translates to:
  /// **'Awal minggu'**
  String get weekStartLabel;

  /// No description provided for @weekStartMonday.
  ///
  /// In id, this message translates to:
  /// **'Senin'**
  String get weekStartMonday;

  /// No description provided for @weekStartSunday.
  ///
  /// In id, this message translates to:
  /// **'Minggu'**
  String get weekStartSunday;

  /// No description provided for @languageLabel.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get languageLabel;

  /// No description provided for @langSystem.
  ///
  /// In id, this message translates to:
  /// **'Sistem'**
  String get langSystem;

  /// No description provided for @langId.
  ///
  /// In id, this message translates to:
  /// **'Bahasa Indonesia'**
  String get langId;

  /// No description provided for @langEn.
  ///
  /// In id, this message translates to:
  /// **'English'**
  String get langEn;

  /// No description provided for @dataSectionLabel.
  ///
  /// In id, this message translates to:
  /// **'Data & cadangan'**
  String get dataSectionLabel;

  /// No description provided for @exportJson.
  ///
  /// In id, this message translates to:
  /// **'Ekspor data (JSON)'**
  String get exportJson;

  /// No description provided for @exportCopy.
  ///
  /// In id, this message translates to:
  /// **'Salin JSON'**
  String get exportCopy;

  /// No description provided for @exportCopied.
  ///
  /// In id, this message translates to:
  /// **'Data JSON disalin ke papan klip'**
  String get exportCopied;

  /// No description provided for @clearAllData.
  ///
  /// In id, this message translates to:
  /// **'Hapus semua data'**
  String get clearAllData;

  /// No description provided for @clearAllTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus semua data?'**
  String get clearAllTitle;

  /// No description provided for @clearAllBody.
  ///
  /// In id, this message translates to:
  /// **'Seluruh kebiasaan, catatan selesai, dan pengingat akan dihapus permanen.'**
  String get clearAllBody;

  /// No description provided for @clearAllDone.
  ///
  /// In id, this message translates to:
  /// **'Semua data telah dihapus'**
  String get clearAllDone;

  /// No description provided for @privacyNote.
  ///
  /// In id, this message translates to:
  /// **'100% disimpan di perangkat ini. Tanpa akun, tanpa pelacak.'**
  String get privacyNote;

  /// No description provided for @onboardingTitle.
  ///
  /// In id, this message translates to:
  /// **'Catat rutinitas harian dalam satu ketukan'**
  String get onboardingTitle;

  /// No description provided for @onboardingBody.
  ///
  /// In id, this message translates to:
  /// **'Bangun konsistensi lewat jadwal fleksibel, perhitungan streak otomatis, dan riwayat heatmap yang tersimpan penuh di perangkat Anda.'**
  String get onboardingBody;

  /// No description provided for @onboardingPillar1.
  ///
  /// In id, this message translates to:
  /// **'Satu ketukan untuk mencatat selesai di hari ini maupun hari yang terlewat'**
  String get onboardingPillar1;

  /// No description provided for @onboardingPillar2.
  ///
  /// In id, this message translates to:
  /// **'Streak dan statistik dihitung langsung dari riwayat nyata'**
  String get onboardingPillar2;

  /// No description provided for @onboardingPillar3.
  ///
  /// In id, this message translates to:
  /// **'Berfungsi penuh tanpa internet dan tanpa perlu membuat akun'**
  String get onboardingPillar3;

  /// No description provided for @onboardingSkip.
  ///
  /// In id, this message translates to:
  /// **'Lewati'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In id, this message translates to:
  /// **'Lanjut'**
  String get onboardingNext;

  /// No description provided for @onboardingStep2Title.
  ///
  /// In id, this message translates to:
  /// **'Lihat pola dan jaga konsistensi'**
  String get onboardingStep2Title;

  /// No description provided for @onboardingStep2Body.
  ///
  /// In id, this message translates to:
  /// **'Pantau streak harian atau mingguan, tinjau heatmap 3 bulan, dan atur pengingat lokal sesuai jadwal Anda.'**
  String get onboardingStep2Body;

  /// No description provided for @onboardingStep3Title.
  ///
  /// In id, this message translates to:
  /// **'Mulai dengan contoh kebiasaan'**
  String get onboardingStep3Title;

  /// No description provided for @onboardingStep3Body.
  ///
  /// In id, this message translates to:
  /// **'Pilih kebiasaan awal di bawah ini untuk langsung ditambahkan, atau mulai dari kosong.'**
  String get onboardingStep3Body;

  /// No description provided for @starterWater.
  ///
  /// In id, this message translates to:
  /// **'Minum air 8 gelas'**
  String get starterWater;

  /// No description provided for @starterRead.
  ///
  /// In id, this message translates to:
  /// **'Membaca 20 menit'**
  String get starterRead;

  /// No description provided for @starterExercise.
  ///
  /// In id, this message translates to:
  /// **'Olahraga ringan'**
  String get starterExercise;

  /// No description provided for @onboardingStart.
  ///
  /// In id, this message translates to:
  /// **'Mulai mencatat kebiasaan'**
  String get onboardingStart;

  /// No description provided for @timeOfDaySectionLabel.
  ///
  /// In id, this message translates to:
  /// **'Waktu pelaksanaan'**
  String get timeOfDaySectionLabel;

  /// No description provided for @timeAnytime.
  ///
  /// In id, this message translates to:
  /// **'Bebas'**
  String get timeAnytime;

  /// No description provided for @timeMorning.
  ///
  /// In id, this message translates to:
  /// **'Pagi'**
  String get timeMorning;

  /// No description provided for @timeAfternoon.
  ///
  /// In id, this message translates to:
  /// **'Siang'**
  String get timeAfternoon;

  /// No description provided for @timeEvening.
  ///
  /// In id, this message translates to:
  /// **'Malam'**
  String get timeEvening;

  /// No description provided for @filterAll.
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get filterAll;

  /// No description provided for @dailyCelebration.
  ///
  /// In id, this message translates to:
  /// **'Target harian 100% tercapai! Pertahankan ritme baik ini.'**
  String get dailyCelebration;

  /// No description provided for @badgesTitle.
  ///
  /// In id, this message translates to:
  /// **'Lencana pencapaian'**
  String get badgesTitle;

  /// No description provided for @badgeDays.
  ///
  /// In id, this message translates to:
  /// **'{count} {unit}'**
  String badgeDays(int count, String unit);

  /// No description provided for @weeklyRecapTitle.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan minggu ini'**
  String get weeklyRecapTitle;

  /// No description provided for @weeklyRecapCheckIns.
  ///
  /// In id, this message translates to:
  /// **'Selesai minggu ini'**
  String get weeklyRecapCheckIns;

  /// No description provided for @weeklyRecapPerfectDays.
  ///
  /// In id, this message translates to:
  /// **'Hari sempurna'**
  String get weeklyRecapPerfectDays;

  /// No description provided for @weeklyRecapTopHabit.
  ///
  /// In id, this message translates to:
  /// **'Paling konsisten'**
  String get weeklyRecapTopHabit;

  /// No description provided for @weeklyRecapNoTop.
  ///
  /// In id, this message translates to:
  /// **'Belum ada'**
  String get weeklyRecapNoTop;

  /// No description provided for @exportCsv.
  ///
  /// In id, this message translates to:
  /// **'Ekspor data (CSV)'**
  String get exportCsv;

  /// No description provided for @exportCsvCopy.
  ///
  /// In id, this message translates to:
  /// **'Salin CSV'**
  String get exportCsvCopy;

  /// No description provided for @exportCsvCopied.
  ///
  /// In id, this message translates to:
  /// **'Data CSV disalin ke papan klip'**
  String get exportCsvCopied;

  /// No description provided for @importJson.
  ///
  /// In id, this message translates to:
  /// **'Impor data (JSON)'**
  String get importJson;

  /// No description provided for @importJsonHint.
  ///
  /// In id, this message translates to:
  /// **'Tempel teks cadangan JSON di sini...'**
  String get importJsonHint;

  /// No description provided for @importJsonConfirm.
  ///
  /// In id, this message translates to:
  /// **'Pulihkan'**
  String get importJsonConfirm;

  /// No description provided for @importJsonSuccess.
  ///
  /// In id, this message translates to:
  /// **'{count} kebiasaan berhasil dipulihkan'**
  String importJsonSuccess(int count);

  /// No description provided for @importJsonError.
  ///
  /// In id, this message translates to:
  /// **'Format JSON tidak valid'**
  String get importJsonError;
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
