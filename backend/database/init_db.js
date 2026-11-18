// database/init_db.js - Skrip Otomatis Inisialisasi Database MySQL Laragon
const fs = require('fs');
const path = require('path');
const mysql = require('mysql2/promise');
const config = require('../config/env');

async function initializeDatabase() {
    console.log('======================================================================');
    console.log('       INISIALISASI BASIS DATA SISTEM DONOR DARAH (LARAGON)           ');
    console.log('======================================================================');
    console.log(`Target Host     : ${config.db.host}:${config.db.port}`);
    console.log(`Target Database : ${config.db.database}`);
    console.log(`User Database   : ${config.db.user}\n`);

    let rootConnection;

    try {
        // 1. Hubungkan ke MySQL server tanpa memilih database terlebih dahulu
        console.log('[INFO] Menghubungkan ke layanan MySQL Laragon...');
        rootConnection = await mysql.createConnection({
            host: config.db.host,
            port: config.db.port,
            user: config.db.user,
            password: config.db.password,
            multipleStatements: true
        });
        console.log('[INFO] Berhasil terhubung ke server MySQL Laragon.');

        // 2. Buat database jika belum ada
        console.log(`[INFO] Memverifikasi / membuat database "${config.db.database}"...`);
        await rootConnection.query(
            `CREATE DATABASE IF NOT EXISTS \`${config.db.database}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;`
        );
        console.log(`[INFO] Database "${config.db.database}" siap.`);

        // 3. Eksekusi skrip schema.sql untuk membuat tabel pendonor
        console.log('[INFO] Menjalankan migrasi skema tabel "pendonor"...');
        const schemaPath = path.resolve(__dirname, 'schema.sql');
        const schemaSql = fs.readFileSync(schemaPath, 'utf8');

        await rootConnection.query(schemaSql);
        console.log('[INFO] Skema tabel "pendonor" berhasil diterapkan.');

        // 4. Periksa apakah ingin menambahkan data dummy (opsional: via flag --seed)
        const isSeedRequested = process.argv.includes('--seed');
        if (isSeedRequested) {
            console.log('[INFO] Memasukkan data awal contoh (seed data)...');
            const seedPath = path.resolve(__dirname, 'seed.sql');
            if (fs.existsSync(seedPath)) {
                const seedSql = fs.readFileSync(seedPath, 'utf8');
                await rootConnection.query(seedSql);
                console.log('[INFO] Data seed berhasil dimasukkan ke tabel pendonor.');
            }
        }

        // 5. Cek jumlah data yang tersimpan
        const [rows] = await rootConnection.query(
            `SELECT COUNT(*) as total FROM \`${config.db.database}\`.\`pendonor\`;`
        );
        console.log(`[INFO] Total baris data pendonor saat ini: ${rows[0].total} baris.\n`);

        console.log('======================================================================');
        console.log('STATUS: Basis data siap digunakan oleh Backend Express & Frontend.');
        console.log('======================================================================');

    } catch (err) {
        console.error('\n[ERROR] GAGAL MENGHUBUNGKAN KE MYSQL LARAGON:');
        console.error(`Pesan Error: ${err.message}`);
        console.log('\nTIPS PEMECAHAN MASALAH:');
        console.log('1. Pastikan aplikasi Laragon sudah dibuka di Windows.');
        console.log('2. Klik tombol "Start All" di Laragon dan pastikan lampu service MySQL aktif.');
        console.log('3. Pastikan port MySQL adalah 3306 (default Laragon).');
        console.log('4. Cek konfigurasi di backend/.env jika Anda menggunakan password khusus.');
        process.exit(1);
    } finally {
        if (rootConnection) {
            await rootConnection.end();
        }
    }
}

if (require.main === module) {
    initializeDatabase();
}

module.exports = { initializeDatabase };
