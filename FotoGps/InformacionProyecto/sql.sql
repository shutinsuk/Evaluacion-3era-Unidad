CREATE DATABASE IF NOT EXISTS delivery_app;
USE delivery_app;

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    hashed_password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    is_active TINYINT(1) DEFAULT 1
);

CREATE TABLE IF NOT EXISTS packages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tracking_number VARCHAR(50) NOT NULL,
    address TEXT NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    assigned_to INT,
    status VARCHAR(20) DEFAULT 'pending',
    FOREIGN KEY (assigned_to) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS deliveries (
    id INT AUTO_INCREMENT PRIMARY KEY,
    package_id INT NOT NULL,
    delivered_by INT NOT NULL,
    delivered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    photo_path VARCHAR(255),
    gps_latitude DECIMAL(10, 8),
    gps_longitude DECIMAL(11, 8),
    FOREIGN KEY (package_id) REFERENCES packages(id),
    FOREIGN KEY (delivered_by) REFERENCES users(id)
);

-- User: agent1 / Password: secret
INSERT INTO users (username, hashed_password, full_name, is_active) VALUES 
('agent1', '$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', 'Agente Uno', 1);

INSERT INTO packages (tracking_number, address, latitude, longitude, assigned_to, status) VALUES 
('TRK-001', 'Av. Reforma 123, Ciudad de México', 19.432608, -99.133209, 1, 'pending'),
('TRK-002', 'Calle 5 de Mayo 45, Puebla', 19.0414, -98.2063, 1, 'pending'),
('TRK-003', 'Insurgentes Sur 100, CDMX', 19.4200, -99.1600, 1, 'pending');
