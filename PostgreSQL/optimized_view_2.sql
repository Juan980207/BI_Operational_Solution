WITH won_accounts AS (
    SELECT DISTINCT account_id
    FROM crm.crm_opportunities
    WHERE stage = 'Closed Won'
)
SELECT 
    o.order_id,
    ca.account_name,
    o.total_amount,
    ca.billing_city,
    ca.billing_country
FROM erp.erp_orders o
JOIN won_accounts wa ON o.custom_account_id = wa.account_id
JOIN crm.crm_accounts ca ON ca.account_id = o.custom_account_id
ORDER BY o.total_amount DESC;