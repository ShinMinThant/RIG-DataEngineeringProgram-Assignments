create database universitydb;
use universitydb;
create table Student(
StudentID int auto_increment primary key,
 FirstName varchar(50), 
 LastName varchar(50), 
 Email varchar(30)
 );

INSERT INTO Student (StudentID, FirstName, LastName, Email) VALUES
(1, 'First1', 'Last1', 'student1@school.edu'),
(2, 'First2', 'Last2', 'student2@school.edu'),
(3, 'First3', 'Last3', 'student3@school.edu'),
(4, 'First4', 'Last4', 'student4@school.edu'),
(5, 'First5', 'Last5', 'student5@school.edu'),
(6, 'First6', 'Last6', 'student6@school.edu'),
(7, 'First7', 'Last7', 'student7@school.edu'),
(8, 'First8', 'Last8', 'student8@school.edu'),
(9, 'First9', 'Last9', 'student9@school.edu'),
(10, 'First10', 'Last10', 'student10@school.edu'),
(11, 'First11', 'Last11', 'student11@school.edu'),
(12, 'First12', 'Last12', 'student12@school.edu'),
(13, 'First13', 'Last13', 'student13@school.edu'),
(14, 'First14', 'Last14', 'student14@school.edu'),
(15, 'First15', 'Last15', 'student15@school.edu'),
(16, 'First16', 'Last16', 'student16@school.edu'),
(17, 'First17', 'Last17', 'student17@school.edu'),
(18, 'First18', 'Last18', 'student18@school.edu'),
(19, 'First19', 'Last19', 'student19@school.edu'),
(20, 'First20', 'Last20', 'student20@school.edu');

create table Instructor (
InstructorID int primary key , InstructorName varchar(50), Email varchar(30));

INSERT INTO Instructor (InstructorID, InstructorName, Email) VALUES
(1, 'Instructor1', 'instructor1@school.edu'),
(2, 'Instructor2', 'instructor2@school.edu'),
(3, 'Instructor3', 'instructor3@school.edu'),
(4, 'Instructor4', 'instructor4@school.edu'),
(5, 'Instructor5', 'instructor5@school.edu');

create table Course (
CourseID int primary key,
 CourseName varchar(50), 
 InstructorID int, FOREIGN KEY (InstructorID) REFERENCES Instructor(InstructorID) );

INSERT INTO Course (CourseID, CourseName, InstructorID) VALUES
(1, 'Course1', 3),
(2, 'Course2', 3),
(3, 'Course3', 3),
(4, 'Course4', 5),
(5, 'Course5', 2),
(6, 'Course6', 5),
(7, 'Course7', 5),
(8, 'Course8', 5),
(9, 'Course9', 3),
(10, 'Course10', 3);

create table Enrollment (
StudentID int ,
 CourseID int , 
 EnrollmentDate date,
 FOREIGN KEY (StudentID) REFERENCES Student(StudentID) ,
 FOREIGN KEY (CourseID) REFERENCES Course(CourseID) 
 );

INSERT INTO Enrollment (StudentID, CourseID, EnrollmentDate) VALUES
(10, 6, '2023-02-17'),
(19, 3, '2023-04-23'),
(6, 8, '2023-06-27'),
(19, 3, '2023-08-26'),
(12, 4, '2023-09-22'),
(5, 7, '2023-05-15'),
(15, 5, '2023-07-23'),
(11, 5, '2023-08-28'),
(19, 1, '2023-10-20'),
(5, 6, '2023-11-01'),
(3, 10, '2023-03-30'),
(15, 6, '2023-11-30'),
(20, 10, '2023-04-13'),
(10, 5, '2023-05-05'),
(13, 6, '2023-05-31'),
(11, 7, '2023-12-05'),
(4, 4, '2023-01-21'),
(6, 9, '2023-03-10'),
(17, 7, '2023-11-14'),
(4, 5, '2023-05-14');

create table Assignment (
AssignmentID int primary key,
 AssignmentName varchar(50), 
 CourseID int , 
 DueDate date,
 FOREIGN KEY (CourseID) REFERENCES Course(CourseID)
 );
 
INSERT INTO Assignment (AssignmentID, AssignmentName, CourseID, DueDate) VALUES
(1, 'Assignment1', 5, '2024-04-07'),
(2, 'Assignment2', 10, '2024-04-09'),
(3, 'Assignment3', 4, '2024-02-16'),
(4, 'Assignment4', 4, '2024-05-26'),
(5, 'Assignment5', 8, '2024-03-25'),
(6, 'Assignment6', 8, '2024-03-07'),
(7, 'Assignment7', 5, '2024-01-05'),
(8, 'Assignment8', 4, '2024-03-16'),
(9, 'Assignment9', 6, '2024-05-31'),
(10, 'Assignment10', 1, '2024-03-01'),
(11, 'Assignment11', 4, '2024-02-16'),
(12, 'Assignment12', 6, '2024-06-12'),
(13, 'Assignment13', 3, '2024-02-14'),
(14, 'Assignment14', 4, '2024-06-30'),
(15, 'Assignment15', 5, '2024-06-12'),
(16, 'Assignment16', 2, '2024-01-30'),
(17, 'Assignment17', 6, '2024-06-26'),
(18, 'Assignment18', 10, '2024-01-19'),
(19, 'Assignment19', 3, '2024-01-14'),
(20, 'Assignment20', 10, '2024-03-15');

BEGIN;

INSERT INTO Student VALUES (55, 'John', 'Doe', 'john@mail.com');

-- valid course
INSERT INTO course VALUES (101, 'Database', 1);

-- ❌ invalid enrollment (course 999 doesn't exist)
INSERT INTO enrollment VALUES (1, 999, NOW());

ROLLBACK;

select * from Student;

INSERT INTO student VALUES (21, 'A', 'B', 'invalid-email');