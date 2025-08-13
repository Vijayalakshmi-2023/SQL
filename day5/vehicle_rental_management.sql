-- Vehicles Table
CREATE TABLE vehicles (
    vehicle_id INT AUTO_INCREMENT PRIMARY KEY,  -- Unique vehicle ID
    make VARCHAR(100) NOT NULL,                 -- Vehicle make (e.g., Toyota)
    model VARCHAR(100) NOT NULL,                -- Vehicle model (e.g., Corolla)
    year INT CHECK (year >= 1900),              -- Year of manufacture (must be valid year)
    available BOOLEAN DEFAULT TRUE,             -- Availability status of the vehicle
    mileage INT DEFAULT 0,                      -- Current mileage
    fuel_level DECIMAL(5, 2) DEFAULT 100.00,    -- Fuel level (percentage)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP  -- Vehicle addition timestamp
);

-- Customers Table
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,  -- Unique customer ID
    first_name VARCHAR(100) NOT NULL,            -- Customer first name
    last_name VARCHAR(100) NOT NULL,             -- Customer last name
    email VARCHAR(100) UNIQUE,                   -- Customer email (must be unique)
    phone VARCHAR(20) UNIQUE,                    -- Customer phone (must be unique)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP  -- Customer creation timestamp
);

-- Rentals Table
CREATE TABLE rentals (
    rental_id INT AUTO_INCREMENT PRIMARY KEY,    -- Unique rental ID
    customer_id INT,                             -- Foreign Key: References customers
    vehicle_id INT,                              -- Foreign Key: References vehicles
    rental_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Rental date
    return_date TIMESTAMP,                       -- Return date (to be filled later)
    mileage_at_return INT,                       -- Mileage at the time of return
    fuel_level_at_return DECIMAL(5, 2),          -- Fuel level at the time of return
    status VARCHAR(20) DEFAULT 'active',         -- Status of the rental (active, completed)
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id) ON DELETE CASCADE,
    CHECK (return_date > rental_date)  -- Ensure return date is after rental date
);

-- Invoices Table
CREATE TABLE invoices (
    invoice_id INT AUTO_INCREMENT PRIMARY KEY,   -- Unique invoice ID
    rental_id INT,                               -- Foreign Key: References rentals
    total_amount DECIMAL(10, 2) NOT NULL,        -- Total amount of the rental
    payment_status VARCHAR(20) DEFAULT 'unpaid', -- Payment status (paid, unpaid)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Invoice creation timestamp
    FOREIGN KEY (rental_id) REFERENCES rentals(rental_id) ON DELETE CASCADE
);
DELIMITER $$

-- Create a stored procedure for renting a vehicle
CREATE PROCEDURE RentVehicle(IN vehicle_id INT, IN customer_id INT)
BEGIN
    DECLARE is_available BOOLEAN;

    -- Start the transaction
    START TRANSACTION;

    -- Check if the vehicle is available
    SELECT available INTO is_available FROM vehicles WHERE vehicle_id = vehicle_id;

    -- If the vehicle is available, proceed with rental
    IF is_available = TRUE THEN
        -- Mark the vehicle as unavailable
        UPDATE vehicles SET available = FALSE WHERE vehicle_id = vehicle_id;

        -- Insert the rental record for the customer
        INSERT INTO rentals (customer_id, vehicle_id, rental_date)
        VALUES (customer_id, vehicle_id, NOW());

        -- Commit the transaction
        COMMIT;
    ELSE
        -- Rollback if the vehicle is not available
        ROLLBACK;
        -- Raise an error message
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vehicle not available for rental.';
    END IF;
END $$

DELIMITER ;
-- Call the procedure to rent a vehicle (vehicle_id = 1, customer_id = 1)
CALL RentVehicle(1, 1);
-- Update mileage and fuel level after return
UPDATE vehicles
SET mileage = mileage + ?, fuel_level = ?
WHERE vehicle_id = ?;
-- Delete completed rentals older than 3 months
DELETE FROM rentals
WHERE status = 'completed' AND return_date < NOW() - INTERVAL 3 MONTH;
DELIMITER $$

-- Create a stored procedure for renting a vehicle and generating the invoice
CREATE PROCEDURE RentVehicleAndGenerateInvoice(IN customer_id INT, IN vehicle_id INT, IN price DECIMAL(10, 2))
BEGIN
    DECLARE rental_id INT;

    -- Start the transaction
    START TRANSACTION;

    -- Savepoint in case of error
    SAVEPOINT before_invoice_creation;

    -- Insert the rental record
    INSERT INTO rentals (customer_id, vehicle_id, rental_date)
    VALUES (customer_id, vehicle_id, NOW());

    -- Get the rental ID of the last inserted rental
    SET rental_id = LAST_INSERT_ID();

    -- Attempt to create an invoice (price must be valid)
    INSERT INTO invoices (rental_id, total_amount)
    VALUES (rental_id, price);

    -- Simulate a pricing error (invalid amount check)
    IF price < 0 THEN
        -- Rollback to the SAVEPOINT if the pricing is invalid
        ROLLBACK TO SAVEPOINT before_invoice_creation;
        -- Raise an error message
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid pricing, transaction rolled back.';
    END IF;

    -- Commit the transaction if everything is successful
    COMMIT;
END $$

DELIMITER ;
-- Call the stored procedure to rent a vehicle and generate an invoice
CALL RentVehicleAndGenerateInvoice(1, 1, 150.00);
-- Step 1: Start the rental transaction
START TRANSACTION;

-- Rent vehicle and generate an invoice
INSERT INTO rentals (customer_id, vehicle_id, rental_date)
VALUES (?, ?, NOW());

-- Insert the invoice (total amount is calculated)
INSERT INTO invoices (rental_id, total_amount)
VALUES (LAST_INSERT_ID(), ?);

-- Commit the transaction if everything is successful
COMMIT;

-- Step 2: Simulate a disconnect and reconnect in the system

-- Reconnect and verify that the records are still present
SELECT * FROM rentals WHERE customer_id = ?;  -- Verify rental exists
SELECT * FROM invoices WHERE rental_id = ?;   -- Verify invoice exists
INSERT INTO vehicles (make, model, year, available, mileage, fuel_level)
VALUES ('Toyota', 'Corolla', 2020, TRUE, 15000, 95.00),
       ('Ford', 'Focus', 2019, TRUE, 22000, 80.00);
INSERT INTO customers (first_name, last_name, email, phone)
VALUES ('Alice', 'Brown', 'alice.brown@example.com', '555-1234'),
       ('Bob', 'Smith', 'bob.smith@example.com', '555-5678');
-- Start the rental transaction
START TRANSACTION;

-- Rent a vehicle (customer 1 rents vehicle 1)
INSERT INTO rentals (customer_id, vehicle_id, rental_date)
VALUES (1, 1, NOW());

-- Insert the invoice (calculate total rental amount)
INSERT INTO invoices (rental_id, total_amount)
VALUES (LAST_INSERT_ID(), 150.00);  -- Example pricing

-- Commit the transaction
COMMIT;
