/*
Creates tables in the 'silver' schema. 
    Enforces correct data types (Dates, Numbers) for analytical querying.
*/

USE EnterpriseSalesDW;
GO

-- Create Silver CRM Table
IF OBJECT_ID('silver.crm_customers', 'U') IS NOT NULL
    DROP TABLE silver.crm_customers;

CREATE TABLE silver.crm_customers (
    customer_id NVARCHAR(50),
    customer_name NVARCHAR(100),
    segment NVARCHAR(50),
    country NVARCHAR(50),
    city NVARCHAR(50),
    state NVARCHAR(50),
    region NVARCHAR(50),
    dwh_create_date DATETIME DEFAULT GETDATE() 
);
GO

-- Create Silver ERP Table
IF OBJECT_ID('silver.erp_sales', 'U') IS NOT NULL
    DROP TABLE silver.erp_sales;

CREATE TABLE silver.erp_sales (
    order_id NVARCHAR(50),
    order_date DATE,           
    ship_date DATE,            
    ship_mode NVARCHAR(50),
    customer_id NVARCHAR(50),
    product_id NVARCHAR(50),
    category NVARCHAR(50),
    sub_category NVARCHAR(50),
    product_name NVARCHAR(MAX), 
    sales FLOAT,               
    quantity INT,              
    discount FLOAT,            
    profit FLOAT,              
    shipping_cost FLOAT,       
    dwh_create_date DATETIME DEFAULT GETDATE() 
);
GO