# Rutin - Offline-First Habit Tracker

Aplikasi pelacak kebiasaan untuk Android (API 26 / Android 8.0+) yang bekerja 100% secara lokal (*offline-first*), tanpa akun wajib, tanpa iklan, dan tanpa pelacak pihak ketiga.

## Fitur Utama

- **Pencatatan Satu Ketukan (< 5 Detik):** Centang kebiasaan hari ini atau lengkapi hari yang terlewat melalui *week strip* dengan umpan balik *haptic*, catatan harian opsional per tanggal, serta animasi selebrasi saat target harian 100% tercapai.
- **Jadwal Fleksibel & Pengelompokan Waktu:** Mendukung kebiasaan **Harian**, **Hari tertentu**, dan **X kali per minggu**, ditambah pengelompokan waktu (**Bebas**, **Pagi**, **Siang**, **Malam**) serta pengurutan ulang dengan *drag-and-drop*.
- **Streak Jujur, Heatmap, & Lencana Pencapaian:** Perhitungan *streak* harian/mingguan yang dihitung langsung dari riwayat catatan nyata, *heatmap* 3 bulan, lencana pencapaian (*7, 30, 100*), layar statistik keseluruhan, dan laporan ringkasan mingguan.
- **Pengingat Lokal Cerdas:** Beberapa jam pengingat per kebiasaan, otomatis melewati pengingat hari ini jika kebiasaan sudah selesai, serta tombol aksi cepat langsung dari notifikasi (**Tandai selesai** dan **Tunda 15 mnt**).
- **Kendali Penuh atas Data & Tampilan:** Ekspor data ke **JSON** maupun **CSV**, impor kembali dari cadangan **JSON**, opsi hapus seluruh data, tema **Terang / Gelap / Sistem** (*Warm Botanical & Tactile Planner*), pilihan hari awal minggu (**Senin / Minggu**), serta dukungan **Bahasa Indonesia** dan **Bahasa Inggris**.

## Dokumentasi Proyek

- [Studi Kasus Portofolio (`docs/case-study.md`)](docs/case-study.md)
- [Sistem Desain & Token Visual (`DESIGN.md`)](DESIGN.md)
- [Kebijakan Privasi (`docs/privacy-policy.md`)](docs/privacy-policy.md)
- [Panduan Uji Pengingat & Reboot (`docs/notification-testing.md`)](docs/notification-testing.md)

## Cara Menjalankan & Membangun

```bash
# 1. Unduh dependensi dan buat kode lokalisasi
flutter pub get
flutter gen-l10n

# 2. Jalankan analisis statis dan seluruh pengujian (89 tes)
flutter analyze
flutter test --coverage

# 3. Jalankan aplikasi di perangkat/emulator
flutter run

# 4. Bangun APK rilis beserta analisis ukuran (~21.6 MB untuk arm64-v8a)
flutter build apk --release --analyze-size --target-platform android-arm64
```

## Arsitektur

Tiga lapisan per fitur (`lib/features/habits`, `lib/features/reminders`, `lib/features/settings`):

- **Domain (`domain/`):** Fungsi Dart murni untuk penjadwalan (`isScheduledOn`), validasi (`validateHabit`), perhitungan *streak* (`calculateStreak`), statistik & ringkasan mingguan (`calculateStats`, `calculateWeeklyRecap`, `unlockedBadges`), serta perencana pengingat (`planNotifications`). *Streak* tidak pernah disimpan sebagai kolom di database dan selalu dihitung ulang dari `HabitLog`.
- **Data (`data/`):** Database SQLite lokal dengan Drift (`Habits`, `HabitLogs`, `Reminders` dengan `ON DELETE CASCADE` dan indeks unik `(habit_id, date)`), ekspor/impor JSON & CSV tervalidasi, serta `FlutterLocalNotificationsGateway` berbasis zona waktu lokal.
- **Presentation (`presentation/`):** Antarmuka Material 3 dengan Riverpod dan `go_router`, lokalisasi Bahasa Indonesia & Inggris (`lib/core/l10n/`), kontras warna $\ge 3.0:1$ teruji otomatis, dukungan skala teks hingga `200%`, label semantik pembaca layar, dan target sentuh minimal `48x48 dp`.
