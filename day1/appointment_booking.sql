CREATE DATABASE hospital_db;
USE hospital_db;
CREATE TABLE departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL
);
CREATE TABLE doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    department_id INT,
    specialty VARCHAR(100),
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);
CREATE TABLE patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(15)
);
CREATE TABLE appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT,
    doctor_id INT,
    appointment_date DATETIME NOT NULL,
    appointment_status ENUM('Scheduled', 'Completed', 'Cancelled') DEFAULT 'Scheduled',
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);
INSERT INTO departments (department_name) VALUES
('Cardiology'),
('Neurology'),
('Orthopedics'),
('Pediatrics');
INSERT INTO doctors (first_name, last_name, department_id, specialty) VALUES
('John', 'Doe', 1, 'Cardiologist'),
('Jane', 'Smith', 1, 'Cardiologist'),
('Mark', 'Brown', 2, 'Neurologist'),
('Sarah', 'Williams', 2, 'Neurologist'),
('David', 'Jones', 3, 'Orthopedic Surgeon'),
('Emily', 'Davis', 3, 'Orthopedic Surgeon'),
('Michael', 'Miller', 4, 'Pediatrician'),
('Jessica', 'Wilson', 4, 'Pediatrician'),
('Chris', 'Taylor', 1, 'Cardiologist'),
('Rachel', 'Anderson', 2, 'Neurologist');
INSERT INTO patients (first_name, last_name, email, phone_number) VALUES
('Alice', 'Johnson', 'alice.johnson@patient.com', '123-456-7890'),
('Bob', 'Smith', 'bob.smith@patient.com', '123-456-7891'),
('Charlie', 'Davis', 'charlie.davis@patient.com', '123-456-7892'),
('David', 'Martinez', 'david.martinez@patient.com', '123-456-7893'),
('Emily', 'Garcia', 'emily.garcia@patient.com', '123-456-7894'),
('Frank', 'Miller', 'frank.miller@patient.com', '123-456-7895'),
('Grace', 'Wilson', 'grace.wilson@patient.com', '123-456-7896'),
('Hannah', 'Lopez', 'hannah.lopez@patient.com', '123-456-7897'),
('Ivy', 'Anderson', 'ivy.anderson@patient.com', '123-456-7898'),
('Jack', 'Thomas', 'jack.thomas@patient.com', '123-456-7899'),
('Lily', 'Harris', 'lily.harris@patient.com', '123-456-7900'),
('Mason', 'Clark', 'mason.clark@patient.com', '123-456-7901'),
('Nora', 'Lewis', 'nora.lewis@patient.com', '123-456-7902'),
('Oliver', 'Young', 'oliver.young@patient.com', '123-456-7903'),
('Penny', 'Walker', 'penny.walker@patient.com', '123-456-7904');
INSERT INTO appointments (patient_id, doctor_id, appointment_date, appointment_status) VALUES
(1, 1, '2023-08-01 10:00:00', 'Scheduled'),
(2, 2, '2023-08-02 11:00:00', 'Scheduled'),
(3, 3, '2023-08-03 14:00:00', 'Scheduled'),
(4, 4, '2023-08-04 09:00:00', 'Scheduled'),
(5, 5, '2023-08-05 15:00:00', 'Scheduled'),
(6, 6, '2023-08-06 10:00:00', 'Scheduled'),
(7, 7, '2023-08-07 11:00:00', 'Scheduled'),
(8, 8, '2023-08-08 14:00:00', 'Scheduled'),
(9, 9, '2023-08-09 09:00:00', 'Scheduled'),
(10, 10, '2023-08-10 13:00:00', 'Scheduled'),
(1, 3, '2023-08-11 10:00:00', 'Completed'),
(2, 4, '2023-08-12 11:00:00', 'Completed'),
(3, 5, '2023-08-13 14:00:00', 'Cancelled'),
(4, 6, '2023-08-14 09:00:00', 'Scheduled'),
(5, 7, '2023-08-15 15:00:00', 'Completed'),
(6, 8, '2023-08-16 10:00:00', 'Scheduled'),
(7, 9, '2023-08-17 11:00:00', 'Cancelled'),
(8, 10, '2023-08-18 14:00:00', 'Scheduled'),
(9, 1, '2023-08-19 09:00:00', 'Completed'),
(10, 2, '2023-08-20 13:00:00', 'Scheduled');
SELECT a.appointment_id, p.first_name AS patient_first_name, p.last_name AS patient_last_name, 
       d.first_name AS doctor_first_name, d.last_name AS doctor_last_name, a.appointment_date, a.appointment_status
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id
JOIN doctors d ON a.doctor_id = d.doctor_id
WHERE DATE(a.appointment_date) = '2023-08-01';
SELECT d.first_name, d.last_name, d.specialty, dep.department_name
FROM doctors d
JOIN departments dep ON d.department_id = dep.department_id
WHERE dep.department_name = 'Cardiology';
SELECT d.first_name, d.last_name, COUNT(a.appointment_id) AS patient_count
FROM doctors d
LEFT JOIN appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id;
