CREATE TABLE vehicles (
    vehicle_id INT PRIMARY KEY,
    model VARCHAR(100),
    type VARCHAR(50), -- e.g., SUV, Sedan
    daily_rate DECIMAL(10,2)
);

CREATE TABLE rentals (
    rental_id INT PRIMARY KEY,
    vehicle_id INT,
    customer_id INT,
    rental_date DATE,
    return_date DATE,
    cost DECIMAL(10,2),
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    rental_id INT,
    payment_date DATE,
    amount DECIMAL(10,2),
    FOREIGN KEY (rental_id) REFERENCES rentals(rental_id)
);
SELECT vehicle_id, COUNT(*) AS total_rentals
FROM rentals
GROUP BY vehicle_id;
SELECT vehicle_id, COUNT(*) AS total_rentals
FROM rentals
GROUP BY vehicle_id
HAVING COUNT(*) > 10;
SELECT v.type, AVG(r.cost) AS avg_rental_cost
FROM rentals r
JOIN vehicles v ON r.vehicle_id = v.vehicle_id
GROUP BY v.type;
SELECT r.rental_id, r.rental_date, r.cost, v.model, v.type
FROM rentals r
INNER JOIN vehicles v ON r.vehicle_id = v.vehicle_id;
SELECT v.vehicle_id, v.model, v.type, p.payment_id, p.amount
FROM vehicles v
LEFT JOIN rentals r ON v.vehicle_id = r.vehicle_id
LEFT JOIN payments p ON r.rental_id = p.rental_id;
SELECT 
    v1.vehicle_id AS vehicle1_id, v1.model AS model1,
    v2.vehicle_id AS vehicle2_id, v2.model AS model2,
    v1.type
FROM vehicles v1
JOIN vehicles v2 
  ON v1.model = v2.model AND v1.type = v2.type AND v1.vehicle_id <> v2.vehicle_id
ORDER BY v1.model, v1.type;
