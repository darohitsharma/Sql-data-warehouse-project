/*
Non-destructive development bootstrap. Review the instance and database name.
Creates missing objects only. Does not load data or complete the ETL.
Not execution-validated against SQL Server in this repository refresh.
*/
USE master;
GO
IF DB_ID(N'DataWarehouse') IS NULL
BEGIN
    EXEC(N'CREATE DATABASE [DataWarehouse]');
END;
GO
USE [DataWarehouse];
GO
IF SCHEMA_ID(N'bronze') IS NULL EXEC(N'CREATE SCHEMA [bronze]');
GO
IF SCHEMA_ID(N'silver') IS NULL EXEC(N'CREATE SCHEMA [silver]');
GO
IF SCHEMA_ID(N'gold') IS NULL EXEC(N'CREATE SCHEMA [gold]');
GO
