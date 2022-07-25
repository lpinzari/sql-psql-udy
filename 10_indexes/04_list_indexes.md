# LIST Indexes

PostgreSQL does not provide a command like `SHOW INDEXES` to list the index information of a table or database.

However, it does provide you with access to the `pg_indexes` view so that you can query the index information. If you use psql to access the PostgreSQL database, you can use the `\d` command to view the index information for a table.

## PostgreSQL List Indexes using pg_indexes view

The `pg_indexes` view allows you **to access useful information on each index in the PostgreSQL database**. The `pg_indexes` **view** consists of five columns:

- `schemaname`: stores the name of the schema that contains tables and indexes.
- `tablename`: stores name of the table to which the index belongs.
- `indexname`: stores name of the index.
- `tablespace`: stores name of the tablespace that contains indexes.
- `indexdef`: stores index definition command in the form of CREATE INDEX statement.

The following statement lists all indexes of the schema public in the current database:

```SQL
SELECT tablename,
       indexname,
       indexdef
  FROM pg_indexes
 WHERE schemaname = 'public'
 ORDER BY tablename, indexname;
```

```console
tablename   |                      indexname                      |                                                                   indexdef
---------------+-----------------------------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------
actor         | actor_pkey                                          | CREATE UNIQUE INDEX actor_pkey ON public.actor USING btree (actor_id)
actor         | idx_actor_last_name                                 | CREATE INDEX idx_actor_last_name ON public.actor USING btree (last_name)
address       | address_pkey                                        | CREATE UNIQUE INDEX address_pkey ON public.address USING btree (address_id)
address       | idx_address_phone                                   | CREATE INDEX idx_address_phone ON public.address USING btree (phone)
address       | idx_fk_city_id                                      | CREATE INDEX idx_fk_city_id ON public.address USING btree (city_id)
category      | category_pkey                                       | CREATE UNIQUE INDEX category_pkey ON public.category USING btree (category_id)
city          | city_pkey                                           | CREATE UNIQUE INDEX city_pkey ON public.city USING btree (city_id)
city          | idx_fk_country_id                                   | CREATE INDEX idx_fk_country_id ON public.city USING btree (country_id)
country       | country_pkey                                        | CREATE UNIQUE INDEX country_pkey ON public.country USING btree (country_id)
customer      | customer_pkey                                       | CREATE UNIQUE INDEX customer_pkey ON public.customer USING btree (customer_id)
customer      | idx_fk_address_id                                   | CREATE INDEX idx_fk_address_id ON public.customer USING btree (address_id)
customer      | idx_fk_store_id                                     | CREATE INDEX idx_fk_store_id ON public.customer USING btree (store_id)
customer      | idx_last_name                                       | CREATE INDEX idx_last_name ON public.customer USING btree (last_name)
film          | film_fulltext_idx                                   | CREATE INDEX film_fulltext_idx ON public.film USING gist (fulltext)
film          | film_pkey                                           | CREATE UNIQUE INDEX film_pkey ON public.film USING btree (film_id)
film          | idx_fk_language_id                                  | CREATE INDEX idx_fk_language_id ON public.film USING btree (language_id)
film          | idx_title                                           | CREATE INDEX idx_title ON public.film USING btree (title)
film_actor    | film_actor_pkey                                     | CREATE UNIQUE INDEX film_actor_pkey ON public.film_actor USING btree (actor_id, film_id)
film_actor    | idx_fk_film_id                                      | CREATE INDEX idx_fk_film_id ON public.film_actor USING btree (film_id)
film_category | film_category_pkey                                  | CREATE UNIQUE INDEX film_category_pkey ON public.film_category USING btree (film_id, category_id)
inventory     | idx_store_id_film_id                                | CREATE INDEX idx_store_id_film_id ON public.inventory USING btree (store_id, film_id)
inventory     | inventory_pkey                                      | CREATE UNIQUE INDEX inventory_pkey ON public.inventory USING btree (inventory_id)
language      | language_pkey                                       | CREATE UNIQUE INDEX language_pkey ON public.language USING btree (language_id)
payment       | idx_fk_customer_id                                  | CREATE INDEX idx_fk_customer_id ON public.payment USING btree (customer_id)
payment       | idx_fk_rental_id                                    | CREATE INDEX idx_fk_rental_id ON public.payment USING btree (rental_id)
payment       | idx_fk_staff_id                                     | CREATE INDEX idx_fk_staff_id ON public.payment USING btree (staff_id)
payment       | payment_pkey                                        | CREATE UNIQUE INDEX payment_pkey ON public.payment USING btree (payment_id)
rental        | idx_fk_inventory_id                                 | CREATE INDEX idx_fk_inventory_id ON public.rental USING btree (inventory_id)
rental        | idx_unq_rental_rental_date_inventory_id_customer_id | CREATE UNIQUE INDEX idx_unq_rental_rental_date_inventory_id_customer_id ON public.rental USING btree (rental_date, inventory_id, customer_id)
rental        | rental_pkey                                         | CREATE UNIQUE INDEX rental_pkey ON public.rental USING btree (rental_id)
staff         | staff_pkey                                          | CREATE UNIQUE INDEX staff_pkey ON public.staff USING btree (staff_id)
store         | idx_unq_manager_staff_id                            | CREATE UNIQUE INDEX idx_unq_manager_staff_id ON public.store USING btree (manager_staff_id)
store         | store_pkey                                          | CREATE UNIQUE INDEX store_pkey ON public.store USING btree (store_id)
(33 rows)
```

