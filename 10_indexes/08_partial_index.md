# PARTIAL INDEX

So far you have learned how to add values of one or more columns to an index. PostgreSQL **partial index** even **allows you to specify the rows of a table that should be indexed**. This partial index helps **speed up the query while reducing the size of the index**.

The **partial index** is useful in case you have commonly used `WHERE` conditions which use constant values as follows:

```SQL
SELECT *
FROM table_name
WHERE column_name = constant_value;
```

Let’s take a look at the `customer` table from the sample database:

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
```

For example, you typically are interested in **inactive customers** and often do some kinds of follow-ups to get them back to buy more stuff.

The following query finds **all inactive customers**:

```SQL
SELECT customer_id,
       first_name,
       last_name,
       email
  FROM customer
 WHERE active = 0;
```

**Results**

|customer_id | first_name | last_name |                email|
|:-----------:|:---------:|:---------:|:------------------------------------:|
|         16 | Sandra     | Martin    | sandra.martin@sakilacustomer.org|
|         64 | Judith     | Cox       | judith.cox@sakilacustomer.org|
|        124 | Sheila     | Wells     | sheila.wells@sakilacustomer.org|
|        169 | Erica      | Matthews  | erica.matthews@sakilacustomer.org|
|        241 | Heidi      | Larson    | heidi.larson@sakilacustomer.org|
|        271 | Penny      | Neal      | penny.neal@sakilacustomer.org|
|        315 | Kenneth    | Gooden    | kenneth.gooden@sakilacustomer.org|
|        368 | Harry      | Arce      | harry.arce@sakilacustomer.org|
|        406 | Nathan     | Runyon    | nathan.runyon@sakilacustomer.org|
|        446 | Theodore   | Culp      | theodore.culp@sakilacustomer.org|
|        482 | Maurice    | Crawley   | maurice.crawley@sakilacustomer.org|
|        510 | Ben        | Easter    | ben.easter@sakilacustomer.org|
|        534 | Christian  | Jung      | christian.jung@sakilacustomer.org|
|        558 | Jimmie     | Eggleston | jimmie.eggleston@sakilacustomer.org|
|        592 | Terrance   | Roush     | terrance.roush@sakilacustomer.org|

To perform this query, the query planner needs to scan the `customer` table as shown in the following `EXPLAIN` statement:

```SQL
EXPLAIN
SELECT customer_id,
       first_name,
       last_name,
       email
  FROM customer
 WHERE active = 0;
```

```console
QUERY PLAN
-----------------------------------------------------------
Seq Scan on customer  (cost=0.00..16.49 rows=15 width=49)
Filter: (active = 0)
(2 rows)
```

You can optimize this query by creating an **index** for the `active` column as follows:

```SQL
CREATE INDEX idx_customer_active
ON customer(active);
```

This index fulfills its purpose, however, **it includes many rows that are never searched**, namely `all the active customers`.

To define an **index** that `includes only inactive customers`, you use the following statement:

```SQL
CREATE INDEX idx_customer_inactive
ON customer(active)
WHERE active = 0;
```

From now on, PostgreSQL will consider the **partial index** whenever the `WHERE` clause **appears in a query**:

```SQL
EXPLAIN
SELECT customer_id,
       first_name,
       last_name,
       email
  FROM customer
 WHERE active = 0;
```

```console
QUERY PLAN
---------------------------------------------------------------------------------------
Index Scan using idx_customer_active on customer  (cost=0.28..12.30 rows=15 width=49)
Index Cond: (active = 0)
(2 rows)
```

The syntax for defining a partial index is quite straightforward:

```SQL
CREATE INDEX index_name
ON table_name(column_list)
WHERE condition;
```

In this syntax, the `WHERE` clause specifies which rows should be added to the index.
