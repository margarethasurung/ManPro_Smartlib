# Kesesuaian Frontend dengan Proposal SmartLib (versi final)
| Aturan proposal | Status di frontend |
|---|---|
| 3 peran: Anggota, Pustakawan, Manajemen | Sesuai (akun demo di `js/config.js`) |
| 1 buku aktif, pinjam 7 hari | Sesuai (pengajuan yang belum diambil ikut dihitung) |
| Alur diajukan, dikonfirmasi, diambil | Sesuai; Pustakawan konfirmasi/tolak/tandai diambil |
| Hangus jika tidak diambil 10 menit sebelum tutup | Sesuai (`PICKUP_CUTOFF_MINUTES`, jam tutup `CLOSING_HOUR`) |
| Walk-in dicatat Pustakawan | Pinjam walk-in lewat "Input walk-in (scan)"; **walk-in pesan tempat belum ada** |
| Denda Rp1.000/hari, blokir pinjam | Sesuai |
| Bayar denda tunai (Pustakawan) / daring sandbox | Sesuai (tombol sandbox masih simulasi, belum Midtrans) |
| Pesan tempat, anti bentrok, no-show 15 menit | Sesuai (ruang tertutup + Meja Komunal) |
| Pengadaan: Pustakawan usul, Manajemen setuju/tolak, Pustakawan tandai diadakan | Sesuai |
| Laporan Manajemen (pinjam, denda, tempat, pengadaan) | Sesuai, tabel + ekspor CSV (grafik belum ada) |
| Perpanjangan | Dihapus (di luar ruang lingkup) |
| Database, RBAC, hash, HTTPS | **Belum**: data masih localStorage; diganti saat integrasi Laravel |
Fitur di luar proposal yang masih ada di kode: acara, pengumuman, baca buku, ulasan, favorit, paspor membaca, PWA.
