/*
=====================================================================
Data Quality Checks: Silver Layer
=====================================================================
Purpose:
    Validates the cleanliness of the Silver layer.
    Checks for NULLs, invalid numbers, and logical date errors.
=====================================================================
*/

USE EnterpriseSalesDW;
GO

PRINT '================================================';
PRINT 'Running Silver Layer Quality Checks';
PRINT '================================================';

-- 1. Check for NULLs in essential CRM columns
-- Expected Result: 0
SELECT 'CRM Customers - NULL IDs' AS Check_Name, COUNT(*) AS Issue_Count 
FROM silver.crm_customers 
WHERE customer_id IS NULL;

-- 2. Check for negative or zero sales in ERP
-- Expected Result: 0 (Sales should always be positive)
SELECT 'ERP Sales - Invalid Sales Amounts' AS Check_Name, COUNT(*) AS Issue_Count 
FROM silver.erp_sales 
WHERE sales <= 0 OR sales IS NULL;

-- 3. Check for logical date errors (Order Date after Ship Date)
-- Expected Result: 0
SELECT 'ERP Sales - Order After Ship Date' AS Check_Name, COUNT(*) AS Issue_Count 
FROM silver.erp_sales 
WHERE order_date > ship_date;