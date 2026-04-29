USE EnterpriseSalesDW;
GO

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME;
    
    BEGIN TRY
        PRINT '================================================';
        PRINT 'Executing Load: Bronze Layer';
        PRINT '================================================';

        -- Load CRM Data
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_customers_raw';
        TRUNCATE TABLE bronze.crm_customers_raw;

        PRINT '>> Inserting Data: bronze.crm_customers_raw';
        BULK INSERT bronze.crm_customers_raw
        -
        FROM 'C:\Users\DELL\Desktop\DS Projects\SQLDataWarehouse\datasets\crm_customers_raw.csv'
        WITH (
            FORMAT = 'CSV',        
            FIELDQUOTE = '"',      
            FIRSTROW = 2, 
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '------------------------------------------------';

        -- Load ERP Data
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_sales_raw';
        TRUNCATE TABLE bronze.erp_sales_raw;

        PRINT '>> Inserting Data: bronze.erp_sales_raw';
        BULK INSERT bronze.erp_sales_raw
        
        FROM 'C:\Users\DELL\Desktop\DS Projects\SQLDataWarehouse\datasets\erp_sales_raw.csv'
        WITH (
            FORMAT = 'CSV',        -
            FIELDQUOTE = '"',      
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '================================================';
        PRINT 'Bronze Layer Load Completed Successfully!';

    END TRY
    BEGIN CATCH
        PRINT '================================================';
        PRINT 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT '================================================';
    END CATCH
END;
GO