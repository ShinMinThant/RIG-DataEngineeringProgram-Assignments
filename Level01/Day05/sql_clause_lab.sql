-- =====================================================
-- SQL CLAUSES COMPLETE LAB
-- Covers: SELECT, FROM, WHERE, GROUP BY, HAVING, ORDER BY
-- =====================================================

-- =====================================================
-- 1. CREATE DATABASE
-- =====================================================
DROP DATABASE IF EXISTS sql_clause_lab;
CREATE DATABASE sql_clause_lab;
USE sql_clause_lab;

-- =====================================================
-- 2. CREATE TABLE
-- =====================================================
CREATE TABLE sales (
    sale_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100),
    product VARCHAR(100),
    region VARCHAR(50),
    amount DECIMAL(10,2),
    sale_date DATE
);

-- =====================================================
-- 3. INSERT SAMPLE DATA
-- =====================================================
INSERT INTO sales (customer_name, product, region, amount, sale_date)
VALUES
('Aung Aung', 'Laptop', 'Yangon', 1500, '2025-01-01'),
('Su Su', 'Phone', 'Mandalay', 800, '2025-01-02'),
('Kyaw Kyaw', 'Laptop', 'Yangon', 2000, '2025-01-03'),
('Mya Mya', 'Tablet', 'Bago', 600, '2025-01-04'),
('Ko Ko', 'Phone', 'Yangon', 900, '2025-01-05'),
('Hla Hla', 'Laptop', 'Mandalay', 1800, '2025-01-06');

-- View all data
SELECT * FROM sales;

-- =====================================================
-- 4. SELECT + FROM
-- Select specific columns from table
-- =====================================================
SELECT customer_name, product
FROM sales;

-- =====================================================
-- 5. WHERE CLAUSE
-- Filter rows based on condition
-- =====================================================

-- Filter by region
SELECT * FROM sales
WHERE region = 'Yangon';

-- Multiple conditions
SELECT * FROM sales
WHERE amount > 1000 AND region = 'Yangon';

-- =====================================================
-- 6. GROUP BY CLAUSE
-- Group rows and apply aggregation
-- =====================================================

-- Total sales by region
SELECT region, SUM(amount) AS total_sales
FROM sales
GROUP BY region;

-- Count orders per product
SELECT product, COUNT(*) AS total_orders
FROM sales
GROUP BY product;

-- =====================================================
-- 7. HAVING CLAUSE
-- Filter grouped results
-- =====================================================

-- Regions with total sales > 2000
SELECT region, SUM(amount) AS total_sales
FROM sales
GROUP BY region
HAVING SUM(amount) > 2000;

-- =====================================================
-- 8. ORDER BY CLAUSE
-- Sort results
-- =====================================================

-- Sort by amount ascending
SELECT * FROM sales
ORDER BY amount ASC;

-- Sort by amount descending
SELECT * FROM sales
ORDER BY amount DESC;

-- =====================================================
-- 9. COMBINED QUERY (REAL USE CASE)
-- =====================================================

-- Total sales per region with conditions and sorting
SELECT 
    region,
    COUNT(*) AS total_orders,
    SUM(amount) AS total_sales
FROM sales
WHERE amount > 500
GROUP BY region
HAVING SUM(amount) > 1500
ORDER BY total_sales DESC;

-- =====================================================
-- 10. EXECUTION ORDER (IMPORTANT NOTE)
-- =====================================================
-- SQL Execution Order:
-- 1. FROM
-- 2. WHERE
-- 3. GROUP BY
-- 4. HAVING
-- 5. SELECT
-- 6. ORDER BY

-- =====================================================
-- 11. CLEANUP (OPTIONAL)
-- =====================================================
-- DROP DATABASE sql_clause_lab;