/*
Create Database and Schemas
Purpose:
    This script creates a new database named 'EnterpriseSalesDW'.
    Sets up three schemas: 'bronze', 'silver', and 'gold'.
=============================================================
*/

USE master;
GO


IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'EnterpriseSalesDW')
BEGIN
    ALTER DATABASE EnterpriseSalesDW SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE EnterpriseSalesDW;
END;
GO


CREATE DATABASE EnterpriseSalesDW;
GO

USE EnterpriseSalesDW;
GO

-- Create the Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO