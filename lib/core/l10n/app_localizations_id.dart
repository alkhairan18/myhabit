// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appName => 'Rutin';

  @override
  String get todayLabel => 'Hari ini';

  @override
  String progressLabel(int done, int total) {
    return '$done/$total';
  }

  @override
  String get dailyGoalDone => 'Semua kebiasaan hari ini tuntas';

  @override
  String get dailyGoalPartial => 'Ketuk lingkaran untuk mencatat selesai';

  @override
  String get emptyTitle => 'Belum ada kebiasaan';

  @override
  String get emptyBody =>
      'Mulai dari satu kebiasaan kecil setiap hari dan catat selesai dalam satu ketukan.';

  @override
  String get addHabit => 'Tambah kebiasaan';

  @override
  String markDone(String name) {
    return 'Tandai $name selesai';
  }

  @override
  String markUndone(String name) {
    return 'Batalkan tanda selesai $name';
  }

  @override
  String get nothingScheduled => 'Tidak ada kebiasaan terjadwal di hari ini.';

  @override
  String get newHabit => 'Kebiasaan baru';

  @override
  String get editHabit => 'Ubah kebiasaan';

  @override
  String get nameLabel => 'Nama kebiasaan';

  @override
  String get nameHint => 'Mis. Minum air 8 gelas';

  @override
  String get descriptionLabel => 'Catatan motivasi (opsional)';

  @override
  String get descriptionHint => 'Mis. Supaya tubuh tetap bugar sepanjang hari';

  @override
  String get iconSectionLabel => 'Ikon';

  @override
  String get colorSectionLabel => 'Warna penanda';

  @override
  String get frequencySectionLabel => 'Jadwal pengulangan';

  @override
  String get errNameEmpty => 'Nama wajib diisi';

  @override
  String get errNameTooLong => 'Maksimal 40 karakter';

  @override
  String get freqDaily => 'Harian';

  @override
  String get freqDays => 'Hari tertentu';

  @override
  String get freqWeekly => 'X kali/minggu';

  @override
  String freqWeeklySummary(int count) {
    return '${count}x per minggu';
  }

  @override
  String get errNoDays => 'Pilih minimal satu hari';

  @override
  String get targetLabel => 'Target per minggu';

  @override
  String get errTarget => 'Isi 1 sampai 7';

  @override
  String get save => 'Simpan kebiasaan';

  @override
  String get delete => 'Hapus';

  @override
  String get deleteTitle => 'Hapus kebiasaan?';

  @override
  String get deleteBody => 'Seluruh riwayat dan pengingat ikut terhapus.';

  @override
  String get cancel => 'Batal';

  @override
  String get archive => 'Arsipkan';

  @override
  String get unarchive => 'Pulihkan';

  @override
  String get archiveTitle => 'Arsip';

  @override
  String get archivedBadge => 'Diarsipkan';

  @override
  String get addReminder => 'Tambah pengingat';

  @override
  String get reminders => 'Pengingat';

  @override
  String get noArchived =>
      'Tidak ada kebiasaan terarsip. Kebiasaan yang Anda arsipkan akan tersimpan di sini beserta riwayatnya.';

  @override
  String get currentStreak => 'Streak saat ini';

  @override
  String get bestStreak => 'Streak terbaik';

  @override
  String get streakUnitDays => 'hari';

  @override
  String get streakUnitWeeks => 'minggu';

  @override
  String get success7 => '7 hari';

  @override
  String get success30 => '30 hari';

  @override
  String get successAll => 'Semua';

  @override
  String get totalDone => 'Total selesai';

  @override
  String get heatmapTitle => 'Riwayat 3 bulan terakhir';

  @override
  String get heatDone => 'selesai';

  @override
  String get heatNotDone => 'belum selesai';

  @override
  String get edit => 'Ubah';

  @override
  String get dailyNoteTitle => 'Catatan harian';

  @override
  String get dailyNoteHint => 'Tulis catatan singkat untuk hari ini...';

  @override
  String get saveNote => 'Simpan catatan';

  @override
  String get statsTitle => 'Statistik';

  @override
  String get overallActiveHabits => 'Kebiasaan aktif';

  @override
  String get overallWeeklyTrend => 'Performa 7 hari terakhir';

  @override
  String get overallMonthlyTrend => 'Performa 4 minggu terakhir';

  @override
  String get permTitle => 'Aktifkan pengingat?';

  @override
  String get permBody =>
      'Rutin memakai notifikasi lokal agar kamu diingatkan tepat pada jam yang kamu pilih.';

  @override
  String get permAllow => 'Izinkan';

  @override
  String get permDenied =>
      'Izin notifikasi ditolak; pengingat tidak akan berbunyi.';

  @override
  String get permExactDenied =>
      'Izin alarm presisi ditolak; pengingat mungkin sedikit terlambat.';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get themeLabel => 'Tampilan tema';

  @override
  String get themeSystem => 'Mengikuti sistem';

  @override
  String get themeLight => 'Terang (Kertas hangat)';

  @override
  String get themeDark => 'Gelap (Pinus pekat)';

  @override
  String get weekStartLabel => 'Awal minggu';

  @override
  String get weekStartMonday => 'Senin';

  @override
  String get weekStartSunday => 'Minggu';

  @override
  String get languageLabel => 'Bahasa';

  @override
  String get langSystem => 'Sistem';

  @override
  String get langId => 'Bahasa Indonesia';

  @override
  String get langEn => 'English';

  @override
  String get dataSectionLabel => 'Data & cadangan';

  @override
  String get exportJson => 'Ekspor data (JSON)';

  @override
  String get exportCopy => 'Salin JSON';

  @override
  String get exportCopied => 'Data JSON disalin ke papan klip';

  @override
  String get clearAllData => 'Hapus semua data';

  @override
  String get clearAllTitle => 'Hapus semua data?';

  @override
  String get clearAllBody =>
      'Seluruh kebiasaan, catatan selesai, dan pengingat akan dihapus permanen.';

  @override
  String get clearAllDone => 'Semua data telah dihapus';

  @override
  String get privacyNote =>
      '100% disimpan di perangkat ini. Tanpa akun, tanpa pelacak.';

  @override
  String get onboardingTitle => 'Catat rutinitas harian dalam satu ketukan';

  @override
  String get onboardingBody =>
      'Bangun konsistensi lewat jadwal fleksibel, perhitungan streak otomatis, dan riwayat heatmap yang tersimpan penuh di perangkat Anda.';

  @override
  String get onboardingPillar1 =>
      'Satu ketukan untuk mencatat selesai di hari ini maupun hari yang terlewat';

  @override
  String get onboardingPillar2 =>
      'Streak dan statistik dihitung langsung dari riwayat nyata';

  @override
  String get onboardingPillar3 =>
      'Berfungsi penuh tanpa internet dan tanpa perlu membuat akun';

  @override
  String get onboardingSkip => 'Lewati';

  @override
  String get onboardingNext => 'Lanjut';

  @override
  String get onboardingStep2Title => 'Lihat pola dan jaga konsistensi';

  @override
  String get onboardingStep2Body =>
      'Pantau streak harian atau mingguan, tinjau heatmap 3 bulan, dan atur pengingat lokal sesuai jadwal Anda.';

  @override
  String get onboardingStep3Title => 'Mulai dengan contoh kebiasaan';

  @override
  String get onboardingStep3Body =>
      'Pilih kebiasaan awal di bawah ini untuk langsung ditambahkan, atau mulai dari kosong.';

  @override
  String get starterWater => 'Minum air 8 gelas';

  @override
  String get starterRead => 'Membaca 20 menit';

  @override
  String get starterExercise => 'Olahraga ringan';

  @override
  String get onboardingStart => 'Mulai mencatat kebiasaan';

  @override
  String get timeOfDaySectionLabel => 'Waktu pelaksanaan';

  @override
  String get timeAnytime => 'Bebas';

  @override
  String get timeMorning => 'Pagi';

  @override
  String get timeAfternoon => 'Siang';

  @override
  String get timeEvening => 'Malam';

  @override
  String get filterAll => 'Semua';

  @override
  String get dailyCelebration =>
      'Target harian 100% tercapai! Pertahankan ritme baik ini.';

  @override
  String get badgesTitle => 'Lencana pencapaian';

  @override
  String badgeDays(int count, String unit) {
    return '$count $unit';
  }

  @override
  String get weeklyRecapTitle => 'Ringkasan minggu ini';

  @override
  String get weeklyRecapCheckIns => 'Selesai minggu ini';

  @override
  String get weeklyRecapPerfectDays => 'Hari sempurna';

  @override
  String get weeklyRecapTopHabit => 'Paling konsisten';

  @override
  String get weeklyRecapNoTop => 'Belum ada';

  @override
  String get exportCsv => 'Ekspor data (CSV)';

  @override
  String get exportCsvCopy => 'Salin CSV';

  @override
  String get exportCsvCopied => 'Data CSV disalin ke papan klip';

  @override
  String get importJson => 'Impor data (JSON)';

  @override
  String get importJsonHint => 'Tempel teks cadangan JSON di sini...';

  @override
  String get importJsonConfirm => 'Pulihkan';

  @override
  String importJsonSuccess(int count) {
    return '$count kebiasaan berhasil dipulihkan';
  }

  @override
  String get importJsonError => 'Format JSON tidak valid';
}
