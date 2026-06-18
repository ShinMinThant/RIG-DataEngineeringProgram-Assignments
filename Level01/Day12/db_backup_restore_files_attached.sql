-- service -stop
-- copy xx.mdf and yy.ldf file into another
-- xx.mdf and yy.ldf file - File Properties -> Allow Full Controll 
CREATE DATABASE ecommerce_db
ON
(FILENAME = 'C:\DE_Scholarship\ecommerce_db.mdf'),
(FILENAME = 'C:\DE_Scholarship\ecommerce_db_log.ldf')
FOR ATTACH;