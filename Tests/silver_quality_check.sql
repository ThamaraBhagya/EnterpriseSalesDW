/*

Purpose:
    Validates the cleanliness of the Silver layer.
    Checks for NULLs, invalid numbers, and logical date errors.

*/

USE EnterpriseSalesDW;
GO

PRINT '================================================';
PRINT 'Running Silver Layer Quality Checks';
PRINT '================================================';

-- Check for NULLs in essential CRM columns
SELECT 'CRM Customers - NULL IDs' AS Check_Name, COUNT(*) AS Issue_Count 
FROM silver.crm_customers 
WHERE customer_id IS NULL;

-- Check for negative or zero sales in ERP
SELECT 'ERP Sales - Invalid Sales Amounts' AS Check_Name, COUNT(*) AS Issue_Count 
FROM silver.erp_sales 
WHERE sales <= 0 OR sales IS NULL;

--  Check for logical date errors (Order Date after Ship Date)
SELECT 'ERP Sales - Order After Ship Date' AS Check_Name, COUNT(*) AS Issue_Count 
FROM silver.erp_sales 
WHERE order_date > ship_date;