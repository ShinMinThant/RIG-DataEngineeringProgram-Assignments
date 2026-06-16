-- Testing for adminuser'@'localhost' IDENTIFIED BY 'AdminPass123';
USE university_db;
SELECT * FROM students;

INSERT INTO students (student_id, name, email, gpa) VALUES
(11, 'Aung Aung Moe', 'aung.aungmoe@example.com', 3.55);

UPDATE students 
SET email='aungmoe@example.com'
WHERE student_id=11;

DELETE FROM students
WHERE student_id=11;

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


