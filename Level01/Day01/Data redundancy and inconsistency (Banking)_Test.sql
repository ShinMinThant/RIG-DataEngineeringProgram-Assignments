-- Data redundancy and inconsistency (Banking)
-- Bad design tables to simulate separate files
-- Sample data population
-- Workflow problem script showing inconsistency
-- DBMS solution tables with centralized customer data
-- Workflow script showing single source of truth
-- Test case scripts for training/demo 
-- bad design
-- =========================================
-- BAD DESIGN: SEPARATE FILES
-- =========================================
CREATE DATABASE bad_bankingdb;
USE bad_bankingdb;
DROP TABLE IF EXISTS account_file;
DROP TABLE IF EXISTS loan_file;
DROP TABLE IF EXISTS credit_card_file;

CREATE TABLE account_file (
    account_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id VARCHAR(20) NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    address VARCHAR(255) NOT NULL,
    phone VARCHAR(30),
    account_type VARCHAR(50),
    balance DECIMAL(12,2)
);

CREATE TABLE loan_file (
    loan_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id VARCHAR(20) NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    address VARCHAR(255) NOT NULL,
    phone VARCHAR(30),
    loan_type VARCHAR(50),
    loan_amount DECIMAL(12,2),
    outstanding_amount DECIMAL(12,2)
);

CREATE TABLE credit_card_file (
    card_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id VARCHAR(20) NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    address VARCHAR(255) NOT NULL,
    phone VARCHAR(30),
    card_number VARCHAR(30),
    card_type VARCHAR(50),
    credit_limit DECIMAL(12,2)
);

-- =========================================
-- SAMPLE DATA: DUPLICATED CUSTOMER DATA
-- =========================================

INSERT INTO account_file
(customer_id, customer_name, address, phone, account_type, balance)
VALUES
('C001', 'Aung Aung', 'No.10, Pyay Road, Yangon', '09-111111111', 'Savings', 500000.00),
('C002', 'Su Su', 'No.22, Hledan Street, Yangon', '09-222222222', 'Current', 1200000.00),
('C003', 'Kyaw Kyaw', 'No.45, Mandalay Road, Mandalay', '09-333333333', 'Savings', 300000.00);

INSERT INTO loan_file
(customer_id, customer_name, address, phone, loan_type, loan_amount, outstanding_amount)
VALUES
('C001', 'Aung Aung', 'No.10, Pyay Road, Yangon', '09-111111111', 'Home Loan', 10000000.00, 7500000.00),
('C002', 'Su Su', 'No.22, Hledan Street, Yangon', '09-222222222', 'Car Loan', 5000000.00, 2000000.00);

INSERT INTO credit_card_file
(customer_id, customer_name, address, phone, card_number, card_type, credit_limit)
VALUES
('C001', 'Aung Aung', 'No.10, Pyay Road, Yangon', '09-111111111', '4111111111111111', 'Gold', 2000000.00),
('C003', 'Kyaw Kyaw', 'No.45, Mandalay Road, Mandalay', '09-333333333', '4222222222222222', 'Classic', 1000000.00);

-- Workflow Problem
-- Customer updates address only in the Account file.
-- Loan file and credit card file remain unchanged.
-- =========================================
-- WORKFLOW PROBLEM
-- Customer C001 changes address
-- Only account_file is updated
-- =========================================

SELECT * FROM account_file;

USE bad_bankingdb;

SET SQL_SAFE_UPDATES = 0;

UPDATE account_file
SET address = 'No.99, Inya Road, Yangon'
WHERE customer_id = 'C001';

-- Check inconsistency

SELECT 'ACCOUNT FILE' AS source, customer_id, customer_name, address
FROM account_file
WHERE customer_id = 'C001'
UNION ALL
SELECT 'LOAN FILE' AS source, customer_id, customer_name, address
FROM loan_file
WHERE customer_id = 'C001'
UNION ALL
SELECT 'CREDIT CARD FILE' AS source, customer_id, customer_name, address
FROM credit_card_file
WHERE customer_id = 'C001';

-- DBMS Solution: Centralized Database
-- redesign using normalization.
-- customers = single source of truth
-- accounts = account details only
-- loans = loan details only
-- credit_cards = credit card details only

CREATE DATABASE good_bankingdb;
USE good_bankingdb;
-- =========================================
-- GOOD DESIGN: CENTRALIZED DATABASE
-- =========================================

