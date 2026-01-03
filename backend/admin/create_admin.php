<?php
/**
 * FitLife Admin - Admin Kullanıcısı Oluştur
 * 
 * Bu dosyayı tarayıcıda çalıştırarak admin kullanıcısı oluşturabilirsiniz.
 * Güvenlik için kullanımdan sonra bu dosyayı silin!
 */

require_once '../config/config.php';

// Admin bilgileri
$username = 'admin';
$password = 'admin123';
$email = 'admin@fitlife.com';

try {
    $pdo = getDB();
    
    // Şifreyi hash'le (güvenli)
    $hashedPassword = password_hash($password, PASSWORD_BCRYPT);
    
    // Hash'in başarılı oluşturulduğunu kontrol et
    if (!$hashedPassword) {
        throw new Exception('Şifre hash\'leme hatası!');
    }
    
    // Hash formatını kontrol et (güvenlik)
    if (!preg_match('/^\$2[ay]\$\d{2}\$/', $hashedPassword)) {
        throw new Exception('Geçersiz şifre hash formatı!');
    }
    
    // Admin kullanıcısını ekle veya güncelle
    $stmt = $pdo->prepare("
        INSERT INTO admins (username, password, email) 
        VALUES (?, ?, ?)
        ON DUPLICATE KEY UPDATE 
        password = VALUES(password),
        email = VALUES(email),
        updated_at = CURRENT_TIMESTAMP
    ");
    
    $stmt->execute([$username, $hashedPassword, $email]);
    
    // Sonucu göster
    echo "<!DOCTYPE html>
    <html lang='tr'>
    <head>
        <meta charset='UTF-8'>
        <meta name='viewport' content='width=device-width, initial-scale=1.0'>
        <title>Admin Oluşturuldu</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                max-width: 600px;
                margin: 50px auto;
                padding: 20px;
                background: #f5f5f5;
            }
            .container {
                background: white;
                padding: 30px;
                border-radius: 10px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            }
            h2 {
                color: #27ae60;
                margin-top: 0;
            }
            .info {
                background: #e8f5e9;
                padding: 15px;
                border-radius: 5px;
                margin: 20px 0;
            }
            .info p {
                margin: 10px 0;
            }
            .info strong {
                color: #2c3e50;
            }
            .warning {
                background: #fff3cd;
                padding: 15px;
                border-radius: 5px;
                margin: 20px 0;
                border-left: 4px solid #ffc107;
            }
            .btn {
                display: inline-block;
                padding: 10px 20px;
                background: #3498db;
                color: white;
                text-decoration: none;
                border-radius: 5px;
                margin-top: 20px;
            }
            .btn:hover {
                background: #2980b9;
            }
        </style>
    </head>
    <body>
        <div class='container'>
            <h2>✅ Admin Kullanıcısı Başarıyla Oluşturuldu!</h2>
            
            <div class='info'>
                <p><strong>Kullanıcı Adı:</strong> $username</p>
                <p><strong>Şifre:</strong> $password</p>
                <p><strong>Email:</strong> $email</p>
            </div>
            
            <div class='warning'>
                <strong>⚠️ Güvenlik Uyarısı:</strong><br>
                Bu dosyayı kullanımdan sonra sunucudan silin! Güvenlik riski oluşturabilir.
            </div>
            
            <a href='login.html' class='btn'>Admin Paneline Git</a>
        </div>
    </body>
    </html>";
    
} catch(PDOException $e) {
    echo "<!DOCTYPE html>
    <html lang='tr'>
    <head>
        <meta charset='UTF-8'>
        <meta name='viewport' content='width=device-width, initial-scale=1.0'>
        <title>Hata</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                max-width: 600px;
                margin: 50px auto;
                padding: 20px;
                background: #f5f5f5;
            }
            .container {
                background: white;
                padding: 30px;
                border-radius: 10px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            }
            h2 {
                color: #e74c3c;
                margin-top: 0;
            }
            .error {
                background: #fee;
                padding: 15px;
                border-radius: 5px;
                margin: 20px 0;
                border-left: 4px solid #e74c3c;
            }
        </style>
    </head>
    <body>
        <div class='container'>
            <h2>❌ Hata Oluştu</h2>
            <div class='error'>
                <p><strong>Hata Mesajı:</strong> " . htmlspecialchars($e->getMessage()) . "</p>";
    
    if (strpos($e->getMessage(), 'Unknown database') !== false) {
        echo "<p><strong>Çözüm:</strong> Önce veritabanını oluşturun (veritabani.sql dosyasını çalıştırın)</p>";
    } elseif (strpos($e->getMessage(), 'Table') !== false && strpos($e->getMessage(), "doesn't exist") !== false) {
        echo "<p><strong>Çözüm:</strong> Önce admins tablosunu oluşturun (veritabani.sql dosyasını çalıştırın)</p>";
    }
    
    echo "</div>
        </div>
    </body>
    </html>";
}
?>

