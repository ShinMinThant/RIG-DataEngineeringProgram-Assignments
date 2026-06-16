/* =============================================
   COMPANY DATABASE STORED PROCEDURE LAB
   Beginner Level MSSQL Stored Procedure Examples
   SQL Server Version
============================================= */

-- =============================================
-- STEP 1: CREATE DATABASE
-- =============================================

CREATE DATABASE company_db;
GO

USE company_db;
GO

-- =============================================
-- STEP 2: CREATE EMPLOYEES TABLE
-- =============================================

CREATE TABLE employees (

    employee_id INT IDENTITY(1,1) PRIMARY KEY,

    employee_name VARCHAR(100) NOT NULL,

    department VARCHAR(100),

    salary DECIMAL(10,2),

    address VARCHAR(255),

    phone_number VARCHAR(20),

    created_at DATETIME DEFAULT GETDATE()

);
GO

-- =============================================
-- STEP 3: INSERT SAMPLE DATA
-- =============================================

INSERT INTO employees
(employee_name, department, salary, address, phone_number)
VALUES
('Aung Aung', 'IT', 800000, 'Yangon', '091111111'),
('Su Su', 'HR', 600000, 'Mandalay', '092222222'),
('Kyaw Kyaw', 'Finance', 900000, 'Naypyitaw', '093333333'),
('Mya Mya', 'Marketing', 700000, 'Yangon', '094444444'),
('Ko Ko', 'IT', 850000, 'Bago', '095555555');
GO

-- =============================================
-- VIEW CURRENT EMPLOYEE DATA
-- =============================================

SELECT * FROM employees;
GO

/* =============================================
   STORED PROCEDURE 1:
   InsertEmployee
   PURPOSE:
   Insert new employee records
============================================= */

CREATE PROCEDURE InsertEmployee

    @p_employee_name VARCHAR(100),

    @p_department VARCHAR(100),

    @p_salary DECIMAL(10,2),

    @p_address VARCHAR(255),

    @p_phone_number VARCHAR(20)

AS
BEGIN

    INSERT INTO employees(

        employee_name,

        department,

        salary,

        address,

        phone_number

    )

    VALUES(

        @p_employee_name,

        @p_department,

        @p_salary,

        @p_address,

        @p_phone_number

    );

END;
GO

-- =============================================
-- EXECUTE InsertEmployee PROCEDURE
-- =============================================

EXEC InsertEmployee
    'Hla Hla',
    'Admin',
    500000,
    'Yangon',
    '096666666';
GO

-- =============================================
-- VIEW DATA AFTER INSERT
-- =============================================

SELECT * FROM employees;
GO

/* =============================================
   STORED PROCEDURE 2:
   DeleteEmployee
   PURPOSE:
   Delete employee using employee ID
============================================= */

CREATE PROCEDURE DeleteEmployee

    @p_employee_id INT

AS
BEGIN

    DELETE FROM employees
    WHERE employee_id = @p_employee_id;

END;
GO

-- =============================================
-- EXECUTE DeleteEmployee PROCEDURE
-- =============================================

EXEC DeleteEmployee 5;
GO

-- =============================================
-- VIEW DATA AFTER DELETE
-- =============================================

SELECT * FROM employees;
GO

/* =============================================
   STORED PROCEDURE 3:
   UpdateEmployeeAddress
   PURPOSE:
   Update employee address
============================================= */

CREATE PROCEDURE UpdateEmployeeAddress

    @p_employee_id INT,

    @p_new_address VARCHAR(255)

AS
BEGIN

    UPDATE employees

    SET address = @p_new_address

    WHERE employee_id = @p_employee_id;

END;
GO

-- =============================================
-- EXECUTE UpdateEmployeeAddress PROCEDURE
-- =============================================

EXEC UpdateEmployeeAddress 2, 'Taunggyi';
GO

-- =============================================
-- VIEW DATA AFTER UPDATE
-- =============================================

SELECT * FROM employees;
GO

