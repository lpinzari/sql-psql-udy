# Retrieving all Rows and Columns from a Table

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

## Problem

You have a table and want to see all of the data in it.

## Solution

Use the special `*` character and issue a `SELECT` against the table:

```SQL
SELECT *
  FROM emp;
```

**Output**

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



## Discussion

The character `*` has special meaning in SQL. Using it will return every column for the table specified. Since there is no `WHERE` clause specified, every row will be returned as well. The alternative would be to list each column individually:

```SQL
SELECT empno,
       ename,
         job,
         sal,
         mgr,
    hiredate,
        comm,
      deptno
  FROM emp;
```

In ad hoc queries that you execute interactively, it’s easier to use `SELECT *`. However, when writing program code, it’s better to specify each column individually. The performance will be the same, but by **being explicit you will always know what columns you are returning from the query**.

Likewise, such queries **are easier to understand by people other than yourself** (who may or may not know all the columns in the tables in the query).

Problems with `SELECT *` can also arise if your query is within code, and the program gets a different set of columns from the query than was expected. At least, if you specify all columns and one or more is missing, any error thrown is more likely to be traceable to the specific missing column(s).
