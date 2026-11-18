// controllers/donorController.js - Logika Bisnis & Pengolahan Data Donor Darah
const db = require('../config/database');
const { validasiDonor } = require('../screening');

/**
 * Helper untuk menghasilkan ID kode unik otomatis berurutan: D01, D02, D03, dst.
 */
async function generateCustomDonorId() {
    try {
        const [rows] = await db.query(`
            SELECT id FROM pendonor 
            WHERE id LIKE 'D%' 
            ORDER BY CAST(SUBSTRING(id, 2) AS UNSIGNED) DESC 
            LIMIT 1
        `);

        if (!rows || rows.length === 0) {
            return 'D01';
        }

        const lastId = String(rows[0].id);
        const numberPart = parseInt(lastId.substring(1), 10);
        const nextNumber = isNaN(numberPart) ? 1 : numberPart + 1;
        return `D${String(nextNumber).padStart(2, '0')}`;
    } catch (err) {
        // Fallback jika terjadi kendala query max id
        return 'D01';
    }
}

/**
 * Controller untuk Registrasi Calon Pendonor & Skrining Medis
 * Mengintegrasikan pengujian White Box (screening.js) dengan penyimpanan MySQL Laragon
 */
async function registerDonor(req, res) {
    try {
        const { nik, nama, gol_darah, berat_badan, sistol, diastol, hb } = req.body;

        // 1. Validasi Keberadaan Input Dasar (Server-side validation)
        if (!nik || !nama || !gol_darah || berat_badan === undefined || sistol === undefined || diastol === undefined || hb === undefined) {
            return res.status(400).json({
                status: 'Error',
                message: 'Data formulir tidak lengkap. Mohon isi semua kolom yang diperlukan.'
            });
        }

        // 2. Normalisasi & Konversi Tipe Data
        const parsedBB = parseFloat(berat_badan);
        const parsedSistol = parseInt(sistol, 10);
        const parsedDiastol = parseInt(diastol, 10);
        const parsedHb = parseFloat(hb);

        if (isNaN(parsedBB) || isNaN(parsedSistol) || isNaN(parsedDiastol) || isNaN(parsedHb)) {
            return res.status(400).json({
                status: 'Error',
                message: 'Nilai parameter medis harus berupa angka valid.'
            });
        }

        // 3. Eksekusi Logika Skrining Medis (White Box Testing: Basis Path)
        const hasilSkrining = validasiDonor(parsedBB, parsedSistol, parsedDiastol, parsedHb);

        // 4. Jika DITOLAK skrining medis:
        // Sesuai perancangan sistem, calon pendonor yang tidak lolos tidak dimasukkan ke daftar pendonor resmi
        if (!hasilSkrining.lolos) {
            return res.status(200).json({
                status: 'Ditolak',
                message: hasilSkrining.pesan
            });
        }

        // 5. Generate Kode Unik Otomatis (D01, D02, D03, ...)
        const customId = await generateCustomDonorId();

        // 6. Jika LOLOS skrining medis: Simpan ke basis data MySQL Laragon (tabel pendonor)
        const insertQuery = `
            INSERT INTO pendonor 
            (id, nik, nama, gol_darah, berat_badan, sistol, diastol, hb, status_donor)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'Lolos')
        `;

        await db.query(insertQuery, [
            customId,
            String(nik).trim(),
            String(nama).trim(),
            String(gol_darah).trim().toUpperCase(),
            parsedBB,
            parsedSistol,
            parsedDiastol,
            parsedHb
        ]);

        return res.status(200).json({
            status: 'Lolos',
            message: hasilSkrining.pesan,
            insertId: customId,
            data: {
                id: customId,
                nik: String(nik).trim(),
                nama: String(nama).trim(),
                gol_darah: String(gol_darah).trim().toUpperCase(),
                berat_badan: parsedBB,
                sistol: parsedSistol,
                diastol: parsedDiastol,
                hb: parsedHb,
                status_donor: 'Lolos'
            }
        });

    } catch (err) {
        console.error('Error saat registrasi pendonor:', err);
        return res.status(500).json({
            status: 'Error',
            message: 'Gagal memproses data ke database: ' + err.message
        });
    }
}

