# SmartLib — paket frontend + backend integrasi awal

Paket ini menggabungkan UI frontend awal, database RIS, dan API PHP awal yang diselaraskan dengan skema database.

## Struktur

- `frontend/` — UI SPA asli (dipertahankan).
- `backend/` — koneksi PDO dan endpoint API auth/katalog.
- `database/` — `schema.sql`, `seed.sql`, `seed_demo.sql` dari tim RIS.
- `docs/` — catatan kesesuaian dan integrasi.

## Penting sebelum menjalankan SQL

`database/schema.sql` berisi `DROP DATABASE IF EXISTS smartlib`. Perintah ini akan menghapus database `smartlib` yang sudah ada. Backup data dahulu, atau hapus baris DROP hanya jika tim database menyetujui strategi migrasi. Impor `schema.sql`, lalu `seed.sql`; `seed_demo.sql` opsional untuk skenario pengujian.

## Menjalankan di XAMPP

1. Ekstrak folder `smartlib_update` ke `C:\xampp\htdocs\smartlib-update`.
2. Jalankan Apache dan MySQL.
3. Import SQL sesuai urutan di atas melalui phpMyAdmin.
4. Atur environment DB PHP sesuai `backend/.env.example` (file contoh tidak otomatis dibaca PHP).
5. Tes `http://localhost/smartlib-update/backend/api/health.php`.
6. UI: `http://localhost/smartlib-update/frontend/`.

Untuk tes login/register API, ambil CSRF token dari `GET /backend/api/csrf.php`, lalu kirim token pada header `X-CSRF-Token` untuk request POST.

## Status yang jujur

- Sudah diselaraskan: nama tabel akun `pengguna`, kolom `id_anggota`, `password_hash`, `role`, `status`; role DB `anggota/pustakawan/manajemen`; katalog membaca `v_katalog`.
- Sudah tersedia: API auth (login/register/me/logout), CSRF, health check, katalog.
- Belum selesai: seluruh SPA belum memakai API. Peminjaman, pengembalian, denda, reservasi, booking ruang, acara, komunitas, dan admin masih memerlukan endpoint dan integrasi frontend bersama tim RIS/RBAC.
- Registrasi API selalu memberi role `anggota`; role staf harus ditetapkan oleh admin/manajemen melalui prosedur resmi.

## Branch Git

Paket ini ditujukan sebagai bahan branch `feature/frontend-awal` dan bahan koordinasi integrasi ke `develop`. Jangan menimpa pekerjaan branch `feature/database-ris` atau `feature/auth-rbac`; sepakati file backend/API bersama pemilik branch sebelum merge.
