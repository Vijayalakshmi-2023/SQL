-- Table for Customers
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    dob DATE,
    email VARCHAR(100),
    phone VARCHAR(15)
);

-- Table for Loan Types
CREATE TABLE loan_types (
    loan_type_id INT PRIMARY KEY,
    type_name VARCHAR(50),
    interest_rate DECIMAL(5, 2)
);

-- Table for Loans
CREATE TABLE loans (
    loan_id INT PRIMARY KEY,
    customer_id INT,
    loan_type_id INT,
    loan_amount DECIMAL(15, 2),
    disbursal_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (loan_type_id) REFERENCES loan_types(loan_type_id)
);

-- Table for Payments
CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    loan_id INT,
    payment_date DATE,
    payment_amount DECIMAL(15, 2),
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id)
);
SELECT l.loan_id, l.customer_id, l.loan_amount,
       (l.loan_amount - COALESCE(SUM(p.payment_amount), 0)) AS outstanding_balance
FROM loans l
LEFT JOIN payments p ON l.loan_id = p.loan_id
GROUP BY l.loan_id, l.customer_id, l.loan_amount;
SELECT lt.type_name, SUM(p.payment_amount) AS total_repayments
FROM payments p
JOIN loans l ON p.loan_id = l.loan_id
JOIN loan_types lt ON l.loan_type_id = lt.loan_type_id
GROUP BY lt.type_name;
SELECT l.loan_id, l.customer_id,
       CASE
           WHEN (l.loan_amount - COALESCE(SUM(p.payment_amount), 0)) <= 0 THEN 'Closed'
           WHEN DATEDIFF(CURDATE(), l.disbursal_date) <= 30 THEN 'On Track'
           ELSE 'Delayed'
       END AS loan_status
FROM loans l
LEFT JOIN payments p ON l.loan_id = p.loan_id
GROUP BY l.loan_id, l.customer_id, l.loan_amount, l.disbursal_date;
-- Active Loans: Loans with an outstanding balance
SELECT l.loan_id, l.customer_id, 'Active' AS loan_status
FROM loans l
LEFT JOIN payments p ON l.loan_id = p.loan_id
GROUP BY l.loan_id, l.customer_id
HAVING (l.loan_amount - COALESCE(SUM(p.payment_amount), 0)) > 0

UNION ALL

-- Closed Loans: Loans with no outstanding balance
SELECT l.loan_id, l.customer_id, 'Closed' AS loan_status
FROM loans l
LEFT JOIN payments p ON l.loan_id = p.loan_id
GROUP BY l.loan_id, l.customer_id
HAVING (l.loan_amount - COALESCE(SUM(p.payment_amount), 0)) = 0;
SELECT c.customer_id, c.name
FROM customers c
JOIN loans l ON c.customer_id = l.customer_id
JOIN payments p ON l.loan_id = p.loan_id
WHERE p.payment_amount > (
    SELECT AVG(payment_amount)
    FROM payments
    WHERE loan_id = l.loan_id
);
SELECT p.payment_id, p.loan_id, p.payment_date,
       DATEDIFF(CURDATE(), p.payment_date) AS days_late
FROM payments p
JOIN loans l ON p.loan_id = l.loan_id
WHERE DATEDIFF(CURDATE(), p.payment_date) > 30
ORDER BY days_late DESC;
