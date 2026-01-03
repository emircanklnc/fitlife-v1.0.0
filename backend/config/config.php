<?php
/**
 * FitLife Backend - Configuration
 * 
 * Veritabanı bağlantısı ve yardımcı fonksiyonlar
 */

// Hata raporlama (production'da kapatılmalı)
// Hostinger Production: Hataları loglara yaz, ekranda gösterme
error_reporting(E_ALL);
ini_set('display_errors', 0); // Production'da kapalı
ini_set('log_errors', 1);

// CORS Headers
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json; charset=utf-8');

// OPTIONS request için hemen dön
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Veritabanı Ayarları - Hostinger
define('DB_HOST', 'localhost');
define('DB_NAME', 'u499931761_fitlife');
define('DB_USER', 'u499931761_emircan');
define('DB_PASS', 'Emircan987.?');
define('JWT_SECRET', 'fitlife-secret-key-2024');

/**
 * Veritabanı Bağlantısı
 * 
 * @return PDO
 */
function getDB() {
    try {
        $pdo = new PDO(
            "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8mb4",
            DB_USER,
            DB_PASS,
            [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES => false,
            ]
        );
        return $pdo;
    } catch(PDOException $e) {
        error_log("Database connection error: " . $e->getMessage());
        http_response_code(500);
        // Production'da detaylı hata gösterme, sadece genel mesaj
        $errorMsg = 'Database connection failed';
        if (ini_get('display_errors')) {
            $errorMsg .= ': ' . $e->getMessage();
        }
        echo json_encode(['error' => $errorMsg]);
        exit;
    }
}

/**
 * Token Oluştur ve Kaydet
 * 
 * @param int $userId Kullanıcı ID
 * @return string Token
 */
function generateToken($userId) {
    $token = bin2hex(random_bytes(32));
    $expires = date('Y-m-d H:i:s', strtotime('+7 days'));
    
    $pdo = getDB();
    $stmt = $pdo->prepare("UPDATE users SET token = ?, token_expires_at = ? WHERE id = ?");
    $stmt->execute([$token, $expires, $userId]);
    
    return $token;
}

/**
 * Token Doğrula
 * 
 * @param string $token Token
 * @return array|false Kullanıcı bilgileri veya false
 */
function validateToken($token) {
    if (empty($token)) {
        return false;
    }
    
    $pdo = getDB();
    
    // Önce token'ı kontrol et (expire kontrolü olmadan)
    $stmt = $pdo->prepare("
        SELECT id, email, name, token, token_expires_at
        FROM users 
        WHERE token = ?
    ");
    $stmt->execute([$token]);
    $user = $stmt->fetch();
    
    if (!$user) {
        return false;
    }
    
    // Token expire kontrolü
    if ($user['token_expires_at'] && strtotime($user['token_expires_at']) < time()) {
        return false;
    }
    
    // Sadece gerekli bilgileri döndür
    return [
        'id' => $user['id'],
        'email' => $user['email'],
        'name' => $user['name']
    ];
}

/**
 * Authorization Header'dan Token Al
 * 
 * @return string|null Token veya null
 */
function getTokenFromHeader() {
    // Önce getallheaders() dene
    $headers = getallheaders();
    
    // Eğer getallheaders() çalışmazsa, alternatif yöntem kullan
    if (!$headers) {
        // Apache mod_php için
        if (function_exists('apache_request_headers')) {
            $headers = apache_request_headers();
        } else {
            // Manuel olarak $_SERVER'den oku
            $headers = [];
            foreach ($_SERVER as $key => $value) {
                if (strpos($key, 'HTTP_') === 0) {
                    $headerKey = str_replace(' ', '-', ucwords(str_replace('_', ' ', strtolower(substr($key, 5)))));
                    $headers[$headerKey] = $value;
                }
            }
        }
    }
    
    // Authorization header'ını kontrol et (case-insensitive)
    $authHeader = null;
    if (isset($headers['Authorization'])) {
        $authHeader = $headers['Authorization'];
    } elseif (isset($headers['authorization'])) {
        $authHeader = $headers['authorization'];
    } elseif (isset($_SERVER['HTTP_AUTHORIZATION'])) {
        $authHeader = $_SERVER['HTTP_AUTHORIZATION'];
    } elseif (isset($_SERVER['REDIRECT_HTTP_AUTHORIZATION'])) {
        $authHeader = $_SERVER['REDIRECT_HTTP_AUTHORIZATION'];
    }
    
    if ($authHeader) {
        // Bearer token'ı çıkar
        if (preg_match('/Bearer\s+(.*)$/i', $authHeader, $matches)) {
            return trim($matches[1]);
        }
    }
    
    return null;
}

/**
 * JSON Response Gönder
 * 
 * @param array $data Response data
 * @param int $statusCode HTTP status code
 */
function sendJsonResponse($data, $statusCode = 200) {
    http_response_code($statusCode);
    echo json_encode($data, JSON_UNESCAPED_UNICODE);
    exit;
}

/**
 * Hata Response Gönder
 * 
 * @param string $message Hata mesajı
 * @param int $statusCode HTTP status code
 */
function sendErrorResponse($message, $statusCode = 400) {
    sendJsonResponse(['error' => $message], $statusCode);
}

/**
 * Başarı Response Gönder
 * 
 * @param array $data Response data
 */
function sendSuccessResponse($data = []) {
    sendJsonResponse(array_merge(['success' => true], $data));
}
?>

