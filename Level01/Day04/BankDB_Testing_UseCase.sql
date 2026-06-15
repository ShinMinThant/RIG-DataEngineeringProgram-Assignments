💾 Full SQL Script: BankDB Testing Use Case
-- 1. Create Schema
CREATE DATABASE IF NOT EXISTS BankDB;
USE BankDB;

-- 2. Create Customer Table
CREATE TABLE Customer (
    CustomerID INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE
);

-- 3. Create Account Table
CREATE TABLE Account (
    AccountID INT PRIMARY KEY,
    CustomerID INT NOT NULL,
    AccountType VARCHAR(30) NOT NULL,
    Balance DECIMAL(12, 2) DEFAULT 0.00,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

-- 4. Create Transaction Table
CREATE TABLE TransactionHistory (
    TransactionID INT PRIMARY KEY,
    AccountID INT NOT NULL,
    Amount DECIMAL(10,2),
    TransactionDate DATE,
    FOREIGN KEY (AccountID) REFERENCES Account(AccountID)
);

-- 5. Check Schema Exists
SELECT SCHEMA_NAME
FROM INFORMATION_SCHEMA.SCHEMATA
WHERE SCHEMA_NAME = 'BankDB';

-- 6. Check Tables Exist
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'BankDB';

-- 7. Check Column Structure of Customer
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_KEY
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Customer'
AND TABLE_SCHEMA = 'BankDB';

-- 8. Check Primary Keys
SELECT t.CONSTRAINT_NAME, k.COLUMN_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS t
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE k
ON t.CONSTRAINT_NAME = k.CONSTRAINT_NAME
WHERE t.CONSTRAINT_TYPE = 'PRIMARY KEY'
AND t.TABLE_SCHEMA = 'BankDB';

-- 9. Check Foreign Keys
SELECT TABLE_NAME, COLUMN_NAME, CONSTRAINT_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'BankDB' AND REFERENCED_TABLE_NAME IS NOT NULL;

-- 10. Check Indexes on Customer
SHOW INDEX FROM Customer;

-- 11. Insert Test Data into Customer
INSERT INTO Customer (CustomerID, FirstName, LastName, Email)
VALUES 
(1, 'Alice', 'Wong', 'alice.wong@bank.com'),
(2, 'Bob', 'Smith', 'bob.smith@bank.com');

-- 12. Insert Duplicate Email to Trigger Constraint Violation
-- This should fail
INSERT INTO Customer (CustomerID, FirstName, LastName, Email)
VALUES (3, 'Charlie', 'Brown', 'alice.wong@bank.com');

-- 13. Insert Data into Account
INSERT INTO Account (AccountID, CustomerID, AccountType, Balance)
VALUES 
(101, 1, 'Savings', 5000.00),
(102, 2, 'Checking', 1200.50);

-- 14. Insert Data into TransactionHistory
INSERT INTO TransactionHistory (TransactionID, AccountID, Amount, TransactionDate)
VALUES 
(1001, 101, 150.00, '2025-04-01'),
(1002, 101, -50.00, '2025-04-03');

-- 15. Test Foreign Key Violation (Invalid CustomerID)
-- This should fail
INSERT INTO Account (AccountID, CustomerID, AccountType, Balance)
VALUES (103, 999, 'Fixed Deposit', 2000.00);
