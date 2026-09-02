/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure executes the ETL pipeline to load data into the Bronze 
    layer from external CSV files (CRM and ERP sources).
    
    Key Operations:
      - Truncates existing raw bronze tables.
      - Uses BULK INSERT to stage fresh data from source files.
      - Tracks and logs execution durations for individual tables and the overall batch.
      - Catches and reports runtime errors via TRY...CATCH.
===============================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
    BEGIN TRY -- A ROLLBACK with a TRANSACTION would be better in case the error happens at the end of the TRY as the code until then is still committed
        -- Time duration of loading bronze layer
        SET @batch_start_time = GETDATE();
        
        PRINT '===================================================================='
        PRINT 'Loading Bronze Layer'
        PRINT '===================================================================='

        PRINT '--------------------------------------------------------------------'
        PRINT 'Loading CRM Tables'
        PRINT '--------------------------------------------------------------------'

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_cust_info'
        TRUNCATE TABLE bronze.crm_cust_info;

        PRINT '>> Inserting Data Into Table: bronze.crm_cust_info'
        BULK INSERT bronze.crm_cust_info
        FROM 'C:\Users\refor\Desktop\SQL Course\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)+ ' seconds';
        PRINT '>> -----------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_prd_info'
        TRUNCATE TABLE bronze.crm_prd_info;

        PRINT '>> Inserting Data Into Table: bronze.crm_prd_info'
        BULK INSERT bronze.crm_prd_info
        FROM 'C:\Users\refor\Desktop\SQL Course\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)+ ' seconds';
        PRINT '>> -----------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_sales_details'
        TRUNCATE TABLE bronze.crm_sales_details;

        PRINT '>> Inserting Data Into Table: bronze.crm_sales_details'
        BULK INSERT bronze.crm_sales_details
        FROM 'C:\Users\refor\Desktop\SQL Course\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)+ ' seconds';
        PRINT '>> -----------------';

        PRINT '--------------------------------------------------------------------'
        PRINT 'Loading ERP Tables'
        PRINT '--------------------------------------------------------------------'

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_cust_az12'
        TRUNCATE TABLE bronze.erp_cust_az12;

        PRINT '>> Inserting Data Into Table: bronze.erp_cust_az12'
        BULK INSERT bronze.erp_cust_az12
        FROM 'C:\Users\refor\Desktop\SQL Course\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)+ ' seconds';
        PRINT '>> -----------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_loc_a101'
        TRUNCATE TABLE bronze.erp_loc_a101;

        PRINT '>> Inserting Data Into Table: bronze.erp_loc_a101'
        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\Users\refor\Desktop\SQL Course\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)+ ' seconds';
        PRINT '>> -----------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2'
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        PRINT '>> Inserting Data Into Table: bronze.erp_px_cat_g1v2'
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\Users\refor\Desktop\SQL Course\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)+ ' seconds';
        PRINT '>> -----------------';

        SET @batch_end_time = GETDATE();
        PRINT '===================================================================='
        PRINT 'Loading Bronze Layer is Completed';
        PRINT '       Total Bronze Layer Load Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '===================================================================='
    END TRY
    BEGIN CATCH
        PRINT '===================================================================='
        PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
        PRINT 'Error Message: '+ERROR_MESSAGE()
        PRINT 'Error Number: '+CAST(ERROR_NUMBER() AS NVARCHAR)
        PRINT 'Error State: '+CAST(ERROR_STATE() AS NVARCHAR)
        PRINT '===================================================================='
    END CATCH
END
