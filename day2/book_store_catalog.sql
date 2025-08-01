CREATE TABLE books (
    book_id INT PRIMARY KEY,
    title VARCHAR(200),
    author VARCHAR(100),
    genre VARCHAR(50),
    price DECIMAL(10,2),
    published_year INT,
    stock INT
);
SELECT title, author, price
FROM books
WHERE genre = 'Fiction' AND price < 500;
SELECT DISTINCT genre
FROM books;
SELECT *
FROM books
WHERE title LIKE 'The%';
SELECT *
FROM books
WHERE published_year BETWEEN 2010 AND 2023;
SELECT *
FROM books
WHERE stock IS NULL;
SELECT *
FROM books
ORDER BY published_year DESC, title ASC;
