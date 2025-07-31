CREATE DATABASE library_db;
USE library_db;
CREATE TABLE members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);
CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    author VARCHAR(100) NOT NULL,
    published_year INT,
    isbn VARCHAR(20) UNIQUE NOT NULL
);
CREATE TABLE borrowings (
    borrowing_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT,
    book_id INT,
    borrow_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE,
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);
INSERT INTO members (first_name, last_name, email) VALUES
('Alice', 'Johnson', 'alice.johnson@example.com'),
('Bob', 'Smith', 'bob.smith@example.com'),
('Charlie', 'Davis', 'charlie.davis@example.com'),
('David', 'Martinez', 'david.martinez@example.com'),
('Emily', 'Garcia', 'emily.garcia@example.com'),
('Frank', 'Miller', 'frank.miller@example.com'),
('Grace', 'Wilson', 'grace.wilson@example.com'),
('Hannah', 'Lopez', 'hannah.lopez@example.com'),
('Ivy', 'Anderson', 'ivy.anderson@example.com'),
('Jack', 'Thomas', 'jack.thomas@example.com');
INSERT INTO books (title, author, published_year, isbn) VALUES
('The Great Gatsby', 'F. Scott Fitzgerald', 1925, '9780743273565'),
('Moby Dick', 'Herman Melville', 1851, '9781503280786'),
('1984', 'George Orwell', 1949, '9780451524935'),
('To Kill a Mockingbird', 'Harper Lee', 1960, '9780061120084'),
('The Catcher in the Rye', 'J.D. Salinger', 1951, '9780316769488'),
('Pride and Prejudice', 'Jane Austen', 1813, '9780141439518'),
('The Lord of the Rings', 'J.R.R. Tolkien', 1954, '9780544003415'),
('The Hobbit', 'J.R.R. Tolkien', 1937, '9780261102217'),
('Animal Farm', 'George Orwell', 1945, '9780451526342'),
('Brave New World', 'Aldous Huxley', 1932, '9780060850524');
INSERT INTO borrowings (member_id, book_id, borrow_date, due_date) VALUES
(1, 1, '2023-06-01', '2023-06-15'),
(2, 3, '2023-06-05', '2023-06-20'),
(4, 7, '2023-06-10', '2023-06-25'),
(5, 8, '2023-06-12', '2023-06-26'),
(6, 2, '2023-06-15', '2023-06-30');
SELECT b.title, b.author, bo.borrow_date, bo.due_date
FROM borrowings bo
JOIN books b ON bo.book_id = b.book_id
WHERE bo.member_id = 1;
SELECT b.title, b.author, bo.due_date
FROM borrowings bo
JOIN books b ON bo.book_id = b.book_id
WHERE bo.due_date < CURDATE() AND bo.return_date IS NULL;
SELECT b.title, b.author, COUNT(bo.book_id) AS borrow_count
FROM borrowings bo
JOIN books b ON bo.book_id = b.book_id
GROUP BY b.book_id
ORDER BY borrow_count DESC;

