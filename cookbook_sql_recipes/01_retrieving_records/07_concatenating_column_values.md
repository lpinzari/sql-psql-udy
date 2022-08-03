# Concatenating Column Values Problem

```console
cookbook=> \d emp
                        Table "public.emp"
  Column  |         Type          | Collation | Nullable | Default
----------+-----------------------+-----------+----------+---------
 empno    | integer               |           | not null |
 ename    | character varying(10) |           |          |
 job      | character varying(9)  |           |          |
 mgr      | integer               |           |          |
 hiredate | date                  |           |          |
 sal      | integer               |           |          |
 comm     | integer               |           |          |
 deptno   | integer               |           |          |
Indexes:
    "emp_pkey" PRIMARY KEY, btree (empno)
```

You want to **return values in multiple columns as one column**. For example, you would like to produce this result set from a query against the `EMP` table:

```console
    CLARK WORKS AS A MANAGER
    KING WORKS AS A PRESIDENT
    MILLER WORKS AS A CLERK
```

However, the data that you need to generate this result set comes from two different columns, the `ENAME` and `JOB` columns in the `EMP` table:

```SQL
SELECT ename, job
  FROM emp
 WHERE deptno = 10;
```

**Output**

|ename  |    job|
|:-----:|:----------:|
|CLARK  | MANAGER|
|KING   | PRESIDENT|
|MILLER | CLERK|

**(3 rows)**

## Solution

Find and use the **built-in function provided by your** `DBMS` to concatenate values from multiple columns.

### DB2, Oracle, PostgreSQL

These databases use the double vertical bar `||` as the **concatenation operator** or the [CONCAT](https://github.com/lpinzari/sql-psql-udy/blob/master/06_string_functions/04_concat.md) function:

```SQL
SELECT ename || ' WORKS AS A ' || job AS msg
  FROM emp
 WHERE deptno = 10;
```

```SQL
SELECT concat(ename, ' WORKS AS A ',job) AS msg
  FROM emp
 WHERE deptno = 10;
```

**Output**

|msg|
|:-------------------------:|
|CLARK WORKS AS A MANAGER|
|KING WORKS AS A PRESIDENT|
|MILLER WORKS AS A CLERK|

**(3 rows)**

### MySQL

This database supports a function called `CONCAT`:

```SQL
SELECT concat(ename, ' WORKS AS A ',job) AS msg
  FROM emp
 WHERE deptno = 10;
```

### SQL Server

Use the `+` operator for concatenation:

```SQL
SELECT ename + ' WORKS AS A ' + job AS msg
  FROM emp
 WHERE deptno = 10;
```    

## Discussion

Use the `CONCAT` function to concatenate values from multiple columns. The `||` is a shortcut for the `CONCAT` function in DB2, Oracle, and PostgreSQL, while `+` is the shortcut for SQL Server.
