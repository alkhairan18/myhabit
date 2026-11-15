import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { system, light, dark }

class SettingsRepository {
  SettingsRepository(this._prefs);
  final SharedPreferences _prefs;

  AppThemeMode get themeMode => AppThemeMode.values.firstWhere(
      (m) => m.name == _prefs.getString('themeMode'),
      orElse: () => AppThemeMode.system);

  Future<void> setThemeMode(AppThemeMode m) => _prefs.setString('themeMode', m.name);

  bool get onboardingDone => _prefs.getBool('onboardingDone') ?? false;

  Future<void> setOnboardingDone() => _prefs.setBool('onboardingDone', true);

  int get weekStartsOn => _prefs.getInt('weekStartsOn') ?? DateTime.monday;

  Future<void> setWeekStartsOn(int day) => _prefs.setInt('weekStartsOn', day);

  String? get localeCode => _prefs.getString('localeCode');

  Future<void> setLocaleCode(String? code) =>
      code == null ? _prefs.remove('localeCode') : _prefs.setString('localeCode', code);
}
