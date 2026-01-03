<?php
/**
 * Egzersizler Endpoint
 * 
 * GET /api/exercises.php?date=2024-01-15 - Belirtilen tarihin egzersizlerini getir
 * POST /api/exercises.php - Yeni egzersiz ekle
 * DELETE /api/exercises.php?id=<exercise_id>&date=2024-01-15 - Egzersiz sil
 * 
 * Headers:
 * Authorization: Bearer <token>
 * 
 * POST Body:
 * {
 *   "id": "uuid",
 *   "date": "2024-01-15",
 *   "type": "cardio" | "weights",
 *   "name": "Koşu",
 *   "duration": 30,
 *   "calories_burned": 300
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
    // Belirtilen tarihin egzersizlerini getir
    try {
        $date = $_GET['date'] ?? date('Y-m-d');
        
        // Tarih formatını kontrol et
        if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $date)) {
            sendErrorResponse('Invalid date format. Use YYYY-MM-DD');
        }
        
        $stmt = $pdo->prepare("
            SELECT 
                id, date, type, name, duration, calories_burned, created_at
            FROM exercises
            WHERE user_id = ? AND date = ?
            ORDER BY created_at ASC
        ");
        $stmt->execute([$userId, $date]);
        $exercises = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        // Tarih formatını düzelt
        foreach ($exercises as &$exercise) {
            $exercise['date'] = $exercise['date'];
            $exercise['created_at'] = $exercise['created_at'];
        }
        
        sendSuccessResponse(['exercises' => $exercises]);
        
    } catch(PDOException $e) {
        error_log("Get exercises error: " . $e->getMessage());
        sendErrorResponse('Failed to get exercises', 500);
    }
    
} elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Yeni egzersiz ekle
    try {
        $data = json_decode(file_get_contents('php://input'), true);
        
        $id = $data['id'] ?? '';
        $date = $data['date'] ?? date('Y-m-d');
        $type = $data['type'] ?? '';
        $name = $data['name'] ?? '';
        $duration = $data['duration'] ?? 0;
        $caloriesBurned = $data['calories_burned'] ?? 0;
        
        // Validasyon
        if (empty($id) || empty($type) || empty($name) || $duration <= 0) {
            sendErrorResponse('Missing required fields');
        }
        
        if (!in_array($type, ['cardio', 'weights'])) {
            sendErrorResponse('Invalid exercise type. Use "cardio" or "weights"');
        }
        
        if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $date)) {
            sendErrorResponse('Invalid date format. Use YYYY-MM-DD');
        }
        
        $stmt = $pdo->prepare("
            INSERT INTO exercises (
                id, user_id, date, type, name, duration, calories_burned
            )
            VALUES (?, ?, ?, ?, ?, ?, ?)
        ");
        $stmt->execute([
            $id,
            $userId,
            $date,
            $type,
            $name,
            $duration,
            $caloriesBurned
        ]);
        
        sendSuccessResponse(['message' => 'Exercise added successfully']);
        
    } catch(PDOException $e) {
        error_log("Add exercise error: " . $e->getMessage());
        sendErrorResponse('Failed to add exercise', 500);
    }
    
} elseif ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
    // Egzersiz sil
    try {
        $id = $_GET['id'] ?? '';
        $date = $_GET['date'] ?? date('Y-m-d');
        
        if (empty($id)) {
            sendErrorResponse('Exercise ID is required');
        }
        
        if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $date)) {
            sendErrorResponse('Invalid date format. Use YYYY-MM-DD');
        }
        
        $stmt = $pdo->prepare("
            DELETE FROM exercises
            WHERE id = ? AND user_id = ? AND date = ?
        ");
        $stmt->execute([$id, $userId, $date]);
        
        if ($stmt->rowCount() > 0) {
            sendSuccessResponse(['message' => 'Exercise deleted successfully']);
        } else {
            sendErrorResponse('Exercise not found', 404);
        }
        
    } catch(PDOException $e) {
        error_log("Delete exercise error: " . $e->getMessage());
        sendErrorResponse('Failed to delete exercise', 500);
    }
    
} else {
    sendErrorResponse('Method not allowed', 405);
}
?>

