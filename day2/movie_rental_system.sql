CREATE TABLE movies (
    movie_id INT PRIMARY KEY,
    title VARCHAR(200),
    genre VARCHAR(50),
    price DECIMAL(10,2),
    rating DECIMAL(3,1),   -- e.g., 4.5, 3.0
    available BOOLEAN      -- or TINYINT (1 for true, 0 for false)
);
SELECT title, genre, rating
FROM movies
WHERE available = TRUE AND genre IN ('Action', 'Thriller');
SELECT *
FROM movies
WHERE title LIKE '%Star%';
SELECT *
FROM movies
WHERE genre IN ('Action', 'Thriller', 'Comedy');  -- Example list
SELECT *
FROM movies
WHERE rating IS NULL;
SELECT DISTINCT genre
FROM movies;
SELECT *
FROM movies
ORDER BY rating DESC, price ASC;
