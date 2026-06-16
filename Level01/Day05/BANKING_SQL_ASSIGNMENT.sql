-- BANKING SQL ASSIGNMENT (INTERMEDIATE) 

-- 1. Setup (Given Schema) -- ============== -- BANKING DATABASE SETUP -- =================== 

DROP DATABASE IF EXISTS banking_lab; 
CREATE DATABASE banking_lab; 
USE banking_lab; -- Customers 

CREATE TABLE customers ( 
customer_id INT PRIMARY KEY AUTO_INCREMENT, 
customer_name VARCHAR(100), 
city VARCHAR(50) 
); 

-- Accounts 
CREATE TABLE accounts ( 
account_id INT PRIMARY KEY AUTO_INCREMENT, 
customer_id INT, 
account_type VARCHAR(50), -- Savings / Current 
balance DECIMAL(12,2), 
FOREIGN KEY (customer_id) REFERENCES customers(customer_id) 
);

 -- Transactions 
CREATE TABLE transactions ( 
transaction_id INT PRIMARY KEY AUTO_INCREMENT, 
account_id INT, 
transaction_type VARCHAR(50), -- Deposit / Withdrawal 
amount DECIMAL(12,2), 
transaction_date DATE, 
FOREIGN KEY (account_id) REFERENCES accounts(account_id) 
); 

-- 2. Sample Data -- Customers 
INSERT INTO customers (customer_name, city) VALUES 
('Aung Aung', 'Yangon'), 
('Su Su', 'Mandalay'), 
('Kyaw Kyaw', 'Yangon'), 
('Mya Mya', 'Bago'), 
('Ko Ko', 'Yangon'); 

-- Accounts 
INSERT INTO accounts (customer_id, account_type, balance) VALUES 
(1, 'Savings', 5000), 
(2, 'Current', 8000), 
(3, 'Savings', 12000), 
(4, 'Savings', 3000), 
(5, 'Current', 15000); 

-- Transactions 

INSERT INTO transactions (account_id, transaction_type, amount, transaction_date) VALUES 
(1, 'Deposit', 2000, '2025-01-01'), 
(1, 'Withdrawal', 500, '2025-01-02'), 
(2, 'Deposit', 3000, '2025-01-03'), 
(3, 'Deposit', 4000, '2025-01-04'), 
(3, 'Withdrawal', 1000, '2025-01-05'), 
(4, 'Deposit', 1500, '2025-01-06'), 
(5, 'Deposit', 7000, '2025-01-07'), 
(5, 'Withdrawal', 2000, '2025-01-08'); 

-- 3. Assignment Questions 
-- PART A: SELECT & FROM 

-- 1. Display all customers 
select * from customers;

-- 2. Show customer name and city only 
select customer_name, city from customers;

-- 3. Display all accounts with balance 
SELECT account_id, customer_id, account_type, balance
FROM accounts;

-- PART B: WHERE 
-- 4. Find customers from Yangon 
SELECT *
FROM customers
WHERE city = 'Yangon';

-- 5. Find accounts with balance greater than 10,000 
SELECT *
FROM accounts
WHERE balance > 10000;

-- 6. Show all Deposit transactions only 
SELECT *
FROM transactions
WHERE transaction_type = 'Deposit';

-- 7. Find transactions between '2025-01-01' and '2025-01-05' 
SELECT *
FROM transactions
WHERE transaction_date BETWEEN '2025-01-01' AND '2025-01-05';

-- PART C: ORDER BY 

-- 8. Display accounts sorted by balance (highest first) 
SELECT *
FROM accounts
ORDER BY balance DESC;

-- 9. Show transactions sorted by date (latest first)
SELECT *
FROM transactions
ORDER BY transaction_date DESC;
 
-- PART D: GROUP BY 

-- 10. Total balance per account type 
SELECT account_type,
       SUM(balance) AS total_balance
FROM accounts
GROUP BY account_type;

-- 11. Total transaction amount per account 
SELECT account_id,
       SUM(amount) AS total_transaction_amount
FROM transactions
GROUP BY account_id;

-- 12. Number of transactions per account 
SELECT account_id,
       COUNT(*) AS total_transactions
FROM transactions
GROUP BY account_id;


-- PART E: HAVING
 
-- 13. Show account types with total balance > 10,000 
SELECT account_type,
       SUM(balance) AS total_balance
FROM accounts
GROUP BY account_type
HAVING SUM(balance) > 10000;

-- 14. Show accounts with total transaction amount > 5,000 
SELECT account_id,
       SUM(amount) AS total_transaction_amount
FROM transactions
GROUP BY account_id
HAVING SUM(amount) > 5000;

-- PART F: COMBINED QUERY 

-- 15. For each customer: 
-- • Show total transactions 
-- • Show total amount 
-- • Only include customers with total amount > 3,000 
-- • Sort by total amount descending 

SELECT c.customer_id,
       c.customer_name,
       COUNT(t.transaction_id) AS total_transactions,
       SUM(t.amount) AS total_amount
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id
JOIN transactions t
    ON a.account_id = t.account_id
GROUP BY c.customer_id, c.customer_name
HAVING SUM(t.amount) > 3000
ORDER BY total_amount DESC;


-- PART G: ADVANCED (JOIN + CLAUSES) 

-- 16. Show customer name, account type, and balance 
SELECT c.customer_name,
       a.account_type,
       a.balance
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id;

-- 17. Show total deposits per customer 
SELECT c.customer_name,
       SUM(t.amount) AS total_deposits
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id
JOIN transactions t
    ON a.account_id = t.account_id
WHERE t.transaction_type = 'Deposit'
GROUP BY c.customer_id, c.customer_name;

-- 18. Show customers who made more than 1 transaction 
SELECT c.customer_name,
       COUNT(t.transaction_id) AS transaction_count
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id
JOIN transactions t
    ON a.account_id = t.account_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(t.transaction_id) > 1;

-- 19. Show customers with total withdrawals > 1,000 
SELECT c.customer_name,
       SUM(t.amount) AS total_withdrawals
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id
JOIN transactions t
    ON a.account_id = t.account_id
WHERE t.transaction_type = 'Withdrawal'
GROUP BY c.customer_id, c.customer_name
HAVING SUM(t.amount) > 1000;