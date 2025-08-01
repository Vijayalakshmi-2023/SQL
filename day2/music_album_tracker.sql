CREATE TABLE albums (
    album_id INT PRIMARY KEY,
    artist VARCHAR(100),
    genre VARCHAR(50),
    title VARCHAR(200),
    release_year INT,
    price DECIMAL(10,2)
);
SELECT title, artist, price
FROM albums
WHERE genre IN ('Jazz', 'Classical') AND release_year > 2015;
SELECT DISTINCT artist
FROM albums;
SELECT *
FROM albums
WHERE title LIKE '%Love%';
SELECT *
FROM albums
WHERE price IS NULL;
SELECT *
FROM albums
ORDER BY release_year DESC, title ASC;
