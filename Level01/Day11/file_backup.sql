Create database ecommerce_db
ON
(
	FILENAME = '(C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\Backup\ecommerce_db_log.ldf)',
	FILENAME = '(C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\Backup\ecommerce_db.mdf)'
)
for attach;