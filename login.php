<?php
require_once __DIR__ . '/includes/auth.php';

if ($u = pengguna_saat_ini()) {
    arahkan_sesuai_role($u['role']);
}

$error = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    csrf_cek();
    $email = strtolower(trim($_POST['email'] ?? ''));
    $password = $_POST['password'] ?? '';

    $stmt = db()->prepare('SELECT id, nama, email, password_hash, role FROM pengguna WHERE email = ?');
    $stmt->execute([$email]);
    $user = $stmt->fetch();

    if ($user && password_verify($password, $user['password_hash'])) {
        session_regenerate_id(true);
        $_SESSION['user'] = [
            'id'    => (int) $user['id'],
            'nama'  => $user['nama'],
            'email' => $user['email'],
            'role'  => $user['role'],
        ];
        arahkan_sesuai_role($user['role']);
    }
    // Pesan sengaja sama untuk email salah maupun password salah.
    $error = 'Email atau password salah.';
}
?>
<!doctype html>
<html lang="id">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Masuk - SmartLib</title>
</head>
<body>
  <h1>Masuk ke SmartLib</h1>
  <?php if (isset($_GET['daftar'])): ?><p>Pendaftaran berhasil. Silakan masuk.</p><?php endif; ?>
  <?php if ($error): ?><p role="alert" style="color:#b00020"><?= e($error) ?></p><?php endif; ?>
  <form method="post" action="">
    <input type="hidden" name="csrf" value="<?= e(csrf_token()) ?>">
    <p><label>Email<br><input type="email" name="email" required value="<?= e($_POST['email'] ?? '') ?>"></label></p>
    <p><label>Password<br><input type="password" name="password" required></label></p>
    <p><button type="submit">Masuk</button></p>
  </form>
  <p>Belum punya akun? <a href="register.php">Daftar sebagai anggota</a></p>
</body>
</html>
