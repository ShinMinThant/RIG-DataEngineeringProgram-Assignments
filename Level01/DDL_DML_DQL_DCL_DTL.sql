-- e-Commerce Use Case
-- Creating product, warehouse, and inventory tables
-- 1. Data Definition Language (DDL) 
CREATE DATABASE ecommercedb;
USE ecommercedb;
-- Create Products Table
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(150),
    sku VARCHAR(50) UNIQUE,
    selling_price DECIMAL(10,2)
);

-- Create Inventory Table
CREATE TABLE inventory_stock (
    stock_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    quantity INT,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE sales_orders (
    sales_order_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_number VARCHAR(50) NOT NULL UNIQUE,
    customer_id BIGINT NULL,
    warehouse_id INT NULL,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status ENUM('PENDING','CONFIRMED','SHIPPED','DELIVERED','CANCELLED') 
           NOT NULL DEFAULT 'PENDING',
    total_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 2. Data Manipulation Language (DML) 
-- Insert product
INSERT INTO products (product_name, sku, selling_price)
VALUES ('iPhone 14', 'SKU001', 1000);

INSERT INTO products (product_name, sku, selling_price)
VALUES ('Rice Cooker', 'SKU010', 200);

INSERT INTO inventory_stock (stock_id,product_id,quantity)
VALUES(1,1,1000);

-- Update stock
UPDATE inventory_stock
SET quantity = quantity + 10
WHERE product_id = 1;

-- Delete product
DELETE FROM products WHERE product_id = 2;

-- 3. Data Query Language (DQL)
-- View all products
SELECT product_id,product_name FROM products;
SELECT * FROM products;
SELECT * FROM sales_orders;
-- Check stock availability

SELECT p.product_name, i.quantity
FROM products p
JOIN inventory_stock i ON p.product_id = i.product_id;

-- Low stock alert
SELECT * FROM inventory_stock
WHERE quantity < 200;

-- 4. Data Control Language (DCL)
 -- Restrict warehouse staff vs admin access 
 -- Grant permission
 
CREATE USER 'staff_user'@'localhost' IDENTIFIED BY 'password123';
CREATE USER 'staff_user2'@'localhost' IDENTIFIED BY 'password12';
GRANT SELECT, INSERT, UPDATE, DELETE ON products TO 'staff_user'@'localhost';
GRANT SELECT ON products TO 'staff_user2'@'localhost';

-- Apply Changes 
FLUSH PRIVILEGES;
-- Revoke permission
REVOKE SELECT ON products FROM 'staff_user'@'localhost';
REVOKE INSERT ON products FROM 'staff_user'@'localhost';
REVOKE UPDATE ON products FROM 'staff_user'@'localhost';
REVOKE DELETE ON products FROM 'staff_user'@'localhost';

-- 5. Transaction Control Language (TCL)
-- Order placement (stock deduction + payment)

START TRANSACTION;

-- Deduct stock
UPDATE inventory_stock
SET quantity = quantity - 1
WHERE product_id = 1;

-- Insert sales order

INSERT INTO sales_orders (order_number, total_amount, status)
VALUES ('SO1003', 2000, 'CONFIRMED');
INSERT INTO sales_orders 
(order_number, customer_id, warehouse_id, total_amount)
VALUES 
('SO1004', 1, 1, 1200);

INSERT INTO sales_orders (order_number, total_amount)
VALUES ('SO1005', 1500);

INSERT INTO sales_orders (order_number, total_amount)
VALUES
('SO1006', 900),
('SO1007', 1100),
('SO1008', 1300);

-- If error occurs
ROLLBACK;
-- If everything is correct
COMMIT;



SELECT * FROM sales_orders;