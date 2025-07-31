CREATE DATABASE event_portal;
USE event_portal;
CREATE TABLE events (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    event_name VARCHAR(100) NOT NULL,
    event_date DATETIME NOT NULL,
    event_description TEXT
);
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(15)
);
CREATE TABLE registrations (
    registration_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    event_id INT,
    registration_date DATETIME NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (event_id) REFERENCES events(event_id)
);
INSERT INTO events (event_name, event_date, event_description) VALUES
('Tech Conference 2023', '2023-09-15 09:00:00', 'A conference for tech enthusiasts, speakers, and workshops.'),
('Music Festival 2023', '2023-09-25 15:00:00', 'A grand outdoor music festival featuring various artists.'),
('Food Expo 2023', '2023-10-05 11:00:00', 'An expo showcasing the best food and beverages from around the world.'),
('Sports Meet 2023', '2023-10-20 08:00:00', 'A sports event with various competitions and activities.'),
('Art Exhibition 2023', '2023-11-10 10:00:00', 'An exhibition of contemporary art from local and international artists.');
INSERT INTO users (first_name, last_name, email, phone_number) VALUES
('Alice', 'Johnson', 'alice.johnson@example.com', '123-456-7890'),
('Bob', 'Smith', 'bob.smith@example.com', '123-456-7891'),
('Charlie', 'Davis', 'charlie.davis@example.com', '123-456-7892'),
('David', 'Martinez', 'david.martinez@example.com', '123-456-7893'),
('Emily', 'Garcia', 'emily.garcia@example.com', '123-456-7894'),
('Frank', 'Miller', 'frank.miller@example.com', '123-456-7895');
INSERT INTO registrations (user_id, event_id, registration_date) VALUES
(1, 1, '2023-08-01 10:00:00'), -- Alice registered for Tech Conference
(2, 1, '2023-08-01 11:00:00'), -- Bob registered for Tech Conference
(3, 2, '2023-08-02 10:00:00'), -- Charlie registered for Music Festival
(4, 3, '2023-08-02 12:00:00'), -- David registered for Food Expo
(5, 4, '2023-08-03 09:00:00'), -- Emily registered for Sports Meet
(6, 5, '2023-08-03 14:00:00'), -- Frank registered for Art Exhibition
(1, 3, '2023-08-04 10:30:00'), -- Alice registered for Food Expo
(2, 2, '2023-08-04 11:30:00'), -- Bob registered for Music Festival
(3, 4, '2023-08-05 15:00:00'), -- Charlie registered for Sports Meet
(4, 5, '2023-08-06 16:00:00'); -- David registered for Art Exhibition
SELECT e.event_name, COUNT(r.registration_id) AS total_registrations
FROM events e
LEFT JOIN registrations r ON e.event_id = r.event_id
GROUP BY e.event_id
ORDER BY total_registrations DESC;
SELECT event_name, event_date, event_description
FROM events
WHERE event_date > NOW() -- Filters events that are in the future
ORDER BY event_date ASC;
