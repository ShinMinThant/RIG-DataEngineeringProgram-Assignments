-- =====================================================
-- MYSQL DATA TYPES LAB
-- Covers: Character, Binary, Text, Blob, Numeric,
--         Date/Time, ENUM, SET
-- =====================================================

-- =====================================================
-- 1. CREATE DATABASE
-- =====================================================
DROP DATABASE IF EXISTS datatype_lab;
CREATE DATABASE datatype_lab;
USE datatype_lab;

-- =====================================================
-- 2. CHARACTER & BINARY DATA TYPES
-- CHAR, VARCHAR, BINARY, VARBINARY
-- =====================================================
CREATE TABLE char_types (
    id INT AUTO_INCREMENT PRIMARY KEY,
    
    -- Fixed-length string (always uses full size)
    fixed_char CHAR(10),
    
    -- Variable-length string (saves space)
    variable_char VARCHAR(100),
    
    -- Fixed-length binary data
    fixed_binary BINARY(5),
    
    -- Variable-length binary data
    variable_binary VARBINARY(50)
);

-- Insert sample data
INSERT INTO char_types (fixed_char, variable_char, fixed_binary, variable_binary)
VALUES
('ABC', 'Hello World', '12345', 'BinaryData1'),
('XYZ', 'MySQL Test', '54321', 'BinaryData2');

-- View data
SELECT * FROM char_types;

-- =====================================================
-- 3. TEXT & BLOB DATA TYPES
-- TINYTEXT, TEXT, MEDIUMTEXT, LONGTEXT
-- TINYBLOB, BLOB, MEDIUMBLOB, LONGBLOB
-- =====================================================
CREATE TABLE text_blob_types (
    id INT AUTO_INCREMENT PRIMARY KEY,
    
    -- Text types (store large text)
    tiny_text TINYTEXT,
    text_data TEXT,
    medium_text MEDIUMTEXT,
    long_text LONGTEXT,
    
    -- Binary large objects (images, files, etc.)
    tiny_blob TINYBLOB,
    blob_data BLOB,
    medium_blob MEDIUMBLOB,
    long_blob LONGBLOB
);

-- Insert sample data
INSERT INTO text_blob_types 
(tiny_text, text_data, medium_text, long_text, tiny_blob, blob_data)
VALUES
('Short text', 'This is normal text', 'Medium text example', 'Long text example',
 'abc', 'binarydata');

-- View selected columns
SELECT id, tiny_text, text_data FROM text_blob_types;

-- =====================================================
-- 4. NUMERIC DATA TYPES
-- BIT, TINYINT, BOOLEAN, SMALLINT, MEDIUMINT, INT, BIGINT
-- FLOAT, DOUBLE, DECIMAL
-- =====================================================
CREATE TABLE numeric_types (
    id INT AUTO_INCREMENT PRIMARY KEY,
    
    -- Bit value (binary representation)
    bit_val BIT(4),
    
    -- Integer types
    tiny_val TINYINT,
    bool_val BOOLEAN,
    small_val SMALLINT,
    medium_val MEDIUMINT,
    int_val INT,
    big_val BIGINT,
    
    -- Floating point (approximate values)
    float_val FLOAT(10,2),
    double_val DOUBLE(10,2),
    
    -- Exact numeric (financial data)
    decimal_val DECIMAL(10,2)
);

-- Insert sample data
INSERT INTO numeric_types
(bit_val, tiny_val, bool_val, small_val, medium_val, int_val, big_val, float_val, double_val, decimal_val)
VALUES
(b'1010', 10, TRUE, 100, 1000, 10000, 1000000, 10.55, 20.12, 999.99),
(b'0101', 5, FALSE, 200, 2000, 20000, 2000000, 15.75, 30.56, 888.88);

-- View data
SELECT * FROM numeric_types;

-- =====================================================
-- 5. DATE & TIME DATA TYPES
-- DATE, DATETIME, TIMESTAMP, TIME, YEAR
-- =====================================================
CREATE TABLE datetime_types (
    id INT AUTO_INCREMENT PRIMARY KEY,
    
    -- Date only
    date_val DATE,
    
    -- Date and time
    datetime_val DATETIME,
    
    -- Auto timestamp (updated automatically)
    timestamp_val TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Time only
    time_val TIME,
    
    -- Year
    year_val YEAR
);

-- Insert sample data
INSERT INTO datetime_types (date_val, datetime_val, time_val, year_val)
VALUES
('2025-01-01', '2025-01-01 10:30:00', '10:30:00', 2025),
('2026-06-15', '2026-06-15 15:45:00', '15:45:00', 2026);

-- View data
SELECT * FROM datetime_types;

-- =====================================================
-- 6. ENUM & SET DATA TYPES
-- ENUM = single choice
-- SET = multiple choices
-- =====================================================
CREATE TABLE enum_set_types (
    id INT AUTO_INCREMENT PRIMARY KEY,
    
    -- ENUM allows only one value
    status ENUM('Pending', 'Approved', 'Rejected'),
    
    -- SET allows multiple values
    permissions SET('Read', 'Write', 'Execute')
);

-- Insert sample data
INSERT INTO enum_set_types (status, permissions)
VALUES
('Pending', 'Read'),
('Approved', 'Read,Write'),
('Rejected', 'Read,Execute');

-- View data
SELECT * FROM enum_set_types;

-- =====================================================
-- 7. PRACTICAL SELECT QUERIES
-- Demonstrates filtering and searching
-- =====================================================

-- Numeric filter
SELECT * FROM numeric_types 
WHERE int_val > 10000;

-- Text search
SELECT * FROM text_blob_types 
WHERE text_data LIKE '%text%';

-- Date filter
SELECT * FROM datetime_types 
WHERE year_val = 2025;

-- ENUM filter
SELECT * FROM enum_set_types 
WHERE status = 'Approved';

-- =====================================================
-- 8. CLEANUP (OPTIONAL)
-- =====================================================
-- DROP DATABASE datatype_lab;