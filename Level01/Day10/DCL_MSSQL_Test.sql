/* =============================================
   DATA CONTROL LANGUAGE (DCL) LAB
   Microsoft SQL Server (MSSQL)
   Beginner to Intermediate Level
   eCommerce Security Use Case
============================================= */

-- =============================================
-- STEP 1: CREATE DATABASE
-- =============================================

CREATE DATABASE ecommerce_security_db;
GO

USE ecommerce_security_db;
GO

/* =============================================
   STEP 2: CREATE SAMPLE TABLES
============================================= */

CREATE TABLE products (

    product_id INT IDENTITY(1,1) PRIMARY KEY,

    product_name VARCHAR(100),

    price DECIMAL(10,2),

    stock_qty INT

);
GO

CREATE TABLE orders (

    order_id INT IDENTITY(1,1) PRIMARY KEY,

    customer_name VARCHAR(100),

    total_amount DECIMAL(10,2)

);
GO

/* =============================================
   STEP 3: INSERT SAMPLE DATA
============================================= */

INSERT INTO products
(product_name, price, stock_qty)
VALUES
('Laptop', 1200000, 10),
('Mouse', 25000, 100),
('Keyboard', 45000, 50),
('Monitor', 350000, 20),
('Printer', 450000, 5);
GO

INSERT INTO orders
(customer_name, total_amount)
VALUES
('Aung Aung', 1250000),
('Su Su', 45000),
('Kyaw Kyaw', 300000);
GO

/* =============================================
   STEP 4: VIEW SAMPLE DATA
============================================= */

SELECT * FROM products;
GO

SELECT * FROM orders;
GO

/* =============================================
   STEP 5: CREATE SQL SERVER LOGINS
   NOTE:
   Logins are created at SQL Server level
============================================= */

CREATE LOGIN admin_user
WITH PASSWORD = 'Admin@123';
GO

CREATE LOGIN sales_user
WITH PASSWORD = 'Sales@123';
GO

CREATE LOGIN report_user
WITH PASSWORD = 'Report@123';
GO

/* =============================================
   STEP 6: CREATE DATABASE USERS
   NOTE:
   Users are mapped to logins
============================================= */

USE ecommerce_security_db;
GO

CREATE USER admin_user
FOR LOGIN admin_user;
GO

CREATE USER sales_user
FOR LOGIN sales_user;
GO

CREATE USER report_user
FOR LOGIN report_user;
GO

-- check user roles

SELECT
    dp1.name AS database_role,
    dp2.name AS database_user
FROM sys.database_role_members drm
JOIN sys.database_principals dp1
    ON drm.role_principal_id = dp1.principal_id
JOIN sys.database_principals dp2
    ON drm.member_principal_id = dp2.principal_id
WHERE dp2.name = 'report_user';

/* =============================================
   STEP 7: VIEW USERS
============================================= */

SELECT
    name,
    type_desc
FROM sys.database_principals
WHERE type IN ('S', 'U');
GO

/* =============================================
   STEP 8: GRANT PERMISSIONS
============================================= */

-- =============================================
-- ADMIN USER
-- Full control on database
-- =============================================

GRANT CONTROL
ON DATABASE::ecommerce_security_db
TO admin_user;
GO

/* =============================================
   SALES USER
   Can:
   - Read products
   - Read orders
   - Insert orders
============================================= */

GRANT SELECT
ON products
TO sales_user;
GO

GRANT SELECT, INSERT
ON orders
TO sales_user;
GO

/* =============================================
   REPORT USER
   Read-only access
============================================= */

GRANT SELECT
ON products
TO report_user;
GO

GRANT SELECT
ON orders
TO report_user;
GO

/* =============================================
   STEP 9: TEST admin_user
============================================= */

EXECUTE AS USER = 'admin_user';
GO

SELECT * FROM products;
GO

SELECT * FROM orders;
GO

REVERT;
GO

/* =============================================
   STEP 10: TEST sales_user
============================================= */

EXECUTE AS USER = 'sales_user';
GO

-- Allowed: View products

SELECT * FROM products;
GO

-- Allowed: View orders

SELECT * FROM orders;
GO

-- Allowed: Insert orders

INSERT INTO orders
(customer_name, total_amount)
VALUES
('Mya Mya', 550000);
GO

SELECT * FROM orders;
GO

REVERT;
GO

/* =============================================
   STEP 11: TEST report_user
============================================= */

EXECUTE AS USER = 'report_user';
GO

-- Allowed: Read-only access

SELECT * FROM products;
GO

SELECT * FROM orders;
GO

REVERT;
GO

SELECT USER_NAME();
/* =============================================
   STEP 12: TEST report_user CANNOT INSERT
============================================= */

EXECUTE AS USER = 'report_user';
GO

-- This should FAIL

INSERT INTO orders
(customer_name, total_amount)
VALUES
('Unauthorized User', 1000);
GO

-- REVERT back to dbo/admin
REVERT;
GO

/* =============================================
   EXPECTED ERROR:
   INSERT permission denied
============================================= */

/* =============================================
   STEP 13: REVOKE PERMISSION
   Remove INSERT permission from sales_user
============================================= */

REVOKE INSERT
ON orders
FROM sales_user;
GO

/* =============================================
   STEP 14: TEST REVOKE
============================================= */

EXECUTE AS USER = 'sales_user';
GO

-- This should FAIL after REVOKE

INSERT INTO orders
(customer_name, total_amount)
VALUES
('Blocked User', 5000);
GO

REVERT;
GO

/* =============================================
   STEP 15: DENY DELETE PERMISSION
============================================= */

DENY DELETE
ON orders
TO sales_user;
GO

/* =============================================
   STEP 16: TEST DENY
============================================= */

EXECUTE AS USER = 'sales_user';
GO

-- This should FAIL

DELETE FROM orders
WHERE order_id = 1;
GO

REVERT;
GO

/* =============================================
   STEP 17: VIEW USER PERMISSIONS
============================================= */

SELECT

    pr.name AS user_name,

    pe.permission_name,

    pe.state_desc,

    ob.name AS object_name

FROM sys.database_permissions pe

JOIN sys.database_principals pr
    ON pe.grantee_principal_id = pr.principal_id

JOIN sys.objects ob
    ON pe.major_id = ob.object_id

ORDER BY pr.name;
GO

/* =============================================
   STEP 18: VIEW CURRENT SESSION USER
============================================= */

SELECT
    USER_NAME() AS current_database_user;
GO

/* =============================================
   STEP 19: VIEW CURRENT LOGIN
============================================= */

SELECT
    SYSTEM_USER AS current_login;
GO

/* =============================================
   STEP 20: SHOW LOGIN INFORMATION
============================================= */

SELECT
    name,
    type_desc,
    create_date
FROM sys.server_principals
WHERE type IN ('S', 'U');
GO

/* =============================================
   STEP 21: CLEANUP SECTION
   DROP USERS
============================================= */

DROP USER admin_user;
GO

DROP USER sales_user;
GO

DROP USER report_user;
GO

/* =============================================
   STEP 22: DROP LOGINS
============================================= */

DROP LOGIN admin_user;
GO

DROP LOGIN sales_user;
GO

DROP LOGIN report_user;
GO

/* =============================================
   END OF DCL LAB SCRIPT
============================================= */