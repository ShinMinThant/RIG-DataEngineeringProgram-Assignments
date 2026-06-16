-- =====================================================
-- MySQL VIEW DEMO SCRIPT
-- Features:
-- Simple View
-- Complex View
-- Join View
-- Aggregation View
-- View with WHERE
-- View with WITH CHECK OPTION
-- Updatable View
-- Read-only View
-- OR REPLACE View
-- ALGORITHM option
-- SQL SECURITY option
-- DROP View
-- =====================================================

CREATE DATABASE view_demo;
USE view_demo;

-- =====================================================
-- 1. CREATE TABLES
-- =====================================================

CREATE TABLE departments (
    dept_id INT PRIMARY KEY AUTO_INCREMENT,
    dept_name VARCHAR(100) NOT NULL
);

CREATE TABLE employees (
    emp_id INT PRIMARY KEY AUTO_INCREMENT,
    emp_name VARCHAR(100) NOT NULL,
    gender VARCHAR(10),
    salary DECIMAL(10,2),
    dept_id INT,
    status VARCHAR(20),
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

-- =====================================================
-- 2. INSERT SAMPLE DATA
-- =====================================================

INSERT INTO departments (dept_name) VALUES
('HR'),
('IT'),
('Finance'),
('Sales');

INSERT INTO employees (emp_name, gender, salary, dept_id, status) VALUES
('Aung Aung', 'Male', 800000, 1, 'Active'),
('Su Su', 'Female', 950000, 2, 'Active'),
('Kyaw Kyaw', 'Male', 700000, 2, 'Inactive'),
('Hla Hla', 'Female', 1200000, 3, 'Active'),
('Mg Mg', 'Male', 600000, 4, 'Active');

-- =====================================================
-- 3. SIMPLE VIEW
-- Shows selected columns only
-- =====================================================

CREATE VIEW vw_employee_basic AS
SELECT emp_id, emp_name, salary
FROM employees;

SELECT * FROM vw_employee_basic;

-- =====================================================
-- 4. VIEW WITH WHERE CONDITION
-- Shows only active employees
-- =====================================================

CREATE VIEW vw_active_employees AS
SELECT emp_id, emp_name, salary, status
FROM employees
WHERE status = 'Active';

SELECT * FROM vw_active_employees;

-- =====================================================
-- 5. JOIN VIEW
-- Combines employees and departments
-- =====================================================

CREATE VIEW vw_employee_department AS
SELECT 
    e.emp_id,
    e.emp_name,
    e.salary,
    d.dept_name
FROM employees e
INNER JOIN departments d
ON e.dept_id = d.dept_id;

SELECT * FROM vw_employee_department;

-- =====================================================
-- 6. AGGREGATE VIEW
-- Shows department salary summary
-- This view is read-only
-- =====================================================

CREATE VIEW vw_department_salary_summary AS
SELECT 
    d.dept_name,
    COUNT(e.emp_id) AS total_employees,
    SUM(e.salary) AS total_salary,
    AVG(e.salary) AS average_salary,
    MAX(e.salary) AS highest_salary,
    MIN(e.salary) AS lowest_salary
FROM departments d
LEFT JOIN employees e
ON d.dept_id = e.dept_id
GROUP BY d.dept_name;

SELECT * FROM vw_department_salary_summary;

-- =====================================================
-- 7. VIEW WITH ORDER BY
-- Note: ORDER BY in view is not always guaranteed
-- unless used with LIMIT or ordered again in SELECT
-- =====================================================

CREATE VIEW vw_high_salary_employees AS
SELECT emp_id, emp_name, salary
FROM employees
WHERE salary >= 800000
ORDER BY salary DESC;

SELECT * FROM vw_high_salary_employees;

-- =====================================================
-- 8. UPDATABLE VIEW
-- Simple view from one table can be updated
-- =====================================================

CREATE VIEW vw_employee_salary_update AS
SELECT emp_id, emp_name, salary
FROM employees;

-- Update data through view
UPDATE vw_employee_salary_update
SET salary = 850000
WHERE emp_id = 1;

SELECT * FROM employees;

-- =====================================================
-- 9. VIEW WITH CHECK OPTION
-- Prevents inserting/updating rows that violate view condition
-- =====================================================

CREATE VIEW vw_active_employee_check AS
SELECT emp_id, emp_name, salary, status
FROM employees
WHERE status = 'Active'
WITH CHECK OPTION;

-- Valid update
UPDATE vw_active_employee_check
SET salary = 1000000
WHERE emp_id = 2;

SELECT * FROM vw_active_employee_check;

-- Invalid update example
-- This will fail because status becomes Inactive
UPDATE vw_active_employee_check
SET status = 'Inactive'
WHERE emp_id = 2; 

-- error message
-- Error Code: 1369. CHECK OPTION failed 'view_demo.vw_active_employee_check'
-- active pyit tae employee tway pal view create htar tar ko inactive change lo ma ya 
-- =====================================================
-- 10. CASCADED CHECK OPTION
-- Default behavior
-- Checks conditions of this view and underlying views
-- =====================================================

CREATE OR REPLACE VIEW vw_high_paid_active AS
SELECT emp_id, emp_name, salary, status
FROM vw_active_employee_check
WHERE salary >= 800000
WITH CASCADED CHECK OPTION;


SELECT * FROM vw_high_paid_active;

-- don't update, follow underlying Check Option (stauts=active)
UPDATE vw_high_paid_active
SET salary = 999
WHERE emp_id = 3; 

UPDATE vw_high_paid_active
SET salary = 999
WHERE emp_id = 1; 

-- Error Code: 1369. CHECK OPTION failed 'view_demo.vw_high_paid_active'
-- check current Check Option and underlying check option
-- =====================================================
-- 11. LOCAL CHECK OPTION
-- Checks only current view condition
-- =====================================================

CREATE VIEW vw_local_check_example AS
SELECT emp_id, emp_name, salary, status
FROM vw_active_employee_check
WHERE salary >= 700000
WITH LOCAL CHECK OPTION;

SELECT * FROM vw_local_check_example;

INSERT INTO vw_local_check_example 
VALUES(6,'Mg Mg Aung', 760000, 'Active');

SELECT * FROM vw_local_check_example;

SELECT * FROM vw_active_employee_check;
-- =====================================================
-- 12. CREATE OR REPLACE VIEW
-- Modify existing view without dropping manually
-- =====================================================

CREATE OR REPLACE VIEW vw_employee_basic AS
SELECT emp_id, emp_name, gender, salary
FROM employees;

SELECT * FROM vw_employee_basic;

-- =====================================================
-- 13. ALGORITHM = MERGE
-- MySQL tries to merge view query into outer query
-- Good for simple views
-- =====================================================

CREATE OR REPLACE
ALGORITHM = MERGE
VIEW vw_merge_employee AS
SELECT emp_id, emp_name, salary
FROM employees
WHERE salary > 700000;

SELECT * FROM vw_merge_employee;

-- =====================================================
-- 14. ALGORITHM = TEMPTABLE
-- MySQL creates temporary table for view result
-- Usually read-only
-- =====================================================

CREATE OR REPLACE
ALGORITHM = TEMPTABLE
VIEW vw_temp_department_summary AS
SELECT dept_id, COUNT(*) AS total_employee
FROM employees
GROUP BY dept_id;

SELECT * FROM vw_temp_department_summary;

-- =====================================================
-- 15. ALGORITHM = UNDEFINED
-- MySQL decides best algorithm
-- =====================================================

CREATE OR REPLACE
ALGORITHM = UNDEFINED
VIEW vw_undefined_employee AS
SELECT emp_id, emp_name, salary
FROM employees;

SELECT * FROM vw_undefined_employee;

-- =====================================================
-- 16. SQL SECURITY DEFINER
-- View runs using permissions of creator
-- =====================================================

CREATE OR REPLACE
SQL SECURITY DEFINER
VIEW vw_security_definer AS
SELECT emp_id, emp_name, salary
FROM employees;

SELECT * FROM vw_security_definer;

-- =====================================================
-- 17. SQL SECURITY INVOKER
-- View runs using permissions of user who calls it
-- =====================================================

CREATE OR REPLACE
SQL SECURITY INVOKER
VIEW vw_security_invoker AS
SELECT emp_id, emp_name, salary
FROM employees;

SELECT * FROM vw_security_invoker;

-- =====================================================
-- 18. VIEW FOR DATA SECURITY
-- Hide sensitive columns
-- Example: users can see employee name but not salary
-- =====================================================

CREATE VIEW vw_employee_public AS
SELECT emp_id, emp_name, gender, status
FROM employees;

SELECT * FROM vw_employee_public;

-- =====================================================
-- 19. VIEW FOR REPORTING
-- Monthly or management reporting style
-- =====================================================

CREATE VIEW vw_management_report AS
SELECT 
    d.dept_name,
    COUNT(e.emp_id) AS employee_count,
    ROUND(AVG(e.salary), 2) AS avg_salary
FROM departments d
LEFT JOIN employees e
ON d.dept_id = e.dept_id
GROUP BY d.dept_name;

SELECT * FROM vw_management_report;

-- =====================================================
-- 20. READ-ONLY VIEW EXAMPLES
-- These views cannot normally be updated:
-- GROUP BY, DISTINCT, JOIN, UNION, aggregate functions
-- =====================================================

CREATE VIEW vw_distinct_status AS
SELECT DISTINCT status
FROM employees;

SELECT * FROM vw_distinct_status;

-- This will fail because aggregate view is read-only
UPDATE vw_department_salary_summary
SET average_salary = 1000000
WHERE dept_name = 'IT';

-- =====================================================
-- 21. SHOW VIEW INFORMATION
-- =====================================================

SHOW FULL TABLES WHERE Table_type = 'VIEW';

SHOW CREATE VIEW vw_employee_basic;

-- =====================================================
-- 22. DROP VIEW
-- =====================================================

DROP VIEW IF EXISTS vw_employee_public;

-- =====================================================
-- END OF SCRIPT
-- =====================================================