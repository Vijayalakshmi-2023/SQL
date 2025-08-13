-- Create Authors Table
CREATE TABLE authors (
    author_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    UNIQUE (first_name, last_name)  -- Ensure no duplicate authors
);

-- Create Genres Table
CREATE TABLE genres (
    genre_id INT PRIMARY KEY AUTO_INCREMENT,
    genre_name VARCHAR(100) NOT NULL UNIQUE
);

-- Create Publishers Table
CREATE TABLE publishers (
    publisher_id INT PRIMARY KEY AUTO_INCREMENT,
    publisher_name VARCHAR(200) NOT NULL UNIQUE,
    contact_email VARCHAR(100)
);

-- Create Books Table
CREATE TABLE books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    author_id INT NOT NULL,
    genre_id INT NOT NULL,
    publisher_id INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    publication_date DATE,
    stock_quantity INT NOT NULL,
    FOREIGN KEY (author_id) REFERENCES authors(author_id),
    FOREIGN KEY (genre_id) REFERENCES genres(genre_id),
    FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id)
);

-- Create Sales Table (Denormalized for monthly book sales)
CREATE TABLE sales (
    sale_id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT NOT NULL,
    sale_date DATE NOT NULL,
    quantity_sold INT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);
-- Create Non-clustered Index on title for faster search by book title
CREATE INDEX idx_title ON books(title);
-- Create Non-clustered Index on author_id for faster search by author
CREATE INDEX idx_author_id ON books(author_id);
EXPLAIN SELECT b.book_id, b.title, a.first_name, a.last_name
FROM books b
JOIN authors a ON b.author_id = a.author_id
WHERE b.title LIKE '%SQL%' AND (a.first_name LIKE '%John%' OR a.last_name LIKE '%Doe%');
EXPLAIN SELECT b.book_id, b.title, a.first_name, a.last_name 
FROM books b
JOIN authors a ON b.author_id = a.author_id
WHERE b.title LIKE '%SQL%' AND (a.first_name LIKE '%John%' OR a.last_name LIKE '%Doe%');
SELECT 
    b.book_id,
    b.title,
    a.first_name AS author_first_name,
    a.last_name AS author_last_name,
    g.genre_name,
    p.publisher_name
FROM books b
JOIN authors a ON b.author_id = a.author_id
JOIN genres g ON b.genre_id = g.genre_id
JOIN publishers p ON b.publisher_id = p.publisher_id;
-- Create Denormalized Summary Table for Monthly Book Sales
CREATE TABLE monthly_sales_summary (
    book_id INT,
    month_year VARCHAR(7),  -- Format 'YYYY-MM'
    total_quantity_sold INT,
    total_revenue DECIMAL(10, 2),
    PRIMARY KEY (book_id, month_year),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);

-- Insert monthly summary data (example)
INSERT INTO monthly_sales_summary (book_id, month_year, total_quantity_sold, total_revenue)
SELECT 
    s.book_id,
    DATE_FORMAT(s.sale_date, '%Y-%m') AS month_year,
    SUM(s.quantity_sold) AS total_quantity_sold,
    SUM(s.total_amount) AS total_revenue
FROM sales s
GROUP BY s.book_id, month_year;
-- Select top 10 best-selling books for a given month (with pagination)
SELECT 
    b.book_id, 
    b.title, 
    SUM(s.quantity_sold) AS total_quantity_sold,
    SUM(s.total_amount) AS total_revenue
FROM sales s
JOIN books b ON s.book_id = b.book_id
WHERE s.sale_date BETWEEN '2023-01-01' AND '2023-01-31'
GROUP BY b.book_id
ORDER BY total_quantity_sold DESC
LIMIT 10 OFFSET 0;  -- Adjust OFFSET for pagination (next page: OFFSET 10, 20, etc.)
-- Insert authors
INSERT INTO authors (first_name, last_name) VALUES ('John', 'Doe'), ('Jane', 'Smith');

-- Insert genres
INSERT INTO genres (genre_name) VALUES ('Fiction'), ('Science Fiction'), ('Romance');

-- Insert publishers
INSERT INTO publishers (publisher_name, contact_email) VALUES ('ABC Books', 'contact@abcbooks.com'), ('XYZ Publishers', 'contact@xyzpublishers.com');
-- Insert books
INSERT INTO books (title, author_id, genre_id, publisher_id, price, publication_date, stock_quantity)
VALUES 
('The Adventures of John Doe', 1, 1, 1, 19.99, '2023-01-01', 100),
('Sci-Fi Wonders', 2, 2, 2, 29.99, '2023-02-01', 50);
-- Insert sales data
INSERT INTO sales (book_id, sale_date, quantity_sold, total_amount)
VALUES
(1, '2023-01-15', 10, 199.90),
(1, '2023-01-20', 5, 99.95),
(2, '2023-02-10', 8, 239.92);
-- Query best-selling books with pagination
SELECT 
    b.book_id, 
    b.title, 
    SUM(s.quantity_sold) AS total_quantity_sold,
    SUM(s.total_amount) AS total_revenue
FROM sales s
JOIN books b ON s.book_id = b.book_id
WHERE s.sale_date BETWEEN '2023-01-01' AND '2023-01-31'
GROUP BY b.book_id
ORDER BY total_quantity_sold DESC
LIMIT 10 OFFSET 0;  -- First page (next: OFFSET 10, 20, etc.)
