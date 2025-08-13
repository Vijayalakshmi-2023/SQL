CREATE TABLE fact_visits (
    visit_id INT PRIMARY KEY,
    patient_id INT,
    doctor_id INT,
    department_id INT,
    appointment_id INT,
    visit_date DATE,
    wait_time INT, -- in minutes
    visit_duration INT, -- in minutes
    FOREIGN KEY (patient_id) REFERENCES dim_patient(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES dim_doctor(doctor_id),
    FOREIGN KEY (department_id) REFERENCES dim_department(department_id),
    FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id),
    FOREIGN KEY (visit_date) REFERENCES dim_time(date)
);
CREATE TABLE dim_patient (
    patient_id INT PRIMARY KEY,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    dob DATE,
    gender VARCHAR(10),
    phone_number VARCHAR(20)
);
CREATE TABLE dim_doctor (
    doctor_id INT PRIMARY KEY,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    specialty VARCHAR(255),
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES dim_department(department_id)
);
CREATE TABLE dim_department (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(255)
);
CREATE TABLE dim_time (
    date DATE PRIMARY KEY,
    year INT,
    quarter INT,
    month INT,
    day INT,
    day_of_week VARCHAR(10)
);
-- Extract and clean data from appointments and doctors
WITH cleaned_appointments AS (
    SELECT
        a.appointment_id,
        a.patient_id,
        a.doctor_id,
        a.department_id,
        a.appointment_date,
        a.actual_visit_date,
        EXTRACT(EPOCH FROM (a.actual_visit_date - a.appointment_date)) / 60 AS wait_time_minutes, -- compute wait time in minutes
        EXTRACT(EPOCH FROM (a.actual_visit_date - a.appointment_date)) / 60 AS visit_duration_minutes
    FROM appointments a
    JOIN dim_patient p ON a.patient_id = p.patient_id
    JOIN dim_doctor d ON a.doctor_id = d.doctor_id
)
-- Insert cleaned data into the fact_visits table
INSERT INTO fact_visits (appointment_id, patient_id, doctor_id, department_id, visit_date, wait_time, visit_duration)
SELECT 
    appointment_id,
    patient_id,
    doctor_id,
    department_id,
    actual_visit_date::DATE AS visit_date,
    wait_time_minutes AS wait_time,
    visit_duration_minutes AS visit_duration
FROM cleaned_appointments;
SELECT 
    d.first_name || ' ' || d.last_name AS doctor_name,
    AVG(fv.wait_time) AS avg_wait_time_minutes
FROM fact_visits fv
JOIN dim_doctor d ON fv.doctor_id = d.doctor_id
GROUP BY doctor_name
ORDER BY avg_wait_time_minutes DESC;
SELECT 
    dept.department_name,
    COUNT(fv.visit_id) AS total_visits
FROM fact_visits fv
JOIN dim_department dept ON fv.department_id = dept.department_id
GROUP BY dept.department_name
ORDER BY total_visits DESC;
SELECT 
    appointment_id,
    patient_id,
    doctor_id,
    department_id,
    appointment_date,
    actual_visit_date,
    EXTRACT(EPOCH FROM (actual_visit_date - appointment_date)) / 60 AS wait_time_minutes
FROM appointments
WHERE department_id = 1 -- Example department filter
ORDER BY appointment_date;
-- Drill down into department visits by specific doctor
SELECT 
    d.first_name || ' ' || d.last_name AS doctor_name,
    COUNT(fv.visit_id) AS doctor_visits
FROM fact_visits fv
JOIN dim_doctor d ON fv.doctor_id = d.doctor_id
WHERE fv.department_id = 1 -- Example department
GROUP BY doctor_name;
-- Roll up to get total visits per quarter
SELECT 
    t.quarter,
    COUNT(fv.visit_id) AS total_visits
FROM fact_visits fv
JOIN dim_time t ON fv.visit_date = t.date
GROUP BY t.quarter
ORDER BY t.quarter;
