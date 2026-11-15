# Rutin — Offline-First Habit Tracker

Aplikasi pelacak kebiasaan ringan untuk Android (API 26+) yang bekerja 100% offline, tanpa akun, dan tanpa pelacak pihak ketiga.

## Cara Menjalankan

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter test
flutter run
```

## Arsitektur

Tiga lapisan per fitur (`lib/features/habits`, `lib/features/reminders`, `lib/features/settings`):

- **Domain (`domain/`):** fungsi Dart murni untuk penjadwalan (`isScheduledOn`), validasi (`validateHabit`), perhitungan streak (`calculateStreak`), statistik (`calculateStats`), dan perencana pengingat (`planNotifications`). Streak tidak pernah disimpan ke database — selalu dihitung ulang dari `HabitLog`.
- **Data (`data/`):** Drift SQLite (`Habits`, `HabitLogs`, `Reminders` dengan `ON DELETE CASCADE` dan indeks unik `(habit_id, date)`), plus `FlutterLocalNotificationsGateway` berbasis zona waktu lokal.
- **Presentation (`presentation/`):** widget Material 3 dengan Riverpod dan `go_router`, lokalisasi Bahasa Indonesia & Inggris (`lib/core/l10n/`), kontras warna teruji, label semantik untuk pembaca layar, dan target sentuh minimal 48 dp.
