USE EnterpriseSalesDW;
GO
CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @start_time DATETIME, @end_time DATETIME;

    BEGIN TRY
        BEGIN TRANSACTION;

        PRINT '================================================';
        PRINT 'Executing Load: Silver Layer';
        PRINT '================================================';

        -- Transform & Load CRM Data
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

        ;WITH erp_deduped AS (
            SELECT
                order_id, order_date, ship_date, ship_mode, customer_id, product_id,
                category, sub_category, product_name, sales, quantity, discount, profit, shipping_cost,
                ROW_NUMBER() OVER (
                    PARTITION BY order_id, product_id, order_date, ship_date, ship_mode,
                                 customer_id, category, sub_category, product_name,
                                 sales, quantity, discount, profit, shipping_cost
                    ORDER BY (SELECT NULL)
                ) AS row_num
            FROM bronze.erp_sales_raw
            WHERE order_id IS NOT NULL
              AND TRY_CAST(sales AS FLOAT) > 0
        )
        INSERT INTO silver.erp_sales (
            order_id, order_date, ship_date, ship_mode, customer_id, product_id, 
            category, sub_category, product_name, sales, quantity, discount, profit, shipping_cost
        )
        SELECT 
            TRIM(order_id),
            TRY_CAST(order_date AS DATE), 
            TRY_CAST(ship_date AS DATE),   
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
        FROM erp_deduped
        WHERE row_num = 1;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        COMMIT TRANSACTION;

        PRINT '================================================';
        PRINT 'Silver Layer Load Completed Successfully!';
        PRINT '================================================';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        PRINT '================================================';
        PRINT 'ERROR OCCURRED DURING LOADING SILVER LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Both tables rolled back to previous state.';
        PRINT '================================================';
    END CATCH
END;
GO