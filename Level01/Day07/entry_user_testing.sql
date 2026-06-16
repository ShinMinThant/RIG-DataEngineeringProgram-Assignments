-- Testing for 'dataentry'@'localhost' IDENTIFIED BY 'Entry123';
USE university_db;
-- error
SELECT * FROM students;

INSERT INTO students (student_id, name, email, gpa) VALUES
(13, 'Soe Soe', 'soesoe@example.com', 3.55);

UPDATE students 
SET email='aungmoe@example.com'
WHERE student_id=13;
-- error
DELETE FROM students
WHERE student_id=13;

-- View Permissions
-- Check what privileges each user has:
SHOW GRANTS FOR 'adminuser'@'localhost';
SHOW GRANTS FOR 'readonlyuser'@'localhost';
SHOW GRANTS FOR 'dataentry'@'localhost';
