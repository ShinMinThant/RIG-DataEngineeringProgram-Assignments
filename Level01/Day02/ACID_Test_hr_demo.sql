-- =========================================================
-- FILE NAME: hr_acid_examples.sql
-- PURPOSE   : Demonstrate ACID properties in MySQL
-- DATABASE  : hr_demo
-- USE CASE  : Simple HR database
-- =========================================================

-- =========================================================
-- 1. RESET DATABASE
-- =========================================================
DROP DATABASE IF EXISTS hr_demo;
CREATE DATABASE hr_demo;
USE hr_demo;

-- =========================================================
-- 2. CREATE HR SAMPLE TABLE
-- =========================================================
CREATE TABLE employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_name VARCHAR(100) NOT NULL,
    department VARCHAR(100),
    salary DECIMAL(10,2) NOT NULL,
    leave_balance INT NOT NULL DEFAULT 0
);

-- =========================================================
-- 3. INSERT SAMPLE DATA
-- =========================================================
INSERT INTO employees (employee_name, department, salary, leave_balance)
VALUES
('Aung Aung', 'IT', 800000, 10),
('Su Su', 'HR', 600000, 8),
('Kyaw Kyaw', 'Finance', 900000, 12),
('Hla Hla', 'Admin', 550000, 6),
('Mya Mya', 'IT', 750000, 9),
('Ko Ko', 'Operations', 700000, 11);

-- =========================================================
-- 4. VIEW INITIAL DATA
-- =========================================================
SELECT 'INITIAL EMPLOYEE DATA' AS info;
SELECT * FROM employees;

-- =========================================================
-- A — ATOMICITY
-- =========================================================
-- Definition:
-- A transaction must be completed fully or not at all.
--
-- Use Case:
-- HR updates employee salary and leave balance together.
-- If one step fails, the whole transaction should be rolled back.
-- =========================================================

SELECT 'ATOMICITY TEST - BEFORE SUCCESSFUL TRANSACTION' AS info;
SELECT * FROM employees WHERE employee_id = 1;

-- ---------------------------------------------------------
-- A1. SUCCESSFUL ATOMIC TRANSACTION
-- Both salary increase and leave deduction succeed
-- ---------------------------------------------------------
START TRANSACTION;

UPDATE employees
SET salary = salary + 50000
WHERE employee_id = 1;

UPDATE employees
SET leave_balance = leave_balance - 2
WHERE employee_id = 1;

COMMIT;

SELECT 'ATOMICITY TEST - AFTER SUCCESSFUL COMMIT' AS info;
SELECT * FROM employees WHERE employee_id = 1;

-- ---------------------------------------------------------
-- A2. ROLLBACK EXAMPLE
-- Mistake happens in second step
-- We rollback so first change does not remain alone
-- ---------------------------------------------------------
SELECT 'ATOMICITY TEST - BEFORE FAILED TRANSACTION' AS info;
SELECT * FROM employees WHERE employee_id = 2;

START TRANSACTION;

UPDATE employees
SET salary = salary + 50000
WHERE employee_id = 2;

-- Mistake / unexpected issue
-- This update affects no valid intended record
UPDATE employees
SET leave_balance = leave_balance - 100
WHERE employee_id = 999;

ROLLBACK;

SELECT 'ATOMICITY TEST - AFTER ROLLBACK' AS info;
SELECT * FROM employees WHERE employee_id = 2;

-- =========================================================
-- C — CONSISTENCY
-- =========================================================
-- Definition:
-- A transaction must move the database
-- from one valid state to another valid state.
--
-- Use Case:
-- HR should not allow negative leave balance.
-- Business rule:
-- leave_balance must remain >= 0
-- =========================================================

SELECT 'CONSISTENCY TEST - BEFORE VALID UPDATE' AS info;
SELECT * FROM employees WHERE employee_id = 3;

-- ---------------------------------------------------------
-- C1. VALID CONSISTENT TRANSACTION
-- Deduct leave only if enough leave balance exists
-- ---------------------------------------------------------
START TRANSACTION;

UPDATE employees
SET leave_balance = leave_balance - 3
WHERE employee_id = 3
  AND leave_balance >= 3;

COMMIT;

SELECT 'CONSISTENCY TEST - AFTER VALID UPDATE' AS info;
SELECT * FROM employees WHERE employee_id = 3;

-- ---------------------------------------------------------
-- C2. INVALID BUSINESS CASE EXAMPLE
-- This update logic prevents negative leave balance
-- ---------------------------------------------------------
SELECT 'CONSISTENCY TEST - BEFORE INVALID ATTEMPT' AS info;
SELECT * FROM employees WHERE employee_id = 4;

START TRANSACTION;

UPDATE employees
SET leave_balance = leave_balance - 20
WHERE employee_id = 4
  AND leave_balance >= 20;

COMMIT;

