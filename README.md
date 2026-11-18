# Sistem Registrasi dan Skrining untuk Donor Darah

Sistem terintegrasi untuk pendaftaran dan skrining kelayakan calon pendonor darah berbasis **Flutter Web**, **Node.js (Express.js)**, dan **MySQL (Laragon)**.

---

## 1. Fungsi & Tujuan Proyek

Proyek ini dibangun untuk mendigitalisasi proses skrining awal calon pendonor darah di fasilitas kesehatan atau unit donor darah (PMI).

### Tujuan Utama:
1. **Otomatisasi Skrining Medis:** Menyeleksi kelayakan calon pendonor secara objektif berdasarkan standar parameter fisik dan medis (Berat Badan minimal 45 kg, Tekanan Sistol 100–150 mmHg, Tekanan Diastol 70–100 mmHg, dan Kadar Hemoglobin minimal 12.5 g/dL).
2. **Integrasi Basis Data Relasional:** Menghubungkan antarmuka formulir donor secara *real-time* ke server database MySQL lokal (Laragon) melalui REST API yang aman dan efisien (*Connection Pooling*).
3. **Penerapan Integritas Data (*Data Integrity*):** Memastikan hanya calon pendonor yang lolos uji medis yang tersimpan di database dengan kode unik berurutan (`D01`, `D02`, dst.), sedangkan data yang tidak layak tidak mengotori tabel utama.

---

## 2. Struktur Folder & Berkas Beserta Fungsinya

Arsitektur proyek dipisahkan secara modular antara server backend, penyimpanan basis data, dan antarmuka frontend:

```text
donor_darah_project/
├── backend/
│   ├── config/
│   │   ├── database.js          # Koneksi pool MySQL & inisialisasi tabel otomatis
│   │   └── env.js               # Parser variabel lingkungan (.env)
│   ├── controllers/
│   │   └── donorController.js   # Logika bisnis, query SQL (INSERT/SELECT), & auto-ID D01
│   ├── routes/
│   │   └── donorRoutes.js       # Pemetaan endpoint REST API
│   ├── database/
│   │   ├── schema.sql           # DDL SQL resmi (CREATE DATABASE & TABLE)
│   │   ├── seed.sql             # Data awal sampel untuk demonstrasi
│   │   └── init_db.js           # Skrip CLI untuk inisialisasi DB
│   ├── screening.js             # Logika evaluasi standar kelayakan medis
│   ├── test_whitebox.js         # Pengujian White Box (4 Basis Paths)
│   ├── index.js                 # Entry point server Express (Port 3000)
│   └── package.json             # Dependensi Node.js (express, mysql2, cors)
├── frontend/
│   ├── lib/
│   │   ├── widgets/
│   │   │   ├── header_card.dart             # Header gradien, pill badges, & judul sistem
│   │   │   ├── data_diri_section.dart       # Form Seksi 1: NIK, Nama, & Golongan Darah
│   │   │   ├── parameter_medis_section.dart # Form Seksi 2: Berat Badan, Tensi, & Kadar Hb
│   │   │   ├── dialog_hasil.dart            # Pop-up modal responsif hasil Lolos / Ditolak
│   │   │   └── input_decoration.dart        # Helper styling dekorasi & border input field
│   │   └── main.dart                        # Entry point Flutter & State Controller form
│   ├── pubspec.yaml             # Konfigurasi dependensi Flutter
│   └── web/                     # Konfigurasi platform web
├── PANDUAN_TUGAS.md             # Dokumen panduan komprehensif & tanya-jawab dosen
├── .gitignore                   # Aturan pengabaian file build & node_modules
└── README.md                    # Dokumentasi utama proyek
```

### Tabel Fungsi Berkas Utama:

| Komponen / Berkas | Fungsi & Kegunaan |
| :--- | :--- |
| **`backend/config/database.js`** | Mengelola *connection pool* MySQL (`mysql2/promise`), mengeksekusi query, serta membuat database `db_donor_darah` dan tabel `pendonor` otomatis saat server dimulai. |
| **`backend/controllers/donorController.js`** | Menerima data pendaftaran, memanggil fungsi skrining, menghasilkan ID unik (`D01`, `D02`, dst.), dan menjalankan query `INSERT` atau `SELECT`. |
| **`backend/routes/donorRoutes.js`** | Menyediakan 5 rute REST API (`/register`, `/`, `/stats`, `/health`, `/nik/:nik`). |
| **`backend/screening.js`** | Modul independen berisi aturan keputusan medis pendonor. |
| **`backend/database/schema.sql`** | Skrip DDL SQL untuk struktur basis data relasional. |
| **`frontend/lib/main.dart`** | Pengatur alur utama aplikasi Flutter, state form, dan komunikasi HTTP POST ke backend. |
| **`frontend/lib/widgets/`** | Kumpulan modul antarmuka yang dipecah terstruktur agar kode rapi, mudah dibaca, dan mudah dirawat. |

---

## 3. Mekanisme Alur Sistem (*System Flow*)

Alur kerja data dari pengisian formulir hingga tersimpan di MySQL:

