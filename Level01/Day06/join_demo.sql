-- =========================================
-- CREATE DATABASE
-- =========================================
CREATE DATABASE join_demo;
USE join_demo;

-- =========================================
-- CREATE DEPARTMENTS TABLE
-- =========================================
CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(100)
);

-- =========================================
-- CREATE EMPLOYEES TABLE
-- =========================================
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100),
    dept_id INT,
    salary DECIMAL(10,2),
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);
-- =========================================
-- INSERT INTO DEPARTMENTS
-- =========================================
INSERT INTO departments VALUES
(1, 'HR'),
(2, 'IT'),
(3, 'Finance'),
(4, 'Marketing');

-- =========================================
-- INSERT INTO EMPLOYEES
-- =========================================
INSERT INTO employees VALUES
(101, 'Aung Aung', 1, 800000),
(102, 'Su Su', 2, 900000),
(103, 'Kyaw Kyaw', 2, 850000),
(104, 'Hla Hla', null, 700000),   -- No department
(105, 'Mg Mg', 3, 750000);        -- Invalid dept (no match)

-- =========================================
-- INNER JOIN
-- Only employees with valid departments
-- =========================================
SELECT e.emp_id, e.emp_name, d.dept_name
FROM employees e
INNER JOIN departments d
ON e.dept_id = d.dept_id;

-- =========================================
-- LEFT JOIN
-- All employees, even without department
-- =========================================
SELECT e.emp_id, e.emp_name, d.dept_name
FROM employees e
LEFT JOIN departments d
ON e.dept_id = d.dept_id;

-- =========================================
-- RIGHT JOIN
-- All departments, even without employees
-- =========================================
SELECT e.emp_id, e.emp_name, d.dept_name
FROM employees e
RIGHT JOIN departments d
ON e.dept_id = d.dept_id;

-- =========================================
-- FULL OUTER JOIN (using UNION)
-- All employees + all departments
-- =========================================
SELECT e.emp_id, e.emp_name, d.dept_name
FROM employees e
LEFT JOIN departments d
ON e.dept_id = d.dept_id

UNION

SELECT e.emp_id, e.emp_name, d.dept_name
FROM employees e
RIGHT JOIN departments d
ON e.dept_id = d.dept_id;

-- =========================================
-- CROSS JOIN
-- Every employee with every department
-- =========================================
SELECT e.emp_name, d.dept_name
FROM employees e
CROSS JOIN departments d;

-- =========================================
-- SELF JOIN (Manager Example)
-- =========================================
-- Add manager_id column first
ALTER TABLE employees ADD manager_id INT;

-- Update sample manager data
UPDATE employees SET manager_id = 101 WHERE emp_id = 102;
UPDATE employees SET manager_id = 101 WHERE emp_id = 103;

-- Query
SELECT e.emp_name AS Employee,
       m.emp_name AS Manager
FROM employees e
LEFT JOIN employees m
ON e.manager_id = m.emp_id;

-- =========================================
-- NATURAL JOIN
-- (dept_id is common column)
-- =========================================
SELECT *
FROM employees
NATURAL JOIN departments;

-- =========================================
-- JOIN with condition
-- =========================================
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
INNER JOIN departments d
ON e.dept_id = d.dept_id
WHERE e.salary > 800000;


