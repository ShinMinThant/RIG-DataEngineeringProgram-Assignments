/* CORE BANKING COMPLIANCE DATABASE LAB - MSSQL */

CREATE DATABASE corebank_compliance;
GO

USE corebank_compliance;
GO

/* 1. CUSTOMERS */
CREATE TABLE customers (
    customer_id INT IDENTITY(1,1) PRIMARY KEY,
    full_name NVARCHAR(100) NOT NULL,
    nrc_passport NVARCHAR(50) UNIQUE,
    date_of_birth DATE,
    phone NVARCHAR(30),
    email NVARCHAR(100),
    address NVARCHAR(MAX),
    risk_level NVARCHAR(20),
    created_at DATETIME DEFAULT GETDATE()
);
GO

/* 2. ACCOUNTS */
CREATE TABLE accounts (
    account_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT NOT NULL,
    account_number NVARCHAR(30) UNIQUE,
    account_type NVARCHAR(30),
    balance DECIMAL(18,2) DEFAULT 0,
    status NVARCHAR(20),
    opened_date DATE,
    CONSTRAINT fk_accounts_customers
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
GO

/* 3. TRANSACTIONS */
CREATE TABLE bank_transactions (
    transaction_id INT IDENTITY(1,1) PRIMARY KEY,
    account_id INT NOT NULL,
    transaction_type NVARCHAR(30),
    amount DECIMAL(18,2),
    transaction_date DATETIME DEFAULT GETDATE(),
    channel NVARCHAR(30),
    destination_country NVARCHAR(50),
    remarks NVARCHAR(255),
    CONSTRAINT fk_transactions_accounts
        FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);
GO

/* 4. KYC VERIFICATION */
CREATE TABLE kyc_verification (
    kyc_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT NOT NULL,
    document_type NVARCHAR(50),
    document_number NVARCHAR(100),
    verification_status NVARCHAR(30),
    verified_by NVARCHAR(100),
    verification_date DATE,
    CONSTRAINT fk_kyc_customers
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
GO

/* 5. AML MONITORING */
CREATE TABLE aml_monitoring (
    aml_id INT IDENTITY(1,1) PRIMARY KEY,
    transaction_id INT NOT NULL,
    aml_rule NVARCHAR(255),
    risk_score INT,
    flagged_status NVARCHAR(30),
    reviewed_by NVARCHAR(100),
    review_date DATE,
    CONSTRAINT fk_aml_transactions
        FOREIGN KEY (transaction_id) REFERENCES bank_transactions(transaction_id)
);
GO

/* 6. SUSPICIOUS ACTIVITY REPORTS */
CREATE TABLE suspicious_activity_reports (
    sar_id INT IDENTITY(1,1) PRIMARY KEY,
    transaction_id INT NOT NULL,
    suspicious_reason NVARCHAR(MAX),
    reported_to_authority NVARCHAR(100),
    report_status NVARCHAR(30),
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT fk_sar_transactions
        FOREIGN KEY (transaction_id) REFERENCES bank_transactions(transaction_id)
);
GO

/* 7. AUDIT LOGS */
CREATE TABLE audit_logs (
    log_id INT IDENTITY(1,1) PRIMARY KEY,
    username NVARCHAR(100),
    action_type NVARCHAR(50),
    table_name NVARCHAR(100),
    action_time DATETIME DEFAULT GETDATE(),
    old_value NVARCHAR(MAX),
    new_value NVARCHAR(MAX)
);
GO

/* 8. INSERT CUSTOMERS */
INSERT INTO customers
(full_name, nrc_passport, date_of_birth, phone, email, address, risk_level)
VALUES
('Aung Aung', '12/PaKaTa(N)123456', '1990-05-10', '091111111', 'aung@gmail.com', 'Yangon', 'LOW'),
('Su Su', '12/YaKaNa(N)654321', '1988-08-22', '092222222', 'susu@gmail.com', 'Mandalay', 'HIGH'),
('Kyaw Kyaw', '13/LaKaNa(N)998877', '1995-03-15', '093333333', 'kyaw@gmail.com', 'Naypyitaw', 'MEDIUM');
GO


/* 9. INSERT ACCOUNTS */
INSERT INTO accounts
(customer_id, account_number, account_type, balance, status, opened_date)
VALUES
(1, 'MM000111222', 'Saving', 10000000, 'ACTIVE', '2025-01-01'),
(2, 'MM000333444', 'Current', 500000000, 'ACTIVE', '2025-01-05'),
(3, 'MM000555666', 'Saving', 3000000, 'ACTIVE', '2025-02-01');
GO

/* 10. INSERT TRANSACTIONS */
INSERT INTO bank_transactions
(account_id, transaction_type, amount, transaction_date, channel, destination_country, remarks)
VALUES
(1, 'TRANSFER', 500000, GETDATE(), 'Mobile Banking', 'Myanmar', 'Local transfer'),
(2, 'TRANSFER', 200000000, GETDATE(), 'SWIFT', 'Dubai', 'International transfer'),
(3, 'DEPOSIT', 100000, GETDATE(), 'ATM', 'Myanmar', 'Cash deposit');
GO

/* 11. INSERT KYC RECORDS */
INSERT INTO kyc_verification
(customer_id, document_type, document_number, verification_status, verified_by, verification_date)
VALUES
(1, 'NRC', '12/PaKaTa(N)123456', 'VERIFIED', 'Compliance Officer', CAST(GETDATE() AS DATE)),
(2, 'Passport', 'MM998877', 'VERIFIED', 'Compliance Officer', CAST(GETDATE() AS DATE)),
(3, 'NRC', '13/LaKaNa(N)998877', 'PENDING', 'Junior Officer', CAST(GETDATE() AS DATE));
GO

/* 12. AML DETECTION QUERY: LARGE TRANSACTIONS */
SELECT
    t.transaction_id,
    c.full_name,
    a.account_number,
    t.amount,
    t.destination_country
FROM bank_transactions t
JOIN accounts a ON t.account_id = a.account_id
JOIN customers c ON a.customer_id = c.customer_id
WHERE t.amount > 100000000;
GO

/* 13. DETECT HIGH RISK CUSTOMERS */
SELECT *
FROM customers
WHERE risk_level = 'HIGH';
GO

/* 14. DETECT FOREIGN TRANSFERS */
SELECT *
FROM bank_transactions
WHERE destination_country <> 'Myanmar';
GO

/* 15. INSERT AML MONITORING RESULT */
INSERT INTO aml_monitoring
(transaction_id, aml_rule, risk_score, flagged_status, reviewed_by, review_date)
VALUES
(2, 'Large International Transfer', 95, 'FLAGGED', 'Senior Compliance Officer', CAST(GETDATE() AS DATE));
GO

/* 16. INSERT SUSPICIOUS ACTIVITY REPORT */
INSERT INTO suspicious_activity_reports
(transaction_id, suspicious_reason, reported_to_authority, report_status)
VALUES
(2, 'Large overseas transfer from high-risk customer', 'Central Bank', 'SUBMITTED');
GO

/* 17. CREATE AUDIT TRIGGER */
CREATE TRIGGER trg_account_balance_update
ON accounts
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO audit_logs
    (
        username,
        action_type,
        table_name,
        old_value,
        new_value
    )
    SELECT
        SUSER_SNAME(),
        'UPDATE',
        'accounts',
        CONCAT('Old Balance: ', d.balance),
        CONCAT('New Balance: ', i.balance)
    FROM inserted i
    JOIN deleted d ON i.account_id = d.account_id;
END;
GO

/* 18. TEST AUDIT TRIGGER */
UPDATE accounts
SET balance = 12000000
WHERE account_id = 1;
GO

/* 19. VIEW AUDIT LOGS */
SELECT *
FROM audit_logs;
GO



/* 20. DAILY AML REPORT */
SELECT
    c.full_name,
    a.account_number,
    t.amount,
    t.destination_country,
    am.risk_score,
    am.flagged_status
FROM aml_monitoring am
JOIN bank_transactions t ON am.transaction_id = t.transaction_id
JOIN accounts a ON t.account_id = a.account_id
JOIN customers c ON a.customer_id = c.customer_id;
GO

/* 21. CREATE COMPLIANCE VIEW */
CREATE VIEW vw_suspicious_customers AS
SELECT
    c.customer_id,
    c.full_name,
    c.risk_level,
    t.amount,
    t.destination_country,
    am.flagged_status
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
JOIN bank_transactions t ON a.account_id = t.account_id
JOIN aml_monitoring am ON t.transaction_id = am.transaction_id
WHERE am.flagged_status = 'FLAGGED';
GO

/* 22. QUERY VIEW */
SELECT *
FROM vw_suspicious_customers;
GO

/* 23. STORED PROCEDURE FOR AML SCAN */
CREATE PROCEDURE sp_detect_large_transactions
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.full_name,
        a.account_number,
        t.amount,
        t.destination_country
    FROM bank_transactions t
    JOIN accounts a ON t.account_id = a.account_id
    JOIN customers c ON a.customer_id = c.customer_id
    WHERE t.amount >= 100000000;
END;
GO

/* 24. EXECUTE PROCEDURE */
EXEC sp_detect_large_transactions;
GO

/* 25. DASHBOARD QUERIES */
SELECT COUNT(*) AS total_customers
FROM customers;

SELECT COUNT(*) AS total_accounts
FROM accounts;

SELECT COUNT(*) AS total_transactions
FROM bank_transactions;

SELECT COUNT(*) AS total_flagged_transactions
FROM aml_monitoring
WHERE flagged_status = 'FLAGGED';

SELECT COUNT(*) AS total_sar_reports
FROM suspicious_activity_reports;
GO

/* =========================================================
   ADD MORE SAMPLE DATA FOR CORE BANKING COMPLIANCE DATABASE
   MSSQL VERSION
   ========================================================= */

USE corebank_compliance;
GO

/* =========================================================
   1. ADD MORE CUSTOMERS
   ========================================================= */

INSERT INTO customers
(full_name, nrc_passport, date_of_birth, phone, email, address, risk_level)
VALUES
('Mya Mya', '12/LaMaNa(N)111222', '1992-01-12', '094444444', 'mya@gmail.com', 'Yangon', 'LOW'),
('Hla Hla', '9/MaHaMa(N)333444', '1985-04-20', '095555555', 'hla@gmail.com', 'Mandalay', 'MEDIUM'),
('Tun Tun', '8/PaKhaKa(N)555666', '1978-11-05', '096666666', 'tun@gmail.com', 'Magway', 'HIGH'),
('Nilar Win', '14/PaThaNa(N)777888', '1996-07-18', '097777777', 'nilar@gmail.com', 'Pathein', 'LOW'),
('Zaw Zaw', '7/PaMaNa(N)999000', '1989-09-25', '098888888', 'zaw@gmail.com', 'Bago', 'MEDIUM'),
('Ei Ei', '10/MaLaMa(N)123789', '1993-12-01', '099999999', 'eiei@gmail.com', 'Mawlamyine', 'LOW'),
('Ko Ko', '5/KaLaNa(N)456123', '1982-06-14', '091010101', 'koko@gmail.com', 'Sagaing', 'HIGH'),
('Thandar', '6/HaThaTa(N)789456', '1997-02-28', '092020202', 'thandar@gmail.com', 'Dawei', 'MEDIUM'),
('Moe Moe', '1/MaKaNa(N)654987', '1991-10-10', '093030303', 'moe@gmail.com', 'Myitkyina', 'LOW'),
('Aye Chan', '3/BaAn(N)321654', '1987-03-30', '094040404', 'ayechan@gmail.com', 'Hpa-An', 'HIGH');
GO

/* =========================================================
   2. ADD MORE ACCOUNTS
   customer_id 4 to 13 are newly inserted customers
   ========================================================= */

INSERT INTO accounts
(customer_id, account_number, account_type, balance, status, opened_date)
VALUES
(4, 'MM000777001', 'Saving', 2500000, 'ACTIVE', '2025-03-01'),
(5, 'MM000777002', 'Current', 15000000, 'ACTIVE', '2025-03-02'),
(6, 'MM000777003', 'Saving', 800000000, 'ACTIVE', '2025-03-03'),
(7, 'MM000777004', 'Saving', 1200000, 'ACTIVE', '2025-03-04'),
(8, 'MM000777005', 'Current', 30000000, 'ACTIVE', '2025-03-05'),
(9, 'MM000777006', 'Saving', 900000, 'ACTIVE', '2025-03-06'),
(10, 'MM000777007', 'Current', 650000000, 'ACTIVE', '2025-03-07'),
(11, 'MM000777008', 'Saving', 5000000, 'ACTIVE', '2025-03-08'),
(12, 'MM000777009', 'Saving', 700000, 'DORMANT', '2023-01-01'),
(13, 'MM000777010', 'Current', 1000000000, 'ACTIVE', '2025-03-10');
GO

/* =========================================================
   3. ADD MORE TRANSACTIONS
   Includes normal, high-value, foreign, and suspicious patterns
   ========================================================= */

INSERT INTO bank_transactions
(account_id, transaction_type, amount, transaction_date, channel, destination_country, remarks)
VALUES
(4, 'TRANSFER', 300000, GETDATE(), 'Mobile Banking', 'Myanmar', 'Normal local transfer'),
(5, 'WITHDRAW', 2000000, GETDATE(), 'ATM', 'Myanmar', 'Cash withdrawal'),
(6, 'TRANSFER', 250000000, GETDATE(), 'SWIFT', 'Singapore', 'Large foreign transfer'),
(7, 'DEPOSIT', 1000000, GETDATE(), 'Branch', 'Myanmar', 'Cash deposit'),
(8, 'TRANSFER', 85000000, GETDATE(), 'Mobile Banking', 'Thailand', 'Foreign transfer'),
(9, 'TRANSFER', 200000, GETDATE(), 'Mobile Banking', 'Myanmar', 'Small transfer'),
(10, 'TRANSFER', 500000000, GETDATE(), 'SWIFT', 'Dubai', 'Very large international transfer'),
(11, 'WITHDRAW', 700000, GETDATE(), 'ATM', 'Myanmar', 'ATM withdrawal'),
(12, 'TRANSFER', 150000000, GETDATE(), 'Mobile Banking', 'Myanmar', 'Dormant account sudden large transfer'),
(13, 'TRANSFER', 300000000, GETDATE(), 'SWIFT', 'Malaysia', 'High-risk foreign transfer');
GO

/* =========================================================
   4. ADD MORE KYC DATA
   ========================================================= */

INSERT INTO kyc_verification
(customer_id, document_type, document_number, verification_status, verified_by, verification_date)
VALUES
(4, 'NRC', '12/LaMaNa(N)111222', 'VERIFIED', 'Compliance Officer', CAST(GETDATE() AS DATE)),
(5, 'NRC', '9/MaHaMa(N)333444', 'VERIFIED', 'Compliance Officer', CAST(GETDATE() AS DATE)),
(6, 'NRC', '8/PaKhaKa(N)555666', 'VERIFIED', 'Senior Officer', CAST(GETDATE() AS DATE)),
(7, 'NRC', '14/PaThaNa(N)777888', 'PENDING', 'Junior Officer', CAST(GETDATE() AS DATE)),
(8, 'NRC', '7/PaMaNa(N)999000', 'VERIFIED', 'Compliance Officer', CAST(GETDATE() AS DATE)),
(9, 'NRC', '10/MaLaMa(N)123789', 'PENDING', 'Junior Officer', CAST(GETDATE() AS DATE)),
(10, 'Passport', 'MM445566', 'VERIFIED', 'Senior Officer', CAST(GETDATE() AS DATE)),
(11, 'NRC', '6/HaThaTa(N)789456', 'VERIFIED', 'Compliance Officer', CAST(GETDATE() AS DATE)),
(12, 'NRC', '1/MaKaNa(N)654987', 'REJECTED', 'Compliance Officer', CAST(GETDATE() AS DATE)),
(13, 'Passport', 'MM778899', 'VERIFIED', 'Senior Officer', CAST(GETDATE() AS DATE));
GO

/* =========================================================
   5. ADD AML MONITORING DATA
   transaction_id depends on previous inserted transactions
   ========================================================= */

INSERT INTO aml_monitoring
(transaction_id, aml_rule, risk_score, flagged_status, reviewed_by, review_date)
VALUES
(5, 'Large Foreign Transfer', 90, 'FLAGGED', 'AML Officer', CAST(GETDATE() AS DATE)),
(7, 'Foreign Transfer', 65, 'REVIEWED', 'AML Officer', CAST(GETDATE() AS DATE)),
(9, 'Very Large International Transfer', 98, 'FLAGGED', 'Senior AML Officer', CAST(GETDATE() AS DATE)),
(11, 'Dormant Account Sudden Large Transfer', 92, 'FLAGGED', 'Senior AML Officer', CAST(GETDATE() AS DATE)),
(12, 'High Risk Foreign Transfer', 96, 'FLAGGED', 'AML Manager', CAST(GETDATE() AS DATE));
GO

/* =========================================================
   6. ADD SUSPICIOUS ACTIVITY REPORTS
   ========================================================= */

INSERT INTO suspicious_activity_reports
(transaction_id, suspicious_reason, reported_to_authority, report_status)
VALUES
(5, 'Large transfer to Singapore', 'Central Bank', 'SUBMITTED'),
(9, 'Very large transfer to Dubai', 'Central Bank', 'SUBMITTED'),
(11, 'Dormant account suddenly transferred large amount', 'Internal Audit', 'UNDER REVIEW'),
(12, 'High-risk foreign transfer to Malaysia', 'Central Bank', 'SUBMITTED');
GO

/* =========================================================
   REPORT 1: CUSTOMER RISK SUMMARY
   ========================================================= */

SELECT
    risk_level,
    COUNT(*) AS total_customers
FROM customers
GROUP BY risk_level
ORDER BY total_customers DESC;
GO

/* =========================================================
   REPORT 2: KYC STATUS REPORT
   ========================================================= */

SELECT
    verification_status,
    COUNT(*) AS total_customers
FROM kyc_verification
GROUP BY verification_status;
GO

/* =========================================================
   REPORT 3: LARGE TRANSACTION REPORT
   ========================================================= */

SELECT
    c.full_name,
    a.account_number,
    t.transaction_type,
    t.amount,
    t.channel,
    t.destination_country,
    t.transaction_date
FROM bank_transactions t
JOIN accounts a ON t.account_id = a.account_id
JOIN customers c ON a.customer_id = c.customer_id
WHERE t.amount >= 100000000
ORDER BY t.amount DESC;
GO

/* =========================================================
   REPORT 4: FOREIGN TRANSFER REPORT
   ========================================================= */

SELECT
    c.full_name,
    a.account_number,
    t.amount,
    t.destination_country,
    t.channel,
    t.transaction_date
FROM bank_transactions t
JOIN accounts a ON t.account_id = a.account_id
JOIN customers c ON a.customer_id = c.customer_id
WHERE t.destination_country <> 'Myanmar'
ORDER BY t.amount DESC;
GO

/* =========================================================
   REPORT 5: HIGH-RISK CUSTOMER TRANSACTION REPORT
   ========================================================= */

SELECT
    c.full_name,
    c.risk_level,
    a.account_number,
    t.amount,
    t.transaction_type,
    t.destination_country
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
JOIN bank_transactions t ON a.account_id = t.account_id
WHERE c.risk_level = 'HIGH'
ORDER BY t.amount DESC;
GO

/* =========================================================
   REPORT 6: AML FLAGGED TRANSACTION REPORT
   ========================================================= */

SELECT
    c.full_name,
    a.account_number,
    t.amount,
    t.destination_country,
    am.aml_rule,
    am.risk_score,
    am.flagged_status,
    am.reviewed_by
FROM aml_monitoring am
JOIN bank_transactions t ON am.transaction_id = t.transaction_id
JOIN accounts a ON t.account_id = a.account_id
JOIN customers c ON a.customer_id = c.customer_id
WHERE am.flagged_status = 'FLAGGED'
ORDER BY am.risk_score DESC;
GO

/* =========================================================
   REPORT 7: SUSPICIOUS ACTIVITY REPORT SUMMARY
   ========================================================= */

SELECT
    sar.report_status,
    COUNT(*) AS total_reports
FROM suspicious_activity_reports sar
GROUP BY sar.report_status;
GO

/* =========================================================
   REPORT 8: DAILY TRANSACTION SUMMARY BY CHANNEL
   ========================================================= */

SELECT
    channel,
    COUNT(*) AS total_transactions,
    SUM(amount) AS total_amount,
    AVG(amount) AS average_amount
FROM bank_transactions
GROUP BY channel
ORDER BY total_amount DESC;
GO

/* =========================================================
   REPORT 9: ACCOUNT STATUS REPORT
   ========================================================= */

SELECT
    status,
    COUNT(*) AS total_accounts,
    SUM(balance) AS total_balance
FROM accounts
GROUP BY status;
GO

/* =========================================================
   REPORT 10: DORMANT ACCOUNT WITH LARGE TRANSACTION
   ========================================================= */

SELECT
    c.full_name,
    a.account_number,
    a.status,
    t.amount,
    t.transaction_date,
    t.remarks
FROM accounts a
JOIN customers c ON a.customer_id = c.customer_id
JOIN bank_transactions t ON a.account_id = t.account_id
WHERE a.status = 'DORMANT'
AND t.amount >= 100000000;
GO

/* =========================================================
   REPORT 11: COMPLIANCE DASHBOARD SUMMARY
   ========================================================= */

SELECT 'Total Customers' AS metric_name, COUNT(*) AS metric_value
FROM customers

UNION ALL

SELECT 'Total Accounts', COUNT(*)
FROM accounts

UNION ALL

SELECT 'Total Transactions', COUNT(*)
FROM bank_transactions

UNION ALL

SELECT 'High Risk Customers', COUNT(*)
FROM customers
WHERE risk_level = 'HIGH'

UNION ALL

SELECT 'Pending KYC', COUNT(*)
FROM kyc_verification
WHERE verification_status = 'PENDING'

UNION ALL

SELECT 'AML Flagged Transactions', COUNT(*)
FROM aml_monitoring
WHERE flagged_status = 'FLAGGED'

UNION ALL

SELECT 'Suspicious Activity Reports', COUNT(*)
FROM suspicious_activity_reports;
GO

/* =========================================================
   REPORT 12: TOP 5 HIGHEST TRANSACTIONS
   ========================================================= */

SELECT TOP 5
    c.full_name,
    a.account_number,
    t.amount,
    t.channel,
    t.destination_country,
    t.transaction_date
FROM bank_transactions t
JOIN accounts a ON t.account_id = a.account_id
JOIN customers c ON a.customer_id = c.customer_id
ORDER BY t.amount DESC;
GO

/* =========================================================
   REPORT 13: CUSTOMER-WISE TOTAL TRANSACTION AMOUNT
   ========================================================= */

SELECT
    c.customer_id,
    c.full_name,
    COUNT(t.transaction_id) AS total_transactions,
    SUM(t.amount) AS total_transaction_amount
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
JOIN bank_transactions t ON a.account_id = t.account_id
GROUP BY c.customer_id, c.full_name
ORDER BY total_transaction_amount DESC;
GO