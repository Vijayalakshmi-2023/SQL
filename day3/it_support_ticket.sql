CREATE TABLE technicians (
    tech_id INT PRIMARY KEY,
    tech_name VARCHAR(100)
);

CREATE TABLE clients (
    client_id INT PRIMARY KEY,
    client_name VARCHAR(100)
);

CREATE TABLE tickets (
    ticket_id INT PRIMARY KEY,
    client_id INT,
    tech_id INT,
    issue_type VARCHAR(100),
    created_at DATETIME,
    resolved_at DATETIME,
    FOREIGN KEY (client_id) REFERENCES clients(client_id),
    FOREIGN KEY (tech_id) REFERENCES technicians(tech_id)
);
SELECT 
    t.tech_id,
    t.tech_name,
    COUNT(k.ticket_id) AS ticket_count
FROM technicians t
JOIN tickets k ON t.tech_id = k.tech_id
GROUP BY t.tech_id, t.tech_name;
SELECT 
    AVG(TIMESTAMPDIFF(HOUR, created_at, resolved_at)) AS avg_resolution_hours
FROM tickets
WHERE resolved_at IS NOT NULL;
SELECT 
    t.tech_id,
    t.tech_name,
    COUNT(k.ticket_id) AS total_tickets
FROM technicians t
JOIN tickets k ON t.tech_id = k.tech_id
GROUP BY t.tech_id, t.tech_name
HAVING COUNT(k.ticket_id) > 10;
SELECT 
    k.ticket_id,
    k.issue_type,
    k.created_at,
    t.tech_name
FROM tickets k
INNER JOIN technicians t ON k.tech_id = t.tech_id;
SELECT 
    c.client_id,
    c.client_name,
    k.ticket_id,
    k.issue_type
FROM clients c
LEFT JOIN tickets k ON c.client_id = k.client_id;
SELECT 
    t1.ticket_id AS ticket1_id,
    t2.ticket_id AS ticket2_id,
    t1.issue_type
FROM tickets t1
JOIN tickets t2 
  ON t1.issue_type = t2.issue_type AND t1.ticket_id <> t2.ticket_id
ORDER BY t1.issue_type;
