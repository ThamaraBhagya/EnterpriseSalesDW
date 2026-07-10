USE EnterpriseSalesDW;
GO
CREATE OR ALTER PROCEDURE bronze.load_bronze
    @crm_file_path NVARCHAR(500) = 'C:\Users\DELL\Desktop\DS Projects\SQLDataWarehouse\datasets\crm_customers_raw.csv',
    @erp_file_path NVARCHAR(500) = 'C:\Users\DELL\Desktop\DS Projects\SQLDataWarehouse\datasets\erp_sales_raw.csv'
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @start_time DATETIME, @end_time DATETIME;
    DECLARE @sql NVARCHAR(MAX);

    BEGIN TRY
        BEGIN TRANSACTION;

        PRINT '================================================';
        PRINT 'Executing Load: Bronze Layer';
        PRINT '================================================';

        -- Load CRM Data
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_customers_raw';
        TRUNCATE TABLE bronze.crm_customers_raw;

        PRINT '>> Inserting Data: bronze.crm_customers_raw';
        SET @sql = N'BULK INSERT bronze.crm_customers_raw
            FROM ''' + @crm_file_path + N'''
            WITH (
                FORMAT = ''CSV'',
                FIELDQUOTE = ''"'',
                FIRSTROW = 2,
                FIELDTERMINATOR = '','',
                ROWTERMINATOR = ''\n'',
                TABLOCK
            );';
        EXEC sp_executesql @sql;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '------------------------------------------------';

        -- Load ERP Data
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_sales_raw';
        TRUNCATE TABLE bronze.erp_sales_raw;

        PRINT '>> Inserting Data: bronze.erp_sales_raw';
        SET @sql = N'BULK INSERT bronze.erp_sales_raw
            FROM ''' + @erp_file_path + N'''
            WITH (
                FORMAT = ''CSV'',
                FIELDQUOTE = ''"'',
                FIRSTROW = 2,
                FIELDTERMINATOR = '','',
                ROWTERMINATOR = ''\n'',
                TABLOCK
            );';
        EXEC sp_executesql @sql;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        COMMIT TRANSACTION;

        PRINT '================================================';
        PRINT 'Bronze Layer Load Completed Successfully!';
        PRINT '================================================';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        PRINT '================================================';
        PRINT 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Both tables rolled back to previous state.';
        PRINT '================================================';
    END CATCH
END;
GO