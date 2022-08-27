# Inserting a New Record

You want to insert a new record into a table.

## Problem

```console
cookbook=# \d dept
                       Table "public.dept"
 Column |         Type          | Collation | Nullable | Default
--------+-----------------------+-----------+----------+---------
 deptno | integer               |           | not null |
 dname  | character varying(14) |           |          |
 loc    | character varying(13) |           |          |
Indexes:
    "dept_pkey" PRIMARY KEY, btree (deptno)
```

For example, you want to insert a new record into the `DEPT` table. The value for `DEPTNO` should be **50**, `DNAME` should be `PROGRAMMING`, and **LOC** should be `BALTIMORE`.

## Solution

Use the `INSERT` statement with the `VALUES` clause to insert one row at a time:

```SQL
INSERT INTO dept
       (deptno, dname, loc)
VALUES (50,'PROGRAMMING','BALTIMORE');
```

For DB2, SQL Server, PostgreSQL, and MySQL you have the option of inserting one row at a time or multiple rows at a time by including multiple `VALUES` lists:

```SQL
INSERT INTO dept
       (deptno, dname, loc)
VALUES (50,'PROGRAMMING','BALTIMOE'),
       (60,'ELECTRONICS','BALTIMORE');
```

## Discussion

The INSERT statement allows you to create new rows in database tables. The syntax for inserting a single row is consistent across all database brands.

As a shortcut, you can omit the column list in an INSERT statement:

```SQL
INSERT INTO dept
VALUES (50,'PROGRAMMING','BALTIMORE');
```

However, if you do not list your target columns, you must insert into all of the columns in the table and **be mindful of the order of the values in the** `VALUES` list; you must supply values in the same order in which the database displays columns in response to a `SELECT * query`.

Either way, you should be mindful of column constraints because **if you don’t insert into every column**, you are will `create a row` where some values are `null`. This can cause an error if there are columns constrained not to accept nulls.
