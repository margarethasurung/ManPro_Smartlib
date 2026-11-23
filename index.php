<?php
require_once __DIR__ . '/includes/auth.php';
$user = pengguna_saat_ini();
if ($user) {
    arahkan_sesuai_role($user['role']);
}
header('Location: ' . BASE_URL . '/login.php');
exit;
