import 'package:flutter_test/flutter_test.dart';
import 'package:rutin/features/settings/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('defaults: system theme, onboarding not done, monday start, system locale', () async {
    SharedPreferences.setMockInitialValues({});
    final r = SettingsRepository(await SharedPreferences.getInstance());
    expect(r.themeMode, AppThemeMode.system);
    expect(r.onboardingDone, false);
    expect(r.weekStartsOn, DateTime.monday);
    expect(r.localeCode, isNull);
  });
  test('theme, onboarding, weekStartsOn, and localeCode persist', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await SettingsRepository(prefs).setThemeMode(AppThemeMode.dark);
    await SettingsRepository(prefs).setOnboardingDone();
    await SettingsRepository(prefs).setWeekStartsOn(DateTime.sunday);
    await SettingsRepository(prefs).setLocaleCode('id');
    final r = SettingsRepository(prefs);
    expect(r.themeMode, AppThemeMode.dark);
    expect(r.onboardingDone, true);
    expect(r.weekStartsOn, DateTime.sunday);
    expect(r.localeCode, 'id');
  });
}
