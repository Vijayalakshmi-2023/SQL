-- Guests Table
CREATE TABLE guests (
    guest_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(15) UNIQUE NOT NULL,
    address TEXT
);

-- Room Types Table
CREATE TABLE room_types (
    room_type_id INT PRIMARY KEY AUTO_INCREMENT,
    room_type_name VARCHAR(255) NOT NULL,
    description TEXT,
    price_per_night DECIMAL(10, 2) NOT NULL
);

-- Rooms Table
CREATE TABLE rooms (
    room_id INT PRIMARY KEY AUTO_INCREMENT,
    room_number VARCHAR(10) UNIQUE NOT NULL,
    room_type_id INT,
    status ENUM('available', 'booked', 'maintenance') NOT NULL,
    FOREIGN KEY (room_type_id) REFERENCES room_types(room_type_id)
);

-- Bookings Table
CREATE TABLE bookings (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    guest_id INT,
    room_id INT,
    check_in DATE,
    check_out DATE,
    booking_date DATETIME,
    FOREIGN KEY (guest_id) REFERENCES guests(guest_id),
    FOREIGN KEY (room_id) REFERENCES rooms(room_id)
);

-- Payments Table
CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT,
    amount DECIMAL(10, 2) NOT NULL,
    payment_date DATETIME,
    payment_status ENUM('successful', 'failed') NOT NULL,
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
);
-- Index on room_type for faster lookups by room type
CREATE INDEX idx_room_type ON rooms(room_type_id);

-- Index on check_in date for quick lookup of bookings by check-in date
CREATE INDEX idx_check_in ON bookings(check_in);

-- Index on guest_id for fast access to bookings by guest
CREATE INDEX idx_guest_id ON bookings(guest_id);
EXPLAIN 
SELECT g.first_name, g.last_name, r.room_number, b.check_in, b.check_out, p.amount
FROM bookings b
JOIN guests g ON b.guest_id = g.guest_id
JOIN rooms r ON b.room_id = r.room_id
JOIN payments p ON b.booking_id = p.booking_id
WHERE g.guest_id = 1
ORDER BY b.booking_date DESC;
SELECT g.first_name, g.last_name, r.room_number, b.check_in, b.check_out, p.amount, p.payment_status
FROM bookings b
JOIN guests g ON b.guest_id = g.guest_id
JOIN rooms r ON b.room_id = r.room_id
JOIN payments p ON b.booking_id = p.booking_id
WHERE r.status = 'available'
ORDER BY b.check_in DESC;
-- Denormalized Table for Daily Revenue Reporting
CREATE TABLE daily_revenue (
    report_date DATE PRIMARY KEY,
    total_revenue DECIMAL(10, 2) NOT NULL
);

-- Populate the daily revenue table (for example, for today)
INSERT INTO daily_revenue (report_date, total_revenue)
SELECT CURDATE(), SUM(p.amount)
FROM payments p
JOIN bookings b ON p.booking_id = b.booking_id
WHERE b.check_in <= CURDATE() AND b.check_out >= CURDATE();
SELECT g.first_name, g.last_name, SUM(p.amount) AS total_spent
FROM guests g
JOIN bookings b ON g.guest_id = b.guest_id
JOIN payments p ON b.booking_id = p.booking_id
GROUP BY g.guest_id
ORDER BY total_spent DESC
LIMIT 10;
