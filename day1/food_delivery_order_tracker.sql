CREATE DATABASE food_delivery;
USE food_delivery;
CREATE TABLE restaurants (
    restaurant_id INT AUTO_INCREMENT PRIMARY KEY,
    restaurant_name VARCHAR(100) NOT NULL,
    address VARCHAR(255) NOT NULL,
    phone_number VARCHAR(15)
);
CREATE TABLE menus (
    menu_id INT AUTO_INCREMENT PRIMARY KEY,
    restaurant_id INT,
    item_name VARCHAR(100) NOT NULL,
    item_description VARCHAR(255),
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
);
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(15)
);
CREATE TABLE delivery_agents (
    agent_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(15)
);
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    restaurant_id INT,
    order_date DATETIME NOT NULL,
    delivery_status ENUM('Pending', 'Delivered', 'In Progress') DEFAULT 'Pending',
    agent_id INT,
    total_amount DECIMAL(10, 2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id),
    FOREIGN KEY (agent_id) REFERENCES delivery_agents(agent_id)
);
INSERT INTO restaurants (restaurant_name, address, phone_number) VALUES
('Pizza Palace', '123 Pizza Street, City', '123-456-7890'),
('Burger King', '456 Burger Road, City', '123-456-7891'),
('Sushi World', '789 Sushi Lane, City', '123-456-7892'),
('Taco Bell', '101 Taco Blvd, City', '123-456-7893'),
('Pasta Pronto', '202 Pasta Ave, City', '123-456-7894');
INSERT INTO menus (restaurant_id, item_name, item_description, price) VALUES
(1, 'Margherita Pizza', 'Classic pizza with tomato, cheese, and basil', 12.99),
(1, 'Pepperoni Pizza', 'Pizza topped with pepperoni and cheese', 14.99),
(2, 'Cheeseburger', 'Juicy burger with cheese, lettuce, and tomato', 8.99),
(2, 'Vegan Burger', 'Plant-based burger with vegan cheese', 9.99),
(3, 'California Roll', 'Roll with avocado, cucumber, and crab', 10.99),
(3, 'Salmon Sashimi', 'Fresh salmon slices served raw', 14.99),
(4, 'Beef Taco', 'Taco with seasoned beef, lettuce, and cheese', 3.99),
(4, 'Chicken Taco', 'Taco with grilled chicken, salsa, and cheese', 4.99),
(5, 'Spaghetti Bolognese', 'Spaghetti with rich beef bolognese sauce', 13.99),
(5, 'Fettuccine Alfredo', 'Fettuccine pasta with creamy Alfredo sauce', 15.99);
INSERT INTO customers (first_name, last_name, email, phone_number) VALUES
('Alice', 'Johnson', 'alice.johnson@example.com', '123-456-7890'),
('Bob', 'Smith', 'bob.smith@example.com', '123-456-7891'),
('Charlie', 'Davis', 'charlie.davis@example.com', '123-456-7892'),
('David', 'Martinez', 'david.martinez@example.com', '123-456-7893'),
('Emily', 'Garcia', 'emily.garcia@example.com', '123-456-7894'),
('Frank', 'Miller', 'frank.miller@example.com', '123-456-7895'),
('Grace', 'Wilson', 'grace.wilson@example.com', '123-456-7896'),
('Hannah', 'Lopez', 'hannah.lopez@example.com', '123-456-7897'),
('Ivy', 'King', 'ivy.king@example.com', '123-456-7898'),
('Jack', 'Lee', 'jack.lee@example.com', '123-456-7899');
INSERT INTO delivery_agents (first_name, last_name, phone_number) VALUES
('John', 'Doe', '123-456-7890'),
('Jane', 'Smith', '123-456-7891'),
('Mike', 'Johnson', '123-456-7892'),
('Sara', 'Lee', '123-456-7893'),
('David', 'Williams', '123-456-7894');
INSERT INTO orders (customer_id, restaurant_id, order_date, delivery_status, agent_id, total_amount) VALUES
(1, 1, '2023-07-01 12:00:00', 'Pending', 1, 12.99),
(2, 2, '2023-07-01 12:15:00', 'Delivered', 2, 8.99),
(3, 3, '2023-07-01 12:30:00', 'In Progress', 3, 10.99),
(4, 4, '2023-07-01 12:45:00', 'Pending', 4, 3.99),
(5, 5, '2023-07-01 13:00:00', 'Delivered', 5, 13.99),
(6, 1, '2023-07-02 14:00:00', 'Pending', 1, 14.99),
(7, 2, '2023-07-02 14:15:00', 'Delivered', 2, 9.99),
(8, 3, '2023-07-02 14:30:00', 'In Progress', 3, 14.99),
(9, 4, '2023-07-02 14:45:00', 'Pending', 4, 4.99),
(10, 5, '2023-07-02 15:00:00', 'Delivered', 5, 15.99),
(1, 2, '2023-07-03 12:00:00', 'In Progress', 2, 8.99),
(2, 3, '2023-07-03 12:15:00', 'Pending', 3, 14.99),
(3, 4, '2023-07-03 12:30:00', 'Delivered', 4, 3.99),
(4, 5, '2023-07-03 12:45:00', 'In Progress', 5, 13.99),
(5, 1, '2023-07-03 13:00:00', 'Delivered', 1, 12.99);
SELECT o.order_id, r.restaurant_name, c.first_name AS customer_first_name, c.last_name AS customer_last_name, o.order_date
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.delivery_status = 'Pending';
