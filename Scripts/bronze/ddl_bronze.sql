
-- Create Bronze Tables

USE EnterpriseSalesDW;
GO


-- Create Bronze CRM Table

IF OBJECT_ID('bronze.crm_customers_raw', 'U') IS NOT NULL
    DROP TABLE bronze.crm_customers_raw;

CREATE TABLE bronze.crm_customers_raw (
    customer_id NVARCHAR(50),
    customer_name NVARCHAR(100),
    segment NVARCHAR(50),
    country NVARCHAR(50),
    city NVARCHAR(50),
    state NVARCHAR(50),
    region NVARCHAR(50)
);
GO

-- Create Bronze ERP Table

IF OBJECT_ID('bronze.erp_sales_raw', 'U') IS NOT NULL
    DROP TABLE bronze.erp_sales_raw;

CREATE TABLE bronze.erp_sales_raw (
    order_id NVARCHAR(50),
    order_date NVARCHAR(50),
    ship_date NVARCHAR(50),
    ship_mode NVARCHAR(50),
    customer_id NVARCHAR(50),
    product_id NVARCHAR(50),
    category NVARCHAR(50),
    sub_category NVARCHAR(50),
    product_name NVARCHAR(MAX), -- Set to MAX to prevent truncation errors!
    sales NVARCHAR(50),         -- Kept as string to prevent import crashes
    quantity NVARCHAR(50),
    discount NVARCHAR(50),
    profit NVARCHAR(50),        -- Kept as string to prevent NULLs
    shipping_cost NVARCHAR(50)
);
GO