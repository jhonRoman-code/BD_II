
USE master;
GO
IF EXISTS(SELECT * FROM sys.databases WHERE name = 'QhatuPERU')
    DROP DATABASE QhatuPERU;
GO
CREATE DATABASE QhatuPERU;
GO
----
use master
go
Create database QhatuPeru
on primary
	(name = QhatuPeru_Data,
	filename = 'D:\BaseDatos2024\QhatuPeru_Data.mdf',
	size = 5,
	maxsize = 20,
	filegrowth = 5)
log on
	(name = QhatuPeru_Log,
	filename = 'D:\BaseDatos2024\QhatuPeru_Log.ldf',
	size = 2,
	maxsize = 8,
	filegrowth = 2)
go