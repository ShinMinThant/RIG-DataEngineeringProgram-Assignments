SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'schoolmsdb';

SELECT
    kcu.CONSTRAINT_NAME AS foreign_key_name,
    kcu.TABLE_NAME AS child_table,
    kcu.COLUMN_NAME AS child_column,
    kcu.REFERENCED_TABLE_NAME AS parent_table,
    kcu.REFERENCED_COLUMN_NAME AS parent_column
FROM information_schema.KEY_COLUMN_USAGE kcu
WHERE kcu.REFERENCED_TABLE_NAME IS NOT NULL
  AND kcu.TABLE_SCHEMA = 'schoolmsdb'
ORDER BY child_table, foreign_key_name;
