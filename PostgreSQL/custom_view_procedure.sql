CREATE OR REPLACE FUNCTION crm.crm_erp_view_update()
RETURNS void AS $$
BEGIN
----- DELETE IF EXISTS
    IF EXISTS (
        SELECT 1 FROM information_schema.views 
        WHERE table_schema = 'crm' AND table_name = 'crm_erp_view'
    ) THEN
        EXECUTE 'DROP VIEW crm.crm_erp_view';
    END IF;

-- USE CTE
    EXECUTE '
        CREATE VIEW crm.crm_erp_view AS
        WITH orders AS (
            SELECT 
                o.order_id,
                o.custom_account_id,
                o.order_date,
                SUM(o.total_amount) AS total_amount,
                ol.product_id,
                p.product_name,
                p.product_category,
                AVG(p.unit_price) AS unit_price,
                AVG(p.cost_price) AS cost_price,
                o.order_status,
                o.shipping_state,
				SUM(ol.quantity) AS total_quantity
            FROM erp.erp_orders o
            LEFT JOIN erp.erp_orderlinesitems ol ON o.order_id = ol.order_id
            LEFT JOIN erp.erp_products p ON ol.product_id = p.product_id
			GROUP BY o.order_id,
			o.custom_account_id,
			o.order_date,
			ol.product_id,
			p.product_name,
			p.product_category,
			o.order_status,
			o.shipping_state
			),
        customer AS (
            SELECT 
                account_id,
                CONCAT(first_name, '' '', last_name) AS full_name,
                title
            FROM crm.crm_contacts
        ),
        accounts AS (
            SELECT DISTINCT 
                ac.account_id,
                ac.account_name,
                UPPER(ac.industry) AS sector,
                FIRST_VALUE(act.activity_type) OVER (
                    PARTITION BY ac.account_name, UPPER(ac.industry)
                    ORDER BY act.activity_date ASC
                ) AS contact_point
            FROM crm.crm_accounts ac
            LEFT JOIN crm.crm_opportunities op ON ac.account_id = op.account_id
            LEFT JOIN crm.crm_activities act ON op.contact_id = act.contact_id
        )
        SELECT 
		DISTINCT
			o.order_id,
			a.account_name AS name,
            a.sector AS segment,
            a.contact_point AS acquisition_channel,
            o.product_name,
            o.product_category,
            AVG(o.unit_price) AS unit_price,
            AVG(o.cost_price) AS cost_price,
            o.order_date,
            SUM(o.total_amount) AS total_amount,
            o.order_status,
            o.shipping_state AS shipping_region,
            c.full_name AS representative,
            c.title AS role,
			SUM(o.total_quantity) AS total_quantity
        FROM orders o
        JOIN accounts a ON o.custom_account_id = a.account_id
        JOIN customer c ON a.account_id = c.account_id
		GROUP BY o.order_id,
		a.account_name,
		a.sector,
		a.contact_point,
		o.product_name,
		a.contact_point,
		o.product_name,
		o.product_category,
		o.order_date,
		o.shipping_state,
		c.full_name,
		c.title,
		o.order_status,
		o.total_quantity;
    ';
END;
$$ LANGUAGE plpgsql;