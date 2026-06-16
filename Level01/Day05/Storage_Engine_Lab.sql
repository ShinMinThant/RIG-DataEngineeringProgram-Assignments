-- =====================================================
-- MySQL Storage Engines Hands-on Lab
-- Engines: InnoDB, MyISAM, MEMORY, CSV, ARCHIVE
-- =====================================================

DROP DATABASE IF EXISTS storage_engine_lab;
CREATE DATABASE storage_engine_lab;
USE storage_engine_lab;

-- Check supported engines
SHOW ENGINES;
-- Support means Indicates whether the storage engine is available and usable in MySQL.
-- XA means Indicates whether the engine supports XA Transactions (Distributed Transactions).
-- Savepoints means Indicates whether the engine supports SAVEPOINT inside transactions.

-- =====================================================
-- 1. CREATE TABLES WITH DIFFERENT STORAGE ENGINES
-- =====================================================

CREATE TABLE customers_innodb (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE customers_myisam (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=MyISAM;

CREATE TABLE customers_memory (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=MEMORY;

-- CSV - null value pay lo ma ya
CREATE TABLE customers_csv (
    customer_id INT NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=CSV;

CREATE TABLE customers_archive (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=ARCHIVE;

-- Check table engines
SHOW TABLE STATUS WHERE Name LIKE 'customers_%';

-- =====================================================
-- 2. INSERT SAMPLE DATA
-- =====================================================

INSERT INTO customers_innodb (customer_name, email)
VALUES
('Aung Aung', 'aung@example.com'),
('Su Su', 'susu@example.com'),
('Kyaw Kyaw', 'kyaw@example.com');

INSERT INTO customers_myisam (customer_name, email)
SELECT customer_name, email FROM customers_innodb;

INSERT INTO customers_memory (customer_name, email)
SELECT customer_name, email FROM customers_innodb;

INSERT INTO customers_csv (customer_id, customer_name, email)
VALUES
(1, 'Aung Aung', 'aung@example.com'),
(2, 'Su Su', 'susu@example.com'),
(3, 'Kyaw Kyaw', 'kyaw@example.com');

INSERT INTO customers_archive (customer_name, email)
SELECT customer_name, email FROM customers_innodb;

-- View data
SELECT * FROM customers_innodb;
SELECT * FROM customers_myisam;
SELECT * FROM customers_memory;
SELECT * FROM customers_csv;
SELECT * FROM customers_archive;

USE storage_engine_lab;

-- =========================================
-- TABLE SIZE REPORT BY STORAGE ENGINE
-- =========================================
SELECT
    table_name,
    engine,
    table_rows,
    ROUND(data_length / 1024, 2) AS data_kb,
    ROUND(index_length / 1024, 2) AS index_kb,
    ROUND((data_length + index_length) / 1024, 2) AS total_kb,
    ROUND(data_free / 1024, 2) AS free_kb
FROM information_schema.tables
WHERE table_schema = 'storage_engine_lab'
ORDER BY total_kb DESC;

-- =====================================================
-- 3. TRANSACTION TEST
-- InnoDB supports ROLLBACK
-- MyISAM, MEMORY, CSV, ARCHIVE do not support real rollback
-- =====================================================

START TRANSACTION;

INSERT INTO customers_innodb (customer_name, email)
VALUES ('Rollback Test InnoDB', 'rollback_innodb@example.com');

SELECT * FROM customers_innodb;

ROLLBACK;

SELECT * FROM customers_innodb
WHERE customer_name = 'Rollback Test InnoDB';

-- MyISAM rollback test
START TRANSACTION;

INSERT INTO customers_myisam (customer_name, email)
VALUES ('Rollback Test MyISAM', 'rollback_myisam@example.com');

SELECT * FROM customers_myisam;
ROLLBACK;

SELECT * FROM customers_myisam
WHERE customer_name = 'Rollback Test MyISAM';

-- Expected:
-- InnoDB record disappears after rollback.
-- MyISAM record remains because MyISAM is non-transactional.

-- =====================================================
-- 4. UPDATE TEST
-- =====================================================

UPDATE customers_innodb
SET email = 'updated_innodb@example.com'
WHERE customer_id = 1;

UPDATE customers_myisam
SET email = 'updated_myisam@example.com'
WHERE customer_id = 1;

UPDATE customers_memory
SET email = 'updated_memory@example.com'
WHERE customer_id = 1;

-- CSV may not support UPDATE properly depending on MySQL version
-- Try this:
UPDATE customers_csv
SET email = 'updated_csv@example.com'
WHERE customer_id = 1;

-- ARCHIVE usually does not support UPDATE
UPDATE customers_archive
SET email = 'updated_archive@example.com'
WHERE customer_id = 1;

-- View data
SELECT * FROM customers_innodb;
SELECT * FROM customers_myisam;
SELECT * FROM customers_memory;
SELECT * FROM customers_csv;
SELECT * FROM customers_archive;
-- =====================================================
-- 5. DELETE TEST
-- =====================================================

DELETE FROM customers_innodb WHERE customer_id = 2;
DELETE FROM customers_myisam WHERE customer_id = 2;
DELETE FROM customers_memory WHERE customer_id = 2;

-- CSV / ARCHIVE may give errors depending on version
DELETE FROM customers_csv WHERE customer_id = 2;
DELETE FROM customers_archive WHERE customer_id = 2;

-- =====================================================
-- 6. PERFORMANCE TEST TABLES
-- =====================================================

CREATE TABLE perf_innodb (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100),
    amount DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_amount (amount)
) ENGINE=InnoDB;

CREATE TABLE perf_myisam (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100),
    amount DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_amount (amount)
) ENGINE=MyISAM;

CREATE TABLE perf_memory (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100),
    amount DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_amount (amount)
) ENGINE=MEMORY;

CREATE TABLE perf_archive (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100),
    amount DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=ARCHIVE;


-- =====================================================
-- 7. INSERT PERFORMANCE TEST
-- Run each block separately and check execution time
-- in MySQL Workbench Action Output
-- =====================================================

INSERT INTO perf_innodb (customer_name, amount)
SELECT CONCAT('Customer ', n), RAND() * 100000
FROM (
    SELECT a.N + b.N * 10 + c.N * 100 + d.N * 1000 AS n
    FROM
    (SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
     UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a,
    (SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
     UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b,
    (SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
     UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) c,
    (SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
     UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) d
) numbers;

INSERT INTO perf_myisam (customer_name, amount)
SELECT customer_name, amount FROM perf_innodb;

INSERT INTO perf_memory (customer_name, amount)
SELECT customer_name, amount FROM perf_innodb;

INSERT INTO perf_archive (customer_name, amount)
SELECT customer_name, amount FROM perf_innodb;

-- =========================================
-- TABLE SIZE REPORT BY STORAGE ENGINE
-- =========================================
SELECT
    table_name,
    engine,
    table_rows,
    ROUND(data_length / 1024, 2) AS data_kb,
    ROUND(index_length / 1024, 2) AS index_kb,
    ROUND((data_length + index_length) / 1024, 2) AS total_kb,
    ROUND(data_free / 1024, 2) AS free_kb
FROM information_schema.tables
WHERE table_schema = 'storage_engine_lab'
ORDER BY total_kb DESC;

-- Count records
SELECT 'InnoDB' AS engine_name, COUNT(*) AS total_rows FROM perf_innodb
UNION ALL
SELECT 'MyISAM', COUNT(*) FROM perf_myisam
UNION ALL
SELECT 'MEMORY', COUNT(*) FROM perf_memory
UNION ALL
SELECT 'ARCHIVE', COUNT(*) FROM perf_archive;

-- =====================================================
-- 8. SELECT PERFORMANCE TEST
-- Run each SELECT separately and compare execution time
-- =====================================================

SELECT * FROM perf_innodb WHERE amount BETWEEN 10000 AND 20000;

SELECT * FROM perf_myisam WHERE amount BETWEEN 10000 AND 20000;

SELECT * FROM perf_memory WHERE amount BETWEEN 10000 AND 20000;

SELECT * FROM perf_archive WHERE amount BETWEEN 10000 AND 20000;

-- Enable Profiling (for MySQL Workbench / Session)

SET profiling = 1;
-- InnoDB
SELECT * FROM perf_innodb 
WHERE amount BETWEEN 10000 AND 50000;

-- MyISAM
SELECT * FROM perf_myisam 
WHERE amount BETWEEN 10000 AND 50000;

-- MEMORY
SELECT * FROM perf_memory 
WHERE amount BETWEEN 10000 AND 50000;

-- ARCHIVE
SELECT * FROM perf_archive 
WHERE amount BETWEEN 10000 AND 50000;

-- Get Execution Time (Milliseconds)
-- Show all query profiles
SHOW PROFILES;

-- Compare Multiple Engines
-- InnoDB Test
SET @start = NOW(6);
SELECT * FROM perf_innodb WHERE amount BETWEEN 10000 AND 50000;
SET @end = NOW(6);
SELECT 'InnoDB' AS engine,
TIMESTAMPDIFF(MICROSECOND, @start, @end)/1000 AS ms;

-- MyISAM Test
SET @start = NOW(6);
SELECT * FROM perf_myisam WHERE amount BETWEEN 10000 AND 50000;
SET @end = NOW(6);
SELECT 'MyISAM' AS engine,
TIMESTAMPDIFF(MICROSECOND, @start, @end)/1000 AS ms;

-- MEMORY Test
SET @start = NOW(6);
SELECT * FROM perf_memory WHERE amount BETWEEN 10000 AND 50000;
SET @end = NOW(6);
SELECT 'MEMORY' AS engine,
TIMESTAMPDIFF(MICROSECOND, @start, @end)/1000 AS ms;

-- ARCHIVE Test
SET @start = NOW(6);
SELECT * FROM perf_archive WHERE amount BETWEEN 10000 AND 50000;
SET @end = NOW(6);
SELECT 'ARCHIVE' AS engine,
TIMESTAMPDIFF(MICROSECOND, @start, @end)/1000 AS ms;
-- =====================================================
-- 9. INDEX USAGE TEST
-- =====================================================

EXPLAIN SELECT * FROM perf_innodb WHERE amount BETWEEN 10000 AND 20000;

EXPLAIN SELECT * FROM perf_myisam WHERE amount BETWEEN 10000 AND 20000;

EXPLAIN SELECT * FROM perf_memory WHERE amount BETWEEN 10000 AND 20000;

EXPLAIN SELECT * FROM perf_archive WHERE amount BETWEEN 10000 AND 20000;

-- =====================================================
-- 10. STORAGE SIZE CHECK
-- =====================================================

SELECT 
    table_name,
    engine,
    table_rows,
    ROUND(data_length / 1024 / 1024, 2) AS data_mb,
    ROUND(index_length / 1024 / 1024, 2) AS index_mb,
    ROUND((data_length + index_length) / 1024 / 1024, 2) AS total_mb
FROM information_schema.tables
WHERE table_schema = 'storage_engine_lab'
ORDER BY total_mb DESC;

-- Run once before testing (caching effect)
SELECT COUNT(*) FROM perf_innodb;

-- With index
SELECT * FROM perf_innodb WHERE amount > 25000;

-- Without index (force full scan)
SELECT * FROM perf_innodb IGNORE INDEX (idx_amount)
WHERE amount > 25000;

SET @start = NOW(6);
SELECT * FROM perf_innodb WHERE amount > 25000;
SET @end = NOW(6);
SELECT 'InnoDB' AS engine,
TIMESTAMPDIFF(MICROSECOND, @start, @end)/1000 AS ms;

SET @start = NOW(6);
SELECT * FROM perf_innodb IGNORE INDEX (idx_amount)
WHERE amount > 25000;
SET @end = NOW(6);
SELECT 'InnoDB' AS engine,
TIMESTAMPDIFF(MICROSECOND, @start, @end)/1000 AS ms;
-- Index using faster than without index
-- Indexes are best when the query returns a small number of rows.
-- For large result sets, a full table scan can be faster.

SET @start = NOW(6);
SELECT * FROM perf_innodb 
WHERE amount BETWEEN 25000 AND 25100;
SET @end = NOW(6);

SELECT 'InnoDB With Index' AS test_name,
TIMESTAMPDIFF(MICROSECOND, @start, @end)/1000 AS ms;

SET @start = NOW(6);
SELECT * FROM perf_innodb IGNORE INDEX (idx_amount)
WHERE amount BETWEEN 25000 AND 25100;
SET @end = NOW(6);

SELECT 'InnoDB Without Index' AS test_name,
TIMESTAMPDIFF(MICROSECOND, @start, @end)/1000 AS ms;