import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'widgets/header_card.dart';
import 'widgets/data_diri_section.dart';
import 'widgets/parameter_medis_section.dart';
import 'widgets/dialog_hasil.dart';

void main() {
  runApp(const DonorApp());
}

class DonorApp extends StatelessWidget {
  const DonorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skrining Donor Darah',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF1F5F9), // Slate 100
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F766E), // Teal 700
          primary: const Color(0xFF0F766E),
          secondary: const Color(0xFF0D9488),
        ),
      ),
      home: const FormDonorPage(),
    );
  }
}

class FormDonorPage extends StatefulWidget {
  const FormDonorPage({super.key});

  @override
  State<FormDonorPage> createState() => _FormDonorPageState();
}

class _FormDonorPageState extends State<FormDonorPage> {
  final _formKey = GlobalKey<FormState>();

  // Controller untuk input teks (Logika Controller Utama)
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _bbController = TextEditingController();
  final TextEditingController _sistolController = TextEditingController();
  final TextEditingController _diastolController = TextEditingController();
  final TextEditingController _hbController = TextEditingController();

  String? _golonganDarah;
  final List<String> _listGolDarah = ['A', 'B', 'AB', 'O'];

  bool _isLoading = false;

  // Endpoint REST API lokal untuk komunikasi dengan Express & MySQL Laragon
  static const String _apiUrl = 'http://localhost:3000/api/donor/register';

  // Logika pengiriman data formulir ke backend REST API
  Future<void> _kirimData() async {
    // 1. Validasi Form Lokal (Target Pengujian Black Box)
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi seluruh formulir dengan data yang valid.'),
          backgroundColor: Color(0xFFE11D48),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final payload = {
      'nik': _nikController.text.trim(),
      'nama': _namaController.text.trim(),
      'gol_darah': _golonganDarah,
      'berat_badan': double.tryParse(_bbController.text.trim()) ?? 0,
      'sistol': int.tryParse(_sistolController.text.trim()) ?? 0,
      'diastol': int.tryParse(_diastolController.text.trim()) ?? 0,
      'hb': double.tryParse(_hbController.text.trim()) ?? 0,
    };

    try {
      final response = await http
          .post(
            Uri.parse(_apiUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (!mounted) return;

      final bool isLolos = data['status'] == 'Lolos';
      final String pesan = data['message'] ?? 'Tidak ada pesan respon dari server.';

      // Tampilkan Modal Dialog Hasil Skrining
      showHasilSkriningDialog(
        context,
        isLolos: isLolos,
        pesan: pesan,
        donorData: payload,
        onSelesai: () {
          if (isLolos) {
            _resetForm();
          }
        },
      );
    } catch (e) {
      if (!mounted) return;
      showKoneksiErrorDialog(
        context,
        'Gagal terhubung ke server backend di $_apiUrl.\n\nPastikan node server backend aktif dan MySQL Laragon berjalan.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nikController.clear();
    _namaController.clear();
    _bbController.clear();
    _sistolController.clear();
    _diastolController.clear();
    _hbController.clear();
    setState(() {
      _golonganDarah = null;
    });
  }

  @override
  void dispose() {
    _nikController.dispose();
    _namaController.dispose();
    _bbController.dispose();
    _sistolController.dispose();
    _diastolController.dispose();
    _hbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F9), // Spek Figma: background: #F0F5F9
      body: SelectionArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 28.0),
          child: Center(
            child: ConstrainedBox(
              // Sesuai spek Figma: width: 628px
              constraints: const BoxConstraints(maxWidth: 628),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ==========================================
                  // 1. HEADER CARD (Komponen Terstruktur: HeaderCard)
                  // ==========================================
                  const HeaderCard(),

                  const SizedBox(height: 18),

                  // ==========================================
                  // 2. FORMULIR PENDAFTARAN & PARAMETER MEDIS
                  // ==========================================
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 26.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // ------------------------------------------
                            // SEKSI 1: DATA DIRI PENDONOR (Komponen Terstruktur)
                            // ------------------------------------------
                            DataDiriSection(
                              nikController: _nikController,
                              namaController: _namaController,
                              golonganDarah: _golonganDarah,
                              listGolDarah: _listGolDarah,
                              onGolonganDarahChanged: (val) {
                                setState(() {
                                  _golonganDarah = val;
                                });
                              },
                            ),

                            const SizedBox(height: 28),

                            // ------------------------------------------
                            // SEKSI 2: PARAMETER FISIK & MEDIS (Komponen Terstruktur)
                            // ------------------------------------------
                            ParameterMedisSection(
                              bbController: _bbController,
                              sistolController: _sistolController,
                              diastolController: _diastolController,
                              hbController: _hbController,
                            ),

                            const SizedBox(height: 28),

                            // ------------------------------------------
                            // TOMBOL AKSI UTAMA (Sesuai Desain Asli Screenshot)
                            // ------------------------------------------
                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _kirimData,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0F766E), // Deep Teal
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shadowColor: const Color(0xFF0F766E).withValues(alpha: 0.4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_circle_outline_rounded, size: 20),
                                          SizedBox(width: 8),
                                          Text(
                                            'Daftar & Cek Kelayakan Skrining',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Tombol Reset Form
                            Center(
                              child: TextButton.icon(
                                onPressed: _isLoading ? null : _resetForm,
                                icon: const Icon(Icons.refresh_rounded, size: 16, color: Color(0xFF64748B)),
                                label: const Text(
                                  'Bersihkan Formulir',
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Footer info
                  const Center(
                    child: Text(
                      'Sistem Skrining Donor Darah',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
