-- Enviora Database Schema
-- Last updated: 2026-03-15

-- 1. Create Database
CREATE DATABASE IF NOT EXISTS enviora_db;
USE enviora_db;

-- 2. Users Table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    points INT DEFAULT 0,
    language_preference VARCHAR(10) DEFAULT 'en',
    reset_otp VARCHAR(10),
    reset_otp_expires TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Activities Table (History)
CREATE TABLE IF NOT EXISTS activities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    action_type VARCHAR(255) NOT NULL,
    points_earned INT NOT NULL,
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 4. Notifications Table
CREATE TABLE IF NOT EXISTS notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 5. Reports Table data (Complaints reports)
CREATE TABLE IF NOT EXISTS reports (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    report_type VARCHAR(50) NOT NULL, -- missed_collection, illegal_dumping, etc.
    issue_type VARCHAR(255) NOT NULL,
    details TEXT,
    image_path VARCHAR(255),
    status VARCHAR(50) DEFAULT 'Pending', -- Pending, In Progress, Resolved
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 6. Seed Default User (G.G.K.Ranudaya)
-- Using INSERT IGNORE to prevent errors if already exists
INSERT IGNORE INTO users (id, name, email, password, points, language_preference)
VALUES (1, 'G.G.K.Ranudaya', 'ggkranudaya@gmail.com', 'demo123', 1000, 'en');

-- 7. Seed Sample Data
INSERT IGNORE INTO activities (user_id, action_type, points_earned)
VALUES 
(1, 'Illegal Dumping Reported', 50),
(1, 'Recycling Collection', 20);

INSERT IGNORE INTO notifications (user_id, message)
VALUES 
(1, 'Your report #EV-7740 has been updated to In Progress.'),
(1, 'Next garbage collection in your area is tomorrow.');
