<?php
/**
 * Kullanıcı Giriş Endpoint
 * 
 * POST /api/login.php
 * 
 * Body:
 * {
 *   "email": "user@example.com",
 *   "password": "password123"
 * }
 */

require_once '../config/config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendErrorResponse('Method not allowed', 405);
}

$data = json_decode(file_get_contents('php://input'), true);
$email = $data['email'] ?? '';
$password = $data['password'] ?? '';

if (empty($email) || empty($password)) {
    sendErrorResponse('Email and password are required');
}

try {
    $pdo = getDB();
    $stmt = $pdo->prepare("SELECT id, email, password, name FROM users WHERE email = ?");
    $stmt->execute([$email]);
    $user = $stmt->fetch();
    
    if (!$user || !password_verify($password, $user['password'])) {
        sendErrorResponse('Invalid credentials', 401);
    }
    
    // Token oluştur
    $token = generateToken($user['id']);
    
    sendSuccessResponse([
        'token' => $token,
        'user' => [
            'id' => (int)$user['id'],
            'email' => $user['email'],
            'name' => $user['name']
        ]
    ]);
    
} catch(PDOException $e) {
    error_log("Login error: " . $e->getMessage());
    sendErrorResponse('Login failed', 500);
}
?>

