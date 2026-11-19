<?php
require_once __DIR__ . '/../config/koneksi.php';

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

// Escape output supaya aman dari XSS.
function e(?string $teks): string
{
    return htmlspecialchars($teks ?? '', ENT_QUOTES, 'UTF-8');
}

function pengguna_saat_ini(): ?array
{
    return $_SESSION['user'] ?? null;
}

// Halaman utama tiap role: /anggota/, /pustakawan/, /manajemen/
function halaman_role(string $role): string
{
    return BASE_URL . '/' . $role . '/';
}

function arahkan_sesuai_role(string $role): void
{
    header('Location: ' . halaman_role($role));
    exit;
}

// Wajib login. Kalau belum, lempar ke halaman login.
function wajib_login(): array
{
    $user = pengguna_saat_ini();
    if (!$user) {
        header('Location: ' . BASE_URL . '/login.php');
        exit;
    }
    return $user;
}

// Wajib punya salah satu role. Dicek DI SERVER, jadi tidak bisa dilewati dari browser.
function wajib_role(string ...$role_diizinkan): array
{
    $user = wajib_login();
    if (!in_array($user['role'], $role_diizinkan, true)) {
        http_response_code(403);
        exit('403 - Kamu tidak punya akses ke halaman ini.');
    }
    return $user;
}

// Perlindungan CSRF sederhana untuk form POST.
function csrf_token(): string
{
    if (empty($_SESSION['csrf'])) {
        $_SESSION['csrf'] = bin2hex(random_bytes(32));
    }
    return $_SESSION['csrf'];
}

function csrf_cek(): void
{
    $kirim = $_POST['csrf'] ?? '';
    if (!hash_equals($_SESSION['csrf'] ?? '', $kirim)) {
        http_response_code(400);
        exit('Permintaan tidak valid. Muat ulang halaman lalu coba lagi.');
    }
}