SELECT 'CONSISTENCY TEST - AFTER INVALID ATTEMPT (NO CHANGE EXPECTED)' AS info;
SELECT * FROM employees WHERE employee_id = 4;

-- =========================================================
-- I — ISOLATION
-- =========================================================
-- Definition:
-- Transactions should not interfere with each other
-- while running at the same time.
--
-- Use Case:
-- Two HR staff work on the same employee salary.
--
-- IMPORTANT:
-- Run this test in TWO separate MySQL sessions/windows.
-- =========================================================

-- ---------------------------------------------------------
-- SESSION 1
-- ---------------------------------------------------------
-- Run the following in Window 1:
--
USE hr_demo;
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
--
UPDATE employees
SET salary = salary + 100000
WHERE employee_id = 5;
--
SELECT * FROM employees WHERE employee_id = 5;
--
-- -- DO NOT COMMIT YET

-- ---------------------------------------------------------
-- SESSION 2
-- ---------------------------------------------------------
-- Run the following in Window 2:
--
-- USE hr_demo;
-- SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
--
-- SELECT * FROM employees WHERE employee_id = 5;
--
-- Expected:
-- Session 2 should still see the old committed salary,
-- not the uncommitted salary from Session 1.
--
-- Then go back to Session 1 and run:
Rollback;
COMMIT;
--
-- Then in Session 2 run again:
-- SELECT * FROM employees WHERE employee_id = 5;
--
-- Expected:
-- Now Session 2 can see the committed salary change.

-- =========================================================
-- D — DURABILITY
-- =========================================================
-- Definition:
-- Once a transaction is committed,
-- the change remains permanently saved.
--
-- Use Case:
-- HR updates employee salary and commits it.
-- Even if the system closes after commit,
-- the data should remain stored.
-- =========================================================

SELECT 'DURABILITY TEST - BEFORE COMMIT' AS info;
SELECT * FROM employees WHERE employee_id = 2;

START TRANSACTION;

UPDATE employees
SET salary = 950000
WHERE employee_id = 2;

COMMIT;

SELECT 'DURABILITY TEST - AFTER COMMIT' AS info;
SELECT * FROM employees WHERE employee_id = 2;

-- To manually test durability:
-- 1. Run the COMMIT above
-- 2. Disconnect and reconnect MySQL
-- 3. Run:
--    SELECT * FROM employees WHERE employee_id = 2;
-- If salary is still 950000, durability is confirmed.

-- =========================================================
-- FULL PRACTICAL EXAMPLE
-- =========================================================
-- Use Case: Employee promotion
--
-- When an employee is promoted:
-- 1. salary increases
-- 2. department changes
-- 3. leave balance gets 2 extra days
--
-- All changes should succeed together.
-- =========================================================

SELECT 'PROMOTION TEST - BEFORE SUCCESSFUL PROMOTION' AS info;
SELECT * FROM employees WHERE employee_id = 1;

-- ---------------------------------------------------------
-- FULL SUCCESSFUL TRANSACTION
-- ---------------------------------------------------------
START TRANSACTION;

UPDATE employees
SET salary = salary + 150000
WHERE employee_id = 1;

UPDATE employees
SET department = 'Senior IT'
WHERE employee_id = 1;

UPDATE employees
SET leave_balance = leave_balance + 2
WHERE employee_id = 1;

COMMIT;

SELECT 'PROMOTION TEST - AFTER SUCCESSFUL PROMOTION' AS info;
SELECT * FROM employees WHERE employee_id = 1;

-- ---------------------------------------------------------
-- FAILED PROMOTION EXAMPLE
-- If something goes wrong, rollback everything
-- ---------------------------------------------------------
SELECT 'PROMOTION TEST - BEFORE FAILED PROMOTION' AS info;
SELECT * FROM employees WHERE employee_id = 6;

START TRANSACTION;

UPDATE employees
SET salary = salary + 150000
WHERE employee_id = 6;

UPDATE employees
SET department = 'Senior Operations'
WHERE employee_id = 6;

-- Suppose this is wrong
UPDATE employees
SET leave_balance = leave_balance + 2
WHERE employee_id = 999;

SELECT * FROM employees WHERE employee_id = 6;
ROLLBACK;

SELECT 'PROMOTION TEST - AFTER FAILED PROMOTION ROLLBACK' AS info;
SELECT * FROM employees WHERE employee_id = 6;

-- =========================================================
-- FINAL TEST DATA VIEW
-- =========================================================
SELECT 'FINAL EMPLOYEE DATA' AS info;
SELECT * FROM employees;

-- =========================================================
-- SHORT ACID SUMMARY
-- =========================================================
-- Atomicity  : salary + leave update must both succeed or both fail
-- Consistency: leave balance should not become invalid
-- Isolation  : concurrent HR users should not disturb each other
-- Durability : committed changes remain permanently saved
-- =========================================================