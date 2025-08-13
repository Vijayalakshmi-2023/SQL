CREATE TABLE fact_bookings (
    booking_id INT PRIMARY KEY,
    customer_id INT,
    movie_id INT,
    theater_id INT,
    show_id INT,
    booking_date TIMESTAMP,
    ticket_price DECIMAL(10, 2),
    currency VARCHAR(10),
    number_of_tickets INT,
    occupancy_rate DECIMAL(5, 2),  -- Occupancy rate per show
    FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
    FOREIGN KEY (movie_id) REFERENCES dim_movie(movie_id),
    FOREIGN KEY (theater_id) REFERENCES dim_theater(theater_id),
    FOREIGN KEY (show_id) REFERENCES dim_show(show_id),
    FOREIGN KEY (booking_date) REFERENCES dim_time(time_id)
);
CREATE TABLE fact_bookings (
    booking_id INT PRIMARY KEY,
    customer_id INT,
    movie_id INT,
    theater_id INT,
    show_id INT,
    booking_date TIMESTAMP,
    ticket_price DECIMAL(10, 2),
    currency VARCHAR(10),
    number_of_tickets INT,
    occupancy_rate DECIMAL(5, 2),  -- Occupancy rate per show
    FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
    FOREIGN KEY (movie_id) REFERENCES dim_movie(movie_id),
    FOREIGN KEY (theater_id) REFERENCES dim_theater(theater_id),
    FOREIGN KEY (show_id) REFERENCES dim_show(show_id),
    FOREIGN KEY (booking_date) REFERENCES dim_time(time_id)
);
CREATE TABLE dim_movie (
    movie_id INT PRIMARY KEY,
    movie_name VARCHAR(255),
    genre VARCHAR(50),
    director VARCHAR(255),
    release_year INT
);
CREATE TABLE dim_customer (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    email VARCHAR(255),
    phone_number VARCHAR(20),
    address VARCHAR(255)
);
CREATE TABLE dim_theater (
    theater_id INT PRIMARY KEY,
    theater_name VARCHAR(255),
    theater_location VARCHAR(255),
    seating_capacity INT
);
CREATE TABLE dim_show (
    show_id INT PRIMARY KEY,
    movie_id INT,
    theater_id INT,
    show_time TIMESTAMP,
    FOREIGN KEY (movie_id) REFERENCES dim_movie(movie_id),
    FOREIGN KEY (theater_id) REFERENCES dim_theater(theater_id)
);
CREATE TABLE dim_show (
    show_id INT PRIMARY KEY,
    movie_id INT,
    theater_id INT,
    show_time TIMESTAMP,
    FOREIGN KEY (movie_id) REFERENCES dim_movie(movie_id),
    FOREIGN KEY (theater_id) REFERENCES dim_theater(theater_id)
);
SELECT 
    m.movie_name,
    AVG(f.occupancy_rate) AS avg_occupancy_rate
FROM fact_bookings f
JOIN dim_movie m ON f.movie_id = m.movie_id
GROUP BY m.movie_name
ORDER BY avg_occupancy_rate DESC;
SELECT 
    m.genre,
    t.month,
    SUM(f.number_of_tickets) AS tickets_sold
FROM fact_bookings f
JOIN dim_movie m ON f.movie_id = m.movie_id
JOIN dim_time t ON f.booking_date = t.date
GROUP BY m.genre, t.month
ORDER BY t.month, m.genre;
SELECT 
    m.movie_name,
    AVG(f.occupancy_rate) AS avg_occupancy_rate,
    COUNT(f.booking_id) AS total_bookings
FROM fact_bookings f
JOIN dim_movie m ON f.movie_id = m.movie_id
GROUP BY m.movie_name
ORDER BY avg_occupancy_rate DESC, total_bookings DESC;
