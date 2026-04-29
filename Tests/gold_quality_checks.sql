/*
Purpose:
    Validates the integrity of the Star Schema.
    Checks for duplicate keys and orphaned foreign keys.

*/

USE EnterpriseSalesDW;
GO

PRINT '================================================';
PRINT 'Running Gold Layer Quality Checks';
PRINT '================================================';

--Check uniqueness of Customer Keys in Dimension
SELECT customer_key, COUNT(*) AS Duplicate_Count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- Check uniqueness of Product Keys in Dimension
SELECT product_key, COUNT(*) AS Duplicate_Count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- referential Integrity: Are there sales with missing customers?
SELECT 'Orphaned Sales - Missing Customer' AS Check_Name, COUNT(*) AS Issue_Count
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c 
    ON f.customer_key = c.customer_key
WHERE c.customer_key IS NULL;

-- Referential Integrity: Are there sales with missing products?
SELECT 'Orphaned Sales - Missing Product' AS Check_Name, COUNT(*) AS Issue_Count
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p 
    ON f.product_key = p.product_key
WHERE p.product_key IS NULL;