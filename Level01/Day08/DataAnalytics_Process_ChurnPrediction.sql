/* =========================================================
   LAB: AI-Based Telecom Customer Churn Analytics
   Database: MSSQL Server
   Use Case: Telecom Customer Churn Prediction
   ========================================================= */

-- 1. Create Database
CREATE DATABASE TelecomAI_DB;
GO

USE TelecomAI_DB;
GO

/* =========================================================
   2. Create Customer Table
   ========================================================= */

CREATE TABLE telecom_customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    gender VARCHAR(10),
    age INT,
    contract_type VARCHAR(20),
    monthly_bill DECIMAL(10,2),
    internet_usage_gb DECIMAL(10,2),
    call_minutes INT,
    complaint_count INT,
    payment_delay_days INT,
    churn_status VARCHAR(10)
);
GO

/* =========================================================
   3. Insert Sample Telecom Data
   ========================================================= */

INSERT INTO telecom_customers
(customer_id, customer_name, gender, age, contract_type, monthly_bill,
 internet_usage_gb, call_minutes, complaint_count, payment_delay_days, churn_status)
VALUES
(1, 'Aung Aung', 'Male', 28, 'Prepaid', 25000, 35.5, 400, 3, 10, 'Yes'),
(2, 'Su Su', 'Female', 32, 'Postpaid', 45000, 80.0, 900, 0, 0, 'No'),
(3, 'Kyaw Kyaw', 'Male', 45, 'Prepaid', 18000, 20.0, 250, 4, 15, 'Yes'),
(4, 'Mya Mya', 'Female', 25, 'Postpaid', 60000, 120.5, 1200, 1, 2, 'No'),
(5, 'Hla Hla', 'Female', 39, 'Prepaid', 22000, 25.5, 300, 5, 20, 'Yes'),
(6, 'Tun Tun', 'Male', 30, 'Postpaid', 52000, 100.0, 1000, 0, 0, 'No'),
(7, 'Nandar', 'Female', 27, 'Prepaid', 20000, 18.5, 200, 2, 8, 'Yes'),
(8, 'Moe Moe', 'Female', 35, 'Postpaid', 48000, 75.0, 850, 1, 1, 'No'),
(9, 'Zaw Zaw', 'Male', 42, 'Prepaid', 26000, 30.0, 350, 4, 12, 'Yes'),
(10, 'Ei Ei', 'Female', 29, 'Postpaid', 55000, 110.0, 1100, 0, 0, 'No');
GO

/* =========================================================
   4. Data Exploration
   --========================================================= */

-- View all data
SELECT * FROM telecom_customers;

-- Count churn and non-churn customers
--SELECT churn_status	- Retrieves churn category
--COUNT(*)	- Counts rows
--AS total_customers	- Gives alias name
--FROM telecom_customers	- Reads from telecom table
--GROUP BY churn_status	- Groups rows by churn type


SELECT 
    churn_status,
    COUNT(*) AS total_customers
FROM telecom_customers
GROUP BY churn_status;

-- Average monthly bill by churn status
--AVG(monthly_bill)	-Calculates average bill
--AS avg_monthly_bill	-Renames output
--GROUP BY churn_status	-Separates churn vs non-churn

SELECT 
    churn_status,
    AVG(monthly_bill) AS avg_monthly_bill
FROM telecom_customers
GROUP BY churn_status;

-- Average complaints by churn status
SELECT 
    churn_status,
    AVG(complaint_count) AS avg_complaints
FROM telecom_customers
GROUP BY churn_status;

/* =========================================================
   5. Data Preparation
   Convert Churn Status into Numeric Label
   Yes = 1, No = 0
   ========================================================= */
	--CASE	- Conditional logic
	--WHEN churn_status = 'Yes'	- Checks churn condition
	--THEN 1	- Assigns numeric value
	--ELSE 0	- Assigns non-churn value
	--END AS churn_label	- Creates new column

SELECT 
    customer_id,
    customer_name,
    age,
    contract_type,
    monthly_bill,
    internet_usage_gb,
    call_minutes,
    complaint_count,
    payment_delay_days,
    CASE 
        WHEN churn_status = 'Yes' THEN 1
        ELSE 0
    END AS churn_label
FROM telecom_customers;

/* =========================================================
   6. Simple AI Rule-Based Churn Risk Scoring
   This simulates AI scoring logic inside SQL.
   ========================================================= */
 --  Condition 1
	--WHEN complaint_count >= 4

	--Customers with many complaints may leave.
	--Condition 2
	--OR payment_delay_days >= 15

	--Late payments indicate dissatisfaction or financial issues.
	--Condition 3
	--OR contract_type = 'Prepaid'
	--Prepaid users are easier to switch to competitors.

SELECT 
    customer_id,
    customer_name,
    contract_type,
    monthly_bill,
    complaint_count,
    payment_delay_days,
    churn_status,

    CASE 
        WHEN complaint_count >= 4 
             OR payment_delay_days >= 15 
             OR contract_type = 'Prepaid'
        THEN 'High Risk'

        WHEN complaint_count BETWEEN 2 AND 3 
             OR payment_delay_days BETWEEN 7 AND 14
        THEN 'Medium Risk'

        ELSE 'Low Risk'
    END AS predicted_churn_risk

FROM telecom_customers;
GO

/* =========================================================
   7. Create View for Churn Risk Dashboard
   ========================================================= */

CREATE VIEW vw_customer_churn_risk AS
SELECT 
    customer_id,
    customer_name,
    gender,
    age,
    contract_type,
    monthly_bill,
    internet_usage_gb,
    call_minutes,
    complaint_count,
    payment_delay_days,
    churn_status,

    CASE 
        WHEN complaint_count >= 4 
             OR payment_delay_days >= 15 
             OR contract_type = 'Prepaid'
        THEN 'High Risk'

        WHEN complaint_count BETWEEN 2 AND 3 
             OR payment_delay_days BETWEEN 7 AND 14
        THEN 'Medium Risk'

        ELSE 'Low Risk'
    END AS predicted_churn_risk
FROM telecom_customers;
GO

/* =========================================================
   8. Query the Churn Risk Dashboard View
   ========================================================= */

SELECT * FROM vw_customer_churn_risk;

-- Show only high-risk customers
SELECT *
FROM vw_customer_churn_risk
WHERE predicted_churn_risk = 'High Risk';

/* =========================================================
   9. Retention Campaign Recommendation
   ========================================================= */

SELECT 
    customer_id,
    customer_name,
    predicted_churn_risk,
    CASE 
        WHEN predicted_churn_risk = 'High Risk'
        THEN 'Offer discount package and priority customer support'

        WHEN predicted_churn_risk = 'Medium Risk'
        THEN 'Send loyalty offer and service improvement message'

        ELSE 'Maintain normal service communication'
    END AS recommended_action
FROM vw_customer_churn_risk;
GO

/* =========================================================
   10. Model Evaluation Simulation
   Compare Actual Churn Status with Predicted Risk
   ========================================================= */

SELECT 
    churn_status,
    predicted_churn_risk,
    COUNT(*) AS total_customers
FROM vw_customer_churn_risk
GROUP BY churn_status, predicted_churn_risk;
GO