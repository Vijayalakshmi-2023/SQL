-- Patients Table
CREATE TABLE patients (
    patient_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    dob DATE,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15) UNIQUE
);

-- Doctors Table
CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    specialty VARCHAR(100),
    available BOOLEAN DEFAULT TRUE -- Availability of the doctor
);

-- Appointments Table
CREATE TABLE appointments (
    appointment_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT,
    doctor_id INT,
    appointment_date DATETIME,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);

-- Visits Table (for logs)
CREATE TABLE visits (
    visit_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT,
    visit_date DATETIME,
    visit_details TEXT,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
);

-- Billing Table (for reference, but excluded in view)
CREATE TABLE billing (
    bill_id INT PRIMARY KEY AUTO_INCREMENT,
    appointment_id INT,
    amount DECIMAL(10, 2),
    billing_date DATETIME,
    FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id)
);
CREATE VIEW view_patient_summary AS
SELECT 
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    FLOOR(DATEDIFF(CURDATE(), p.dob) / 365) AS age,  -- Age calculation
    a.appointment_date AS latest_appointment
FROM patients p
LEFT JOIN appointments a ON p.patient_id = a.patient_id
WHERE a.appointment_date = (SELECT MAX(appointment_date) FROM appointments WHERE patient_id = p.patient_id);
DELIMITER $$

CREATE PROCEDURE add_patient_visit(
    IN p_patient_id INT,
    IN p_visit_details TEXT
)
BEGIN
    DECLARE v_visit_date DATETIME;
    
    -- Get the current date and time for the visit
    SET v_visit_date = NOW();
    
    -- Insert the visit log
    INSERT INTO visits (patient_id, visit_date, visit_details)
    VALUES (p_patient_id, v_visit_date, p_visit_details);
    
    -- Optionally, you can also create an appointment or update other related tables
    -- INSERT INTO appointments (patient_id, doctor_id, appointment_date) VALUES (p_patient_id, some_doctor_id, some_date);
    
END $$

DELIMITER ;
CALL add_patient_visit(1, 'Patient reported pain in the abdomen.');
DELIMITER $$

CREATE FUNCTION get_doctor_schedule(p_doctor_id INT)
RETURNS TABLE
BEGIN
    RETURN
    SELECT a.appointment_date, CONCAT(p.first_name, ' ', p.last_name) AS patient_name
    FROM appointments a
    JOIN patients p ON a.patient_id = p.patient_id
    WHERE a.doctor_id = p_doctor_id
    ORDER BY a.appointment_date;
END $$

DELIMITER ;
DELIMITER $$

CREATE TRIGGER after_insert_appointment
AFTER INSERT ON appointments
FOR EACH ROW
BEGIN
    -- Update doctor availability after an appointment is created
    UPDATE doctors
    SET available = FALSE
    WHERE doctor_id = NEW.doctor_id;
END $$

DELIMITER ;
CREATE USER 'non_admin_user'@'localhost' IDENTIFIED BY 'password';
GRANT SELECT ON view_patient_summary TO 'non_admin_user'@'localhost';
REVOKE ALL PRIVILEGES ON patients FROM 'non_admin_user'@'localhost';
REVOKE ALL PRIVILEGES ON appointments FROM 'non_admin_user'@'localhost';
REVOKE ALL PRIVILEGES ON visits FROM 'non_admin_user'@'localhost';
REVOKE ALL PRIVILEGES ON billing FROM 'non_admin_user'@'localhost';
