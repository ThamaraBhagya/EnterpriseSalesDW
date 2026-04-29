import pandas as pd


df = pd.read_csv('superstore.csv', encoding='latin1')

# Create the CRM Dataset 
crm_columns = [
    'Customer.ID', 
    'Customer.Name', 
    'Segment', 
    'Country', 
    'City', 
    'State', 
    'Region'
]
crm_df = df[crm_columns].drop_duplicates(subset=['Customer.ID'])

# Create the ERP Dataset 
erp_columns = [
    'Order.ID', 
    'Order.Date', 
    'Ship.Date', 
    'Ship.Mode', 
    'Customer.ID', 
    'Product.ID', 
    'Category', 
    'Sub.Category', 
    'Product.Name', 
    'Sales', 
    'Quantity', 
    'Discount', 
    'Profit', 
    'Shipping.Cost'
]
erp_df = df[erp_columns]

# Export to two separate CSV files
crm_df.to_csv('crm_customers_raw.csv', index=False)
erp_df.to_csv('erp_sales_raw.csv', index=False)

print(f"✅ Success! Created CRM with {len(crm_df)} unique customers and ERP with {len(erp_df)} transactions.")