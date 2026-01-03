<?php
/**
 * Kullanıcı Kayıt Endpoint
 * 
 * POST /api/register.php
 * 
 * Body:
 * {
 *   "email": "user@example.com",
 *   "password": "password123",
 *   "name": "Kullanıcı Adı",
 *   "age": 25 (optional),
 *   "height": 175.5 (optional),
 *   "weight": 70.5 (optional),
 *   "gender": "Male" | "Female" (optional)
 * }
 */

require_once '../config/config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendErrorResponse('Method not allowed', 405);
}

$rawInput = file_get_contents('php://input');
$data = json_decode($rawInput, true);

// JSON decode hatası kontrolü
if (json_last_error() !== JSON_ERROR_NONE) {
    sendErrorResponse('Invalid JSON format: ' . json_last_error_msg(), 400);
}

// Validasyon
$email = $data['email'] ?? '';
$password = $data['password'] ?? '';
$name = $data['name'] ?? '';

if (empty($email) || empty($password) || empty($name)) {
    sendErrorResponse('Email, password and name are required');
}

// Email format kontrolü
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    sendErrorResponse('Invalid email format');
}

// Şifre uzunluk kontrolü
if (strlen($password) < 6) {
    sendErrorResponse('Password must be at least 6 characters');
}

try {
    $pdo = getDB();
    
    // Email kontrolü (zaten kayıtlı mı?)
    $stmt = $pdo->prepare("SELECT id FROM users WHERE email = ?");
    $stmt->execute([$email]);
    if ($stmt->fetch()) {
        sendErrorResponse('Email already exists', 409);
    }
    
    // Kullanıcı oluştur
    $hashedPassword = password_hash($password, PASSWORD_BCRYPT);
    $stmt = $pdo->prepare("
        INSERT INTO users (email, password, name, age, height, weight, gender, daily_calorie_goal) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ");
    $stmt->execute([
        $email,
        $hashedPassword,
        $name,
        $data['age'] ?? null,
        $data['height'] ?? null,
        $data['weight'] ?? null,
        $data['gender'] ?? null,
        2000 // Varsayılan kalori hedefi
    ]);
    
    $userId = $pdo->lastInsertId();
    $token = generateToken($userId);
    
    // İlk kilo kaydı (eğer verildiyse)
    if (!empty($data['weight'])) {
        $stmt = $pdo->prepare("
            INSERT INTO weight_history (user_id, weight, date) 
            VALUES (?, ?, CURDATE())
        ");
        $stmt->execute([$userId, $data['weight']]);
    }
    
    sendSuccessResponse([
        'token' => $token,
        'user' => [
            'id' => (int)$userId,
            'email' => $email,
            'name' => $name
        ]
    ]);
    
} catch(PDOException $e) {
    error_log("Register error: " . $e->getMessage());
    // Production'da detaylı hata mesajı göster (debug için)
    $errorMsg = 'Registration failed: ' . $e->getMessage();
    sendErrorResponse($errorMsg, 500);
} catch(Exception $e) {
    error_log("Register error: " . $e->getMessage());
    sendErrorResponse('Registration failed: ' . $e->getMessage(), 500);
}
?>

