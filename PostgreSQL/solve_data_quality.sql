--STARDARDIZE THE CASE SENSITIVE FILTER
UPDATE erp.erp_products SET product_category=UPPER(product_category);


--SET THE VARIABLE IS ACTIVE FROM PRODUCTS AS BOOLEAN
ALTER TABLE erp.erp_products ALTER COLUMN is_active
SET DATA TYPE BOOLEAN
USING (erp.erp_products.is_active='VERDADERO');
