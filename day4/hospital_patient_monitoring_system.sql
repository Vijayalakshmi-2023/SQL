-- Table for Patients
CREATE TABLE patients (
    patient_id INT PRIMARY KEY,
    name VARCHAR(100),
    dob DATE,
    gender CHAR(1),
    address VARCHAR(255),
    phone VARCHAR(15),
    email VARCHAR(100)
);

-- Table for Appointments
CREATE TABLE appointments (
    appointment_id INT PRIMARY KEY,
    patient_id INT,
    doctor_id INT,
    appointment_date DATE,
    bill_amount DECIMAL(10, 2),
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);

-- Table for Doctors
CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY,
    name VARCHAR(100),
    specialization VARCHAR(100),
    department VARCHAR(100)
);

-- Table for Treatments
CREATE TABLE treatments (
    treatment_id INT PRIMARY KEY,
    patient_id INT,
    doctor_id INT,
    treatment_date DATE,
    treatment_description VARCHAR(255),
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);
SELECT doctor_id, COUNT(*) AS total_patients
FROM (
    SELECT DISTINCT patient_id, doctor_id
    FROM treatments
) AS unique_patients
GROUP BY doctor_id;
SELECT patient_id, COUNT(*) AS treatment_count
FROM treatments
GROUP BY patient_id
HAVING COUNT(*) > 3;
SELECT p.patient_id, p.name,
       CASE 
           WHEN COUNT(t.treatment_id) > 5 OR SUM(a.bill_amount) > 1000 THEN 'Critical'
           ELSE 'Normal'
       END AS patient_status
FROM patients p
JOIN treatments t ON p.patient_id = t.patient_id
JOIN appointments a ON p.patient_id = a.patient_id
GROUP BY p.patient_id, p.name;
SELECT d.department, p.patient_id, p.name, COUNT(a.appointment_id) AS stay_duration
FROM doctors d
JOIN appointments a ON a.doctor_id = d.doctor_id
JOIN patients p ON p.patient_id = a.patient_id
WHERE COUNT(a.appointment_id) = (
    SELECT MAX(appointment_count)
    FROM (
        SELECT patient_id, COUNT(*) AS appointment_count
        FROM appointments
        WHERE doctor_id = d.doctor_id
        GROUP BY patient_id
    ) AS department_appointments
)
GROUP BY d.department, p.patient_id, p.name;
SELECT DISTINCT p.patient_id, p.name
FROM patients p
JOIN treatments t ON p.patient_id = t.patient_id
WHERE t.treatment_date >= CURDATE() - INTERVAL 30 DAY;
-- Outpatient records: Patients who have appointments but no treatment.
SELECT p.patient_id, p.name, 'Outpatient' AS patient_type, a.appointment_date
FROM patients p
JOIN appointments a ON p.patient_id = a.patient_id
LEFT JOIN treatments t ON p.patient_id = t.patient_id
WHERE t.patient_id IS NULL

UNION

-- Inpatient records: Patients who have a treatment record (indicating hospitalization).
SELECT p.patient_id, p.name, 'Inpatient' AS patient_type, t.treatment_date
FROM patients p
JOIN treatments t ON p.patient_id = t.patient_id;
