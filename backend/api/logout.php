<?php
/**
 * Kullanıcı Çıkış Endpoint
 * 
 * POST /api/logout.php
 * 
 * Headers:
 * Authorization: Bearer <token>
 */

require_once '../config/config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendErrorResponse('Method not allowed', 405);
}

$token = getTokenFromHeader();
$user = validateToken($token);

if (!$user) {
    sendErrorResponse('Invalid or expired token', 401);
}

try {
    $pdo = getDB();
    $userId = $user['id'];
    
    // Token'ı veritabanında null yap (iptal et)
    $stmt = $pdo->prepare("UPDATE users SET token = NULL, token_expires_at = NULL WHERE id = ?");
    $stmt->execute([$userId]);
    
    sendSuccessResponse(['message' => 'Logged out successfully']);
    
} catch(PDOException $e) {
    error_log("Logout error: " . $e->getMessage());
    sendErrorResponse('Logout failed', 500);
}
?>