/**
 * Controller untuk Mengambil Seluruh Daftar Pendonor yang Lolos Skrining
 */
async function getAllDonors(req, res) {
    try {
        const { gol_darah, limit } = req.query;
        let sql = 'SELECT * FROM pendonor';
        const params = [];

        if (gol_darah) {
            sql += ' WHERE gol_darah = ?';
            params.push(gol_darah.toUpperCase());
        }

        sql += ' ORDER BY CAST(SUBSTRING(id, 2) AS UNSIGNED) ASC, created_at ASC';

        if (limit && !isNaN(parseInt(limit, 10))) {
            sql += ` LIMIT ${parseInt(limit, 10)}`;
        }

        const [rows] = await db.query(sql, params);

        return res.status(200).json({
            status: 'Success',
            total: rows.length,
            data: rows
        });
    } catch (err) {
        console.error('Error saat mengambil data pendonor:', err);
        return res.status(500).json({
            status: 'Error',
            message: 'Gagal mengambil data dari database: ' + err.message
        });
    }
}

/**
 * Controller untuk Mencari Data Pendonor Berdasarkan NIK
 */
async function getDonorByNik(req, res) {
    try {
        const { nik } = req.params;
        const [rows] = await db.query('SELECT * FROM pendonor WHERE nik = ? ORDER BY created_at DESC', [nik]);

        if (rows.length === 0) {
            return res.status(404).json({
                status: 'Not Found',
                message: `Data pendonor dengan NIK ${nik} tidak ditemukan.`
            });
        }

        return res.status(200).json({
            status: 'Success',
            data: rows
        });
    } catch (err) {
        console.error('Error saat mencari NIK pendonor:', err);
        return res.status(500).json({
            status: 'Error',
            message: 'Gagal mengambil data NIK: ' + err.message
        });
    }
}

/**
 * Controller untuk Statistik Pendonor (Ringkasan Golongan Darah & Rata-rata Hb)
 */
async function getDonorStats(req, res) {
    try {
        const [totalRows] = await db.query('SELECT COUNT(*) as total FROM pendonor');
        const [golDarahRows] = await db.query(`
            SELECT gol_darah, COUNT(*) as jumlah 
            FROM pendonor 
            GROUP BY gol_darah
        `);
        const [avgRows] = await db.query(`
            SELECT 
                ROUND(AVG(berat_badan), 1) as avg_bb,
                ROUND(AVG(sistol), 1) as avg_sistol,
                ROUND(AVG(diastol), 1) as avg_diastol,
                ROUND(AVG(hb), 2) as avg_hb
            FROM pendonor
        `);

        return res.status(200).json({
            status: 'Success',
            stats: {
                total_pendonor: totalRows[0].total,
                distribusi_gol_darah: golDarahRows,
                rata_rata_medis: avgRows[0]
            }
        });
    } catch (err) {
        console.error('Error saat mengambil statistik pendonor:', err);
        return res.status(500).json({
            status: 'Error',
            message: 'Gagal mengambil statistik: ' + err.message
        });
    }
}

/**
 * Controller Pemeriksaan Koneksi & Status Database
 */
async function checkHealth(req, res) {
    try {
        const connCheck = await db.testConnection();
        if (connCheck.ok) {
            const [rows] = await db.query('SELECT COUNT(*) as count FROM pendonor');
            return res.status(200).json({
                status: 'Healthy',
                database: 'Connected to Laragon MySQL',
                total_records: rows[0].count,
                timestamp: new Date().toISOString()
            });
        } else {
            return res.status(503).json({
                status: 'Degraded',
                database: 'Disconnected',
                error: connCheck.error
            });
        }
    } catch (err) {
        return res.status(500).json({
            status: 'Error',
            message: err.message
        });
    }
}

module.exports = {
    registerDonor,
    getAllDonors,
    getDonorByNik,
    getDonorStats,
    checkHealth,
    generateCustomDonorId
};
