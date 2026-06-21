Drop table dept Cascade Constraints;
-- Create the DEPT table
CREATE TABLE dept (
    deptno NUMBER PRIMARY KEY,
    dname VARCHAR2(50),
    loc VARCHAR2(50)
);

desc dept;
select * from dept;

Drop table emp Cascade Constraints;
-- Create the EMP table
CREATE TABLE emp (
    empno NUMBER PRIMARY KEY,
    ename VARCHAR2(50),
    job VARCHAR2(30),
    mgr NUMBER,
    hiredate DATE,
    sal NUMBER(8,2),
    comm NUMBER(8,2),
    deptno NUMBER,
    FOREIGN KEY (deptno) REFERENCES dept(deptno)
);
desc emp;
select * from emp;
-- populate data
-- Insert data into DEPT table
INSERT INTO dept (deptno, dname, loc) VALUES (1, 'ACCOUNTING', 'NEW YORK');
INSERT INTO dept (deptno, dname, loc) VALUES (2, 'RESEARCH', 'DALLAS');
INSERT INTO dept (deptno, dname, loc) VALUES (3, 'SALES', 'CHICAGO');
INSERT INTO dept (deptno, dname, loc) VALUES (7, 'IT', 'SAN FRANCISCO');

-- Insert data into EMP table
INSERT INTO emp (empno, ename, job, mgr, hiredate, sal, comm, deptno)
VALUES (101, 'SMITH', 'CLERK', NULL, TO_DATE('2023-01-15','YYYY-MM-DD'), 1200, NULL, 1);

INSERT INTO emp (empno, ename, job, mgr, hiredate, sal, comm, deptno)
VALUES (102, 'ALLEN', 'SALESMAN', 101, TO_DATE('2023-02-10','YYYY-MM-DD'), 1600, 300, 3);

INSERT INTO emp (empno, ename, job, mgr, hiredate, sal, comm, deptno)
VALUES (103, 'WARD', 'SALESMAN', 101, TO_DATE('2023-03-01','YYYY-MM-DD'), 1250, 500, 3);

INSERT INTO emp (empno, ename, job, mgr, hiredate, sal, comm, deptno)
VALUES (104, 'JONES', 'MANAGER', NULL, TO_DATE('2023-04-20','YYYY-MM-DD'), 2975, NULL, 2);

INSERT INTO emp (empno, ename, job, mgr, hiredate, sal, comm, deptno)
VALUES (105, 'MILLER', 'CLERK', 104, TO_DATE('2023-05-11','YYYY-MM-DD'), 1300, NULL, 2);

-- Employees in department 7
INSERT INTO emp (empno, ename, job, mgr, hiredate, sal, comm, deptno)
VALUES (106, 'DAVIS', 'ANALYST', 104, TO_DATE('2023-06-18','YYYY-MM-DD'), 3000, NULL, 7);

INSERT INTO emp (empno, ename, job, mgr, hiredate, sal, comm, deptno)
VALUES (107, 'ADAMS', 'DEVELOPER', 106, TO_DATE('2023-07-05','YYYY-MM-DD'), 2500, NULL, 7);






-- Create the VIEW for employees in department 7
CREATE VIEW emp_dept7 AS
SELECT empno, ename, sal
FROM emp
WHERE deptno = 7;

SELECT * FROM emp_dept7;

--Create Simple View Column Alias Example
CREATE VIEW emp_annualSalary
AS SELECT empno employeeID, ename employeeNAME,
sal*12 annualSALARY
FROM emp
WHERE deptno = 3;
for
SELECT * FROM emp_annualSalary;

-- Rules 1 for Performing DML Operations on a View
-- Can usually perform DML operations
-- on simple views.
INSERT INTO emp_dept7 (empno, ename, sal) VALUES (9999, 'KO KO', 2000);


SELECT * FROM emp_dept7;

-- cannot insert BECAUSE WHERE CLAUSE

CREATE OR REPLACE VIEW emp_dept7 AS
SELECT empno, ename, sal, deptno
FROM emp
WHERE deptno = 7;
INSERT INTO emp_dept7 (empno, ename, sal, deptno) VALUES (4444, 'NYI NYI', 3000,7);
SELECT * FROM emp_dept7;

DELETE FROM emp_dept7 WHERE empno=4444;
SELECT * FROM emp_dept7;

UPDATE emp_dept7 SET SAL=SAL+300;
SELECT * FROM emp_dept7;

--Cannot remove a row if the view contains the following:
--Group functions
--A GROUP BY clause
--The DISTINCT keyword
--The pseudocolumn ROWNUM keyword
--  1. View using Group Functions
CREATE OR REPLACE VIEW emp_salary_stats AS
SELECT 
    deptno,
    COUNT(*) AS total_employees,
    AVG(sal) AS avg_salary,
    MAX(sal) AS max_salary,
    MIN(sal) AS min_salary
FROM emp
GROUP BY deptno;
SELECT * FROM emp_salary_stats;

