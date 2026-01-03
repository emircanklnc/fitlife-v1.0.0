<?php
/**
 * FitLife Admin Panel - Dashboard (Backend)
 * 
 * Sadece PHP mantığı (veritabanı işlemleri)
 * Tasarım dashboard.html dosyasında
 */

// HTML çıktısı için header'ı ayarla (config.php'den önce)
if (!headers_sent()) {
    header('Content-Type: text/html; charset=utf-8');
}

session_start();

// Eğer giriş yapılmamışsa login sayfasına yönlendir
if (!isset($_SESSION['admin_id']) || empty($_SESSION['admin_id']) || !is_numeric($_SESSION['admin_id'])) {
    session_destroy(); // Güvenlik için session'ı temizle
    header('Location: login.html');
    exit;
}

// Config dosyasını yükle (session kontrolünden sonra)
require_once '../config/config.php';

// Admin kaydının gerçekten var olduğunu kontrol et (güvenlik)
try {
    $pdo = getDB();
    $adminId = (int)$_SESSION['admin_id'];
    $stmt = $pdo->prepare("SELECT id, username FROM admins WHERE id = ? LIMIT 1");
    $stmt->execute([$adminId]);
    $adminCheck = $stmt->fetch(PDO::FETCH_ASSOC);
    
    // Admin kaydı yoksa veya username eşleşmiyorsa logout yap
    if (!$adminCheck || $adminCheck['username'] !== ($_SESSION['admin_username'] ?? '')) {
        session_destroy();
        header('Location: login.html?error=' . urlencode('Oturum geçersiz. Lütfen tekrar giriş yapın.'));
        exit;
    }
} catch(PDOException $e) {
    // Veritabanı hatası durumunda güvenli çıkış
    error_log("Admin session check error: " . $e->getMessage());
    session_destroy();
    header('Location: login.html?error=' . urlencode('Oturum kontrolü başarısız. Lütfen tekrar giriş yapın.'));
    exit;
}

// Çıkış işlemi
if (isset($_GET['action']) && $_GET['action'] === 'logout') {
    session_destroy();
    header('Location: login.html');
    exit;
}

// Config dosyası yukarıda yüklendi (session kontrolünden sonra)

// HTML için header'ı tekrar ayarla (config.php JSON header'ı set edebilir)
if (!headers_sent()) {
    header('Content-Type: text/html; charset=utf-8');
}

// Flash message'ları başlat
if (!isset($_SESSION['flash_message'])) {
    $_SESSION['flash_message'] = '';
    $_SESSION['flash_type'] = '';
}

// Kullanıcı silme işlemi
if (isset($_GET['action']) && $_GET['action'] === 'delete' && isset($_GET['id'])) {
    try {
        $pdo = getDB();
        $userId = (int)$_GET['id'];
        
        $stmt = $pdo->prepare("DELETE FROM users WHERE id = ?");
        $stmt->execute([$userId]);
        
        $_SESSION['flash_message'] = 'Kullanıcı başarıyla silindi.';
        $_SESSION['flash_type'] = 'success';
        header('Location: dashboard.php');
        exit;
    } catch(PDOException $e) {
        $_SESSION['flash_message'] = 'Kullanıcı silinirken hata oluştu: ' . $e->getMessage();
        $_SESSION['flash_type'] = 'error';
        header('Location: dashboard.php');
        exit;
    }
}

// Kullanıcı güncelleme işlemi
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'update') {
    try {
        $pdo = getDB();
        $userId = (int)$_POST['user_id'];
        $email = trim($_POST['email'] ?? '');
        $name = trim($_POST['name'] ?? '');
        $age = !empty($_POST['age']) ? (int)$_POST['age'] : null;
        $height = !empty($_POST['height']) ? (float)$_POST['height'] : null;
        $weight = !empty($_POST['weight']) ? (float)$_POST['weight'] : null;
        $gender = !empty($_POST['gender']) ? $_POST['gender'] : null;
        
        // Validasyon
        if (empty($email) || empty($name)) {
            throw new Exception('Email ve isim alanları zorunludur.');
        }
        
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            throw new Exception('Geçerli bir email adresi giriniz.');
        }
        
        // Email kontrolü (kendi email'i hariç)
        $stmt = $pdo->prepare("SELECT id FROM users WHERE email = ? AND id != ?");
        $stmt->execute([$email, $userId]);
        if ($stmt->fetch()) {
            throw new Exception('Bu email adresi başka bir kullanıcı tarafından kullanılıyor.');
        }
        
        // Güncelleme
        $stmt = $pdo->prepare("
            UPDATE users 
            SET email = ?, name = ?, age = ?, height = ?, weight = ?, gender = ?
            WHERE id = ?
        ");
        $stmt->execute([$email, $name, $age, $height, $weight, $gender, $userId]);
        
        $_SESSION['flash_message'] = 'Kullanıcı bilgileri başarıyla güncellendi.';
        $_SESSION['flash_type'] = 'success';
        header('Location: dashboard.php');
        exit;
    } catch(Exception $e) {
        $_SESSION['flash_message'] = $e->getMessage();
        $_SESSION['flash_type'] = 'error';
        header('Location: dashboard.php');
        exit;
    }
}

// Veritabanından verileri çek
$totalUsers = 0;
$users = [];
$error = '';

try {
    $pdo = getDB();
    
    // Toplam kullanıcı sayısı
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM users");
    $totalUsers = $stmt->fetch()['total'];
    
    // Kullanıcı listesi
    $stmt = $pdo->query("
        SELECT id, email, name, age, height, weight, gender, created_at 
        FROM users 
        ORDER BY created_at DESC
    ");
    $users = $stmt->fetchAll();
} catch(PDOException $e) {
    $error = 'Veri çekme hatası: ' . $e->getMessage();
}

// Flash message'ı al ve temizle
$flashMessage = $_SESSION['flash_message'] ?? '';
$flashType = $_SESSION['flash_type'] ?? '';
unset($_SESSION['flash_message']);
unset($_SESSION['flash_type']);

// HTML dosyasını include et (PHP değişkenleri kullanılabilir)
include 'dashboard.html';
?>

