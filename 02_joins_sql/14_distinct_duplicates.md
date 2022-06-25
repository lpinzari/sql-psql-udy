# DISTINCT

A significant difference between sql and relational algebra is the management of **duplicates**.

- In `algebra` , a table is seen as a relation from the mathematical point of view, and thus as **a set of elements (tuples) different from each other**.

- In `sql` a table can have many rows with the same values for all their attributes. These are known as **duplicates**.


For emulating the behaviour of relational algebra in sql, it would be necessary to eliminate all the duplicates each time a projection operation is executed. However, the removal of duplicates is time consuming and often unnecessary, in that frequently the result contains no duplicates.

For example, when the result includes a key for every table that appears in the from clause, the resulting table cannot contain identical rows. For this reason it was decided to allow the presence of duplicates in sql, leaving it to the person writing the query to specify when the removal of duplicates is necessary.

The elimination of duplicates is specified by the keyword `DISTINCT`, placed immediately after the keyword `SELECT`. The syntax also allows for the specification of the keyword `ALL` in place of distinct, indicating the requirement that the duplicates should be retained. The use of the word all is optional, in that **the conservation of duplicates constitutes the default option**.

## Introduction to PostgreSQL SELECT DISTINCT clause

The `DISTINCT` clause is used in the `SELECT` statement to remove duplicate rows from a result set. The `DISTINCT` clause keeps **one row for each group of duplicates**. The `DISTINCT` clause can be applied to one or more columns in the select list of the SELECT statement.

The following illustrates the syntax of the `DISTINCT` clause:

**SQL**
```SQL
SELECT DISTINCT column1
  FROM table_name;
```

In this statement, the values in the `column1` column are used to evaluate the duplicate.

If you specify **multiple columns**, the `DISTINCT` clause will evaluate the duplicate based on the **combination of values of these columns**.

**SQL**
```SQL
SELECT DISTINCT column1, column2
FROM table_name;
```

In this case, the combination of values in both `column1` and `column2` columns will be used for evaluating the duplicate.

PostgreSQL also provides the `DISTINCT ON` (expression) **to keep the “first” row of each group of duplicates** using the following syntax:

**SQL**
```SQL
SELECT DISTINCT ON (column1) column_alias, column2
  FROM table_name
 ORDER BY column1, column2;
```

The order of rows returned from the `SELECT` statement is unspecified therefore the “first” row of each group of the duplicate is also unspecified.

It is a good practice to **always use the** `ORDER BY` **clause with the** `DISTINCT ON(expression)` **to make the result set predictable**.

Notice that the `DISTINCT ON` expression **must match the leftmost expression in the** `ORDER BY` clause.

### SQL DISTINCT and NULL

In the database, `NULL` means unknown or missing data.

Unlike values like numbers, strings, dates, etc. NULL does not equal anything, even itself. The following expression will return unknown (or NULL):

`NULL=NULL`

Typically, the DISTINCT operator treats all NULL the same. Therefore, the `DISTINCT` **operator keeps only one** `NULL` **in the result set**.

## PostgreSQL SELECT DISTINCT examples

Let’s create a new table called `distinct_demo` and insert data into it for practicing the `DISTINCT` clause.

First, use the following `CREATE TABLE` statement to create the `distinct_demo` table that consists of three columns: `id`, `bcolorand` `fcolor`.

**SQL**
```SQL
CREATE TABLE distinct_demo (
        id serial NOT NULL PRIMARY KEY,
        bcolor VARCHAR,
        fcolor VARCHAR
);
```

Second, insert some rows into the `distinct_demo` table using the following `INSERT` statement:

```console
uniy=# INSERT INTO distinct_demo (bcolor, fcolor)
uniy-# VALUES
uniy-#        ('red', 'red'),
uniy-#        ('red', 'red'),
uniy-#        ('red', NULL),
uniy-#        (NULL, 'red'),
uniy-#        ('red', 'green'),
uniy-#        ('red', 'blue'),
uniy-#        ('green', 'red'),
uniy-#        ('green', 'blue'),
uniy-#        ('green', 'green'),
uniy-#        ('blue', 'red'),
uniy-#        ('blue', 'green'),
uniy-#        ('blue', 'blue');
INSERT 0 12
```