Another command is `\di`:

```console
dvdrental=# \di
                                        List of relations
 Schema |                        Name                         | Type  |  Owner   |     Table
--------+-----------------------------------------------------+-------+----------+---------------
 public | actor_pkey                                          | index | postgres | actor
 public | address_pkey                                        | index | postgres | address
 public | category_pkey                                       | index | postgres | category
 public | city_pkey                                           | index | postgres | city
 public | country_pkey                                        | index | postgres | country
 public | customer_pkey                                       | index | postgres | customer
 public | film_actor_pkey                                     | index | postgres | film_actor
 public | film_category_pkey                                  | index | postgres | film_category
 public | film_fulltext_idx                                   | index | postgres | film
 public | film_pkey                                           | index | postgres | film
 public | idx_actor_last_name                                 | index | postgres | actor
 public | idx_address_phone                                   | index | postgres | address
 public | idx_fk_address_id                                   | index | postgres | customer
 public | idx_fk_city_id                                      | index | postgres | address
 public | idx_fk_country_id                                   | index | postgres | city
 public | idx_fk_customer_id                                  | index | postgres | payment
 public | idx_fk_film_id                                      | index | postgres | film_actor
 public | idx_fk_inventory_id                                 | index | postgres | rental
 public | idx_fk_language_id                                  | index | postgres | film
 public | idx_fk_rental_id                                    | index | postgres | payment
 public | idx_fk_staff_id                                     | index | postgres | payment
 public | idx_fk_store_id                                     | index | postgres | customer
 public | idx_last_name                                       | index | postgres | customer
 public | idx_store_id_film_id                                | index | postgres | inventory
 public | idx_title                                           | index | postgres | film
 public | idx_unq_manager_staff_id                            | index | postgres | store
 public | idx_unq_rental_rental_date_inventory_id_customer_id | index | postgres | rental
 public | inventory_pkey                                      | index | postgres | inventory
 public | language_pkey                                       | index | postgres | language
 public | payment_pkey                                        | index | postgres | payment
 public | rental_pkey                                         | index | postgres | rental
 public | staff_pkey                                          | index | postgres | staff
 public | store_pkey                                          | index | postgres | store
(33 rows)
```

To show all the indexes of a table, you use the following statement:

```SQL
SELECT indexname,
       indexdef
  FROM pg_indexes
 WHERE tablename = 'table_name';
```

For example, to list all the indexes for the `customer` table, you use the following statement:

