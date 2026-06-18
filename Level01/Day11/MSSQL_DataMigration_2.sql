-- Part 2: MSSQL Target Database Script
-- 3. Create Target Database in SQL Server
-- MSSQL Target Database
CREATE DATABASE CompanyDW;
GO

USE CompanyDW;
GO
--4. Create Schemas for Two Source Databases
-- Separate schemas for migrated databases
CREATE SCHEMA sales;
GO

CREATE SCHEMA hr;
GO
--5. Create Sales Tables in MSSQL
CREATE TABLE sales.customers (
    customer_id INT PRIMARY KEY,
    customer_name NVARCHAR(100),
    phone NVARCHAR(30),
    email NVARCHAR(100),
    city NVARCHAR(50)
);

CREATE TABLE sales.products (
    product_id INT PRIMARY KEY,
    product_name NVARCHAR(100),
    category NVARCHAR(50),
    unit_price DECIMAL(10,2)
);

CREATE TABLE sales.orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(12,2),
    CONSTRAINT FK_orders_customers
        FOREIGN KEY (customer_id)
        REFERENCES sales.customers(customer_id)
);
--6. Create HR Tables in MSSQL
CREATE TABLE hr.departments (
    department_id INT PRIMARY KEY,
    department_name NVARCHAR(100)
);

CREATE TABLE hr.employees (
    employee_id INT PRIMARY KEY,
    employee_name NVARCHAR(100),
    email NVARCHAR(100),
    phone NVARCHAR(30),
    department_id INT,
    salary DECIMAL(12,2),
    hire_date DATE,
    CONSTRAINT FK_employees_departments
        FOREIGN KEY (department_id)
        REFERENCES hr.departments(department_id)
);