DROP TABLE IF EXISTS credit_cards;
DROP TABLE IF EXISTS loans;
DROP TABLE IF EXISTS accounts;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    address VARCHAR(255) NOT NULL,
    phone VARCHAR(30),
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE accounts (
    account_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id VARCHAR(20) NOT NULL,
    account_type VARCHAR(50) NOT NULL,
    balance DECIMAL(12,2) NOT NULL DEFAULT 0,
    opened_date DATE,
    CONSTRAINT fk_accounts_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE loans (
    loan_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id VARCHAR(20) NOT NULL,
    loan_type VARCHAR(50) NOT NULL,
    loan_amount DECIMAL(12,2) NOT NULL,
    outstanding_amount DECIMAL(12,2) NOT NULL,
    start_date DATE,
    CONSTRAINT fk_loans_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE credit_cards (
    card_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id VARCHAR(20) NOT NULL,
    card_number VARCHAR(30) NOT NULL UNIQUE,
    card_type VARCHAR(50),
    credit_limit DECIMAL(12,2),
    expiry_date DATE,
    CONSTRAINT fk_cards_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- =========================================
-- SAMPLE DATA: NORMALIZED DESIGN
-- =========================================

INSERT INTO customers
(customer_id, customer_name, address, phone, email)
VALUES
('C001', 'Aung Aung', 'No.10, Pyay Road, Yangon', '09-111111111', 'aung@example.com'),
('C002', 'Su Su', 'No.22, Hledan Street, Yangon', '09-222222222', 'susu@example.com'),
('C003', 'Kyaw Kyaw', 'No.45, Mandalay Road, Mandalay', '09-333333333', 'kyaw@example.com');

INSERT INTO accounts
(customer_id, account_type, balance, opened_date)
VALUES
('C001', 'Savings', 500000.00, '2024-01-10'),
('C002', 'Current', 1200000.00, '2024-02-15'),
('C003', 'Savings', 300000.00, '2024-03-01');

INSERT INTO loans
(customer_id, loan_type, loan_amount, outstanding_amount, start_date)
VALUES
('C001', 'Home Loan', 10000000.00, 7500000.00, '2024-04-01'),
('C002', 'Car Loan', 5000000.00, 2000000.00, '2024-05-10');

INSERT INTO credit_cards
(customer_id, card_number, card_type, credit_limit, expiry_date)
VALUES
('C001', '4111111111111111', 'Gold', 2000000.00, '2028-12-31'),
('C003', '4222222222222222', 'Classic', 1000000.00, '2027-11-30');

-- Workflow Script for DBMS Solution
-- =========================================
-- DBMS WORKFLOW
-- Update customer address in one place only
-- =========================================

UPDATE customers
SET address = 'No.99, Inya Road, Yangon'
WHERE customer_id = 'C001';

-- Check consistent result through joins
SELECT 
    c.customer_id,
    c.customer_name,
    c.address,
    a.account_type,
    a.balance,
    l.loan_type,
    l.outstanding_amount,
    cc.card_number,
    cc.card_type
FROM customers c
LEFT JOIN accounts a ON c.customer_id = a.customer_id
LEFT JOIN loans l ON c.customer_id = l.customer_id
LEFT JOIN credit_cards cc ON c.customer_id = cc.customer_id
WHERE c.customer_id = 'C001';

DROP VIEW IF EXISTS vw_customer_banking_profile;

-- View for Easy Demonstration
CREATE VIEW vw_customer_banking_profile AS
SELECT
    c.customer_id,
    c.customer_name,
    c.address,
    c.phone,
    a.account_id,
    a.account_type,
    a.balance,
    l.loan_id,
    l.loan_type,
    l.loan_amount,
    l.outstanding_amount,
    cc.card_id,
    cc.card_number,
    cc.card_type,
    cc.credit_limit
FROM customers c
LEFT JOIN accounts a ON c.customer_id = a.customer_id
LEFT JOIN loans l ON c.customer_id = l.customer_id
LEFT JOIN credit_cards cc ON c.customer_id = cc.customer_id;

SELECT * FROM vw_customer_banking_profile WHERE customer_id = 'C001';

-- Test Cases
-- Reset old data for C001

USE bad_bankingdb;

UPDATE account_file
SET address = 'No.10, Pyay Road, Yangon'
WHERE customer_id = 'C001';

UPDATE loan_file
SET address = 'No.10, Pyay Road, Yangon'
WHERE customer_id = 'C001';

UPDATE credit_card_file
SET address = 'No.10, Pyay Road, Yangon'
WHERE customer_id = 'C001';

-- Update only account file
UPDATE account_file
SET address = 'No.99, Inya Road, Yangon'
WHERE customer_id = 'C001';

-- Verify inconsistency
SELECT 'ACCOUNT FILE' AS source, address
FROM account_file
WHERE customer_id = 'C001'
UNION ALL
SELECT 'LOAN FILE' AS source, address
FROM loan_file
WHERE customer_id = 'C001'
UNION ALL
SELECT 'CREDIT CARD FILE' AS source, address
FROM credit_card_file
WHERE customer_id = 'C001';

-- Test Case 2: Consistency in DBMS design
USE good_bankingdb;
-- Reset centralized data
UPDATE customers
SET address = 'No.10, Pyay Road, Yangon'
WHERE customer_id = 'C001';

-- Update once
UPDATE customers
SET address = 'No.99, Inya Road, Yangon'
WHERE customer_id = 'C001';

-- Verify consistency
SELECT 
    c.customer_id,
    c.customer_name,
    c.address,
    a.account_type,
    l.loan_type,
    cc.card_type
FROM customers c
LEFT JOIN accounts a ON c.customer_id = a.customer_id
LEFT JOIN loans l ON c.customer_id = l.customer_id
LEFT JOIN credit_cards cc ON c.customer_id = cc.customer_id
WHERE c.customer_id = 'C001';


