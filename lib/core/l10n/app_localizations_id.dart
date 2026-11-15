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
  String get emptyTitle => 'Belum ada kebiasaan';

  @override
  String get emptyBody =>
      'Buat kebiasaan pertamamu dan centang dengan satu ketukan.';

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
  String get nothingScheduled => 'Tidak ada jadwal di hari ini.';

  @override
  String get newHabit => 'Kebiasaan baru';

  @override
  String get editHabit => 'Ubah kebiasaan';

  @override
  String get nameLabel => 'Nama';

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
  String get errNoDays => 'Pilih minimal satu hari';

  @override
  String get targetLabel => 'Target per minggu';

  @override
  String get errTarget => 'Isi 1 sampai 7';

  @override
  String get save => 'Simpan';

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
  String get addReminder => 'Tambah pengingat';

  @override
  String get reminders => 'Pengingat';

  @override
  String get noArchived => 'Tidak ada kebiasaan terarsip.';

  @override
  String get currentStreak => 'Streak saat ini';

  @override
  String get bestStreak => 'Streak terbaik';

  @override
  String get success7 => 'Berhasil 7 hari';

  @override
  String get success30 => 'Berhasil 30 hari';

  @override
  String get successAll => 'Sepanjang waktu';

  @override
  String get totalDone => 'Total selesai';

  @override
  String get heatDone => 'selesai';

  @override
  String get heatNotDone => 'belum selesai';

  @override
  String get edit => 'Ubah';

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
}
