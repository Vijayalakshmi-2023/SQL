CREATE TABLE officers (
    officer_id INT PRIMARY KEY,
    officer_name VARCHAR(100)
);

CREATE TABLE clients (
    client_id INT PRIMARY KEY,
    client_name VARCHAR(100),
    city VARCHAR(100)
);

CREATE TABLE loans (
    loan_id INT PRIMARY KEY,
    client_id INT,
    officer_id INT,
    amount DECIMAL(12, 2),
    issue_date DATE,
    FOREIGN KEY (client_id) REFERENCES clients(client_id),
    FOREIGN KEY (officer_id) REFERENCES officers(officer_id)
);

CREATE TABLE repayments (
    repayment_id INT PRIMARY KEY,
    loan_id INT,
    amount_paid DECIMAL(12, 2),
    payment_date DATE,
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id)
);
SELECT 
    o.officer_id,
    o.officer_name,
    COUNT(l.loan_id) AS total_loans
FROM officers o
JOIN loans l ON o.officer_id = l.officer_id
GROUP BY o.officer_id, o.officer_name;
SELECT 
    c.client_id,
    c.client_name,
    SUM(r.amount_paid) AS total_repaid
FROM clients c
JOIN loans l ON c.client_id = l.client_id
JOIN repayments r ON l.loan_id = r.loan_id
GROUP BY c.client_id, c.client_name
HAVING SUM(r.amount_paid) > 100000;
SELECT 
    o.officer_id,
    o.officer_name,
    COUNT(l.loan_id) AS loan_count
FROM officers o
JOIN loans l ON o.officer_id = l.officer_id
GROUP BY o.officer_id, o.officer_name
HAVING COUNT(l.loan_id) > 10;
SELECT 
    c.client_name,
    l.loan_id,
    l.amount,
    o.officer_name
FROM clients c
INNER JOIN loans l ON c.client_id = l.client_id
INNER JOIN officers o ON l.officer_id = o.officer_id;
-- LEFT JOIN
SELECT 
    l.loan_id,
    l.amount AS loan_amount,
    r.repayment_id,
    r.amount_paid
FROM loans l
LEFT JOIN repayments r ON l.loan_id = r.loan_id

UNION

-- RIGHT JOIN
SELECT 
    l.loan_id,
    l.amount AS loan_amount,
    r.repayment_id,
    r.amount_paid
FROM loans l
RIGHT JOIN repayments r ON l.loan_id = r.loan_id;
SELECT 
    c1.client_name AS client1,
    c2.client_name AS client2,
    c1.city
FROM clients c1
JOIN clients c2 
  ON c1.city = c2.city AND c1.client_id <> c2.client_id
ORDER BY c1.city;
