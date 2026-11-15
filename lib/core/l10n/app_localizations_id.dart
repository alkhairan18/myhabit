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
}
