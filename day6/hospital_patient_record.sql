-- Patients Table
CREATE TABLE patients (
    patient_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    date_of_birth DATE,
    gender ENUM('Male', 'Female', 'Other'),
    contact_number VARCHAR(15) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL
);

-- Doctors Table
CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    department_id INT,
    specialization VARCHAR(255),
    contact_number VARCHAR(15),
    email VARCHAR(255) UNIQUE NOT NULL,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- Departments Table
CREATE TABLE departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(255) NOT NULL UNIQUE
);

-- Appointments Table
CREATE TABLE appointments (
    appointment_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT,
    doctor_id INT,
    appointment_date DATETIME NOT NULL,
    appointment_type VARCHAR(255),
    status ENUM('Scheduled', 'Completed', 'Cancelled') NOT NULL,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);

-- Medications Table
CREATE TABLE medications (
    medication_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT,
    doctor_id INT,
    medication_name VARCHAR(255),
    dosage VARCHAR(255),
    start_date DATE,
    end_date DATE,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);
-- Index on appointment_date for quick search by appointment date
CREATE INDEX idx_appointment_date ON appointments(appointment_date);

-- Index on patient_id for fast lookup by patient
CREATE INDEX idx_patient_id ON appointments(patient_id);

-- Index on doctor_id for fast lookup by doctor
CREATE INDEX idx_doctor_id ON appointments(doctor_id);
EXPLAIN SELECT * FROM appointments
WHERE appointment_date BETWEEN '2023-01-01' AND '2023-01-31'
ORDER BY appointment_date DESC;
SELECT p.first_name, p.last_name, COUNT(a.appointment_id) AS visit_count
FROM patients p
JOIN appointments a ON p.patient_id = a.patient_id
GROUP BY p.patient_id
HAVING visit_count = (
    SELECT MAX(visit_count)
    FROM (
        SELECT COUNT(appointment_id) AS visit_count
        FROM appointments
        GROUP BY patient_id
    ) AS subquery
);
-- Denormalized View for Dashboard Analytics
CREATE VIEW dashboard_analytics AS
SELECT p.patient_id, p.first_name AS patient_first_name, p.last_name AS patient_last_name,
       COUNT(a.appointment_id) AS total_appointments,
       d.department_name AS department_name,
       COUNT(DISTINCT a.doctor_id) AS distinct_doctors
FROM patients p
JOIN appointments a ON p.patient_id = a.patient_id
JOIN doctors doc ON a.doctor_id = doc.doctor_id
JOIN departments d ON doc.department_id = d.department_id
GROUP BY p.patient_id, d.department_name;
SELECT a.appointment_id, a.appointment_date, a.status, d.first_name AS doctor_first_name, d.last_name AS doctor_last_name
FROM appointments a
JOIN doctors d ON a.doctor_id = d.doctor_id
WHERE a.patient_id = ?
ORDER BY a.appointment_date DESC
LIMIT 5;
