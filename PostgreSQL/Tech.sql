PGDMP      .                 }            Tech    17.5    17.5 ?    R           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                           false            S           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                           false            T           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                           false            U           1262    16388    Tech    DATABASE     |   CREATE DATABASE "Tech" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Spanish_Colombia.1252';
    DROP DATABASE "Tech";
                     postgres    false                        2615    16535    crm    SCHEMA        CREATE SCHEMA crm;
    DROP SCHEMA crm;
                     postgres    false            V           0    0 
   SCHEMA crm    COMMENT     -   COMMENT ON SCHEMA crm IS 'CRM source data.';
                        postgres    false    6                        2615    16718    erp    SCHEMA        CREATE SCHEMA erp;
    DROP SCHEMA erp;
                     postgres    false            W           0    0 
   SCHEMA erp    COMMENT     ,   COMMENT ON SCHEMA erp IS 'ERP source data';
                        postgres    false    7            �            1255    24586    crm_erp_view_update()    FUNCTION     �  CREATE FUNCTION crm.crm_erp_view_update() RETURNS void
    LANGUAGE plpgsql
    AS $$
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
$$;
 )   DROP FUNCTION crm.crm_erp_view_update();
       crm               postgres    false    6            �            1255    17285    crm_erp_view_update()    FUNCTION     *	  CREATE FUNCTION public.crm_erp_view_update() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
----- DELETE IF EXISTS
    IF EXISTS (
        SELECT 1 FROM information_schema.views 
        WHERE table_schema = crm AND table_name = 'crm_erp_view'
    ) THEN
        EXECUTE 'DROP VIEW crm_erp_view';
    END IF;

-- USE CTE
    EXECUTE '
        CREATE VIEW crm.crm_erp_view AS
        WITH orders AS (
            SELECT 
                o.order_id,
                o.custom_account_id,
                o.order_date,
                o.total_amount,
                ol.product_id,
                p.product_name,
                p.product_category,
                p.unit_price,
                p.cost_price,
                o.order_status,
                o.shipping_state
            FROM erp.erp_orders o
            LEFT JOIN erp.erp_orderlinesitems ol ON o.order_id = ol.order_id
            LEFT JOIN erp.erp_products p ON ol.product_id = p.product_id
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
            JOIN crm.crm_opportunities op ON ac.account_id = op.account_id
            JOIN crm.crm_activities act ON op.contact_id = act.contact_id
        )
        SELECT 
            a.account_name AS name,
            a.sector AS segment,
            a.contact_point AS acquisition_channel,
            o.product_name,
            o.product_category,
            o.unit_price,
            o.cost_price,
            o.order_date,
            o.total_amount,
            o.order_status,
            o.shipping_state AS shipping_region,
            c.full_name AS representative,
            c.title AS role
        FROM orders o
        JOIN accounts a ON o.custom_account_id = a.account_id
        JOIN customer c ON a.account_id = c.account_id;
    ';
