-- SCHEMA: crm
-- DELETE INCONCISTENT ACCOUNT
DELETE FROM crm.crm_contacts
WHERE crm.crm_contacts.account_id='ACCXXX';

--ACCOUNTS
ALTER TABLE crm.crm_accounts
ADD CONSTRAINT accounts_users
FOREIGN KEY (account_owner_user_id) REFERENCES crm.crm_users(user_id)
ON DELETE CASCADE;
--CONTACTS
ALTER TABLE crm.crm_contacts
ADD CONSTRAINT contacts_accounts
FOREIGN KEY (account_id) REFERENCES crm.crm_accounts(account_id)
ON DELETE CASCADE;
--OPPORTUNITIES
ALTER TABLE crm.crm_opportunities
ADD CONSTRAINT opportunities_accounts
FOREIGN KEY (account_id) REFERENCES crm.crm_accounts(account_id)
ON DELETE CASCADE;

ALTER TABLE crm.crm_opportunities
ADD CONSTRAINT opportunities_contacts
FOREIGN KEY (contact_id) REFERENCES crm.crm_contacts(contact_id)
ON DELETE CASCADE;

ALTER TABLE crm.crm_opportunities
ADD CONSTRAINT opportunities_users
FOREIGN KEY (owner_user_id) REFERENCES crm.crm_users(user_id)
ON DELETE CASCADE;
--ACTVITIES
ALTER TABLE crm.crm_activities
ADD CONSTRAINT activities_contacts
FOREIGN KEY (contact_id) REFERENCES crm.crm_contacts(contact_id)
ON DELETE CASCADE;

ALTER TABLE crm.crm_activities
ADD CONSTRAINT activities_opportunity
FOREIGN KEY (opportunity_id) REFERENCES crm.crm_opportunities(opportunity_id)
ON DELETE CASCADE;

ALTER TABLE crm.crm_activities
ADD CONSTRAINT activities_users
FOREIGN KEY (creator_user_id) REFERENCES crm.crm_users(user_id)
ON DELETE CASCADE;