# Destroying (Dropping) Tables

Just as SQL allows new tables to be created, it must provide a way to destroy exisiting tables. This destruction is accomplished by using the `DROP` statement.

The geenral form of `DROP` is:

```console
DROP TABLE <table>;
```

The first two words describe what is to be done while the last, `<table>`, names the table to be deleted. Like `CREATE`, `DROP` returns no results other than a message from SQL indicating that the specified table has been destroyed.

For example, to drop the **students** table in the uniY sample database, you could type:

```console
DROP TABLE students;
```

Similarly, to drop the **teachers** table, the command is:

```console
DROP TABLE teachers;
```

Note that the SQL-92 standard requires adding either `CASCADE` or `RESTRICT` to the end of the `DROP TABLE` command. This option is introduced in the next section of this lesson.

## Introduction to PostgreSQL DROP TABLE statement

To drop a table from the database, you use the `DROP TABLE` statement as follows:

```console
DROP TABLE [IF EXISTS] table_name
[CASCADE | RESTRICT];
```

In this syntax:

1. First, specify the name of the table, `table_name` that you want to drop after the `DROP TABLE` keywords.
2. Second, use the [`IF EXISTS`] option to remove the table only if it exists.

If you **remove a table that does not exist**, PostgreSQL **issues an error**. To avoid this situation, you can use the `IF EXISTS` option.

### Dropping Tables with depend objects

