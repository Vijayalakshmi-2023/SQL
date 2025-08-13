CREATE TABLE fact_loans (
    loan_id INT PRIMARY KEY,
    customer_id INT,
    branch_id INT,
    loan_product_id INT,
    disbursement_date DATE,
    loan_amount DECIMAL(12, 2),
    repayment_amount DECIMAL(12, 2),
    loan_balance DECIMAL(12, 2),  -- Remaining loan balance
    payment_status_id INT,  -- Payment status (paid, overdue, defaulted)
    FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
    FOREIGN KEY (branch_id) REFERENCES dim_branch(branch_id),
    FOREIGN KEY (loan_product_id) REFERENCES dim_loan_product(loan_product_id),
    FOREIGN KEY (payment_status_id) REFERENCES dim_payment_status(payment_status_id),
    FOREIGN KEY (disbursement_date) REFERENCES dim_time(time_id)
);
CREATE TABLE dim_customer (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    email VARCHAR(255),
    phone_number VARCHAR(20),
    address VARCHAR(255)
);
CREATE TABLE dim_branch (
    branch_id INT PRIMARY KEY,
    branch_name VARCHAR(255),
    branch_location VARCHAR(255)
);
CREATE TABLE dim_loan_product (
    loan_product_id INT PRIMARY KEY,
    product_name VARCHAR(255),
    interest_rate DECIMAL(5, 2),
    loan_term INT  -- Loan term in months
);
CREATE TABLE dim_loan_product (
    loan_product_id INT PRIMARY KEY,
    product_name VARCHAR(255),
    interest_rate DECIMAL(5, 2),
    loan_term INT  -- Loan term in months
);
CREATE TABLE dim_time (
    time_id INT PRIMARY KEY,
    date DATE,
    day_of_week INT,
    week INT,
    month INT,
    quarter INT,
    year INT
);
-- Step 1: Extract loan repayment data and calculate remaining balance
WITH raw_loans AS (
    SELECT
        l.loan_id,
        l.customer_id,
        l.branch_id,
        l.loan_product_id,
        l.disbursement_date,
        l.loan_amount,
        SUM(p.payment_amount) AS total_repayment,
        (l.loan_amount - SUM(p.payment_amount)) AS loan_balance,
        CASE
            WHEN (l.loan_amount - SUM(p.payment_amount)) <= 0 THEN 1  -- Paid
            WHEN SUM(p.payment_amount) > l.loan_amount THEN 2  -- Overdue
            ELSE 3  -- Defaulted
        END AS payment_status_id
    FROM loans l
    LEFT JOIN payments p ON l.loan_id = p.loan_id
    GROUP BY l.loan_id, l.customer_id, l.branch_id, l.loan_product_id, l.disbursement_date, l.loan_amount
)
-- Step 2: Load into fact_loans table
INSERT INTO fact_loans (loan_id, customer_id, branch_id, loan_product_id, disbursement_date, loan_amount, repayment_amount, loan_balance, payment_status_id)
SELECT 
    loan_id,
    customer_id,
    branch_id,
    loan_product_id,
    disbursement_date,
    loan_amount,
    total_repayment,
    loan_balance,
    payment_status_id
FROM raw_loans;
SELECT 
    b.branch_name,
    COUNT(CASE WHEN f.payment_status_id = 3 THEN 1 END) AS defaulted_loans,
    COUNT(f.loan_id) AS total_loans,
    (COUNT(CASE WHEN f.payment_status_id = 3 THEN 1 END) * 100.0 / COUNT(f.loan_id)) AS default_rate
FROM fact_loans f
JOIN dim_branch b ON f.branch_id = b.branch_id
GROUP BY b.branch_name
ORDER BY default_rate DESC;
SELECT 
    lp.product_name,
    SUM(f.loan_amount) AS total_disbursed_amount,
    SUM(f.repayment_amount) AS total_repaid_amount,
    AVG(f.loan_balance) AS avg_balance_remaining
FROM fact_loans f
JOIN dim_loan_product lp ON f.loan_product_id = lp.loan_product_id
GROUP BY lp.product_name
ORDER BY total_disbursed_amount DESC;
SELECT 
    t.year,
    t.month,
    COUNT(CASE WHEN f.payment_status_id = 3 THEN 1 END) AS defaulted_loans,
    COUNT(f.loan_id) AS total_loans,
    (COUNT(CASE WHEN f.payment_status_id = 3 THEN 1 END) * 100.0 / COUNT(f.loan_id)) AS default_rate
FROM fact_loans f
JOIN dim_time t ON f.disbursement_date = t.date
GROUP BY t.year, t.month
ORDER BY t.year, t.month;
