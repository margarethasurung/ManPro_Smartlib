-- Akun awal Pustakawan dan Manajemen (dibuat tim, bukan lewat registrasi).
-- Password hanya untuk demo/pengembangan. GANTI sebelum website dipublikasikan.
USE smartlib;

INSERT INTO users (nama, email, password_hash, role) VALUES
('Pustakawan SmartLib', 'pustakawan@smartlib.id', '$2y$10$Oz7FEZWLgoZFgcK8ah4pqOfyjGh9t1mjgIXzefJjK6y90qN3WZksC', 'pustakawan'),
('Manajemen SmartLib',  'manajemen@smartlib.id',  '$2y$10$8Okv2ViOVCEn2Cpmo9NuNeRrbQKzZHOA1aHbwFB9fq.etgUeQwQm.', 'manajemen')
ON DUPLICATE KEY UPDATE nama = VALUES(nama);
