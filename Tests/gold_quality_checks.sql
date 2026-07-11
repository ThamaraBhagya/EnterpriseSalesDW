/*
Purpose:
    Validates the integrity of the Star Schema.
    Checks for duplicate keys (surrogate and natural) and orphaned foreign keys.
*/
USE EnterpriseSalesDW;
GO

PRINT '================================================';
PRINT 'Running Gold Layer Quality Checks';
PRINT '================================================';

-- Check 1: Uniqueness of surrogate Customer Keys in Dimension
SELECT 'Dim Customers - Duplicate customer_key' AS Check_Name, COUNT(*) AS Issue_Count
FROM (
    SELECT customer_key
    FROM gold.dim_customers
    GROUP BY customer_key
    HAVING COUNT(*) > 1
) dup;

-- Check 2: Uniqueness of surrogate Product Keys in Dimension
SELECT 'Dim Products - Duplicate product_key' AS Check_Name, COUNT(*) AS Issue_Count
FROM (
    SELECT product_key
    FROM gold.dim_products
    GROUP BY product_key
    HAVING COUNT(*) > 1
) dup;

-- Check 3: Uniqueness of NATURAL key (customer_id) in Dimension
-- Catches cases where the same real-world customer ended up with 2+ surrogate keys
SELECT 'Dim Customers - Duplicate customer_id' AS Check_Name, COUNT(*) AS Issue_Count
FROM (
    SELECT customer_id
    FROM gold.dim_customers
    GROUP BY customer_id
    HAVING COUNT(*) > 1
) dup;

-- Check 4: Uniqueness of NATURAL key (product_id) in Dimension
-- Catches cases where the same real-world product ended up with 2+ surrogate keys
SELECT 'Dim Products - Duplicate product_id' AS Check_Name, COUNT(*) AS Issue_Count
FROM (
    SELECT product_id
    FROM gold.dim_products
    GROUP BY product_id
    HAVING COUNT(*) > 1
) dup;

-- Check 5: Referential Integrity - sales with missing customer
SELECT 'Orphaned Sales - Missing Customer' AS Check_Name, COUNT(*) AS Issue_Count
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c 
    ON f.customer_key = c.customer_key
WHERE c.customer_key IS NULL;

-- Check 6: Referential Integrity - sales with missing product
SELECT 'Orphaned Sales - Missing Product' AS Check_Name, COUNT(*) AS Issue_Count
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p 
    ON f.product_key = p.product_key
WHERE p.product_key IS NULL;

PRINT '================================================';
PRINT 'Gold Layer Quality Checks Completed';
PRINT '================================================';
GO