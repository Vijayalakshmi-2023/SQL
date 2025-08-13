CREATE TABLE users (
    user_id INT PRIMARY KEY,
    user_name VARCHAR(100),
    subscription_id INT
);

CREATE TABLE subscriptions (
    subscription_id INT PRIMARY KEY,
    plan_name VARCHAR(50)
);

CREATE TABLE movies (
    movie_id INT PRIMARY KEY,
    title VARCHAR(200),
    genre VARCHAR(50),
    duration INT  -- duration in minutes
);

CREATE TABLE views (
    view_id INT PRIMARY KEY,
    user_id INT,
    movie_id INT,
    watch_time INT,  -- watch time in minutes
    view_date DATE,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id)
);
SELECT movie_id, COUNT(*) AS total_views
FROM views
GROUP BY movie_id;
SELECT m.genre, AVG(v.watch_time) AS avg_watch_time
FROM views v
JOIN movies m ON v.movie_id = m.movie_id
GROUP BY m.genre;
SELECT movie_id, COUNT(*) AS total_views
FROM views
GROUP BY movie_id
HAVING COUNT(*) > 500;
SELECT v.view_id, v.user_id, m.movie_id, m.title, m.genre, v.watch_time
FROM views v
INNER JOIN movies m ON v.movie_id = m.movie_id;
SELECT u.user_id, u.user_name, s.plan_name
FROM users u
LEFT JOIN subscriptions s ON u.subscription_id = s.subscription_id;
SELECT 
    u1.user_id AS user1_id, u1.user_name AS user1_name,
    u2.user_id AS user2_id, u2.user_name AS user2_name,
    s.plan_name
FROM users u1
JOIN users u2 ON u1.subscription_id = u2.subscription_id AND u1.user_id <> u2.user_id
JOIN subscriptions s ON u1.subscription_id = s.subscription_id
ORDER BY s.plan_name, u1.user_id;
