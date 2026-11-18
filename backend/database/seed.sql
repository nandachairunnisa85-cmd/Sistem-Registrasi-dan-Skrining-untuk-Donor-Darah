-- =====================================================================
-- SEED DATA CONTOH: SISTEM REGISTRASI DONOR DARAH
-- Format Kode Unik ID: D01, D02, D03, D04
-- Seluruh kolom NOT NULL
-- =====================================================================

USE `db_donor_darah`;

INSERT INTO `pendonor` (`id`, `nik`, `nama`, `gol_darah`, `berat_badan`, `sistol`, `diastol`, `hb`, `status_donor`)
VALUES
('D01', '3201012345670001', 'Ahmad Fauzi Rahman', 'O', 65.5, 120, 80, 14.2, 'Lolos'),
('D02', '3201012345670004', 'Dewi Lestari', 'AB', 58.0, 118, 78, 12.8, 'Lolos');
