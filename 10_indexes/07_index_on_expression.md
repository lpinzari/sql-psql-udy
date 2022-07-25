# Index on Expression

Normally, you create an index that references one or more columns of a table. But you can also **create an index** `based on an expression that involves table columns`. This index is called an **index on expression**.

The indexes on expressions are also known as **functional-based indexes**.

The syntax for creating an **index on expression** is as follows:

```SQL
CREATE INDEX index_name
ON table_name (expression);
```

In this statement:

- First, specify the name of the index after the `CREATE INDEX` clause.
- Then, form an **expression that involves table columns** of the `table_name`.

Once you define an index expression, PostgreSQL will consider using that index when the expression that defines the index appears in the `WHERE` clause or in the `ORDER BY` clause of the SQL statement.

Note that indexes on expressions **are quite expensive to maintain because PostgreSQL has to evaluate the expression for each row when it is inserted or updated and use the result for indexing**.

Therefore, you should use the indexes on expressions when `retrieval speed` **is more critical** than `insertion and update speed`.

## PostgreSQL index on expression example

Let’s see the `customer` table from the `dvdrental` sample database.

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

The customer table has a `B-Tree` index defined for the `last_name` column. The following query finds customers whose last name is `Purdy`:

```SQL
SELECT customer_id,
       first_name,
       last_name
  FROM customer
 WHERE last_name = 'Purdy';
```

|customer_id | first_name | last_name|
|:----------:|:----------:|:----------:|
|        333 | Andrew     | Purdy|

When executing this query, PostgreSQL uses the `idx_last_name` index as shown in the following `EXPLAIN` statement:

```SQL
EXPLAIN
SELECT customer_id,
       first_name,
       last_name
  FROM customer
 WHERE last_name = 'Purdy';
```

```console
QUERY PLAN
-------------------------------------------------------------------------------
Index Scan using idx_last_name on customer  (cost=0.28..8.29 rows=1 width=17)
Index Cond: ((last_name)::text = 'Purdy'::text)
(2 rows)
```

The following statement that finds customers whose last name is `purdy` in lowercase. However, **PostgreSQL could not utilize the index for lookup**:

```SQL
EXPLAIN
SELECT customer_id,
       first_name,
       last_name
  FROM customer
 WHERE LOWER(last_name) = 'purdy';
```

```console
QUERY PLAN
----------------------------------------------------------
Seq Scan on customer  (cost=0.00..17.98 rows=3 width=17)
Filter: (lower((last_name)::text) = 'purdy'::text)
(2 rows)
```

To improve this query, you can define an index expression like this:

```SQL
CREATE INDEX idx_ic_last_name
ON customer(LOWER(last_name));
```

Now, the query that finds customers based on the last name in a case-insensitive manner will use the index on expression as shown below:

```SQL
EXPLAIN
SELECT customer_id,
       first_name,
       last_name
  FROM customer
 WHERE LOWER(last_name) = 'purdy';
```

```console
QUERY PLAN
-------------------------------------------------------------------------------
Bitmap Heap Scan on customer  (cost=4.30..11.15 rows=3 width=17)
Recheck Cond: (lower((last_name)::text) = 'purdy'::text)
->  Bitmap Index Scan on idx_ic_last_name  (cost=0.00..4.30 rows=3 width=0)
Index Cond: (lower((last_name)::text) = 'purdy'::text)
(4 rows)
```
