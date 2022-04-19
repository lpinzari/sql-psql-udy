# Deleting Records From a Table

So far we have explained how to add data to tables and how to change data. What remains is to discuss **how to remove data that is no longer needed**. Just as adding data is only possible in whole rows, **you can only remove entire rows from a table**.

In the previous section we explained that SQL does not provide a way to directly address individual rows. Therefore, **removing rows can only be done by specifying conditions that the rows to be removed have to match**. If you have a primary key in the table then you can specify the exact row. But you can also remove groups of rows matching a condition, **or you can remove all rows in the table at once**.

The general form of the satement used, `DELETE`, is:

```console
DELETE FROM <table>
      WHERE <pedicate>;
```

When this statement is used, `<table>` is replaced by the name of the table from which the records are to be deleted. All records for which the `<predicate>` is TRUE will be deleted. (As we will describe shortly, the WHERE clause can sometimes be omitted.) In some ways, `DELETE` is similar to `SELECT`. Instead of returning the selected records, however, `DELETE` removes them from the table.

## PostgreSQL DELETE statement

The PostgreSQL `DELETE` statement allows you to delete one or more rows from a table.

The following shows basic syntax of the `DELETE` statement:

```console
DELETE FROM table_name
      WHERE condition;
```

In this syntax:

1. First, specify the name of the table from which you want to delete data after the `DELETE FROM` keywords.
2. Second, use a condition in the `WHERE` clause to specify which rows from the table to delete.

The `WHERE` clause **is optional**. **If you omit the** `WHERE` clause, the `DELETE` statement **will delete all rows in the table**.

The DELETE statement returns the number of rows deleted. It returns zero if the DELETE statement did not delete any row.

To return the deleted row(s) to the client, you use the `RETURNING` clause as follows:

```console
DELETE FROM table_name
      WHERE condition
RETURNING (select_list | *)
```

The asterisk (*) allows you to return all columns of the deleted row from the `table_name`.

To return specific columns, you specify them after the `RETURNING` keyword.

> Note that the DELETE statement only removes data from a table. It doesn’t modify the structure of the table. If you want to change the structure of a table such as removing a column, you should use the ALTER TABLE statement.

## PostgreSQL DELETE to delete one row from the table

We will use the database tables of the previous [section](./18_updating_unity_tables.md) for the demonstration:

![20 update](./images/20_update.png)

The **products** table that stores the product data. The **products** table has the foreign key column `segment_id` that links to the `id` of the **product_segments** table.

**product_segments**

|id |   segment    | discount|
|:--|:------------:|--------:|
|1  | Grand Luxury |     0.05|
|2  | Luxury       |     0.06|
|3  | Mass         |     0.10|

**products**

|id |           name            | price  | net_price | segment_id|
|:---|:-------------------------|:------:|:---------:|----------:|
|1   | diam                      | 804.89 |    764.65 |          1|
|2   | vestibulum aliquet        | 228.55 |    205.70 |          3|
|3   | lacinia erat              | 366.45 |    344.46 |          2|
|4   | scelerisque quam turpulis | 145.33 |    130.80 |          3|
|5   | justo lacinia             | 551.77 |    518.66 |          2|
|6   | ultrices mattis odio      | 261.58 |    235.42 |          3|
|7   | hendrerit                 | 519.62 |    488.44 |          2|
|8   | in hac habitasse          | 843.31 |    801.14 |          1|
|9   | orci eget orci            | 254.18 |    228.76 |          3|
|10  | pellentesque              | 427.78 |    402.11 |          2|
|11  | sit amet nunc             | 936.29 |    889.48 |          1|
|12  | sed vestibulum            | 910.34 |    864.82 |          1|
|13  | turpis eget               | 208.33 |    187.50 |          3|
|14  | cursus vestibulum         | 985.45 |    936.18 |          1|
|15  | orci nullam               | 841.26 |    799.20 |          1|
|16  | est quam pharetra         | 896.38 |    851.56 |          1|
|17  | posuere                   | 575.74 |    541.20 |          2|
|18  | ligula                    | 530.64 |    498.80 |          2|
|19  | convallis                 | 892.43 |    847.81 |          1|
|**20**  | **nulla elit ac**             | **161.71** |    **145.54** |          **3**|

The following statement uses the `DELETE` statement **to delete one row** with the id `20` from the `products` table:

```console
DELETE FROM products
      WHERE id = 20;
```

Let's execute in the `psql` prompt.

```console
uniy=> DELETE FROM products
uniy->       WHERE id = 20;
DELETE 1
```

The statement returns 1 indicated that one row has been deleted.

