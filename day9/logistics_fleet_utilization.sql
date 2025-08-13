CREATE TABLE fact_deliveries (
    delivery_id INT PRIMARY KEY,
    vehicle_id INT,
    driver_id INT,
    route_id INT,
    delivery_date TIMESTAMP,
    delivery_distance DECIMAL(10, 2),  -- in kilometers or miles
    fuel_usage DECIMAL(10, 2),  -- in liters or gallons
    gps_start_lat DECIMAL(10, 6),
    gps_start_lon DECIMAL(10, 6),
    gps_end_lat DECIMAL(10, 6),
    gps_end_lon DECIMAL(10, 6),
    timestamp_start TIMESTAMP,
    timestamp_end TIMESTAMP,
    FOREIGN KEY (vehicle_id) REFERENCES dim_vehicle(vehicle_id),
    FOREIGN KEY (driver_id) REFERENCES dim_driver(driver_id),
    FOREIGN KEY (route_id) REFERENCES dim_route(route_id),
    FOREIGN KEY (delivery_date) REFERENCES dim_time(time_id)
);
CREATE TABLE dim_vehicle (
    vehicle_id INT PRIMARY KEY,
    vehicle_type VARCHAR(255),
    model VARCHAR(255),
    fuel_type VARCHAR(50),
    capacity DECIMAL(10, 2)  -- Maximum load capacity (e.g., in kg or tons)
);
CREATE TABLE dim_vehicle (
    vehicle_id INT PRIMARY KEY,
    vehicle_type VARCHAR(255),
    model VARCHAR(255),
    fuel_type VARCHAR(50),
    capacity DECIMAL(10, 2)  -- Maximum load capacity (e.g., in kg or tons)
);
CREATE TABLE dim_route (
    route_id INT PRIMARY KEY,
    start_point VARCHAR(255),
    end_point VARCHAR(255),
    estimated_time INT,  -- in minutes
    difficulty_level VARCHAR(50)  -- Easy, Medium, Hard
);
CREATE TABLE dim_time (
    time_id INT PRIMARY KEY,
    date DATE,
    day_of_week INT,
    week INT,
    month INT,
    quarter INT,
    year INT
);
-- Step 1: Extract and Transform Delivery Data (clean timestamps, GPS, and calculate fuel usage)
WITH raw_deliveries AS (
    SELECT
        d.delivery_id,
        d.vehicle_id,
        d.driver_id,
        d.route_id,
        d.delivery_date,
        d.delivery_distance,
        -- Clean GPS coordinates (round to 6 decimal places for consistency)
        ROUND(d.gps_start_lat, 6) AS gps_start_lat,
        ROUND(d.gps_start_lon, 6) AS gps_start_lon,
        ROUND(d.gps_end_lat, 6) AS gps_end_lat,
        ROUND(d.gps_end_lon, 6) AS gps_end_lon,
        -- Normalize timestamps (convert to UTC, if necessary)
        CONVERT_TZ(d.timestamp_start, 'America/New_York', 'UTC') AS timestamp_start_utc,
        CONVERT_TZ(d.timestamp_end, 'America/New_York', 'UTC') AS timestamp_end_utc,
        -- Estimate fuel usage based on distance and vehicle type
        CASE
            WHEN v.fuel_type = 'Diesel' THEN (d.delivery_distance * 0.08)  -- Example fuel rate
            WHEN v.fuel_type = 'Gasoline' THEN (d.delivery_distance * 0.1)
            ELSE 0
        END AS fuel_usage
    FROM deliveries d
    JOIN vehicles v ON d.vehicle_id = v.vehicle_id
)
-- Step 2: Load into fact_deliveries table
INSERT INTO fact_deliveries (delivery_id, vehicle_id, driver_id, route_id, delivery_date, delivery_distance, fuel_usage, gps_start_lat, gps_start_lon, gps_end_lat, gps_end_lon, timestamp_start, timestamp_end)
SELECT 
    delivery_id,
    vehicle_id,
    driver_id,
    route_id,
    delivery_date,
    delivery_distance,
    fuel_usage,
    gps_start_lat,
    gps_start_lon,
    gps_end_lat,
    gps_end_lon,
    timestamp_start_utc,
    timestamp_end_utc
FROM raw_deliveries;
SELECT 
    v.vehicle_type,
    r.start_point,
    r.end_point,
    SUM(f.fuel_usage) AS total_fuel_usage
FROM fact_deliveries f
JOIN dim_vehicle v ON f.vehicle_id = v.vehicle_id
JOIN dim_route r ON f.route_id = r.route_id
GROUP BY v.vehicle_type, r.start_point, r.end_point
ORDER BY total_fuel_usage DESC;
SELECT 
    d.first_name,
    d.last_name,
    COUNT(f.delivery_id) AS total_deliveries,
    SUM(f.fuel_usage) AS total_fuel_used,
    AVG(f.delivery_distance) AS avg_delivery_distance
FROM fact_deliveries f
JOIN dim_driver d ON f.driver_id = d.driver_id
GROUP BY d.driver_id
ORDER BY total_deliveries DESC;
SELECT 
    r.start_point,
    r.end_point,
    AVG(f.fuel_usage) AS avg_fuel_usage,
    AVG(TIMESTAMPDIFF(MINUTE, f.timestamp_start, f.timestamp_end)) AS avg_delivery_time
FROM fact_deliveries f
JOIN dim_route r ON f.route_id = r.route_id
GROUP BY r.start_point, r.end_point
ORDER BY avg_fuel_usage ASC;
