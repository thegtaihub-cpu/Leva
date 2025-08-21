<?php
// Debug email configuration
error_reporting(E_ALL);
ini_set('display_errors', 1);

require_once 'includes/functions.php';
require_once 'config/database.php';

echo "<h2>Email Configuration Debug</h2>";

try {
    $database = new Database();
    $pdo = $database->getConnection();
    
    echo "<p>✅ Database connection successful</p>";
    
    // Check if email_logs table exists
    try {
        $stmt = $pdo->query("DESCRIBE email_logs");
        echo "<p>✅ email_logs table exists</p>";
    } catch (Exception $e) {
        echo "<p>⚠️ email_logs table missing - creating it...</p>";
        
        $pdo->exec("
            CREATE TABLE IF NOT EXISTS email_logs (
                id INT AUTO_INCREMENT PRIMARY KEY,
                recipient_email VARCHAR(255) NOT NULL,
                subject VARCHAR(255) NOT NULL,
                email_type ENUM('EXPORT','REPORT','NOTIFICATION') NOT NULL,
                status ENUM('SENT','FAILED','PENDING') DEFAULT 'PENDING',
                response_data TEXT DEFAULT NULL,
                admin_id INT NOT NULL,
                sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (admin_id) REFERENCES users(id)
            )
        ");
        
        echo "<p>✅ email_logs table created</p>";
    }
    
    // Get current email settings
    $stmt = $pdo->prepare("
        SELECT setting_key, setting_value 
        FROM settings 
        WHERE setting_key IN ('smtp_host', 'smtp_port', 'smtp_username', 'smtp_password', 'smtp_encryption', 'hotel_name')
    ");
    $stmt->execute();
    $settings = [];
    while ($row = $stmt->fetch()) {
        $settings[$row['setting_key']] = $row['setting_value'];
    }
    
    echo "<h3>Current Email Settings:</h3>";
    echo "<ul>";
    echo "<li>SMTP Host: " . htmlspecialchars($settings['smtp_host'] ?? 'Not set') . "</li>";
    echo "<li>SMTP Port: " . htmlspecialchars($settings['smtp_port'] ?? 'Not set') . "</li>";
    echo "<li>SMTP Username: " . htmlspecialchars($settings['smtp_username'] ?? 'Not set') . "</li>";
    echo "<li>SMTP Password: " . (empty($settings['smtp_password']) ? 'Not set' : '***SET***') . "</li>";
    echo "<li>SMTP Encryption: " . htmlspecialchars($settings['smtp_encryption'] ?? 'Not set') . "</li>";
    echo "<li>Hotel Name: " . htmlspecialchars($settings['hotel_name'] ?? 'Not set') . "</li>";
    echo "</ul>";
    
    // Check PHPMailer availability
    if (file_exists(__DIR__ . '/vendor/autoload.php')) {
        echo "<p>✅ PHPMailer available via Composer</p>";
        require_once __DIR__ . '/vendor/autoload.php';
        echo "<p>✅ PHPMailer loaded successfully</p>";
    } else {
        echo "<p>⚠️ PHPMailer not available - will use PHP mail() function</p>";
    }
    
    // Check if all required settings are present
    $required = ['smtp_host', 'smtp_username', 'smtp_password'];
    $missing = [];
    foreach ($required as $key) {
        if (empty($settings[$key])) {
            $missing[] = $key;
        }
    }
    
    if (!empty($missing)) {
        echo "<p style='color: red;'>❌ Missing required settings: " . implode(', ', $missing) . "</p>";
    } else {
        echo "<p style='color: green;'>✅ All required email settings are configured</p>";
    }
    
    echo "<hr>";
    echo "<p><a href='owner/settings.php'>Go to Settings</a></p>";
    
} catch (Exception $e) {
    echo "<p style='color: red;'>❌ Error: " . htmlspecialchars($e->getMessage()) . "</p>";
    echo "<p>Stack trace:</p>";
    echo "<pre>" . htmlspecialchars($e->getTraceAsString()) . "</pre>";
}
?>