```console
uniy=> SELECT * FROM products;
 id |           name            | price  | net_price | segment_id
----+---------------------------+--------+-----------+------------
  1 | diam                      | 804.89 |    764.65 |          1
  2 | vestibulum aliquet        | 228.55 |    205.70 |          3
  3 | lacinia erat              | 366.45 |    344.46 |          2
  4 | scelerisque quam turpulis | 145.33 |    130.80 |          3
  5 | justo lacinia             | 551.77 |    518.66 |          2
  6 | ultrices mattis odio      | 261.58 |    235.42 |          3
  7 | hendrerit                 | 519.62 |    488.44 |          2
  8 | in hac habitasse          | 843.31 |    801.14 |          1
  9 | orci eget orci            | 254.18 |    228.76 |          3
 10 | pellentesque              | 427.78 |    402.11 |          2
 11 | sit amet nunc             | 936.29 |    889.48 |          1
 12 | sed vestibulum            | 910.34 |    864.82 |          1
 13 | turpis eget               | 208.33 |    187.50 |          3
 14 | cursus vestibulum         | 985.45 |    936.18 |          1
 15 | orci nullam               | 841.26 |    799.20 |          1
 16 | est quam pharetra         | 896.38 |    851.56 |          1
 17 | posuere                   | 575.74 |    541.20 |          2
 18 | ligula                    | 530.64 |    498.80 |          2
 19 | convallis                 | 892.43 |    847.81 |          1
(19 rows)
```
If we try now to delete a record from the **products** table with `id` equals to `20`, the output of the `DELETE` statement must return 0, since the row with id equals to `20` does not exist.

```console
uniy=> DELETE FROM products
uniy->       WHERE id = 20;
DELETE 0
```

## PostgreSQL DELETE to delete a row and return the deleted row

The following statement deletes the row with **id** `19` and returns the deleted row to the client:

```console
uniy=> DELETE FROM products
uniy->       WHERE id = 19
uniy-> RETURNING *;
 id |   name    | price  | net_price | segment_id
----+-----------+--------+-----------+------------
 19 | convallis | 892.43 |    847.81 |          1
(1 row)

DELETE 1
```

## PostgreSQL DELETE to delete multiple rows from the table

The following statement deletes all the `Grand Luxury` products,`segment_is` is  `1`, from the **products** table.

|id |           name            | price  | net_price | segment_id|
|:---|:-------------------------|:------:|:---------:|----------:|
|`1`   | `diam`                      | `804.89` |    `764.65` |          **1**|
|2   | vestibulum aliquet        | 228.55 |    205.70 |          3|
|3   | lacinia erat              | 366.45 |    344.46 |          2|
|4   | scelerisque quam turpulis | 145.33 |    130.80 |          3|
|5   | justo lacinia             | 551.77 |    518.66 |          2|
|6   | ultrices mattis odio      | 261.58 |    235.42 |          3|
|7   | hendrerit                 | 519.62 |    488.44 |          2|
|`8`   | `in hac habitasse`          | `843.31` |    `801.14` |          **1**|
|9   | orci eget orci            | 254.18 |    228.76 |          3|
|10  | pellentesque              | 427.78 |    402.11 |          2|
|`11`  | `sit amet nunc`             | `936.29` |    `889.48` |          **1**|
|`12`  | `sed vestibulum`            | `910.34` |    `864.82` |          **1**|
|13  | turpis eget               | 208.33 |    187.50 |          3|
|`14`  | `cursus vestibulum`         | `985.45` |    `936.18` |          **1**|
|`15`  | `orci nullam`               | `841.26` |    `799.20` |          **1**|
|`16`  | `est quam pharetra`         | `896.38` |    `851.56` |          **1**|
|17  | posuere                   | 575.74 |    541.20 |          2|
|18  | ligula                    | 530.64 |    498.80 |          2|

```console
uniy=> DELETE FROM products
uniy->       WHERE segment_id = 1
uniy-> RETURNING *;
 id |       name        | price  | net_price | segment_id
----+-------------------+--------+-----------+------------
  1 | diam              | 804.89 |    764.65 |          1
  8 | in hac habitasse  | 843.31 |    801.14 |          1
 11 | sit amet nunc     | 936.29 |    889.48 |          1
 12 | sed vestibulum    | 910.34 |    864.82 |          1
 14 | cursus vestibulum | 985.45 |    936.18 |          1
 15 | orci nullam       | 841.26 |    799.20 |          1
 16 | est quam pharetra | 896.38 |    851.56 |          1
(7 rows)

DELETE 7
```

Seven rows from the **products** table have been deleted.

## SQL DELETE rows from related tables

In the previous example, we used the `DELETE` statement to delete all `Grand Luxury` products, `segement_id = 1`, from table **products**. Therefore,  the record with primary key `id` equals to `1` in the table **product_segments** is not referenced anymore by any records in the **products** table.

Consequently, deleting the `Grand Luxury`'s record in the table **product_segements**:

|id |   segment    | discount|
|:--|:------------:|--------:|
|1  | Grand Luxury |     0.05|

