<?php
/**
 * Yemek Kayıtları Endpoint
 * 
 * GET /api/food_logs.php?date=2024-01-15 - Belirtilen tarihin yemek kayıtlarını getir
 * POST /api/food_logs.php - Yeni yemek kaydı ekle
 * DELETE /api/food_logs.php?id=<food_log_id>&date=2024-01-15 - Yemek kaydı sil
 * 
 * Headers:
 * Authorization: Bearer <token>
 * 
 * POST Body:
 * {
 *   "id": "uuid",
 *   "date": "2024-01-15",
 *   "food_name": "Tavuk Göğsü",
 *   "calories": 200,
 *   "protein": 40.0,
 *   "carbs": 0.0,
 *   "fat": 5.0
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
    // Belirtilen tarihin yemek kayıtlarını getir
    try {
        $date = $_GET['date'] ?? date('Y-m-d');
        
        // Tarih formatını kontrol et
        if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $date)) {
            sendErrorResponse('Invalid date format. Use YYYY-MM-DD');
        }
        
        $stmt = $pdo->prepare("
            SELECT 
                id, date, food_name, calories, 
                CAST(protein AS DECIMAL(5,2)) as protein,
                CAST(carbs AS DECIMAL(5,2)) as carbs,
                CAST(fat AS DECIMAL(5,2)) as fat,
                created_at
            FROM food_logs
            WHERE user_id = ? AND date = ?
            ORDER BY created_at ASC
        ");
        $stmt->execute([$userId, $date]);
        $foodLogs = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        // Veri formatını düzelt (DECIMAL alanları float'a çevir)
        foreach ($foodLogs as &$log) {
            $log['date'] = $log['date'];
            $log['protein'] = floatval($log['protein'] ?? 0);
            $log['carbs'] = floatval($log['carbs'] ?? 0);
            $log['fat'] = floatval($log['fat'] ?? 0);
            $log['calories'] = intval($log['calories'] ?? 0);
            $log['created_at'] = $log['created_at'];
        }
        
        sendSuccessResponse(['food_logs' => $foodLogs]);
        
    } catch(PDOException $e) {
        error_log("Get food logs error: " . $e->getMessage());
        sendErrorResponse('Failed to get food logs', 500);
    }
    
} elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Yeni yemek kaydı ekle
    try {
        $data = json_decode(file_get_contents('php://input'), true);
        
        $id = $data['id'] ?? '';
        $date = $data['date'] ?? date('Y-m-d');
        $foodName = $data['food_name'] ?? '';
        $calories = $data['calories'] ?? 0;
        $protein = $data['protein'] ?? 0.0;
        $carbs = $data['carbs'] ?? 0.0;
        $fat = $data['fat'] ?? 0.0;
        
        // Validasyon
        if (empty($id) || empty($foodName) || $calories <= 0) {
            sendErrorResponse('Missing required fields');
        }
        
        if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $date)) {
            sendErrorResponse('Invalid date format. Use YYYY-MM-DD');
        }
        
        $stmt = $pdo->prepare("
            INSERT INTO food_logs (
                id, user_id, date, food_name, calories, protein, carbs, fat
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ");
        $stmt->execute([
            $id,
            $userId,
            $date,
            $foodName,
            $calories,
            $protein,
            $carbs,
            $fat
        ]);
        
        sendSuccessResponse(['message' => 'Food log added successfully']);
        
    } catch(PDOException $e) {
        error_log("Add food log error: " . $e->getMessage());
        sendErrorResponse('Failed to add food log', 500);
    }
    
} elseif ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
    // Yemek kaydı sil
    try {
        $id = $_GET['id'] ?? '';
        $date = $_GET['date'] ?? date('Y-m-d');
        
        if (empty($id)) {
            sendErrorResponse('Food log ID is required');
        }
        
        if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $date)) {
            sendErrorResponse('Invalid date format. Use YYYY-MM-DD');
        }
        
        $stmt = $pdo->prepare("
            DELETE FROM food_logs
            WHERE id = ? AND user_id = ? AND date = ?
        ");
        $stmt->execute([$id, $userId, $date]);
        
        if ($stmt->rowCount() > 0) {
            sendSuccessResponse(['message' => 'Food log deleted successfully']);
        } else {
            sendErrorResponse('Food log not found', 404);
        }
        
    } catch(PDOException $e) {
        error_log("Delete food log error: " . $e->getMessage());
        sendErrorResponse('Failed to delete food log', 500);
    }
    
} else {
    sendErrorResponse('Method not allowed', 405);
}
?>

