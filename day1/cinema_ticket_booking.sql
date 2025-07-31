CREATE DATABASE cinema_db;
USE cinema_db;
CREATE TABLE movies (
    movie_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    genre VARCHAR(50),
    duration INT, -- Duration in minutes
    release_year INT
);
CREATE TABLE screens (
    screen_id INT AUTO_INCREMENT PRIMARY KEY,
    screen_name VARCHAR(50) NOT NULL,
    total_seats INT -- Total number of seats available in the screen
);
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(15)
);
CREATE TABLE bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    movie_id INT,
    screen_id INT,
    booking_date DATETIME,
    seats_booked INT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id),
    FOREIGN KEY (screen_id) REFERENCES screens(screen_id)
);
INSERT INTO movies (title, genre, duration, release_year) VALUES
('Inception', 'Sci-Fi', 148, 2010),
('The Dark Knight', 'Action', 152, 2008),
('Avatar', 'Sci-Fi', 162, 2009),
('The Shawshank Redemption', 'Drama', 142, 1994),
('Pulp Fiction', 'Crime', 154, 1994);
INSERT INTO screens (screen_name, total_seats) VALUES
('Screen 1', 100),
('Screen 2', 150),
('Screen 3', 200);
INSERT INTO customers (first_name, last_name, email, phone_number) VALUES
('Alice', 'Johnson', 'alice.johnson@cinema.com', '123-456-7890'),
('Bob', 'Smith', 'bob.smith@cinema.com', '123-456-7891'),
('Charlie', 'Davis', 'charlie.davis@cinema.com', '123-456-7892'),
('David', 'Martinez', 'david.martinez@cinema.com', '123-456-7893'),
('Emily', 'Garcia', 'emily.garcia@cinema.com', '123-456-7894'),
('Frank', 'Miller', 'frank.miller@cinema.com', '123-456-7895'),
('Grace', 'Wilson', 'grace.wilson@cinema.com', '123-456-7896'),
('Hannah', 'Lopez', 'hannah.lopez@cinema.com', '123-456-7897');
INSERT INTO bookings (customer_id, movie_id, screen_id, booking_date, seats_booked) VALUES
(1, 1, 1, '2023-08-01 10:00:00', 2),
(2, 2, 2, '2023-08-02 14:00:00', 4),
(3, 3, 1, '2023-08-03 16:00:00', 3),
(4, 4, 3, '2023-08-04 12:00:00', 5),
(5, 5, 1, '2023-08-05 18:00:00', 3),
(6, 1, 2, '2023-08-06 20:00:00', 6),
(7, 2, 3, '2023-08-07 10:00:00', 2),
(8, 3, 1, '2023-08-08 14:00:00', 1),
(1, 4, 2, '2023-08-09 16:00:00', 4),
(2, 5, 3, '2023-08-10 12:00:00', 2),
(3, 1, 1, '2023-08-11 18:00:00', 1),
(4, 2, 2, '2023-08-12 20:00:00', 3),
(5, 3, 3, '2023-08-13 10:00:00', 2),
(6, 4, 1, '2023-08-14 14:00:00', 4),
(7, 5, 2, '2023-08-15 16:00:00', 3);
INSERT INTO bookings (customer_id, movie_id, screen_id, booking_date, seats_booked) VALUES
(1, 1, 1, '2023-08-01 10:00:00', 2),
(2, 2, 2, '2023-08-02 14:00:00', 4),
(3, 3, 1, '2023-08-03 16:00:00', 3),
(4, 4, 3, '2023-08-04 12:00:00', 5),
(5, 5, 1, '2023-08-05 18:00:00', 3),
(6, 1, 2, '2023-08-06 20:00:00', 6),
(7, 2, 3, '2023-08-07 10:00:00', 2),
(8, 3, 1, '2023-08-08 14:00:00', 1),
(1, 4, 2, '2023-08-09 16:00:00', 4),
(2, 5, 3, '2023-08-10 12:00:00', 2),
(3, 1, 1, '2023-08-11 18:00:00', 1),
(4, 2, 2, '2023-08-12 20:00:00', 3),
(5, 3, 3, '2023-08-13 10:00:00', 2),
(6, 4, 1, '2023-08-14 14:00:00', 4),
(7, 5, 2, '2023-08-15 16:00:00', 3);
SELECT m.title, b.booking_date, SUM(b.seats_booked) AS booked_seats
FROM bookings b
JOIN movies m ON b.movie_id = m.movie_id
GROUP BY m.title, b.booking_date;
SELECT m.title, COUNT(b.booking_id) AS times_booked
FROM bookings b
JOIN movies m ON b.movie_id = m.movie_id
GROUP BY m.movie_id
ORDER BY times_booked DESC
LIMIT 3;
