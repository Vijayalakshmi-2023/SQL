CREATE TABLE fact_bookings (
    booking_id INT PRIMARY KEY,
    guest_id INT,
    room_id INT,
    check_in_date DATE,
    check_out_date DATE,
    total_revenue DECIMAL(10, 2),
    duration INT,  -- Stay duration in days
    services_revenue DECIMAL(10, 2),  -- Revenue from services
    FOREIGN KEY (guest_id) REFERENCES dim_guest(guest_id),
    FOREIGN KEY (room_id) REFERENCES dim_room(room_id),
    FOREIGN KEY (check_in_date) REFERENCES dim_time(time_id)
);
CREATE TABLE fact_bookings (
    booking_id INT PRIMARY KEY,
    guest_id INT,
    room_id INT,
    check_in_date DATE,
    check_out_date DATE,
    total_revenue DECIMAL(10, 2),
    duration INT,  -- Stay duration in days
    services_revenue DECIMAL(10, 2),  -- Revenue from services
    FOREIGN KEY (guest_id) REFERENCES dim_guest(guest_id),
    FOREIGN KEY (room_id) REFERENCES dim_room(room_id),
    FOREIGN KEY (check_in_date) REFERENCES dim_time(time_id)
);
CREATE TABLE dim_room (
    room_id INT PRIMARY KEY,
    room_type_id INT,
    room_number VARCHAR(10),
    capacity INT,
    base_rate DECIMAL(10, 2),  -- Standard rate for the room type
    FOREIGN KEY (room_type_id) REFERENCES dim_room_type(room_type_id)
);
CREATE TABLE dim_room_type (
    room_type_id INT PRIMARY KEY,
    room_type_name VARCHAR(50),  -- e.g., Standard, Deluxe, Suite
    description TEXT
);
CREATE TABLE dim_room_type (
    room_type_id INT PRIMARY KEY,
    room_type_name VARCHAR(50),  -- e.g., Standard, Deluxe, Suite
    description TEXT
);
CREATE TABLE dim_service (
    service_id INT PRIMARY KEY,
    service_name VARCHAR(255),
    service_type VARCHAR(50)  -- e.g., Spa, Room Service, Laundry
);
CREATE TABLE dim_booking_status (
    status_id INT PRIMARY KEY,
    status_name VARCHAR(50)  -- e.g., Confirmed, Cancelled
);
-- Step 1: Extract and Transform Booking Data (calculate stay duration, compute revenue)
WITH raw_bookings AS (
    SELECT
        b.booking_id,
        b.guest_id,
        b.room_id,
        b.check_in_date,
        b.check_out_date,
        DATEDIFF(b.check_out_date, b.check_in_date) AS duration,  -- Calculate stay duration
        r.base_rate * DATEDIFF(b.check_out_date, b.check_in_date) AS total_revenue,  -- Room revenue
        -- Compute services revenue based on services ordered during the stay
        (SELECT SUM(s.service_rate) FROM services s WHERE s.booking_id = b.booking_id) AS services_revenue
    FROM bookings b
    JOIN rooms r ON b.room_id = r.room_id
)
-- Step 2: Load into fact_bookings table
INSERT INTO fact_bookings (booking_id, guest_id, room_id, check_in_date, check_out_date, total_revenue, duration, services_revenue)
SELECT 
    booking_id,
    guest_id,
    room_id,
    check_in_date,
    check_out_date,
    total_revenue,
    duration,
    services_revenue
FROM raw_bookings;
SELECT 
    t.season,
    COUNT(b.booking_id) AS total_bookings,
    SUM(DATEDIFF(b.check_out_date, b.check_in_date)) AS total_nights_stayed,
    (SUM(DATEDIFF(b.check_out_date, b.check_in_date)) / (COUNT(r.room_id) * COUNT(DISTINCT t.month))) * 100 AS occupancy_rate
FROM fact_bookings b
JOIN dim_time t ON b.check_in_date = t.date
JOIN dim_room r ON b.room_id = r.room_id
GROUP BY t.season
ORDER BY occupancy_rate DESC;
SELECT 
    rt.room_type_name,
    COUNT(b.booking_id) AS total_bookings,
    SUM(f.total_revenue) AS total_room_revenue,
    SUM(f.services_revenue) AS total_services_revenue,
    SUM(f.total_revenue + f.services_revenue) AS total_revenue
FROM fact_bookings f
JOIN dim_room r ON f.room_id = r.room_id
JOIN dim_room_type rt ON r.room_type_id = rt.room_type_id
GROUP BY rt.room_type_name
ORDER BY total_revenue DESC;
SELECT 
    t.season,
    SUM(f.total_revenue) AS room_revenue,
    SUM(f.services_revenue) AS services_revenue,
    SUM(f.total_revenue + f.services_revenue) AS total_revenue
FROM fact_bookings f
JOIN dim_time t ON f.check_in_date = t.date
GROUP BY t.season
ORDER BY total_revenue DESC;
