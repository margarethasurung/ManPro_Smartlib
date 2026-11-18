<?php
require_once __DIR__ . '/includes/auth.php';

if ($u = pengguna_saat_ini()) {
    arahkan_sesuai_role($u['role']);
}

$errors = [];
$nama = '';
$email = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    csrf_cek();
    $nama = trim($_POST['nama'] ?? '');
    $email = strtolower(trim($_POST['email'] ?? ''));
    $password = $_POST['password'] ?? '';
    $konfirmasi = $_POST['konfirmasi'] ?? '';

    if ($nama === '' || mb_strlen($nama) > 100) {
        $errors[] = 'Nama wajib diisi (maksimal 100 karakter).';
    }
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        $errors[] = 'Format email tidak valid.';
    }
    if (strlen($password) < 8) {
        $errors[] = 'Password minimal 8 karakter.';
    }
    if ($password !== $konfirmasi) {
        $errors[] = 'Konfirmasi password tidak sama.';
    }

    if (!$errors) {
        $cek = db()->prepare('SELECT id FROM pengguna WHERE email = ?');
        $cek->execute([$email]);
        if ($cek->fetch()) {
            $errors[] = 'Email sudah terdaftar.';
        }
    }

    if (!$errors) {
        // Generate id_anggota otomatis: SL-2026-XXXX
        $last = db()->query("SELECT id_anggota FROM pengguna WHERE id_anggota LIKE 'SL-%' ORDER BY id DESC LIMIT 1")->fetchColumn();
        $next = $last ? ((int) substr($last, strrpos($last, '-') + 1)) + 1 : 1;
        $id_anggota = 'SL-' . date('Y') . '-' . str_pad($next, 4, '0', STR_PAD_LEFT);

        // Role SELALU 'anggota'. Tidak ada input role di form, jadi tidak bisa daftar sendiri jadi pustakawan/manajemen.
        $simpan = db()->prepare('INSERT INTO pengguna (id_anggota, nama, email, password_hash, role) VALUES (?, ?, ?, ?, ?)');
        $simpan->execute([$id_anggota, $nama, $email, password_hash($password, PASSWORD_DEFAULT), 'anggota']);
        header('Location: ' . BASE_URL . '/login.php?daftar=1');
        exit;
    }
}
?>
<!doctype html>
<html lang="id">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Daftar - SmartLib</title>
</head>
<body>
  <h1>Daftar anggota SmartLib</h1>
  <?php foreach ($errors as $err): ?><p role="alert" style="color:#b00020"><?= e($err) ?></p><?php endforeach; ?>
  <form method="post" action="">
    <input type="hidden" name="csrf" value="<?= e(csrf_token()) ?>">
    <p><label>Nama lengkap<br><input name="nama" required value="<?= e($nama) ?>"></label></p>
    <p><label>Email<br><input type="email" name="email" required value="<?= e($email) ?>"></label></p>
    <p><label>Password (minimal 8 karakter)<br><input type="password" name="password" required></label></p>
    <p><label>Ulangi password<br><input type="password" name="konfirmasi" required></label></p>
    <p><button type="submit">Daftar</button></p>
  </form>
  <p>Sudah punya akun? <a href="login.php">Masuk</a></p>
</body>
</html>
