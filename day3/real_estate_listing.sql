CREATE TABLE agents (
    agent_id INT PRIMARY KEY,
    agent_name VARCHAR(100),
    area VARCHAR(100)
);

CREATE TABLE properties (
    property_id INT PRIMARY KEY,
    agent_id INT,
    location VARCHAR(100),
    price DECIMAL(12, 2),
    FOREIGN KEY (agent_id) REFERENCES agents(agent_id)
);

CREATE TABLE clients (
    client_id INT PRIMARY KEY,
    client_name VARCHAR(100)
);

CREATE TABLE inquiries (
    inquiry_id INT PRIMARY KEY,
    property_id INT,
    client_id INT,
    inquiry_date DATE,
    FOREIGN KEY (property_id) REFERENCES properties(property_id),
    FOREIGN KEY (client_id) REFERENCES clients(client_id)
);
SELECT 
    a.agent_id,
    a.agent_name,
    COUNT(p.property_id) AS properties_listed
FROM agents a
JOIN properties p ON a.agent_id = p.agent_id
GROUP BY a.agent_id, a.agent_name;
SELECT 
    location,
    AVG(price) AS avg_price
FROM properties
GROUP BY location;
SELECT 
    a.agent_id,
    a.agent_name,
    COUNT(i.inquiry_id) AS total_inquiries
FROM agents a
JOIN properties p ON a.agent_id = p.agent_id
JOIN inquiries i ON p.property_id = i.property_id
GROUP BY a.agent_id, a.agent_name
HAVING COUNT(i.inquiry_id) > 20;
SELECT 
    p.property_id,
    p.location,
    p.price,
    a.agent_name,
    i.inquiry_id,
    i.inquiry_date
FROM properties p
INNER JOIN agents a ON p.agent_id = a.agent_id
INNER JOIN inquiries i ON p.property_id = i.property_id;
SELECT 
    p.property_id,
    p.location,
    p.price,
    i.inquiry_id
FROM properties p
LEFT JOIN inquiries i ON p.property_id = i.property_id;
SELECT 
    a1.agent_id AS agent1_id,
    a1.agent_name AS agent1_name,
    a2.agent_id AS agent2_id,
    a2.agent_name AS agent2_name,
    a1.area
FROM agents a1
JOIN agents a2 
  ON a1.area = a2.area AND a1.agent_id <> a2.agent_id
ORDER BY a1.area, a1.agent_id;
