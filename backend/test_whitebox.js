// test_whitebox.js - Pengujian White Box: Basis Path Testing
// Berdasarkan Cyclomatic Complexity V(G) = P + 1 = 3 + 1 = 4 Jalur Independen
const { validasiDonor } = require('./screening');

console.log("======================================================================");
console.log("             PENGUJIAN WHITE BOX: BASIS PATH TESTING                  ");
console.log("              Sistem Skrining Kelayakan Donor Darah                   ");
console.log("======================================================================");
console.log("Kompleksitas Siklomatis (Cyclomatic Complexity):");
console.log("- Jumlah Titik Keputusan (Predicate Nodes / P) = 3");
console.log("- V(G) = P + 1 = 3 + 1 = 4 Jalur Independen (Basis Paths)\n");

const testCases = [
    {
        path: "Path 1 (BB < 45)",
        input: { bb: 40, sistol: 120, diastol: 80, hb: 13.0 },
        expectedStatus: false,
        expectedMessagePrefix: "Ditolak: Berat badan",
        description: "Berat badan kurang dari batas minimal 45 kg"
    },
    {
        path: "Path 2 (Tensi di luar 100-150 / 70-100)",
        input: { bb: 55, sistol: 160, diastol: 80, hb: 13.0 },
        expectedStatus: false,
        expectedMessagePrefix: "Ditolak: Tekanan darah",
        description: "Sistol 160 mmHg melebihi batas normal (100-150)"
    },
    {
        path: "Path 3 (Hb < 12.5)",
        input: { bb: 60, sistol: 120, diastol: 80, hb: 11.0 },
        expectedStatus: false,
        expectedMessagePrefix: "Ditolak: Kadar hemoglobin",
        description: "Kadar Hb 11.0 g/dL kurang dari batas minimal 12.5 g/dL"
    },
    {
        path: "Path 4 (Semua Parameter Normal)",
        input: { bb: 65, sistol: 120, diastol: 80, hb: 13.5 },
        expectedStatus: true,
        expectedMessagePrefix: "Lolos",
        description: "BB=65kg, Tensi=120/80 mmHg, Hb=13.5 g/dL (Lolos skrining)"
    }
];

let allPassed = true;

testCases.forEach((tc, idx) => {
    const result = validasiDonor(tc.input.bb, tc.input.sistol, tc.input.diastol, tc.input.hb);
    const passed = (result.lolos === tc.expectedStatus) && result.pesan.startsWith(tc.expectedMessagePrefix);

    if (!passed) allPassed = false;

    console.log(`[TEST ${idx + 1}] ${tc.path}`);
    console.log(`  Kondisi  : ${tc.description}`);
    console.log(`  Input    : BB=${tc.input.bb}kg, Sistol=${tc.input.sistol}, Diastol=${tc.input.diastol}, Hb=${tc.input.hb} g/dL`);
    console.log(`  Ekspektasi Status : ${tc.expectedStatus ? 'Lolos' : 'Ditolak'}`);
    console.log(`  Hasil Eksekusi    : [${result.lolos ? 'Lolos' : 'Ditolak'}] ${result.pesan}`);
    console.log(`  Status Pengujian  : ${passed ? 'PASSED (Sesuai Ekspektasi)' : ' FAILED'}\n`);
});

console.log("======================================================================");
console.log(`HASIL AKHIR: ${allPassed ? 'SEMUA 4 BASIS PATH BERHASIL DIUJI DENGAN TEPAT' : 'ADA PENGUJIAN GAGAL'}`);
console.log("======================================================================");
