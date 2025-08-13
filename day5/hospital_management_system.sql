-- Table for Departments
CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL
);

-- Table for Doctors
CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    specialization VARCHAR(100),
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- Table for Patients
CREATE TABLE patients (
    patient_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    age INT CHECK (age BETWEEN 0 AND 120),
    contact_info VARCHAR(255) NOT NULL
);

-- Table for Appointments
CREATE TABLE appointments (
    appointment_id INT PRIMARY KEY,
    patient_id INT,
    doctor_id INT,
    appointment_date DATE,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);
INSERT INTO patients (patient_id, name, age, contact_info)
VALUES (1, 'John Doe', 30, '1234 Elm St, Springfield');
INSERT INTO appointments (appointment_id, patient_id, doctor_id, appointment_date)
VALUES (1, 1, 2, '2025-08-15'); -- Assuming doctor with doctor_id = 2
UPDATE doctors
SET specialization = 'Cardiologist', department_id = 3
WHERE doctor_id = 2;
DELETE FROM patients
WHERE patient_id = 1;
ALTER TABLE patients
ADD CONSTRAINT age_check CHECK (age BETWEEN 0 AND 120);
-- Start a transaction
BEGIN;

-- Set a savepoint before deleting
SAVEPOINT before_delete;

-- Delete the patient record
DELETE FROM patients WHERE patient_id = 1;

-- If there is an error or we decide to rollback, use:
-- ROLLBACK TO before_delete;  -- Uncomment this to rollback

-- Commit the transaction if everything is fine
COMMIT;
-- Start a transaction
BEGIN;

-- Update the doctor’s specialization and department
UPDATE doctors
SET specialization = 'Neurologist', department_id = 4
WHERE doctor_id = 2;

-- Update the doctor for a specific appointment
UPDATE appointments
SET doctor_id = 3
WHERE appointment_id = 1; -- Assuming appointment_id = 1

-- If any error occurs, we can rollback:
-- ROLLBACK;

-- If everything is successful, commit the transaction
COMMIT;
