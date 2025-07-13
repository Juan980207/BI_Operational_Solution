-----SET ALL THE RELATIONSHIPS BETWEEN TABLES
--------------
ALTER TABLE erp.erp_products
ADD CONSTRAINT products_suppliers
FOREIGN KEY (supplier_id) REFERENCES erp.erp_suppliers(supplier_id)
ON DELETE CASCADE;
--------------
ALTER TABLE erp.erp_inventory
ADD CONSTRAINT inventory_product
FOREIGN KEY (product_id) REFERENCES erp.erp_products(product_id)
ON DELETE CASCADE;
----------------
ALTER TABLE erp.erp_orders
ADD CONSTRAINT orders_accounts
FOREIGN KEY (custom_account_id) REFERENCES crm.crm_accounts(account_id)
ON DELETE CASCADE;

ALTER TABLE erp.erp_orders
ADD CONSTRAINT orders_users
FOREIGN KEY (sales_rep_user_id) REFERENCES crm.crm_users(user_id)
ON DELETE CASCADE;
-----------------
ALTER TABLE erp.erp_orderlinesitems
ADD CONSTRAINT orderlinesitems_order
FOREIGN KEY (order_id) REFERENCES erp.erp_orders(order_id)
ON DELETE CASCADE;

ALTER TABLE erp.erp_orderlinesitems
ADD CONSTRAINT orderlinesitems_product
FOREIGN KEY (product_id) REFERENCES erp.erp_products(product_id)
ON DELETE CASCADE;
---------------
ALTER TABLE erp.erp_invoices
ADD CONSTRAINT invoices_orders
FOREIGN KEY (order_id) REFERENCES erp.erp_orders(order_id)
ON DELETE CASCADE;
---------------
ALTER TABLE erp.erp_shipments
ADD CONSTRAINT shipments_orders
FOREIGN KEY (order_id) REFERENCES erp.erp_orders(order_id)
ON DELETE CASCADE;