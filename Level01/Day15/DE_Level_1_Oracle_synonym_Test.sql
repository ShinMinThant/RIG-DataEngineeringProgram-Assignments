/* =========================================================
   ORACLE SYNONYM COMPLETE PRACTICE SCRIPT
   Scenario: Telecom Billing System
   ========================================================= */

/* =========================================================
   1. CLEAN OLD OBJECTS
   ========================================================= */

BEGIN
   EXECUTE IMMEDIATE 'DROP SYNONYM syn_subscribers';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP SYNONYM syn_call_records';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP VIEW vw_active_subscribers';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP PROCEDURE prc_get_subscriber_bill';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE call_records CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE subscribers CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

/* =========================================================
   2. CREATE BASE TABLES
   ========================================================= */

CREATE TABLE subscribers
(
    subscriber_id   NUMBER PRIMARY KEY,
    msisdn          VARCHAR2(20) UNIQUE NOT NULL,
    customer_name   VARCHAR2(100),
    city            VARCHAR2(50),
    status          VARCHAR2(20),
    activation_date DATE
);

CREATE TABLE call_records
(
    call_id        NUMBER PRIMARY KEY,
    subscriber_id  NUMBER,
    call_type      VARCHAR2(20),
    call_start     DATE,
    duration_sec   NUMBER,
    charge_amount  NUMBER(10,2),

    CONSTRAINT fk_call_subscriber
    FOREIGN KEY (subscriber_id)
    REFERENCES subscribers(subscriber_id)
);

/* =========================================================
   3. POPULATE SAMPLE DATA
   ========================================================= */

INSERT INTO subscribers VALUES
(1, '959400000001', 'Aung Aung', 'Yangon', 'ACTIVE', DATE '2024-01-01');

INSERT INTO subscribers VALUES
(2, '959400000002', 'Mg Mg', 'Mandalay', 'ACTIVE', DATE '2024-01-05');

INSERT INTO subscribers VALUES
(3, '959400000003', 'Hla Hla', 'Naypyitaw', 'INACTIVE', DATE '2024-02-01');

INSERT INTO subscribers VALUES
(4, '959400000004', 'Su Su', 'Yangon', 'ACTIVE', DATE '2024-02-10');

INSERT INTO subscribers VALUES
(5, '959400000005', 'Kyaw Kyaw', 'Bago', 'SUSPENDED', DATE '2024-03-01');

INSERT INTO call_records VALUES
(101, 1, 'VOICE', DATE '2024-04-01', 120, 150.00);

INSERT INTO call_records VALUES
(102, 1, 'SMS', DATE '2024-04-02', 0, 15.00);

INSERT INTO call_records VALUES
(103, 2, 'DATA', DATE '2024-04-03', 500, 400.00);

INSERT INTO call_records VALUES
(104, 4, 'VOICE', DATE '2024-04-04', 300, 350.00);

INSERT INTO call_records VALUES
(105, 4, 'DATA', DATE '2024-04-05', 700, 600.00);

COMMIT;

/* =========================================================
   4. CREATE VIEW
   ========================================================= */

CREATE OR REPLACE VIEW vw_active_subscribers
AS
SELECT
    subscriber_id,
    msisdn,
    customer_name,
    city,
    activation_date
FROM subscribers
WHERE status = 'ACTIVE';

/* =========================================================
   5. CREATE PROCEDURE
   ========================================================= */

CREATE OR REPLACE PROCEDURE prc_get_subscriber_bill
(
    p_subscriber_id IN NUMBER
)
AS
    v_total_bill NUMBER(10,2);
BEGIN
    SELECT NVL(SUM(charge_amount), 0)
    INTO v_total_bill
    FROM call_records
    WHERE subscriber_id = p_subscriber_id;

    DBMS_OUTPUT.PUT_LINE('Subscriber ID: ' || p_subscriber_id);
    DBMS_OUTPUT.PUT_LINE('Total Bill: ' || v_total_bill);
END;
/

/* =========================================================
   6. CREATE PRIVATE SYNONYMS
   ========================================================= */

CREATE SYNONYM syn_subscribers
FOR subscribers;

CREATE SYNONYM syn_call_records
FOR call_records;

CREATE SYNONYM syn_active_subscribers
FOR vw_active_subscribers;

CREATE SYNONYM syn_get_bill
FOR prc_get_subscriber_bill;

/* =========================================================
   7. TEST SYNONYM FOR TABLE SELECT
   ========================================================= */

SELECT *
FROM syn_subscribers;

SELECT *
FROM syn_call_records;

