-- Table for Agents
CREATE TABLE agents (
    agent_id INT PRIMARY KEY,
    name VARCHAR(100),
    city VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(15)
);

-- Table for Properties
CREATE TABLE properties (
    property_id INT PRIMARY KEY,
    agent_id INT,
    property_type VARCHAR(50),
    city VARCHAR(100),
    list_date DATE,
    sale_price DECIMAL(15, 2),
    status VARCHAR(50), -- 'Sold' or 'Listed'
    FOREIGN KEY (agent_id) REFERENCES agents(agent_id)
);

-- Table for Sales
CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    property_id INT,
    client_id INT,
    sale_date DATE,
    sale_price DECIMAL(15, 2),
    FOREIGN KEY (property_id) REFERENCES properties(property_id),
    FOREIGN KEY (client_id) REFERENCES clients(client_id)
);

-- Table for Clients
CREATE TABLE clients (
    client_id INT PRIMARY KEY,
    name VARCHAR(100),
    contact_info VARCHAR(255)
);
SELECT a.agent_id, a.name, SUM(s.sale_price) AS total_sales
FROM agents a
JOIN properties p ON a.agent_id = p.agent_id
JOIN sales s ON p.property_id = s.property_id
GROUP BY a.agent_id, a.name
HAVING SUM(s.sale_price) > (
    SELECT AVG(total_sales) 
    FROM (
        SELECT SUM(s.sale_price) AS total_sales
        FROM agents a
        JOIN properties p ON a.agent_id = p.agent_id
        JOIN sales s ON p.property_id = s.property_id
        GROUP BY a.agent_id
    ) AS company_sales
);
SELECT p.property_id, p.property_type,
       CASE
           WHEN p.property_type IN ('House', 'Apartment', 'Villa') THEN 'Residential'
           WHEN p.property_type IN ('Office', 'Retail') THEN 'Commercial'
           ELSE 'Other'
       END AS property_category
FROM properties p;
-- Sold Properties
SELECT p.property_id, p.city, p.list_date, p.sale_price, 'Sold' AS status
FROM properties p
JOIN sales s ON p.property_id = s.property_id
WHERE p.status = 'Sold'

UNION ALL

-- Listed Properties
SELECT p.property_id, p.city, p.list_date, NULL AS sale_price, 'Listed' AS status
FROM properties p
WHERE p.status = 'Listed';
SELECT a.agent_id, a.name, MAX(s.sale_price) AS highest_sale
FROM agents a
JOIN properties p ON a.agent_id = p.agent_id
JOIN sales s ON p.property_id = s.property_id
WHERE s.sale_price = (
    SELECT MAX(sale_price)
    FROM sales s2
    JOIN properties p2 ON s2.property_id = p2.property_id
    WHERE p2.agent_id = a.agent_id
)
GROUP BY a.agent_id, a.name;
SELECT a.agent_id, a.name, p.city, SUM(s.sale_price) AS total_sales
FROM agents a
JOIN properties p ON a.agent_id = p.agent_id
JOIN sales s ON p.property_id = s.property_id
GROUP BY a.agent_id, a.name, p.city;
