<?php
/**
 * FitLife Admin Panel - Giriş Sayfası (Backend)
 * 
 * Sadece PHP mantığı (giriş işlemi)
 * Tasarım login.html dosyasında
 */

session_start();

// Eğer zaten giriş yapılmışsa dashboard'a yönlendir
if (isset($_SESSION['admin_id']) && !empty($_SESSION['admin_id'])) {
    header('Location: dashboard.php');
    exit;
}

// Config dosyasını yükle
require_once '../config/config.php';

// Giriş işlemi
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['login'])) {
    // Input sanitization
    $username = trim($_POST['username'] ?? '');
    $password = $_POST['password'] ?? '';
    
    // Boş alan kontrolü
    if (empty($username) || empty($password)) {
        header('Location: login.html?error=' . urlencode('Lütfen tüm alanları doldurun!'));
        exit;
    }
    
    // Username uzunluk kontrolü (güvenlik)
    if (strlen($username) > 100 || strlen($password) > 255) {
        header('Location: login.html?error=' . urlencode('Geçersiz giriş bilgileri!'));
        exit;
    }
    
    try {
        $pdo = getDB();
        
        // Admin kullanıcısını sorgula (sadece username ile)
        $stmt = $pdo->prepare("SELECT id, username, password, email FROM admins WHERE username = ? LIMIT 1");
        $stmt->execute([$username]);
        $admin = $stmt->fetch(PDO::FETCH_ASSOC);
        
        // Admin kaydı yoksa veya password hash yoksa hata ver
        if (!$admin) {
            // Güvenlik için aynı hata mesajı (timing attack önleme)
            password_verify($password, '$2y$10$dummyhashforsecuritycheck'); // Dummy hash
            error_log("Admin login: User not found: $username");
            header('Location: login.html?error=' . urlencode('Kullanıcı adı veya şifre hatalı!'));
            exit;
        }
        
        // Password hash boş mu kontrol et
        if (empty($admin['password']) || strlen(trim($admin['password'])) < 10) {
            error_log("Admin login: Empty or invalid password hash for user: $username");
            // Güvenlik için aynı hata mesajı (timing attack önleme)
            password_verify($password, '$2y$10$dummyhashforsecuritycheck'); // Dummy hash
            header('Location: login.html?error=' . urlencode('Kullanıcı adı veya şifre hatalı!'));
            exit;
        }
        
        // Şifre hash formatını kontrol et
        $passwordHash = $admin['password'];
        if (!preg_match('/^\$2[ay]\$\d{2}\$/', $passwordHash)) {
            // Hash formatı geçersiz - güvenlik hatası
            error_log("Admin login: Invalid password hash format for user: $username");
            header('Location: login.html?error=' . urlencode('Kullanıcı adı veya şifre hatalı!'));
            exit;
        }
        
        // Şifre doğrulama
        $passwordValid = password_verify($password, $passwordHash);
        
        // Debug log (production'da kaldırılmalı)
        error_log("Admin login attempt: username=$username, password_valid=" . ($passwordValid ? 'true' : 'false') . ", hash_length=" . strlen($passwordHash));
        
        // Şifre doğru değilse hata ver
        if (!$passwordValid) {
            header('Location: login.html?error=' . urlencode('Kullanıcı adı veya şifre hatalı!'));
            exit;
        }
        
        // Admin ID kontrolü (güvenlik)
        if (empty($admin['id']) || !is_numeric($admin['id'])) {
            header('Location: login.html?error=' . urlencode('Geçersiz admin kaydı!'));
            exit;
        }
        
        // Session güvenliği için ek kontroller
        if (empty($admin['username']) || $admin['username'] !== $username) {
            header('Location: login.html?error=' . urlencode('Kullanıcı adı veya şifre hatalı!'));
            exit;
        }
        
        // Session başlat (güvenli)
        session_regenerate_id(true); // Session fixation saldırısını önle
        
        $_SESSION['admin_id'] = (int)$admin['id'];
        $_SESSION['admin_username'] = $admin['username'];
        $_SESSION['admin_email'] = $admin['email'] ?? '';
        $_SESSION['login_time'] = time(); // Login zamanı
        
        // Başarılı giriş
        header('Location: dashboard.php');
        exit;
        
    } catch(PDOException $e) {
        // Hata loglama (production'da)
        error_log("Admin login error: " . $e->getMessage());
        header('Location: login.html?error=' . urlencode('Giriş hatası oluştu. Lütfen daha sonra tekrar deneyin.'));
        exit;
    }
} else {
    // GET isteği ise login.html'e yönlendir
    header('Location: login.html');
    exit;
}
?>

