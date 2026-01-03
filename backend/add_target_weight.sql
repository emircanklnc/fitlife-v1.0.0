-- FitLife - Hedef Kilo (target_weight) Kolonu Ekleme
-- 
-- Bu SQL script'i users tablosuna target_weight kolonunu ekler.
-- Hedef kilo, kullanıcının ulaşmak istediği kilo hedefini saklar.
--
-- Kullanım:
-- 1. phpMyAdmin veya MySQL client ile veritabanınıza bağlanın
-- 2. Bu SQL kodunu çalıştırın
-- 3. Backend API otomatik olarak target_weight'i destekleyecektir

-- Users tablosuna target_weight kolonu ekle
ALTER TABLE users 
ADD COLUMN target_weight DECIMAL(5,2) NULL 
COMMENT 'Hedef kilo (kg)' 
AFTER daily_calorie_goal;

-- Kolonun başarıyla eklendiğini kontrol et
-- SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_COMMENT 
-- FROM INFORMATION_SCHEMA.COLUMNS 
-- WHERE TABLE_SCHEMA = DATABASE() 
-- AND TABLE_NAME = 'users' 
-- AND COLUMN_NAME = 'target_weight';

