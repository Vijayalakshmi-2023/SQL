CREATE TABLE users (
    user_id INT PRIMARY KEY,
    user_name VARCHAR(100),
    trainer_id INT,
    goal VARCHAR(100)  -- e.g., 'Weight Loss', 'Muscle Gain'
);

CREATE TABLE trainers (
    trainer_id INT PRIMARY KEY,
    trainer_name VARCHAR(100)
);

CREATE TABLE workouts (
    workout_id INT PRIMARY KEY,
    user_id INT,
    session_date DATE,
    duration INT,            -- in minutes
    calories_burned INT,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE goals (
    goal_id INT PRIMARY KEY,
    description VARCHAR(100)
);
SELECT AVG(calories_burned) AS avg_calories
FROM workouts;
SELECT user_id, COUNT(*) AS total_sessions
FROM workouts
GROUP BY user_id
HAVING COUNT(*) > 10;
SELECT u.user_id, u.user_name, w.session_date, w.duration, w.calories_burned
FROM users u
INNER JOIN workouts w ON u.user_id = w.user_id;
SELECT t.trainer_id, t.trainer_name, u.user_id, u.user_name
FROM trainers t
LEFT JOIN users u ON t.trainer_id = u.trainer_id;
SELECT 
    u1.user_id AS user1_id, u1.user_name AS user1_name,
    u2.user_id AS user2_id, u2.user_name AS user2_name,
    u1.goal
FROM users u1
JOIN users u2 
  ON u1.goal = u2.goal AND u1.user_id <> u2.user_id
ORDER BY u1.goal, u1.user_id;