```text
[ Calon Pendonor ]
       │ Mengisi NIK, Nama, Gol Darah, Berat Badan, Tensi, Hb
       ▼
[ Frontend Flutter Web ]
       │ Validasi format input lokal (Wajib isi, NIK 16 digit angka)
       ▼
[ HTTP POST: /api/donor/register ]
       │ Mengirim payload JSON ke port 3000
       ▼
[ Backend Express.js ]
       │ Menyalurkan data ke donorController.js
       ▼
[ Logika Evaluasi Medis (screening.js) ]
       │
       ├─────────────────────────────────────────┐
       ▼                                         ▼
[ Status: DITOLAK ]                       [ Status: LOLOS ]
       │ (Salah satu syarat tidak terpenuhi)     │ (Semua syarat terpenuhi)
       │                                         ▼
       │                              [ Generate ID Unik: D01, D02... ]
       │                                         │
       │                                         ▼
       │                              [ SQL: INSERT INTO pendonor ]
       │                                         │
       │                                         ▼
       │                              [ Tersimpan di MySQL Laragon ]
       │                                         │
       └────────────────────┬────────────────────┘
                            ▼
              [ HTTP Response JSON (200 OK) ]
                            │
                            ▼
              [ Pop-Up Dialog Hasil di Flutter ]
              - Hijau : Memenuhi Syarat & Tersimpan
              - Merah : Belum Memenuhi Syarat Medis
```

---

## 4. Basis Data (*Database Architecture*)

Sistem menggunakan database relasional **MySQL** yang dijalankan melalui **Laragon**.

### A. Skema Tabel `pendonor`
- **Database:** `db_donor_darah`
- **Tabel:** `pendonor`
- **Collation:** `utf8mb4_unicode_ci`

```sql
CREATE DATABASE IF NOT EXISTS `db_donor_darah`
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE `db_donor_darah`;

CREATE TABLE IF NOT EXISTS `pendonor` (
    `id` VARCHAR(10) NOT NULL PRIMARY KEY COMMENT 'Kode ID Unik: D01, D02, dst.',
    `nik` VARCHAR(16) NOT NULL COMMENT 'NIK 16 digit angka resmi KTP',
    `nama` VARCHAR(100) NOT NULL COMMENT 'Nama lengkap pendonor',
    `gol_darah` ENUM('A', 'B', 'AB', 'O') NOT NULL COMMENT 'Golongan darah pendonor',
    `berat_badan` DECIMAL(5,2) NOT NULL COMMENT 'Berat badan dalam kg (minimal 45)',
    `sistol` INT NOT NULL COMMENT 'Tekanan darah sistol mmHg (100-150)',
    `diastol` INT NOT NULL COMMENT 'Tekanan darah diastol mmHg (70-100)',
    `hb` DECIMAL(4,2) NOT NULL COMMENT 'Kadar hemoglobin g/dL (minimal 12.5)',
    `status_donor` ENUM('Lolos', 'Ditolak') NOT NULL DEFAULT 'Lolos' COMMENT 'Status kelayakan skrining',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Waktu registrasi otomatis',
    
    INDEX `idx_nik` (`nik`),
    INDEX `idx_gol_darah` (`gol_darah`),
    INDEX `idx_status_donor` (`status_donor`),
    INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### B. Alasan Pemilihan Tipe Data:
1. **`id` (`VARCHAR(10)`):** Menyimpan kode unik berformat identitas rekam medis (`D01`, `D02`, dst.) yang dihasilkan otomatis oleh backend.
2. **`nik` (`VARCHAR(16)`):** NIK adalah nomor identitas, bukan nilai matematis. Disimpan sebagai teks agar angka nol di awal tidak terpotong dan terhindar dari *overflow* batas integer biasa (maksimal 2,1 miliar).
3. **`gol_darah` (`ENUM`):** Mengunci integritas nilai hanya pada 4 opsi valid (`A`, `B`, `AB`, `O`).
4. **`berat_badan` & `hb` (`DECIMAL`):** Menyimpan angka desimal presisi tinggi tanpa risiko pembulatan acak *floating point*.
5. **`sistol` & `diastol` (`INT`):** Tekanan darah selalu diukur dalam bilangan bulat mmHg.
6. **`NOT NULL` pada Seluruh Kolom:** Mencegah terjadinya *missing value* / data kosong demi keandalan data medis.
7. **Pengindeksan (`INDEX`):** Mempercepat waktu eksekusi query saat mencari riwayat berdasarkan NIK, memfilter stok golongan darah, atau mengurutkan waktu registrasi.

---

## 5. Cara Menjalankan Aplikasi

### 1. Aktifkan Database (Laragon)
- Buka aplikasi **Laragon** di Windows.
- Klik tombol **Start All** (pastikan MySQL berjalan pada port `3306`).

### 2. Jalankan Backend (Node.js)
```powershell
cd backend
npm install
npm start
```
*(Server akan otomatis membuat database dan tabel `pendonor` jika belum ada, lalu aktif di `http://localhost:3000`)*.

### 3. Jalankan Frontend (Flutter Web)
```powershell
cd frontend
flutter pub get
flutter run -d chrome
```
Aplikasi akan terbuka otomatis di Google Chrome.