Will not have any action on the corresponding **products** table. The obvious reason is that the referential integrity that maintains the correspondence between the primary key record,(`id: 1`), in the **product_segments** table and the records in the **products** table is preserved.

```console
uniy=> DELETE FROM product_segments
uniy->       WHERE id = 1
uniy-> RETURNING *;
 id |   segment    | discount
----+--------------+----------
  1 | Grand Luxury |     0.05
(1 row)

DELETE 1
```

If we run a `SELECT` satetement to list all the rows in the **product_segments** table:

```console
uniy=> SELECT * FROM product_segments;
 id | segment | discount
----+---------+----------
  2 | Luxury  |     0.06
  3 | Mass    |     0.10
(2 rows)
```

We see that the `Grand Luxury` segment is gone. Now, let's say we want to delete the `Luxury` segment from the **product_segments** table.

```console
uniy=> DELETE FROM product_segments
uniy->       WHERE segment = 'Luxury';
ERROR:  update or delete on table "product_segments" violates foreign key constraint "products_segment_id_fkey" on table "products"
DETAIL:  Key (id)=(2) is still referenced from table "products".
```

Because of the `ON DELETE NO ACTION`, PostgreSQL issues a **constraint violation** because the referencing rows of the `id` **2**, (`Luxury`), **still exist in the products table:**

```console
uniy=> SELECT *
uniy->   FROM products
uniy->  WHERE segment_id = 2;
 id |     name      | price  | net_price | segment_id
----+---------------+--------+-----------+------------
  3 | lacinia erat  | 366.45 |    344.46 |          2
  5 | justo lacinia | 551.77 |    518.66 |          2
  7 | hendrerit     | 519.62 |    488.44 |          2
 10 | pellentesque  | 427.78 |    402.11 |          2
 17 | posuere       | 575.74 |    541.20 |          2
 18 | ligula        | 530.64 |    498.80 |          2
(6 rows)
```

This is clear if we execute the `DESCRIBE` table command on the **product_segments** table.

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
    TABLE "products" CONSTRAINT "products_segment_id_fkey" FOREIGN KEY (segment_id) REFERENCES product_segments(id)
```

And the **products** table:

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
    "products_segment_id_fkey" FOREIGN KEY (segment_id) REFERENCES product_segments(id)
```

A solution to this problem is to add a foreign key constraint with **ON DELETE OPTION** to the **products** `child` table.

First, drop existing foreign key constraints "`products_segment_id_fkey`":

```console
ALTER TABLE products
      DROP CONSTRAINT products_segment_id_fkey;
```

Second, add a new foreign key constraint with  **ON DELETE CASCADE** action:

```console
ALTER TABLE products
      ADD CONSTRAINT products_segment_id_fkey
          FOREIGN KEY (segment_id)
          REFERENCES product_segments (id)
          ON DELETE CASCADE;
```

Let's execute the commands in the `psql` prompt:

```console
uniy=> ALTER TABLE products
uniy->       DROP CONSTRAINT products_segment_id_fkey;
ALTER TABLE
uniy=> ALTER TABLE products
uniy->       ADD CONSTRAINT products_segment_id_fkey
uniy->           FOREIGN KEY (segment_id)
uniy->           REFERENCES product_segments (id)
uniy->           ON DELETE CASCADE;
ALTER TABLE
uniy=>
```

Now, before executing the command let's show the rows in the parent and child tables.

**product_segments** parent table.

|id | segment | discount|
|:--|:-------:|--------:|
|**2** | **Luxury**  |     **0.06**|
|3 | Mass    |     0.10|

**products** child table:

|id |           name            | price  | net_price | segment_id|
|:--|:--------------------------|:------:|:---------:|----------:|
|2  | vestibulum aliquet        | 228.55 |    205.70 |          3|
|**3**  | **lacinia erat**      | **366.45** |    **344.46** |          **2**|
|4  | scelerisque quam turpulis | 145.33 |    130.80 |          3|
|**5**  | **justo lacinia**             | **551.77** |    **518.66** |    **2**|
|6  | ultrices mattis odio      | 261.58 |    235.42 |          3|
|**7**  | **hendrerit**         | **519.62** |    **488.44** |          **2**|
|9  | orci eget orci            | 254.18 |    228.76 |          3|
|**10** | **pellentesque**      | **427.78** |    **402.11** |          **2**|
|13 | turpis eget               | 208.33 |    187.50 |          3|
|**17** | **posuere**           | **575.74** |    **541.20** |          **2**|
|**18** | **ligula**            | **530.64** |    **498.80** |          **2**|

Let's execute the `DELETE` statement in the `psql` prompt.

```console
uniy=> DELETE FROM product_segments
uniy->       WHERE id = 2
uniy-> RETURNING *;
 id | segment | discount
----+---------+----------
  2 | Luxury  |     0.06
(1 row)

DELETE 1
```

Let's execute a `SELECT` statement to list the rows in the **products** child table:

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
