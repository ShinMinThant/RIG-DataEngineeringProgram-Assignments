-- SESSION 2
-- ---------------------------------------------------------
-- Run the following in Window 2:
--
DROP DATABASE IF EXISTS hr_demo;
USE hr_demo;
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
--
SELECT * FROM employees WHERE employee_id = 5;
--
-- Expected:
-- Session 2 should still see the old committed salary,
-- not the uncommitted salary from Session 1.