DELETE FROM emp_salary_stats WHERE deptno=1;

--Error starting at line : 119 in command -
--DELETE FROM emp_salary_stats WHERE deptno=1
--Error at Command Line : 119 Column : 13
--Error report -
--SQL Error: ORA-01732: data manipulation operation not legal on this view

--2. View using GROUP BY Clause
CREATE OR REPLACE VIEW emp_count_per_job AS
SELECT 
    job,
    COUNT(*) AS num_employees
FROM emp
GROUP BY job;
SELECT * FROM emp_count_per_job;
DELETE FROM emp_count_per_job WHERE job='CLERK';

--Error starting at line : 135 in command -
--DELETE FROM emp_count_per_job WHERE job='CLERK'
--Error at Command Line : 135 Column : 13
--Error report -
--SQL Error: ORA-01732: data manipulation operation not legal on this view

--3. View using DISTINCT Keyword
CREATE OR REPLACE VIEW distinct_jobs AS
SELECT DISTINCT job
FROM emp;
SELECT * FROM distinct_jobs;
DELETE FROM distinct_jobs WHERE job='CLERK';

--Error starting at line : 148 in command -
--DELETE FROM distinct_jobs WHERE job='CLERK'
--Error at Command Line : 148 Column : 13
--Error report -
--SQL Error: ORA-01732: data manipulation operation not legal on this view

--4. View using ROWNUM Pseudocolumn
CREATE OR REPLACE VIEW top5_earners AS
SELECT empno, ename, sal
FROM (
    SELECT empno, ename, sal
    FROM emp
    ORDER BY sal DESC
)
WHERE ROWNUM <= 5;


SELECT * FROM top5_earners;
DELETE FROM top5_earners WHERE empno=106;

--Error starting at line : 168 in command -
--DELETE FROM top5_earners WHERE empno=106
--Error at Command Line : 168 Column : 13
--Error report -
--SQL Error: ORA-01732: data manipulation operation not legal on this view

--CREATE [OR REPLACE] [FORCE|NOFORCE] VIEW view
--[(alias[, alias]...)]
--AS subquery
--[WITH CHECK OPTION [CONSTRAINT constraint]]
--[WITH READ ONLY [CONSTRAINT constraint]];


CREATE OR REPLACE VIEW empvu7
AS SELECT *
FROM emp
WHERE deptno = 7
WITH CHECK OPTION CONSTRAINT empvu7_ck ;

SELECT * FROM empvu7;

INSERT INTO emp (empno, ename, job, mgr, hiredate, sal, comm, deptno)
VALUES (111, 'MOE MOE', 'DEVELOPER', 106, TO_DATE('2024-07-05','YYYY-MM-DD'), 2500, NULL, 7);

INSERT INTO empvu7 (empno, ename, job, mgr, hiredate, sal, comm, deptno)
VALUES (222, 'SOE SOE', 'DEVELOPER', 106, TO_DATE('2025-01-01','YYYY-MM-DD'), 2500, NULL,1);

--Error starting at line : 194 in command -
--INSERT INTO empvu7 (empno, ename, job, mgr, hiredate, sal, comm, deptno)
--VALUES (222, 'SOE SOE', 'DEVELOPER', 106, TO_DATE('2025-01-01','YYYY-MM-DD'), 2500, NULL, 6)
--Error at Command Line : 194 Column : 13
--Error report -
--SQL Error: ORA-01402: view WITH CHECK OPTION where-clause violation
CREATE OR REPLACE VIEW empvu7
AS SELECT *
FROM emp
WHERE deptno = 7;

SELECT *
FROM emp;


CREATE FORCE VIEW divinfo
AS
SELECT *
FROM divisions;

SELECT *
FROM divinfo;

CREATE TABLE divisions
(id number(5),
description varchar(20)
);

INSERT INTO divisions VALUES(1, 'aaa');

drop table divsions;

CREATE OR REPLACE VIEW empvu10
AS SELECT *
FROM emp
WITH READ ONLY ;

SELECT *
FROM empvu10;
INSERT INTO empvu10 (empno, ename, job, mgr, hiredate, sal, comm, deptno)
VALUES (333, 'SOE SOE', 'DEVELOPER', 106, TO_DATE('2025-01-01','YYYY-MM-DD'), 2500, NULL,1);


-- NOFORCE

CREATE OR REPLACE NOFORCE VIEW myview
AS SELECT *
FROM mytemp;

CREATE OR REPLACE VIEW myview
AS SELECT *
FROM mytemp;

CREATE OR REPLACE FORCE VIEW myview
AS SELECT *
FROM mytemp;

-- Warning: View created with compilation errors.


CREATE TABLE mytemp
(id number(5),
description varchar(20)
);

INSERT INTO mytemp VALUES(1,'no force test-1');

INSERT INTO mytemp VALUES(2,'no force test-2');


INSERT INTO mytemp VALUES(3,'no force test-3');





DROP VIEW empvu10; 