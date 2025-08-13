CREATE TABLE Support_Tickets (
    ticket_id INT PRIMARY KEY,
    customer_id INT,
    issue_description VARCHAR(255),
    issue_reported TIMESTAMP,
    resolved BOOLEAN DEFAULT FALSE
);
CREATE TABLE Escalation_Levels (
    escalation_level_id INT PRIMARY KEY,
    level_name VARCHAR(50)  -- Agent, Supervisor, Manager
);
CREATE TABLE Support_Interactions (
    interaction_id INT PRIMARY KEY,
    ticket_id INT,
    agent_id INT,   -- Agent who handled the interaction
    supervisor_id INT,  -- Supervisor who handled the escalation (if any)
    manager_id INT,  -- Manager who handled the escalation (if any)
    escalation_level_id INT,
    interaction_timestamp TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES Support_Tickets(ticket_id),
    FOREIGN KEY (escalation_level_id) REFERENCES Escalation_Levels(escalation_level_id)
);
CREATE TABLE Agents (
    agent_id INT PRIMARY KEY,
    agent_name VARCHAR(100)
);
CREATE TABLE Supervisors (
    supervisor_id INT PRIMARY KEY,
    supervisor_name VARCHAR(100)
);
CREATE TABLE Managers (
    manager_id INT PRIMARY KEY,
    manager_name VARCHAR(100)
);
WITH RECURSIVE EscalationFlow AS (
    -- Base case: Agent
    SELECT 
        si.interaction_id, 
        si.ticket_id, 
        si.agent_id,
        NULL AS supervisor_id, 
        NULL AS manager_id, 
        si.escalation_level_id, 
        1 AS level,
        si.interaction_timestamp
    FROM Support_Interactions si
    WHERE si.escalation_level_id = 1  -- Agent level
    
    UNION ALL
    
    -- Recursive case: Supervisor
    SELECT 
        si.interaction_id, 
        si.ticket_id, 
        NULL AS agent_id,
        si.supervisor_id, 
        NULL AS manager_id, 
        si.escalation_level_id, 
        ef.level + 1 AS level,
        si.interaction_timestamp
    FROM Support_Interactions si
    JOIN EscalationFlow ef ON si.ticket_id = ef.ticket_id
    WHERE si.escalation_level_id = 2  -- Supervisor level
    
    UNION ALL
    
    -- Recursive case: Manager
    SELECT 
        si.interaction_id, 
        si.ticket_id, 
        NULL AS agent_id,
        NULL AS supervisor_id, 
        si.manager_id, 
        si.escalation_level_id, 
        ef.level + 1 AS level,
        si.interaction_timestamp
    FROM Support_Interactions si
    JOIN EscalationFlow ef ON si.ticket_id = ef.ticket_id
    WHERE si.escalation_level_id = 3  -- Manager level
)
SELECT 
    interaction_id, 
    ticket_id, 
    agent_id, 
    supervisor_id, 
    manager_id, 
    escalation_level_id, 
    level, 
    interaction_timestamp
FROM EscalationFlow
ORDER BY ticket_id, level;
WITH OrderedInteractions AS (
    SELECT 
        si.interaction_id, 
        si.ticket_id, 
        si.agent_id, 
        si.supervisor_id, 
        si.manager_id, 
        si.escalation_level_id, 
        si.interaction_timestamp, 
        ROW_NUMBER() OVER (PARTITION BY si.ticket_id ORDER BY si.interaction_timestamp) AS event_order
    FROM Support_Interactions si
)
SELECT * 
FROM OrderedInteractions
ORDER BY ticket_id, event_order;
WITH AgentEscalationCount AS (
    SELECT 
        si.agent_id, 
        COUNT(si.ticket_id) AS escalated_tickets
    FROM Support_Interactions si
    WHERE si.escalation_level_id = 1  -- Agent level
    GROUP BY si.agent_id
),
RankedAgents AS (
    SELECT 
        ae.agent_id, 
        ae.escalated_tickets, 
        RANK() OVER (ORDER BY ae.escalated_tickets DESC) AS escalation_rank
    FROM AgentEscalationCount ae
)
SELECT 
    ra.agent_id, 
    a.agent_name, 
    ra.escalated_tickets, 
    ra.escalation_rank
FROM RankedAgents ra
JOIN Agents a ON ra.agent_id = a.agent_id
ORDER BY ra.escalation_rank;
WITH ResolutionTime AS (
    SELECT 
        si.ticket_id, 
        si.interaction_id, 
        si.agent_id, 
        si.supervisor_id, 
        si.manager_id, 
        si.escalation_level_id, 
        si.interaction_timestamp,
        LAG(si.interaction_timestamp) OVER (PARTITION BY si.ticket_id ORDER BY si.interaction_timestamp) AS previous_interaction_timestamp
    FROM Support_Interactions si
)
SELECT 
    ticket_id, 
    interaction_id, 
    agent_id, 
    supervisor_id, 
    manager_id, 
    escalation_level_id, 
    interaction_timestamp, 
    previous_interaction_timestamp,
    EXTRACT(EPOCH FROM (interaction_timestamp - previous_interaction_timestamp)) / 3600 AS resolution_time_diff_hours
FROM ResolutionTime
WHERE previous_interaction_timestamp IS NOT NULL
ORDER BY ticket_id, interaction_timestamp;
