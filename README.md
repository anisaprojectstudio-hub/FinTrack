# FinTrack — Fase Profile (Tanpa Firebase Storage)

> Lanjutan dari fase Financial Report — fitur terakhir dari daftar Core Features di Tahap 1. **Catatan penting**: Firebase Storage sekarang wajib paket berbayar (Blaze), jadi foto profil di sini TIDAK memakainya sama sekali. Sebagai gantinya, foto dikompres kecil lalu disimpan sebagai **base64 langsung di Firestore**, yang tetap gratis di Spark plan.

---

## 1. Kenapa Base64-di-Firestore, Bukan Firebase Storage

| Firebase Storage | Base64-di-Firestore (dipakai di sini) |
|---|---|
| Wajib paket Blaze (kartu kredit, bayar-sesuai-pakai) | Gratis di Spark plan (kuota Firestore biasa) |
| Perlu setup Storage Rules terpisah | Cukup Firestore Rules yang sudah ada (Tahap 3) |
| Cocok untuk file besar (video, dokumen) | Cocok untuk foto kecil (avatar ~150–300px) |
| URL publik oleh default (perlu rules ketat) | Data ikut aturan akses dokumen `users/{uid}` yang sudah aman |

Trade-off yang perlu kamu tahu: foto ikut ke-fetch setiap kali dokumen user dibaca (field `photoUrl` sedikit "berat" dibanding string biasa), dan ukurannya dibatasi ketat (maks ~700KB base64, otomatis dikompres ke 300px). Untuk foto profil kecil, ini sama sekali tidak masalah — dan untuk skala portofolio/personal, jauh lebih praktis daripada harus aktifkan billing.

---

## 2. File yang Dibuat/Diperbarui

```
lib/
├── core/utils/image_encoder.dart          # BARU — kompres foto ke base64
│
└── features/profile/
    ├── domain/
    │   ├── repositories/profile_repository.dart          # diperbarui — signature uploadPhoto
    │   └── usecases/
    │       ├── watch_profile_usecase.dart
    │       ├── update_name_usecase.dart
    │       ├── upload_profile_photo_usecase.dart          # diperbarui — Result<void>
    │       └── update_notification_setting_usecase.dart
    ├── data/
    │   ├── datasources/profile_remote_data_source.dart    # diperbarui — HAPUS Firebase Storage
    │   └── repositories/profile_repository_impl.dart      # diperbarui
    └── presentation/
        ├── providers/profile_providers.dart                # diperbarui — hapus DI FirebaseStorage
        ├── widgets/
        │   ├── profile_avatar.dart                          # BARU — render base64 / inisial nama
        │   ├── profile_header.dart                          # diperbarui — pakai ProfileAvatar
        │   └── settings_menu_tile.dart
        └── pages/
            ├── profile_page.dart
            ├── edit_profile_page.dart
            └── change_password_page.dart
```

Juga diperbarui sebelumnya: `user_entity.dart` (+`notificationsEnabled`), `user_model.dart` (parsing dari `settings.notificationsEnabled`), dan `app_shell.dart` (tab Profile, bottom nav lengkap 4 tab).

---

## 3. Cara Pasang

1. Salin/timpa semua file di atas ke project kamu.
2. **Update `pubspec.yaml`**:
   - **Hapus** baris `firebase_storage: ^12.1.0` (tidak dipakai lagi).
   - **Tambahkan**:
     ```yaml
     image: ^4.2.0
     ```
     (package murni Dart untuk resize/kompres gambar, tanpa setup native tambahan)
3. `flutter pub get`, lalu `flutter run`.
4. **Tidak perlu** mengaktifkan Firebase Storage di Firebase Console sama sekali untuk fitur ini — cukup Firestore yang sudah ada.

---

## 4. Cara Kerja Singkat

