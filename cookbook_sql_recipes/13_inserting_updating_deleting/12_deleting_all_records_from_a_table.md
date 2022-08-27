# Deleting All Records from a Table

You want to delete all the records from a table.

## Problem

Suppose we have the following table:

```console
SELECT * FROM emp_2;

empno | ename  |    job    | mgr  |  hiredate  | sal  | comm | deptno
-------+--------+-----------+------+------------+------+------+--------
 7654 | MARTIN | SALESMAN  | 7698 | 2006-09-28 | 1250 | 1400 |     30
 7499 | ALLEN  | SALESMAN  | 7698 | 2006-01-20 | 1600 |  450 |     30
 7521 | WARD   | SALESMAN  | 7698 | 2006-02-22 | 1250 |  750 |     30
 7844 | TURNER | SALESMAN  | 7698 | 2006-09-08 | 1500 |  100 |     30
 7369 | SMITH  | CLERK     | 7902 | 2015-12-17 |  800 |  500 |     20
 7566 | JONES  | MANAGER   | 7839 | 2006-04-02 | 2975 |  100 |     20
 7698 | BLAKE  | MANAGER   | 7839 | 2006-05-01 | 2850 |  100 |     30
 7782 | CLARK  | MANAGER   | 7839 | 2006-06-09 | 2450 |  100 |     10
 7788 | SCOTT  | ANALYST   | 7566 | 2007-12-09 | 3000 |  100 |     20
 7839 | KING   | PRESIDENT |      | 2006-11-17 | 5000 |  100 |     10
 7876 | ADAMS  | CLERK     | 7788 | 2008-01-12 | 1100 |  100 |     20
 7900 | JAMES  | CLERK     | 7698 | 2006-12-03 |  950 |  500 |     30
 7902 | FORD   | ANALYST   | 7566 | 2006-12-03 | 3000 |  100 |     20
 7934 | MILLER | CLERK     | 7782 | 2007-01-23 | 1300 |  100 |     10
```

You want to delete all records from emp_2;

```console
cookbook=# SELECT * FROM emp_2;
 empno | ename | job | mgr | hiredate | sal | comm | deptno
-------+-------+-----+-----+----------+-----+------+--------
(0 rows)
```

## Solution

Use the `DELETE` command to delete records from a table. For example, to delete all records from `EMP`, use the following:

- **Solution 1**:

```SQL
DELETE FROM emp_2;
```

- **Solution 2**:

Use the `TRUNCATE` command:

```SQL
TRUNCATE TABLE emp_2;
```

## Discussion

When using the `DELETE` command without a `WHERE` clause, you will delete all rows from the table specified. Sometimes `TRUNCATE`, which applies to tables and therefore doesn’t use the `WHERE` clause, **is preferred as it is faster**.
