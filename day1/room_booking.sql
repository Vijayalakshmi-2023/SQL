CREATE DATABASE hotel_db;
USE hotel_db;
CREATE TABLE rooms (
    room_id INT AUTO_INCREMENT PRIMARY KEY,
    room_type VARCHAR(50) NOT NULL,
    price_per_night DECIMAL(10, 2) NOT NULL
);
CREATE TABLE guests (
    guest_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(15)
);
CREATE TABLE services (
    service_id INT AUTO_INCREMENT PRIMARY KEY,
    service_name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);
CREATE TABLE bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    guest_id INT,
    room_id INT,
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    FOREIGN KEY (guest_id) REFERENCES guests(guest_id),
    FOREIGN KEY (room_id) REFERENCES rooms(room_id)
);
CREATE TABLE guest_services (
    guest_service_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT,
    service_id INT,
    quantity INT NOT NULL,
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id),
    FOREIGN KEY (service_id) REFERENCES services(service_id)
);
INSERT INTO rooms (room_type, price_per_night) VALUES
('Single', 100.00),
('Double', 150.00),
('Suite', 250.00),
('Penthouse', 500.00);
INSERT INTO services (service_name, price) VALUES
('Room Service', 20.00),
('Laundry', 15.00),
('Spa Treatment', 50.00),
('Airport Pickup', 30.00);
INSERT INTO guests (first_name, last_name, email, phone_number) VALUES
('Alice', 'Johnson', 'alice.johnson@example.com', '123-456-7890'),
('Bob', 'Smith', 'bob.smith@example.com', '123-456-7891'),
('Charlie', 'Davis', 'charlie.davis@example.com', '123-456-7892'),
('David', 'Martinez', 'david.martinez@example.com', '123-456-7893'),
('Emily', 'Garcia', 'emily.garcia@example.com', '123-456-7894'),
('Frank', 'Miller', 'frank.miller@example.com', '123-456-7895'),
('Grace', 'Wilson', 'grace.wilson@example.com', '123-456-7896'),
('Hannah', 'Lopez', 'hannah.lopez@example.com', '123-456-7897');
INSERT INTO bookings (guest_id, room_id, check_in_date, check_out_date) VALUES
(1, 1, '2023-08-01', '2023-08-05'),
(2, 2, '2023-08-02', '2023-08-06'),
(3, 3, '2023-08-03', '2023-08-07'),
(4, 4, '2023-08-04', '2023-08-08'),
(5, 2, '2023-08-05', '2023-08-09'),
(6, 3, '2023-08-06', '2023-08-10'),
(7, 1, '2023-08-07', '2023-08-11'),
(8, 4, '2023-08-08', '2023-08-12'),
(1, 2, '2023-08-09', '2023-08-13'),
(2, 3, '2023-08-10', '2023-08-14');
INSERT INTO guest_services (booking_id, service_id, quantity) VALUES
(1, 1, 3), -- Alice: Room Service x 3
(2, 2, 1), -- Bob: Laundry x 1
(3, 3, 2), -- Charlie: Spa Treatment x 2
(4, 4, 1), -- David: Airport Pickup x 1
(5, 1, 2), -- Emily: Room Service x 2
(6, 3, 1), -- Frank: Spa Treatment x 1
(7, 2, 1), -- Grace: Laundry x 1
(8, 1, 3), -- Hannah: Room Service x 3
(1, 3, 1), -- Alice: Spa Treatment x 1
(2, 4, 2), -- Bob: Airport Pickup x 2
(3, 1, 1), -- Charlie: Room Service x 1
(4, 2, 1), -- David: Laundry x 1
(5, 4, 1), -- Emily: Airport Pickup x 1
(6, 1, 1), -- Frank: Room Service x 1
(7, 3, 1); -- Grace: Spa Treatment x 1
SELECT b.booking_id, g.first_name, g.last_name, r.room_type, b.check_in_date, b.check_out_date, 
       DATEDIFF(b.check_out_date, b.check_in_date) AS booking_duration
FROM bookings b
JOIN guests g ON b.guest_id = g.guest_id
JOIN rooms r ON b.room_id = r.room_id;
SELECT g.first_name, g.last_name, SUM(gs.quantity * s.price) AS total_service_charges
FROM guest_services gs
JOIN services s ON gs.service_id = s.service_id
JOIN bookings b ON gs.booking_id = b.booking_id
JOIN guests g ON b.guest_id = g.guest_id
GROUP BY g.guest_id;
