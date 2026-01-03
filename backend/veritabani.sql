-- FitLife Veritabanı SQL Script
-- phpMyAdmin'de çalıştırın

-- Veritabanı oluştur
CREATE DATABASE IF NOT EXISTS fitlife_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE fitlife_db;

-- Kullanıcılar Tablosu
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL COMMENT 'Hashed password (password_hash)',
    name VARCHAR(100) NOT NULL,
    age INT NULL,
    height DECIMAL(5,2) NULL COMMENT 'Boy (cm)',
    weight DECIMAL(5,2) NULL COMMENT 'Kilo (kg)',
    gender ENUM('Male', 'Female') NULL,
    daily_calorie_goal INT DEFAULT 2000 COMMENT 'Günlük kalori hedefi',
    token VARCHAR(255) UNIQUE NULL COMMENT 'JWT veya random token',
    token_expires_at DATETIME NULL COMMENT 'Token son kullanma tarihi',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_token (token)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Kilo Geçmişi Tablosu
CREATE TABLE weight_history (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    weight DECIMAL(5,2) NOT NULL COMMENT 'Kilo (kg)',
    date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_date (user_id, date),
    INDEX idx_user_date (user_id, date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Günlük İstatistikler Tablosu
CREATE TABLE daily_statistics (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    date DATE NOT NULL,
    calories_in INT DEFAULT 0 COMMENT 'Alınan kalori',
    calories_out INT DEFAULT 0 COMMENT 'Yakılan kalori',
    water_intake INT DEFAULT 0 COMMENT 'Su tüketimi (bardak)',
    exercise_minutes INT DEFAULT 0 COMMENT 'Egzersiz süresi (dakika)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_date (user_id, date),
    INDEX idx_user_date (user_id, date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Egzersizler Tablosu
CREATE TABLE exercises (
    id VARCHAR(255) PRIMARY KEY COMMENT 'UUID',
    user_id INT NOT NULL,
    date DATE NOT NULL,
    type VARCHAR(50) NOT NULL COMMENT 'cardio veya weights',
    name VARCHAR(255) NOT NULL COMMENT 'Egzersiz adı',
    duration INT NOT NULL COMMENT 'Süre (dakika)',
    calories_burned INT NOT NULL COMMENT 'Yakılan kalori',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_date (user_id, date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Yemek Kayıtları Tablosu
CREATE TABLE food_logs (
    id VARCHAR(255) PRIMARY KEY COMMENT 'UUID',
    user_id INT NOT NULL,
    date DATE NOT NULL,
    food_name VARCHAR(255) NOT NULL COMMENT 'Yemek adı',
    calories INT NOT NULL COMMENT 'Kalori',
    protein DECIMAL(5,2) DEFAULT 0 COMMENT 'Protein (gram)',
    carbs DECIMAL(5,2) DEFAULT 0 COMMENT 'Karbonhidrat (gram)',
    fat DECIMAL(5,2) DEFAULT 0 COMMENT 'Yağ (gram)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_date (user_id, date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Admin Tablosu (Web paneli için)
CREATE TABLE admins (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL COMMENT 'Hashed password',
    email VARCHAR(255) UNIQUE NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_username (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Varsayılan Admin Kullanıcısı
-- Username: admin, Password: admin123
-- Şifre: password_hash('admin123', PASSWORD_BCRYPT) ile hash'lenmiş
INSERT INTO admins (username, password, email) VALUES 
('admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin@fitlife.com');

-- Test Kullanıcısı (isteğe bağlı)
-- Email: test@test.com, Password: test123
INSERT INTO users (email, password, name, age, height, weight, gender, daily_calorie_goal) VALUES 
('test@test.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Test User', 25, 175.5, 70.5, 'Male', 2000);

