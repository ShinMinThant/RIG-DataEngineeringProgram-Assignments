-- eCommerce VIEW Assignment (MySQL) 
-- Business Scenario 
-- An eCommerce system has: 
-- • Customers 
-- • Products 
-- • Orders 
-- • Order Items 

-- 1. Database Schema (Setup) -- ================== -- CREATE DATABASE -- ================== 
CREATE DATABASE ecommerce_view_demo; 
USE ecommerce_view_demo;

 -- ==================== -- TABLES -- ==================== 
CREATE TABLE customers ( 
customer_id INT PRIMARY KEY AUTO_INCREMENT, 
customer_name VARCHAR(100), 
email VARCHAR(100), 
city VARCHAR(100) 
); 

CREATE TABLE products ( 
product_id INT PRIMARY KEY AUTO_INCREMENT, 
product_name VARCHAR(100), 
category VARCHAR(50), 
price DECIMAL(10,2) 
); 

CREATE TABLE orders ( 
order_id INT PRIMARY KEY AUTO_INCREMENT, 
customer_id INT, 
order_date DATE, 
status VARCHAR(50), 
FOREIGN KEY (customer_id) REFERENCES customers(customer_id) 
); 

CREATE TABLE order_items ( 
order_item_id INT PRIMARY KEY AUTO_INCREMENT, 
order_id INT, 
product_id INT, 
quantity INT, 
FOREIGN KEY (order_id) REFERENCES orders(order_id), 
FOREIGN KEY (product_id) REFERENCES products(product_id) 
);

 -- ========================================= -- SAMPLE DATA -- ========================================= 
INSERT INTO customers (customer_name, email, city) VALUES 
('Aung Aung', 'aung@gmail.com', 'Yangon'), 
('Su Su', 'susu@gmail.com', 'Mandalay'), 
('Kyaw Kyaw', 'kyaw@gmail.com', 'Yangon'); 

INSERT INTO products (product_name, category, price) VALUES 
('Laptop', 'Electronics', 1500000), 
('Phone', 'Electronics', 800000), 
('Shoes', 'Fashion', 120000); 

INSERT INTO orders (customer_id, order_date, status) VALUES 
(1, '2024-01-10', 'Completed'), 
(2, '2024-01-11', 'Pending'), 
(1, '2024-01-12', 'Completed'); 

INSERT INTO order_items (order_id, product_id, quantity) VALUES 
(1, 1, 1), 
(1, 2, 2), 
(2, 3, 1), 
(3, 2, 1); 

-- Assignment Questions & Answers 
-- Q1. Create a VIEW to show customer basic information (hide email) 
CREATE VIEW customer_basic_info AS
SELECT customer_id, customer_name, city
FROM customers;

-- Q2. Create a VIEW to show all completed orders 
CREATE VIEW completed_orders AS
SELECT *
FROM orders
WHERE status = 'Completed';

-- Q3. Create a JOIN VIEW for order details (customer + product)
CREATE VIEW order_details AS
SELECT 
    o.order_id,
    c.customer_name,
    p.product_name,
    oi.quantity,
    p.price
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id;

-- Q4. Create a VIEW to calculate total sales per order 
CREATE VIEW order_total_sales AS
SELECT 
    o.order_id,
    SUM(oi.quantity * p.price) AS total_sales
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY o.order_id;

-- Q5. Create a VIEW for high-value orders (above 1,000,000) 
CREATE VIEW high_value_orders AS
SELECT 
    o.order_id,
    SUM(oi.quantity * p.price) AS total_amount
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY o.order_id
HAVING total_amount > 1000000;

-- Q6. Create a VIEW with WITH CHECK OPTION (only completed orders allowed) 
CREATE VIEW completed_orders_check AS
SELECT *
FROM orders
WHERE status = 'Completed'
WITH CHECK OPTION;

-- Q7. Try to update data using VIEW (Updatable View) 
UPDATE completed_orders_check
SET status = 'Completed'
WHERE order_id = 1;

-- Q8. Try invalid update (should fail) 
UPDATE completed_orders_check
SET status = 'Pending'
WHERE order_id = 1;

-- Q9. Create a VIEW for customer purchase summary 
CREATE VIEW customer_purchase_summary AS
SELECT 
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS total_orders,
    SUM(oi.quantity * p.price) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY c.customer_id, c.customer_name;

select * from customer_purchase_summary;

-- Q10. Create a VIEW using ALGORITHM = TEMPTABLE 
CREATE ALGORITHM = TEMPTABLE 
VIEW temp_order_summary AS
SELECT 
    order_id,
    COUNT(*) AS total_items
FROM order_items
GROUP BY order_id;

-- Q11. Create a VIEW for security (hide price) 
CREATE VIEW product_public_view AS
SELECT 
    product_id,
    product_name,
    category
FROM products;

-- Q12. Show all views in database 
SHOW FULL TABLES
WHERE Table_type = 'VIEW';

-- Q13. Show view definition 
SHOW CREATE VIEW order_details;

-- Q14. Drop a view 
DROP VIEW customer_basic_info;

-- Additional Questions 
-- 1. Create a view for pending orders only 
CREATE VIEW pending_orders AS
SELECT *
FROM orders
WHERE status = 'Pending';

-- 2. Create a view showing top 3 expensive products
CREATE VIEW top_3_products AS
SELECT *
FROM products
ORDER BY price DESC
LIMIT 3;
 
-- 3. Create a view showing customer orders by city 
CREATE VIEW orders_by_city AS
SELECT 
    c.city,
    c.customer_name,
    o.order_id,
    o.order_date,
    o.status
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id;

select * from orders_by_city;

-- 4. Create a view for monthly sales report 
CREATE VIEW monthly_sales_report AS
SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m') AS month,
    SUM(oi.quantity * p.price) AS total_sales
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m');

select * from monthly_sales_report;

-- 5. Create a view showing products not ordered 
CREATE VIEW products_not_ordered AS
SELECT *
FROM products
WHERE product_id NOT IN (
    SELECT DISTINCT product_id FROM order_items
);