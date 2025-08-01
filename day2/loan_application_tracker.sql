CREATE TABLE loans (
    loan_id INT PRIMARY KEY,
    applicant_name VARCHAR(100),
    amount DECIMAL(15,2),
    loan_type VARCHAR(50),
    status VARCHAR(20),
    approval_date DATE
);
SELECT applicant_name, amount, status
FROM loans
WHERE amount BETWEEN 50000 AND 200000;
SELECT *
FROM loans
WHERE loan_type IN ('Home', 'Education');
SELECT *
FROM loans
WHERE approval_date IS NULL;
SELECT *
FROM loans
ORDER BY amount DESC;
