CREATE TABLE courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(255),
    description TEXT,
    instructor_id INT,
    creation_date TIMESTAMP
);
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    username VARCHAR(255) UNIQUE,
    email VARCHAR(255) UNIQUE,
    registration_date TIMESTAMP
);
CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY,
    course_id INT,
    user_id INT,
    enrollment_date TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES courses(course_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);
CREATE TABLE completions (
    completion_id INT PRIMARY KEY,
    course_id INT,
    user_id INT,
    completion_date TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES courses(course_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);
CREATE TABLE instructors (
    instructor_id INT PRIMARY KEY,
    name VARCHAR(255),
    bio TEXT
);
CREATE INDEX idx_course_id ON enrollments(course_id);
CREATE INDEX idx_user_id ON enrollments(user_id);
CREATE INDEX idx_completion_date ON completions(completion_date);
EXPLAIN SELECT course_id, COUNT(user_id) AS completions
FROM completions
GROUP BY course_id;
SELECT user_id
FROM completions
GROUP BY user_id
HAVING COUNT(course_id) > 3;
CREATE TABLE course_leaderboard (
    course_id INT,
    user_id INT,
    completion_date TIMESTAMP,
    PRIMARY KEY (course_id, user_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);
SELECT course_id, COUNT(user_id) AS completions
FROM completions
GROUP BY course_id
ORDER BY completions DESC
LIMIT 5;
