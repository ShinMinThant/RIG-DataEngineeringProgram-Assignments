-- Section A — DDL

-- Question 1
CREATE DATABASE telecom_user_mgmt;

USE telecom_user_mgmt;

-- Question 2
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE,
    department VARCHAR(50),
    status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Question 3
CREATE TABLE roles (
    role_id INT PRIMARY KEY AUTO_INCREMENT,
    role_name VARCHAR(50) UNIQUE,
    description VARCHAR(255)
);

-- Question 4
CREATE TABLE permissions (
    permission_id INT PRIMARY KEY AUTO_INCREMENT,
    permission_name VARCHAR(100),
    module_name VARCHAR(100)
);

-- Question 5
CREATE TABLE user_roles (
    user_role_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    role_id INT,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (role_id) REFERENCES roles(role_id)
);

-- Question 6
CREATE TABLE audit_logs (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    action_taken VARCHAR(255),
    action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);


-- Section B — DML

-- Question 7
INSERT INTO users (username, email, department)
VALUES
('john_admin', 'john@telecom.com', 'IT'),
('mary_bill', 'mary@telecom.com', 'Billing'),
('sam_support', 'sam@telecom.com', 'Customer Support'),
('alex_network', 'alex@telecom.com', 'Network Operations'),
('linda_manager', 'linda@telecom.com', 'Management');

-- Question 8
INSERT INTO roles (role_name, description)
VALUES
('Admin', 'Full system access'),
('Billing Officer', 'Billing operations'),
('Support Agent', 'Customer support access'),
('Network Engineer', 'Network management'),
('Viewer', 'Read-only access');

-- Question 9
INSERT INTO permissions (permission_name, module_name)
VALUES
('Create User', 'User Management'),
('Update Billing', 'Billing'),
('View Reports', 'Reports'),
('Manage Network', 'Network'),
('Read Logs', 'Audit');

-- Question 10
INSERT INTO user_roles (user_id, role_id)
VALUES
(1,1),
(2,2),
(3,3),
(4,4),
(5,5);

-- Question 11
UPDATE users
SET status = 'INACTIVE'
WHERE user_id = 3;

-- Question 12
DELETE FROM permissions
WHERE permission_id = 5;


-- Section C — DQL

-- Question 13
SELECT * FROM users;

-- Question 14
SELECT * FROM users
WHERE status = 'ACTIVE';

-- Question 15
SELECT u.username, u.department, r.role_name
FROM users u
JOIN user_roles ur ON u.user_id = ur.user_id
JOIN roles r ON ur.role_id = r.role_id;

-- Question 16
SELECT department, COUNT(*) AS total_users
FROM users
GROUP BY department;

-- Question 17
SELECT * FROM users
WHERE department = 'Billing';

-- Question 18
SELECT r.role_name, p.permission_name
FROM roles r
CROSS JOIN permissions p;

-- Question 19
SELECT * FROM users
ORDER BY username ASC;

-- Question 20
SELECT COUNT(*) AS total_users
FROM users;

-- =========================================
-- Section D — TCL
-- =========================================

-- Question 21
START TRANSACTION;

INSERT INTO audit_logs (user_id, action_taken)
VALUES (1, 'User logged into system');

COMMIT;

-- Question 22
START TRANSACTION;

UPDATE users
SET status = 'ACTIVE'
WHERE user_id = 3;

ROLLBACK;

SELECT * FROM users
WHERE user_id = 3;

-- Question 23
START TRANSACTION;

UPDATE users
SET department = 'IT'
WHERE user_id = 2;

SAVEPOINT sp1;

UPDATE users
SET department = 'Management'
WHERE user_id = 4;

ROLLBACK TO sp1;

COMMIT;

-- Question 24
-- COMMIT Example
START TRANSACTION;

UPDATE users
SET status = 'ACTIVE'
WHERE user_id = 2;

COMMIT;

-- ROLLBACK Example
START TRANSACTION;

UPDATE users
SET status = 'INACTIVE'
WHERE user_id = 2;

ROLLBACK;

-- =========================================
-- Section E — DCL
-- =========================================

-- Question 25
CREATE USER 'billing_user'@'localhost'
IDENTIFIED BY 'billing123';

-- Question 26
GRANT SELECT, UPDATE
ON telecom_user_mgmt.users
TO 'billing_user'@'localhost';

-- Question 27

GRANT INSERT
ON telecom_user_mgmt.audit_logs
TO 'billing_user'@'localhost';

-- Question 28
SHOW GRANTS FOR 'billing_user'@'localhost';

-- Question 29
REVOKE UPDATE
ON telecom_user_mgmt.users
FROM 'billing_user'@'localhost';

-- Question 30
CREATE USER 'viewer_user'@'localhost'
IDENTIFIED BY 'viewer123';

GRANT SELECT
ON telecom_user_mgmt.*
TO 'viewer_user'@'localhost';

-- =========================================
-- Section F — Practical Scenario Questions
-- =========================================

-- Question 31
CREATE USER 'admin_user'@'localhost'
IDENTIFIED BY 'admin123';

GRANT ALL PRIVILEGES
ON telecom_user_mgmt.users
TO 'admin_user'@'localhost';

-- Question 32
GRANT SELECT, UPDATE
ON telecom_user_mgmt.users
TO 'billing_user'@'localhost';

-- Question 33
CREATE USER 'support_user'@'localhost'
IDENTIFIED BY 'sup123';

GRANT SELECT
ON telecom_user_mgmt.*
TO 'support_user'@'localhost';

-- Question 34
SELECT
    u.username,
    r.role_name,
    p.permission_name,
    p.module_name
FROM users u
JOIN user_roles ur
    ON u.user_id = ur.user_id
JOIN roles r
    ON ur.role_id = r.role_id
JOIN permissions p;

-- Question 35
/*
Role-Based Access Control (RBAC) is important in telecom systems because:

1. Security:
RBAC ensures only authorized users can access sensitive telecom systems and data.

2. Auditability:
User activities can be tracked through logs, making monitoring and investigation easier.

3. Data Protection:
Sensitive customer and billing information is protected from unauthorized access.

4. Access Limitation:
Employees only receive permissions required for their job roles, reducing misuse risks.

5. Compliance:
RBAC helps telecom companies comply with security regulations and industry standards.
*/