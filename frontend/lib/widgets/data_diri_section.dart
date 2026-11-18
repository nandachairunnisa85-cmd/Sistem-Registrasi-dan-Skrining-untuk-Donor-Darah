import 'package:flutter/material.dart';
import 'input_decoration.dart';

class DataDiriSection extends StatelessWidget {
  final TextEditingController nikController;
  final TextEditingController namaController;
  final String? golonganDarah;
  final List<String> listGolDarah;
  final ValueChanged<String?> onGolonganDarahChanged;

  const DataDiriSection({
    super.key,
    required this.nikController,
    required this.namaController,
    required this.golonganDarah,
    required this.listGolDarah,
    required this.onGolonganDarahChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header Seksi 1: Data Diri Pendonor
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFCCFBF1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person_outline_rounded, color: Color(0xFF0F766E), size: 20),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Data Diri Pendonor',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'Informasi identitas resmi sesuai KTP',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Input NIK (16 digit angka)
        TextFormField(
          controller: nikController,
          keyboardType: TextInputType.number,
          maxLength: 16,
          decoration: customInputDecoration(
            label: 'Nomor Induk Kependudukan (NIK)',
            prefixIcon: Icons.badge_outlined,
            suffix: 'Wajib tepat 16 digit angka',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'NIK wajib diisi';
            }
            final trimmed = value.trim();
            if (!RegExp(r'^[0-9]{16}$').hasMatch(trimmed)) {
              return 'NIK harus berupa 16 digit angka valid';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),

        // Input Nama Lengkap (3-30 karakter, hanya huruf & spasi)
        TextFormField(
          controller: namaController,
          decoration: customInputDecoration(
            label: 'Nama Lengkap',
            prefixIcon: Icons.person_rounded,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Nama lengkap wajib diisi';
            }
            final trimmed = value.trim();
            if (trimmed.length < 3 || trimmed.length > 30) {
              return 'Nama harus antara 3 hingga 30 karakter';
            }
            if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(trimmed)) {
              return 'Nama hanya boleh berupa huruf dan spasi';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),

        // Dropdown Golongan Darah (A, B, AB, O)
        DropdownButtonFormField<String>(
          initialValue: golonganDarah,
          hint: const Text(
            'Pilih Golongan Darah',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
          ),
          decoration: customInputDecoration(
            label: 'Golongan Darah',
            prefixIcon: Icons.water_drop_outlined,
          ),
          items: listGolDarah.map((gol) {
            return DropdownMenuItem(
              value: gol,
              child: Text(gol, style: const TextStyle(fontWeight: FontWeight.w600)),
            );
          }).toList(),
          onChanged: onGolonganDarahChanged,
          validator: (val) => val == null ? 'Golongan darah wajib dipilih' : null,
        ),
      ],
    );
  }
}
