# FinTrack — Fase Transaction CRUD

> Lanjutan dari fase Authentication. Ini fitur inti aplikasi: tambah, lihat, ubah, hapus transaksi — mengikuti skema `transactions` (Tahap 3) dan desain Transaction List & Add Transaction (Tahap 4).

---

## 1. File yang Dibuat

```
lib/
├── core/
│   ├── constants/categories.dart          # kategori default + ikon
│   └── utils/
│       ├── currency_formatter.dart        # format Rupiah
│       └── date_label_formatter.dart      # label "Hari Ini"/"Kemarin"
│
└── features/transaction/
    ├── domain/
    │   ├── entities/transaction_entity.dart   # + enum TransactionType
    │   ├── repositories/transaction_repository.dart
    │   └── usecases/
    │       ├── watch_transactions_usecase.dart
    │       ├── add_transaction_usecase.dart      # validasi nominal > 0
    │       ├── update_transaction_usecase.dart
    │       └── delete_transaction_usecase.dart
    ├── data/
    │   ├── models/transaction_model.dart
    │   ├── datasources/transaction_remote_data_source.dart
    │   └── repositories/transaction_repository_impl.dart
    └── presentation/
        ├── providers/transaction_providers.dart
        ├── widgets/
        │   ├── transaction_list_tile.dart
        │   ├── category_grid_picker.dart
        │   └── type_segmented_control.dart
        └── pages/
            ├── transaction_list_page.dart
            └── add_transaction_page.dart      # dipakai untuk Tambah & Ubah
```

`main.dart` juga diperbarui — setelah login, langsung diarahkan ke `TransactionListPage` supaya fitur ini bisa langsung dites (Dashboard sungguhan menyusul di fase berikutnya).

---

## 2. Cara Pasang

1. Salin file-file di atas ke project kamu, ikuti struktur folder yang sama.
2. Timpa `lib/main.dart` yang lama dengan versi terbaru (sudah diarahkan ke Transaction List).
3. `flutter pub get` lalu `flutter run`.

---

## 3. Poin Desain Penting

- **Nominal divalidasi di use case** (`amount > 0`), bukan cuma di UI — supaya aturan bisnis ini tetap berlaku walau nanti ada cara lain untuk menambah transaksi (misal import CSV di masa depan).
- **Query bulan aktif** (`transactionsStreamProvider`) otomatis real-time — begitu ada transaksi baru masuk ke Firestore, list & filter langsung update tanpa refresh manual, sesuai pola Stream yang dirancang di Tahap 2.
- **`monthSummaryProvider`** sudah dibuat sekarang (total income/expense bulan aktif, dihitung dari data yang sama) — ini nanti tinggal dipakai ulang di `BalanceCard`/`SummaryCard` pada fase Dashboard, tidak perlu query baru.
- **Hapus transaksi**: konfirmasi dialog dulu sebelum benar-benar dihapus dari Firestore, lalu snackbar dengan tombol **Undo** yang menulis ulang dokumen dengan ID yang sama (`restoreTransaction`) — sesuai pertimbangan UX di Tahap 4.
- **Form Tambah & Ubah pakai satu halaman yang sama** (`AddTransactionPage`) — `existing == null` berarti mode tambah, terisi berarti mode edit. Ini mengurangi duplikasi kode sesuai aturan coding di brief awal kamu.

---

## 4. Testing Manual

| Skenario | Langkah | Hasil yang diharapkan |
|---|---|---|
| Tambah transaksi expense | Isi nominal, pilih kategori Food, simpan | Muncul di list, warna merah, cek Firestore koleksi `transactions` ada dokumen baru dengan `userId` yang benar |
| Tambah transaksi income | Ganti ke tab Pemasukan, pilih kategori Salary | Muncul di list dengan warna hijau dan tanda `+` |
| Validasi nominal | Coba simpan tanpa isi nominal / isi 0 | Muncul pesan error, tidak tersimpan |
| Edit transaksi | Tap transaksi di list, ubah nominal, simpan | Data di Firestore ter-update, ada field `updatedAt` |
| Hapus transaksi | Swipe kiri, konfirmasi hapus | Transaksi hilang dari list, muncul snackbar dengan tombol Undo |
| Undo hapus | Tap "Undo" di snackbar sebelum hilang | Transaksi muncul lagi persis dengan data yang sama |
| Filter bulan | Tap panah kiri/kanan di filter bulan | List hanya menampilkan transaksi bulan yang dipilih |
| Filter tipe | Pilih "Income" di dropdown | List hanya menampilkan transaksi income |

Kalau query bulan belum jalan dan muncul error terkait index di console/log, itu tandanya composite index Firestore (`userId` + `date`) belum dibuat — klik link yang muncul di error tersebut untuk membuatnya otomatis (sudah disinggung di Tahap 3).

---

## 5. Kriteria Keberhasilan Fase Ini

- ✅ CRUD transaksi berjalan penuh dan tersambung real-time ke Firestore.
- ✅ Validasi nominal & kategori bekerja di level domain, bukan cuma UI.
- ✅ Undo setelah hapus berfungsi.
- ✅ `monthSummaryProvider` siap dipakai ulang untuk Dashboard.

---

## 6. Langkah Selanjutnya

Fase berikutnya sesuai roadmap:

**Fase Dashboard Analytics** — `BalanceCard`, ringkasan income/expense (pakai `monthSummaryProvider` yang sudah ada), grafik donut pengeluaran per kategori, dan daftar transaksi terakhir — sesuai desain Tahap 4.

Coba dulu testing di atas, kabari hasilnya, lalu kita lanjut ke Dashboard.