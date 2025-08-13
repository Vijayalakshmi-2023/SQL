CREATE TABLE members (
    member_id INT PRIMARY KEY,
    member_name VARCHAR(100)
);

CREATE TABLE books (
    book_id INT PRIMARY KEY,
    title VARCHAR(200),
    author VARCHAR(100)
);

CREATE TABLE checkouts (
    checkout_id INT PRIMARY KEY,
    member_id INT,
    book_id INT,
    checkout_date DATE,
    return_date DATE,
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);

CREATE TABLE fines (
    fine_id INT PRIMARY KEY,
    member_id INT,
    amount DECIMAL(10, 2),
    fine_date DATE,
    FOREIGN KEY (member_id) REFERENCES members(member_id)
);
SELECT 
    m.member_id,
    m.member_name,
    COUNT(c.checkout_id) AS books_issued
FROM members m
JOIN checkouts c ON m.member_id = c.member_id
GROUP BY m.member_id, m.member_name;
SELECT 
    m.member_id,
    m.member_name,
    SUM(f.amount) AS total_fines
FROM members m
JOIN fines f ON m.member_id = f.member_id
GROUP BY m.member_id, m.member_name
HAVING SUM(f.amount) > 500;
SELECT 
    b.book_id,
    b.title,
    COUNT(c.checkout_id) AS checkout_count
FROM books b
JOIN checkouts c ON b.book_id = c.book_id
GROUP BY b.book_id, b.title
HAVING COUNT(c.checkout_id) > 5;
SELECT 
    c.checkout_id,
    m.member_name,
    b.title,
    c.checkout_date,
    c.return_date
FROM checkouts c
INNER JOIN members m ON c.member_id = m.member_id
INNER JOIN books b ON c.book_id = b.book_id;
SELECT 
    b.book_id,
    b.title,
    c.checkout_id,
    c.checkout_date
FROM books b
LEFT JOIN checkouts c ON b.book_id = c.book_id;
SELECT 
    m1.member_name AS member1,
    m2.member_name AS member2,
    b.title
FROM checkouts c1
JOIN checkouts c2 ON c1.book_id = c2.book_id AND c1.member_id <> c2.member_id
JOIN members m1 ON c1.member_id = m1.member_id
JOIN members m2 ON c2.member_id = m2.member_id
JOIN books b ON c1.book_id = b.book_id
ORDER BY b.title, member1, member2;
