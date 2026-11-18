-- Tabel users (bagian awal untuk login dan RBAC).
-- Nanti digabung Rosvirgini ke schema.sql lengkap (sesuai ERD).
CREATE DATABASE IF NOT EXISTS smartlib CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE smartlib;

CREATE TABLE IF NOT EXISTS users (
  id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nama          VARCHAR(100) NOT NULL,
  email         VARCHAR(150) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role          ENUM('anggota','pustakawan','manajemen') NOT NULL DEFAULT 'anggota',
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
