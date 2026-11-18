# Kesesuaian Frontend dengan Proposal SmartLib

Peran: **Khim = Yohanes** (UI/UX Designer & Frontend), Retha = Margaretha (PM & Backend), Virgin = Rosvirgini (Database & QA).

## A. Kebutuhan fungsional (proposal bagian 5.1) vs prototipe
| Kebutuhan proposal | Status | Keterangan |
|---|---|---|
| Beranda: sapaan, cari cepat, rekomendasi, ringkasan layanan | Ada | `app.js` (`renderHome`) |
| Katalog 12 buku, cari, filter, urut, detail, pinjam/antre, wishlist | Ada | `catalog.js`, `CATALOG_PAGE_SIZE: 12`; wishlist lewat Favorit |
| Login/registrasi + hak akses multi-level | Sebagian | Ada Anggota dan Admin. **Belum ada peran Pustakawan terpisah** (kini digabung di Admin) |
| Pinjam, jatuh tempo, kembali, denda Rp1.000/hari, antrean, simulasi bayar | Ada | `loans.js`, `config.js` |
| Booking Ruang Senja, Studio Kata, Meja Komunal + cegah bentrok + batal | Ada | `rooms.js` |
| Kartu digital, QR SVG, salin nomor anggota | Ada | `card-scan.js` |
| Asisten Pustakawan AI lokal | Ada | `ai.js` |
| Panel admin: inventaris, pengadaan, anggota | Ada | `admin.js` (tab Buku, Anggota, Peminjaman, Booking, Statistik, Komunitas) |
| Pelaporan analitik / rekapitulasi (ekspor) | **Belum** | Baru tab Statistik, belum ada laporan yang bisa diekspor |
| Profil + riwayat peminjaman (jadwal 16-22 Nov) | Sebagian | Profil dasar ada; riwayat ada di halaman Peminjaman, belum halaman/dasbor tersendiri |
| Responsif mobile (jadwal 23-29 Nov) | Sebagian | Ada breakpoint 920/680/850/560 px; perlu diuji di perangkat |
| Mockup Figma (jadwal 9-15 Nov) | **Belum ada di repo** | Tambahkan link/screenshot ke `docs/mockup/` |

## B. Perbedaan yang perlu diputuskan tim
1. **Tech stack:** proposal menyebut "framework UI" dan RESTful API; prototipe memakai JavaScript murni tanpa framework. Cukup tulis di laporan "JavaScript modular (ES modules), tanpa framework" atau pasang framework CSS. Jangan biarkan proposal dan kode berbeda tanpa dijelaskan.
2. **Penyimpanan:** proposal mensyaratkan database RDBMS dan RBAC; prototipe masih `localStorage`. Ini pekerjaan integrasi (lihat `INTEGRASI_PHP.md`).
3. **Keamanan:** password demo ada di `js/config.js`; enkripsi kredensial dan HTTPS harus di sisi PHP/hosting.
4. **Peran Pustakawan demo:** ditambahkan di frontend setelah Margaretha menentukan role di database (`anggota`, `pustakawan`, `admin`).

## C. Koreksi kecil di dokumen proposal
- Nomor bagian loncat: bagian **11** (Anggaran) ada sebelum **9** dan **10**; urutkan jadi 9 (Anggaran), 10 (Rapat), 11 (Jobdesk).
- Hari salah menurut kalender 2026: 15 Nov, 22 Nov, dan 29 Nov jatuh pada **Minggu** (bukan Sabtu); 5 Des jatuh pada **Sabtu** (bukan Jumat). Sabtu yang benar: 14 Nov, 21 Nov, 28 Nov, 5 Des. Sesuaikan agenda rapat atau tanggalnya.
- Salah ketik: "pemcabangan" → "percabangan"; "pencarian dan pencarian koleksi" → "pencarian koleksi".
- Total anggaran sudah benar: Rp150.000 + 300.000 + 200.000 + 750.000 + 100.000 = Rp1.500.000.
