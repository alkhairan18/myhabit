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
}
