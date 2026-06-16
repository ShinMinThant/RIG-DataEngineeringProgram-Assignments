-- =============================================
-- ECOMMERCE STORED FUNCTIONS LAB
-- MySQL Beginner Level
-- =============================================

CREATE DATABASE IF NOT EXISTS ecommerce_db;
USE ecommerce_db;

-- =============================================
-- DROP OLD TABLES
-- =============================================

DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

-- =============================================
-- CREATE TABLES
-- =============================================

CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    membership_level VARCHAR(30)
);

CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    unit_price DECIMAL(10,2),
    stock_qty INT
);

CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    order_status VARCHAR(30),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- =============================================
-- POPULATE SAMPLE DATA
-- =============================================

INSERT INTO customers (customer_name, email, membership_level)
VALUES
('Aung Aung', 'aung@example.com', 'Gold'),
('Su Su', 'su@example.com', 'Silver'),
('Kyaw Kyaw', 'kyaw@example.com', 'Normal');

INSERT INTO products (product_name, category, unit_price, stock_qty)
VALUES
('Laptop', 'Electronics', 1200000, 10),
('Mouse', 'Electronics', 25000, 100),
('Keyboard', 'Electronics', 45000, 50),
('Office Chair', 'Furniture', 180000, 20),
('Desk', 'Furniture', 250000, 15);

INSERT INTO orders (customer_id, order_date, order_status)
VALUES
(1, '2026-05-01', 'Completed'),
(2, '2026-05-02', 'Completed'),
(3, '2026-05-03', 'Pending');

INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES
(1, 1, 1, 1200000),
(1, 2, 2, 25000),
(2, 4, 1, 180000),
(2, 3, 1, 45000),
(3, 5, 1, 250000);

-- =============================================
-- FUNCTION 1: Calculate order subtotal
-- =============================================

DELIMITER $$