/* =============================================
   STORED PROCEDURE 4:
   GetEmployees
   PURPOSE:
   Retrieve all employee records
============================================= */

CREATE PROCEDURE GetEmployees

AS
BEGIN

    SELECT *
    FROM employees;

END;
GO

-- =============================================
-- EXECUTE GetEmployees PROCEDURE
-- =============================================

EXEC GetEmployees;
GO

/* =============================================
   STORED PROCEDURE 5:
   GetEmployeeCount
   PURPOSE:
   Return total employee count
   OUTPUT PARAMETER EXAMPLE
============================================= */

CREATE PROCEDURE GetEmployeeCount

    @p_total_employees INT OUTPUT

AS
BEGIN

    SELECT @p_total_employees = COUNT(*)
    FROM employees;

END;
GO

-- =============================================
-- EXECUTE GetEmployeeCount PROCEDURE
-- =============================================

DECLARE @total INT;

EXEC GetEmployeeCount @total OUTPUT;

SELECT @total AS total_employees;
GO

/* =============================================
   STORED PROCEDURE 6:
   IncreaseSalary
   PURPOSE:
   Increase employee salary and
   return updated salary
============================================= */

CREATE PROCEDURE IncreaseSalary

    @p_employee_id INT,

    @p_increment DECIMAL(10,2) OUTPUT

AS
BEGIN

    -- Increase salary

    UPDATE employees

    SET salary = salary + @p_increment

    WHERE employee_id = @p_employee_id;

    -- Return updated salary

    SELECT @p_increment = salary

    FROM employees

    WHERE employee_id = @p_employee_id;

END;
GO

-- =============================================
-- EXECUTE IncreaseSalary PROCEDURE
-- =============================================

DECLARE @new_salary DECIMAL(10,2);

SET @new_salary = 50000;

EXEC IncreaseSalary 1, @new_salary OUTPUT;

SELECT @new_salary AS updated_salary;
GO

-- =============================================
-- VIEW ALL STORED PROCEDURES
-- =============================================

SELECT
    name,
    create_date,
    modify_date
FROM sys.procedures;
GO

-- =============================================
-- VIEW PROCEDURE DEFINITION
-- =============================================

EXEC sp_helptext 'GetEmployees';
GO

-- =============================================
-- ALTER STORED PROCEDURE EXAMPLE
-- =============================================

ALTER PROCEDURE GetEmployees

AS
BEGIN

    SELECT
        employee_id,
        employee_name,
        department,
        salary
    FROM employees;

END;
GO

-- =============================================
-- EXECUTE ALTERED PROCEDURE
-- =============================================

EXEC GetEmployees;
GO

-- Local temporary stored procedures

DROP PROCEDURE IF EXISTS #TempEmployeeReport;
GO

CREATE PROCEDURE #TempEmployeeReport
AS
BEGIN

    SELECT
        employee_id,
        employee_name,
        department,
        salary
    FROM employees
    WHERE salary >= 700000;

END;
GO

EXEC #TempEmployeeReport;
GO

-- Global temporary stored procedures

DROP PROCEDURE IF EXISTS ##GlobalEmployeeReport;
GO

CREATE PROCEDURE ##GlobalEmployeeReport
AS
BEGIN

    SELECT
        employee_id,
        employee_name,
        department,
        salary
    FROM employees
    WHERE salary >= 800000;

END;
GO

EXEC ##GlobalEmployeeReport;
GO

-- Check Session IDs

SELECT @@SPID AS session_id;
-- =============================================
-- DROP PROCEDURE EXAMPLES
-- =============================================

-- DROP PROCEDURE InsertEmployee;
-- DROP PROCEDURE DeleteEmployee;
-- DROP PROCEDURE UpdateEmployeeAddress;
-- DROP PROCEDURE GetEmployees;
-- DROP PROCEDURE GetEmployeeCount;
-- DROP PROCEDURE IncreaseSalary;

-- =============================================
-- END OF MSSQL LAB SCRIPT
-- =============================================