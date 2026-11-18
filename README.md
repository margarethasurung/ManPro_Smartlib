# Database SmartLib

MySQL 8 / MariaDB 10.4+ (cocok dengan XAMPP). 21 tabel, 28 relasi, 3 view.

## Cara memasang

```bash
mysql -u root -p < database/schema.sql          # buat database "smartlib" + semua tabel (menghapus data lama!)
mysql -u root -p smartlib < database/seed.sql   # akun staf, 52 buku, ruang, acara, aturan bisnis
mysql -u root -p smartlib < database/seed_demo.sql   # OPSIONAL: skenario uji (terlambat, blokir, antrean)
```

Di XAMPP bisa juga lewat phpMyAdmin: tab **Import** → pilih file sesuai urutan di atas.

## Akun demo (hanya untuk pengembangan)

| Email | Password | Role |
|---|---|---|
| pustakawan@smartlib.id | Pustaka12345 | pustakawan |
| manajemen@smartlib.id | Manajemen12345 | manajemen |
| nadia@smartlib.id | Nadia12345 | anggota |
| budi@smartlib.id *(demo)* | Budi12345 | anggota, **pinjaman terlambat 5 hari** |
| citra@smartlib.id *(demo)* | Citra12345 | anggota, **punya denda belum lunas → harus diblokir** |
| dimas@smartlib.id *(demo)* | Dimas12345 | anggota, **sudah 4 pinjaman aktif (batas maksimal)** |

Password disimpan sebagai hash bcrypt (`$2y$`). Di PHP cukup:

```php
password_verify($passwordDariForm, $row['password_hash']);   // login
password_hash($passwordBaru, PASSWORD_DEFAULT);              // register
```

## Role (untuk pengecekan role / RBAC)

| Role | Boleh |
|---|---|
| `anggota` | katalog, pinjam/perpanjang, reservasi, bayar denda, booking ruang, acara, usulan, jurnal |
| `pustakawan` | semua fitur anggota + kelola buku, proses pinjam/kembali, tandai denda lunas, kelola booking/acara/pengadaan |
| `manajemen` | lihat laporan dan statistik, kelola akun staf |

## Query siap pakai untuk PHP

```sql
-- Apakah anggota ini diblokir meminjam? (ada baris = diblokir)
SELECT total_denda FROM v_blokir_pinjam WHERE pengguna_id = ?;

-- Pinjaman aktif + hari terlambat + denda berjalan
SELECT * FROM v_pinjaman_aktif WHERE pengguna_id = ?;

-- Katalog dengan rating rata-rata
SELECT * FROM v_katalog WHERE judul LIKE ? OR penulis LIKE ?;

-- Batas pinjam dan denda per hari dibaca dari tabel, bukan ditulis di kode
SELECT nilai FROM pengaturan WHERE kunci = 'maks_pinjam';
```

Saat **meminjam**: kurangi `buku.tersedia` dan tambah baris `peminjaman` dalam **satu transaksi** (`BEGIN … COMMIT`), pakai `SELECT … FOR UPDATE` pada baris buku supaya stok tidak jadi minus. Database menolak `tersedia > total_eksemplar`.

## Aturan yang dijaga langsung oleh database

Email dan ID anggota unik · `tersedia ≤ total_eksemplar` · perpanjang maksimal 2× · jatuh tempo ≥ tanggal pinjam · satu ulasan per anggota per buku, rating 1–5 · satu denda per pinjaman · satu pendaftaran per anggota per acara · jam selesai booking > jam mulai · role hanya `anggota/pustakawan/manajemen`.

Aturan yang **harus dicek di PHP** (tidak bisa di SQL): booking ruang bentrok, batas 4 pinjaman aktif, blokir saat ada denda, booking maksimal H+14 dan 2 aktif, pembatalan minimal 1 jam sebelum.

## Perbedaan dengan frontend lama (localStorage) — mohon dicocokkan

1. **Role**: frontend memakai `admin` / `member`. Database memakai `pustakawan` / `manajemen` / `anggota`. Akun `admin@smartlib.id` lama digantikan `pustakawan@smartlib.id`.
2. **Status berspasi → underscore**: `"siap diambil"` → `siap_diambil`, `"belum dibayar"` → `belum_dibayar`. Status `dipinjam`/`active` digabung jadi `dipinjam`.
3. **Nama field**: `title/author/copies/available` → `judul/penulis/total_eksemplar/tersedia`, dst. Lihat `ERD.png`.
4. **Stok awal**: di frontend beberapa buku sudah "tersedia < jumlah" tanpa ada data pinjaman. Di database stok awal = total eksemplar (konsisten dengan tabel `peminjaman` yang kosong). `seed_demo.sql` menghitung ulang stok dari pinjaman yang ada.
5. **Typo karakter** di `js/catalog-data.js`: `Saint-ExupÃ©ry` dan `BrontÃ«` rusak (encoding). Di seed sudah diperbaiki menjadi *Exupéry* dan *Brontë*; file JS sebaiknya ikut dibetulkan.
6. **Kategori**: data buku memakai 19 kategori, sedangkan `CONFIG.CATEGORIES` hanya 6. Tabel `kategori` mengikuti data buku.
