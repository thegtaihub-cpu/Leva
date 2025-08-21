-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Aug 21, 2025 at 05:31 AM
-- Server version: 10.11.10-MariaDB-log
-- PHP Version: 7.2.34

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `u261459251_software`
--

-- --------------------------------------------------------

--
-- Stand-in structure for view `admin_activity`
-- (See below for the actual view)
--
CREATE TABLE `admin_activity` (
`admin_id` int(11)
,`admin_name` varchar(50)
,`total_bookings` bigint(21)
,`active_bookings` bigint(21)
,`completed_bookings` bigint(21)
,`advance_bookings` bigint(21)
,`total_revenue` decimal(32,2)
,`last_booking_date` timestamp
);

-- --------------------------------------------------------

--
-- Table structure for table `bookings`
--

CREATE TABLE `bookings` (
  `id` int(11) NOT NULL,
  `resource_id` int(11) NOT NULL,
  `client_name` varchar(255) NOT NULL,
  `client_mobile` varchar(15) NOT NULL,
  `client_aadhar` varchar(20) DEFAULT NULL,
  `client_license` varchar(20) DEFAULT NULL,
  `receipt_number` varchar(100) DEFAULT NULL,
  `payment_mode` enum('ONLINE','OFFLINE') DEFAULT 'OFFLINE',
  `check_in` datetime NOT NULL,
  `check_out` datetime NOT NULL,
  `actual_check_in` datetime DEFAULT NULL,
  `actual_check_out` datetime DEFAULT NULL,
  `status` enum('BOOKED','PENDING','COMPLETED','ADVANCED_BOOKED','PAID') DEFAULT 'BOOKED',
  `booking_type` enum('regular','advanced') DEFAULT 'regular',
  `advance_date` date DEFAULT NULL,
  `advance_payment_mode` enum('ONLINE','OFFLINE') DEFAULT NULL,
  `admin_id` int(11) NOT NULL,
  `is_paid` tinyint(1) DEFAULT 0,
  `total_amount` decimal(10,2) DEFAULT 0.00,
  `payment_notes` text DEFAULT NULL,
  `duration_minutes` int(11) DEFAULT 0,
  `sms_sent` tinyint(1) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `bookings`
--

INSERT INTO `bookings` (`id`, `resource_id`, `client_name`, `client_mobile`, `client_aadhar`, `client_license`, `receipt_number`, `payment_mode`, `check_in`, `check_out`, `actual_check_in`, `actual_check_out`, `status`, `booking_type`, `advance_date`, `advance_payment_mode`, `admin_id`, `is_paid`, `total_amount`, `payment_notes`, `duration_minutes`, `sms_sent`, `created_at`, `updated_at`) VALUES
(1, 1, 'vishal', '9765834383', '689265983323', NULL, '1234', 'OFFLINE', '2025-08-21 10:24:00', '2025-08-22 10:10:00', '2025-08-21 04:48:16', '2025-08-21 05:03:04', 'PAID', 'regular', NULL, NULL, 3, 1, 0.00, NULL, 0, 0, '2025-08-21 04:48:16', '2025-08-21 05:03:04'),
(2, 7, 'Raj', '9765834383', NULL, NULL, '132', 'OFFLINE', '2025-08-22 12:00:00', '2025-08-22 12:00:00', NULL, NULL, 'ADVANCED_BOOKED', 'advanced', '2025-08-22', 'OFFLINE', 3, 0, 0.00, NULL, 0, 0, '2025-08-21 04:49:31', '2025-08-21 04:49:31'),
(3, 2, 'shivaji', '7767834383', '968599888899', 'MH15568565', '7898', 'ONLINE', '2025-08-21 04:57:00', '2025-08-22 04:57:00', '2025-08-21 04:58:44', '2025-08-21 04:59:23', 'PAID', 'regular', NULL, NULL, 3, 1, 0.00, NULL, 0, 0, '2025-08-21 04:58:44', '2025-08-21 04:59:23'),
(4, 1, 'MAYUR', '9860500330', NULL, NULL, NULL, 'OFFLINE', '2025-08-21 05:05:00', '2025-08-22 05:05:00', '2025-08-21 05:07:10', '2025-08-21 05:14:14', 'COMPLETED', 'regular', NULL, NULL, 2, 0, 0.00, NULL, 7, 0, '2025-08-21 05:07:10', '2025-08-21 05:14:14');

-- --------------------------------------------------------

--
-- Table structure for table `booking_cancellations`
--

CREATE TABLE `booking_cancellations` (
  `id` int(11) NOT NULL,
  `booking_id` int(11) NOT NULL,
  `resource_id` int(11) NOT NULL,
  `cancelled_by` int(11) NOT NULL,
  `cancellation_reason` text DEFAULT NULL,
  `original_client_name` varchar(255) DEFAULT NULL,
  `original_client_mobile` varchar(15) DEFAULT NULL,
  `original_advance_date` date DEFAULT NULL,
  `duration_at_cancellation` int(11) DEFAULT 0,
  `cancelled_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Stand-in structure for view `booking_summary`
-- (See below for the actual view)
--
CREATE TABLE `booking_summary` (
`id` int(11)
,`client_name` varchar(255)
,`client_mobile` varchar(15)
,`client_aadhar` varchar(20)
,`client_license` varchar(20)
,`receipt_number` varchar(100)
,`payment_mode` enum('ONLINE','OFFLINE')
,`resource_name` varchar(100)
,`resource_custom_name` varchar(100)
,`resource_type` enum('room','hall')
,`check_in` datetime
,`check_out` datetime
,`status` enum('BOOKED','PENDING','COMPLETED','ADVANCED_BOOKED','PAID')
,`booking_type` enum('regular','advanced')
,`advance_date` date
,`advance_payment_mode` enum('ONLINE','OFFLINE')
,`total_amount` decimal(10,2)
,`is_paid` tinyint(1)
,`admin_name` varchar(50)
,`created_at` timestamp
);

-- --------------------------------------------------------

--
-- Table structure for table `email_logs`
--

CREATE TABLE `email_logs` (
  `id` int(11) NOT NULL,
  `recipient_email` varchar(255) NOT NULL,
  `subject` varchar(255) NOT NULL,
  `email_type` enum('EXPORT','REPORT','NOTIFICATION') NOT NULL,
  `status` enum('SENT','FAILED','PENDING') DEFAULT 'PENDING',
  `response_data` text DEFAULT NULL,
  `admin_id` int(11) NOT NULL,
  `sent_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `payments`
--

CREATE TABLE `payments` (
  `id` int(11) NOT NULL,
  `booking_id` int(11) DEFAULT NULL,
  `resource_id` int(11) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `payment_method` varchar(50) DEFAULT 'UPI',
  `payment_status` enum('PENDING','COMPLETED','FAILED') DEFAULT 'PENDING',
  `upi_transaction_id` varchar(100) DEFAULT NULL,
  `payment_notes` text DEFAULT NULL,
  `admin_id` int(11) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `payments`
--

INSERT INTO `payments` (`id`, `booking_id`, `resource_id`, `amount`, `payment_method`, `payment_status`, `upi_transaction_id`, `payment_notes`, `admin_id`, `created_at`) VALUES
(1, 3, 2, 500.00, 'CHECKOUT', 'COMPLETED', NULL, 'Checkout payment for A103 - Duration: 0h 2m', 3, '2025-08-21 04:59:23'),
(2, NULL, 3, 500.00, 'UPI', 'PENDING', NULL, NULL, 3, '2025-08-21 05:01:45'),
(3, NULL, 3, 500.00, 'MANUAL', 'COMPLETED', NULL, 'Manual payment for A104', 3, '2025-08-21 05:01:53'),
(4, 1, 1, 500.00, 'CHECKOUT', 'COMPLETED', NULL, 'Checkout payment for A102 - Duration: 5h 20m', 3, '2025-08-21 05:03:04'),
(5, 4, 1, 500.00, 'CHECKOUT_COMPLETE', 'COMPLETED', NULL, 'Checkout completed for A102 - Duration: 0h 9m', 3, '2025-08-21 05:14:14'),
(6, NULL, 3, 900.00, 'UPI', 'PENDING', NULL, NULL, 3, '2025-08-21 05:17:36');

-- --------------------------------------------------------

--
-- Table structure for table `resources`
--

CREATE TABLE `resources` (
  `id` int(11) NOT NULL,
  `type` enum('room','hall') NOT NULL,
  `identifier` varchar(50) NOT NULL,
  `display_name` varchar(100) NOT NULL,
  `custom_name` varchar(100) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `resources`
--

INSERT INTO `resources` (`id`, `type`, `identifier`, `display_name`, `custom_name`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'room', '1', 'ROOM NO 1', 'A102', 1, '2025-08-21 04:24:42', '2025-08-21 04:42:05'),
(2, 'room', '2', 'ROOM NO 2', 'A103', 1, '2025-08-21 04:24:42', '2025-08-21 04:42:13'),
(3, 'room', '3', 'ROOM NO 3', 'A104', 1, '2025-08-21 04:24:42', '2025-08-21 04:43:58'),
(4, 'room', '4', 'ROOM NO 4', 'A105', 1, '2025-08-21 04:24:42', '2025-08-21 04:44:06'),
(5, 'room', '5', 'ROOM NO 5', 'A106', 1, '2025-08-21 04:24:42', '2025-08-21 04:44:10'),
(6, 'room', '6', 'ROOM NO 6', 'A107', 1, '2025-08-21 04:24:42', '2025-08-21 04:44:14'),
(7, 'room', '7', 'ROOM NO 7', 'A108', 1, '2025-08-21 04:24:42', '2025-08-21 04:44:17'),
(8, 'room', '8', 'ROOM NO 8', 'A201', 1, '2025-08-21 04:24:42', '2025-08-21 04:44:31'),
(9, 'room', '9', 'ROOM NO 9', 'A202', 1, '2025-08-21 04:24:42', '2025-08-21 04:44:35'),
(10, 'room', '10', 'ROOM NO 10', 'A203', 1, '2025-08-21 04:24:42', '2025-08-21 04:44:39'),
(11, 'room', '11', 'ROOM NO 11', 'A204', 1, '2025-08-21 04:24:42', '2025-08-21 04:44:43'),
(12, 'room', '12', 'ROOM NO 12', 'A205', 1, '2025-08-21 04:24:42', '2025-08-21 04:44:48'),
(13, 'room', '13', 'ROOM NO 13', 'A206', 1, '2025-08-21 04:24:42', '2025-08-21 04:44:53'),
(14, 'room', '14', 'ROOM NO 14', 'A207', 1, '2025-08-21 04:24:42', '2025-08-21 04:44:58'),
(15, 'room', '15', 'ROOM NO 15', 'A208', 1, '2025-08-21 04:24:42', '2025-08-21 04:45:02'),
(16, 'room', '16', 'ROOM NO 16', 'A209', 1, '2025-08-21 04:24:42', '2025-08-21 04:45:08'),
(17, 'room', '17', 'ROOM NO 17', 'A210', 1, '2025-08-21 04:24:42', '2025-08-21 04:45:17'),
(18, 'room', '18', 'ROOM NO 18', 'B101', 1, '2025-08-21 04:24:42', '2025-08-21 04:45:27'),
(19, 'room', '19', 'ROOM NO 19', 'B102', 1, '2025-08-21 04:24:42', '2025-08-21 04:45:33'),
(20, 'room', '20', 'ROOM NO 20', 'B103', 1, '2025-08-21 04:24:42', '2025-08-21 04:45:42'),
(21, 'room', '21', 'ROOM NO 21', 'B201', 1, '2025-08-21 04:24:42', '2025-08-21 04:45:51'),
(22, 'room', '22', 'ROOM NO 22', 'B202', 1, '2025-08-21 04:24:42', '2025-08-21 04:46:00'),
(23, 'room', '23', 'ROOM NO 23', 'B203', 1, '2025-08-21 04:24:42', '2025-08-21 04:46:07'),
(24, 'room', '24', 'ROOM NO 24', 'B001', 1, '2025-08-21 04:24:42', '2025-08-21 04:46:15'),
(25, 'room', '25', 'ROOM NO 25', 'B002', 1, '2025-08-21 04:24:42', '2025-08-21 04:46:22'),
(26, 'room', '26', 'ROOM NO 26', 'B003', 1, '2025-08-21 04:24:42', '2025-08-21 04:46:33'),
(27, 'hall', 'SMALL_PARTY_HALL', 'SMALL PARTY HALL', 'LARGE HALL', 1, '2025-08-21 04:24:42', '2025-08-21 04:46:54'),
(28, 'hall', 'BIG_PARTY_HALL', 'BIG PARTY HALL', 'SMALL HALL', 1, '2025-08-21 04:24:42', '2025-08-21 04:46:43');

-- --------------------------------------------------------

--
-- Table structure for table `settings`
--

CREATE TABLE `settings` (
  `id` int(11) NOT NULL,
  `setting_key` varchar(100) NOT NULL,
  `setting_value` text DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `settings`
--

INSERT INTO `settings` (`id`, `setting_key`, `setting_value`, `updated_by`, `updated_at`) VALUES
(1, 'upi_id', 'vishrajrathod@kotak', 1, '2025-08-21 05:17:25'),
(2, 'upi_name', 'L.P.S.T Bookings', 1, '2025-08-21 05:17:25'),
(3, 'hotel_name', 'L.P.S.T Hotel', 1, '2025-08-21 05:16:14'),
(4, 'sms_api_url', 'https://api.textlocal.in/send/', 1, '2025-08-21 05:16:14'),
(5, 'sms_api_key', 'YOUR_SMS_API_KEY_HERE', 1, '2025-08-21 05:16:14'),
(6, 'sms_sender_id', 'LPSTHT', 1, '2025-08-21 05:16:14'),
(7, 'smtp_host', 'smtp.hostinger.com', 1, '2025-08-21 05:06:15'),
(8, 'smtp_port', '465', 1, '2025-08-21 05:06:15'),
(9, 'smtp_username', 'info@gtai.in', 1, '2025-08-21 05:06:15'),
(10, 'smtp_password', 'Vishraj@9884', 1, '2025-08-21 05:06:15'),
(11, 'smtp_encryption', 'tls', 1, '2025-08-21 05:06:15'),
(12, 'owner_email', 'owner@lpsthotel.com', 1, '2025-08-21 05:06:15'),
(13, 'system_timezone', 'Asia/Kolkata', NULL, '2025-08-21 04:24:42'),
(14, 'auto_refresh_interval', '30', NULL, '2025-08-21 04:24:42'),
(15, 'checkout_grace_hours', '24', NULL, '2025-08-21 04:24:42'),
(16, 'default_room_rate', '1000.00', NULL, '2025-08-21 04:24:42'),
(17, 'default_hall_rate', '5000.00', NULL, '2025-08-21 04:24:42'),
(19, 'qr_image', '', NULL, '2025-08-21 04:30:15');

-- --------------------------------------------------------

--
-- Table structure for table `sms_logs`
--

CREATE TABLE `sms_logs` (
  `id` int(11) NOT NULL,
  `booking_id` int(11) NOT NULL,
  `mobile_number` varchar(15) NOT NULL,
  `message` text NOT NULL,
  `sms_type` enum('BOOKING','CHECKOUT','CANCELLATION','ADVANCE') NOT NULL,
  `status` enum('SENT','FAILED','PENDING') DEFAULT 'PENDING',
  `response_data` text DEFAULT NULL,
  `admin_id` int(11) NOT NULL,
  `sent_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `sms_logs`
--

INSERT INTO `sms_logs` (`id`, `booking_id`, `mobile_number`, `message`, `sms_type`, `status`, `response_data`, `admin_id`, `sent_at`) VALUES
(1, 1, '9765834383', 'Dear vishal, your room A102 booked successfully at 21-Aug-2025 10:24 at L.P.S.T Hotel. Thank you!', 'BOOKING', 'FAILED', '{\"errors\":[{\"code\":3,\"message\":\"Invalid login details\"}],\"status\":\"failure\"}', 3, '2025-08-21 04:48:16'),
(2, 2, '9765834383', 'Dear Raj, your advance booking for A108 on 22-Aug-2025 at L.P.S.T Hotel confirmed. Thank you!', 'ADVANCE', 'FAILED', '{\"errors\":[{\"code\":3,\"message\":\"Invalid login details\"}],\"status\":\"failure\"}', 3, '2025-08-21 04:49:31'),
(3, 3, '7767834383', 'Dear shivaji, your room A103 booked successfully at 21-Aug-2025 04:57 at L.P.S.T Hotel. Thank you!', 'BOOKING', 'FAILED', '{\"errors\":[{\"code\":3,\"message\":\"Invalid login details\"}],\"status\":\"failure\"}', 3, '2025-08-21 04:58:44'),
(4, 3, '7767834383', 'Dear shivaji, checkout from A103 completed at L.P.S.T Hotel. Thank you for your visit! Please visit again.', 'CHECKOUT', 'FAILED', '{\"errors\":[{\"code\":3,\"message\":\"Invalid login details\"}],\"status\":\"failure\"}', 3, '2025-08-21 04:59:23'),
(5, 1, '9765834383', 'Dear vishal, checkout from A102 completed at L.P.S.T Hotel. Thank you for your visit! Please visit again.', 'CHECKOUT', 'FAILED', '{\"errors\":[{\"code\":3,\"message\":\"Invalid login details\"}],\"status\":\"failure\"}', 3, '2025-08-21 05:03:04'),
(6, 4, '9860500330', 'Dear MAYUR, your room A102 booked successfully at 21-Aug-2025 05:05 at L.P.S.T Hotel. Thank you!', 'BOOKING', 'FAILED', '{\"errors\":[{\"code\":3,\"message\":\"Invalid login details\"}],\"status\":\"failure\"}', 2, '2025-08-21 05:07:10'),
(7, 4, '9860500330', 'Dear MAYUR, checkout from A102 completed at L.P.S.T Hotel. Thank you for your visit! Please visit again.', 'CHECKOUT', 'FAILED', '{\"errors\":[{\"code\":3,\"message\":\"Invalid login details\"}],\"status\":\"failure\"}', 2, '2025-08-21 05:14:14');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('OWNER','ADMIN') NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `password`, `role`, `created_at`, `updated_at`) VALUES
(1, 'owner', '$2y$10$cGb5zSziSATjboGnZDyGxuOPx/AgImgSGnatdAnz29seZuBUvleyq', 'OWNER', '2025-08-21 04:24:42', '2025-08-21 04:35:14'),
(2, 'mayur', '$2y$10$XjkpdHRcaxxPJQoSVdhz1.SaP/ha3ELyOM4lbjYT3orAWmLeqUYGu', 'ADMIN', '2025-08-21 04:24:42', '2025-08-21 04:36:49'),
(3, 'raj', '$2y$10$06/SKVSQpg/bUwQMqsog/.oq4ZBsatlUTAh6VRSISZA97kUUnC91C', 'ADMIN', '2025-08-21 04:24:42', '2025-08-21 04:37:57'),
(4, 'admin3', '$2y$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/lewdBxGkgaHqz3nO6', 'ADMIN', '2025-08-21 04:24:42', '2025-08-21 04:24:42'),
(5, 'admin4', '$2y$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/lewdBxGkgaHqz3nO6', 'ADMIN', '2025-08-21 04:24:42', '2025-08-21 04:24:42'),
(6, 'admin5', '$2y$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/lewdBxGkgaHqz3nO6', 'ADMIN', '2025-08-21 04:24:42', '2025-08-21 04:24:42'),
(7, 'admin6', '$2y$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/lewdBxGkgaHqz3nO6', 'ADMIN', '2025-08-21 04:24:42', '2025-08-21 04:24:42');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `bookings`
--
ALTER TABLE `bookings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_bookings_resource_status` (`resource_id`,`status`),
  ADD KEY `idx_bookings_advance_date` (`advance_date`),
  ADD KEY `idx_bookings_admin` (`admin_id`),
  ADD KEY `idx_bookings_mobile` (`client_mobile`);

--
-- Indexes for table `booking_cancellations`
--
ALTER TABLE `booking_cancellations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `booking_id` (`booking_id`),
  ADD KEY `resource_id` (`resource_id`),
  ADD KEY `cancelled_by` (`cancelled_by`);

--
-- Indexes for table `email_logs`
--
ALTER TABLE `email_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_email_logs_admin` (`admin_id`);

--
-- Indexes for table `payments`
--
ALTER TABLE `payments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `booking_id` (`booking_id`),
  ADD KEY `admin_id` (`admin_id`),
  ADD KEY `idx_payments_resource` (`resource_id`);

--
-- Indexes for table `resources`
--
ALTER TABLE `resources`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_resource` (`type`,`identifier`),
  ADD KEY `idx_resources_active` (`is_active`);

--
-- Indexes for table `settings`
--
ALTER TABLE `settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `setting_key` (`setting_key`),
  ADD KEY `updated_by` (`updated_by`);

--
-- Indexes for table `sms_logs`
--
ALTER TABLE `sms_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `admin_id` (`admin_id`),
  ADD KEY `idx_sms_logs_booking` (`booking_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `bookings`
--
ALTER TABLE `bookings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `booking_cancellations`
--
ALTER TABLE `booking_cancellations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `email_logs`
--
ALTER TABLE `email_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `payments`
--
ALTER TABLE `payments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `resources`
--
ALTER TABLE `resources`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=57;

--
-- AUTO_INCREMENT for table `settings`
--
ALTER TABLE `settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- AUTO_INCREMENT for table `sms_logs`
--
ALTER TABLE `sms_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

-- --------------------------------------------------------

--
-- Structure for view `admin_activity`
--
DROP TABLE IF EXISTS `admin_activity`;

CREATE ALGORITHM=UNDEFINED DEFINER=`u261459251_hotel`@`127.0.0.1` SQL SECURITY DEFINER VIEW `admin_activity`  AS SELECT `u`.`id` AS `admin_id`, `u`.`username` AS `admin_name`, count(`b`.`id`) AS `total_bookings`, count(case when `b`.`status` = 'BOOKED' then 1 end) AS `active_bookings`, count(case when `b`.`status` = 'COMPLETED' then 1 end) AS `completed_bookings`, count(case when `b`.`booking_type` = 'advanced' then 1 end) AS `advance_bookings`, sum(case when `b`.`is_paid` = 1 then `b`.`total_amount` else 0 end) AS `total_revenue`, max(`b`.`created_at`) AS `last_booking_date` FROM (`users` `u` left join `bookings` `b` on(`u`.`id` = `b`.`admin_id`)) WHERE `u`.`role` = 'ADMIN' GROUP BY `u`.`id`, `u`.`username` ;

-- --------------------------------------------------------

--
-- Structure for view `booking_summary`
--
DROP TABLE IF EXISTS `booking_summary`;

CREATE ALGORITHM=UNDEFINED DEFINER=`u261459251_hotel`@`127.0.0.1` SQL SECURITY DEFINER VIEW `booking_summary`  AS SELECT `b`.`id` AS `id`, `b`.`client_name` AS `client_name`, `b`.`client_mobile` AS `client_mobile`, `b`.`client_aadhar` AS `client_aadhar`, `b`.`client_license` AS `client_license`, `b`.`receipt_number` AS `receipt_number`, `b`.`payment_mode` AS `payment_mode`, `r`.`display_name` AS `resource_name`, `r`.`custom_name` AS `resource_custom_name`, `r`.`type` AS `resource_type`, `b`.`check_in` AS `check_in`, `b`.`check_out` AS `check_out`, `b`.`status` AS `status`, `b`.`booking_type` AS `booking_type`, `b`.`advance_date` AS `advance_date`, `b`.`advance_payment_mode` AS `advance_payment_mode`, `b`.`total_amount` AS `total_amount`, `b`.`is_paid` AS `is_paid`, `u`.`username` AS `admin_name`, `b`.`created_at` AS `created_at` FROM ((`bookings` `b` join `resources` `r` on(`b`.`resource_id` = `r`.`id`)) join `users` `u` on(`b`.`admin_id` = `u`.`id`)) ;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `bookings`
--
ALTER TABLE `bookings`
  ADD CONSTRAINT `bookings_ibfk_1` FOREIGN KEY (`resource_id`) REFERENCES `resources` (`id`),
  ADD CONSTRAINT `bookings_ibfk_2` FOREIGN KEY (`admin_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `booking_cancellations`
--
ALTER TABLE `booking_cancellations`
  ADD CONSTRAINT `booking_cancellations_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`),
  ADD CONSTRAINT `booking_cancellations_ibfk_2` FOREIGN KEY (`resource_id`) REFERENCES `resources` (`id`),
  ADD CONSTRAINT `booking_cancellations_ibfk_3` FOREIGN KEY (`cancelled_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `email_logs`
--
ALTER TABLE `email_logs`
  ADD CONSTRAINT `email_logs_ibfk_1` FOREIGN KEY (`admin_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `payments`
--
ALTER TABLE `payments`
  ADD CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`),
  ADD CONSTRAINT `payments_ibfk_2` FOREIGN KEY (`resource_id`) REFERENCES `resources` (`id`),
  ADD CONSTRAINT `payments_ibfk_3` FOREIGN KEY (`admin_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `settings`
--
ALTER TABLE `settings`
  ADD CONSTRAINT `settings_ibfk_1` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `sms_logs`
--
ALTER TABLE `sms_logs`
  ADD CONSTRAINT `sms_logs_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`),
  ADD CONSTRAINT `sms_logs_ibfk_2` FOREIGN KEY (`admin_id`) REFERENCES `users` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
