CREATE TABLE patients (
    patient_id INT PRIMARY KEY,
    patient_name VARCHAR(100),
    birth_date DATE
);

CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY,
    doctor_name VARCHAR(100)
);

CREATE TABLE appointments (
    appointment_id INT PRIMARY KEY,
    patient_id INT,
    doctor_id INT,
    appointment_date DATE,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);

CREATE TABLE treatments (
    treatment_id INT PRIMARY KEY,
    appointment_id INT,
    treatment_cost DECIMAL(10,2),
    FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id)
);
SELECT d.doctor_id, d.doctor_name, COUNT(DISTINCT a.patient_id) AS patients_treated
FROM doctors d
JOIN appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.doctor_name;
SELECT d.doctor_id, d.doctor_name, AVG(t.treatment_cost) AS avg_treatment_cost
FROM doctors d
JOIN appointments a ON d.doctor_id = a.doctor_id
JOIN treatments t ON a.appointment_id = t.appointment_id
GROUP BY d.doctor_id, d.doctor_name;
SELECT d.doctor_id, d.doctor_name, COUNT(DISTINCT a.patient_id) AS patients_treated
FROM doctors d
JOIN appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.doctor_name
HAVING COUNT(DISTINCT a.patient_id) > 10;
SELECT a.appointment_id, a.appointment_date, d.doctor_name
FROM appointments a
INNER JOIN doctors d ON a.doctor_id = d.doctor_id;
SELECT d.doctor_id, d.doctor_name, a.appointment_id
FROM appointments a
RIGHT JOIN doctors d ON a.doctor_id = d.doctor_id
WHERE a.appointment_id IS NULL;
SELECT d.doctor_id, d.doctor_name, a.appointment_id
FROM doctors d
LEFT JOIN appointments a ON d.doctor_id = a.doctor_id
WHERE a.appointment_id IS NULL;
SELECT p1.patient_id AS patient1_id, p1.patient_name AS patient1_name,
       p2.patient_id AS patient2_id, p2.patient_name AS patient2_name,
       p1.birth_date
FROM patients p1
JOIN patients p2 ON p1.birth_date = p2.birth_date AND p1.patient_id <> p2.patient_id
ORDER BY p1.birth_date;
