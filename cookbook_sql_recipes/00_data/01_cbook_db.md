# CookBook SQL Recipes DB

In this section we create a new database called `cookbook`. To create and populate the tables in the `cookbook` database we'll execute an external sql script `cookbook-db.sql`. You can find the file [here](https://github.com/lpinzari/sql-psql-udy/tree/master/data).

For a detailed discussion on how to create a database from  a sql script, please follow this [link](https://github.com/lpinzari/sql-psql-udy/blob/master/00_psql_setup/05_parch_posey.md).

## CREATE DATABASE cookbook

```console
(base) ludo $  psql postgres -U usertest
postgres=> CREATE DATABASE cookbook;
CREATE DATABASE
postgres=> GRANT ALL PRIVILEGES ON DATABASE cookbook to usertest;
GRANT
postgres=> \q
(base) ludo  $  ls cookbook-db.sql
cookbook-db.sql
(base) ludo  $  psql cookbook -U usertest
cookbook=> \i cookbook-db.sql
```

## Tables used in this cookbook

```console
cookbook=> \dt
        List of relations
 Schema | Name | Type  |  Owner
--------+------+-------+----------
 public | dept | table | usertest
 public | emp  | table | usertest
 public | t1   | table | usertest
 public | t10  | table | usertest
 public | t100 | table | usertest
(5 rows)
```

The majority of the examples in this recipes book involve the use of two tables, `emp` and `dept`.

**emp** table:

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

The `emp` table is a simple 14-row table with only numeric, string, and date fields.


**dept** table:

```console
cookbook=> \d dept
                       Table "public.dept"
 Column |         Type          | Collation | Nullable | Default
--------+-----------------------+-----------+----------+---------
 deptno | integer               |           | not null |
 dname  | character varying(14) |           |          |
 loc    | character varying(13) |           |          |
Indexes:
    "dept_pkey" PRIMARY KEY, btree (deptno)
```

The `dept` table is a simple four-row table with only numeric and string fields.

In order to see the NULL values present in the tables, let's execute the following command, `\pset null NULL;`:

```console
cookbook=> \pset null NULL;
Null display is "NULL;".
```

The contents of `emp` and `dept` are shown here, respectively:

```SQL
SELECT *
  FROM emp;
```

**emp** Table:

|empno | ename  |    job    |  mgr  |  hiredate  | sal  | comm  | deptno  |
|:----:|:-------:|:--------:|:-----:|:----------:|:----:|:-----:|:-------:|
| 7369 | SMITH  | CLERK     |  7902 | 2015-12-17 |  800 | NULL; |     20|
| 7499 | ALLEN  | SALESMAN  |  7698 | 2006-01-20 | 1600 |   300 |     30|
| 7521 | WARD   | SALESMAN  |  7698 | 2006-02-22 | 1250 |   500 |     30|
| 7566 | JONES  | MANAGER   |  7839 | 2006-04-02 | 2975 | NULL; |     20|
| 7654 | MARTIN | SALESMAN  |  7698 | 2006-09-28 | 1250 |  1400 |     30|
| 7698 | BLAKE  | MANAGER   |  7839 | 2006-05-01 | 2850 | NULL; |     30|
| 7782 | CLARK  | MANAGER   |  7839 | 2006-06-09 | 2450 | NULL; |     10|
| 7788 | SCOTT  | ANALYST   |  7566 | 2007-12-09 | 3000 | NULL; |     20|
| 7839 | KING   | PRESIDENT | NULL; | 2006-11-17 | 5000 | NULL; |     10|
| 7844 | TURNER | SALESMAN  |  7698 | 2006-09-08 | 1500 |     0 |     30|
| 7876 | ADAMS  | CLERK     |  7788 | 2008-01-12 | 1100 | NULL; |     20|
| 7900 | JAMES  | CLERK     |  7698 | 2006-12-03 |  950 | NULL; |     30|
| 7902 | FORD   | ANALYST   |  7566 | 2006-12-03 | 3000 | NULL; |     20|
| 7934 | MILLER | CLERK     |  7782 | 2007-01-23 | 1300 | NULL; |     10|

**(14 rows)**

```SQL
SELECT *
  FROM dept;
```

|deptno |   dname    |   loc|
|:-----:|:----------:|:--------:|
|    10 | ACCOUNTING | NEW YORK|
|    20 | RESEARCH   | DALLAS|
|    30 | SALES      | CHICAGO|
|    40 | OPERATIONS | BOSTON|

**(4 rows)**

Additionally, you will find four pivot tables used in this book: `t1`, `t10`, `t100`. Because these tables exist only to facilitate pivots, we didn’t give them clever names. The number following the `“T”` in each of the pivot tables signifies **the number of rows in each table**, starting from `1`. For example, here are the values for `T1` and `T10`:

```SQL
SELECT *
  FROM t1;
```

| id|
|:--:|
|  1|

**(1 row)**

```SQL
SELECT *
  FROM t10;
```

| id|
|:--:|
|  1|
|  2|
|  3|
|  4|
|  5|
|  6|
|  7|
|  8|
|  9|
| 10|

**(10 rows)**

The pivot tables are a useful shortcut when we need to create a series of rows to facilitate a query.
