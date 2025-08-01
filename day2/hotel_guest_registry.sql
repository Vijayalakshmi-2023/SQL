CREATE TABLE guests (
    guest_id INT PRIMARY KEY,
    name VARCHAR(100),
    room_type VARCHAR(50),
    check_in DATE,
    check_out DATE,
    payment_status VARCHAR(20)  -- e.g., 'Paid', 'Pending', or NULL
);
SELECT name, room_type, check_in
FROM guests
WHERE check_in BETWEEN '2025-07-01' AND '2025-07-31';
SELECT *
FROM guests
WHERE payment_status IS NULL;
SELECT *
FROM guests
WHERE name LIKE 'K%';
SELECT DISTINCT room_type
FROM guests;
SELECT *
FROM guests
ORDER BY check_out DESC, name ASC;
