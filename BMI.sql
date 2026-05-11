-- 1. Membuat Database
CREATE DATABASE IF NOT EXISTS db_bmi;
USE db_bmi;

-- 2. Membuat Tabel Riwayat BMI
CREATE TABLE IF NOT EXISTS riwayat_bmi (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    umur INT NOT NULL,
    berat FLOAT NOT NULL,    -- Disimpan dalam satuan kg
    tinggi FLOAT NOT NULL,   -- Disimpan dalam satuan cm
    bmi FLOAT NOT NULL,      -- Hasil perhitungan berat / (tinggi/100)^2
    kategori VARCHAR(50),    -- Menyimpan hasil klasifikasi (Normal, Obesitas, dll)
    tanggal DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 3. Membuat User Khusus (Opsional, agar sesuai dengan db_config di Python)
-- Lewati langkah ini jika user sudah ada
CREATE USER IF NOT EXISTS 'user_bmi'@'%' IDENTIFIED BY 'password_bmi';
GRANT ALL PRIVILEGES ON db_bmi.* TO 'user_bmi'@'%';
FLUSH PRIVILEGES;