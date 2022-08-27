# Inserting into Multiple Tables at Once

You want to `take rows` returned `by a query` and **insert** `those rows into multiple target tables`.

## Problem

For example, you want to insert rows from `DEPT` into tables `DEPT_EAST`, `DEPT_WEST`, and `DEPT_MID`.

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


All three tables have the same structure (same columns and data types) as `DEPT` and are currently empty.

## Solution

The solution is to insert the result of a query into the target tables. The difference from `Recipe 4` is that for this problem you have `multiple target tables`.

```SQL
CREATE TABLE dept_east (
  deptno INTEGER PRIMARY KEY,
  dname VARCHAR(10),
  loc VARCHAR(10) CHECK (loc IN ('NEW YORK', 'BOSTON'))
);
CREATE TABLE dept_mid (
  deptno INTEGER PRIMARY KEY,
  dname VARCHAR(10),
  loc VARCHAR(10) CHECK (loc = 'CHICAGO')
);
CREATE TABLE dept_west (
  deptno INTEGER PRIMARY KEY,
  dname VARCHAR(10),
  loc VARCHAR(10) CHECK (loc = 'DALLAS')
);
```
```SQL
INSERT INTO dept_east
SELECT * FROM dept WHERE loc IN ('NEW YORK', 'BOSTON');

INSERT INTO dept_mid
SELECT * FROM dept WHERE loc = 'CHICAGO';

INSERT INTO dept_west
SELECT * FROM dept WHERE loc = 'DALLAs';
```
