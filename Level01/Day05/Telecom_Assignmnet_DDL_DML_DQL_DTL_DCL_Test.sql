-- TELECOM DATABASE CASE STUDY 
-- Scenario 
-- A telecom company manages: 
-- • Subscribers (customers)  
-- • SIM cards  
-- • Call/Data usage  
-- • Billing 

-- PART 1: DDL (Data Definition Language) 

-- Q1. Create database telecom_db 
DROP DATABASE IF EXISTS telecom_db;
CREATE DATABASE telecom_db;
USE telecom_db;

-- Q2. Create table subscribers 

CREATE TABLE subscribers ( 
subscriber_id INT AUTO_INCREMENT PRIMARY KEY, 
subscriber_name VARCHAR(100) NOT NULL, 
phone_number VARCHAR(20) UNIQUE, 
city VARCHAR(50), 
registration_date DATE 
); 

-- Q3. Create table plans

CREATE TABLE plans ( 
plan_id INT AUTO_INCREMENT PRIMARY KEY, 
plan_name VARCHAR(100), 
monthly_fee DECIMAL(10,2), 
data_limit INT 
); 

-- Q4. Create table usage_records 

CREATE TABLE usage_records ( 
usage_id INT AUTO_INCREMENT PRIMARY KEY, 
subscriber_id INT, 
data_used DECIMAL(10,2), 
call_minutes INT, 
usage_date DATE, 
FOREIGN KEY (subscriber_id) REFERENCES subscribers(subscriber_id) 
); 

-- Q5. Add column email to subscribers 
ALTER TABLE subscribers 
ADD email VARCHAR(100); 

-- Q6. Modify column city 
ALTER TABLE subscribers 
MODIFY city VARCHAR(100); 

-- Q7. Drop column email 
ALTER TABLE subscribers 
DROP COLUMN email; 

-- PART 2: DML (Data Manipulation Language) 

-- Q8. Insert subscribers 
INSERT INTO subscribers (subscriber_name, phone_number, city, registration_date) 
VALUES 
('Aung Aung', '0912345678', 'Yangon', '2025-01-01'), 
('Su Su', '0923456789', 'Mandalay', '2025-02-01'), 
('Kyaw Kyaw', '0934567890', 'Yangon', '2025-03-01'); 

-- Q9. Insert plans 
INSERT INTO plans (plan_name, monthly_fee, data_limit) 
VALUES 
('Basic', 10, 5), 
('Standard', 20, 10), 
('Premium', 30, 20); 

-- Q10. Insert usage records 
INSERT INTO usage_records (subscriber_id, data_used, call_minutes, usage_date) 
VALUES 
(1, 2.5, 30, '2025-04-01'), 
(1, 1.0, 10, '2025-04-02'), 
(2, 5.0, 60, '2025-04-01'), 
(3, 8.0, 90, '2025-04-03'); 

-- Q11. Update data usage 
UPDATE usage_records 
SET data_used = data_used + 1 
WHERE subscriber_id = 1; 

-- Q12. Delete inactive subscriber 
DELETE FROM subscribers 
WHERE subscriber_id = 3; 

-- PART 3: DQL (Data Query Language) 

-- Q13. Select all subscribers 
SELECT * FROM subscribers; 

-- Q14. Find subscribers in Yangon 
SELECT * FROM subscribers 
WHERE city = 'Yangon'; 

-- Q15. Total data usage per subscriber 
SELECT subscriber_id, SUM(data_used) AS total_data 
FROM usage_records 
GROUP BY subscriber_id; 

-- Q16. Subscribers with high usage (>5 GB) 
SELECT subscriber_id, SUM(data_used) AS total_data 
FROM usage_records 
GROUP BY subscriber_id 
HAVING SUM(data_used) > 5; 

-- Q17. Sort subscribers by registration date 
SELECT * FROM subscribers 
ORDER BY registration_date DESC; 

-- Q18. Join subscriber with usage 
SELECT s.subscriber_name, u.data_used, u.call_minutes 
FROM subscribers s 
JOIN usage_records u 
ON s.subscriber_id = u.subscriber_id; 

-- PART 4: TCL (Transaction Control Language) 

-- Q19. Data correction with rollback 
START TRANSACTION; 

UPDATE usage_records 
SET data_used = data_used + 10 
WHERE subscriber_id = 2; 

ROLLBACK; 

-- Q20. Confirm update with commit 
START TRANSACTION; 

UPDATE usage_records 
SET data_used = data_used + 2 
WHERE subscriber_id = 2; 

COMMIT; 

-- Q21. Use SAVEPOINT
START TRANSACTION; 

UPDATE usage_records SET data_used = data_used + 1 WHERE subscriber_id=1; 
SAVEPOINT sp1; 
UPDATE usage_records SET data_used = data_used + 5 WHERE subscriber_id=1; 

ROLLBACK TO sp1; 

COMMIT; 

-- PART 5: DCL (Data Control Language) 

-- Q22. Create user 
CREATE USER 'telecom_user'@'localhost' IDENTIFIED BY 'password123'; 

-- Q23. Grant SELECT access 
GRANT SELECT ON telecom_db.* TO 'telecom_user'@'localhost'; 

-- Q24. Grant INSERT and UPDATE 
GRANT INSERT, UPDATE ON telecom_db.usage_records 
TO 'telecom_user'@'localhost'; 

-- Q25. Revoke UPDATE permission 
REVOKE UPDATE ON telecom_db.usage_records 
FROM 'telecom_user'@'localhost'; 

-- Q26. Show permissions 
SHOW GRANTS FOR 'telecom_user'@'localhost'; 

-- Q27. Drop user 
DROP USER 'telecom_user'@'localhost'; 