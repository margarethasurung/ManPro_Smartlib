<?php
require_once __DIR__ . '/../includes/auth.php';
$user = wajib_role('anggota');
?>
<!doctype html>
<html lang="id">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Beranda Anggota - SmartLib</title>
</head>
<body>
  <h1>Beranda Anggota</h1>
  <p>Halo, <?= e($user['nama']) ?> (role: <?= e($user['role']) ?>).</p>
  <p><em>Halaman ini placeholder. Fitur anggota akan ditambahkan di PR berikutnya.</em></p>
  <p><a href="<?= BASE_URL ?>/logout.php">Keluar</a></p>
</body>
</html>
