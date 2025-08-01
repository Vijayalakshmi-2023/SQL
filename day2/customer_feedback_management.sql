CREATE TABLE feedback (
    feedback_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    rating INT,                        -- typically from 1 to 5
    comment TEXT,
    product VARCHAR(100),
    submitted_date DATE
);
SELECT customer_name, rating, comment
FROM feedback
WHERE rating >= 4 AND product = 'Smartphone';
SELECT *
FROM feedback
WHERE comment LIKE '%slow%';
SELECT *
FROM feedback
WHERE submitted_date BETWEEN CURDATE() - INTERVAL 30 DAY AND CURDATE();
SELECT *
FROM feedback
WHERE comment IS NULL;
SELECT DISTINCT product
FROM feedback;
SELECT *
FROM feedback
ORDER BY rating DESC, submitted_date DESC;
