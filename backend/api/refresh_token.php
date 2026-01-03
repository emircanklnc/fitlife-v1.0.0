<?php
/**
 * Token Yenileme Endpoint
 * 
 * POST /api/refresh_token.php
 * 
 * Headers:
 * Authorization: Bearer <token>
 * 
 * Mevcut token'ı doğrular ve yeni token oluşturur.
 * 7 günlük token yenileme mekanizması için kullanılır.
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
    // Mevcut token geçerliyse yeni token oluştur
    $newToken = generateToken($user['id']);
    
    sendSuccessResponse([
        'token' => $newToken,
        'message' => 'Token refreshed successfully'
    ]);
    
} catch(PDOException $e) {
    error_log("Refresh token error: " . $e->getMessage());
    sendErrorResponse('Token refresh failed', 500);
}
?>

