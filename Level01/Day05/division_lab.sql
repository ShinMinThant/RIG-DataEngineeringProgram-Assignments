-- =====================================================
-- SQL DIVISION OPERATOR REAL CASE
-- Use Case: Employees who completed ALL required courses
-- =====================================================

DROP DATABASE IF EXISTS division_lab;
CREATE DATABASE division_lab;
USE division_lab;

-- =====================================================
-- 1. CREATE TABLES
-- =====================================================

CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    department VARCHAR(50) NOT NULL
);

CREATE TABLE required_courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL
);

CREATE TABLE employee_courses (
    employee_id INT NOT NULL,
    course_id INT NOT NULL,
    completion_date DATE NOT NULL,
    PRIMARY KEY (employee_id, course_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY (course_id) REFERENCES required_courses(course_id)
);

-- =====================================================
-- 2. POPULATE DATA
-- =====================================================

INSERT INTO employees (employee_name, department)
VALUES
('Aung Aung', 'IT'),
('Su Su', 'HR'),
('Kyaw Kyaw', 'Finance'),
('Mya Mya', 'IT'),
('Ko Ko', 'Operations');

INSERT INTO required_courses (course_name)
VALUES
('Cyber Security Awareness'),
('Data Privacy'),
('Workplace Safety');

-- Aung Aung completed ALL required courses
INSERT INTO employee_courses VALUES
(1, 1, '2026-01-10'),
(1, 2, '2026-01-11'),
(1, 3, '2026-01-12'),

-- Su Su completed only 2 courses
(2, 1, '2026-01-10'),
(2, 2, '2026-01-11'),

-- Kyaw Kyaw completed ALL required courses
(3, 1, '2026-01-15'),
(3, 2, '2026-01-16'),
(3, 3, '2026-01-17'),

-- Mya Mya completed only 1 course
(4, 1, '2026-01-20'),

-- Ko Ko completed ALL required courses
(5, 1, '2026-01-22'),
(5, 2, '2026-01-23'),
(5, 3, '2026-01-24');

-- =====================================================
-- 3. VIEW SAMPLE DATA
-- =====================================================

SELECT * FROM employees;
SELECT * FROM required_courses;
SELECT * FROM employee_courses;

-- =====================================================
-- 4. DIVISION QUERY
-- Find employees who completed ALL required courses
-- =====================================================

SELECT 
    e.employee_id,
    e.employee_name,
    e.department
FROM employees e
JOIN employee_courses ec 
    ON e.employee_id = ec.employee_id
GROUP BY 
    e.employee_id, 
    e.employee_name, 
    e.department
HAVING COUNT(DISTINCT ec.course_id) = (
    SELECT COUNT(*) FROM required_courses
);

-- Expected result:
-- Aung Aung
-- Kyaw Kyaw
-- Ko Ko

-- =====================================================
-- 5. SHOW COMPLETION COUNT PER EMPLOYEE
-- =====================================================

SELECT 
    e.employee_name,
    COUNT(DISTINCT ec.course_id) AS completed_courses,
    (SELECT COUNT(*) FROM required_courses) AS required_courses
FROM employees e
LEFT JOIN employee_courses ec 
    ON e.employee_id = ec.employee_id
GROUP BY e.employee_id, e.employee_name;

-- =====================================================
-- 6. FIND EMPLOYEES WHO HAVE NOT COMPLETED ALL COURSES
-- =====================================================

SELECT 
    e.employee_id,
    e.employee_name,
    e.department
FROM employees e
LEFT JOIN employee_courses ec 
    ON e.employee_id = ec.employee_id
GROUP BY 
    e.employee_id, 
    e.employee_name, 
    e.department
HAVING COUNT(DISTINCT ec.course_id) < (
    SELECT COUNT(*) FROM required_courses
);

-- Expected result:
-- Su Su
-- Mya Mya