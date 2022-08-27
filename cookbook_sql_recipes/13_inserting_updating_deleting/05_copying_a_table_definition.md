# Copying a Table Definition

You want to create a new table having the same set of columns as an existing table.


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

For example, you want to create a copy of the `DEPT` table and call it `DEPT_2`. You do not want to copy the rows, only the column structure of the table.


## Solution

Use the `CREATE TABLE` command with a `subquery` that **returns no rows**:

```SQL
CREATE TABLE dept_2 AS
  SELECT *
    FROM dept
   WHERE 1 = 0;
```

```console
cookbook=# \d dept_2
                      Table "public.dept_2"
 Column |         Type          | Collation | Nullable | Default
--------+-----------------------+-----------+----------+---------
 deptno | integer               |           |          |
 dname  | character varying(14) |           |          |
 loc    | character varying(13) |           |          |
```

You must add the constraint manually.

## Discussion

When using `Create Table As Select` (CTAS), all rows from your query will be used to populate the new table you are creating unless you specify a `false` condition in the `WHERE` clause.

In the solution provided, the expression “`1 = 0`” in the `WHERE` clause of the query causes no rows to be returned. Thus, the result of the CTAS statement is **an empty table** based on the columns in the `SELECT` clause of the query.
