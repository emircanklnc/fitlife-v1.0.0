<?php
/**
 * Profil Getir/Güncelle Endpoint
 * 
 * GET /api/profile.php - Profil getir
 * PUT /api/profile.php - Profil güncelle
 * 
 * Headers:
 * Authorization: Bearer <token>
 * 
 * PUT Body:
 * {
 *   "name": "Yeni İsim" (optional),
 *   "age": 26 (optional),
 *   "height": 176.0 (optional),
 *   "weight": 71.0 (optional),
 *   "gender": "Male" | "Female" (optional),
 *   "daily_calorie_goal": 2200 (optional)
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
    // Profil getir
    try {
        $stmt = $pdo->prepare("
            SELECT 
                id, email, name, age, height, weight, gender, 
                daily_calorie_goal, target_weight, created_at, updated_at
            FROM users 
            WHERE id = ?
        ");
        $stmt->execute([$userId]);
        $profile = $stmt->fetch();
        
        if (!$profile) {
            sendErrorResponse('Profile not found', 404);
        }
        
        // Kilo geçmişi
        $stmt = $pdo->prepare("
            SELECT date, weight 
            FROM weight_history 
            WHERE user_id = ? 
            ORDER BY date ASC
        ");
        $stmt->execute([$userId]);
        $weightHistory = $stmt->fetchAll();
        
        // Tarih formatını düzelt
        foreach ($weightHistory as &$entry) {
            $entry['date'] = date('Y-m-d', strtotime($entry['date']));
        }
        
        $profile['weight_history'] = $weightHistory;
        $profile['id'] = (int)$profile['id'];
        $profile['age'] = $profile['age'] !== null ? (int)$profile['age'] : null;
        $profile['daily_calorie_goal'] = (int)$profile['daily_calorie_goal'];
        
        sendSuccessResponse(['profile' => $profile]);
        
    } catch(PDOException $e) {
        error_log("Get profile error: " . $e->getMessage());
        sendErrorResponse('Failed to get profile', 500);
    }
    
} elseif ($_SERVER['REQUEST_METHOD'] === 'PUT') {
    // Profil güncelle
    try {
        $data = json_decode(file_get_contents('php://input'), true);
        
        // Mevcut profili al
        $stmt = $pdo->prepare("SELECT weight FROM users WHERE id = ?");
        $stmt->execute([$userId]);
        $currentProfile = $stmt->fetch();
        $oldWeight = $currentProfile['weight'] ?? null;
        
        // Profil güncelle
        $updateFields = [];
        $updateValues = [];
        
        if (isset($data['name'])) {
            $updateFields[] = 'name = ?';
            $updateValues[] = $data['name'];
        }
        if (isset($data['age'])) {
            $updateFields[] = 'age = ?';
            $updateValues[] = $data['age'];
        }
        if (isset($data['height'])) {
            $updateFields[] = 'height = ?';
            $updateValues[] = $data['height'];
        }
        if (isset($data['weight'])) {
            $updateFields[] = 'weight = ?';
            $updateValues[] = $data['weight'];
        }
        if (isset($data['gender'])) {
            $updateFields[] = 'gender = ?';
            $updateValues[] = $data['gender'];
        }
        if (isset($data['daily_calorie_goal'])) {
            $updateFields[] = 'daily_calorie_goal = ?';
            $updateValues[] = $data['daily_calorie_goal'];
        }
        if (isset($data['target_weight'])) {
            $updateFields[] = 'target_weight = ?';
            $updateValues[] = $data['target_weight'];
        }
        
        if (!empty($updateFields)) {
            $updateValues[] = $userId;
            $sql = "UPDATE users SET " . implode(', ', $updateFields) . " WHERE id = ?";
            $stmt = $pdo->prepare($sql);
            $stmt->execute($updateValues);
        }
        
        // Kilo değiştiyse geçmişe ekle
        if (isset($data['weight']) && $data['weight'] != $oldWeight) {
            try {
                $stmt = $pdo->prepare("
                    INSERT INTO weight_history (user_id, weight, date) 
                    VALUES (?, ?, CURDATE())
                    ON DUPLICATE KEY UPDATE weight = ?
                ");
                $stmt->execute([$userId, $data['weight'], $data['weight']]);
                error_log("Weight history added: user_id=$userId, weight={$data['weight']}, date=" . date('Y-m-d'));
            } catch(PDOException $e) {
                error_log("Weight history insert error: " . $e->getMessage());
                // Kilo geçmişi eklenemese bile profil güncellemesi başarılı sayılır
                // Çünkü ana kilo zaten güncellendi
            }
        }
        
        sendSuccessResponse(['message' => 'Profile updated successfully']);
        
    } catch(PDOException $e) {
        error_log("Update profile error: " . $e->getMessage());
        error_log("Update profile error trace: " . $e->getTraceAsString());
        sendErrorResponse('Failed to update profile: ' . $e->getMessage(), 500);
    } catch(Exception $e) {
        error_log("Update profile general error: " . $e->getMessage());
        error_log("Update profile error trace: " . $e->getTraceAsString());
        sendErrorResponse('Failed to update profile: ' . $e->getMessage(), 500);
    }
    
} else {
    sendErrorResponse('Method not allowed', 405);
}
?>

