# Copying Rows from One Table into Another

You want to **copy rows from one table** `to` **another by using a query**.

The query may be `complex` or `simple`, but ultimately **you want the result to be inserted into another tbale**.

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

For example, you want to copy rows from the `DEPT` table to the `DEPT_EAST` table. The `DEPT_EAST` table has already been created with the same structure (same columns and data types) as `DEPT` and is currently empty.

```SQL
CREATE TABLE dept_east (
  deptno INTEGER PRIMARY KEY,
  dname VARCHAR(14),
  loc VARCHAR(13)
);
```

## Solution

Use the `INSERT` statement followed by a query to produce the rows you want:

```SQL
INSERT INTO dept_east
       (deptno, dname, loc)
 SELECT deptno, dname, loc
   FROM dept
  WHERE loc IN ('NEW YORK', 'BOSTON');
```

```SQL
SELECT * FROM dept_east;
```

|deptno |   dname    |   loc|
|:------:|:---------:|:---------:|
|    10 | ACCOUNTING | NEW YORK|
|    40 | OPERATIONS | BOSTON|

## Discussion

Simply follow the `INSERT` statement with a query that returns the desired rows. If you want to copy all rows from the source table, exclude the WHERE clause from the query. Like a regular insert, you do not have to explicitly specify which columns you are inserting into.

But if you do not specify your target columns, you must insert data into all of the table’s columns, and you must be mindful of the order of the values in the `SELECT` list.
