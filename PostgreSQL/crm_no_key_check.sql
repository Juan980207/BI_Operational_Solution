-- SCHEMA: crm
SELECT account_owner_user_id
FROM crm.crm_accounts
WHERE account_owner_user_id IS NOT NULL AND account_owner_user_id NOT IN (
SELECT user_id FROM crm.crm_users);
------------
SELECT account_id
FROM crm.crm_contacts
WHERE account_id IS NOT NULL AND account_id NOT IN (
SELECT account_id FROM crm.crm_accounts);
------------
SELECT account_id
FROM crm.crm_opportunities
WHERE account_id IS NOT NULL AND account_id NOT IN (
SELECT account_id FROM crm.crm_accounts);
-------------
SELECT contact_id
FROM crm.crm_opportunities
WHERE contact_id IS NOT NULL AND contact_id NOT IN (
SELECT contact_id FROM crm.crm_contacts);
--------------
SELECT owner_user_id
FROM crm.crm_opportunities
WHERE owner_user_id IS NOT NULL AND owner_user_id NOT IN (
SELECT user_id FROM crm.crm_users);
---------------
SELECT contact_id
FROM crm.crm_activities
WHERE contact_id IS NOT NULL AND contact_id NOT IN (
SELECT contact_id FROM crm.crm_contacts);
----------------
SELECT opportunity_id
FROM crm.crm_activities
WHERE opportunity_id IS NOT NULL AND opportunity_id NOT IN (
SELECT opportunity_id FROM crm.crm_opportunities);
-----------------
SELECT creator_user_id
FROM crm.crm_activities
WHERE creator_user_id IS NOT NULL AND creator_user_id NOT IN (
SELECT user_id FROM crm.crm_users);
