CREATE DATABASE voting_db;
USE voting_db;
CREATE TABLE voters (
    voter_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(15)
);
CREATE TABLE candidates (
    candidate_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    election_id INT,
    FOREIGN KEY (election_id) REFERENCES elections(election_id)
);
CREATE TABLE elections (
    election_id INT AUTO_INCREMENT PRIMARY KEY,
    election_name VARCHAR(100) NOT NULL,
    election_date DATE NOT NULL
);
CREATE TABLE votes (
    vote_id INT AUTO_INCREMENT PRIMARY KEY,
    voter_id INT,
    candidate_id INT,
    election_id INT,
    vote_date DATETIME NOT NULL,
    FOREIGN KEY (voter_id) REFERENCES voters(voter_id),
    FOREIGN KEY (candidate_id) REFERENCES candidates(candidate_id),
    FOREIGN KEY (election_id) REFERENCES elections(election_id),
    CONSTRAINT unique_vote_per_election UNIQUE(voter_id, election_id) -- Ensure one vote per election per voter
);
INSERT INTO elections (election_name, election_date) VALUES
('Presidential Election 2023', '2023-11-01'),
('Gubernatorial Election 2023', '2023-12-01'),
('Local Council Election 2023', '2023-12-15');
INSERT INTO candidates (first_name, last_name, election_id) VALUES
('John', 'Doe', 1), -- Presidential Election
('Jane', 'Smith', 1), -- Presidential Election
('Mike', 'Johnson', 2), -- Gubernatorial Election
('Sarah', 'Lee', 2), -- Gubernatorial Election
('Tom', 'Brown', 3), -- Local Council Election
('Emily', 'Davis', 3); -- Local Council Election
INSERT INTO voters (first_name, last_name, email, phone_number) VALUES
('Alice', 'Johnson', 'alice.johnson@example.com', '123-456-7890'),
('Bob', 'Smith', 'bob.smith@example.com', '123-456-7891'),
('Charlie', 'Davis', 'charlie.davis@example.com', '123-456-7892'),
('David', 'Martinez', 'david.martinez@example.com', '123-456-7893'),
('Emily', 'Garcia', 'emily.garcia@example.com', '123-456-7894'),
('Frank', 'Miller', 'frank.miller@example.com', '123-456-7895'),
('Grace', 'Wilson', 'grace.wilson@example.com', '123-456-7896'),
('Hannah', 'Lopez', 'hannah.lopez@example.com', '123-456-7897'),
('Ivy', 'King', 'ivy.king@example.com', '123-456-7898'),
('Jack', 'Lee', 'jack.lee@example.com', '123-456-7899');
INSERT INTO votes (voter_id, candidate_id, election_id, vote_date) VALUES
(1, 1, 1, '2023-11-01 10:00:00'), -- Alice voted for John Doe in Presidential Election
(2, 2, 1, '2023-11-01 11:30:00'), -- Bob voted for Jane Smith in Presidential Election
(3, 1, 1, '2023-11-01 12:00:00'), -- Charlie voted for John Doe in Presidential Election
(4, 2, 1, '2023-11-01 13:00:00'), -- David voted for Jane Smith in Presidential Election
(5, 2, 2, '2023-12-01 09:30:00'), -- Emily voted for Sarah Lee in Gubernatorial Election
(6, 1, 2, '2023-12-01 10:15:00'), -- Frank voted for Mike Johnson in Gubernatorial Election
(7, 2, 3, '2023-12-15 08:45:00'), -- Grace voted for Emily Davis in Local Council Election
(8, 1, 3, '2023-12-15 09:00:00'), -- Hannah voted for Tom Brown in Local Council Election
(9, 2, 3, '2023-12-15 09:30:00'), -- Ivy voted for Emily Davis in Local Council Election
(10, 1, 3, '2023-12-15 10:00:00'); -- Jack voted for Tom Brown in Local Council Election
SELECT c.first_name, c.last_name, COUNT(v.vote_id) AS total_votes
FROM candidates c
LEFT JOIN votes v ON c.candidate_id = v.candidate_id
WHERE v.election_id = 1 -- Replace with the desired election_id
GROUP BY c.candidate_id
ORDER BY total_votes DESC;
SELECT c.first_name, c.last_name, COUNT(v.vote_id) AS total_votes
FROM candidates c
LEFT JOIN votes v ON c.candidate_id = v.candidate_id
WHERE v.election_id = 1 -- Replace with the desired election_id
GROUP BY c.candidate_id
ORDER BY total_votes DESC
LIMIT 1; -- Only get the winner (top vote-getter)
UPDATE votes
SET candidate_id = 2, vote_date = '2023-11-01 14:00:00' -- New candidate and vote timestamp
WHERE vote_id = 1; -- Specify the vote record ID to update
