-- SCHEMA: erp
SELECT supplier_id
FROM erp.erp_products
WHERE supplier_id IS NOT NULL AND supplier_id NOT IN (
SELECT supplier_id FROM erp.erp_suppliers);
-------------------
SELECT product_id
FROM erp.erp_inventory
WHERE product_id IS NOT NULL AND product_id NOT IN (
SELECT product_id FROM erp.erp_products);
-------------------
SELECT custom_account_id
FROM erp.erp_orders
WHERE custom_account_id IS NOT NULL AND custom_account_id NOT IN (
SELECT account_id FROM crm.crm_accounts);
-------------------
SELECT sales_rep_user_id
FROM erp.erp_orders
WHERE sales_rep_user_id IS NOT NULL AND sales_rep_user_id NOT IN (
SELECT user_id FROM crm.crm_users);
--------------------
SELECT order_id
FROM erp.erp_orderlinesitems
WHERE order_id IS NOT NULL AND order_id NOT IN (
SELECT order_id FROM erp.erp_orders);
---------------------
SELECT product_id
FROM erp.erp_orderlinesitems
WHERE product_id IS NOT NULL AND product_id NOT IN (
SELECT product_id FROM erp.erp_products);
----------------------
SELECT order_id
FROM erp.erp_invoices
WHERE order_id IS NOT NULL
  AND order_id NOT IN (
    SELECT order_id FROM erp.erp_orders
);
----------------------
SELECT order_id
FROM erp.erp_shipments
WHERE order_id IS NOT NULL
  AND order_id NOT IN (
    SELECT order_id FROM erp.erp_orders
);
----------------------
-- DROP INCONCISTENT VALUES;
DELETE FROM erp.erp_suppliers
WHERE supplier_id='SUP999';
-- DROP INCONCISTENT VALUES PRODUCTS
DELETE FROM erp.erp_inventory
WHERE product_id='P999';
---- DELETE ORDER WITH NO INFORMATION
DELETE FROM erp.erp_orders
WHERE custom_account_id='ACCXXX';
DELETE FROM erp.erp_shipments
WHERE order_id='ORD024';
DELETE FROM erp.erp_invoices
WHERE order_id='ORDXXX';
----- DELETE PRODUCT THAT IS NOT ACTIVE
DELETE FROM erp.erp_products
WHERE is_active='FALSO';
DELETE FROM erp.erp_orderlinesitems
WHERE product_id='P500';
------ DELETE NO ORDER_ID
DELETE FROM erp.erp_orderlinesitems
WHERE order_id='ORDXXX';
--------------------------------------
