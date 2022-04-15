# PostgreSQL - SERIAL example

In this lesson,  you will learn about the PostgreSQL [SERIAL](https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-serial/) pseudo-type and how to use the `SERIAL` pseudo-type **to define auto-increment columns in tables**.

## Introduction to the PostgreSQL SERIAL pseudo-type

In PostgreSQL, a [sequence](https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-sequences/) is a special kind of database object that generates a sequence of integers. **A sequence is often used as the primary key column in a table**.

When creating a new table, the sequence can be created through the SERIAL pseudo-type. The following statement creates the **fruits** table with the `id` column as the `SERIAL` column:

```console
test=> CREATE TABLE fruits (
test(>   id SERIAL PRIMARY KEY,
test(>   name VARCHAR NOT NULL,
test(>   quantity SMALLINT DEFAULT 0
test(> );
CREATE TABLE
test=> \d fruits
                                  Table "public.fruits"
  Column  |       Type        | Collation | Nullable |              Default
----------+-------------------+-----------+----------+------------------------------------
 id       | integer           |           | not null | nextval('fruits_id_seq'::regclass)
 name     | character varying |           | not null |
 quantity | smallint          |           |          | 0
Indexes:
    "fruits_pkey" PRIMARY KEY, btree (id)

```

To assign the default value for a serial column when you insert row into the table, **you ignore the column name** or use the `DEFAULT` keyword in the `INSERT` statement.

See the following example:

```console
test=> INSERT INTO fruits
test->        (name)
test-> VALUES ('Orange')
test-> RETURNING *;
 id |  name  | quantity
----+--------+----------
  1 | Orange |        0
(1 row)

INSERT 0 1
```

Another insertion.

```console
test=> INSERT INTO fruits
test->        (id, name)
test-> VALUES (DEFAULT,'Apple')
test-> RETURNING id;
 id
----
  2
(1 row)

INSERT 0 1
```

Now, let's list the records in the table.

```console
test=> SELECT *
test-> FROM fruits;
 id |  name  | quantity
----+--------+----------
  1 | Orange |        0
  2 | Apple  |        0
(2 rows)
```

PostgreSQL inserted two rows into the fruits table with the values for the `id` column are `1` and `2`.

```console
test=> INSERT INTO fruits
test->        (id, name, quantity)
test-> VALUES (DEFAULT, 'Apple', DEFAULT)
test-> RETURNING id;
 id
----
  3
(1 row)

INSERT 0 1
```

Let's show the table's records.

```console
test=> SELECT *
test->   FROM fruits;
 id |  name  | quantity
----+--------+----------
  1 | Orange |        0
  2 | Apple  |        0
  3 | Apple  |        0
(3 rows)
```
Now, let's delete the last insertion because is a duplicate name for the `name` record.

```console
test=> DELETE FROM fruits
test->        WHERE id = 3;
DELETE 1
test=> SELECT *
test-> FROM fruits;
 id |  name  | quantity
----+--------+----------
  1 | Orange |        0
  2 | Apple  |        0
(2 rows)
```

Now, what you think would happen if we insert a new record into the table?

```console
test=> INSERT INTO fruits
test->        (id, name, quantity)
test-> VALUES (DEFAULT, 'Orange', DEFAULT)
test-> RETURNING *;
 id |  name  | quantity
----+--------+----------
  4 | Orange |        0
(1 row)

INSERT 0 1
```

The last insertion has a progrssive number `4` although the records in the table are only 3.

```console
uniy=> SELECT *
uniy->   FROM fruits;
 id |  name  | quantity
----+--------+----------
  1 | Orange |        0
  2 | Apple  |        0
  4 | Orange |        0
(3 rows)
```

You can pass a sequence name to the  `currval()` function to get the recent value generated by the sequence. For example, the following statement returns the recent value generated by the `fruits_id_seq` object:

```console
test=> SELECT currval(pg_get_serial_sequence('fruits', 'id'));
 currval
---------
       4
(1 row)
```

The sequence generator operation is not transaction-safe. It means that if two concurrent database connections attempt to get the next value from a sequence, each client will get a different value. If one client rolls back the transaction, the sequence number of that client will be unused, creating a gap in the sequence.