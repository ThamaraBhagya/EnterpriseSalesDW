/*
Performs the ETL to populate the 'silver' schema from the 'bronze' schema.
    - Truncates Silver tables.
    - Cleanses data and uses TRY_CAST for safe data type conversion.

*/

USE EnterpriseSalesDW;
GO

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME;
    
    BEGIN TRY
        PRINT '================================================';
        PRINT 'Executing Load: Silver Layer';
        PRINT '================================================';

        --Transform & Load CRM Data
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.crm_customers';
        TRUNCATE TABLE silver.crm_customers;

        PRINT '>> Inserting Data: silver.crm_customers';
        INSERT INTO silver.crm_customers (
            customer_id, customer_name, segment, country, city, state, region
        )
        SELECT 
            TRIM(customer_id), 
            TRIM(customer_name), 
            TRIM(segment), 
            TRIM(country), 
            TRIM(city), 
            TRIM(state), 
            TRIM(region)
        FROM bronze.crm_customers_raw
        WHERE customer_id IS NOT NULL; 

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '------------------------------------------------';

        -- Transform & Load ERP Data
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.erp_sales';
        TRUNCATE TABLE silver.erp_sales;

        PRINT '>> Inserting Data: silver.erp_sales';
        INSERT INTO silver.erp_sales (
            order_id, order_date, ship_date, ship_mode, customer_id, product_id, 
            category, sub_category, product_name, sales, quantity, discount, profit, shipping_cost
        )
        SELECT 
            TRIM(order_id),
            TRY_CAST(order_date AS DATE), 
            TRIM(ship_mode),
            TRIM(customer_id),
            TRIM(product_id),
            TRIM(category),
            TRIM(sub_category),
            TRIM(product_name),
            TRY_CAST(sales AS FLOAT),     
            TRY_CAST(quantity AS INT),    
            TRY_CAST(discount AS FLOAT),
            TRY_CAST(profit AS FLOAT),
            TRY_CAST(shipping_cost AS FLOAT)
        FROM bronze.erp_sales_raw
        WHERE order_id IS NOT NULL;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '================================================';
        PRINT 'Silver Layer Load Completed Successfully!';

    END TRY
    BEGIN CATCH
        PRINT '================================================';
        PRINT 'ERROR OCCURRED DURING LOADING SILVER LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT '================================================';
    END CATCH
END;
GO