-- SCHEMA: CRM
-- DROP SCHEMA IF EXISTS "CRM" ;
CREATE SCHEMA IF NOT EXISTS crm
    AUTHORIZATION postgres;

COMMENT ON SCHEMA crm
    IS 'CRM source data.';
--CREATE CRM USERS TABLE
CREATE TABLE crm.crm_users(
	user_id VARCHAR(6) PRIMARY KEY,
	username VARCHAR,
	full_name VARCHAR,
	role VARCHAR,
	start_date DATE
);
--CREATE CRM ACCOUNT TABLE
CREATE TABLE crm.crm_accounts(
	account_id VARCHAR(6) PRIMARY KEY,
	account_name VARCHAR,
	industry VARCHAR,
	billing_city VARCHAR,
	billing_state VARCHAR(2),
	billing_country VARCHAR(3),
	account_owner_user_id VARCHAR(6),
	created_date DATE,
	annual_revenue INTEGER
	--FOREIGN KEY (account_owner_user_id) REFERENCES crm.crm_users(user_id)
);
--CREATE CRM CONTACTS TABLE
CREATE TABLE crm.crm_contacts(
	contact_id VARCHAR(6) PRIMARY KEY,
	account_id VARCHAR(6),
	first_name VARCHAR,
	last_name VARCHAR,
	email VARCHAR,
	phone VARCHAR(8),
	title VARCHAR,
	last_activity_date DATE
	--FOREIGN KEY (account_id) REFERENCES crm.crm_accounts(account_id)
);
--CREATE CRM OPPORTUNITIES TABLE
CREATE TABLE crm.crm_opportunities(
	opportunity_id VARCHAR(6) PRIMARY KEY,
	account_id VARCHAR(6),
	contact_id VARCHAR(6),
	opportunity_name VARCHAR,
	stage VARCHAR,
	close_date DATE,
	expected_revenue INTEGER,
	probability_percent INTEGER,
	owner_user_id VARCHAR(6),
	created_date DATE
	--FOREIGN KEY (account_id) REFERENCES crm.crm_accounts(account_id),
	--FOREIGN KEY (contact_id) REFERENCES crm.crm_contacts(contact_id),
	--FOREIGN KEY (owner_user_id) REFERENCES crm.crm_users(user_id)
);
--CREATE CRM ACTIVIEIES TABLE 
CREATE TABLE crm.crm_activities(
	activity_id VARCHAR(6) PRIMARY KEY,
	activity_type VARCHAR,
	activity_date DATE,
	contact_id VARCHAR,
	opportunity_id VARCHAR(6),
	notes VARCHAR,
	creator_user_id VARCHAR(6),
	duration_minutes INTEGER
	--FOREIGN KEY (contact_id) REFERENCES crm.crm_contacts(contact_id),
	--FOREIGN KEY (opportunity_id) REFERENCES crm.crm_opportunities(opportunity_id),
	--FOREIGN KEY (creator_user_id) REFERENCES crm.crm_users(user_id)
);