In case the table that you want to remove is used in other objects such as [views](https://www.postgresqltutorial.com/postgresql-views/), [triggers](https://www.postgresqltutorial.com/postgresql-triggers/), functions, and [stored procedures](https://www.postgresql.org/docs/current/sql-createprocedure.html), the `DROP TABLE` **cannot remove the table**. In this case, you have two options:

- The `CASCADE` **option** allows you to remove the table and its dependent objects.
- The `RESTRICT` **option** rejects the removal if there is any object depends on the table. The `RESTRICT` **option is the default** if you don’t explicitly specify it in the `DROP TABLE` statement.

The `DROP TABLE` statement **removes both** `data` and `structure` of a table permanently. Some database systems require the table must be empty before it can be removed from the database. This helps you prevent from accidentally deleting a table that is still in use.

### Dropping Multiple Tables

To remove multiple tables at once, you can place a comma-separated list of tables after the `DROP TABLE` keywords:

```console
DROP TABLE [IF EXISTS]
   table_name_1,
   table_name_2,
   ...
[CASCADE | RESTRICT];
```

Note that you need to have the roles of the superuser, schema owner, or table owner in order to drop tables.

## PostgreSQL DROP TABLE examples

Let’s take some examples of using the PostgreSQL `DROP TABLE` statement.

### Drop a table that does not exist

Let's list all the tables in the uniY sample database:

```console
uniy=> \dt
              List of relations
 Schema |       Name       | Type  |  Owner
--------+------------------+-------+----------
 public | courses          | table | usertest
 public | enrolls          | table | usertest
 public | sections         | table | usertest
 public | students         | table | usertest
 public | teachers         | table | usertest
(9 rows)
```

The following statement removes a non-existing table named **author** in the uniY database:

```console
uniy=> DROP TABLE author;
ERROR:  table "author" does not exist
```

To avoid the error, you can use the `IF EXISTS` option like this.

```console
uniy=> DROP TABLE IF EXISTS author;
NOTICE:  table "author" does not exist, skipping
DROP TABLE
```

As can be seen clearly from the output, PostgreSQL issued a notice instead of an error.

### Drop an existing table

Let's say we have the followig tables in the database:

```console
uniy=> CREATE TABLE product_segments (
uniy(>    id SERIAL PRIMARY KEY,
uniy(>    segment VARCHAR NOT NULL,
uniy(>    discount NUMERIC (4,2)
uniy(> );
CREATE TABLE
uniy=> CREATE TABLE products (
uniy(>    id SERIAL PRIMARY KEY,
uniy(>    name VARCHAR NOT NULL,
uniy(>    price NUMERIC (10,2),
uniy(>    net_price NUMERIC (10,2),
uniy(>    segment_id INT NOT NULL,
uniy(>    FOREIGN KEY (segment_id) REFERENCES product_segments(id) ON DELETE CASCADE
uniy(> );
CREATE TABLE
```
List all the tables in the database:

```console
uniy=> \dt
              List of relations
 Schema |       Name       | Type  |  Owner
--------+------------------+-------+----------
 public | blacklist        | table | usertest
 public | contacts         | table | usertest
```

**contacts**

```console
uniy=> \d contacts
                                         Table "public.contacts"
   Column   |         Type          | Collation | Nullable |                   Default
------------+-----------------------+-----------+----------+----------------------------------------------
 contact_id | integer               |           | not null | nextval('contacts_contact_id_seq'::regclass)
 first_name | character varying(50) |           | not null |
 last_name  | character varying(50) |           | not null |
 phone      | character varying(15) |           | not null |
Indexes:
    "contacts_pkey" PRIMARY KEY, btree (contact_id)
```

Let's list the records in the `contacts` table.

```console
uniy=> SELECT * FROM contacts;
 contact_id | first_name | last_name |     phone
------------+------------+-----------+----------------
          3 | Lily       | Bush      | (408)-124-9221
(1 row)
```

The `contacts` table is not referenced by any foreign key in other tables of the database. Therefore, we can delete the table using the `DROP TABLE` statement.

```console
uniy=> DROP TABLE contacts;
DROP TABLE
```

If we list the tables in the database:

```console
uniy=> \dt
              List of relations
 Schema |       Name       | Type  |  Owner
--------+------------------+-------+----------
 public | blacklist        | table | usertest
```

We see that the `contacts` table has been destroyed.

```console
uniy=> DROP TABLE IF EXISTS blacklist;
DROP TABLE
```

Similarly we can destroy the remaining table in the database.

## Drop a table that has dependent objects

Let's say we have the following tables in the database:

```console
uniy=> \dt
              List of relations
 Schema |       Name       | Type  |  Owner
--------+------------------+-------+----------
 public | product_segments | table | usertest
 public | products         | table | usertest
```

**product_segments** table.

```console
uniy=> \d product_segments
                                  Table "public.product_segments"
  Column  |       Type        | Collation | Nullable |                   Default
----------+-------------------+-----------+----------+----------------------------------------------
 id       | integer           |           | not null | nextval('product_segments_id_seq'::regclass)
 segment  | character varying |           | not null |
 discount | numeric(4,2)      |           |          |
Indexes:
    "product_segments_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "products" CONSTRAINT "products_segment_id_fkey" FOREIGN KEY (segment_id) REFERENCES product_segments(id) ON DELETE CASCADE
```

The output shows that the **product_segmants** table is referenced by the **products** table.

**products** table.

```console
uniy=> \d products
                                   Table "public.products"
   Column   |       Type        | Collation | Nullable |               Default
------------+-------------------+-----------+----------+--------------------------------------
 id         | integer           |           | not null | nextval('products_id_seq'::regclass)
 name       | character varying |           | not null |
 price      | numeric(10,2)     |           |          |
 net_price  | numeric(10,2)     |           |          |
 segment_id | integer           |           | not null |
Indexes:
    "products_pkey" PRIMARY KEY, btree (id)
Foreign-key constraints:
    "products_segment_id_fkey" FOREIGN KEY (segment_id) REFERENCES product_segments(id) ON DELETE CASCADE
```

The output shows that the **products** table references the **product_segments** table.

Let's list the records in the **product_segments** table.

```console
uniy=> SELECT * FROM product_segments;
 id | segment | discount
----+---------+----------
  3 | Mass    |     0.10
(1 row)
```

**products** table.

```console
uniy=> SELECT * FROM products;
 id |           name            | price  | net_price | segment_id
----+---------------------------+--------+-----------+------------
  2 | vestibulum aliquet        | 228.55 |    205.70 |          3
  4 | scelerisque quam turpulis | 145.33 |    130.80 |          3
  6 | ultrices mattis odio      | 261.58 |    235.42 |          3
  9 | orci eget orci            | 254.18 |    228.76 |          3
 13 | turpis eget               | 208.33 |    187.50 |          3
(5 rows)
```

Let's destroy the **product_segments** table.

```console
uniy=> DROP TABLE IF EXISTS product_segments;
ERROR:  cannot drop table product_segments because other objects depend on it
DETAIL:  constraint products_segment_id_fkey on table products depends on table product_segments
HINT:  Use DROP ... CASCADE to drop the dependent objects too.
```

Because the constraint on the `products` table depends on the `product_segments` table, PostgreSQL issues an error message. The message gives an HINT: `Use DROP ... CASCADE to drop the dependent objects too`.

```console
uniy=> DELETE FROM products;
DELETE 5
uniy=> DROP TABLE IF EXISTS product_segments;
ERROR:  cannot drop table product_segments because other objects depend on it
DETAIL:  constraint products_segment_id_fkey on table products depends on table product_segments
HINT:  Use DROP ... CASCADE to drop the dependent objects too.
```
We still got an error even if we delete all the records in the child table. There are actually three solutions to this problem.

1. Remove the foreign key constraint in the child table and then destroy the parent table.
2. Destroy all the dependent objects first: the child table first and then destroy the parent table.
3. Use the `DROP TABLE` with the `CASCADE` clause option.

### 2: Destroy multiple tables

The following example uses a single `DROP TABLE` statement to drop the **products** (child) and **product_segments** (parent) tables:

```console
uniy=> DROP TABLE IF EXISTS
uniy->            products,
uniy->            product_segments;
DROP TABLE
```

### 3: Destroy table CASCADE

**product_segments** table:

|id |   segment    | discount|
|:---|:-----------:|--------:|
| 1  | Grand Luxury |    0.05|
| 2  | Luxury       |     0.06|

**products** table:

|id |     name     | price  | net_price | segment_id|
|:--|:------------:|:------:|:---------:|----------:|
| 1 | diam         | 804.89 |    764.65 |          1|
| 2 | lacinia erat | 366.45 |    344.46 |          2|


```console
uniy=> DROP TABLE product_segments CASCADE;
NOTICE:  drop cascades to constraint products_segment_id_fkey on table products
DROP TABLE
```

If the `DROP TABLE` statement removes the dependent objects of the table that is being dropped, it will issue a notice like this:

`NOTICE:  drop cascades to constraint products_segment_id_fkey on table products`

However, if we list all the tables in the database:

```console
uniy=> \dt
          List of relations
 Schema |   Name   | Type  |  Owner
--------+----------+-------+----------
 public | products | table | usertest
```

We see that the **products** table is still there !

```console
uniy=> \d products
                                   Table "public.products"
   Column   |       Type        | Collation | Nullable |               Default
------------+-------------------+-----------+----------+--------------------------------------
 id         | integer           |           | not null | nextval('products_id_seq'::regclass)
 name       | character varying |           | not null |
 price      | numeric(10,2)     |           |          |
 net_price  | numeric(10,2)     |           |          |
 segment_id | integer           |           | not null |
Indexes:
    "products_pkey" PRIMARY KEY, btree (id)
```

Clearly, the foreign key constraint has been removed. What are the records in the **products** table ?

```console
uniy=> SELECT * FROM products;
 id |     name     | price  | net_price | segment_id
----+--------------+--------+-----------+------------
  1 | diam         | 804.89 |    764.65 |          1
  2 | lacinia erat | 366.45 |    344.46 |          2
(2 rows)
```

We can delete column `segment_id` in the **products** table since the **product_segments** has been destroyed and this column is not part of the primary key constraint. To drop a column in the table **products** we'll use the [DROP COLUMN](https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-drop-column/) statement.

```console
uniy=> ALTER TABLE products
uniy-> DROP COLUMN segment_id;
ALTER TABLE
uniy=> SELECT * FROM products;
 id |     name     | price  | net_price
----+--------------+--------+-----------
  1 | diam         | 804.89 |    764.65
  2 | lacinia erat | 366.45 |    344.46
(2 rows)
```

Alternatively, if we want to delete both tables with a single `DROP TABLE` statement, we could type:

```console
CREATE TABLE
uniy=> DROP TABLE IF EXISTS
uniy->            product_segments,
uniy->            products
uniy-> CASCADE;
DROP TABLE
```

### Summary

- Use the `DROP TABLE` statement to drop a table.
- Use the `CASCADE` option to drop a table and all of it dependent objects.

In the next lesson we'll be using the `DROP TABLE` statement to destroy all the tables in the **uniY** sample database.
