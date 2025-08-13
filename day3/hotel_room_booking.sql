CREATE TABLE rooms (
    room_id INT PRIMARY KEY,
    room_type VARCHAR(50)
);

CREATE TABLE guests (
    guest_id INT PRIMARY KEY,
    guest_name VARCHAR(100)
);

CREATE TABLE bookings (
    booking_id INT PRIMARY KEY,
    guest_id INT,
    room_id INT,
    check_in DATE,
    check_out DATE,
    FOREIGN KEY (guest_id) REFERENCES guests(guest_id),
    FOREIGN KEY (room_id) REFERENCES rooms(room_id)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    booking_id INT,
    amount DECIMAL(10,2),
    payment_date DATE,
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
);
SELECT g.guest_id, g.guest_name, SUM(p.amount) AS total_paid
FROM guests g
JOIN bookings b ON g.guest_id = b.guest_id
JOIN payments p ON b.booking_id = p.booking_id
GROUP BY g.guest_id, g.guest_name;
SELECT room_id, COUNT(*) AS booking_count
FROM bookings
GROUP BY room_id
HAVING COUNT(*) > 5;
SELECT r.room_type, AVG(DATEDIFF(day, b.check_in, b.check_out)) AS avg_stay_duration
FROM bookings b
JOIN rooms r ON b.room_id = r.room_id
GROUP BY r.room_type;
SELECT g.guest_name, b.booking_id, r.room_type, b.check_in, b.check_out
FROM guests g
INNER JOIN bookings b ON g.guest_id = b.guest_id
INNER JOIN rooms r ON b.room_id = r.room_id;
SELECT r.room_id, r.room_type, b.booking_id, b.guest_id, b.check_in, b.check_out
FROM rooms r
LEFT JOIN bookings b ON r.room_id = b.room_id

UNION

SELECT r.room_id, r.room_type, b.booking_id, b.guest_id, b.check_in, b.check_out
FROM rooms r
RIGHT JOIN bookings b ON r.room_id = b.room_id;
SELECT 
    b1.guest_id AS guest1_id, g1.guest_name AS guest1_name,
    b2.guest_id AS guest2_id, g2.guest_name AS guest2_name,
    b1.room_id,
    b1.booking_id AS booking1, b2.booking_id AS booking2
FROM bookings b1
JOIN bookings b2 ON b1.room_id = b2.room_id 
    AND b1.guest_id = b2.guest_id 
    AND b1.booking_id <> b2.booking_id
JOIN guests g1 ON b1.guest_id = g1.guest_id
JOIN guests g2 ON b2.guest_id = g2.guest_id
ORDER BY b1.room_id, b1.guest_id;
