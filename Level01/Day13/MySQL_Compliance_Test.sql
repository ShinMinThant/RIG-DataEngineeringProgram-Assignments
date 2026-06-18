/* =========================================================
   CORE BANKING COMPLIANCE DATABASE LAB
   =========================================================
   Objective:
   Create a simplified Compliance Database for Core Banking
   including:
   - Customers
   - Accounts
   - Transactions
   - KYC
   - AML Monitoring
   - Suspicious Activity Reports
   - Audit Logging

   Recommended Database:
   - MySQL 8.x
   - MSSQL (minor syntax modification)

   =========================================================
*/


/* =========================================================
   STEP 1 — CREATE DATABASE
   ========================================================= */

CREATE DATABASE corebank_compliance;

USE corebank_compliance;


/* =========================================================
   STEP 2 — CREATE CUSTOMERS TABLE
   =========================================================
   This table stores customer information for KYC and AML.
*/

CREATE TABLE customers (

    customer_id INT PRIMARY KEY AUTO_INCREMENT,

    full_name VARCHAR(100) NOT NULL,

    nrc_passport VARCHAR(50) UNIQUE,

    date_of_birth DATE,

    phone VARCHAR(30),

    email VARCHAR(100),

    address TEXT,

    risk_level VARCHAR(20)
        COMMENT 'LOW, MEDIUM, HIGH',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


/* =========================================================
   STEP 3 — CREATE ACCOUNTS TABLE
   =========================================================
   One customer can have multiple accounts.
*/

CREATE TABLE accounts (

    account_id INT PRIMARY KEY AUTO_INCREMENT,

    customer_id INT NOT NULL,

    account_number VARCHAR(30) UNIQUE,

    account_type VARCHAR(30),

    balance DECIMAL(18,2) DEFAULT 0,

    status VARCHAR(20)
        COMMENT 'ACTIVE, CLOSED, SUSPENDED',

    opened_date DATE,

    FOREIGN KEY (customer_id)
    REFERENCES customers(customer_id)
);


/* =========================================================
   STEP 4 — CREATE TRANSACTIONS TABLE
   =========================================================
   Stores banking transaction records.
*/

CREATE TABLE transactions (

    transaction_id INT PRIMARY KEY AUTO_INCREMENT,

    account_id INT NOT NULL,

    transaction_type VARCHAR(30)
        COMMENT 'DEPOSIT, WITHDRAW, TRANSFER',

    amount DECIMAL(18,2),

    transaction_date DATETIME,

    channel VARCHAR(30)
        COMMENT 'ATM, Mobile Banking, Branch, SWIFT',

    destination_country VARCHAR(50),

    remarks VARCHAR(255),

    FOREIGN KEY (account_id)
    REFERENCES accounts(account_id)
);


/* =========================================================
   STEP 5 — CREATE KYC VERIFICATION TABLE
   =========================================================
   Stores customer KYC verification records.
*/

CREATE TABLE kyc_verification (

    kyc_id INT PRIMARY KEY AUTO_INCREMENT,

    customer_id INT NOT NULL,

    document_type VARCHAR(50),

    document_number VARCHAR(100),

    verification_status VARCHAR(30)
        COMMENT 'PENDING, VERIFIED, REJECTED',

    verified_by VARCHAR(100),

    verification_date DATE,

    FOREIGN KEY (customer_id)
    REFERENCES customers(customer_id)
);


/* =========================================================
   STEP 6 — CREATE AML MONITORING TABLE
   =========================================================
   Stores AML screening and monitoring results.
*/

CREATE TABLE aml_monitoring (

    aml_id INT PRIMARY KEY AUTO_INCREMENT,

    transaction_id INT NOT NULL,

    aml_rule VARCHAR(255),

    risk_score INT,

    flagged_status VARCHAR(30)
        COMMENT 'FLAGGED, REVIEWED, APPROVED',

    reviewed_by VARCHAR(100),

    review_date DATE,

    FOREIGN KEY (transaction_id)
    REFERENCES transactions(transaction_id)
);


/* =========================================================
   STEP 7 — CREATE SUSPICIOUS ACTIVITY REPORT TABLE
   =========================================================
   Stores suspicious transaction reports.
*/

CREATE TABLE suspicious_activity_reports (

    sar_id INT PRIMARY KEY AUTO_INCREMENT,

    transaction_id INT NOT NULL,

    suspicious_reason TEXT,

    reported_to_authority VARCHAR(100),

    report_status VARCHAR(30),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (transaction_id)
    REFERENCES transactions(transaction_id)
);


/* =========================================================
   STEP 8 — CREATE AUDIT LOG TABLE
   =========================================================
   Stores audit logs for compliance tracking.
*/

CREATE TABLE audit_logs (

    log_id INT PRIMARY KEY AUTO_INCREMENT,

    username VARCHAR(100),

    action_type VARCHAR(50),

    table_name VARCHAR(100),

    action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    old_value TEXT,

    new_value TEXT
);


/* =========================================================
   STEP 9 — INSERT SAMPLE CUSTOMER DATA
   ========================================================= */

INSERT INTO customers
(
    full_name,
    nrc_passport,
    date_of_birth,
    phone,
    email,
    address,
    risk_level
)
VALUES

(
    'Aung Aung',
    '12/PaKaTa(N)123456',
    '1990-05-10',
    '091111111',
    'aung@gmail.com',
    'Yangon',
    'LOW'
),

(
    'Su Su',
    '12/YaKaNa(N)654321',
    '1988-08-22',
    '092222222',
    'susu@gmail.com',
    'Mandalay',
    'HIGH'
),

(
    'Kyaw Kyaw',
    '13/LaKaNa(N)998877',
    '1995-03-15',
    '093333333',
    'kyaw@gmail.com',
    'Naypyitaw',
    'MEDIUM'
);


/* =========================================================
   STEP 10 — INSERT ACCOUNT DATA
   ========================================================= */

INSERT INTO accounts
(
    customer_id,
    account_number,
    account_type,
    balance,
    status,
    opened_date
)
VALUES

(
    1,
    'MM000111222',
    'Saving',
    10000000,
    'ACTIVE',
    '2025-01-01'
),

(
    2,
    'MM000333444',
    'Current',
    500000000,
    'ACTIVE',
    '2025-01-05'
),

(
    3,
    'MM000555666',
    'Saving',
    3000000,
    'ACTIVE',
    '2025-02-01'
);


/* =========================================================
   STEP 11 — INSERT TRANSACTION DATA
   ========================================================= */

INSERT INTO transactions
(
    account_id,
    transaction_type,
    amount,
    transaction_date,
    channel,
    destination_country,
    remarks
)
VALUES

(
    1,
    'TRANSFER',
    500000,
    NOW(),
    'Mobile Banking',
    'Myanmar',
    'Local transfer'
),

(
    2,
    'TRANSFER',
    200000000,
    NOW(),
    'SWIFT',
    'Dubai',
    'International transfer'
),

(
    3,
    'DEPOSIT',
    100000,
    NOW(),
    'ATM',
    'Myanmar',
    'Cash deposit'
);


/* =========================================================
   STEP 12 — INSERT KYC RECORDS
   ========================================================= */

INSERT INTO kyc_verification
(
    customer_id,
    document_type,
    document_number,
    verification_status,
    verified_by,
    verification_date
)
VALUES

(
    1,
    'NRC',
    '12/PaKaTa(N)123456',
    'VERIFIED',
    'Compliance Officer',
    CURDATE()
),

(
    2,
    'Passport',
    'MM998877',
    'VERIFIED',
    'Compliance Officer',
    CURDATE()
),

(
    3,
    'NRC',
    '13/LaKaNa(N)998877',
    'PENDING',
    'Junior Officer',
    CURDATE()
);


/* =========================================================
   STEP 13 — AML DETECTION QUERY
   =========================================================
   Detect large transactions above 100 million.
*/

SELECT
    t.transaction_id,
    c.full_name,
    a.account_number,
    t.amount,
    t.destination_country

FROM transactions t

JOIN accounts a
ON t.account_id = a.account_id

JOIN customers c
ON a.customer_id = c.customer_id

WHERE t.amount > 100000000;


/* =========================================================
   STEP 14 — DETECT HIGH RISK CUSTOMERS
   ========================================================= */

SELECT *
FROM customers
WHERE risk_level = 'HIGH';


/* =========================================================
   STEP 15 — DETECT FOREIGN TRANSFERS
   ========================================================= */

SELECT *
FROM transactions
WHERE destination_country <> 'Myanmar';


/* =========================================================
   STEP 16 — INSERT AML MONITORING RESULT
   ========================================================= */

INSERT INTO aml_monitoring
(
    transaction_id,
    aml_rule,
    risk_score,
    flagged_status,
    reviewed_by,
    review_date
)
VALUES

(
    2,
    'Large International Transfer',
    95,
    'FLAGGED',
    'Senior Compliance Officer',
    CURDATE()
);


/* =========================================================
   STEP 17 — INSERT SUSPICIOUS ACTIVITY REPORT
   ========================================================= */

INSERT INTO suspicious_activity_reports
(
    transaction_id,
    suspicious_reason,
    reported_to_authority,
    report_status
)
VALUES

(
    2,
    'Large overseas transfer from high-risk customer',
    'Central Bank',
    'SUBMITTED'
);


/* =========================================================
   STEP 18 — CREATE AUDIT TRIGGER
   =========================================================
   Track account balance changes.
*/

DELIMITER $$

CREATE TRIGGER trg_account_balance_update

AFTER UPDATE
ON accounts

FOR EACH ROW

BEGIN

    INSERT INTO audit_logs
    (
        username,
        action_type,
        table_name,
        old_value,
        new_value
    )

    VALUES
    (
        CURRENT_USER(),
        'UPDATE',
        'accounts',

        CONCAT('Old Balance: ', OLD.balance),

        CONCAT('New Balance: ', NEW.balance)
    );

END$$

DELIMITER ;


/* =========================================================
   STEP 19 — TEST AUDIT TRIGGER
   ========================================================= */

UPDATE accounts
SET balance = 12000000
WHERE account_id = 1;


/* =========================================================
   STEP 20 — VIEW AUDIT LOGS
   ========================================================= */

SELECT *
FROM audit_logs;


/* =========================================================
   STEP 21 — DAILY AML REPORT
   ========================================================= */

SELECT

    c.full_name,

    a.account_number,

    t.amount,

    t.destination_country,

    am.risk_score,

    am.flagged_status

FROM aml_monitoring am

JOIN transactions t
ON am.transaction_id = t.transaction_id

JOIN accounts a
ON t.account_id = a.account_id

JOIN customers c
ON a.customer_id = c.customer_id;


/* =========================================================
   STEP 22 — CREATE COMPLIANCE VIEW
   =========================================================
   Simplified suspicious customer monitoring view.
*/

CREATE OR REPLACE VIEW vw_suspicious_customers AS

SELECT

    c.customer_id,

    c.full_name,

    c.risk_level,

    t.amount,

    t.destination_country,

    am.flagged_status

FROM customers c

JOIN accounts a
ON c.customer_id = a.customer_id

JOIN transactions t
ON a.account_id = t.account_id

JOIN aml_monitoring am
ON t.transaction_id = am.transaction_id

WHERE am.flagged_status = 'FLAGGED';


/* =========================================================
   STEP 23 — QUERY THE VIEW
   ========================================================= */

SELECT *
FROM vw_suspicious_customers;


/* =========================================================
   STEP 24 — STORED PROCEDURE FOR AML SCAN
   =========================================================
   Automatically detect high-value transactions.
*/

DELIMITER $$

CREATE PROCEDURE sp_detect_large_transactions()

BEGIN

    SELECT

        c.full_name,

        a.account_number,

        t.amount,

        t.destination_country

    FROM transactions t

    JOIN accounts a
    ON t.account_id = a.account_id

    JOIN customers c
    ON a.customer_id = c.customer_id

    WHERE t.amount >= 100000000;

END$$

DELIMITER ;


/* =========================================================
   STEP 25 — EXECUTE AML PROCEDURE
   ========================================================= */

CALL sp_detect_large_transactions();


/* =========================================================
   STEP 26 — COMPLIANCE DASHBOARD QUERIES
   ========================================================= */

/* Total Customers */

SELECT COUNT(*) AS total_customers
FROM customers;


/* Total Accounts */

SELECT COUNT(*) AS total_accounts
FROM accounts;


/* Total Transactions */

SELECT COUNT(*) AS total_transactions
FROM transactions;


/* Total AML Flags */

SELECT COUNT(*) AS total_flagged_transactions
FROM aml_monitoring
WHERE flagged_status = 'FLAGGED';


/* Total Suspicious Reports */

SELECT COUNT(*) AS total_sar_reports
FROM suspicious_activity_reports;


/* =========================================================
   STEP 27 — OPTIONAL SECURITY ROLE EXAMPLE
   ========================================================= */

/*
CREATE USER 'compliance_user'@'localhost'
IDENTIFIED BY 'StrongPassword123!';

GRANT SELECT, INSERT, UPDATE
ON corebank_compliance.*
TO 'compliance_user'@'localhost';

FLUSH PRIVILEGES;
*/


/* =========================================================
   STEP 28 — CLEANUP (OPTIONAL)
   ========================================================= */

/*
DROP DATABASE corebank_compliance;
*/


/* =========================================================
   END OF CORE BANKING COMPLIANCE LAB
   ========================================================= */