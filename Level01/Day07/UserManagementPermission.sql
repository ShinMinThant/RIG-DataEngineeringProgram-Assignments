CREATE DATABASE university_db;
USE university_db;
CREATE TABLE students (
  student_id INT PRIMARY KEY,
  name VARCHAR(100),
  email VARCHAR(100),
  gpa DECIMAL(3,2)
);

-- Populate 10 rows into students table

INSERT INTO students (student_id, name, email, gpa) VALUES
(1, 'Aung Aung', 'aung.aung@example.com', 3.45),
(2, 'Su Su', 'su.su@example.com', 3.80),
(3, 'Kyaw Kyaw', 'kyaw.kyaw@example.com', 2.95),
(4, 'Hla Hla', 'hla.hla@example.com', 3.20),
(5, 'Mya Mya', 'mya.mya@example.com', 3.90),
(6, 'Zaw Zaw', 'zaw.zaw@example.com', 2.75),
(7, 'Thida', 'thida@example.com', 3.60),
(8, 'Min Min', 'min.min@example.com', 3.10),
(9, 'Ei Ei', 'ei.ei@example.com', 3.50),
(10, 'Ko Ko', 'ko.ko@example.com', 2.85);

CREATE USER 'adminuser'@'localhost' IDENTIFIED BY 'AdminPass123';
CREATE USER 'readonlyuser'@'localhost' IDENTIFIED BY 'ReadOnly123';
CREATE USER 'dataentry'@'localhost' IDENTIFIED BY 'Entry123';

GRANT ALL PRIVILEGES ON university_db.* TO 'adminuser'@'localhost';
GRANT SELECT ON university_db.students TO 'readonlyuser'@'localhost';
GRANT INSERT, UPDATE ON university_db.students TO 'dataentry'@'localhost';

-- View Permissions
-- Check what privileges each user has:
SHOW GRANTS FOR 'adminuser'@'localhost';
SHOW GRANTS FOR 'readonlyuser'@'localhost';
SHOW GRANTS FOR 'dataentry'@'localhost';

-- Select Grant to dataentry user
GRANT SELECT, INSERT, UPDATE
ON university_db.students
TO 'dataentry'@'localhost';

FLUSH PRIVILEGES;


-- REVOKE ALL PRIVILEGES ON mydatabase.* FROM 'riguser'@'localhost';

-- Revoke a Privilege
REVOKE UPDATE ON university_db.students FROM 'dataentry'@'localhost';

-- Clean Up (Optional)
-- To remove all users after the test:
DROP USER 'adminuser'@'localhost';
DROP USER 'readonlyuser'@'localhost';
DROP USER 'dataentry'@'localhost';
DROP DATABASE university_db;

-- Revoke Global Privileges (e.g., on all databases)
GRANT SELECT, INSERT, UPDATE
ON *.*
TO 'riguser'@'localhost';
