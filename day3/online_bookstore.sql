CREATE TABLE authors (
    author_id INT PRIMARY KEY,
    author_name VARCHAR(100)
);

CREATE TABLE books (
    book_id INT PRIMARY KEY,
    title VARCHAR(200),
    author_id INT,
    genre VARCHAR(100),
    rating DECIMAL(2,1),
    FOREIGN KEY (author_id) REFERENCES authors(author_id)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100)
);

CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    book_id INT,
    customer_id INT,
    sale_date DATE,
    quantity INT,
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
SELECT b.author_id, a.author_name, SUM(s.quantity) AS total_sold
FROM sales s
INNER JOIN books b ON s.book_id = b.book_id
INNER JOIN authors a ON b.author_id = a.author_id
GROUP BY b.author_id, a.author_name
ORDER BY total_sold DESC;
SELECT b.book_id, b.title, b.rating, SUM(s.quantity) AS total_sold
FROM books b
INNER JOIN sales s ON b.book_id = s.book_id
GROUP BY b.book_id, b.title, b.rating
HAVING b.rating > 4.5 AND SUM(s.quantity) > 100;
SELECT c.customer_id, c.customer_name, COUNT(s.sale_id) AS purchase_count
FROM customers c
INNER JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(s.sale_id) > 5;
SELECT s.sale_id, b.title, c.customer_name, s.sale_date, s.quantity
FROM sales s
INNER JOIN books b ON s.book_id = b.book_id
INNER JOIN customers c ON s.customer_id = c.customer_id;
-- Note: FULL OUTER JOIN syntax differs by SQL dialect; example for PostgreSQL:
-- LEFT JOIN: all authors and their books (if any)
SELECT a.author_id, a.author_name, b.book_id, b.title
FROM authors a
LEFT JOIN books b ON a.author_id = b.author_id

UNION

-- RIGHT JOIN: all books and their authors (if any)
SELECT a.author_id, a.author_name, b.book_id, b.title
FROM authors a
RIGHT JOIN books b ON a.author_id = b.author_id;

SELECT b1.book_id AS book1_id, b1.title AS book1_title,
       b2.book_id AS book2_id, b2.title AS book2_title,
       b1.genre
FROM books b1
JOIN books b2 ON b1.genre = b2.genre AND b1.book_id <> b2.book_id
ORDER BY b1.genre, b1.book_id;

