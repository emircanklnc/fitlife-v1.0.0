# 🚀 Hostinger Deployment Guide

## ✅ Yapılan Güncellemeler

### 1. Veritabanı Konfigürasyonu
- ✅ `backend/config/config.php` dosyası Hostinger bilgileriyle güncellendi
- ✅ Veritabanı host: `localhost`
- ✅ Veritabanı adı: `u499931761_fitlife`
- ✅ Veritabanı kullanıcı: `u499931761_emircan`
- ✅ Hata raporlama production moduna alındı

### 2. Apache Konfigürasyonu
- ✅ `.htaccess` dosyası Hostinger için optimize edildi
- ✅ CORS ayarları güncellendi
- ✅ Security headers eklendi

### 3. Flutter Uygulaması
- ✅ API base URL güncellendi: `https://proje.cloud/api`
- ✅ AndroidManifest.xml'e internet izni eklendi

---

## 📤 Sunucuya Yükleme Adımları

### 1. Dosyaları Yükleme

Hostinger File Manager veya FTP ile:

1. **Backend dosyalarını yükleyin:**
   ```
   public_html/
   └── api/
       ├── config/
       │   └── config.php (güncellenmiş)
       ├── admin/
       │   ├── login.php
       │   ├── login.html
       │   └── dashboard.php
       ├── api/
       │   ├── login.php
       │   ├── register.php
       │   ├── profile.php
       │   ├── exercises.php
       │   ├── food_logs.php
       │   ├── daily_statistics.php
       │   └── ...
       └── .htaccess (güncellenmiş)
   ```

2. **Dosya izinlerini kontrol edin:**
   - Tüm dosyalar: `644` (okuma/yazma)
   - Klasörler: `755` (okuma/yazma/çalıştırma)

### 2. Veritabanı Kontrolü

1. **phpMyAdmin'e girin:**
   - Hostinger panelinden phpMyAdmin'e erişin
   - Veritabanı: `u499931761_fitlife`

2. **Tablo yapısını kontrol edin:**
   - `users` tablosu var mı?
   - `admins` tablosu var mı?
   - `exercises`, `food_logs`, `daily_statistics` tabloları var mı?

3. **Eğer tablolar yoksa:**
   - `veritabani.sql` dosyasını phpMyAdmin'de çalıştırın
   - Veya SQL import ile yükleyin

4. **Admin kullanıcısı oluşturun:**
   ```sql
   INSERT INTO admins (username, password, email) VALUES 
   ('admin', '$2y$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'admin@proje.cloud');
   ```
   Şifre: `admin123456` (hash'lenmiş)

### 3. Test Etme

#### API Test (Tarayıcı veya Postman)

1. **Login Endpoint Test:**
   ```
   POST https://proje.cloud/api/login.php
   Content-Type: application/json
   
   {
     "email": "test@test.com",
     "password": "test123"
   }
   ```

2. **Register Endpoint Test:**
   ```
   POST https://proje.cloud/api/register.php
   Content-Type: application/json
   
   {
     "email": "yeni@test.com",
     "password": "test123",
     "name": "Test User"
   }
   ```

#### Flutter Uygulaması Test

1. **Uygulamayı çalıştırın:**
   ```bash
   flutter run
   ```

2. **Login ekranından test edin:**
   - Kayıt ol
   - Giriş yap
   - Dashboard'u kontrol et

---

## ⚙️ Konfigürasyon Detayları

### Veritabanı Bilgileri
```php
DB_HOST: localhost
DB_NAME: u499931761_fitlife
DB_USER: u499931761_emircan
DB_PASS: Emircan987.?
```

### API Base URL
```
Production: https://proje.cloud/api
```

### CORS Ayarları
- Tüm origin'lere izin verilir (`*`)
- GET, POST, PUT, DELETE, OPTIONS metodları desteklenir
- Authorization header'ı desteklenir

---

## 🔒 Güvenlik Notları

1. **JWT Secret:**
   - Production'da `JWT_SECRET` değiştirilmeli
   - Güçlü bir random string kullanın

2. **Error Reporting:**
   - Production'da `display_errors = 0` (zaten ayarlandı)
   - Hatalar sadece loglara yazılır

3. **HTTPS:**
   - Hostinger SSL sertifikası otomatik sağlanır
   - API URL'leri HTTPS kullanır

---

## 🐛 Sorun Giderme

### API Bağlantı Hatası

1. **Veritabanı bağlantısını kontrol edin:**
   - phpMyAdmin'den veritabanına bağlanabiliyor musunuz?
   - Kullanıcı adı ve şifre doğru mu?

2. **Dosya yollarını kontrol edin:**
   - `config.php` dosyası doğru yerde mi? (`public_html/api/config/`)
   - `.htaccess` dosyası var mı?

3. **CORS hatası alıyorsanız:**
   - `.htaccess` dosyasının yüklü olduğundan emin olun
   - Apache mod_headers modülünün aktif olduğunu kontrol edin

### 500 Internal Server Error

1. **PHP hatalarını kontrol edin:**
   - Hostinger error log'larını kontrol edin
   - `config.php` dosyasındaki veritabanı bilgilerini doğrulayın

2. **Dosya izinlerini kontrol edin:**
   - Tüm dosyalar okunabilir olmalı
   - Klasörler çalıştırılabilir olmalı

### Token Hatası

1. **Token formatını kontrol edin:**
   - Header: `Authorization: Bearer <token>`
   - Token boşluk içermemeli

2. **Token süresini kontrol edin:**
   - Token'lar 7 gün geçerlidir
   - Süre dolduysa yeniden giriş yapın

---

## 📝 Önemli Notlar

1. **Hostinger Dosya Yapısı:**
   - Backend dosyaları `public_html/api/` içinde
   - Admin panel: `public_html/api/admin/`
   - API endpoints: `public_html/api/api/`

2. **SSL Sertifikası:**
   - Hostinger otomatik SSL sağlar
   - HTTPS zorunlu değil ama önerilir

3. **Backup:**
   - Düzenli olarak veritabanı yedeği alın
   - Dosyaları yedekleyin

---

## ✅ Deployment Checklist

- [ ] Backend dosyaları `public_html/api/` klasörüne yüklendi
- [ ] `config.php` dosyası Hostinger bilgileriyle güncellendi
- [ ] `.htaccess` dosyası yüklendi
- [ ] Veritabanı tabloları oluşturuldu
- [ ] Admin kullanıcısı oluşturuldu
- [ ] API endpoint'leri test edildi
- [ ] Flutter uygulamasındaki API URL güncellendi
- [ ] Uygulama test edildi

---

## 🎉 Başarılı Deployment!

Artık uygulamanız Hostinger sunucusunda çalışıyor. 

**API Base URL:** `https://proje.cloud/api`

**Admin Panel:** `https://proje.cloud/api/admin/login.html`

Herhangi bir sorun yaşarsanız, yukarıdaki sorun giderme bölümüne bakın.

