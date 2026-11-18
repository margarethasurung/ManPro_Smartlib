-- =====================================================================
-- SmartLib - Skema Database (MySQL 8 / MariaDB 10.4+, cocok untuk XAMPP)
-- Dibuat oleh : Rosvirgini (Database & QA)
-- Versi       : 1.0 - 18 Nov 2026
-- Cara pakai  : mysql -u root -p < database/schema.sql
--               lalu: mysql -u root -p smartlib < database/seed.sql
-- Catatan     : Skrip ini DROP + CREATE ulang database "smartlib".
--               Jangan dijalankan di database yang sudah berisi data asli.
-- =====================================================================

DROP DATABASE IF EXISTS smartlib;
CREATE DATABASE smartlib
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE smartlib;

SET NAMES utf8mb4;

-- ---------------------------------------------------------------------
-- 1. PENGATURAN (aturan bisnis, mengganti CONFIG di js/config.js)
--    Dibaca PHP supaya angka denda/lama pinjam tidak ditulis di kode.
-- ---------------------------------------------------------------------
CREATE TABLE pengaturan (
  kunci      VARCHAR(50)  NOT NULL,
  nilai      VARCHAR(100) NOT NULL,
  keterangan VARCHAR(200) NULL,
  PRIMARY KEY (kunci)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 2. PENGGUNA (anggota, pustakawan, manajemen)
--    Role dicek di PHP setelah login (RBAC):
--      anggota    : katalog, pinjam, reservasi, booking ruang, acara, dst.
--      pustakawan : kelola buku, proses pinjam/kembali, denda, booking
--      manajemen  : lihat laporan & statistik, kelola akun pustakawan
-- ---------------------------------------------------------------------
CREATE TABLE pengguna (
  id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_anggota    VARCHAR(20)  NOT NULL COMMENT 'Contoh: SL-2026-0001; staf: ST-xxxx',
  nama          VARCHAR(100) NOT NULL,
  email         VARCHAR(150) NOT NULL,
  password_hash VARCHAR(255) NOT NULL COMMENT 'Hasil password_hash() PHP (bcrypt), BUKAN password asli',
  role          ENUM('anggota','pustakawan','manajemen') NOT NULL DEFAULT 'anggota',
  status        ENUM('aktif','nonaktif') NOT NULL DEFAULT 'aktif',
  dibuat_pada   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_pengguna_email (email),
  UNIQUE KEY uq_pengguna_id_anggota (id_anggota),
  KEY idx_pengguna_role (role)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 3. KATEGORI & BUKU
-- ---------------------------------------------------------------------
CREATE TABLE kategori (
  id   INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nama VARCHAR(60)  NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_kategori_nama (nama)
) ENGINE=InnoDB;

CREATE TABLE buku (
  id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  kode_buku      VARCHAR(10)  NOT NULL COMMENT 'Kode katalog, sama dengan id di frontend (B101, B102, ...)',
  judul          VARCHAR(200) NOT NULL,
  penulis        VARCHAR(150) NOT NULL,
  kategori_id    INT UNSIGNED NOT NULL,
  tahun_terbit   SMALLINT     NULL,
  penerbit       VARCHAR(120) NULL,
  isbn           VARCHAR(20)  NULL,
  jumlah_halaman SMALLINT UNSIGNED NULL,
  deskripsi      TEXT         NULL,
  cover_id       INT UNSIGNED NULL COMMENT 'ID cover Open Library',
  cover_url      VARCHAR(255) NULL,
  sumber_url     VARCHAR(255) NULL,
  tingkat_baca   ENUM('ringan','sedang','berat') NOT NULL DEFAULT 'sedang',
  lantai         TINYINT UNSIGNED NOT NULL DEFAULT 2,
  rak            VARCHAR(10)  NOT NULL DEFAULT 'B3',
  baris          TINYINT UNSIGNED NOT NULL DEFAULT 2,
  total_eksemplar INT UNSIGNED NOT NULL DEFAULT 2,
  tersedia       INT UNSIGNED NOT NULL DEFAULT 2 COMMENT 'Stok yang bisa dipinjam sekarang',
  dibuat_pada    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_buku_kode (kode_buku),
  KEY idx_buku_judul (judul),
  KEY idx_buku_penulis (penulis),
  KEY idx_buku_isbn (isbn),
  CONSTRAINT fk_buku_kategori FOREIGN KEY (kategori_id) REFERENCES kategori (id),
  CONSTRAINT ck_buku_stok CHECK (tersedia <= total_eksemplar)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 4. SIRKULASI: PEMINJAMAN, RESERVASI, DENDA
-- ---------------------------------------------------------------------
CREATE TABLE peminjaman (
  id               INT UNSIGNED NOT NULL AUTO_INCREMENT,
  pengguna_id      INT UNSIGNED NOT NULL COMMENT 'Peminjam (anggota)',
  buku_id          INT UNSIGNED NOT NULL,
  diproses_oleh    INT UNSIGNED NULL COMMENT 'Pustakawan yang memproses; NULL = pinjam mandiri',
  tanggal_pinjam   DATE NOT NULL,
  jatuh_tempo      DATE NOT NULL,
  tanggal_kembali  DATE NULL,
  jumlah_perpanjang TINYINT UNSIGNED NOT NULL DEFAULT 0,
  status           ENUM('dipinjam','selesai') NOT NULL DEFAULT 'dipinjam',
  PRIMARY KEY (id),
  KEY idx_pinjam_pengguna_status (pengguna_id, status),
  KEY idx_pinjam_buku_status (buku_id, status),
  KEY idx_pinjam_jatuh_tempo (jatuh_tempo),
  CONSTRAINT fk_pinjam_pengguna FOREIGN KEY (pengguna_id)   REFERENCES pengguna (id),
  CONSTRAINT fk_pinjam_buku     FOREIGN KEY (buku_id)       REFERENCES buku (id),
  CONSTRAINT fk_pinjam_petugas  FOREIGN KEY (diproses_oleh) REFERENCES pengguna (id) ON DELETE SET NULL,
  CONSTRAINT ck_pinjam_tanggal  CHECK (jatuh_tempo >= tanggal_pinjam),
  CONSTRAINT ck_pinjam_kembali  CHECK (tanggal_kembali IS NULL OR tanggal_kembali >= tanggal_pinjam),
  CONSTRAINT ck_pinjam_perpanjang CHECK (jumlah_perpanjang <= 2)
) ENGINE=InnoDB;

CREATE TABLE reservasi (
  id           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  pengguna_id  INT UNSIGNED NOT NULL,
  buku_id      INT UNSIGNED NOT NULL,
  status       ENUM('antre','siap_diambil','diambil','kedaluwarsa','batal') NOT NULL DEFAULT 'antre',
  dibuat_pada  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Urutan antrean = urutan kolom ini',
  siap_pada    DATE NULL,
  kedaluwarsa_pada DATE NULL COMMENT 'Batas ambil, default 2 hari setelah siap',
  PRIMARY KEY (id),
  KEY idx_reservasi_buku_status (buku_id, status, dibuat_pada),
  KEY idx_reservasi_pengguna (pengguna_id, status),
  CONSTRAINT fk_reservasi_pengguna FOREIGN KEY (pengguna_id) REFERENCES pengguna (id),
  CONSTRAINT fk_reservasi_buku     FOREIGN KEY (buku_id)     REFERENCES buku (id)
) ENGINE=InnoDB;

CREATE TABLE denda (
  id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  peminjaman_id INT UNSIGNED NOT NULL,
  pengguna_id   INT UNSIGNED NOT NULL,
  jumlah        INT UNSIGNED NOT NULL COMMENT 'Rupiah',
  status        ENUM('belum_dibayar','lunas') NOT NULL DEFAULT 'belum_dibayar',
  metode        VARCHAR(40) NULL COMMENT 'QRIS simulasi / tunai di meja / pembayaran meja',
  dibuat_pada   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dibayar_pada  DATETIME NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_denda_peminjaman (peminjaman_id),
  KEY idx_denda_pengguna_status (pengguna_id, status),
  CONSTRAINT fk_denda_peminjaman FOREIGN KEY (peminjaman_id) REFERENCES peminjaman (id),
  CONSTRAINT fk_denda_pengguna   FOREIGN KEY (pengguna_id)   REFERENCES pengguna (id),
  CONSTRAINT ck_denda_jumlah CHECK (jumlah > 0)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 5. RUANG & BOOKING
-- ---------------------------------------------------------------------
CREATE TABLE ruang (
  id        INT UNSIGNED NOT NULL AUTO_INCREMENT,
  kode      VARCHAR(30)  NOT NULL COMMENT 'ruang-senja, studio-kata, meja-komunal',
  nama      VARCHAR(80)  NOT NULL,
  kapasitas TINYINT UNSIGNED NOT NULL,
  detail    VARCHAR(200) NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_ruang_kode (kode)
) ENGINE=InnoDB;

CREATE TABLE booking_ruang (
  id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  pengguna_id   INT UNSIGNED NOT NULL,
  ruang_id      INT UNSIGNED NOT NULL,
  tanggal       DATE NOT NULL,
  mulai         TIME NOT NULL,
  selesai       TIME NOT NULL,
  jumlah_orang  TINYINT UNSIGNED NOT NULL,
  keperluan     VARCHAR(200) NULL,
  kode_booking  VARCHAR(20)  NOT NULL COMMENT 'Contoh: SLR-1A2B3C4D',
  status        ENUM('aktif','selesai','dibatalkan','hangus') NOT NULL DEFAULT 'aktif',
  check_in_pada DATETIME NULL,
  dibuat_pada   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_booking_kode (kode_booking),
  KEY idx_booking_ruang_waktu (ruang_id, tanggal, status),
  KEY idx_booking_pengguna (pengguna_id, status),
  CONSTRAINT fk_booking_pengguna FOREIGN KEY (pengguna_id) REFERENCES pengguna (id),
  CONSTRAINT fk_booking_ruang    FOREIGN KEY (ruang_id)    REFERENCES ruang (id),
  CONSTRAINT ck_booking_jam CHECK (selesai > mulai)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 6. KOMUNITAS: ACARA, USULAN BUKU, PENGUMUMAN
-- ---------------------------------------------------------------------
CREATE TABLE acara (
  id        INT UNSIGNED NOT NULL AUTO_INCREMENT,
  judul     VARCHAR(150) NOT NULL,
  tipe      VARCHAR(30)  NOT NULL COMMENT 'bedah buku / workshop / klub baca',
  tanggal   DATE NOT NULL,
  jam       TIME NOT NULL,
  lokasi    VARCHAR(80)  NOT NULL,
  kuota     SMALLINT UNSIGNED NOT NULL,
  deskripsi TEXT NULL,
  PRIMARY KEY (id),
  KEY idx_acara_tanggal (tanggal)
) ENGINE=InnoDB;

CREATE TABLE pendaftaran_acara (
  id          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  acara_id    INT UNSIGNED NOT NULL,
  pengguna_id INT UNSIGNED NOT NULL,
  status      ENUM('terdaftar','tunggu','batal') NOT NULL DEFAULT 'terdaftar' COMMENT 'tunggu = daftar tunggu saat kuota penuh',
  dibuat_pada DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_pendaftaran (acara_id, pengguna_id),
  CONSTRAINT fk_daftar_acara    FOREIGN KEY (acara_id)    REFERENCES acara (id) ON DELETE CASCADE,
  CONSTRAINT fk_daftar_pengguna FOREIGN KEY (pengguna_id) REFERENCES pengguna (id)
) ENGINE=InnoDB;

CREATE TABLE usulan_buku (
  id           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  pengguna_id  INT UNSIGNED NOT NULL,
  judul        VARCHAR(160) NOT NULL,
  penulis      VARCHAR(120) NOT NULL,
  alasan       VARCHAR(500) NULL,
  status       ENUM('dipertimbangkan','disetujui','ditolak','dibeli') NOT NULL DEFAULT 'dipertimbangkan',
  alasan_admin VARCHAR(500) NULL,
  dibuat_pada  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_usulan_status (status),
  CONSTRAINT fk_usulan_pengguna FOREIGN KEY (pengguna_id) REFERENCES pengguna (id)
) ENGINE=InnoDB;

CREATE TABLE dukungan_usulan (
  usulan_id   INT UNSIGNED NOT NULL,
  pengguna_id INT UNSIGNED NOT NULL,
  dibuat_pada DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (usulan_id, pengguna_id),
  CONSTRAINT fk_dukung_usulan   FOREIGN KEY (usulan_id)   REFERENCES usulan_buku (id) ON DELETE CASCADE,
  CONSTRAINT fk_dukung_pengguna FOREIGN KEY (pengguna_id) REFERENCES pengguna (id)
) ENGINE=InnoDB;

CREATE TABLE pengumuman (
  id          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  judul       VARCHAR(150) NOT NULL,
  pesan       TEXT NOT NULL,
  dibuat_oleh INT UNSIGNED NULL,
  aktif       TINYINT(1) NOT NULL DEFAULT 1,
  dibuat_pada DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  CONSTRAINT fk_pengumuman_pengguna FOREIGN KEY (dibuat_oleh) REFERENCES pengguna (id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 7. PENGADAAN BUKU (dicatat pustakawan, dilihat manajemen)
-- ---------------------------------------------------------------------
CREATE TABLE pengadaan (
  id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  judul         VARCHAR(200) NOT NULL,
  penerbit      VARCHAR(120) NOT NULL,
  isbn          VARCHAR(20)  NULL,
  jumlah        SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  harga         INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Rupiah per eksemplar',
  status        ENUM('direncanakan','dibeli','dibatalkan') NOT NULL DEFAULT 'direncanakan',
  usulan_id     INT UNSIGNED NULL COMMENT 'Jika berasal dari usulan anggota',
  buku_id       INT UNSIGNED NULL COMMENT 'Terisi setelah buku diterima & masuk katalog',
  dicatat_oleh  INT UNSIGNED NULL,
  tanggal       DATE NOT NULL,
  diterima_pada DATE NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_pengadaan_usulan  FOREIGN KEY (usulan_id)    REFERENCES usulan_buku (id) ON DELETE SET NULL,
  CONSTRAINT fk_pengadaan_buku    FOREIGN KEY (buku_id)      REFERENCES buku (id)        ON DELETE SET NULL,
  CONSTRAINT fk_pengadaan_petugas FOREIGN KEY (dicatat_oleh) REFERENCES pengguna (id)    ON DELETE SET NULL
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 8. FITUR PEMBACA: ULASAN, FAVORIT, JURNAL, TARGET, AKTIVITAS, NOTIFIKASI
-- ---------------------------------------------------------------------
CREATE TABLE ulasan (
  id          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  pengguna_id INT UNSIGNED NOT NULL,
  buku_id     INT UNSIGNED NOT NULL,
  rating      TINYINT UNSIGNED NOT NULL,
  komentar    VARCHAR(1000) NULL,
  dibuat_pada DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_ulasan (pengguna_id, buku_id) COMMENT 'Satu ulasan per anggota per buku',
  CONSTRAINT fk_ulasan_pengguna FOREIGN KEY (pengguna_id) REFERENCES pengguna (id),
  CONSTRAINT fk_ulasan_buku     FOREIGN KEY (buku_id)     REFERENCES buku (id) ON DELETE CASCADE,
  CONSTRAINT ck_ulasan_rating CHECK (rating BETWEEN 1 AND 5)
) ENGINE=InnoDB;

CREATE TABLE favorit (
  pengguna_id INT UNSIGNED NOT NULL,
  buku_id     INT UNSIGNED NOT NULL,
  dibuat_pada DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (pengguna_id, buku_id),
  CONSTRAINT fk_favorit_pengguna FOREIGN KEY (pengguna_id) REFERENCES pengguna (id),
  CONSTRAINT fk_favorit_buku     FOREIGN KEY (buku_id)     REFERENCES buku (id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE jurnal_baca (
  id          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  pengguna_id INT UNSIGNED NOT NULL,
  buku_id     INT UNSIGNED NOT NULL,
  halaman     SMALLINT UNSIGNED NULL,
  kutipan     VARCHAR(1000) NULL,
  catatan     VARCHAR(3000) NOT NULL,
  tanggal     DATE NOT NULL,
  PRIMARY KEY (id),
  KEY idx_jurnal_pengguna (pengguna_id, tanggal),
  CONSTRAINT fk_jurnal_pengguna FOREIGN KEY (pengguna_id) REFERENCES pengguna (id),
  CONSTRAINT fk_jurnal_buku     FOREIGN KEY (buku_id)     REFERENCES buku (id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE target_baca (
  pengguna_id INT UNSIGNED NOT NULL,
  tahun       SMALLINT UNSIGNED NOT NULL,
  target_buku SMALLINT UNSIGNED NOT NULL DEFAULT 12,
  PRIMARY KEY (pengguna_id, tahun),
  CONSTRAINT fk_target_pengguna FOREIGN KEY (pengguna_id) REFERENCES pengguna (id),
  CONSTRAINT ck_target_buku CHECK (target_buku BETWEEN 1 AND 200)
) ENGINE=InnoDB;

CREATE TABLE aktivitas (
  id          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  pengguna_id INT UNSIGNED NOT NULL,
  tipe        ENUM('peminjaman','pengembalian','perpanjangan','pembayaran','membaca') NOT NULL,
  pesan       VARCHAR(255) NULL,
  tanggal     DATE NOT NULL COMMENT 'Dipakai untuk streak & heatmap paspor membaca',
  dibuat_pada DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_aktivitas_pengguna_tanggal (pengguna_id, tanggal),
  CONSTRAINT fk_aktivitas_pengguna FOREIGN KEY (pengguna_id) REFERENCES pengguna (id)
) ENGINE=InnoDB;

CREATE TABLE notifikasi (
  id          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  pengguna_id INT UNSIGNED NOT NULL,
  tipe        VARCHAR(30)  NOT NULL COMMENT 'lencana, jatuh_tempo, reservasi, usulan, ...',
  pesan       VARCHAR(255) NOT NULL,
  tautan      VARCHAR(120) NULL,
  dibaca      TINYINT(1) NOT NULL DEFAULT 0,
  dibuat_pada DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_notifikasi_pengguna (pengguna_id, dibaca),
  CONSTRAINT fk_notifikasi_pengguna FOREIGN KEY (pengguna_id) REFERENCES pengguna (id)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 9. VIEW BANTUAN UNTUK PHP (Margaretha)
-- ---------------------------------------------------------------------

-- Katalog + rating rata-rata + jumlah ulasan
CREATE VIEW v_katalog AS
SELECT b.id, b.kode_buku, b.judul, b.penulis, k.nama AS kategori, b.tahun_terbit,
       b.penerbit, b.isbn, b.jumlah_halaman, b.deskripsi, b.cover_id, b.cover_url,
       b.tingkat_baca, b.lantai, b.rak, b.baris, b.total_eksemplar, b.tersedia,
       ROUND(AVG(u.rating), 1) AS rating_rata2, COUNT(u.id) AS jumlah_ulasan
FROM buku b
JOIN kategori k ON k.id = b.kategori_id
LEFT JOIN ulasan u ON u.buku_id = b.id
GROUP BY b.id;

-- Pinjaman aktif + hari terlambat + denda berjalan (Rp/hari dari tabel pengaturan)
CREATE VIEW v_pinjaman_aktif AS
SELECT p.id AS peminjaman_id, p.pengguna_id, p.buku_id, b.judul, p.tanggal_pinjam, p.jatuh_tempo,
       p.jumlah_perpanjang,
       GREATEST(DATEDIFF(CURDATE(), p.jatuh_tempo), 0) AS hari_terlambat,
       GREATEST(DATEDIFF(CURDATE(), p.jatuh_tempo), 0)
         * (SELECT CAST(nilai AS UNSIGNED) FROM pengaturan WHERE kunci = 'denda_per_hari') AS denda_berjalan
FROM peminjaman p
JOIN buku b ON b.id = p.buku_id
WHERE p.status = 'dipinjam';

-- Anggota yang DIBLOKIR meminjam: masih punya denda belum lunas
-- Pakai di PHP:  SELECT 1 FROM v_blokir_pinjam WHERE pengguna_id = ?
CREATE VIEW v_blokir_pinjam AS
SELECT d.pengguna_id, COUNT(*) AS jumlah_denda, SUM(d.jumlah) AS total_denda
FROM denda d
WHERE d.status = 'belum_dibayar'
GROUP BY d.pengguna_id;
