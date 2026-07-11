/*

Purpose:
    Creates virtual views for the Gold layer (Star Schema).
    Transforms and combines Silver data into Dimensions and Facts.

*/

USE EnterpriseSalesDW;
GO

-- Create Dimension: Customers
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT 
    
    ROW_NUMBER() OVER (ORDER BY customer_id) AS customer_key, 
    customer_id,
    customer_name,
    segment,
    country,
    city,
    state,
    region
FROM silver.crm_customers;
GO

-- Create Dimension: Products
-- We extract unique products directly from the sales data
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY product_id) AS product_key,
    product_id,
    product_name,
    category,
    sub_category
FROM (
    SELECT 
        product_id, product_name, category, sub_category,
        ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY product_name) AS rn
    FROM silver.erp_sales
) AS deduped
WHERE rn = 1;
GO

-- Create Fact: Sales
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT 
    s.order_id,
    s.order_date,
    s.ship_date,
    s.ship_mode,
    c.customer_key,     
    p.product_key,      
    s.sales,
    s.quantity,
    s.discount,
    s.profit,
    s.shipping_cost
FROM silver.erp_sales s


LEFT JOIN gold.dim_customers c 
    ON s.customer_id = c.customer_id
LEFT JOIN gold.dim_products p 
    ON s.product_id = p.product_id;
GO