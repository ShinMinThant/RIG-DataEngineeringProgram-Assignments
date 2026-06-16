/* ============================================================
   MSSQL LAB: Telecom Data Mapping
   Business Case → Database Fields
   Use Case: Telecom Operator Recharge & Data Usage Analytics
   ============================================================ */

-- 1. Create Database
CREATE DATABASE TelecomDataMappingLab;
GO

USE TelecomDataMappingLab;
GO

/* ============================================================
   2. Create Tables
   ============================================================ */

-- Customer master table
CREATE TABLE customers (
    customer_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_full_name VARCHAR(100) NOT NULL,
    nrc_number VARCHAR(50),
    gender VARCHAR(10),
    city VARCHAR(50),
    created_at DATETIME DEFAULT GETDATE()
);
GO

-- Subscriber / SIM table
CREATE TABLE subscribers (
    subscriber_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT NOT NULL,
    msisdn VARCHAR(20) NOT NULL UNIQUE,
    sim_number VARCHAR(30) NOT NULL,
    package_type VARCHAR(50),
    activation_date DATE,
    status VARCHAR(20),
    CONSTRAINT fk_subscriber_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
GO

-- Recharge transaction table
CREATE TABLE recharge_transactions (
    recharge_id INT IDENTITY(1,1) PRIMARY KEY,
    subscriber_id INT NOT NULL,
    recharge_amount DECIMAL(12,2) NOT NULL,
    recharge_channel VARCHAR(50),
    recharge_created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT fk_recharge_subscriber
        FOREIGN KEY (subscriber_id) REFERENCES subscribers(subscriber_id)
);
GO

-- Data usage table
CREATE TABLE data_usage (
    usage_id INT IDENTITY(1,1) PRIMARY KEY,
    subscriber_id INT NOT NULL,
    usage_date DATE NOT NULL,
    total_data_mb DECIMAL(12,2) NOT NULL,
    network_type VARCHAR(20),
    CONSTRAINT fk_usage_subscriber
        FOREIGN KEY (subscriber_id) REFERENCES subscribers(subscriber_id)
);
GO

-- Business-to-database mapping table
CREATE TABLE data_mapping_catalog (
    mapping_id INT IDENTITY(1,1) PRIMARY KEY,
    business_term VARCHAR(100) NOT NULL,
    source_system VARCHAR(100),
    database_table VARCHAR(100),
    database_field VARCHAR(100),
    field_description VARCHAR(255),
    data_type VARCHAR(50),
    data_owner VARCHAR(100)
);
GO

/* ============================================================
   3. Insert Sample Data
   ============================================================ */

INSERT INTO customers (customer_full_name, nrc_number, gender, city)
VALUES
('Aung Aung', '12/ABC(N)123456', 'Male', 'Yangon'),
('Su Su', '10/XYZ(N)234567', 'Female', 'Mandalay'),
('Kyaw Kyaw', '8/MNO(N)345678', 'Male', 'Naypyitaw'),
('Hla Hla', '7/PQR(N)456789', 'Female', 'Bago'),
('Mya Mya', '9/STU(N)567890', 'Female', 'Yangon');
GO

INSERT INTO subscribers 
(customer_id, msisdn, sim_number, package_type, activation_date, status)
VALUES
(1, '09790000001', 'SIM100001', 'Prepaid', '2025-01-10', 'Active'),
(2, '09790000002', 'SIM100002', 'Postpaid', '2025-02-15', 'Active'),
(3, '09790000003', 'SIM100003', 'Prepaid', '2025-03-20', 'Inactive'),
(4, '09790000004', 'SIM100004', 'Prepaid', '2025-04-05', 'Active'),
(5, '09790000005', 'SIM100005', 'Postpaid', '2025-05-12', 'Active');
GO

INSERT INTO recharge_transactions 
(subscriber_id, recharge_amount, recharge_channel, recharge_created_at)
VALUES
(1, 5000, 'Mobile Wallet', '2026-05-01 09:30:00'),
(1, 7000, 'Retail Shop', '2026-05-03 14:20:00'),
(2, 15000, 'Bank App', '2026-05-02 10:10:00'),
(3, 3000, 'Retail Shop', '2026-05-04 16:45:00'),
(4, 12000, 'Mobile Wallet', '2026-05-05 11:00:00'),
(5, 20000, 'Bank App', '2026-05-06 18:30:00'),
(1, 10000, 'Mobile Wallet', '2026-05-07 08:00:00');
GO

INSERT INTO data_usage
(subscriber_id, usage_date, total_data_mb, network_type)
VALUES
(1, '2026-05-01', 1200.50, '4G'),
(1, '2026-05-02', 850.25, '4G'),
(2, '2026-05-02', 2300.75, '5G'),
(3, '2026-05-03', 400.00, '3G'),
(4, '2026-05-04', 1750.30, '4G'),
(5, '2026-05-05', 3200.90, '5G'),
(1, '2026-05-06', 1500.00, '4G');
GO

INSERT INTO data_mapping_catalog
(business_term, source_system, database_table, database_field, field_description, data_type, data_owner)
VALUES
('Customer Name', 'CRM System', 'customers', 'customer_full_name', 'Full name of telecom customer', 'VARCHAR(100)', 'CRM Team'),
('Customer NRC', 'CRM System', 'customers', 'nrc_number', 'National registration number', 'VARCHAR(50)', 'CRM Team'),
('Customer City', 'CRM System', 'customers', 'city', 'Customer registered city', 'VARCHAR(50)', 'CRM Team'),
('Mobile Number', 'Billing System', 'subscribers', 'msisdn', 'Customer mobile phone number', 'VARCHAR(20)', 'Billing Team'),
('SIM Number', 'Billing System', 'subscribers', 'sim_number', 'SIM card serial number', 'VARCHAR(30)', 'Billing Team'),
('Package Type', 'Billing System', 'subscribers', 'package_type', 'Prepaid or postpaid package type', 'VARCHAR(50)', 'Product Team'),
('Recharge Amount', 'Billing System', 'recharge_transactions', 'recharge_amount', 'Top-up amount by customer', 'DECIMAL(12,2)', 'Billing Team'),
('Recharge Date', 'Billing System', 'recharge_transactions', 'recharge_created_at', 'Date and time of recharge', 'DATETIME', 'Billing Team'),
('Recharge Channel', 'Billing System', 'recharge_transactions', 'recharge_channel', 'Channel used for recharge', 'VARCHAR(50)', 'Sales Team'),
('Internet Usage', 'Network System', 'data_usage', 'total_data_mb', 'Total internet usage in MB', 'DECIMAL(12,2)', 'Network Team'),
('Usage Date', 'Network System', 'data_usage', 'usage_date', 'Date of internet usage', 'DATE', 'Network Team'),
('Network Type', 'Network System', 'data_usage', 'network_type', '3G, 4G, or 5G network type', 'VARCHAR(20)', 'Network Team');
GO

/* ============================================================
   4. Basic SELECT Queries
   ============================================================ */

-- View all customers
SELECT * FROM customers;
GO

-- View all subscribers
SELECT * FROM subscribers;
GO

-- View all recharge transactions
SELECT * FROM recharge_transactions;
GO

-- View all data usage records
SELECT * FROM data_usage;
GO

-- View data mapping catalog
SELECT * FROM data_mapping_catalog;
GO

/* ============================================================
   5. Business Case 1: Customer and SIM Information
   ============================================================ */

SELECT
    c.customer_full_name AS [Customer Name],
    c.city AS [City],
    s.msisdn AS [Mobile Number],
    s.sim_number AS [SIM Number],
    s.package_type AS [Package Type],
    s.status AS [Subscriber Status]
FROM customers c
INNER JOIN subscribers s
    ON c.customer_id = s.customer_id;
GO

/* ============================================================
   6. Business Case 2: Recharge History
   ============================================================ */

SELECT
    c.customer_full_name AS [Customer Name],
    s.msisdn AS [Mobile Number],
    r.recharge_amount AS [Recharge Amount],
    r.recharge_channel AS [Recharge Channel],
    r.recharge_created_at AS [Recharge Date]
FROM customers c
INNER JOIN subscribers s
    ON c.customer_id = s.customer_id
INNER JOIN recharge_transactions r
    ON s.subscriber_id = r.subscriber_id
ORDER BY r.recharge_created_at;
GO

/* ============================================================
   7. Business Case 3: Total Recharge by Customer
   ============================================================ */

SELECT
    c.customer_full_name AS [Customer Name],
    s.msisdn AS [Mobile Number],
    SUM(r.recharge_amount) AS [Total Recharge Amount]
FROM customers c
INNER JOIN subscribers s
    ON c.customer_id = s.customer_id
INNER JOIN recharge_transactions r
    ON s.subscriber_id = r.subscriber_id
GROUP BY c.customer_full_name, s.msisdn
ORDER BY [Total Recharge Amount] DESC;
GO

/* ============================================================
   8. Business Case 4: Customers Recharged More Than 10,000 MMK
   ============================================================ */

SELECT
    c.customer_full_name AS [Customer Name],
    s.msisdn AS [Mobile Number],
    SUM(r.recharge_amount) AS [Total Recharge Amount]
FROM customers c
INNER JOIN subscribers s
    ON c.customer_id = s.customer_id
INNER JOIN recharge_transactions r
    ON s.subscriber_id = r.subscriber_id
GROUP BY c.customer_full_name, s.msisdn
HAVING SUM(r.recharge_amount) > 10000
ORDER BY [Total Recharge Amount] DESC;
GO

/* ============================================================
   9. Business Case 5: Data Usage by Customer
   ============================================================ */

SELECT
    c.customer_full_name AS [Customer Name],
    s.msisdn AS [Mobile Number],
    d.usage_date AS [Usage Date],
    d.total_data_mb AS [Data Usage MB],
    d.network_type AS [Network Type]
FROM customers c
INNER JOIN subscribers s
    ON c.customer_id = s.customer_id
INNER JOIN data_usage d
    ON s.subscriber_id = d.subscriber_id
ORDER BY d.usage_date;
GO

/* ============================================================
   10. Business Case 6: Total Data Usage by Customer
   ============================================================ */

SELECT
    c.customer_full_name AS [Customer Name],
    s.msisdn AS [Mobile Number],
    SUM(d.total_data_mb) AS [Total Data Usage MB]
FROM customers c
INNER JOIN subscribers s
    ON c.customer_id = s.customer_id
INNER JOIN data_usage d
    ON s.subscriber_id = d.subscriber_id
GROUP BY c.customer_full_name, s.msisdn
ORDER BY [Total Data Usage MB] DESC;
GO

/* ============================================================
   11. Business Case 7: Combined Recharge and Data Usage Summary
   ============================================================ */

SELECT
    c.customer_full_name AS [Customer Name],
    s.msisdn AS [Mobile Number],
    s.package_type AS [Package Type],
    SUM(DISTINCT r.recharge_amount) AS [Total Recharge Amount],
    SUM(d.total_data_mb) AS [Total Data Usage MB]
FROM customers c
INNER JOIN subscribers s
    ON c.customer_id = s.customer_id
LEFT JOIN recharge_transactions r
    ON s.subscriber_id = r.subscriber_id
LEFT JOIN data_usage d
    ON s.subscriber_id = d.subscriber_id
GROUP BY c.customer_full_name, s.msisdn, s.package_type;
GO

/* ============================================================
   12. Search Mapping Catalog
   Business Question:
   Which database field is used for Mobile Number?
   ============================================================ */

SELECT
    business_term,
    source_system,
    database_table,
    database_field,
    field_description,
    data_type
FROM data_mapping_catalog
WHERE business_term = 'Mobile Number';
GO

/* ============================================================
   13. Search All Billing System Fields
   ============================================================ */

SELECT
    business_term,
    database_table,
    database_field,
    field_description
FROM data_mapping_catalog
WHERE source_system = 'Billing System';
GO

/* ============================================================
   14. Create View for Business Users
   ============================================================ */

CREATE VIEW vw_customer_recharge_summary AS
SELECT
    c.customer_full_name,
    c.city,
    s.msisdn,
    s.package_type,
    SUM(r.recharge_amount) AS total_recharge_amount
FROM customers c
INNER JOIN subscribers s
    ON c.customer_id = s.customer_id
INNER JOIN recharge_transactions r
    ON s.subscriber_id = r.subscriber_id
GROUP BY c.customer_full_name, c.city, s.msisdn, s.package_type;
GO

-- Test View
SELECT * FROM vw_customer_recharge_summary;
GO

/* ============================================================
   15. Stored Procedure: Get Customer Recharge Summary
   ============================================================ */

CREATE PROCEDURE sp_get_customer_recharge_summary
AS
BEGIN
    SELECT
        customer_full_name,
        city,
        msisdn,
        package_type,
        total_recharge_amount
    FROM vw_customer_recharge_summary
    ORDER BY total_recharge_amount DESC;
END;
GO

-- Execute Stored Procedure
EXEC sp_get_customer_recharge_summary;
GO

/* ============================================================
   16. Stored Procedure: Search Mapping by Business Term
   ============================================================ */

CREATE PROCEDURE sp_search_data_mapping
    @BusinessTerm VARCHAR(100)
AS
BEGIN
    SELECT
        business_term,
        source_system,
        database_table,
        database_field,
        field_description,
        data_type,
        data_owner
    FROM data_mapping_catalog
    WHERE business_term LIKE '%' + @BusinessTerm + '%';
END;
GO

-- Example
EXEC sp_search_data_mapping 'Recharge';
GO

/* ============================================================
   17. Data Quality Check
   ============================================================ */

-- Check missing customer names
SELECT *
FROM customers
WHERE customer_full_name IS NULL;
GO

-- Check inactive subscribers
SELECT *
FROM subscribers
WHERE status = 'Inactive';
GO

-- Check recharge amount less than or equal to zero
SELECT *
FROM recharge_transactions
WHERE recharge_amount <= 0;
GO

-- Check data usage less than zero
SELECT *
FROM data_usage
WHERE total_data_mb < 0;
GO

/* ============================================================
   18. Final Business Report
   ============================================================ */

SELECT
    c.customer_full_name AS [Customer Name],
    c.city AS [City],
    s.msisdn AS [Mobile Number],
    s.package_type AS [Package Type],
    s.status AS [Status],
    ISNULL(SUM(r.recharge_amount), 0) AS [Total Recharge],
    ISNULL(SUM(d.total_data_mb), 0) AS [Total Data Usage MB]
FROM customers c
INNER JOIN subscribers s
    ON c.customer_id = s.customer_id
LEFT JOIN recharge_transactions r
    ON s.subscriber_id = r.subscriber_id
LEFT JOIN data_usage d
    ON s.subscriber_id = d.subscriber_id
GROUP BY
    c.customer_full_name,
    c.city,
    s.msisdn,
    s.package_type,
    s.status
ORDER BY [Total Recharge] DESC;
GO
