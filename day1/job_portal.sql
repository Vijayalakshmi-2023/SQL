CREATE DATABASE job_portal_db;
USE job_portal_db;
CREATE TABLE companies (
    company_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(150),
    contact_info VARCHAR(150)
);
CREATE TABLE jobs (
    job_id INT AUTO_INCREMENT PRIMARY KEY,
    company_id INT,
    job_title VARCHAR(100) NOT NULL,
    job_description TEXT,
    date_posted DATE NOT NULL,
    FOREIGN KEY (company_id) REFERENCES companies(company_id)
);
CREATE TABLE applicants (
    applicant_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(15)
);
CREATE TABLE applications (
    application_id INT AUTO_INCREMENT PRIMARY KEY,
    applicant_id INT,
    job_id INT,
    application_date DATETIME NOT NULL,
    status VARCHAR(50),
    FOREIGN KEY (applicant_id) REFERENCES applicants(applicant_id),
    FOREIGN KEY (job_id) REFERENCES jobs(job_id)
);
INSERT INTO companies (name, location, contact_info) VALUES
('TechSolutions', 'San Francisco, CA', 'contact@techsolutions.com'),
('HealthCorp', 'New York, NY', 'info@healthcorp.com'),
('EduGlobal', 'Los Angeles, CA', 'hr@eduglobal.com'),
('RetailWorld', 'Chicago, IL', 'careers@retailworld.com'),
('AutoMakers', 'Detroit, MI', 'jobs@automakers.com');
INSERT INTO jobs (company_id, job_title, job_description, date_posted) VALUES
(1, 'Software Engineer', 'Develop and maintain software solutions.', '2023-08-01'),
(2, 'Nurse', 'Provide medical care and assist doctors.', '2023-08-02'),
(3, 'Marketing Manager', 'Oversee marketing strategies and campaigns.', '2023-08-03'),
(4, 'Sales Associate', 'Assist customers and drive sales in the retail sector.', '2023-08-04'),
(5, 'Mechanical Engineer', 'Design and improve automotive components.', '2023-08-05'),
(1, 'Data Analyst', 'Analyze data to provide business insights.', '2023-08-06'),
(2, 'Pharmacist', 'Dispense medications and provide healthcare advice.', '2023-08-07'),
(3, 'Graphic Designer', 'Design marketing materials and content.', '2023-08-08'),
(4, 'Product Manager', 'Lead product development and strategy.', '2023-08-09'),
(5, 'Quality Assurance', 'Ensure product quality and testing processes.', '2023-08-10');
INSERT INTO applicants (first_name, last_name, email, phone_number) VALUES
('Alice', 'Johnson', 'alice.johnson@example.com', '123-456-7890'),
('Bob', 'Smith', 'bob.smith@example.com', '123-456-7891'),
('Charlie', 'Davis', 'charlie.davis@example.com', '123-456-7892'),
('David', 'Martinez', 'david.martinez@example.com', '123-456-7893'),
('Emily', 'Garcia', 'emily.garcia@example.com', '123-456-7894'),
('Frank', 'Miller', 'frank.miller@example.com', '123-456-7895'),
('Grace', 'Lee', 'grace.lee@example.com', '123-456-7896'),
('Hannah', 'Walker', 'hannah.walker@example.com', '123-456-7897'),
('Ivy', 'Moore', 'ivy.moore@example.com', '123-456-7898'),
('James', 'Taylor', 'james.taylor@example.com', '123-456-7899');
INSERT INTO applications (applicant_id, job_id, application_date, status) VALUES
(1, 1, '2023-08-01 10:00:00', 'Pending'),
(2, 2, '2023-08-02 11:00:00', 'Accepted'),
(3, 3, '2023-08-03 12:30:00', 'Rejected'),
(4, 4, '2023-08-04 13:00:00', 'Pending'),
(5, 5, '2023-08-05 14:00:00', 'Pending'),
(6, 6, '2023-08-06 15:00:00', 'Accepted'),
(7, 7, '2023-08-07 16:30:00', 'Rejected'),
(8, 8, '2023-08-08 17:00:00', 'Pending'),
(9, 9, '2023-08-09 10:30:00', 'Pending'),
(10, 10, '2023-08-10 11:00:00', 'Accepted');
SELECT j.job_title, j.job_description, a.application_date, a.status
FROM applications a
JOIN jobs j ON a.job_id = j.job_id
WHERE a.applicant_id = 1;  -- Example for applicant with ID 1 (Alice)
SELECT j.job_title, COUNT(a.application_id) AS total_applications
FROM jobs j
LEFT JOIN applications a ON j.job_id = a.job_id
GROUP BY j.job_id
ORDER BY total_applications DESC;
