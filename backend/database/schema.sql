-- =====================================================================
-- SKEMA BASIS DATA: SISTEM SKRINING & REGISTRASI DONOR DARAH
-- Kompatibel dengan Laragon MySQL / MariaDB (Port Default: 3306)
-- Format ID: Kode Unik Otomatis (D01, D02, D03, ...)
-- Seluruh kolom bersifat NOT NULL sesuai integritas data
-- =====================================================================

-- 1. Buat Database Jika Belum Ada
CREATE DATABASE IF NOT EXISTS `db_donor_darah`
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- 2. Gunakan Database
USE `db_donor_darah`;

-- 3. Buat Tabel `pendonor` (Format ID: D01, D02, ...)
CREATE TABLE IF NOT EXISTS `pendonor` (
    `id` VARCHAR(10) NOT NULL PRIMARY KEY COMMENT 'Kode unik pendonor (contoh: D01, D02)',
    `nik` VARCHAR(16) NOT NULL COMMENT 'Nomor Induk Kependudukan 16 digit angka',
    `nama` VARCHAR(50) NOT NULL COMMENT 'Nama lengkap calon pendonor (huruf & spasi)',
    `gol_darah` VARCHAR(5) NOT NULL COMMENT 'Golongan darah resmi (A, B, AB, O)',
    `berat_badan` FLOAT NOT NULL COMMENT 'Berat badan dalam kg (standar minimal 45 kg)',
    `sistol` INT NOT NULL COMMENT 'Tekanan darah sistolik mmHg (standar 100-150)',
    `diastol` INT NOT NULL COMMENT 'Tekanan darah diastolik mmHg (standar 70-100)',
    `hb` FLOAT NOT NULL COMMENT 'Kadar hemoglobin g/dL (standar minimal 12.5)',
    `status_donor` VARCHAR(20) NOT NULL DEFAULT 'Lolos' COMMENT 'Status kelayakan skrining medis',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Waktu pencatatan registrasi',

    -- Indeks untuk optimasi performa pencarian
    INDEX `idx_nik` (`nik`),
    INDEX `idx_gol_darah` (`gol_darah`),
    INDEX `idx_status_donor` (`status_donor`),
    INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