```SQL
SELECT indexname,
       indexdef
  FROM pg_indexes
 WHERE tablename = 'customer';
```

```console
indexname     |                                    indexdef
-------------------+--------------------------------------------------------------------------------
customer_pkey     | CREATE UNIQUE INDEX customer_pkey ON public.customer USING btree (customer_id)
idx_fk_address_id | CREATE INDEX idx_fk_address_id ON public.customer USING btree (address_id)
idx_fk_store_id   | CREATE INDEX idx_fk_store_id ON public.customer USING btree (store_id)
idx_last_name     | CREATE INDEX idx_last_name ON public.customer USING btree (last_name)
(4 rows)
```

If you want to get a list of indexes for tables whose name start with the letter `c`, you can use the following query:

```SQL
SELECT tablename,
       indexname,
       indexdef
  FROM pg_indexes
 WHERE tablename LIKE 'c%'
 ORDER BY tablename, indexname;
```

```console
tablename |     indexname     |                                    indexdef
-----------+-------------------+--------------------------------------------------------------------------------
category  | category_pkey     | CREATE UNIQUE INDEX category_pkey ON public.category USING btree (category_id)
city      | city_pkey         | CREATE UNIQUE INDEX city_pkey ON public.city USING btree (city_id)
city      | idx_fk_country_id | CREATE INDEX idx_fk_country_id ON public.city USING btree (country_id)
country   | country_pkey      | CREATE UNIQUE INDEX country_pkey ON public.country USING btree (country_id)
customer  | customer_pkey     | CREATE UNIQUE INDEX customer_pkey ON public.customer USING btree (customer_id)
customer  | idx_fk_address_id | CREATE INDEX idx_fk_address_id ON public.customer USING btree (address_id)
customer  | idx_fk_store_id   | CREATE INDEX idx_fk_store_id ON public.customer USING btree (store_id)
customer  | idx_last_name     | CREATE INDEX idx_last_name ON public.customer USING btree (last_name)
```

## PostgreSQL List Indexes using psql command

If you use psql to connect to a PostgreSQL database and want to list all indexes of a table, you can use the `\d` psql command as follows:

```console
\d table_name
```
The command will return all information of the table including the table’s structure, indexes, constraints, and triggers.

For example, the following statement returns detailed information about the `customer` table:

```console
dvdrental=# \d customer
                                             Table "public.customer"
   Column    |            Type             | Collation | Nullable |                    Default
-------------+-----------------------------+-----------+----------+-----------------------------------------------
 customer_id | integer                     |           | not null | nextval('customer_customer_id_seq'::regclass)
 store_id    | smallint                    |           | not null |
 first_name  | character varying(45)       |           | not null |
 last_name   | character varying(45)       |           | not null |
 email       | character varying(50)       |           |          |
 address_id  | smallint                    |           | not null |
 activebool  | boolean                     |           | not null | true
 create_date | date                        |           | not null | ('now'::text)::date
 last_update | timestamp without time zone |           |          | now()
 active      | integer                     |           |          |
Indexes:
    "customer_pkey" PRIMARY KEY, btree (customer_id)
    "idx_fk_address_id" btree (address_id)
    "idx_fk_store_id" btree (store_id)
    "idx_last_name" btree (last_name)
Foreign-key constraints:
    "customer_address_id_fkey" FOREIGN KEY (address_id) REFERENCES address(address_id) ON UPDATE CASCADE ON DELETE RESTRICT
Referenced by:
    TABLE "payment" CONSTRAINT "payment_customer_id_fkey" FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON UPDATE CASCADE ON DELETE RESTRICT
    TABLE "rental" CONSTRAINT "rental_customer_id_fkey" FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON UPDATE CASCADE ON DELETE RESTRICT
Triggers:
    last_updated BEFORE UPDATE ON customer FOR EACH ROW EXECUTE PROCEDURE last_updated()
```

As shown clearly in the output, you can find the index of the table under the indexes section.
