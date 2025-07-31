CREATE DATABASE medical_store_db;
USE medical_store_db;
CREATE TABLE medicines (
    medicine_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(50),
    supplier_id INT,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);
CREATE TABLE suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contact_info VARCHAR(150)
);
CREATE TABLE stock (
    stock_id INT AUTO_INCREMENT PRIMARY KEY,
    medicine_id INT,
    batch_number VARCHAR(50) NOT NULL,
    expiry_date DATE,
    quantity INT NOT NULL,
    FOREIGN KEY (medicine_id) REFERENCES medicines(medicine_id)
);
CREATE TABLE sales (
    sale_id INT AUTO_INCREMENT PRIMARY KEY,
    medicine_id INT,
    quantity_sold INT NOT NULL,
    sale_date DATETIME NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (medicine_id) REFERENCES medicines(medicine_id)
);
INSERT INTO suppliers (name, contact_info) VALUES
('PharmaCorp', '123 Pharma St, City, Phone: 555-1234'),
('MediSupply', '456 Supply Rd, City, Phone: 555-5678'),
('HealthMart', '789 Health Ave, City, Phone: 555-9101');
INSERT INTO medicines (name, type, supplier_id) VALUES
('Aspirin', 'Painkiller', 1),
('Amoxicillin', 'Antibiotic', 2),
('Paracetamol', 'Painkiller', 1),
('Insulin', 'Hormone', 3),
('Ibuprofen', 'Anti-inflammatory', 2);
INSERT INTO stock (medicine_id, batch_number, expiry_date, quantity) VALUES
(1, 'BATCH001', '2024-12-31', 100),
(2, 'BATCH002', '2025-05-30', 200),
(3, 'BATCH003', '2024-11-15', 150),
(4, 'BATCH004', '2026-01-01', 50),
(5, 'BATCH005', '2025-07-31', 120);
INSERT INTO sales (medicine_id, quantity_sold, sale_date, total_price) VALUES
(1, 10, '2023-08-01 10:00:00', 100.00),
(2, 20, '2023-08-02 11:00:00', 400.00),
(3, 15, '2023-08-02 14:30:00', 75.00),
(4, 5, '2023-08-03 09:00:00', 250.00),
(5, 10, '2023-08-03 16:00:00', 120.00),
(1, 20, '2023-08-04 10:30:00', 200.00);
SELECT m.name, s.batch_number, s.expiry_date, s.quantity
FROM stock s
JOIN medicines m ON s.medicine_id = m.medicine_id
WHERE s.quantity < 50
ORDER BY s.quantity;
SELECT m.name, SUM(s.quantity_sold) AS total_quantity_sold, SUM(s.total_price) AS total_sales
FROM sales s
JOIN medicines m ON s.medicine_id = m.medicine_id
GROUP BY m.medicine_id
ORDER BY total_sales DESC;
