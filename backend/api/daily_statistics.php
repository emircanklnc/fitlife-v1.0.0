<?php
/**
 * Günlük İstatistikler Endpoint
 * 
 * GET /api/daily_statistics.php - Son 7 günlük istatistikleri getir
 * POST /api/daily_statistics.php - Günlük istatistik kaydet/güncelle
 * 
 * Headers:
 * Authorization: Bearer <token>
 * 
 * POST Body:
 * {
 *   "date": "2024-01-15" (optional, default: today),
 *   "calories_in": 1500 (optional),
 *   "calories_out": 300 (optional),
 *   "water_intake": 6 (optional),
 *   "exercise_minutes": 45 (optional)
 * }
 */

require_once '../config/config.php';

$token = getTokenFromHeader();
$user = validateToken($token);

if (!$user) {
    sendErrorResponse('Invalid or expired token', 401);
}

$pdo = getDB();
$userId = $user['id'];

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Son 7 günlük istatistikleri getir
    try {
        $stmt = $pdo->prepare("
            SELECT 
                date, 
                calories_in, 
                calories_out, 
                water_intake, 
                exercise_minutes
            FROM daily_statistics
            WHERE user_id = ? AND date >= DATE_SUB(CURDATE(), INTERVAL 6 DAY)
            ORDER BY date ASC
        ");
        $stmt->execute([$userId]);
        $statistics = $stmt->fetchAll();
        
        // Tarih formatını düzelt
        foreach ($statistics as &$stat) {
            $stat['date'] = date('Y-m-d', strtotime($stat['date']));
            $stat['calories_in'] = (int)$stat['calories_in'];
            $stat['calories_out'] = (int)$stat['calories_out'];
            $stat['water_intake'] = (int)$stat['water_intake'];
            $stat['exercise_minutes'] = (int)$stat['exercise_minutes'];
        }
        
        sendSuccessResponse(['statistics' => $statistics]);
        
    } catch(PDOException $e) {
        error_log("Get statistics error: " . $e->getMessage());
        sendErrorResponse('Failed to get statistics', 500);
    }
    
} elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Günlük istatistik kaydet/güncelle
    try {
        $data = json_decode(file_get_contents('php://input'), true);
        
        $date = $data['date'] ?? date('Y-m-d');
        $caloriesIn = $data['calories_in'] ?? 0;
        $caloriesOut = $data['calories_out'] ?? 0;
        $waterIntake = $data['water_intake'] ?? 0;
        $exerciseMinutes = $data['exercise_minutes'] ?? 0;
        
        // Tarih formatını kontrol et
        if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $date)) {
            sendErrorResponse('Invalid date format. Use YYYY-MM-DD');
        }
        
        $stmt = $pdo->prepare("
            INSERT INTO daily_statistics (
                user_id, date, calories_in, calories_out, water_intake, exercise_minutes
            )
            VALUES (?, ?, ?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE
                calories_in = VALUES(calories_in),
                calories_out = VALUES(calories_out),
                water_intake = VALUES(water_intake),
                exercise_minutes = VALUES(exercise_minutes),
                updated_at = NOW()
        ");
        $stmt->execute([
            $userId, 
            $date, 
            $caloriesIn, 
            $caloriesOut, 
            $waterIntake, 
            $exerciseMinutes
        ]);
        
        sendSuccessResponse(['message' => 'Statistics saved successfully']);
        
    } catch(PDOException $e) {
        error_log("Save statistics error: " . $e->getMessage());
        sendErrorResponse('Failed to save statistics', 500);
    }
    
} else {
    sendErrorResponse('Method not allowed', 405);
}
?>

