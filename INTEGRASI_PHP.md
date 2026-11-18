# Rencana integrasi frontend ke API PHP

Sesuai proposal: **Khim (Yohanes)** mengintegrasikan antarmuka dengan RESTful API buatan **Retha (Margaretha)**.
Jadwal proposal: fitur inti 16-22 Nov (demo Sabtu 21 Nov), admin dan integrasi 23-29 Nov.

## Prinsip
- Semua data lewat API; `localStorage` hanya untuk preferensi tampilan (tema).
- Aturan pinjam/denda/booking dihitung di PHP (bukan JavaScript). Frontend hanya menampilkan hasil dan pesan error.
- Hak akses (RBAC) dicek di PHP. Menyembunyikan menu di frontend hanya soal tampilan.
- Format respons usulan: `{ "ok": true, "data": ... }` atau `{ "ok": false, "pesan": "..." }`.

## Pemetaan data ke endpoint (usulan, sepakati dengan Retha)
| Data di `store` | Endpoint | Dipakai di | Target |
|---|---|---|---|
| `users`, `session` | `POST /login.php`, `POST /register.php`, `GET /logout.php`, `GET /api/me.php` | `auth.js` | 21 Nov |
| `books` | `GET /api/buku.php?q=&kategori=&urut=&page=` | `catalog.js` | 21 Nov |
| `loans` | `POST /api/pinjam.php`, `/kembali.php`, `/perpanjang.php` | `loans.js` | 21 Nov |
| `fines` | `GET /api/denda.php` | `loans.js`, dasbor | 21 Nov |
| `holds` | `POST /api/reservasi.php` | `loans.js` | 21 Nov |
| `roomBookings` | `GET/POST /api/ruang.php` | `rooms.js` | 29 Nov |
| `acquisitions`, `users` (admin) | `/api/admin/...` | `admin.js` | 29 Nov |

## Langkah Yohanes
1. Buat `js/api.js`: pembungkus `fetch` (kirim cookie sesi, tangani `ok:false` lewat `toast`).
2. Ganti `store.get()/update()` per modul, satu modul per commit: catalog, auth, loans, rooms, admin.
3. Dasbor anggota (`GET /api/dashboard.php`): pinjaman aktif, jatuh tempo, denda, reservasi, riwayat.
4. Hapus `DEMO_ACCOUNTS` dan `catalog-data.js` setelah database terisi `seed.sql` (Rosvirgini).
5. Uji responsif mobile dan perbaiki bug dari issue log Rosvirgini.
6. Pindahkan `frontend/` ke root/`public/` bila disepakati; sesuaikan path di `index.php` dan `service-worker.js`.
