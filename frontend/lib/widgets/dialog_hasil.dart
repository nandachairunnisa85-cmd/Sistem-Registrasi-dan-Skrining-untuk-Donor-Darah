import 'package:flutter/material.dart';

void showHasilSkriningDialog(
  BuildContext context, {
  required bool isLolos,
  required String pesan,
  required Map<String, dynamic> donorData,
  required VoidCallback onSelesai,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      final Color primaryColor = isLolos ? const Color(0xFF0D9488) : const Color(0xFFE11D48);
      final Color bgColor = isLolos ? const Color(0xFFF0FDF4) : const Color(0xFFFFF1F2);
      final Color borderColor = isLolos ? const Color(0xFF86EFAC) : const Color(0xFFFECDD3);

      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 12,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Header dengan efek lingkaran lembut
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isLolos
                          ? [const Color(0xFF10B981), const Color(0xFF047857)]
                          : [const Color(0xFFF43F5E), const Color(0xFFBE123C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    isLolos ? Icons.check_circle_outline_rounded : Icons.highlight_off_rounded,
                    size: 46,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 18),

                // Badge status hasil
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor, width: 1.2),
                  ),
                  child: Text(
                    isLolos ? 'HASIL SKRINING: LOLOS' : 'HASIL SKRINING: DITOLAK',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Judul dialog
                Text(
                  isLolos ? 'Selamat! Memenuhi Syarat' : 'Belum Memenuhi Kriteria Medis',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // Pesan dari backend
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isLolos ? Icons.verified_rounded : Icons.info_outline_rounded,
                        color: primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          pesan,
                          style: TextStyle(
                            color: isLolos ? const Color(0xFF166534) : const Color(0xFF9F1239),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Ringkasan Parameter Donor
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      _buildSummaryRow('Pendonor', '${donorData['nama']} (${donorData['gol_darah']})'),
                      const Divider(height: 12, thickness: 0.5),
                      _buildSummaryRow('Berat Badan', '${donorData['berat_badan']} kg'),
                      const Divider(height: 12, thickness: 0.5),
                      _buildSummaryRow('Tekanan Darah', '${donorData['sistol']}/${donorData['diastol']} mmHg'),
                      const Divider(height: 12, thickness: 0.5),
                      _buildSummaryRow('Kadar Hb', '${donorData['hb']} g/dL'),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Tombol Aksi Dialog
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      onSelesai();
                    },
                    child: Text(
                      isLolos ? 'Selesai & Daftarkan Baru' : 'Kembali ke Form Skrining',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

void showKoneksiErrorDialog(BuildContext context, String pesan) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.wifi_off_rounded, color: Color(0xFFE11D48)),
          SizedBox(width: 10),
          Text('Koneksi Error', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: Text(pesan, style: const TextStyle(fontSize: 14, height: 1.4)),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F766E),
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Tutup'),
        ),
      ],
    ),
  );
}

Widget _buildSummaryRow(String label, String value) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
      ),
      Text(
        value,
        style: const TextStyle(fontSize: 12.5, color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
      ),
    ],
  );
}