1. User tap foto di `ProfileHeader` → `image_picker` buka galeri.
2. File dibaca jadi bytes → `ImageEncoder.compressToDataUri()`: resize ke maksimal 300px, encode JPEG dengan kualitas diturunkan bertahap (70→50→35→20) sampai ukurannya ≤700KB base64. Kalau tetap kebesaran, return `null` → muncul pesan "Foto terlalu besar".
3. Hasilnya (`data:image/jpeg;base64,...`) langsung ditulis ke field `photoUrl` di dokumen `users/{uid}` — **tidak ada** panggilan ke Storage sama sekali.
4. `ProfileAvatar` mendeteksi apakah `photoUrl` adalah data URI (`ImageEncoder.decodeDataUri`) lalu render lewat `Image.memory`. Kalau belum ada foto, otomatis tampil inisial nama sebagai fallback.
5. **Profile pakai stream real-time sendiri** (`profileStreamProvider`, beda dari `authStateProvider` yang cuma "bangun" saat sign-in/sign-out) — jadi perubahan nama/foto langsung tercermin di UI tanpa perlu logout-login.
6. **Ubah password TIDAK pakai `updatePassword()` langsung** (Firebase Auth menolaknya kalau sesi sudah agak lama — "requires-recent-login"). `ChangePasswordPage` reuse `ForgotPasswordUseCase` dari fase Authentication — kirim link reset ke email sendiri.

---

## 5. Testing Manual

| Skenario | Langkah | Hasil yang diharapkan |
|---|---|---|
| Belum ada foto | Buka Profil untuk akun baru | Avatar menampilkan inisial nama/email, bukan foto kosong/rusak |
| Upload foto | Tap avatar, pilih foto dari galeri | Foto muncul di avatar setelah beberapa detik; cek field `photoUrl` di Firebase Console diawali `data:image/jpeg;base64,` |
| Ganti foto | Upload foto lain | Foto lama tergantikan, nama & pengaturan notifikasi tidak ikut berubah |
| Foto besar | Upload foto resolusi tinggi (misal 4000×3000) | Tetap berhasil — otomatis terkompres ke ≤700KB tanpa campur tangan user |
| Edit nama | Tap "Edit Profil", ubah nama, simpan | Nama baru langsung tampil real-time di header |
| Toggle notifikasi | Tap switch "Notifikasi" | Berubah tanpa reload; `users/{uid}.settings.notificationsEnabled` ikut berubah di Firestore |
| Ubah password | Tap "Ubah Password" → "Kirim Link" | Muncul konfirmasi terkirim, cek inbox email |
| Logout | Tap "Logout", konfirmasi | Kembali ke halaman Login otomatis lewat `_AuthGate` |
| Tidak ada biaya | Cek Firebase Console → Storage | Tidak ada bucket/file baru yang terbuat sama sekali |

---

## 6. Kriteria Keberhasilan Fase Ini

- ✅ Fitur foto profil berfungsi penuh tanpa Firebase Storage / tanpa paket Blaze.
- ✅ Fallback inisial nama membuat avatar tetap terlihat profesional walau belum upload foto.
- ✅ Kompresi otomatis mencegah dokumen Firestore membengkak melebihi batas 1 MB.
- ✅ Ubah nama, ubah password, toggle notifikasi, dan logout tetap berfungsi seperti sebelumnya.
- ✅ Semua 4 tab di `AppShell` punya fitur nyata — tidak ada lagi placeholder.

---

## 7. Semua Fitur Inti FinTrack — Selesai

| Fitur | Status |
|---|---|
| Authentication | ✅ |
| Dashboard Analytics | ✅ |
| Transaction CRUD | ✅ |
| Category Management | ✅ |
| Budget Management | ✅ |
| Financial Report | ✅ |
| Profile (foto tanpa biaya) | ✅ |

---

## 8. Langkah Selanjutnya

Sisa dari roadmap awal:

1. **Testing** — unit test untuk use case murni (`CalculateDashboardSummaryUseCase`, `CalculateBudgetProgressUseCase`, `CalculateReportSummaryUseCase`, `ImageEncoder`, dan validasi di use case Auth/Transaction/Budget) — semuanya sengaja dipisah dari Firebase sejak awal supaya bagian ini tinggal dikerjakan tanpa mock rumit.
2. **Deployment** — build APK release, ambil screenshot tiap halaman, lengkapi README GitHub untuk portofolio (target kualitas yang kamu minta di Tahap 1).

Coba dulu testing manual di atas untuk seluruh alur app dari awal (register sampai logout, termasuk upload foto). Kalau semua lancar, kabari saya — kita lanjut ke fase **Testing**.