/* =========================================================
   8. TEST SYNONYM WITH WHERE CONDITION
   ========================================================= */

SELECT subscriber_id,
       msisdn,
       customer_name,
       city
FROM syn_subscribers
WHERE city = 'Yangon';

/* =========================================================
   9. TEST SYNONYM WITH JOIN
   ========================================================= */

SELECT s.customer_name,
       s.msisdn,
       c.call_type,
       c.duration_sec,
       c.charge_amount
FROM syn_subscribers s
JOIN syn_call_records c
ON s.subscriber_id = c.subscriber_id
WHERE s.status = 'ACTIVE';

/* =========================================================
   10. TEST SYNONYM FOR VIEW
   ========================================================= */

SELECT *
FROM syn_active_subscribers;

/* =========================================================
   11. TEST SYNONYM FOR PROCEDURE
   ========================================================= */

SET SERVEROUTPUT ON;

EXEC syn_get_bill(1);

EXEC syn_get_bill(4);

/* =========================================================
   12. TEST INSERT USING SYNONYM
   ========================================================= */

INSERT INTO syn_subscribers
VALUES
(6, '959400000006', 'Mya Mya', 'Yangon', 'ACTIVE', DATE '2024-03-15');

COMMIT;

SELECT *
FROM syn_subscribers
WHERE subscriber_id = 6;

/* =========================================================
   13. TEST UPDATE USING SYNONYM
   ========================================================= */

UPDATE syn_subscribers
SET status = 'INACTIVE'
WHERE subscriber_id = 6;

COMMIT;

SELECT *
FROM syn_subscribers
WHERE subscriber_id = 6;

/* =========================================================
   14. TEST DELETE USING SYNONYM
   ========================================================= */

DELETE FROM syn_subscribers
WHERE subscriber_id = 6;

COMMIT;

SELECT *
FROM syn_subscribers
WHERE subscriber_id = 6;

/* =========================================================
   15. CHECK CREATED SYNONYMS
   ========================================================= */

SELECT synonym_name,
       table_owner,
       table_name
FROM user_synonyms
ORDER BY synonym_name;

/* =========================================================
   16. PUBLIC SYNONYM EXAMPLE
   =========================================================
   Note:
   Public synonym requires CREATE PUBLIC SYNONYM privilege.
   Usually DBA creates it.
   ========================================================= */

-- CREATE PUBLIC SYNONYM pub_subscribers
-- FOR your_schema_name.subscribers;

-- SELECT *
-- FROM pub_subscribers;

/* =========================================================
   17. CROSS-SCHEMA SYNONYM EXAMPLE
   =========================================================
   Example:
   BILLING_USER owns the table.
   CRM_USER wants to access it.
   ========================================================= */

-- Step 1: Login as BILLING_USER

-- GRANT SELECT, INSERT, UPDATE, DELETE
-- ON subscribers
-- TO crm_user;

-- Step 2: Login as CRM_USER

-- CREATE SYNONYM crm_subscribers
-- FOR billing_user.subscribers;

-- SELECT *
-- FROM crm_subscribers;

/* =========================================================
   18. DROP SYNONYM
   ========================================================= */

-- DROP SYNONYM syn_subscribers;
-- DROP SYNONYM syn_call_records;
-- DROP SYNONYM syn_active_subscribers;
-- DROP SYNONYM syn_get_bill;

-- DROP PUBLIC SYNONYM pub_subscribers;

/* =========================================================
   19. COMMON ERRORS
   =========================================================

   Error 1:
   ORA-00942: table or view does not exist

   Possible reasons:
   - Base table does not exist
   - No privilege on base table
   - Wrong schema name
   - Synonym points to invalid object

   Error 2:
   ORA-01031: insufficient privileges

   Possible reasons:
   - User has no CREATE SYNONYM privilege
   - User has no CREATE PUBLIC SYNONYM privilege

   Error 3:
   ORA-01775: looping chain of synonyms

   Possible reason:
   - Synonym points to another synonym repeatedly

   ========================================================= */

/* =========================================================
   20. KEY NOTES
   =========================================================

   1. Synonym is an alias for a database object.
   2. Synonym does not store data.
   3. Synonym can point to table, view, sequence, procedure,
      function, package, or materialized view.
   4. Private synonym belongs to one schema.
   5. Public synonym is available to all users.
   6. Synonym simplifies object access.
   7. Synonym hides schema names.
   8. Synonym does not replace privileges.
   9. User still needs permission on the base object.
   10. If the base object is dropped, synonym becomes invalid.

   ========================================================= */