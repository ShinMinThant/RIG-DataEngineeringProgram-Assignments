-- Lab: Migrate Two MySQL Databases to One MSSQL Database
-- Scenario

-- You have two MySQL databases:

-- mysql_sales_db
-- mysql_hr_db

-- You want to migrate both into one Microsoft SQL Server database:

-- CompanyDW
-- Part 1: MySQL Source Database Scripts
-- 1. Create MySQL Sales Database
-- MySQL Source Database 1: Sales Database
CREATE DATABASE mysql_sales_db;
USE mysql_sales_db;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100),
    phone VARCHAR(30),
    email VARCHAR(100),
    city VARCHAR(50)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100),
    category VARCHAR(50),
    unit_price DECIMAL(10,2)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(12,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

INSERT INTO customers (customer_name, phone, email, city) VALUES
('Aung Aung', '0911111111', 'aung@example.com', 'Yangon'),
('Su Su', '0922222222', 'su@example.com', 'Mandalay'),
('Kyaw Kyaw', '0933333333', 'kyaw@example.com', 'Naypyidaw');

INSERT INTO products (product_name, category, unit_price) VALUES
('Laptop', 'Electronics', 1200000),
('Mouse', 'Electronics', 25000),
('Office Chair', 'Furniture', 180000);

INSERT INTO orders (customer_id, order_date, total_amount) VALUES
(1, '2026-05-01', 1200000),
(2, '2026-05-02', 25000),
(3, '2026-05-03', 180000);
-- 2. Create MySQL HR Database
-- MySQL Source Database 2: HR Database
CREATE DATABASE mysql_hr_db;
USE mysql_hr_db;

CREATE TABLE departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(100)
);

CREATE TABLE employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(30),
    department_id INT,
    salary DECIMAL(12,2),
    hire_date DATE,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

INSERT INTO departments (department_name) VALUES
('IT Department'),
('Finance Department'),
('HR Department');

INSERT INTO employees 
(employee_name, email, phone, department_id, salary, hire_date) VALUES
('Mg Mg', 'mgmg@example.com', '0944444444', 1, 800000, '2025-01-15'),
('Hla Hla', 'hlahla@example.com', '0955555555', 2, 750000, '2025-03-10'),
('Mya Mya', 'myamya@example.com', '0966666666', 3, 650000, '2025-06-20');
