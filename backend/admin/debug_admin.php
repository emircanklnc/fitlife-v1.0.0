<?php
/**
 * FitLife Admin - Debug Script
 * 
 * Admin kayıtlarını ve şifre hash'lerini kontrol eder
 * GÜVENLİK: Kullanımdan sonra silin!
 */

require_once '../config/config.php';

header('Content-Type: text/html; charset=utf-8');

echo "<!DOCTYPE html>
<html lang='tr'>
<head>
    <meta charset='UTF-8'>
    <title>Admin Debug</title>
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; background: #f5f5f5; }
        .container { background: white; padding: 20px; border-radius: 10px; max-width: 800px; margin: 0 auto; }
        h2 { color: #333; }
        .info { background: #e3f2fd; padding: 15px; border-radius: 5px; margin: 10px 0; }
        .error { background: #ffebee; padding: 15px; border-radius: 5px; margin: 10px 0; }
        .success { background: #e8f5e9; padding: 15px; border-radius: 5px; margin: 10px 0; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th, td { padding: 10px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background: #f5f5f5; }
        code { background: #f5f5f5; padding: 2px 6px; border-radius: 3px; }
    </style>
</head>
<body>
    <div class='container'>
        <h2>🔍 Admin Debug Bilgileri</h2>";

try {
    $pdo = getDB();
    
    // Tüm admin kayıtlarını çek
    $stmt = $pdo->query("SELECT id, username, password, email, created_at FROM admins");
    $admins = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo "<div class='info'><strong>Toplam Admin Sayısı:</strong> " . count($admins) . "</div>";
    
    if (empty($admins)) {
        echo "<div class='error'><strong>⚠️ UYARI:</strong> Veritabanında hiç admin kaydı yok!</div>";
    } else {
        echo "<table>
            <tr>
                <th>ID</th>
                <th>Username</th>
                <th>Password Hash</th>
                <th>Hash Uzunluğu</th>
                <th>Hash Format</th>
                <th>Email</th>
                <th>Test</th>
            </tr>";
        
        foreach ($admins as $admin) {
            $hash = $admin['password'];
            $hashLength = strlen($hash);
            $isValidFormat = preg_match('/^\$2[ay]\$\d{2}\$/', $hash);
            
            // Şifre testi
            $testPassword = 'admin123';
            $passwordMatch = password_verify($testPassword, $hash);
            
            echo "<tr>";
            echo "<td>" . htmlspecialchars($admin['id']) . "</td>";
            echo "<td><strong>" . htmlspecialchars($admin['username']) . "</strong></td>";
            echo "<td><code>" . htmlspecialchars(substr($hash, 0, 30)) . "...</code></td>";
            echo "<td>$hashLength</td>";
            echo "<td>" . ($isValidFormat ? "✅ Geçerli" : "❌ Geçersiz") . "</td>";
            echo "<td>" . htmlspecialchars($admin['email'] ?? '') . "</td>";
            echo "<td>" . ($passwordMatch ? "✅ 'admin123' eşleşiyor" : "❌ 'admin123' eşleşmiyor") . "</td>";
            echo "</tr>";
        }
        
        echo "</table>";
    }
    
    // Test: Rastgele şifre ile test
    echo "<div class='info'><h3>🔐 Şifre Doğrulama Testi</h3>";
    
    if (!empty($admins)) {
        $testAdmin = $admins[0];
        $testHash = $testAdmin['password'];
        
        $testCases = [
            'admin123' => 'Doğru şifre',
            'wrongpass' => 'Yanlış şifre',
            'test' => 'Rastgele şifre',
            '' => 'Boş şifre'
        ];
        
        echo "<table>
            <tr><th>Test Şifre</th><th>Açıklama</th><th>Sonuç</th></tr>";
        
        foreach ($testCases as $testPass => $desc) {
            $result = password_verify($testPass, $testHash);
            $status = $result ? "✅ DOĞRU (GİRİŞ YAPABİLİR)" : "❌ YANLIŞ (GİRİŞ YAPAMAZ)";
            $color = $result ? "color: red; font-weight: bold;" : "";
            
            echo "<tr>";
            echo "<td><code>" . htmlspecialchars($testPass ?: '(boş)') . "</code></td>";
            echo "<td>$desc</td>";
            echo "<td style='$color'>$status</td>";
            echo "</tr>";
        }
        
        echo "</table>";
    }
    
    echo "</div>";
    
    // Session bilgileri
    session_start();
    echo "<div class='info'><h3>📋 Mevcut Session Bilgileri</h3>";
    if (isset($_SESSION['admin_id'])) {
        echo "<p><strong>Admin ID:</strong> " . htmlspecialchars($_SESSION['admin_id']) . "</p>";
        echo "<p><strong>Admin Username:</strong> " . htmlspecialchars($_SESSION['admin_username'] ?? '') . "</p>";
        echo "<p><strong>Login Time:</strong> " . (isset($_SESSION['login_time']) ? date('Y-m-d H:i:s', $_SESSION['login_time']) : 'Yok') . "</p>";
    } else {
        echo "<p>❌ Aktif session yok</p>";
    }
    echo "</div>";
    
} catch(PDOException $e) {
    echo "<div class='error'><strong>❌ Veritabanı Hatası:</strong> " . htmlspecialchars($e->getMessage()) . "</div>";
}

echo "<div class='info' style='margin-top: 20px;'>
    <strong>⚠️ GÜVENLİK UYARISI:</strong><br>
    Bu dosyayı kullanımdan sonra sunucudan silin!
</div>";

echo "</div></body></html>";
?>

