-- SCHEMA: ERP
-- DROP SCHEMA IF EXISTS "ERP" ;
CREATE SCHEMA IF NOT EXISTS erp
    AUTHORIZATION postgres;

COMMENT ON SCHEMA erp
    IS 'ERP source data';

--CREATE THE ERP_SUPPLIER TABLE
CREATE TABLE erp.erp_suppliers(
	supplier_id VARCHAR(8) PRIMARY KEY,
	supplier_name VARCHAR,
	contact_person VARCHAR,
	phone VARCHAR(10),
	email VARCHAR
);
--CREATE THE ERP_PRODUCTS TABLE
CREATE TABLE erp.erp_products(
	product_id VARCHAR(4) PRIMARY KEY,
	product_name VARCHAR,
	product_category VARCHAR,
	unit_price INTEGER,
	cost_price INTEGER,
	supplier_id VARCHAR(8),
	is_active VARCHAR(10)
--	FOREIGN KEY (supplier_id) REFERENCES erp.erp_suppliers(supplier_id)	
);
--CREATE THE INVENTORY TABLE
CREATE TABLE erp.erp_inventory(
	inventory_id VARCHAR(6) PRIMARY KEY,
	product_id VARCHAR(4),
	warehouse_location VARCHAR,
	current_stock INTEGER,
	last_update_date DATE
--	FOREIGN KEY (product_id) REFERENCES erp.erp_products(product_id)
);
--CREATE THE ORDERS TABLE
CREATE TABLE erp.erp_orders(
	order_id VARCHAR(6) PRIMARY KEY,
	custom_account_id VARCHAR(6),
	order_date DATE,
	total_amount INTEGER,
	order_status VARCHAR,
	sales_rep_user_id VARCHAR(6),
	shipping_city VARCHAR,
	shipping_state VARCHAR(2),
	shipping_country VARCHAR
--	FOREIGN KEY (custom_account_id) REFERENCES crm.crm_accounts(account_id),
--	FOREIGN KEY (sales_rep_user_id) REFERENCES crm.crm_users(user_id)
);
--CREATE THE ORDERLINESITEMS TABLE
CREATE TABLE erp.erp_orderlinesitems(
	order_line_item_id VARCHAR(6) PRIMARY KEY,
	order_id VARCHAR(6),
	product_id VARCHAR(4),
	quantity INTEGER,
	unit_price_at_sale INTEGER,
	line_total INTEGER
--	FOREIGN KEY (order_id) REFERENCES erp.erp_orders(order_id),
--	FOREIGN KEY (product_id) REFERENCES erp.erp_products(product_id)
);
--CREATE THE ERP INVOICE TABLE
CREATE TABLE erp.erp_invoices(
	invoice_id VARCHAR(6) PRIMARY KEY,
	order_id VARCHAR(6),
	invoice_date DATE,
	invoice_amount INTEGER,
	payment_status VARCHAR
--	FOREIGN KEY (order_id) REFERENCES erp.erp_orders(order_id)
);
--CREATE ERP SHIPMENTS TABLE 
CREATE TABLE erp.erp_shipments(
	shipments_id VARCHAR(7) PRIMARY KEY,
	order_id VARCHAR(6),
	invoice_id VARCHAR(6),
	shipments_date DATE,
	delivery_date DATE,
	shipping_carrier VARCHAR,
	tracking_number VARCHAR(14),
	shipment_status VARCHAR
--	FOREIGN KEY (order_id) REFERENCES erp.erp_orders(order_id)
);