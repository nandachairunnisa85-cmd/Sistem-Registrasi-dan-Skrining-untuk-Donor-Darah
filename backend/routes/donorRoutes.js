// routes/donorRoutes.js - Pemetaan Endpoint API Donor Darah
const express = require('express');
const router = express.Router();
const donorController = require('../controllers/donorController');

// 1. Registrasi & Evaluasi Skrining Medis (White Box + MySQL)
// POST http://localhost:3000/api/donor/register
router.post('/register', donorController.registerDonor);

// 2. Mengambil Semua Daftar Pendonor yang Lolos
// GET http://localhost:3000/api/donor
router.get('/', donorController.getAllDonors);

// 3. Statistik Distribusi Golongan Darah & Rata-rata Medis
// GET http://localhost:3000/api/donor/stats
router.get('/stats', donorController.getDonorStats);

// 4. Status Kesehatan & Konektivitas Database Laragon
// GET http://localhost:3000/api/donor/health
router.get('/health', donorController.checkHealth);

// 5. Pencarian Pendonor Berdasarkan 16-Digit NIK
// GET http://localhost:3000/api/donor/nik/:nik
router.get('/nik/:nik', donorController.getDonorByNik);

module.exports = router;
