CREATE TABLE movies (
    movie_id INT PRIMARY KEY,
    title VARCHAR(255),
    release_year INT,
    duration INT,  -- in minutes
    genre_id INT,  -- foreign key to genres
    FOREIGN KEY (genre_id) REFERENCES genres(genre_id)
);
CREATE TABLE genres (
    genre_id INT PRIMARY KEY,
    genre_name VARCHAR(255)
);
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    username VARCHAR(255) UNIQUE,
    email VARCHAR(255) UNIQUE,
    registration_date TIMESTAMP
);
CREATE TABLE watch_history (
    watch_id INT PRIMARY KEY,
    user_id INT,
    movie_id INT,
    watch_date TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id)
);
CREATE TABLE subscriptions (
    subscription_id INT PRIMARY KEY,
    user_id INT,
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    subscription_type VARCHAR(50),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);
CREATE INDEX idx_movie_id ON watch_history(movie_id);
CREATE INDEX idx_user_id ON watch_history(user_id);
CREATE INDEX idx_watch_date ON watch_history(watch_date);
EXPLAIN SELECT user_id, SUM(movies.duration) AS total_watch_time
FROM watch_history
JOIN movies ON watch_history.movie_id = movies.movie_id
GROUP BY user_id;
SELECT user_id, COUNT(movie_id) AS movies_watched
FROM watch_history
WHERE watch_date >= CURDATE() - INTERVAL 7 DAY
GROUP BY user_id
HAVING COUNT(movie_id) = (
    SELECT MAX(movies_watched)
    FROM (
        SELECT user_id, COUNT(movie_id) AS movies_watched
        FROM watch_history
        WHERE watch_date >= CURDATE() - INTERVAL 7 DAY
        GROUP BY user_id
    ) AS subquery
);
CREATE TABLE monthly_user_engagement (
    user_id INT,
    month DATE,
    total_watch_time INT,
    movies_watched INT,
    PRIMARY KEY (user_id, month),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);
INSERT INTO monthly_user_engagement (user_id, month, total_watch_time, movies_watched)
SELECT user_id, 
       DATE_FORMAT(watch_date, '%Y-%m-01') AS month,
       SUM(movies.duration) AS total_watch_time,
       COUNT(movie_id) AS movies_watched
FROM watch_history
JOIN movies ON watch_history.movie_id = movies.movie_id
GROUP BY user_id, month;
SELECT movie_id, COUNT(user_id) AS watch_count
FROM watch_history
GROUP BY movie_id
ORDER BY watch_count DESC
LIMIT 10;
