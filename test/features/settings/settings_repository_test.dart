import 'package:flutter_test/flutter_test.dart';
import 'package:rutin/features/settings/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('defaults: system theme, onboarding not done', () async {
    SharedPreferences.setMockInitialValues({});
    final r = SettingsRepository(await SharedPreferences.getInstance());
    expect(r.themeMode, AppThemeMode.system);
    expect(r.onboardingDone, false);
  });
  test('theme and onboarding persist', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await SettingsRepository(prefs).setThemeMode(AppThemeMode.dark);
    await SettingsRepository(prefs).setOnboardingDone();
    final r = SettingsRepository(prefs);
    expect(r.themeMode, AppThemeMode.dark);
    expect(r.onboardingDone, true);
  });
}
