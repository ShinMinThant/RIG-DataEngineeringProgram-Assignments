Below is a **complete Oracle Index example script** with tables, sample data, indexes, and testing queries.

```sql
/* =========================================================
   ORACLE INDEX COMPLETE PRACTICE SCRIPT
   Scenario: Telecom Subscriber & Call Detail Records
   ========================================================= */

/* =========================================================
   1. CLEAN OLD OBJECTS
   ========================================================= */

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE call_records CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE subscribers CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

/* =========================================================
   2. CREATE TABLES
   ========================================================= */

CREATE TABLE subscribers
(
    subscriber_id   NUMBER PRIMARY KEY,
    msisdn          VARCHAR2(20) NOT NULL,
    customer_name   VARCHAR2(100),
    nrc_no          VARCHAR2(50),
    city            VARCHAR2(50),
    status          VARCHAR2(20),
    activation_date DATE
);

CREATE TABLE call_records
(
    call_id        NUMBER PRIMARY KEY,
    subscriber_id  NUMBER,
    called_number  VARCHAR2(20),
    call_type      VARCHAR2(20),
    call_start     DATE,
    duration_sec   NUMBER,
    charge_amount  NUMBER(10,2),

    CONSTRAINT fk_call_subscriber
    FOREIGN KEY (subscriber_id)
    REFERENCES subscribers(subscriber_id)
);

/* =========================================================
   3. INSERT SAMPLE DATA
   ========================================================= */

INSERT INTO subscribers VALUES
(1, '959400000001', 'Aung Aung', '12/ABC(N)123456', 'Yangon', 'ACTIVE', DATE '2023-01-10');

INSERT INTO subscribers VALUES
(2, '959400000002', 'Mg Mg', '12/DEF(N)234567', 'Mandalay', 'ACTIVE', DATE '2023-02-15');

INSERT INTO subscribers VALUES
(3, '959400000003', 'Hla Hla', '12/GHI(N)345678', 'Naypyitaw', 'INACTIVE', DATE '2023-03-20');

INSERT INTO subscribers VALUES
(4, '959400000004', 'Su Su', '12/JKL(N)456789', 'Yangon', 'ACTIVE', DATE '2023-04-25');

INSERT INTO subscribers VALUES
(5, '959400000005', 'Kyaw Kyaw', '12/MNO(N)567890', 'Bago', 'SUSPENDED', DATE '2023-05-30');

INSERT INTO call_records VALUES
(101, 1, '959500000001', 'VOICE', DATE '2024-01-01', 120, 150.00);

INSERT INTO call_records VALUES
(102, 1, '959500000002', 'VOICE', DATE '2024-01-02', 300, 350.00);

INSERT INTO call_records VALUES
(103, 2, '959500000003', 'SMS', DATE '2024-01-03', 0, 15.00);

INSERT INTO call_records VALUES
(104, 3, '959500000004', 'DATA', DATE '2024-01-04', 600, 500.00);

INSERT INTO call_records VALUES
(105, 4, '959500000005', 'VOICE', DATE '2024-01-05', 180, 200.00);

INSERT INTO call_records VALUES
(106, 4, '959500000006', 'SMS', DATE '2024-01-06', 0, 15.00);

INSERT INTO call_records VALUES
(107, 5, '959500000007', 'DATA', DATE '2024-01-07', 900, 800.00);

COMMIT;

/* =========================================================
   4. BASIC TEST BEFORE INDEX
   ========================================================= */

SELECT *
FROM subscribers
WHERE msisdn = '959400000004';

SELECT *
FROM subscribers
WHERE city = 'Yangon';

SELECT *
FROM call_records
WHERE subscriber_id = 4;

SELECT *
FROM call_records
WHERE call_start BETWEEN DATE '2024-01-01' AND DATE '2024-01-05';

/* =========================================================
   5. CREATE INDEXES
   ========================================================= */

/* Unique index for phone number lookup */
CREATE UNIQUE INDEX idx_subscribers_msisdn
ON subscribers(msisdn);

/* Normal B-tree index for city search */
CREATE INDEX idx_subscribers_city
ON subscribers(city);

/* Composite index for city and status search */
CREATE INDEX idx_subscribers_city_status
ON subscribers(city, status);

/* Foreign key index for faster join */
CREATE INDEX idx_call_records_subscriber_id
ON call_records(subscriber_id);

/* Date index for call date filtering */
CREATE INDEX idx_call_records_call_start
ON call_records(call_start);

/* Composite index for reporting */
CREATE INDEX idx_call_records_type_date
ON call_records(call_type, call_start);

/* Function-based index for case-insensitive search */
CREATE INDEX idx_subscribers_upper_name
ON subscribers(UPPER(customer_name));

/* =========================================================
   6. TEST AFTER INDEX
   ========================================================= */

/* Test 1: Unique index usage */
SELECT *
FROM subscribers
WHERE msisdn = '959400000004';

/* Test 2: City index usage */
SELECT *
FROM subscribers
WHERE city = 'Yangon';

/* Test 3: Composite index usage */
SELECT *
FROM subscribers
WHERE city = 'Yangon'
AND status = 'ACTIVE';

/* Test 4: Foreign key index usage */
SELECT s.customer_name,
       s.msisdn,
       c.call_type,
       c.duration_sec,
       c.charge_amount
FROM subscribers s
JOIN call_records c
ON s.subscriber_id = c.subscriber_id
WHERE c.subscriber_id = 4;

/* Test 5: Date index usage */
SELECT *
FROM call_records
WHERE call_start BETWEEN DATE '2024-01-01' AND DATE '2024-01-05';

/* Test 6: Composite reporting index */
SELECT *
FROM call_records
WHERE call_type = 'VOICE'
AND call_start >= DATE '2024-01-01';

/* Test 7: Function-based index */
SELECT *
FROM subscribers
WHERE UPPER(customer_name) = 'SU SU';

/* =========================================================
   7. CHECK EXECUTION PLAN
   ========================================================= */

EXPLAIN PLAN FOR
SELECT *
FROM subscribers
WHERE msisdn = '959400000004';

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);

EXPLAIN PLAN FOR
SELECT *
FROM subscribers
WHERE city = 'Yangon'
AND status = 'ACTIVE';

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);

EXPLAIN PLAN FOR
SELECT *
FROM call_records
WHERE call_type = 'VOICE'
AND call_start >= DATE '2024-01-01';

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);

/* =========================================================
   8. VIEW ALL INDEXES
   ========================================================= */

SELECT index_name,
       table_name,
       uniqueness,
       status
FROM user_indexes
WHERE table_name IN ('SUBSCRIBERS', 'CALL_RECORDS')
ORDER BY table_name, index_name;

/* =========================================================
   9. VIEW INDEX COLUMNS
   ========================================================= */

SELECT index_name,
       table_name,
       column_name,
       column_position
FROM user_ind_columns
WHERE table_name IN ('SUBSCRIBERS', 'CALL_RECORDS')
ORDER BY index_name, column_position;

/* =========================================================
   10. INDEX MONITORING
   ========================================================= */

ALTER INDEX idx_subscribers_msisdn MONITORING USAGE;

SELECT *
FROM subscribers
WHERE msisdn = '959400000004';

SELECT *
FROM v$object_usage
WHERE index_name = 'IDX_SUBSCRIBERS_MSISDN';

/* Stop monitoring */
ALTER INDEX idx_subscribers_msisdn NOMONITORING USAGE;

/* =========================================================
   11. REBUILD INDEX
   ========================================================= */

ALTER INDEX idx_subscribers_msisdn REBUILD;

/* =========================================================
   12. DROP INDEX EXAMPLE
   ========================================================= */

-- DROP INDEX idx_subscribers_city;

/* =========================================================
   13. IMPORTANT NOTES
   =========================================================

   1. Primary key automatically creates an index.
   2. Unique index prevents duplicate values.
   3. Foreign key columns should usually be indexed.
   4. Indexes improve SELECT performance.
   5. Too many indexes slow down INSERT, UPDATE, DELETE.
   6. Composite index column order is important.
   7. Function-based index works only when query uses same function.
   8. Low-cardinality columns like STATUS may not always benefit from normal index.
   9. Always check execution plan.
   10. Indexes are best for large tables, not very small tables.

   ========================================================= */
```

This script is ready to run in **Oracle SQL Developer / SQL*Plus**.
