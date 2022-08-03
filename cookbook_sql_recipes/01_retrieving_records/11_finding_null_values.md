# Finding Null Values

Dealing with `NULL` values.

## Problem

You want to **find all rows that are null for a particular column**.

## Solution

To determine whether a value is null, you must use [IS NULL](https://github.com/lpinzari/sql-psql-udy/blob/master/01_basic_sql/19_is_null_not_null.md):

```SQL
SELECT *
  FROM emp
 WHERE comm is null;
```

**Output**

|empno | ename  |    job    |  mgr  |  hiredate  | sal  | comm  | deptno|
|:----:|:------:|:---------:|:------:|:---------:|:----:|:-----:|:------:|
| 7369 | SMITH  | CLERK     |  7902 | 2015-12-17 |  800 | NULL; |     20|
| 7566 | JONES  | MANAGER   |  7839 | 2006-04-02 | 2975 | NULL; |     20|
| 7698 | BLAKE  | MANAGER   |  7839 | 2006-05-01 | 2850 | NULL; |     30|
| 7782 | CLARK  | MANAGER   |  7839 | 2006-06-09 | 2450 | NULL; |     10|
| 7788 | SCOTT  | ANALYST   |  7566 | 2007-12-09 | 3000 | NULL; |     20|
| 7839 | KING   | PRESIDENT | NULL; | 2006-11-17 | 5000 | NULL; |     10|
| 7876 | ADAMS  | CLERK     |  7788 | 2008-01-12 | 1100 | NULL; |     20|
| 7900 | JAMES  | CLERK     |  7698 | 2006-12-03 |  950 | NULL; |     30|
| 7902 | FORD   | ANALYST   |  7566 | 2006-12-03 | 3000 | NULL; |     20|
| 7934 | MILLER | CLERK     |  7782 | 2007-01-23 | 1300 | NULL; |     10|

**(10 rows)**

## Discussion

`NULL` is never equal/not equal to anything, not even itself; therefore, you cannot use `=` or `!=` for testing whether a column is `NULL`. To determine whether a row has `NULL` values, you must use `IS NULL`. You can also use `IS NOT NULL` to find rows without a null in a given column.
