/*
===============================================================================
Database Initialization: DataWarehouse (Medallion Architecture)
===============================================================================
Description:
  Drops any existing 'DataWarehouse' database, creates a fresh instance, 
  and sets up the 'bronze', 'silver', and 'gold' schemas for layered data processing.

WARNING:
  - PERMANENT DATA LOSS: Drops the existing database and all contained data.
  - FORCED DISCONNECT: Kills active user sessions and rolls back transactions.
  - DO NOT RUN IN PRODUCTION: Intended for development and testing setup only.
===============================================================================
*/

USE master;
GO

-- Drop and recreate the 'DataWarehouse' database
IF EXISTS (
	SELECT 1
	FROM sys.databases
	WHERE name = 'DataWarehouse'
)
BEGIN
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse;
END;
GO

-- Create the 'DataWarehouse' database
CREATE DATABASE DataWarehouse;
GO
USE DataWarehouse;
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
