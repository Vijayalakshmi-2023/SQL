CREATE TABLE services (
    service_id INT PRIMARY KEY,
    vehicle_no VARCHAR(20),
    service_type VARCHAR(50),
    cost DECIMAL(10,2),
    service_date DATE,
    technician VARCHAR(100)
);
SELECT vehicle_no, service_type, cost
FROM services
WHERE service_date BETWEEN CURDATE() - INTERVAL 30 DAY AND CURDATE();
SELECT *
FROM services
WHERE vehicle_no LIKE '%9';
SELECT *
FROM services
WHERE cost BETWEEN 500 AND 2000;
SELECT *
FROM services
WHERE technician IS NULL;
SELECT DISTINCT service_type
FROM services;
SELECT *
FROM services
ORDER BY service_date DESC, cost ASC;
