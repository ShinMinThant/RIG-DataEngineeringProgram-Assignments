--Part 4: Import CSV into MSSQL
--7. Bulk Insert Sales Data
USE CompanyDW;
GO

BULK INSERT sales.customers
FROM 'C:\DE_Scholarship\customers.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    TABLOCK
);

BULK INSERT sales.products
FROM 'C:\DE_Scholarship\products.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    TABLOCK
);

BULK INSERT sales.orders
FROM 'C:\DE_Scholarship\orders.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    TABLOCK
);
--8. Bulk Insert HR Data
BULK INSERT hr.departments
FROM 'C:\DE_Scholarship\departments.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    TABLOCK
);

BULK INSERT hr.employees
FROM 'C:\DE_Scholarship\employees.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    TABLOCK
);
--Part 5: Verify Migration
-- Check row counts
SELECT 'sales.customers' AS table_name, COUNT(*) AS total_rows FROM sales.customers
UNION ALL
SELECT 'sales.products', COUNT(*) FROM sales.products
UNION ALL
SELECT 'sales.orders', COUNT(*) FROM sales.orders
UNION ALL
SELECT 'hr.departments', COUNT(*) FROM hr.departments
UNION ALL
SELECT 'hr.employees', COUNT(*) FROM hr.employees;
--Check Migrated Sales Data
SELECT 
    o.order_id,
    c.customer_name,
    c.city,
    o.order_date,
    o.total_amount
FROM sales.orders o
INNER JOIN sales.customers c
    ON o.customer_id = c.customer_id;

--Check Migrated HR Data
SELECT 
    e.employee_id,
    e.employee_name,
    d.department_name,
    e.salary,
    e.hire_date
FROM hr.employees e
INNER JOIN hr.departments d
    ON e.department_id = d.department_id;
--Part 6: Migration Validation Queries
-- Check orphan orders
SELECT o.*
FROM sales.orders o
LEFT JOIN sales.customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Check orphan employees
SELECT e.*
FROM hr.employees e
LEFT JOIN hr.departments d
    ON e.department_id = d.department_id
WHERE d.department_id IS NULL;

-- Check NULL important fields
SELECT *
FROM sales.customers
WHERE customer_name IS NULL OR phone IS NULL;

SELECT *
FROM hr.employees
WHERE employee_name IS NULL OR department_id IS NULL;