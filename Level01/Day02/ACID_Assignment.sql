-- =========================================================
-- HR DATABASE ACID Assignment
-- MySQL Script File
-- =========================================================
-- This script demonstrates:
-- 1. Atomicity
-- 2. Consistency
-- 3. Isolation
-- 4. Durability
--
-- Recommended:
-- Run section by section in MySQL Workbench.
-- Isolation test requires 2 sessions/windows.
-- =========================================================

-- =========================================================
-- 0. CREATE DATABASE
-- =========================================================
DROP DATABASE IF EXISTS hr_acid_db;
CREATE DATABASE hr_acid_db;
USE hr_acid_db;

-- =========================================================
-- 1. CREATE TABLES
-- =========================================================

-- Department master table
CREATE TABLE departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    location VARCHAR(100)
);

-- Employee master table
CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_code VARCHAR(20) NOT NULL UNIQUE,
    employee_name VARCHAR(100) NOT NULL,
    department_id INT,
    job_title VARCHAR(100),
    salary DECIMAL(10,2) NOT NULL,
    leave_balance INT NOT NULL DEFAULT 0,
    status VARCHAR(20) NOT NULL DEFAULT 'Active',
    hire_date DATE,
    CONSTRAINT fk_employee_department
        FOREIGN KEY (department_id) REFERENCES departments(department_id),
    CONSTRAINT chk_salary_positive CHECK (salary >= 0),
    CONSTRAINT chk_leave_balance CHECK (leave_balance >= 0)
);

