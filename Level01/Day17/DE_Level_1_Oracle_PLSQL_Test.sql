SET SERVEROUTPUT ON;

BEGIN
	DBMS_OUTPUT.PUT_LINE('HELLO');
	DBMS_OUTPUT.PUT_LINE('DE CLASS');
END;
/

===
DECLARE
  x NUMBER(3) := 10;

  PROCEDURE abc 
  IS
  BEGIN
    INSERT INTO tempp VALUES (1, 'In abc');
  END abc;
BEGIN
  INSERT INTO tempp VALUES (1, 'In main');
  abc;
 END;
/

====
DECLARE
  
  PROCEDURE pqr(msg IN VARCHAR2) IS   -- or VARCHAR2(50)
  BEGIN
    INSERT INTO tempp VALUES (2, msg);
  END pqr;

BEGIN
  INSERT INTO tempp VALUES (1, 'In main');
  pqr('This');
 END;
/
=====
DECLARE
   x NUMBER(3) := 10;
  PROCEDURE xyz(val2 IN OUT NUMBER) IS   -- or VARCHAR2(50)
  BEGIN
    DBMS_OUTPUT.PUT_LINE('val 2 is ' || val2);
    val2:=300;
  END xyz;


BEGIN
  xyz(x);
  DBMS_OUTPUT.PUT_LINE('x is '||x);

 END;
/




===

DECLARE
  x NUMBER(3) := 10;

  PROCEDURE abc 
  IS
  BEGIN
    INSERT INTO tempp VALUES (1, 'In abc');
  END abc;

  PROCEDURE pqr(msg IN VARCHAR2) IS   -- or VARCHAR2(50)
  BEGIN
    INSERT INTO tempp VALUES (2, msg);
  END pqr;

PROCEDURE xyz(val2 IN OUT NUMBER) IS   -- or VARCHAR2(50)
  BEGIN
    DBMS_OUTPUT.PUT_LINE('val 2 is ' || val2);
    val2:=300;
  END xyz;
  
BEGIN
  
  xyz(x);
  DBMS_OUTPUT.PUT_LINE('x is '||x);
END;
/
=============================

DECLARE
  x NUMBER(3) := 10;

  FUNCTION xyz(val2 IN NUMBER)
    RETURN NUMBER
  IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE('val 2 is ' || val2);
    RETURN 300;
  END xyz;

BEGIN
  x := xyz(x);
  DBMS_OUTPUT.PUT_LINE('x is ' || x);
END;
/



DECLARE
x NUMBER(4):=10;
PROCEDURE abc (y IN NUMBER)
IS
BEGIN
INSERT INTO tempp VALUES(y, 'abc');
END;
 
PROCEDURE def (y OUT NUMBER)
IS
BEGIN
y:=100;
END;
 
PROCEDURE pqr (y IN OUT NUMBER)
IS
BEGIN
y:=y*2;
END;
 
BEGIN
abc(10); 
def(x);
pqr(x);
END;
/







