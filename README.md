# SmartLib — Frontend Awal

Prototipe tampilan SmartLib (HTML/CSS/JavaScript, ES modules tanpa framework). Dibuat oleh Yohanes (Khim) sebagai UI/UX Designer & Frontend Developer. Kesesuaian dengan proposal: lihat `../docs/KESESUAIAN_PROPOSAL.md`.
**Status: data masih disimpan di browser (`localStorage`), belum terhubung ke PHP/MySQL.**
Penyambungan ke PHP dikerjakan pada tahap berikutnya (target Sabtu 21 Nov).

## Cara menjalankan
Modul JavaScript (`type="module"`) tidak jalan kalau file dibuka langsung (`file://`). Jalankan lewat server lokal:

```bash
cd frontend
php -S localhost:8000        # atau: python3 -m http.server 8000
```
Buka `http://localhost:8000/index.html` (versi statis) atau `http://localhost:8000/index.php` (versi PHP).

## Akun demo (hanya untuk prototipe)
| Role | Email | Password |
|---|---|---|
| Admin | admin@smartlib.id | Admin12345 |
| Anggota | nadia@smartlib.id | Nadia12345 |

Akun ini ada di `js/config.js`. **Hapus saat login sudah memakai PHP + database** (password tidak boleh ada di kode frontend).

## Struktur
| Path | Isi |
|---|---|
| `index.html` / `index.php` | Halaman utama (kerangka). `index.php` merakit dari `php/views/` |
| `app.js` | Router berbasis `#/rute` dan pemanggil modul |
| `styles.css` | Seluruh gaya tampilan |
| `js/auth.js` | Login, daftar, sesi |
| `js/catalog.js`, `catalog-data.js` | Katalog + data buku contoh |
| `js/loans.js` | Pinjam, kembali, perpanjang, denda, reservasi |
| `js/rooms.js` | Booking ruang |
| `js/admin.js` | Panel admin |
| `js/card-scan.js` | Kartu digital + scan |
| `js/reading.js`, `reader.js`, `community.js`, `ai.js` | Bacaan, ulasan/komunitas, rekomendasi lokal |
| `js/store.js` | **Penyimpanan data (localStorage)**, titik utama yang diganti ke PHP |
| `js/config.js` | Aturan (maks pinjam 4, 7 hari, denda Rp1.000/hari, dst) |
| `php/` | Partial PHP (head, header, footer, navigasi) |
| `service-worker.js`, `manifest.json` | PWA |

## Fitur yang sudah ada di tampilan
Beranda, katalog + pencarian, detail buku, peminjaman/perpanjang/kembali + denda, reservasi, booking ruang, kartu digital, acara, Pustakawan AI (lokal), favorit, ulasan, panel admin, login/daftar.

## Catatan
- Aturan pinjam/denda masih dihitung di JavaScript. Versi final harus dihitung di PHP agar tidak bisa dimanipulasi.
- Folder `netlify-site/` di zip adalah salinan identik dan **tidak di-upload** supaya tidak ada kode ganda.
