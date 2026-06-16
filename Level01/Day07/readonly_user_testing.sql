-- Testing for 'readonlyuser'@'localhost' IDENTIFIED BY 'ReadOnly123';
USE university_db;
SELECT * FROM students;

-- error
INSERT INTO students (student_id, name, email, gpa) VALUES
(11, 'Aung Aung Moe', 'aung.aungmoe@example.com', 3.55);

-- error
UPDATE students 
SET email='aungmoe@example.com'
WHERE student_id=10;
-- error
DELETE FROM students
WHERE student_id=10;
-- error
ALTER TABLE students ADD COLUMN address VARCHAR(150);
-- can view
DESC students;