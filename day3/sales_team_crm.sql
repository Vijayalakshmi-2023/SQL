CREATE TABLE sales_reps (
    rep_id INT PRIMARY KEY,
    rep_name VARCHAR(100),
    region VARCHAR(100)
);

CREATE TABLE leads (
    lead_id INT PRIMARY KEY,
    rep_id INT,
    client_id INT,
    lead_date DATE,
    conversion_date DATE,  -- NULL if not converted yet
    status VARCHAR(20),    -- e.g. 'Open', 'Closed'
    FOREIGN KEY (rep_id) REFERENCES sales_reps(rep_id),
    FOREIGN KEY (client_id) REFERENCES clients(client_id)
);

CREATE TABLE clients (
    client_id INT PRIMARY KEY,
    client_name VARCHAR(100),
    region VARCHAR(100)
);

CREATE TABLE meetings (
    meeting_id INT PRIMARY KEY,
    rep_id INT,
    client_id INT,
    meeting_date DATE,
    FOREIGN KEY (rep_id) REFERENCES sales_reps(rep_id),
    FOREIGN KEY (client_id) REFERENCES clients(client_id)
);
SELECT rep_id, COUNT(*) AS lead_count
FROM leads
GROUP BY rep_id;
SELECT rep_id, AVG(DATEDIFF(conversion_date, lead_date)) AS avg_conversion_time
FROM leads
WHERE conversion_date IS NOT NULL
GROUP BY rep_id;
SELECT rep_id, COUNT(*) AS closed_deals
FROM leads
WHERE status = 'Closed'
GROUP BY rep_id
HAVING COUNT(*) > 5;
SELECT r.rep_id, r.rep_name, l.lead_id, l.status, l.lead_date
FROM sales_reps r
INNER JOIN leads l ON r.rep_id = l.rep_id;
SELECT r.rep_id, r.rep_name, c.client_id, c.client_name
FROM sales_reps r
RIGHT JOIN clients c ON r.rep_id = (
    SELECT rep_id FROM leads WHERE client_id = c.client_id LIMIT 1
);
SELECT
    r1.rep_id AS rep1_id, r1.rep_name AS rep1_name,
    r2.rep_id AS rep2_id, r2.rep_name AS rep2_name,
    r1.region
FROM sales_reps r1
JOIN sales_reps r2 ON r1.region = r2.region AND r1.rep_id <> r2.rep_id
ORDER BY r1.region, r1.rep_id;
