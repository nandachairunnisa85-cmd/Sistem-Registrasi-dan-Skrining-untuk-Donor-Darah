// index.js - Server REST API Express & Integrasi Database MySQL Laragon
const express = require('express');
const cors = require('cors');
const config = require('./config/env');
const { initDatabase } = require('./config/database');
const donorRoutes = require('./routes/donorRoutes');

const app = express();
const PORT = config.app.port;

// Konfigurasi CORS agar frontend (Flutter Web di Chrome) dapat mengakses API tanpa kendala
app.use(cors({
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use(express.json());

// Mendaftarkan Rute Modular Donor Darah
app.use('/api/donor', donorRoutes);

// Endpoint Informasi API
app.get('/', (req, res) => {
    res.json({
        message: 'Server API Sistem Skrining & Registrasi Donor Darah berjalan dengan baik.',
        status: 'OK',
        database: {
            host: config.db.host,
            port: config.db.port,
            name: config.db.database
        },
        endpoints: {
            register: 'POST /api/donor/register',
            listDonors: 'GET /api/donor',
            donorStats: 'GET /api/donor/stats',
            healthCheck: 'GET /api/donor/health'
        }
    });
});

// Inisialisasi Database MySQL Laragon & Menjalankan Server Express
async function startServer() {
    try {
        await initDatabase();
        console.log(`[INFO] Berhasil terhubung ke database MySQL lokal Laragon (${config.db.database} pada port ${config.db.port}).`);
        console.log('[INFO] Tabel "pendonor" siap digunakan.');
    } catch (err) {
        console.warn(`[WARN] Belum dapat terhubung ke MySQL Laragon (${err.message}).`);
        console.warn('[HINT] Pastikan aplikasi Laragon sudah aktif dan tombol "Start All" telah ditekan.');
    }

    app.listen(PORT, () => {
        console.log(`Server berjalan di http://localhost:${PORT}`);
        console.log(`API Register: POST http://localhost:${PORT}/api/donor/register`);
        console.log(`API List    : GET  http://localhost:${PORT}/api/donor`);
    });
}

startServer();

module.exports = app;
