<?php
/**
 * Email Functions for L.P.S.T Bookings System
 * Handles email sending for reports and exports
 */

// Check if PHPMailer is available via Composer
if (file_exists(__DIR__ . '/../vendor/autoload.php')) {
    require_once __DIR__ . '/../vendor/autoload.php';
    use PHPMailer\PHPMailer\PHPMailer;
    use PHPMailer\PHPMailer\SMTP;
    use PHPMailer\PHPMailer\Exception;
    define('PHPMAILER_AVAILABLE', true);
} else {
    // PHPMailer not available, we'll use PHP's mail() function as fallback
    define('PHPMAILER_AVAILABLE', false);
}

/**
 * Send email with attachment using PHPMailer or fallback to mail()
 */
function send_email($to_email, $subject, $body, $attachment_path = null, $attachment_name = null, $pdo, $admin_id) {
    try {
        // Get email settings from database
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
        
        $smtp_host = $settings['smtp_host'] ?? '';
        $smtp_port = $settings['smtp_port'] ?? '587';
        $smtp_username = $settings['smtp_username'] ?? '';
        $smtp_password = $settings['smtp_password'] ?? '';
        $smtp_encryption = $settings['smtp_encryption'] ?? 'tls';
        $hotel_name = $settings['hotel_name'] ?? 'L.P.S.T Hotel';
        
        if (empty($smtp_host) || empty($smtp_username) || empty($smtp_password)) {
            throw new Exception('Email SMTP configuration not found. Please configure email settings.');
        }
        
        // Log email attempt
        $email_log_id = null;
        try {
            $stmt = $pdo->prepare("
                INSERT INTO email_logs (recipient_email, subject, email_type, status, admin_id) 
                VALUES (?, ?, 'EXPORT', 'PENDING', ?)
            ");
            $stmt->execute([$to_email, $subject, $admin_id]);
            $email_log_id = $pdo->lastInsertId();
        } catch (Exception $e) {
            // Continue without logging if email_logs table doesn't exist
            error_log("Email logging failed: " . $e->getMessage());
        }
        
        if (PHPMAILER_AVAILABLE) {
            // Use PHPMailer
            $result = send_email_phpmailer($to_email, $subject, $body, $attachment_path, $attachment_name, $settings, $email_log_id, $pdo);
        } else {
            // Use PHP mail() function as fallback
            $result = send_email_fallback($to_email, $subject, $body, $attachment_path, $attachment_name, $settings, $email_log_id, $pdo);
        }
        
        return $result;
        
    } catch (Exception $e) {
        // Log error
        if (isset($email_log_id)) {
            $stmt = $pdo->prepare("
                UPDATE email_logs 
                SET status = 'FAILED', response_data = ? 
                WHERE id = ?
            ");
            $stmt->execute(['Error: ' . $e->getMessage(), $email_log_id]);
        }
        
        return [
            'success' => false,
            'message' => $e->getMessage()
        ];
    }
}

/**
 * Send email using PHPMailer
 */
function send_email_phpmailer($to_email, $subject, $body, $attachment_path, $attachment_name, $settings, $email_log_id, $pdo) {
    try {
        $mail = new PHPMailer(true);
        
        // Server settings
        $mail->isSMTP();
        $mail->Host = $settings['smtp_host'];
        $mail->SMTPAuth = true;
        $mail->Username = $settings['smtp_username'];
        $mail->Password = $settings['smtp_password'];
        
        // Handle encryption settings
        $smtp_encryption = $settings['smtp_encryption'] ?? 'tls';
        if ($smtp_encryption === 'ssl') {
            $mail->SMTPSecure = PHPMailer::ENCRYPTION_SMTPS;
            $mail->Port = $settings['smtp_port'] ?? 465;
        } elseif ($smtp_encryption === 'tls') {
            $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
            $mail->Port = $settings['smtp_port'] ?? 587;
        } else {
            $mail->SMTPSecure = false;
            $mail->SMTPAuth = true; // Keep auth enabled even without encryption
            $mail->Port = $settings['smtp_port'] ?? 25;
        }
        
        // Additional settings for better compatibility
        $mail->SMTPOptions = array(
            'ssl' => array(
                'verify_peer' => false,
                'verify_peer_name' => false,
                'allow_self_signed' => true
            )
        );
        
        // Set timeout
        $mail->Timeout = 30;
        
        // Recipients
        $hotel_name = $settings['hotel_name'] ?? 'L.P.S.T Hotel';
        $mail->setFrom($settings['smtp_username'], $hotel_name);
        $mail->addAddress($to_email);
        
        // Content
        $mail->isHTML(true);
        $mail->Subject = $subject;
        $mail->Body = $body;
        
        // Add attachment if provided
        if ($attachment_path && file_exists($attachment_path)) {
            $mail->addAttachment($attachment_path, $attachment_name ?: basename($attachment_path));
        }
        
        // Send email
        $mail->send();
        
        // Update email log with success
        if ($email_log_id) {
            try {
                $stmt = $pdo->prepare("
                    UPDATE email_logs 
                    SET status = 'SENT', response_data = 'Email sent successfully via PHPMailer' 
                    WHERE id = ?
                ");
                $stmt->execute([$email_log_id]);
            } catch (Exception $e) {
                // Continue even if logging fails
                error_log("Email log update failed: " . $e->getMessage());
            }
        }
        
        return [
            'success' => true,
            'message' => 'Email sent successfully via PHPMailer'
        ];
        
    } catch (Exception $e) {
        throw new Exception('PHPMailer Error: ' . $e->getMessage());
    }
}

/**
 * Send email using PHP mail() function as fallback
 */
function send_email_fallback($to_email, $subject, $body, $attachment_path, $attachment_name, $settings, $email_log_id, $pdo) {
    try {
        $hotel_name = $settings['hotel_name'] ?? 'L.P.S.T Hotel';
        $from_email = $settings['smtp_username'] ?? 'noreply@lpsthotel.com';
        
        // Headers
        $headers = "MIME-Version: 1.0\r\n";
        $headers .= "From: $hotel_name <$from_email>\r\n";
        $headers .= "Reply-To: $from_email\r\n";
        $headers .= "X-Mailer: PHP/" . phpversion() . "\r\n";
        
        if ($attachment_path && file_exists($attachment_path)) {
            // Email with attachment
            $boundary = md5(time());
            $headers .= "Content-Type: multipart/mixed; boundary=\"$boundary\"\r\n";
            
            $message = "--$boundary\r\n";
            $message .= "Content-Type: text/html; charset=UTF-8\r\n";
            $message .= "Content-Transfer-Encoding: 7bit\r\n\r\n";
            $message .= $body . "\r\n";
            
            // Attachment
            if (is_readable($attachment_path)) {
                $file_content = chunk_split(base64_encode(file_get_contents($attachment_path)));
                $message .= "--$boundary\r\n";
                $message .= "Content-Type: application/octet-stream; name=\"" . ($attachment_name ?: basename($attachment_path)) . "\"\r\n";
                $message .= "Content-Transfer-Encoding: base64\r\n";
                $message .= "Content-Disposition: attachment; filename=\"" . ($attachment_name ?: basename($attachment_path)) . "\"\r\n\r\n";
                $message .= $file_content . "\r\n";
                $message .= "--$boundary--\r\n";
            } else {
                // Skip attachment if not readable
                $message .= "--$boundary--\r\n";
            }
        } else {
            // Simple HTML email
            $headers .= "Content-Type: text/html; charset=UTF-8\r\n";
            $message = $body;
        }
        
        // Send email
        $result = mail($to_email, $subject, $message, $headers);
        
        if ($result) {
            // Update email log with success
            if ($email_log_id) {
                try {
                    $stmt = $pdo->prepare("
                        UPDATE email_logs 
                        SET status = 'SENT', response_data = 'Email sent successfully via PHP mail()' 
                        WHERE id = ?
                    ");
                    $stmt->execute([$email_log_id]);
                } catch (Exception $e) {
                    // Continue even if logging fails
                    error_log("Email log update failed: " . $e->getMessage());
                }
            }
            
            return [
                'success' => true,
                'message' => 'Email sent successfully via PHP mail() function'
            ];
        } else {
            throw new Exception('PHP mail() function failed to send email');
        }
        
    } catch (Exception $e) {
        throw new Exception('Mail Function Error: ' . $e->getMessage());
    }
}

/**
 * Generate CSV export file
 */
function generate_csv_export($bookings, $filename) {
    $csv_path = 'exports/' . $filename;
    
    // Create exports directory if it doesn't exist
    if (!is_dir('exports')) {
        mkdir('exports', 0755, true);
    }
    
    $output = fopen($csv_path, 'w');
    
    // CSV headers
    fputcsv($output, [
        'ID', 'Resource', 'Type', 'Client Name', 'Mobile', 'Aadhar', 'License', 
        'Receipt No', 'Payment Mode', 'Check-in', 'Check-out', 'Status', 
        'Paid', 'Amount', 'Admin', 'Created', 'Booking Type', 'Advance Date'
    ]);
    
    // CSV data
    foreach ($bookings as $booking) {
        fputcsv($output, [
            $booking['id'],
            $booking['resource_name'] ?: $booking['display_name'],
            $booking['type'],
            $booking['client_name'],
            $booking['client_mobile'],
            $booking['client_aadhar'] ?: '',
            $booking['client_license'] ?: '',
            $booking['receipt_number'],
            $booking['payment_mode'],
            $booking['check_in'],
            $booking['check_out'],
            $booking['status'],
            $booking['is_paid'] ? 'Yes' : 'No',
            $booking['total_amount'],
            $booking['admin_name'],
            $booking['created_at'],
            $booking['booking_type'],
            $booking['advance_date'] ?: ''
        ]);
    }
    
    fclose($output);
    return $csv_path;
}

/**
 * Generate HTML email body for export
 */
function generate_export_email_body($export_type, $date_range, $total_bookings, $total_revenue) {
    $hotel_name = 'L.P.S.T Hotel'; // You can get this from settings
    
    return "
    <html>
    <head>
        <style>
            body { font-family: Arial, sans-serif; }
            .header { background: #2563eb; color: white; padding: 20px; text-align: center; }
            .content { padding: 20px; }
            .stats { background: #f8f9fa; padding: 15px; border-radius: 5px; margin: 15px 0; }
            .footer { background: #6c757d; color: white; padding: 10px; text-align: center; font-size: 12px; }
        </style>
    </head>
    <body>
        <div class='header'>
            <h2>{$hotel_name}</h2>
            <h3>Booking Export Report</h3>
        </div>
        
        <div class='content'>
            <p>Dear Owner,</p>
            
            <p>Please find attached the booking export report as requested.</p>
            
            <div class='stats'>
                <h4>Export Summary:</h4>
                <ul>
                    <li><strong>Export Type:</strong> {$export_type}</li>
                    <li><strong>Date Range:</strong> {$date_range}</li>
                    <li><strong>Total Bookings:</strong> {$total_bookings}</li>
                    <li><strong>Total Revenue:</strong> ₹" . number_format($total_revenue, 2) . "</li>
                    <li><strong>Generated On:</strong> " . date('d-M-Y H:i:s') . "</li>
                </ul>
            </div>
            
            <p>The attached CSV file contains detailed information about all bookings including:</p>
            <ul>
                <li>Guest information (Name, Mobile, ID proof)</li>
                <li>Booking details (Check-in/out, Status, Payment)</li>
                <li>Admin information</li>
                <li>Receipt numbers and payment modes</li>
            </ul>
            
            <p>Thank you for using L.P.S.T Bookings System.</p>
            
            <p>Best regards,<br>
            L.P.S.T Bookings System</p>
        </div>
        
        <div class='footer'>
            This is an automated email from L.P.S.T Bookings System. Please do not reply to this email.
        </div>
    </body>
    </html>
    ";
}

/**
 * Send export email with CSV attachment
 */
function send_export_email($to_email, $bookings, $filters, $pdo, $admin_id) {
    try {
        // Generate CSV file
        $filename = 'lpst_bookings_export_' . date('Y-m-d_H-i-s') . '.csv';
        $csv_path = generate_csv_export($bookings, $filename);
        
        // Calculate stats
        $total_bookings = count($bookings);
        $total_revenue = array_sum(array_column($bookings, 'total_amount'));
        
        // Generate email content
        $date_range = ($filters['start_date'] ?? 'All') . ' to ' . ($filters['end_date'] ?? 'All');
        $export_type = 'Booking Records';
        
        $subject = 'L.P.S.T Hotel - Booking Export Report - ' . date('d-M-Y');
        $body = generate_export_email_body($export_type, $date_range, $total_bookings, $total_revenue);
        
        // Send email
        $result = send_email($to_email, $subject, $body, $csv_path, $filename, $pdo, $admin_id);
        
        // Clean up temporary file
        if (file_exists($csv_path)) {
            unlink($csv_path);
        }
        
        return $result;
        
    } catch (Exception $e) {
        return [
            'success' => false,
            'message' => $e->getMessage()
        ];
    }
}

/**
 * Test email configuration
 */
function test_email_configuration($test_email, $pdo, $admin_id) {
    try {
        // Validate email first
        if (!filter_var($test_email, FILTER_VALIDATE_EMAIL)) {
            throw new Exception('Invalid email address format');
        }
        
        // Get current settings to validate configuration
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
        
        // Check if required settings exist
        if (empty($settings['smtp_host']) || empty($settings['smtp_username']) || empty($settings['smtp_password'])) {
            throw new Exception('SMTP configuration is incomplete. Please configure all required settings first.');
        }
        
    } catch (Exception $e) {
        return [
            'success' => false,
            'message' => $e->getMessage()
        ];
    }
    
    $subject = 'L.P.S.T Bookings - Email Configuration Test';
    $body = "
    <html>
    <head>
        <style>
            body { font-family: Arial, sans-serif; padding: 20px; }
            .header { background: #2563eb; color: white; padding: 15px; border-radius: 5px; text-align: center; }
            .content { padding: 20px; background: #f8f9fa; border-radius: 5px; margin: 15px 0; }
            .success { color: #28a745; font-weight: bold; }
        </style>
    </head>
    <body>
        <div class='header'>
            <h3>🎉 Email Configuration Test Successful!</h3>
        </div>
        <div class='content'>
            <p class='success'>✅ Congratulations! Your email configuration is working correctly.</p>
            <p><strong>Test Details:</strong></p>
            <ul>
                <li>Test sent on: " . date('d-M-Y H:i:s') . "</li>
                <li>System: L.P.S.T Bookings</li>
                <li>Status: Email delivery successful</li>
            </ul>
            <p>You can now use the email export feature to send booking reports.</p>
        </div>
        <div style='text-align: center; color: #6c757d; font-size: 12px; margin-top: 20px;'>
            This is an automated test email from L.P.S.T Bookings System.
        </div>
    </body>
    </html>
    ";
    
    return send_email($test_email, $subject, $body, null, null, $pdo, $admin_id);
}
?>