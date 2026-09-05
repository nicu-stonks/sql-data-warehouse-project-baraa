/*
===============================================================================
Stored Procedure: silver.load_silver
===============================================================================
Script Purpose:
    Performs the ETL load from the Bronze layer to the Silver layer.
    For each target table in the Silver schema (CRM and ERP), this procedure:
      - Truncates existing destination data.
      - Transforms, cleanses, and deduplicates source data from Bronze tables.
      - Inserts the normalized records into Silver tables.
      - Logs progress, individual step durations, and total batch run time.
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		-- Time duration of loading silver layer
        SET @batch_start_time = GETDATE();
        
        PRINT '===================================================================='
        PRINT 'Loading Silver Layer'
        PRINT '===================================================================='

        PRINT '--------------------------------------------------------------------'
        PRINT 'Loading CRM Tables'
        PRINT '--------------------------------------------------------------------'

        -- silver.crm_cust_info
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info;
		PRINT '>> Inserting Data Into: silver.crm_cust_info';
		INSERT INTO silver.crm_cust_info (
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date
		)
		SELECT
			cst_id,
			cst_key,
			TRIM(cst_firstname) AS cst_firstname,
			TRIM(cst_lastname) AS cst_lastname,
			CASE WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
				 WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
				 ELSE 'n/a'
			END AS cst_marital_status, -- Normalize marital status to a readable format
			CASE WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
				 WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
				 ELSE 'n/a'
			END AS cst_gndr, -- Normalize gender values to a readable format
			cst_create_date
		FROM (
			SELECT
				*,
				ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
			FROM bronze.crm_cust_info
			WHERE cst_id IS NOT NULL
		) t
		WHERE flag_last = 1; -- Select the most recent record per customer
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -----------------';

		-- silver.crm_prd_info
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info;
		PRINT '>> Inserting Data Into: silver.crm_prd_info';
		INSERT INTO silver.crm_prd_info (
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		SELECT
			prd_id,
			REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, -- Extract category ID
			SUBSTRING(prd_key, 7) AS prd_key,                       -- Extract product key
			prd_nm,
			COALESCE(prd_cost, 0) AS prd_cost,
			CASE WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
				 WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Robot'
				 WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'other Sales'
				 WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
				 ELSE 'n/a' -- Map product line codes to descriptive values
			END AS prd_line,
			CAST(prd_start_dt AS DATE) AS prd_start_dt,
			CAST(
				DATEADD(day, -1, LEAD(prd_start_dt, 1) OVER(PARTITION BY prd_key ORDER BY prd_start_dt ASC))
				AS DATE
			) AS prd_end_dt -- Calculate end date as one day before the next start date
		FROM bronze.crm_prd_info;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -----------------';

		-- silver.crm_sales_details
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details;
		PRINT '>> Inserting Data Into: silver.crm_sales_details';
		INSERT INTO silver.crm_sales_details (
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)
		SELECT
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
				 ELSE CAST(CAST(sls_order_dt AS NVARCHAR) AS DATE)
			END AS sls_order_dt,
			CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
				 ELSE CAST(CAST(sls_ship_dt AS NVARCHAR) AS DATE)
			END AS sls_ship_dt,
			CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
				 ELSE CAST(CAST(sls_due_dt AS NVARCHAR) AS DATE)
			END AS sls_due_dt,
			CASE WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales != sls_quantity * ABS(sls_price) THEN ABS(sls_price) * sls_quantity
				 ELSE sls_sales
			END AS sls_sales, -- Recalculate sales if original value is missing or incorrect
			sls_quantity,
			CASE WHEN sls_price <= 0 OR sls_price IS NULL THEN sls_sales / NULLIF(sls_quantity, 0)
				 ELSE sls_price 
			END AS sls_price -- Derive price if original value is invalid
		FROM bronze.crm_sales_details;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -----------------';

        PRINT '--------------------------------------------------------------------'
        PRINT 'Loading ERP Tables'
        PRINT '--------------------------------------------------------------------'

		-- silver.erp_cust_az12
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12;
		PRINT '>> Inserting Data Into: silver.erp_cust_az12';
		INSERT INTO silver.erp_cust_az12 (
			cid,
			bdate,
			gen
		)
		SELECT
			CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4)
				 ELSE cid
			END AS cid,
			CASE WHEN bdate > GETDATE() THEN NULL
				 ELSE bdate
			END AS bdate,
			CASE WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
				 WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
				 ELSE 'n/a'
			END AS gen
		FROM bronze.erp_cust_az12;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -----------------';

		-- silver.erp_loc_a101
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_loc_a101';
		TRUNCATE TABLE silver.erp_loc_a101;
		PRINT '>> Inserting Data Into: silver.erp_loc_a101';
		INSERT INTO silver.erp_loc_a101 (
			cid,
			cntry
		)
		SELECT
			REPLACE(cid, '-', '') AS cid,
			CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
				 WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
				 WHEN cntry IS NULL OR TRIM(cntry) = '' THEN 'n/a'
				 ELSE TRIM(cntry)
			END AS cntry -- Normalize and Handle missing or blank country codes
		FROM bronze.erp_loc_a101;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -----------------';

		-- silver.erp_px_cat_g1v2
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';
		TRUNCATE TABLE silver.erp_px_cat_g1v2;
		PRINT '>> Inserting Data Into: silver.erp_px_cat_g1v2';
		INSERT INTO silver.erp_px_cat_g1v2 (
			id,
			cat,
			subcat,
			maintenance
		)
		SELECT
			id,
			cat,
			subcat,
			maintenance
		FROM bronze.erp_px_cat_g1v2;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -----------------';

        SET @batch_end_time = GETDATE();
        PRINT '===================================================================='
        PRINT 'Loading Silver Layer is Completed';
        PRINT '       Total Silver Layer Load Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '===================================================================='
	END TRY
	BEGIN CATCH
		PRINT '===================================================================='
        PRINT 'ERROR OCCURED DURING LOADING SILVER LAYER'
        PRINT 'Error Message: ' + ERROR_MESSAGE()
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR)
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR)
        PRINT '===================================================================='
	END CATCH
END;
