# FitLife Backend API

PHP + MySQL backend API for FitLife mobile application.

## 📁 Klasör Yapısı

```
backend/
├── config/
│   └── config.php          # Veritabanı bağlantısı ve yardımcı fonksiyonlar
├── api/
│   ├── register.php        # Kullanıcı kaydı
│   ├── login.php           # Kullanıcı girişi
│   ├── profile.php         # Profil getir/güncelle
│   └── daily_statistics.php # Günlük istatistikler
├── .htaccess               # Apache configuration
└── README.md              # Bu dosya
```

## 🚀 Kurulum

### 1. XAMPP Kurulumu

1. XAMPP'i indirip kurun: https://www.apachefriends.org/
2. Apache ve MySQL servislerini başlatın

### 2. Backend Dosyalarını Kopyalayın

Backend klasörünü XAMPP'in `htdocs` klasörüne kopyalayın:

```
C:\xampp\htdocs\fitlife_backend\
```

### 3. Veritabanını Oluşturun

1. phpMyAdmin'e gidin: `http://localhost/phpmyadmin`
2. SQL sekmesine tıklayın
3. Veritabanı SQL script'ini çalıştırın (veritabanı.sql dosyası)

### 4. Veritabanı Ayarlarını Düzenleyin

`config/config.php` dosyasını açın ve veritabanı bilgilerinizi güncelleyin:

```php
define('DB_HOST', 'localhost');
define('DB_NAME', 'fitlife_db');
define('DB_USER', 'root');
define('DB_PASS', '');
```

## 📡 API Endpoints

### Authentication

#### POST /api/register.php
Kullanıcı kaydı

**Request:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "name": "Kullanıcı Adı",
  "age": 25,
  "height": 175.5,
  "weight": 70.5,
  "gender": "Male"
}
```

**Response:**
```json
{
  "success": true,
  "token": "abc123...",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "name": "Kullanıcı Adı"
  }
}
```

#### POST /api/login.php
Kullanıcı girişi

**Request:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "token": "abc123...",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "name": "Kullanıcı Adı"
  }
}
```

### Profile

#### GET /api/profile.php
Profil bilgilerini getir

**Headers:**
```
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "profile": {
    "id": 1,
    "email": "user@example.com",
    "name": "Kullanıcı Adı",
    "age": 25,
    "height": 175.5,
    "weight": 70.5,
    "gender": "Male",
    "daily_calorie_goal": 2000,
    "weight_history": [
      {
        "date": "2024-01-15",
        "weight": 70.5
      }
    ]
  }
}
```

#### PUT /api/profile.php
Profil güncelle

**Headers:**
```
Authorization: Bearer <token>
```

**Request:**
```json
{
  "name": "Yeni İsim",
  "age": 26,
  "height": 176.0,
  "weight": 71.0,
  "gender": "Male",
  "daily_calorie_goal": 2200
}
```

### Statistics

#### GET /api/daily_statistics.php
Son 7 günlük istatistikleri getir

**Headers:**
```
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "statistics": [
    {
      "date": "2024-01-15",
      "calories_in": 1500,
      "calories_out": 300,
      "water_intake": 6,
      "exercise_minutes": 45
    }
  ]
}
```

#### POST /api/daily_statistics.php
Günlük istatistik kaydet/güncelle

**Headers:**
```
Authorization: Bearer <token>
```

**Request:**
```json
{
  "date": "2024-01-15",
  "calories_in": 1500,
  "calories_out": 300,
  "water_intake": 6,
  "exercise_minutes": 45
}
```

## 🔐 Güvenlik

- Tüm API endpoint'leri (register/login hariç) token gerektirir
- Token'lar 30 gün geçerlidir
- Şifreler `password_hash()` ile hash'lenir
- SQL injection koruması için prepared statements kullanılır

## 🧪 Test

### Postman veya Thunder Client ile test edin:

1. **Register:**
```
POST http://localhost/fitlife_backend/api/register.php
Content-Type: application/json

{
  "email": "test@test.com",
  "password": "test123",
  "name": "Test User"
}
```

2. **Login:**
```
POST http://localhost/fitlife_backend/api/login.php
Content-Type: application/json

{
  "email": "test@test.com",
  "password": "test123"
}
```

3. **Get Profile:**
```
GET http://localhost/fitlife_backend/api/profile.php
Authorization: Bearer <token>
```

## ⚠️ Önemli Notlar

1. **Localhost URL:**
   - Android Emulator: `http://10.0.2.2/fitlife_backend/api`
   - Fiziksel Cihaz: `http://192.168.1.X/fitlife_backend/api` (bilgisayarınızın IP'si)
   - iOS Simulator: `http://localhost/fitlife_backend/api`

2. **CORS:** 
   - `.htaccess` dosyası CORS ayarlarını içerir
   - Apache `mod_headers` modülünün aktif olduğundan emin olun

3. **Production:**
   - `config.php` dosyasında `error_reporting` ve `display_errors` kapatılmalı
   - `JWT_SECRET` değiştirilmeli
   - HTTPS kullanılmalı

## 📝 Veritabanı

Veritabanı SQL script'i ayrı bir dosyada (`veritabanı.sql`) bulunmalıdır.