Third, query the data from the `distinct_demo` table using the `SELECT` statement:


**SQL**
```SQL
SELECT id, bcolor, fcolor
  FROM distinct_demo;
```

|id | bcolor | fcolor|
|:--:|:-----:|:-------:|
| 1 | red    | red|
| 2 | red    | red|
| 3 | red    | NULL|
| 4 | NULL   | red|
| 5 | red    | green|
| 6 | red    | blue|
| 7 | green  | red|
| 8 | green  | blue|
| 9 | green  | green|
|10 | blue   | red|
|11 | blue   | green|
|12 | blue   | blue|



**Query**
```console
uniy=# \pset null NULL
Null display is "NULL".
uniy=# SELECT id, bcolor, fcolor
uniy-#   FROM distinct_demo;
 id | bcolor | fcolor
----+--------+--------
  1 | red    | red
  2 | red    | red
  3 | red    | NULL
  4 | NULL   | red
  5 | red    | green
  6 | red    | blue
  7 | green  | red
  8 | green  | blue
  9 | green  | green
 10 | blue   | red
 11 | blue   | green
 12 | blue   | blue
(12 rows)
```

## PostgreSQL DISTINCT one column example

The following statement selects unique values in the  `bcolor` column from the `t1` table and sorts the result set in alphabetical order by using the `ORDER BY` clause.

**SQL**
```SQL
SELECT DISTINCT bcolor
  FROM distinct_demo
 ORDER BY bcolor;
```

**Results**

|bcolor|
|:------:|
|blue|
|green|
|red|
|NULL|


**Query**

```console
uniy=# SELECT DISTINCT bcolor
uniy-#   FROM distinct_demo
uniy-#  ORDER BY bcolor;
 bcolor
--------
 blue
 green
 red
 NULL
(4 rows)
```

## PostgreSQL DISTINCT multiple columns

The following statement demonstrates how to use the `DISTINCT` clause on multiple columns:

**SQL**
```SQL
SELECT DISTINCT bcolor, fcolor
  FROM distinct_demo
 ORDER BY bcolor, fcolor;
```

**Results**

|bcolor | fcolor|
|:-----:|:------:|
|**blue**   | **blue**|
|blue   | green|
|blue   | red|
|**green**  | **blue**|
|green  | green|
|green  | red|
|**red**    | **blue**|
|red    | green|
|red    | red|
|red    | NULL|
|**NULL**   | **red**|



**Query**

```console
uniy=# SELECT DISTINCT bcolor, fcolor
uniy-#   FROM distinct_demo
uniy-#  ORDER BY bcolor, fcolor;
 bcolor | fcolor
--------+--------
 blue   | blue
 blue   | green
 blue   | red
 green  | blue
 green  | green
 green  | red
 red    | blue
 red    | green
 red    | red
 red    | NULL
 NULL   | red
(11 rows)
```

Because we specified both `bcolor` and `fcolor` columns in the `SELECT DISTINCT` clause, PostgreSQL **combined the values in both** `bcolor` and `fcolor` columns **to evaluate the uniqueness of the rows**.

The query returns the **unique combination of** `bcolor` and `fcolor` from the `distinct_demo` table. Notice that the `distinct_demo` table has two rows with red value in both  `bcolor` and  `fcolor` columns. When we applied the `DISTINCT` to both columns, one row was removed from the result set because it is the duplicate.

## PostgreSQL DISTINCT ON example

The following statement sorts the result set by the  `bcolor` and  `fcolor`, and then for each group of duplicates, **it keeps the first row in the returned result set**.

**SQL**
```SQL
SELECT DISTINCT ON (bcolor) bcolor, fcolor
  FROM distinct_demo
 ORDER BY bcolor, fcolor;
```

**Results**

|bcolor | fcolor|
|:-----:|:------:|
|blue   | blue|
|green  | blue|
|red    | blue|
|NULL   | red|


**Query**
```console
uniy=# SELECT DISTINCT ON (bcolor) bcolor, fcolor
uniy-#   FROM distinct_demo
uniy-#  ORDER BY bcolor, fcolor;
 bcolor | fcolor
--------+--------
 blue   | blue
 green  | blue
 red    | blue
 NULL   | red
(4 rows)
```
