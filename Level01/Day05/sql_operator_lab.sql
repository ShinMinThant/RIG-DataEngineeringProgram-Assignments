-- =====================================================
-- 1. CREATE DATABASE
-- =====================================================
DROP DATABASE IF EXISTS sql_operator_lab;
CREATE DATABASE sql_operator_lab;
USE sql_operator_lab;

-- =====================================================
-- 2. CREATE TABLE (Sample Business Table)
-- =====================================================
CREATE TABLE employees (
    emp_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_name VARCHAR(100),
    department VARCHAR(50),
    salary DECIMAL(10,2),
    bonus DECIMAL(10,2),
    age INT,
    status ENUM('Active','Inactive'),
    join_date DATE
);

-- =====================================================
-- 3. INSERT DATA (POPULATE)
-- =====================================================
INSERT INTO employees (emp_name, department, salary, bonus, age, status, join_date)
VALUES
('Aung Aung', 'IT', 800000, 50000, 30, 'Active', '2023-01-01'),
('Su Su', 'HR', 600000, 30000, 28, 'Active', '2022-06-15'),
('Kyaw Kyaw', 'Finance', 900000, 70000, 35, 'Inactive', '2021-03-10'),
('Mya Mya', 'IT', 750000, 40000, 26, 'Active', '2024-02-20'),
('Ko Ko', 'HR', 500000, 20000, 40, 'Inactive', '2020-11-05');

-- View all data
SELECT * FROM employees;

-- =====================================================
-- 4. ARITHMETIC OPERATORS
-- +, -, *, /, %
-- =====================================================

-- Add salary + bonus
SELECT emp_name, salary + bonus AS total_income
FROM employees;

-- Subtract bonus
SELECT emp_name, salary - bonus AS net_salary
FROM employees;

-- Multiply salary
SELECT emp_name, salary * 2 AS double_salary
FROM employees;

-- Divide salary
SELECT emp_name, salary / 2 AS half_salary
FROM employees;

-- Modulo
SELECT emp_name, age % 2 AS age_mod
FROM employees;

-- =====================================================
-- 5. BITWISE OPERATORS
-- &, |, ^
-- =====================================================

SELECT emp_name,
       age & 1 AS bit_and,
       age | 1 AS bit_or,
       age ^ 1 AS bit_xor
FROM employees;

-- =====================================================
-- 6. COMPARISON OPERATORS
-- =, >, <, >=, <=, <>
-- =====================================================

SELECT * FROM employees WHERE salary = 800000;
SELECT * FROM employees WHERE salary > 700000;
SELECT * FROM employees WHERE salary < 700000;
SELECT * FROM employees WHERE salary >= 800000;
SELECT * FROM employees WHERE salary <= 600000;
SELECT * FROM employees WHERE salary <> 600000; -- 60000 ma par 

-- =====================================================
-- 7. LOGICAL OPERATORS
-- AND, OR, NOT
-- =====================================================

SELECT * FROM employees
WHERE department = 'IT' AND salary > 700000;

SELECT * FROM employees
WHERE department = 'IT' OR department = 'HR';

SELECT * FROM employees
WHERE NOT status = 'Inactive';

-- =====================================================
-- 8. SPECIAL OPERATORS
-- IN, BETWEEN, LIKE, EXISTS
-- =====================================================

-- IN
SELECT * FROM employees
WHERE department IN ('IT', 'HR');

-- BETWEEN
SELECT * FROM employees
WHERE salary BETWEEN 600000 AND 800000;

-- LIKE
SELECT * FROM employees
WHERE emp_name LIKE 'A%';

-- EXISTS
SELECT * FROM employees e
WHERE EXISTS (
    SELECT 1 FROM employees
    WHERE department = 'Finance'
);

-- =====================================================
-- 9. ASSIGNMENT STYLE UPDATE OPERATORS
-- +=, -=, *=, /= (simulate in MySQL)
-- =====================================================

-- Increase salary
SET SQL_SAFE_UPDATES = 0;

UPDATE employees
SET salary = salary + 10000;

-- Decrease bonus
UPDATE employees
SET bonus = bonus - 5000;

-- Multiply salary
UPDATE employees
SET salary = salary * 1.1;

-- Divide salary
UPDATE employees
SET salary = salary / 1.05;

-- After running update statments, need to change SET SQL_SAFE_UPDATES = 1;

SET SQL_SAFE_UPDATES = 1;

-- Disable in MySQL Workbench (Permanent)
-- Steps:
-- Go to Edit → Preferences
-- Click SQL Editor
-- Uncheck:
-- ✅ Safe Updates (rejects UPDATEs and DELETEs with no key in WHERE clause)
-- Click OK
-- Reconnect to database
-- =====================================================
-- 10. SET OPERATORS (MYSQL ALTERNATIVES)
-- =====================================================

-- UNION (remove duplicates)
SELECT emp_name FROM employees
WHERE department = 'IT'
UNION
SELECT emp_name FROM employees
WHERE department = 'HR';

-- UNION ALL (keep duplicates)
SELECT emp_name FROM employees
WHERE department = 'IT'
UNION ALL
SELECT emp_name FROM employees
WHERE department = 'HR';

-- INTERSECTION (simulate using INNER JOIN)
SELECT a.emp_name
FROM employees a
INNER JOIN employees b
ON a.emp_id = b.emp_id
WHERE a.department = 'IT' AND b.salary > 700000;

-- DIFFERENCE (simulate using NOT IN)
SELECT emp_name FROM employees
WHERE department = 'IT'
AND emp_id NOT IN (
    SELECT emp_id FROM employees WHERE salary > 700000
);

-- CARTESIAN PRODUCT (CROSS JOIN)
SELECT a.emp_name, b.department
FROM employees a
CROSS JOIN employees b;

-- =====================================================
-- 11. SPECIAL OPERATIONS (RELATIONAL CONCEPTS)
-- =====================================================

-- SELECTION (filter rows)
SELECT * FROM employees WHERE salary > 700000;

-- PROJECTION (select columns)
SELECT emp_name, salary FROM employees;

-- JOIN
CREATE TABLE departments (
    dept_id INT AUTO_INCREMENT PRIMARY KEY,
    dept_name VARCHAR(50)
);

INSERT INTO departments (dept_name)
VALUES ('IT'), ('HR'), ('Finance');

-- INNER JOIN
SELECT e.emp_name, d.dept_name
FROM employees e
JOIN departments d
ON e.department = d.dept_name;

-- LEFT JOIN
SELECT e.emp_name, d.dept_name
FROM employees e
LEFT JOIN departments d
ON e.department = d.dept_name;

-- DIVISION (advanced concept simulation)
-- Employees working in ALL departments
-- Not Possible
SELECT emp_name
FROM employees
GROUP BY emp_name
HAVING COUNT(DISTINCT department) =
(SELECT COUNT(*) FROM departments);

-- =====================================================
-- 12. FINAL SELECT CHECK
-- =====================================================
SELECT * FROM employees;