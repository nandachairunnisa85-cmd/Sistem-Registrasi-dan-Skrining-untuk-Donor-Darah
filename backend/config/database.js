// config/database.js - Manajemen Koneksi Pool MySQL & Auto-Setup Basis Data
const mysql = require('mysql2/promise');
const config = require('./env');

let pool = null;

/**
 * Inisialisasi basis data dan tabel pendonor secara otomatis saat server berjalan.
 * Jika database 'db_donor_darah' belum ada di Laragon, sistem akan membuatnya secara mandiri.
 */
async function initDatabase() {
    let bootstrapConn;
    try {
        // 1. Hubungkan ke MySQL server tanpa memilih database dulu (untuk memastikan database ada)
        bootstrapConn = await mysql.createConnection({
            host: config.db.host,
            port: config.db.port,
            user: config.db.user,
            password: config.db.password
        });

        // 2. Buat database jika belum ada
        await bootstrapConn.query(
            `CREATE DATABASE IF NOT EXISTS \`${config.db.database}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;`
        );

        // 3. Buat tabel pendonor jika belum ada (Format ID: D01, D02, ... dan seluruh kolom NOT NULL)
        const createTableQuery = `
            CREATE TABLE IF NOT EXISTS \`${config.db.database}\`.\`pendonor\` (
                \`id\` VARCHAR(10) NOT NULL PRIMARY KEY,
                \`nik\` VARCHAR(16) NOT NULL,
                \`nama\` VARCHAR(50) NOT NULL,
                \`gol_darah\` VARCHAR(5) NOT NULL,
                \`berat_badan\` FLOAT NOT NULL,
                \`sistol\` INT NOT NULL,
                \`diastol\` INT NOT NULL,
                \`hb\` FLOAT NOT NULL,
                \`status_donor\` VARCHAR(20) NOT NULL DEFAULT 'Lolos',
                \`created_at\` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                INDEX \`idx_nik\` (\`nik\`),
                INDEX \`idx_gol_darah\` (\`gol_darah\`),
                INDEX \`idx_status_donor\` (\`status_donor\`),
                INDEX \`idx_created_at\` (\`created_at\`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        `;
        await bootstrapConn.query(createTableQuery);

        // Jika tabel sebelumnya sudah ada dengan id INT, perbarui menjadi VARCHAR(10)
        try {
            const [cols] = await bootstrapConn.query(`
                SELECT DATA_TYPE 
                FROM INFORMATION_SCHEMA.COLUMNS 
                WHERE TABLE_SCHEMA = ? AND TABLE_NAME = 'pendonor' AND COLUMN_NAME = 'id'
            `, [config.db.database]);

            if (cols.length > 0 && cols[0].DATA_TYPE !== 'varchar') {
                await bootstrapConn.query(`
                    ALTER TABLE \`${config.db.database}\`.\`pendonor\` 
                    MODIFY COLUMN \`id\` VARCHAR(10) NOT NULL
                `);
            }
        } catch (alterErr) {
            // Abaikan jika alter gagal / sudah varchar
        }

        console.log(`[Database] Terhubung ke MySQL Laragon (${config.db.host}:${config.db.port}).`);
        console.log(`[Database] Database "${config.db.database}" & tabel "pendonor" siap digunakan.`);
    } catch (err) {
        console.error(`[Database] Gagal auto-inisialisasi database di MySQL Laragon: ${err.message}`);
        console.log('[HINT] Pastikan layanan MySQL di Laragon sudah aktif (tombol "Start All").');
        throw err;
    } finally {
        if (bootstrapConn) {
            await bootstrapConn.end();
        }
    }

    // Buat connection pool untuk melayani request API secara efisien
    pool = mysql.createPool({
        host: config.db.host,
        port: config.db.port,
        user: config.db.user,
        password: config.db.password,
        database: config.db.database,
        waitForConnections: config.db.waitForConnections,
        connectionLimit: config.db.connectionLimit,
        queueLimit: config.db.queueLimit
    });

    return pool;
}

/**
 * Helper untuk mengeksekusi parameterized query SQL
 */
async function query(sql, params = []) {
    if (!pool) {
        // Jika pool belum dibuat, inisialisasi dulu
        await initDatabase();
    }
    return pool.execute(sql, params);
}

/**
 * Fungsi untuk cek konektivitas database (health check)
 */
async function testConnection() {
    try {
        if (!pool) await initDatabase();
        const [rows] = await pool.query('SELECT 1 + 1 AS result');
        return { ok: true, result: rows[0].result };
    } catch (err) {
        return { ok: false, error: err.message };
    }
}

function getPool() {
    return pool;
}

module.exports = {
    initDatabase,
    query,
    testConnection,
    getPool
};
