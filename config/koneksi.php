<?php
// Koneksi database (PDO). Sesuaikan dengan XAMPP/MAMP di komputer masing-masing.
// XAMPP: user root, password kosong. MAMP: user root, password root, port 8889.
const DB_HOST = '127.0.0.1';
const DB_PORT = '3306';
const DB_NAME = 'smartlib';
const DB_USER = 'root';
const DB_PASS = '';

// Nama folder proyek di htdocs (tanpa slash di akhir).
const BASE_URL = '/smartlib';

function db(): PDO
{
    static $pdo = null;
    if ($pdo === null) {
        $dsn = 'mysql:host=' . DB_HOST . ';port=' . DB_PORT . ';dbname=' . DB_NAME . ';charset=utf8mb4';
        $pdo = new PDO($dsn, DB_USER, DB_PASS, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ]);
    }
    return $pdo;
}
