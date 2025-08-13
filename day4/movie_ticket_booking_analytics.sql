SELECT m.movie_id, m.movie_name, COUNT(b.booking_id) AS num_bookings
FROM movies m
JOIN bookings b ON m.movie_id = b.movie_id
GROUP BY m.movie_id, m.movie_name
HAVING COUNT(b.booking_id) > (
    SELECT AVG(book_count)
    FROM (
        SELECT movie_id, COUNT(booking_id) AS book_count
        FROM bookings
        GROUP BY movie_id
    ) AS avg_bookings
);
SELECT 
    b.booking_id,
    c.customer_name,
    m.movie_name,
    b.booking_time,
    b.booking_date
FROM bookings b
JOIN customers c ON b.customer_id = c.customer_id
JOIN movies m ON b.movie_id = m.movie_id;
SELECT 
    b.booking_id,
    b.booking_time,
    CASE
        WHEN HOUR(b.booking_time) BETWEEN 6 AND 11 THEN 'Morning'
        WHEN HOUR(b.booking_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        WHEN HOUR(b.booking_time) BETWEEN 18 AND 23 THEN 'Evening'
        ELSE 'Night'
    END AS booking_period
FROM bookings b;
SELECT b1.customer_id, c.customer_name
FROM bookings b1
JOIN movies m1 ON b1.movie_id = m1.movie_id
JOIN customers c ON b1.customer_id = c.customer_id
WHERE m1.movie_name = 'Avengers'

AND b1.customer_id IN (
    SELECT b2.customer_id
    FROM bookings b2
    JOIN movies m2 ON b2.movie_id = m2.movie_id
    WHERE m2.movie_name = 'Batman'
);

SELECT b.booking_id, b.booking_date, 'Weekend' AS sale_type
FROM bookings b
WHERE DAYOFWEEK(b.booking_date) IN (1, 7)  -- 1 = Sunday, 7 = Saturday

UNION ALL

SELECT b.booking_id, b.booking_date, 'Weekday' AS sale_type
FROM bookings b
WHERE DAYOFWEEK(b.booking_date) BETWEEN 2 AND 6;  -- 2-6 = Monday to Friday

SELECT b.booking_id, b.booking_date, 'Weekend' AS sale_type
FROM bookings b
WHERE DAYOFWEEK(b.booking_date) IN (1, 7)  -- 1 = Sunday, 7 = Saturday

UNION ALL

SELECT b.booking_id, b.booking_date, 'Weekday' AS sale_type
FROM bookings b
WHERE DAYOFWEEK(b.booking_date) BETWEEN 2 AND 6;  -- 2-6 = Monday to Friday
SELECT 
    t.theatre_name,
    b.customer_id,
    c.customer_name,
    COUNT(b.booking_id) AS num_bookings
FROM theatres t
JOIN bookings b ON t.theatre_id = b.theatre_id
JOIN customers c ON b.customer_id = c.customer_id
GROUP BY t.theatre_name, b.customer_id, c.customer_name
HAVING COUNT(b.booking_id) = (
    SELECT MAX(book_count)
    FROM (
        SELECT b2.customer_id, COUNT(b2.booking_id) AS book_count
        FROM bookings b2
        WHERE b2.theatre_id = t.theatre_id
        GROUP BY b2.customer_id
    ) AS max_bookings
);
