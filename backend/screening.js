// screening.js - Logika pemeriksaan fisik pendonor darah
function validasiDonor(beratBadan, sistol, diastol, hb) {
    // Jalur 1: Cek berat badan (minimal 45 kg)
    if (beratBadan < 45) {
        return { lolos: false, pesan: "Ditolak: Berat badan minimal 45 kg." };
    }

    // Jalur 2: Cek tekanan darah (Sistol: 100-150, Diastol: 70-100)
    if (sistol < 100 || sistol > 150 || diastol < 70 || diastol > 100) {
        return { lolos: false, pesan: "Ditolak: Tekanan darah tidak normal." };
    }

    // Jalur 3: Cek hemoglobin (minimal 12.5 g/dL)
    if (hb < 12.5) {
        return { lolos: false, pesan: "Ditolak: Kadar hemoglobin (Hb) kurang dari 12.5 g/dL." };
    }

    // Jalur 4: Memenuhi semua syarat
    return { lolos: true, pesan: "Lolos: Memenuhi syarat donor darah." };
}

module.exports = { validasiDonor };