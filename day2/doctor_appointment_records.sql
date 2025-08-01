CREATE TABLE appointments (
    appointment_id INT PRIMARY KEY,
    patient_name VARCHAR(100),
    doctor_name VARCHAR(100),
    date DATE,
    status VARCHAR(20),
    notes TEXT
);
SELECT *
FROM appointments
WHERE date BETWEEN '2025-07-01' AND '2025-07-07';
SELECT *
FROM appointments
WHERE patient_name LIKE '%th%';
SELECT doctor_name, date, status
FROM appointments;
SELECT *
FROM appointments
WHERE notes IS NULL;
SELECT DISTINCT doctor_name
FROM appointments;
SELECT *
FROM appointments
ORDER BY date DESC;
