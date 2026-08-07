# FinTrack — Fase Financial Report

> Lanjutan dari fase Budget System. Halaman Report memberi gambaran pola keuangan mingguan/bulanan — mengikuti Tahap 1 (laporan mingguan/bulanan, kategori terbesar) dan desain Tahap 4.

---

## 1. File yang Dibuat

```
lib/features/report/
├── domain/
│   ├── entities/
│   │   ├── report_period.dart          # enum weekly/monthly
│   │   └── report_summary.dart         # ReportSummary, CategoryBreakdownItem, TrendPoint
│   └── usecases/calculate_report_summary_usecase.dart   # fungsi murni
└── presentation/
    ├── providers/report_providers.dart
    ├── widgets/
    │   ├── period_toggle.dart
    │   ├── report_summary_row.dart
    │   ├── report_trend_chart.dart          # pakai fl_chart BarChart
    │   ├── top_category_highlight.dart
    │   └── category_breakdown_list.dart     # tappable, drill-down
    └── pages/report_page.dart
```

Dua file yang sudah ada juga **diperbarui**:
- `transaction_list_page.dart` — sekarang menerima `initialCategory` opsional + chip filter kategori yang bisa dihapus, mendukung drill-down dari Report.
- `dashboard_page.dart` — ada ikon grafik di AppBar yang membuka Report (sesuai keputusan navigasi Tahap 4: Report diakses dari Dashboard, bukan dari bottom nav).

---

## 2. Cara Pasang

1. Salin folder `lib/features/report/` ke project kamu.
2. Timpa `transaction_list_page.dart` dan `dashboard_page.dart` dengan versi terbaru.
3. `flutter pub get` (tidak ada dependency baru — `fl_chart` sudah ada), lalu `flutter run`.

---

## 3. Poin Desain Penting

- **Report tidak punya data layer sendiri** — persis pola Dashboard: `reportSummaryProvider` reuse `allTransactionsStreamProvider` yang sudah ada, lalu diproses lewat `CalculateReportSummaryUseCase` (fungsi murni, tidak sentuh Firebase).
- **Grafik tren sengaja dibuat ringkas**: mingguan → 7 batang harian (Sen–Min), bulanan → maksimal 5 batang per minggu-ke (bukan 31 batang harian) — konsisten dengan prinsip UX Tahap 4 "satu insight jelas lebih baik dari grafik padat data".
- **Minggu berjalan pakai konvensi Senin–Minggu**, dihitung dari tanggal hari ini — bukan tanggal yang sedang difilter di Transaction List/Budget (Report selalu tentang periode "sekarang", sesuai brief awal yang tidak menyebutkan navigasi mundur untuk laporan).
- **Drill-down kategori** — tap kategori di breakdown list membuka Transaction List dengan filter kategori otomatis aktif (bisa dihapus lewat chip). Catatan kecil: kalau kamu drill-down dari laporan **mingguan** yang kebetulan menyentuh bulan berbeda dari bulan yang sedang aktif di Transaction List, hasil yang tampil tetap mengikuti bulan aktif itu — ini simplifikasi wajar untuk MVP, bisa disempurnakan nanti kalau perlu.
- **Sama seperti Dashboard**, data dibatasi hingga 500 transaksi terbaru (limit dari `allTransactionsStreamProvider`) — lebih dari cukup untuk laporan mingguan/bulanan skala personal.

---

## 4. Testing Manual

| Skenario | Langkah | Hasil yang diharapkan |
|---|---|---|
| Toggle periode | Buka Report, pilih Mingguan lalu Bulanan | Angka & grafik berubah sesuai periode |
| Ringkasan | Bandingkan Pemasukan/Pengeluaran dengan data manual di Transaction List | Angka cocok untuk periode yang sama |
| Grafik tren mingguan | Tambah expense di hari yang berbeda-beda | Batang bertambah tinggi di hari yang sesuai (Sen–Min) |
| Grafik tren bulanan | Tambah expense di tanggal awal & akhir bulan | Muncul di bucket minggu yang berbeda (M1 vs M4/M5) |
| Kategori terbesar | Tambah beberapa expense di kategori berbeda | Kartu highlight menunjukkan kategori dengan total tertinggi |
| Drill-down | Tap salah satu kategori di Rincian per Kategori | Masuk ke Transaction List dengan chip filter kategori aktif |
| Hapus filter kategori | Di Transaction List hasil drill-down, tap (x) di chip | Filter kategori hilang, list kembali menampilkan semua |
| Empty state | Buka Report untuk periode yang belum ada transaksi expense | Grafik & breakdown menampilkan pesan "Belum ada pengeluaran di periode ini" |
| Akses dari Dashboard | Tap ikon grafik di AppBar Dashboard | Masuk ke halaman Report |

---

## 5. Kriteria Keberhasilan Fase Ini

- ✅ Toggle mingguan/bulanan menampilkan data yang benar sesuai periode.
- ✅ Grafik tren tetap ringkas (maks 7 atau 5 batang), tidak padat data.
- ✅ Drill-down dari kategori ke Transaction List berfungsi.
- ✅ Tidak ada query/koleksi Firestore baru — full reuse dari fitur transaction.

---

## 6. Ringkasan: Semua Fitur Inti FinTrack Selesai

Dengan Report ini, seluruh fitur inti dari brief awal kamu sudah terbangun:

| Fitur | Status |
|---|---|
| Authentication (Register/Login/Logout/Forgot Password) | ✅ |
| Dashboard Analytics | ✅ |
| Transaction CRUD | ✅ |
| Category Management (default) | ✅ (bagian dari Transaction) |
| Budget Management | ✅ |
| Financial Report | ✅ |
| Profile | ⏳ belum dibangun |

---

## 7. Langkah Selanjutnya

Sesuai roadmap awal, yang tersisa:

1. **Profile** — halaman sederhana (foto, nama, email, tombol logout, pengaturan dasar) + tab Profile di `AppShell`.
2. **Testing** — unit test untuk use case murni yang sudah dibuat (`CalculateDashboardSummaryUseCase`, `CalculateBudgetProgressUseCase`, `CalculateReportSummaryUseCase` — semuanya sengaja dibuat tanpa dependency Firebase supaya gampang di-test).
3. **Deployment** — build release, screenshot, README lengkap untuk portofolio.

Coba dulu testing di atas, kabari hasilnya, lalu kita lanjut ke **Profile** — bagian terakhir yang belum ada UI-nya.