END;
$$;
 ,   DROP FUNCTION public.crm_erp_view_update();
       public               postgres    false            �            1259    16882    crm_accounts    TABLE     m  CREATE TABLE crm.crm_accounts (
    account_id character varying(6) NOT NULL,
    account_name character varying,
    industry character varying,
    billing_city character varying,
    billing_state character varying(2),
    billing_country character varying(3),
    account_owner_user_id character varying(6),
    created_date date,
    annual_revenue integer
);
    DROP TABLE crm.crm_accounts;
       crm         heap r       postgres    false    6            �            1259    16904    crm_activities    TABLE     @  CREATE TABLE crm.crm_activities (
    activity_id character varying(6) NOT NULL,
    activity_type character varying,
    activity_date date,
    contact_id character varying,
    opportunity_id character varying(6),
    notes character varying,
    creator_user_id character varying(6),
    duration_minutes integer
);
    DROP TABLE crm.crm_activities;
       crm         heap r       postgres    false    6            �            1259    16890    crm_contacts    TABLE     /  CREATE TABLE crm.crm_contacts (
    contact_id character varying(6) NOT NULL,
    account_id character varying(6),
    first_name character varying,
    last_name character varying,
    email character varying,
    phone character varying(8),
    title character varying,
    last_activity_date date
);
    DROP TABLE crm.crm_contacts;
       crm         heap r       postgres    false    6            �            1259    16897    crm_opportunities    TABLE     {  CREATE TABLE crm.crm_opportunities (
    opportunity_id character varying(6) NOT NULL,
    account_id character varying(6),
    contact_id character varying(6),
    opportunity_name character varying,
    stage character varying,
    close_date date,
    expected_revenue integer,
    probability_percent integer,
    owner_user_id character varying(6),
    created_date date
);
 "   DROP TABLE crm.crm_opportunities;
       crm         heap r       postgres    false    6            �            1259    16954    erp_orderlinesitems    TABLE     �   CREATE TABLE erp.erp_orderlinesitems (
    order_line_item_id character varying(6) NOT NULL,
    order_id character varying(6),
    product_id character varying(4),
    quantity integer,
    unit_price_at_sale integer,
    line_total integer
);
 $   DROP TABLE erp.erp_orderlinesitems;
       erp         heap r       postgres    false    7            �            1259    16946 
   erp_orders    TABLE     m  CREATE TABLE erp.erp_orders (
    order_id character varying(6) NOT NULL,
    custom_account_id character varying(6),
    order_date date,
    total_amount integer,
    order_status character varying,
    sales_rep_user_id character varying(6),
    shipping_city character varying,
    shipping_state character varying(2),
    shipping_country character varying
);
    DROP TABLE erp.erp_orders;
       erp         heap r       postgres    false    7            �            1259    16925    erp_products    TABLE     	  CREATE TABLE erp.erp_products (
    product_id character varying(4) NOT NULL,
    product_name character varying,
    product_category character varying,
    unit_price integer,
    cost_price integer,
    supplier_id character varying(8),
    is_active boolean
);
    DROP TABLE erp.erp_products;
       erp         heap r       postgres    false    7            �            1259    24622    crm_erp_view    VIEW     �	  CREATE VIEW crm.crm_erp_view AS
 WITH orders AS (
         SELECT o_1.order_id,
            o_1.custom_account_id,
            o_1.order_date,
            sum(o_1.total_amount) AS total_amount,
            ol.product_id,
            p.product_name,
            p.product_category,
            avg(p.unit_price) AS unit_price,
            avg(p.cost_price) AS cost_price,
            o_1.order_status,
            o_1.shipping_state,
            sum(ol.quantity) AS total_quantity
           FROM ((erp.erp_orders o_1
             LEFT JOIN erp.erp_orderlinesitems ol ON (((o_1.order_id)::text = (ol.order_id)::text)))
             LEFT JOIN erp.erp_products p ON (((ol.product_id)::text = (p.product_id)::text)))
          GROUP BY o_1.order_id, o_1.custom_account_id, o_1.order_date, ol.product_id, p.product_name, p.product_category, o_1.order_status, o_1.shipping_state
        ), customer AS (
         SELECT crm_contacts.account_id,
            concat(crm_contacts.first_name, ' ', crm_contacts.last_name) AS full_name,
            crm_contacts.title
           FROM crm.crm_contacts
        ), accounts AS (
         SELECT DISTINCT ac.account_id,
            ac.account_name,
            upper((ac.industry)::text) AS sector,
            first_value(act.activity_type) OVER (PARTITION BY ac.account_name, (upper((ac.industry)::text)) ORDER BY act.activity_date) AS contact_point
           FROM ((crm.crm_accounts ac
             LEFT JOIN crm.crm_opportunities op ON (((ac.account_id)::text = (op.account_id)::text)))
             LEFT JOIN crm.crm_activities act ON (((op.contact_id)::text = (act.contact_id)::text)))
        )
 SELECT DISTINCT o.order_id,
    a.account_name AS name,
    a.sector AS segment,
    a.contact_point AS acquisition_channel,
    o.product_name,
    o.product_category,
    avg(o.unit_price) AS unit_price,
    avg(o.cost_price) AS cost_price,
    o.order_date,
    sum(o.total_amount) AS total_amount,
    o.order_status,
    o.shipping_state AS shipping_region,
    c.full_name AS representative,
    c.title AS role,
    sum(o.total_quantity) AS total_quantity
   FROM ((orders o
     JOIN accounts a ON (((o.custom_account_id)::text = (a.account_id)::text)))
     JOIN customer c ON (((a.account_id)::text = (c.account_id)::text)))
  GROUP BY o.order_id, a.account_name, a.sector, a.contact_point, o.product_name, o.product_category, o.order_date, o.shipping_state, c.full_name, c.title, o.order_status, o.total_quantity;
    DROP VIEW crm.crm_erp_view;
       crm       v       postgres    false    225    220    220    220    221    221    221    221    222    222    223    223    223    228    228    228    227    227    227    227    227    227    225    225    225    225    6            �            1259    16875 	   crm_users    TABLE     �   CREATE TABLE crm.crm_users (
    user_id character varying(6) NOT NULL,
    username character varying,
    full_name character varying,
    role character varying,
    start_date date
);
    DROP TABLE crm.crm_users;
       crm         heap r       postgres    false    6            �            1259    16939    erp_inventory    TABLE     �   CREATE TABLE erp.erp_inventory (
    inventory_id character varying(6) NOT NULL,
    product_id character varying(4),
    warehouse_location character varying,
    current_stock integer,
    last_update_date date
);
    DROP TABLE erp.erp_inventory;
       erp         heap r       postgres    false    7            �            1259    16959    erp_invoices    TABLE     �   CREATE TABLE erp.erp_invoices (
    invoice_id character varying(6) NOT NULL,
    order_id character varying(6),
    invoice_date date,
    invoice_amount integer,
    payment_status character varying
);
    DROP TABLE erp.erp_invoices;
       erp         heap r       postgres    false    7            �            1259    16973    erp_shipments    TABLE     F  CREATE TABLE erp.erp_shipments (
    shipments_id character varying(7) NOT NULL,
    order_id character varying(6),
    invoice_id character varying(6),
    shipments_date date,
    delivery_date date,
    shipping_carrier character varying,
    tracking_number character varying(14),
    shipment_status character varying
);
    DROP TABLE erp.erp_shipments;
       erp         heap r       postgres    false    7            �            1259    16911    erp_suppliers    TABLE     �   CREATE TABLE erp.erp_suppliers (
    supplier_id character varying(8) NOT NULL,
    supplier_name character varying,
    contact_person character varying,
    phone character varying(10),
    email character varying
);
    DROP TABLE erp.erp_suppliers;
       erp         heap r       postgres    false    7            E          0    16882    crm_accounts 
   TABLE DATA           �   COPY crm.crm_accounts (account_id, account_name, industry, billing_city, billing_state, billing_country, account_owner_user_id, created_date, annual_revenue) FROM stdin;
    crm               postgres    false    220   Gt       H          0    16904    crm_activities 
   TABLE DATA           �   COPY crm.crm_activities (activity_id, activity_type, activity_date, contact_id, opportunity_id, notes, creator_user_id, duration_minutes) FROM stdin;
    crm               postgres    false    223   �w       F          0    16890    crm_contacts 
   TABLE DATA           {   COPY crm.crm_contacts (contact_id, account_id, first_name, last_name, email, phone, title, last_activity_date) FROM stdin;
    crm               postgres    false    221   �z       G          0    16897    crm_opportunities 
   TABLE DATA           �   COPY crm.crm_opportunities (opportunity_id, account_id, contact_id, opportunity_name, stage, close_date, expected_revenue, probability_percent, owner_user_id, created_date) FROM stdin;
    crm               postgres    false    222   #~       D          0    16875 	   crm_users 
   TABLE DATA           P   COPY crm.crm_users (user_id, username, full_name, role, start_date) FROM stdin;
    crm               postgres    false    219   ��       K          0    16939    erp_inventory 
   TABLE DATA           s   COPY erp.erp_inventory (inventory_id, product_id, warehouse_location, current_stock, last_update_date) FROM stdin;
    erp               postgres    false    226   ͂       N          0    16959    erp_invoices 
   TABLE DATA           g   COPY erp.erp_invoices (invoice_id, order_id, invoice_date, invoice_amount, payment_status) FROM stdin;
    erp               postgres    false    229   �       M          0    16954    erp_orderlinesitems 
   TABLE DATA           ~   COPY erp.erp_orderlinesitems (order_line_item_id, order_id, product_id, quantity, unit_price_at_sale, line_total) FROM stdin;
    erp               postgres    false    228   ��       L          0    16946 
   erp_orders 
   TABLE DATA           �   COPY erp.erp_orders (order_id, custom_account_id, order_date, total_amount, order_status, sales_rep_user_id, shipping_city, shipping_state, shipping_country) FROM stdin;
    erp               postgres    false    227   <�       J          0    16925    erp_products 
   TABLE DATA              COPY erp.erp_products (product_id, product_name, product_category, unit_price, cost_price, supplier_id, is_active) FROM stdin;
    erp               postgres    false    225   ��       O          0    16973    erp_shipments 
   TABLE DATA           �   COPY erp.erp_shipments (shipments_id, order_id, invoice_id, shipments_date, delivery_date, shipping_carrier, tracking_number, shipment_status) FROM stdin;
    erp               postgres    false    230   #�       I          0    16911    erp_suppliers 
   TABLE DATA           ^   COPY erp.erp_suppliers (supplier_id, supplier_name, contact_person, phone, email) FROM stdin;
    erp               postgres    false    224   Ռ       �           2606    16888    crm_accounts crm_accounts_pkey 
   CONSTRAINT     a   ALTER TABLE ONLY crm.crm_accounts
    ADD CONSTRAINT crm_accounts_pkey PRIMARY KEY (account_id);
 E   ALTER TABLE ONLY crm.crm_accounts DROP CONSTRAINT crm_accounts_pkey;
       crm                 postgres    false    220            �           2606    16910 "   crm_activities crm_activities_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY crm.crm_activities
    ADD CONSTRAINT crm_activities_pkey PRIMARY KEY (activity_id);
 I   ALTER TABLE ONLY crm.crm_activities DROP CONSTRAINT crm_activities_pkey;
       crm                 postgres    false    223            �           2606    16896    crm_contacts crm_contacts_pkey 
   CONSTRAINT     a   ALTER TABLE ONLY crm.crm_contacts
    ADD CONSTRAINT crm_contacts_pkey PRIMARY KEY (contact_id);
 E   ALTER TABLE ONLY crm.crm_contacts DROP CONSTRAINT crm_contacts_pkey;
       crm                 postgres    false    221            �           2606    16903 (   crm_opportunities crm_opportunities_pkey 
   CONSTRAINT     o   ALTER TABLE ONLY crm.crm_opportunities
    ADD CONSTRAINT crm_opportunities_pkey PRIMARY KEY (opportunity_id);
 O   ALTER TABLE ONLY crm.crm_opportunities DROP CONSTRAINT crm_opportunities_pkey;
       crm                 postgres    false    222            �           2606    16881    crm_users crm_users_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY crm.crm_users
    ADD CONSTRAINT crm_users_pkey PRIMARY KEY (user_id);
 ?   ALTER TABLE ONLY crm.crm_users DROP CONSTRAINT crm_users_pkey;
       crm                 postgres    false    219            �           2606    16945     erp_inventory erp_inventory_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY erp.erp_inventory
    ADD CONSTRAINT erp_inventory_pkey PRIMARY KEY (inventory_id);
 G   ALTER TABLE ONLY erp.erp_inventory DROP CONSTRAINT erp_inventory_pkey;
       erp                 postgres    false    226            �           2606    16965    erp_invoices erp_invoices_pkey 
   CONSTRAINT     a   ALTER TABLE ONLY erp.erp_invoices
    ADD CONSTRAINT erp_invoices_pkey PRIMARY KEY (invoice_id);
 E   ALTER TABLE ONLY erp.erp_invoices DROP CONSTRAINT erp_invoices_pkey;
       erp                 postgres    false    229            �           2606    16958 ,   erp_orderlinesitems erp_orderlinesitems_pkey 
   CONSTRAINT     w   ALTER TABLE ONLY erp.erp_orderlinesitems
    ADD CONSTRAINT erp_orderlinesitems_pkey PRIMARY KEY (order_line_item_id);
 S   ALTER TABLE ONLY erp.erp_orderlinesitems DROP CONSTRAINT erp_orderlinesitems_pkey;
       erp                 postgres    false    228            �           2606    16952    erp_orders erp_orders_pkey 
   CONSTRAINT     [   ALTER TABLE ONLY erp.erp_orders
    ADD CONSTRAINT erp_orders_pkey PRIMARY KEY (order_id);
 A   ALTER TABLE ONLY erp.erp_orders DROP CONSTRAINT erp_orders_pkey;
       erp                 postgres    false    227            �           2606    16931    erp_products erp_products_pkey 
   CONSTRAINT     a   ALTER TABLE ONLY erp.erp_products
    ADD CONSTRAINT erp_products_pkey PRIMARY KEY (product_id);
 E   ALTER TABLE ONLY erp.erp_products DROP CONSTRAINT erp_products_pkey;
       erp                 postgres    false    225            �           2606    16979     erp_shipments erp_shipments_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY erp.erp_shipments
    ADD CONSTRAINT erp_shipments_pkey PRIMARY KEY (shipments_id);
 G   ALTER TABLE ONLY erp.erp_shipments DROP CONSTRAINT erp_shipments_pkey;
       erp                 postgres    false    230            �           2606    16917     erp_suppliers erp_suppliers_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY erp.erp_suppliers
    ADD CONSTRAINT erp_suppliers_pkey PRIMARY KEY (supplier_id);
 G   ALTER TABLE ONLY erp.erp_suppliers DROP CONSTRAINT erp_suppliers_pkey;
       erp                 postgres    false    224            �           2606    17090    crm_accounts accounts_users    FK CONSTRAINT     �   ALTER TABLE ONLY crm.crm_accounts
    ADD CONSTRAINT accounts_users FOREIGN KEY (account_owner_user_id) REFERENCES crm.crm_users(user_id) ON DELETE CASCADE;
 B   ALTER TABLE ONLY crm.crm_accounts DROP CONSTRAINT accounts_users;
       crm               postgres    false    219    4747    220            �           2606    17080 "   crm_activities activities_contacts    FK CONSTRAINT     �   ALTER TABLE ONLY crm.crm_activities
    ADD CONSTRAINT activities_contacts FOREIGN KEY (contact_id) REFERENCES crm.crm_contacts(contact_id) ON DELETE CASCADE;
 I   ALTER TABLE ONLY crm.crm_activities DROP CONSTRAINT activities_contacts;
       crm               postgres    false    4751    223    221            �           2606    17110 %   crm_activities activities_opportunity    FK CONSTRAINT     �   ALTER TABLE ONLY crm.crm_activities
    ADD CONSTRAINT activities_opportunity FOREIGN KEY (opportunity_id) REFERENCES crm.crm_opportunities(opportunity_id) ON DELETE CASCADE;
 L   ALTER TABLE ONLY crm.crm_activities DROP CONSTRAINT activities_opportunity;
       crm               postgres    false    4753    222    223            �           2606    17115    crm_activities activities_users    FK CONSTRAINT     �   ALTER TABLE ONLY crm.crm_activities
    ADD CONSTRAINT activities_users FOREIGN KEY (creator_user_id) REFERENCES crm.crm_users(user_id) ON DELETE CASCADE;
 F   ALTER TABLE ONLY crm.crm_activities DROP CONSTRAINT activities_users;
       crm               postgres    false    219    4747    223            �           2606    17085    crm_contacts contacts_accounts    FK CONSTRAINT     �   ALTER TABLE ONLY crm.crm_contacts
    ADD CONSTRAINT contacts_accounts FOREIGN KEY (account_id) REFERENCES crm.crm_accounts(account_id) ON DELETE CASCADE;
 E   ALTER TABLE ONLY crm.crm_contacts DROP CONSTRAINT contacts_accounts;
       crm               postgres    false    220    4749    221            �           2606    17095 (   crm_opportunities opportunities_accounts    FK CONSTRAINT     �   ALTER TABLE ONLY crm.crm_opportunities
    ADD CONSTRAINT opportunities_accounts FOREIGN KEY (account_id) REFERENCES crm.crm_accounts(account_id) ON DELETE CASCADE;
 O   ALTER TABLE ONLY crm.crm_opportunities DROP CONSTRAINT opportunities_accounts;
       crm               postgres    false    220    4749    222            �           2606    17100 (   crm_opportunities opportunities_contacts    FK CONSTRAINT     �   ALTER TABLE ONLY crm.crm_opportunities
    ADD CONSTRAINT opportunities_contacts FOREIGN KEY (contact_id) REFERENCES crm.crm_contacts(contact_id) ON DELETE CASCADE;
 O   ALTER TABLE ONLY crm.crm_opportunities DROP CONSTRAINT opportunities_contacts;
       crm               postgres    false    222    4751    221            �           2606    17105 %   crm_opportunities opportunities_users    FK CONSTRAINT     �   ALTER TABLE ONLY crm.crm_opportunities
    ADD CONSTRAINT opportunities_users FOREIGN KEY (owner_user_id) REFERENCES crm.crm_users(user_id) ON DELETE CASCADE;
 L   ALTER TABLE ONLY crm.crm_opportunities DROP CONSTRAINT opportunities_users;
       crm               postgres    false    222    4747    219            �           2606    17140    erp_inventory inventory_product    FK CONSTRAINT     �   ALTER TABLE ONLY erp.erp_inventory
    ADD CONSTRAINT inventory_product FOREIGN KEY (product_id) REFERENCES erp.erp_products(product_id) ON DELETE CASCADE;
 F   ALTER TABLE ONLY erp.erp_inventory DROP CONSTRAINT inventory_product;
       erp               postgres    false    4759    226    225            �           2606    17255    erp_invoices invoices_orders    FK CONSTRAINT     �   ALTER TABLE ONLY erp.erp_invoices
    ADD CONSTRAINT invoices_orders FOREIGN KEY (order_id) REFERENCES erp.erp_orders(order_id) ON DELETE CASCADE;
 C   ALTER TABLE ONLY erp.erp_invoices DROP CONSTRAINT invoices_orders;
       erp               postgres    false    4763    229    227            �           2606    17280 )   erp_orderlinesitems orderlinesitems_order    FK CONSTRAINT     �   ALTER TABLE ONLY erp.erp_orderlinesitems
    ADD CONSTRAINT orderlinesitems_order FOREIGN KEY (order_id) REFERENCES erp.erp_orders(order_id) ON DELETE CASCADE;
 P   ALTER TABLE ONLY erp.erp_orderlinesitems DROP CONSTRAINT orderlinesitems_order;
       erp               postgres    false    4763    227    228            �           2606    17270 +   erp_orderlinesitems orderlinesitems_product    FK CONSTRAINT     �   ALTER TABLE ONLY erp.erp_orderlinesitems
    ADD CONSTRAINT orderlinesitems_product FOREIGN KEY (product_id) REFERENCES erp.erp_products(product_id) ON DELETE CASCADE;
 R   ALTER TABLE ONLY erp.erp_orderlinesitems DROP CONSTRAINT orderlinesitems_product;
       erp               postgres    false    4759    225    228            �           2606    17180    erp_orders orders_accounts    FK CONSTRAINT     �   ALTER TABLE ONLY erp.erp_orders
    ADD CONSTRAINT orders_accounts FOREIGN KEY (custom_account_id) REFERENCES crm.crm_accounts(account_id) ON DELETE CASCADE;
 A   ALTER TABLE ONLY erp.erp_orders DROP CONSTRAINT orders_accounts;
       erp               postgres    false    227    4749    220            �           2606    17185    erp_orders orders_users    FK CONSTRAINT     �   ALTER TABLE ONLY erp.erp_orders
    ADD CONSTRAINT orders_users FOREIGN KEY (sales_rep_user_id) REFERENCES crm.crm_users(user_id) ON DELETE CASCADE;
 >   ALTER TABLE ONLY erp.erp_orders DROP CONSTRAINT orders_users;
       erp               postgres    false    219    227    4747            �           2606    17125    erp_products products_suppliers    FK CONSTRAINT     �   ALTER TABLE ONLY erp.erp_products
    ADD CONSTRAINT products_suppliers FOREIGN KEY (supplier_id) REFERENCES erp.erp_suppliers(supplier_id) ON DELETE CASCADE;
 F   ALTER TABLE ONLY erp.erp_products DROP CONSTRAINT products_suppliers;
       erp               postgres    false    225    224    4757            �           2606    17245    erp_shipments shipments_orders    FK CONSTRAINT     �   ALTER TABLE ONLY erp.erp_shipments
    ADD CONSTRAINT shipments_orders FOREIGN KEY (order_id) REFERENCES erp.erp_orders(order_id) ON DELETE CASCADE;
 E   ALTER TABLE ONLY erp.erp_shipments DROP CONSTRAINT shipments_orders;
       erp               postgres    false    230    227    4763            E   .  x���_o�8şo?����6�C	��٭4/np����N��^�������D��|�9�Dq<R�(��9��!�Q��F��_�Q�~�L��c�!{��2«��cCFC:`C���]�Rk^)AR�ͅ���+�T�
ؙ�D�J�GLve�#0G�T� ���u��na-5ו��������Mt�I@Cr��Bh{�=���\g�
[ӵ�h8��{ـN������E:Rǥ���^�	��<�+b��� 1��\ˊ�L-['�>�J��S�T�z��hో�5��,~�X��Cq�`/�B�W\)�~�kv��E�á1B˟$ѵ�B�ڄ�+�QF�������=�`&bK+�Ƒ���3ً���~����q�.����b�^nz�n]C�Ɯ0x'�����Z������恁`8v�my&�y4���$�f�.�<@�5Y[�Q�����_���I"AY?X�1�>hQ9�&��"���'�)��ӡ�*�AG�t��K��a�fQ'�T�$ԹA����dP��1*�z�-nq+�o�Ov����}�f��Y#���؏}fih���#j�w�I:'lEr�p�zCO���_��9�S(_�#+�$��({ZӸ��E����~����j��Gܛ����I����2xF�����	�� 4G)ZYk��:}�d�4K�^�=���g�d��v&~�i8�V��<t��OVi�+&�w�vh�#8hDƱ�����"Z�<_��'ߓ"�$�{�\���8f���U�ʱ/����}Y��������Ƿ���:��      H     x�u�Os�0��ʧЩ7g��c��&�LI:v;����5�
����� uN�������Vw���ˈ�˺fb)��2]�%�}�_��ǃ��C�A�;�G���߃�Ѐv�-�������͝W�G#U/�,����	���xi�ڜ���;S����K��`�,%͘=8����-�i��j���5ύvV�-�sY0�L��*	{{aOZ9���,�|>NX\��d�P��<��.���TCQa�
�U�0�3�2����5-�p��Ť���C�2R��4���צR�SyǕvPY�����t��M�X\�ƑT&�ɮ�Ts��^�w`��+&��z_,Ě�־x���k�C�����Ad�7r�e��ٰ�V*ݡD��rٴRU��doi�jg�g��v�c��5�T!c���ub��t�������=M����;��8��ќ��q԰Y�p��5��d=P�"�+�D;��,/0����!�*x�c H���̖��}p���5	͑�����c9�#Z�PaɎ�q(�e���遄�$�$$�(���g;�<�j���Zb�,���ǫi戦7"������o���i��^�3���!x����.�ٗ�T5$d$p���"��e�y
p�y�w��y΁�s@c!�1堒Z�;�m}����$'�^B��dD���#%4_�D<�r��;j���N"�j��/a���K����7ip�^���x���Lr��q�Nd�׾���OWOeL�~��b�����}��      F   r  x��U�r�:]#_��ƒ-�٩�$M]��؝v�-�m�Ԑ�S���~0uW�{W 4��C�_��>�33�HX��6�!76��k��LX,��T-dY6H\���тIV��t�f�a6H�7�CL=b
3&���R�w\JV
�RxZF�\ci�	l<H26�`#X�-�R?�����x|>���?2�Gưb�50G�X �C]kD�0��5�\Isu�l�a3xh��C!��:?.sӷԮ3�%�岎�Ȫ#��ܦ�Ǜ�=��
>S"T΍��*�I^�x����KJ�K6lxlح���g�w��w��Ƃ:D�k�:����
%W�@��eҞ��K�z�)|�Bp��Yx�A��]���:D�Vk� k.���t�N=�����*vA�i���ׇ�MG����H��៼�N�I�d23֢��l/(k��� �6d5%S�e��Ei��phG$^-d�j�ں�%A"ꮱL��w!l���E%��J�̹�|d���u�b�K�C�P���U\��T�W��aZн��������d�L��#��=�d�=+�z"C�v3���4ߠu!M�XD��ք�cxĥk9��ˉ���[�j�E������5�J�K����"��lM���̔�� �9�C�ܼ�R)�^�?+�񼢜i��Q�7&��{��gj��9݂�{�*9ш{�g}��D�3Ԅ�u~��^�u�E�Ni�Ft�pz��EK�2����Y�=~�lW�(6y�k7���]�$&%�#��RG�~W�V��D枞%�d-wEW��8Eo�F�vh��ҙU�ub%������,M����u������O�'_����X���E�f��������F���F?⛛���6O�      G   �  x�}��n�8���S�7/Dʔ�c`7h�&�Z-r酕�[I4(*���wȡ�X�����3?��fv�}��n�qa�{r�I��B�Wi�C�bDgM_���ho�Yw��X��2N�IQ�_��я����[-c�ع��3LϢ�R��&�$?ΕG�ӋZ��RX�ې![R�>9�Y����L�`�$zh_eg�Z��ƾ�Zir��J�E�Zw�H�G�d<b�~O
H�4F�j�Pc��\_��$TKvg��>�I�cG�ZQ_:ՅD�w�y�4��Fc�"E8���˲�M#M)ɾP�iȣ��P(������	<|��BR�HQ#���JuV�).�����Ab��lɠ
�UpTHGi�"C�����MV�tE��j+?Y���Ui�>v<u�ȼD����9J�(��iu�-��NU��,��;I�S�B�|T�Yc�5�^G[U)+j�(�oi��7�9'r��Ե�Ol�h�>��~����D }ga�įZ�)����,�����MƉTP$�"���9�_ڷz+ϵ�8B>��?�̧8�(�Lg�e-OR��4�lr?��w�Oq�#�q����E+*���5��1��H3E�ݧ���?dʓj��̷w�������!?�Ld�]1�5l�9z���wH��R��3,Г�;ye�W��^�\-�wx��"�m�^�t'u�V[�)�a'P�"��o
y�Gi�a����$�@W��A�/�B�ʱ+�J���n46w���f=M��2���T���v����I��0n�o|:�୰����=��^þa����q�KI�X;a��\�S��~v���t�����u�z�����l��|�:�hz��k)���뺿}���l�������n�p��,��h��������/~��X,�*�p;      D   �   x�e�Mn�0��p
_��mB�.K����&(�&����� "n_lZT��œ�y�4�d��K^!�M��&{���̝�� Y_US��V���9)�Bz���*%�>�SyF�0�V��d�B5��V�|�<�/\�A�j������I��G���%�U�Fض�w�q�C��Xf��}/V������z�k(R[���FCb�'|����J����mG>|����.���ֵ�$��~��r���!���(      K     x�m��N1Dk�+�� ��k�J�*JE$:$��O(77�NW=y�ǻ�׷�$\d��?�_��ק�`)hR;�zH=��R�(��V,;�7�14�Su��S{�i��;���l�j�(�����WN�NeH\�/NL���$�/�(RF����_�13�&ٱ��*��^ ��SX�����n~rb���Jc����,���NP'�1�2Ȭd�s*vFm��sV8K�g��3G�H�T��h�il6�Afg��f#��f�����I�x�1� Sq�      N   �   x�UѱN�0�9��<�7M��oy�70� ����عr�J��S۹y���hy}���hE/ں��ϟ���$Ҫ,�D�h!z�^��;E1}̙A'*��vi1(��!#��`:�%Q1�"���u�~�3�$� �g����(lO;Ȟ���R��T�+��ʾ�Y0O!��PI�*��#���"���@��螗�s`]��y��f�qQ�)�Hu���^}��`T�Q�똶�ܶm��'��      M   0  x�m�;n�0Dk�0M},�i,`#u��<z��+y�7�P#�/�Վ���;W>����,G�xర���&+bagAP��J�b�θ����i�vV`��0fakiX4On�M�gל�Q��]���〬;KhiV��빺؞����YB�v9��XB�fט�؂
v�19B�H����Sst�-�\����T��	��s*48r<+��9�rA�eϮX��Rɠ����l:S%�ǜ��YJ~YV�v��L\/f�9)��L(4����&T6h���:}���4t���[��~N��,�/�S�~      L   6  x���ݎ�0��'O�/��c0�˔h�H�S�U�Ro��
V�M_�6�
bR��13g����baY����s�s� ��T��M]����_���w���ݻ{���=�	�N�aX����0��m_��j�B����$�b�
�"���Y^-�7��6�� ��\����g������o*-�̋hb[-jx�̈ˈC�:�d�n'%��V�u4jNlXw!dQ�V��e��lA`�A'0�s�挋�R�(�� t�ԯ����������$|�uk����x�6����v;�N�,�F��"��yym�9��lǞ@�r����i$�}㚾��z�܄I �����v�J���[�%F��R�[*�R;K��ŖZ������z@�R(�K���S�x�/�?,�
��f�od�)ʞY�V���f"�UYɦ�]�`W0Y����
w�Q�fk��v7��/\��Cg���p�RҴ���d2ޛL�r3x<���v��m(�Ǳ%B�S�=K->N-��J@>q�?2��3K�����'��E��N�]=M,�����(����a6��#q�      J   �  x�]�Ks�0���W�mOٲ� r�(L69�E1VŖ(��Z����kEUL�t�p��J�`c4��͖��n�~{����A���I�7)�ކ!{�TGX��"|r$,��[a�%3Q��_Z�����(��`�f+4��4�ߍ=�1`q$�����Qe9�h$Z�7
i�XH�h�Q��T{^�f�^O�����V��C6ч"��W�t�=y�B����Dl!�*���eyLn��"f�DV�%L
��V�.�5>�����W."��s�b,��W�~X�[�;��Tl�ٌ��%�ڥ�G�<d�� ST��W�fo�~����Gl[+圤��0\�W5灛Е��C*�^E��ɱ�uyG��˶�A]��LZ�BQ� �����i�]�0��� ��^�x�^�fP1i�H]����ta�UVk[5����:������A�Q*
�J�e���$2��ߓ3]I�੖{���_�%6��o�m�[9���;rN��TO%+��^TFx�B����G�Ϧ�A�����I&��E�����,,�H�m��mo�g��;�v��E��z��=z�T��K����kE�z����/B�Ƹ�t@X���G������������5��x��W&�F��u����!�����^���k
      O   �  x�m��j�0���S�2,�v��X7Z6��v;�2h��C7������!*��bI�.�kc�z�̇�r�1<�07��\v�sx��v����ֺj��s��	��00c��'��z_o3�+HHȘtq.�j�x͐NA, +ɐ
7

���8d�4����ZEC3�t�xI���29�  ���8Ln�JMr�0!a� $�eC(�9V� b�L�A6��ܐk��x��+�WJ�y2�r�!g�l!�,7㈆�r�[��[Ѕm�����lHyK��
�I/7IeDOR��%�BV��p��hHyK�`9$/õ2ܢ!�-�[�+��u�r�	�醼2�`.��$�>
�Uш��9��Ο��㏤!,�&A�v�jL_w�Y�a*�3I�HLO�ު<�.�L������������?      I     x�E�Io�0����+��[QJB���--�r�eb�� 6�Ҫ��v�~z����r6{����	K��W�S��P���6���}��+s���x�u�T1����>k][�J�<z���B�D����ʠ��`Mx��T��j�]P+�Ha'���p5�p�l�.�?멳���-�a!jIX�a��`K?�Ʒ1��:.�l�����$�X�q*�w�9tqa"�ኦ���Q�y#p�wR+�4FZ܏�%𸰯@OWtN|�I��[t��     