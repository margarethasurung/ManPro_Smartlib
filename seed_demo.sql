-- =====================================================================
-- SmartLib - Data DEMO untuk pengujian (OPSIONAL)  |  Jalankan SETELAH seed.sql
--   mysql -u root -p smartlib < database/seed_demo.sql
-- Berisi skenario siap uji untuk test case & log bug:
--   Nadia  (SL-2026-0001): 2 pinjaman aktif normal; antre buku B104 (stok habis)
--   Budi   (SL-2026-0002): 1 pinjaman TERLAMBAT 5 hari (denda berjalan Rp5.000)
--   Citra  (SL-2026-0003): punya denda BELUM LUNAS -> harus DIBLOKIR meminjam
--   Dimas  (SL-2026-0004): bersih; sudah punya 4 pinjaman aktif -> batas maksimal
-- Password demo: Budi12345 / Citra12345 / Dimas12345
-- =====================================================================
USE smartlib;
SET NAMES utf8mb4;

INSERT INTO pengguna (id_anggota, nama, email, password_hash, role) VALUES
('SL-2026-0002','Budi Santoso','budi@smartlib.id','$2y$10$WRA7ItkMIVH52XRxo0vsEucO4GOLj4sEOMcrlDc3sT6Z7sOt9CFvu','anggota'),
('SL-2026-0003','Citra Dewi','citra@smartlib.id','$2y$10$l2p3Z/xyLt4qFgNXtSMM3uJbFXO2zt/N/.xCTOJ1t4Y1DFtOLAAWq','anggota'),
('SL-2026-0004','Dimas Pratama','dimas@smartlib.id','$2y$10$bxxUsM0UNq/xmbF5Cyp76eQMpyDVVZCoND4Qg5paXT3FxwPYUajM2','anggota');

-- Variabel bantu
SET @petugas = (SELECT id FROM pengguna WHERE email='pustakawan@smartlib.id');
SET @nadia   = (SELECT id FROM pengguna WHERE email='nadia@smartlib.id');
SET @budi    = (SELECT id FROM pengguna WHERE email='budi@smartlib.id');
SET @citra   = (SELECT id FROM pengguna WHERE email='citra@smartlib.id');
SET @dimas   = (SELECT id FROM pengguna WHERE email='dimas@smartlib.id');

-- Peminjaman
INSERT INTO peminjaman (pengguna_id, buku_id, diproses_oleh, tanggal_pinjam, jatuh_tempo, tanggal_kembali, jumlah_perpanjang, status) VALUES
-- Nadia: normal
(@nadia,(SELECT id FROM buku WHERE kode_buku='B101'),@petugas, CURDATE()-INTERVAL 2 DAY, CURDATE()+INTERVAL 5 DAY, NULL,0,'dipinjam'),
(@nadia,(SELECT id FROM buku WHERE kode_buku='B103'),NULL,     CURDATE()-INTERVAL 6 DAY, CURDATE()+INTERVAL 1 DAY, NULL,0,'dipinjam'),
-- Budi: terlambat 5 hari (+ riwayat selesai)
(@budi,(SELECT id FROM buku WHERE kode_buku='B104'),@petugas, CURDATE()-INTERVAL 12 DAY, CURDATE()-INTERVAL 5 DAY, NULL,0,'dipinjam'),
(@budi,(SELECT id FROM buku WHERE kode_buku='B102'),@petugas, CURDATE()-INTERVAL 20 DAY, CURDATE()-INTERVAL 13 DAY, CURDATE()-INTERVAL 14 DAY,0,'selesai'),
-- Citra: pinjaman sudah dikembalikan terlambat 3 hari -> denda belum lunas
(@citra,(SELECT id FROM buku WHERE kode_buku='B108'),@petugas, CURDATE()-INTERVAL 14 DAY, CURDATE()-INTERVAL 7 DAY, CURDATE()-INTERVAL 4 DAY,0,'selesai'),
-- Dimas: 4 pinjaman aktif (batas MAKS_PINJAM)
(@dimas,(SELECT id FROM buku WHERE kode_buku='B105'),@petugas, CURDATE()-INTERVAL 1 DAY, CURDATE()+INTERVAL 6 DAY, NULL,0,'dipinjam'),
(@dimas,(SELECT id FROM buku WHERE kode_buku='B106'),@petugas, CURDATE()-INTERVAL 1 DAY, CURDATE()+INTERVAL 6 DAY, NULL,0,'dipinjam'),
(@dimas,(SELECT id FROM buku WHERE kode_buku='B107'),@petugas, CURDATE()-INTERVAL 1 DAY, CURDATE()+INTERVAL 6 DAY, NULL,0,'dipinjam'),
(@dimas,(SELECT id FROM buku WHERE kode_buku='B104'),@petugas, CURDATE()-INTERVAL 1 DAY, CURDATE()+INTERVAL 6 DAY, NULL,0,'dipinjam');

-- Denda: Citra 3 hari x Rp1.000 belum lunas (blokir); Budi riwayat sudah lunas
INSERT INTO denda (peminjaman_id, pengguna_id, jumlah, status, metode, dibayar_pada) VALUES
((SELECT id FROM peminjaman WHERE pengguna_id=@citra AND status='selesai'), @citra, 3000, 'belum_dibayar', NULL, NULL);

-- Reservasi: B104 stok habis (Budi + Dimas pegang 2 eksemplar) -> Nadia antre
INSERT INTO reservasi (pengguna_id, buku_id, status, dibuat_pada) VALUES
(@nadia,(SELECT id FROM buku WHERE kode_buku='B104'),'antre', NOW());

-- Booking ruang
INSERT INTO booking_ruang (pengguna_id, ruang_id, tanggal, mulai, selesai, jumlah_orang, keperluan, kode_booking, status) VALUES
(@nadia,(SELECT id FROM ruang WHERE kode='ruang-senja'), CURDATE()+INTERVAL 2 DAY,'10:00','11:00',4,'Diskusi kelompok','SLR-DEMO0001','aktif');

-- Ulasan, favorit, pendaftaran acara, aktivitas
INSERT INTO ulasan (pengguna_id, buku_id, rating, komentar) VALUES
(@budi,(SELECT id FROM buku WHERE kode_buku='B102'),5,'Mudah dipahami dan relevan untuk sehari-hari.');
INSERT INTO favorit (pengguna_id, buku_id) VALUES (@nadia,(SELECT id FROM buku WHERE kode_buku='B101'));
INSERT INTO pendaftaran_acara (acara_id, pengguna_id, status) VALUES
((SELECT id FROM acara WHERE judul LIKE 'Bedah Buku%' LIMIT 1), @nadia, 'terdaftar');
INSERT INTO aktivitas (pengguna_id, tipe, pesan, tanggal) VALUES
(@nadia,'peminjaman','Meminjam "Laut Bercerita".', CURDATE()-INTERVAL 2 DAY),
(@nadia,'peminjaman','Meminjam "Atomic Habits".',  CURDATE()-INTERVAL 6 DAY);

-- Sinkronkan stok: tersedia = total - pinjaman aktif - reservasi siap diambil
UPDATE buku b SET b.tersedia = b.total_eksemplar
  - (SELECT COUNT(*) FROM peminjaman p WHERE p.buku_id=b.id AND p.status='dipinjam')
  - (SELECT COUNT(*) FROM reservasi r WHERE r.buku_id=b.id AND r.status='siap_diambil');
