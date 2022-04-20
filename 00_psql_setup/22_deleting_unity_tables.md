# PostgreSQL DELETE JOIN

In this lesson, you will learn how to use the PostgreSQL DELETE statement to emulate delete join operations.

## Introduction to PostgreSQL DELETE statement with USING clause

PostgreSQL doesn’t support the `DELETE JOIN` statement. However, it does support the `USING` clause in the `DELETE` statement that provides similar functionality as the `DELETE JOIN`.

The following shows the syntax of the `DELETE` statement with the `USING` **clause**:

```console
DELETE FROM table_name1
       USING table_expression
       WHERE condition
RETURNING returning_columns;
```

In this syntax:

1. First, specify the *table expression* after the `USING` keyword. It can be one or more tables.
2. Then, use columns from the tables that appear in the `USING` clause in the `WHERE` clause for joining data.

For example, the following statement uses the `DELETE` statement with the `USING` clause to **delete data from** `t1` that **has the same** `id` as `t2`:

```console
DELETE FROM t1
       USING t2
       WHERE t1.id = t2.id;
```

### Example: Delete Join

Let’s take a look at an example.

First, use the following statements to create two tables: **contacts** and **blacklist**:

```console
DROP TABLE IF EXISTS contacts;
CREATE TABLE contacts(
   contact_id serial PRIMARY KEY,
   first_name varchar(50) NOT NULL,
   last_name varchar(50) NOT NULL,
   phone varchar(15) NOT NULL
);


DROP TABLE IF EXISTS blacklist;
CREATE TABLE blacklist(
    phone varchar(15) PRIMARY KEY
);


INSERT INTO contacts(first_name, last_name, phone)
VALUES ('John','Doe','(408)-523-9874'),
       ('Jane','Doe','(408)-511-9876'),
       ('Lily','Bush','(408)-124-9221');


INSERT INTO blacklist(phone)
VALUES ('(408)-523-9874'),
       ('(408)-511-9876');
```

**contacts** table.

|contact_id | first_name | last_name |     phone|
|:----------|:----------:|:---------:|---------:|
|1          | John       | Doe       | **(408)-523-9874**|
|2          | Jane       | Doe       | **(408)-511-9876**|
|3          | Lily       | Bush      | (408)-124-9221|

**blacklist** table.

|phone|
|:----:|
|**(408)-523-9874**|
|**(408)-511-9876**|

Second, delete the **contacts** in the contacts table **with the phone number exists** in the `blacklist` table:

```console
uniy=> DELETE FROM contacts
uniy->        USING blacklist
uniy->        WHERE contacts.phone = blacklist.phone
uniy-> RETURNING *;
 contact_id | first_name | last_name |     phone      |     phone
------------+------------+-----------+----------------+----------------
          1 | John       | Doe       | (408)-523-9874 | (408)-523-9874
          2 | Jane       | Doe       | (408)-511-9876 | (408)-511-9876
(2 rows)

DELETE 2
```

Third, query data from the **contacts** table:

```console
uniy=> SELECT * FROM contacts;
 contact_id | first_name | last_name |     phone
------------+------------+-----------+----------------
          3 | Lily       | Bush      | (408)-124-9221
(1 row)
```

## Delete join using a subquery

The `USING` clause is not a part of the SQL standard. It means that the `USING` **clause may not available in other database systems**.

If you plan to make your application compatible with other database products, you should not use the `USING` clause in the `DELETE` statement. Instead, **you can use a subquery**.

The following statement uses the `DELETE` statement **to delete all contacts whose phones are in the** `blacklist` **table**:

```console
uniy=> DELETE FROM contacts
uniy->        WHERE phone IN (
uniy(>              SELECT phone
uniy(>                FROM blacklist)
uniy-> RETURNING *;
 contact_id | first_name | last_name |     phone
------------+------------+-----------+----------------
          4 | John       | Doe       | (408)-523-9874
          5 | Jane       | Doe       | (408)-511-9876
(2 rows)

DELETE 2
```

In this example, the subquery returns a list of phones from the blacklist table and the `DELETE` statement deletes the contacts whose phones match with the phones returned by the subquery.
