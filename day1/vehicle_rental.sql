CREATE DATABASE rental_db;
USE rental_db;
CREATE TABLE vehicle_types (
    vehicle_type_id INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL,
    daily_rate DECIMAL(10, 2) NOT NULL -- Daily rental rate for this vehicle type
);
CREATE TABLE vehicles (
    vehicle_id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_type_id INT,
    license_plate VARCHAR(15) UNIQUE NOT NULL,
    make VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    year INT NOT NULL,
    FOREIGN KEY (vehicle_type_id) REFERENCES vehicle_types(vehicle_type_id)
);
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(15)
);
CREATE TABLE rentals (
    rental_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    vehicle_id INT,
    rental_start DATETIME NOT NULL,
    rental_end DATETIME NOT NULL,
    total_cost DECIMAL(10, 2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id)
);
INSERT INTO vehicle_types (type_name, daily_rate) VALUES
('Sedan', 50.00),
('SUV', 80.00),
('Truck', 100.00),
('Convertible', 120.00),
('Minivan', 70.00);