CREATE FUNCTION fn_order_subtotal(p_order_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_subtotal DECIMAL(10,2);

    SELECT SUM(quantity * unit_price)
    INTO v_subtotal
    FROM order_items
    WHERE order_id = p_order_id;

    RETURN IFNULL(v_subtotal, 0);
END $$

DELIMITER ;

-- Test
SELECT fn_order_subtotal(1) AS order_subtotal;

-- =============================================
-- FUNCTION 2: Calculate tax amount
-- =============================================

DELIMITER $$

CREATE FUNCTION fn_tax_amount(p_amount DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN p_amount * 0.05;
END $$

DELIMITER ;

-- Test
SELECT fn_tax_amount(100000) AS tax_amount;

-- =============================================
-- FUNCTION 3: Calculate discount by membership
-- =============================================

DELIMITER $$

CREATE FUNCTION fn_membership_discount(
    p_amount DECIMAL(10,2),
    p_membership_level VARCHAR(30)
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_discount DECIMAL(10,2);

    IF p_membership_level = 'Gold' THEN
        SET v_discount = p_amount * 0.10;
    ELSEIF p_membership_level = 'Silver' THEN
        SET v_discount = p_amount * 0.05;
    ELSE
        SET v_discount = 0;
    END IF;

    RETURN v_discount;
END $$

DELIMITER ;

-- Test
SELECT fn_membership_discount(100000, 'Gold') AS discount_amount;

-- =============================================
-- FUNCTION 4: Calculate final order total
-- subtotal + tax - discount
-- =============================================

DELIMITER $$

CREATE FUNCTION fn_order_final_total(p_order_id INT)
RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
    DECLARE v_subtotal DECIMAL(10,2);
    DECLARE v_tax DECIMAL(10,2);
    DECLARE v_discount DECIMAL(10,2);
    DECLARE v_membership VARCHAR(30);
    DECLARE v_final_total DECIMAL(10,2);

    SELECT c.membership_level
    INTO v_membership
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_id = p_order_id;

    SET v_subtotal = fn_order_subtotal(p_order_id);
    SET v_tax = fn_tax_amount(v_subtotal);
    SET v_discount = fn_membership_discount(v_subtotal, v_membership);

    SET v_final_total = v_subtotal + v_tax - v_discount;

    RETURN IFNULL(v_final_total, 0);
END $$

DELIMITER ;

-- Test
SELECT fn_order_final_total(1) AS final_order_total;

-- =============================================
-- FUNCTION 5: Check stock status
-- =============================================

DELIMITER $$

CREATE FUNCTION fn_stock_status(p_stock_qty INT)
RETURNS VARCHAR(30)
DETERMINISTIC
BEGIN
    RETURN CASE
        WHEN p_stock_qty = 0 THEN 'Out of Stock'
        WHEN p_stock_qty < 10 THEN 'Low Stock'
        ELSE 'Available'
    END;
END $$

DELIMITER ;

-- Test
SELECT 
    product_name,
    stock_qty,
    fn_stock_status(stock_qty) AS stock_status
FROM products;

-- =============================================
-- FUNCTION 6: Count customer orders
-- =============================================

DELIMITER $$

CREATE FUNCTION fn_customer_order_count(p_customer_id INT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_total_orders INT;

    SELECT COUNT(*)
    INTO v_total_orders
    FROM orders
    WHERE customer_id = p_customer_id;

    RETURN v_total_orders;
END $$

DELIMITER ;

-- Test
SELECT 
    customer_name,
    fn_customer_order_count(customer_id) AS total_orders
FROM customers;

-- =============================================
-- FUNCTION 7: Get customer membership label
-- =============================================

DELIMITER $$

CREATE FUNCTION fn_membership_label(p_membership_level VARCHAR(30))
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    RETURN CASE
        WHEN p_membership_level = 'Gold' THEN 'Gold Member - 10% Discount'
        WHEN p_membership_level = 'Silver' THEN 'Silver Member - 5% Discount'
        ELSE 'Normal Member - No Discount'
    END;
END $$

DELIMITER ;

-- Test
SELECT 
    customer_name,
    membership_level,
    fn_membership_label(membership_level) AS membership_description
FROM customers;

-- =============================================
-- FUNCTION 8: Calculate shipping fee
-- =============================================

DELIMITER $$

CREATE FUNCTION fn_shipping_fee(p_amount DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    IF p_amount >= 500000 THEN
        RETURN 0;
    ELSE
        RETURN 5000;
    END IF;
END $$

DELIMITER ;

-- Test
SELECT fn_shipping_fee(300000) AS shipping_fee;

-- =============================================
-- FUNCTION 9: Calculate grand total
-- final total + shipping fee
-- =============================================

DELIMITER $$

CREATE FUNCTION fn_order_grand_total(p_order_id INT)
RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
    DECLARE v_final_total DECIMAL(10,2);
    DECLARE v_shipping_fee DECIMAL(10,2);

    SET v_final_total = fn_order_final_total(p_order_id);
    SET v_shipping_fee = fn_shipping_fee(v_final_total);

    RETURN v_final_total + v_shipping_fee;
END $$

DELIMITER ;

-- Test
SELECT fn_order_grand_total(1) AS grand_total;

-- =============================================
-- PRACTICAL REPORT QUERY
-- =============================================

SELECT 
    o.order_id,
    c.customer_name,
    c.membership_level,
    fn_order_subtotal(o.order_id) AS subtotal,
    fn_tax_amount(fn_order_subtotal(o.order_id)) AS tax_amount,
    fn_membership_discount(
        fn_order_subtotal(o.order_id),
        c.membership_level
    ) AS discount_amount,
    fn_order_final_total(o.order_id) AS final_total,
    fn_shipping_fee(fn_order_final_total(o.order_id)) AS shipping_fee,
    fn_order_grand_total(o.order_id) AS grand_total,
    o.order_status
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id;

-- =============================================
-- SHOW ALL FUNCTIONS
-- =============================================

SHOW FUNCTION STATUS
WHERE Db = 'ecommerce_db';

-- =============================================
-- DROP FUNCTION EXAMPLES
-- =============================================

-- DROP FUNCTION IF EXISTS fn_order_subtotal;
-- DROP FUNCTION IF EXISTS fn_tax_amount;
-- DROP FUNCTION IF EXISTS fn_membership_discount;
-- DROP FUNCTION IF EXISTS fn_order_final_total;
-- DROP FUNCTION IF EXISTS fn_stock_status;
-- DROP FUNCTION IF EXISTS fn_customer_order_count;
-- DROP FUNCTION IF EXISTS fn_membership_label;
-- DROP FUNCTION IF EXISTS fn_shipping_fee;
-- DROP FUNCTION IF EXISTS fn_order_grand_total;