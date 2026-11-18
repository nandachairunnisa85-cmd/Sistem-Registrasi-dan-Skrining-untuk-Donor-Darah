import 'package:flutter/material.dart';
import 'input_decoration.dart';

class ParameterMedisSection extends StatelessWidget {
  final TextEditingController bbController;
  final TextEditingController sistolController;
  final TextEditingController diastolController;
  final TextEditingController hbController;

  const ParameterMedisSection({
    super.key,
    required this.bbController,
    required this.sistolController,
    required this.diastolController,
    required this.hbController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header Seksi 2: Parameter Fisik & Medis
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFCCFBF1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.monitor_heart_outlined, color: Color(0xFF0F766E), size: 20),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Parameter Fisik & Medis',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'Kriteria kelayakan skrining donor darah',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Info Standar Skrining Box
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDFA), // Light teal background
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF99F6E4)),
          ),
          child: const Row(
            children: [
              Icon(Icons.tune_rounded, color: Color(0xFF0F766E), size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Standar: BB ≥ 45 kg • Sistol 100–150 • Diastol 70–100 • Hb ≥ 12.5 g/dL',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF115E59),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Input Berat Badan
        TextFormField(
          controller: bbController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: customInputDecoration(
            label: 'Berat Badan',
            prefixIcon: Icons.speed_outlined,
            suffix: 'Syarat minimal: 45 kg',
          ),
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Berat badan wajib diisi';
            }
            final bb = double.tryParse(val.trim());
            if (bb == null || bb <= 0) {
              return 'Masukkan angka berat badan yang valid';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),

        // Input Tekanan Darah (Sistol & Diastol)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  TextFormField(
                    controller: sistolController,
                    keyboardType: TextInputType.number,
                    decoration: customInputDecoration(
                      label: 'Tekanan Sistol',
                      prefixIcon: Icons.speed_outlined,
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Sistol wajib diisi';
                      }
                      final s = int.tryParse(val.trim());
                      if (s == null || s <= 0) {
                        return 'Harus angka valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Normal: 100 - 150',
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                children: [
                  TextFormField(
                    controller: diastolController,
                    keyboardType: TextInputType.number,
                    decoration: customInputDecoration(
                      label: 'Tekanan Diastol',
                      prefixIcon: Icons.speed_outlined,
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Diastol wajib diisi';
                      }
                      final d = int.tryParse(val.trim());
                      if (d == null || d <= 0) {
                        return 'Harus angka valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Normal: 70 - 100',
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Input Kadar Hemoglobin (Hb)
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: hbController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: customInputDecoration(
                label: 'Kadar Hemoglobin (Hb)',
                prefixIcon: Icons.water_drop_outlined,
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Kadar hemoglobin wajib diisi';
                }
                final hb = double.tryParse(val.trim());
                if (hb == null || hb <= 0) {
                  return 'Masukkan angka Hb yang valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 4),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Syarat minimal: 12.5 g/dL',
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