-- Payroll history table
CREATE TABLE payroll_transactions (
    payroll_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    payroll_month VARCHAR(20) NOT NULL,
    basic_salary DECIMAL(10,2) NOT NULL,
    bonus DECIMAL(10,2) NOT NULL DEFAULT 0,
    deduction DECIMAL(10,2) NOT NULL DEFAULT 0,
    net_salary DECIMAL(10,2) NOT NULL,
    processed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_payroll_employee
        FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- Leave request table
CREATE TABLE leave_requests (
    leave_request_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    leave_type VARCHAR(50) NOT NULL,
    days_requested INT NOT NULL,
    request_status VARCHAR(20) NOT NULL DEFAULT 'Pending',
    request_date DATE NOT NULL,
    approved_by VARCHAR(100),
    CONSTRAINT fk_leave_employee
        FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    CONSTRAINT chk_days_requested CHECK (days_requested > 0)
);

-- =========================================================
-- 2. INSERT SAMPLE DATA
-- =========================================================

INSERT INTO departments (department_name, location) VALUES
('HR', 'Yangon'),
('IT', 'Mandalay'),
('Finance', 'Naypyidaw'),
('Admin', 'Yangon'),
('Operations', 'Bago');

INSERT INTO employees
(employee_code, employee_name, department_id, job_title, salary, leave_balance, status, hire_date)
VALUES
('EMP001', 'Aung Aung', 2, 'Junior Developer', 800000, 10, 'Active', '2023-01-10'),
('EMP002', 'Su Su', 1, 'HR Officer', 650000, 8, 'Active', '2022-03-15'),
('EMP003', 'Kyaw Kyaw', 3, 'Accountant', 900000, 12, 'Active', '2021-06-01'),
('EMP004', 'Hla Hla', 4, 'Admin Assistant', 500000, 7, 'Active', '2024-02-20'),
('EMP005', 'Mya Mya', 2, 'System Engineer', 1200000, 15, 'Active', '2020-11-11'),
('EMP006', 'Ko Ko', 5, 'Operations Officer', 700000, 9, 'Active', '2023-08-08'),
('EMP007', 'Nyein Nyein', 1, 'Recruitment Specialist', 680000, 11, 'Active', '2022-12-01'),
('EMP008', 'Zaw Zaw', 3, 'Finance Analyst', 950000, 14, 'Active', '2021-09-09');

-- Initial payroll sample
INSERT INTO payroll_transactions
(employee_id, payroll_month, basic_salary, bonus, deduction, net_salary)
VALUES
(1, '2026-04', 800000, 50000, 10000, 840000),
(2, '2026-04', 650000, 30000, 5000, 675000),
(3, '2026-04', 900000, 40000, 15000, 925000);

-- Initial leave requests sample
INSERT INTO leave_requests
(employee_id, leave_type, days_requested, request_status, request_date, approved_by)
VALUES
(1, 'Annual Leave', 2, 'Approved', '2026-04-01', 'HR Manager'),
(2, 'Medical Leave', 1, 'Approved', '2026-04-03', 'HR Manager'),
(4, 'Casual Leave', 2, 'Pending', '2026-04-05', NULL);

-- =========================================================
-- 3. VIEW INITIAL DATA
-- =========================================================
SELECT 'INITIAL DEPARTMENTS' AS info;
SELECT * FROM departments;

SELECT 'INITIAL EMPLOYEES' AS info;
SELECT * FROM employees;

SELECT 'INITIAL PAYROLL' AS info;
SELECT * FROM payroll_transactions;

SELECT 'INITIAL LEAVE REQUESTS' AS info;
SELECT * FROM leave_requests;

-- =========================================================
-- 4. ACID TEST 1 - ATOMICITY
-- =========================================================
-- Definition:
-- A transaction must complete fully or not at all.
--
-- Use Case:
-- Approve leave request and deduct leave balance together.
-- If one step fails, both actions must be rolled back.
-- =========================================================

SELECT 'ATOMICITY TEST - BEFORE' AS info;
SELECT employee_id, employee_name, leave_balance
FROM employees
WHERE employee_id = 1;

SELECT * FROM leave_requests WHERE employee_id = 1;

-- -------------------------
-- 4A. Successful atomic transaction
-- -------------------------
START TRANSACTION;

INSERT INTO leave_requests
(employee_id, leave_type, days_requested, request_status, request_date, approved_by)
VALUES
(1, 'Annual Leave', 3, 'Approved', CURDATE(), 'HR Manager');

UPDATE employees
SET leave_balance = leave_balance - 3
WHERE employee_id = 1;

COMMIT;

SELECT 'ATOMICITY TEST - AFTER SUCCESSFUL COMMIT' AS info;
SELECT employee_id, employee_name, leave_balance
FROM employees
WHERE employee_id = 1;

SELECT * FROM leave_requests WHERE employee_id = 1;

-- -------------------------
-- 4B. Failed atomic transaction example
-- We intentionally create an error by using invalid employee_id in leave_requests
-- and then rollback everything.
-- -------------------------
SELECT 'ATOMICITY TEST - BEFORE FAILED TRANSACTION' AS info;
SELECT employee_id, employee_name, leave_balance
FROM employees
WHERE employee_id = 2;

START TRANSACTION;

-- Step 1: Deduct leave balance
UPDATE employees
SET leave_balance = leave_balance - 2
WHERE employee_id = 2;

-- Step 2: Invalid insert to force error
-- employee_id 9999 does not exist, so FK constraint fails
-- Depending on MySQL client, execute this line and then run ROLLBACK manually
INSERT INTO leave_requests
(employee_id, leave_type, days_requested, request_status, request_date, approved_by)
VALUES
(9999, 'Annual Leave', 2, 'Approved', CURDATE(), 'HR Manager');

ROLLBACK;

SELECT 'ATOMICITY TEST - AFTER ROLLBACK' AS info;
SELECT employee_id, employee_name, leave_balance
FROM employees
WHERE employee_id = 2;

-- =========================================================
-- 5. ACID TEST 2 - CONSISTENCY
-- =========================================================
-- Definition:
-- A transaction must keep data valid according to rules and constraints.
--
-- Business Rules:
-- 1. leave_balance cannot be negative
-- 2. salary cannot be negative
-- 3. employee must belong to a valid department
-- =========================================================

SELECT 'CONSISTENCY TEST - BEFORE' AS info;
SELECT employee_id, employee_name, salary, leave_balance
FROM employees
WHERE employee_id = 3;

-- -------------------------
-- 5A. Valid transaction
-- Deduct leave only if enough balance exists
-- -------------------------
START TRANSACTION;

UPDATE employees
SET leave_balance = leave_balance - 5
WHERE employee_id = 3
  AND leave_balance >= 5;

COMMIT;

SELECT 'CONSISTENCY TEST - AFTER VALID UPDATE' AS info;
SELECT employee_id, employee_name, salary, leave_balance
FROM employees
WHERE employee_id = 3;

-- -------------------------
-- 5B. Invalid transaction example
-- This should fail because leave_balance cannot be negative
-- -------------------------
-- Execute separately if your client stops on error
START TRANSACTION;

UPDATE employees
SET leave_balance = -1
WHERE employee_id = 4;

ROLLBACK;

SELECT 'CONSISTENCY TEST - AFTER INVALID UPDATE ROLLBACK' AS info;
SELECT employee_id, employee_name, salary, leave_balance
FROM employees
WHERE employee_id = 4;

-- -------------------------
-- 5C. Invalid salary example
-- This should fail because salary cannot be negative
-- -------------------------
START TRANSACTION;

UPDATE employees
SET salary = -5000
WHERE employee_id = 5;

ROLLBACK;

SELECT 'CONSISTENCY TEST - AFTER INVALID SALARY ROLLBACK' AS info;
SELECT employee_id, employee_name, salary, leave_balance
FROM employees
WHERE employee_id = 5;

-- =========================================================
-- 6. ACID TEST 3 - ISOLATION
-- =========================================================
-- Definition:
-- Transactions running at the same time should not interfere with each other.
--
-- IMPORTANT:
-- Open TWO MySQL sessions/windows for this test.
-- =========================================================

-- -------------------------
-- SESSION 1
-- -------------------------
-- Run in Window 1:
--
-- USE hr_acid_demo;
-- SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
UPDATE employees
SET salary = salary + 100000
WHERE employee_id = 6;
SELECT * FROM employees WHERE employee_id = 6;

rollback;
-- DO NOT COMMIT YET

-- -------------------------
-- SESSION 2
-- -------------------------
-- Run in Window 2:
--
-- USE hr_acid_demo;
-- SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
-- SELECT * FROM employees WHERE employee_id = 6;
--
-- Expected:
-- Session 2 should see the old committed salary,
-- not the uncommitted salary from Session 1.
--
-- Then go back to Session 1:
-- COMMIT;
--
-- Then in Session 2 run again:
-- SELECT * FROM employees WHERE employee_id = 6;
--
-- Expected:
-- Now Session 2 sees the new salary after commit.

-- =========================================================
-- 7. ACID TEST 4 - DURABILITY
-- =========================================================
-- Definition:
-- Once COMMIT is done, the data is permanently saved.
--
-- Use Case:
-- Process monthly payroll and commit it.
-- After commit, data should remain stored.
-- =========================================================

SELECT 'DURABILITY TEST - BEFORE' AS info;
SELECT * FROM payroll_transactions WHERE employee_id = 7;

START TRANSACTION;

INSERT INTO payroll_transactions
(employee_id, payroll_month, basic_salary, bonus, deduction, net_salary)
VALUES
(7, '2026-05', 680000, 50000, 10000, 720000);

COMMIT;

SELECT 'DURABILITY TEST - AFTER COMMIT' AS info;
SELECT * FROM payroll_transactions WHERE employee_id = 7;

-- To test durability manually:
-- 1. Run the above COMMIT
-- 2. Close MySQL session / reconnect
-- 3. Run:
--    SELECT * FROM payroll_transactions WHERE employee_id = 7;
-- If row still exists, durability is confirmed.

-- =========================================================
-- 8. PRACTICAL FULL ACID BUSINESS TEST
-- =========================================================
-- Scenario:
-- Employee promotion process
-- - change department
-- - update job title
-- - increase salary
-- - add payroll history
-- All steps must succeed together
-- =========================================================

SELECT 'FULL BUSINESS TEST - BEFORE PROMOTION' AS info;
SELECT * FROM employees WHERE employee_id = 8;

START TRANSACTION;

UPDATE employees
SET department_id = 2,
    job_title = 'Senior Finance Systems Analyst',
    salary = salary + 150000
WHERE employee_id = 8;

INSERT INTO payroll_transactions
(employee_id, payroll_month, basic_salary, bonus, deduction, net_salary)
VALUES
(8, '2026-05', 1100000, 100000, 20000, 1180000);

SELECT * FROM payroll_transactions;
COMMIT;

SELECT 'FULL BUSINESS TEST - AFTER PROMOTION COMMIT' AS info;
SELECT * FROM employees WHERE employee_id = 8;
SELECT * FROM payroll_transactions WHERE employee_id = 8;

-- -------------------------
-- Failed promotion transaction example
-- This will rollback all steps
-- -------------------------
SELECT 'FULL BUSINESS TEST - BEFORE FAILED PROMOTION' AS info;
SELECT * FROM employees WHERE employee_id = 5;

START TRANSACTION;

UPDATE employees
SET job_title = 'Lead System Engineer',
    salary = salary + 200000
WHERE employee_id = 5;

-- Invalid foreign key department_id = 9999
UPDATE employees
SET department_id = 9999
WHERE employee_id = 5;

ROLLBACK;

SELECT 'FULL BUSINESS TEST - AFTER FAILED PROMOTION ROLLBACK' AS info;
SELECT * FROM employees WHERE employee_id = 5;

-- =========================================================
-- 9. FINAL DATA CHECK
-- =========================================================
SELECT 'FINAL EMPLOYEE DATA' AS info;
SELECT 
    e.employee_id,
    e.employee_code,
    e.employee_name,
    d.department_name,
    e.job_title,
    e.salary,
    e.leave_balance,
    e.status,
    e.hire_date
FROM employees e
LEFT JOIN departments d
    ON e.department_id = d.department_id
ORDER BY e.employee_id;

SELECT 'FINAL PAYROLL DATA' AS info;
SELECT * FROM payroll_transactions ORDER BY payroll_id;

SELECT 'FINAL LEAVE REQUEST DATA' AS info;
SELECT * FROM leave_requests ORDER BY leave_request_id;

-- =========================================================
-- END OF SCRIPT
-- =========================================================