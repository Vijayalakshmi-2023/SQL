CREATE DATABASE loan_db;
USE loan_db;
CREATE TABLE borrowers (
    borrower_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(15),
    address VARCHAR(255)
);
CREATE TABLE loan_types (
    loan_type_id INT AUTO_INCREMENT PRIMARY KEY,
    loan_type_name VARCHAR(50) NOT NULL,  -- e.g., Personal, Car, Home
    interest_rate DECIMAL(5, 2) NOT NULL  -- Interest rate as a percentage
);
CREATE TABLE loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    borrower_id INT,
    loan_type_id INT,
    loan_amount DECIMAL(15, 2) NOT NULL,
    disbursement_date DATE NOT NULL,
    due_date DATE NOT NULL,
    status ENUM('Active', 'Closed') DEFAULT 'Active',
    FOREIGN KEY (borrower_id) REFERENCES borrowers(borrower_id),
    FOREIGN KEY (loan_type_id) REFERENCES loan_types(loan_type_id)
);
CREATE TABLE repayments (
    repayment_id INT AUTO_INCREMENT PRIMARY KEY,
    loan_id INT,
    repayment_amount DECIMAL(15, 2) NOT NULL,
    repayment_date DATE NOT NULL,
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id)
);
INSERT INTO borrowers (first_name, last_name, email, phone_number, address) VALUES
('Alice', 'Johnson', 'alice.johnson@example.com', '123-456-7890', '123 Main St, City, Country'),
('Bob', 'Williams', 'bob.williams@example.com', '123-456-7891', '456 Oak St, City, Country'),
('Charlie', 'Brown', 'charlie.brown@example.com', '123-456-7892', '789 Pine St, City, Country');
INSERT INTO loan_types (loan_type_name, interest_rate) VALUES
('Personal', 5.00),
('Car', 7.50),
('Home', 4.25);
INSERT INTO loans (borrower_id, loan_type_id, loan_amount, disbursement_date, due_date) VALUES
(1, 1, 10000.00, '2023-01-15', '2024-01-15'),
(2, 2, 20000.00, '2023-03-20', '2024-03-20'),
(3, 3, 30000.00, '2023-05-10', '2024-05-10');
INSERT INTO repayments (loan_id, repayment_amount, repayment_date) VALUES
(1, 2000.00, '2023-07-15'),
(1, 1500.00, '2023-08-10'),
(2, 4000.00, '2023-06-20'),
(2, 3000.00, '2023-07-15'),
(3, 5000.00, '2023-08-05');
SELECT b.first_name, b.last_name, SUM(r.repayment_amount) AS total_repaid
FROM borrowers b
JOIN loans l ON b.borrower_id = l.borrower_id
JOIN repayments r ON l.loan_id = r.loan_id
GROUP BY b.borrower_id
ORDER BY total_repaid DESC;
SELECT b.first_name, b.last_name, l.loan_amount, l.due_date
FROM borrowers b
JOIN loans l ON b.borrower_id = l.borrower_id
WHERE l.due_date > CURDATE() AND l.status = 'Active'
ORDER BY l.due_date;
SELECT b.first_name, b.last_name, l.loan_amount, l.due_date, l.status
FROM borrowers b
JOIN loans l ON b.borrower_id = l.borrower_id
ORDER BY l.status DESC, l.due_date;
