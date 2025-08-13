CREATE TABLE fact_flights (
    flight_id INT PRIMARY KEY,
    booking_id INT,
    route_id INT,
    aircraft_id INT,
    customer_id INT,
    departure_time TIMESTAMP,
    arrival_time TIMESTAMP,
    delay_duration INT,  -- Delay in minutes
    flight_duration INT,  -- Flight duration in minutes
    total_cost DECIMAL(10, 2),
    FOREIGN KEY (route_id) REFERENCES dim_route(route_id),
    FOREIGN KEY (aircraft_id) REFERENCES dim_aircraft(aircraft_id),
    FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
    FOREIGN KEY (departure_time) REFERENCES dim_time(time_id),
    FOREIGN KEY (arrival_time) REFERENCES dim_time(time_id)
);
CREATE TABLE fact_flights (
    flight_id INT PRIMARY KEY,
    booking_id INT,
    route_id INT,
    aircraft_id INT,
    customer_id INT,
    departure_time TIMESTAMP,
    arrival_time TIMESTAMP,
    delay_duration INT,  -- Delay in minutes
    flight_duration INT,  -- Flight duration in minutes
    total_cost DECIMAL(10, 2),
    FOREIGN KEY (route_id) REFERENCES dim_route(route_id),
    FOREIGN KEY (aircraft_id) REFERENCES dim_aircraft(aircraft_id),
    FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
    FOREIGN KEY (departure_time) REFERENCES dim_time(time_id),
    FOREIGN KEY (arrival_time) REFERENCES dim_time(time_id)
);
CREATE TABLE dim_aircraft (
    aircraft_id INT PRIMARY KEY,
    aircraft_model VARCHAR(255),
    capacity INT,
    manufacturer VARCHAR(255)
);
CREATE TABLE dim_customer (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    email VARCHAR(255),
    phone_number VARCHAR(20)
);
CREATE TABLE dim_time (
    time_id INT PRIMARY KEY,
    date DATE,
    hour INT,
    day_of_week INT,
    week INT,
    month INT,
    quarter INT,
    year INT
);
-- Step 1: Extract flight booking data and delays
WITH raw_flights AS (
    SELECT
        f.flight_id,
        f.booking_id,
        f.route_id,
        f.aircraft_id,
        f.customer_id,
        f.departure_time,
        f.arrival_time,
        (EXTRACT(EPOCH FROM (f.arrival_time - f.departure_time)) / 60) AS flight_duration,  -- Duration in minutes
        (EXTRACT(EPOCH FROM (f.arrival_time - f.scheduled_arrival_time)) / 60) AS delay_duration  -- Delay in minutes
    FROM flights f
)
-- Step 2: Transform (calculate delay and flight duration)
, transformed_flights AS (
    SELECT
        flight_id,
        booking_id,
        route_id,
        aircraft_id,
        customer_id,
        departure_time,
        arrival_time,
        ROUND(flight_duration, 2) AS flight_duration,
        ROUND(delay_duration, 2) AS delay_duration
    FROM raw_flights
)
-- Step 3: Load into fact_flights table
INSERT INTO fact_flights (flight_id, booking_id, route_id, aircraft_id, customer_id, departure_time, arrival_time, flight_duration, delay_duration)
SELECT
    flight_id,
    booking_id,
    route_id,
    aircraft_id,
    customer_id,
    departure_time,
    arrival_time,
    flight_duration,
    delay_duration
FROM transformed_flights;
SELECT 
    r.origin_city || ' to ' || r.destination_city AS route,
    AVG(f.delay_duration) AS avg_delay_minutes
FROM fact_flights f
JOIN dim_route r ON f.route_id = r.route_id
GROUP BY route
ORDER BY avg_delay_minutes DESC;
SELECT 
    a.aircraft_model AS carrier,
    AVG(f.delay_duration) AS avg_delay_minutes
FROM fact_flights f
JOIN dim_aircraft a ON f.aircraft_id = a.aircraft_id
GROUP BY carrier
ORDER BY avg_delay_minutes DESC;
SELECT 
    a.aircraft_model AS carrier,
    AVG(f.delay_duration) AS avg_delay_minutes
FROM fact_flights f
JOIN dim_aircraft a ON f.aircraft_id = a.aircraft_id
GROUP BY carrier
ORDER BY avg_delay_minutes DESC;
