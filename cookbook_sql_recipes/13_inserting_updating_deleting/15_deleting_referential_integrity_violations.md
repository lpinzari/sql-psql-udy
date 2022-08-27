# Deleting Referential Integrity Violations

You want to `delete records` **from a table**

- when `those records` **refer to nonexistent records in some other table**.

## Problem

For example, some employees are assigned to departments that do not exist. You want to delete those employees.

Suppose you have the following employee `emp_2` table:

```console
cookbook=# SELECT * FROM emp_2 ORDER BY deptno;
 empno | ename  |    job    | mgr  |  hiredate  | sal  | comm | deptno
-------+--------+-----------+------+------------+------+------+--------
  7934 | MILLER | CLERK     | 7782 | 2007-01-23 | 1300 |      |     10
  7782 | CLARK  | MANAGER   | 7839 | 2006-06-09 | 2450 |      |     10
  7839 | KING   | PRESIDENT |      | 2006-11-17 | 5000 |      |     10
  7788 | SCOTT  | ANALYST   | 7566 | 2007-12-09 | 3000 |      |     20
  7566 | JONES  | MANAGER   | 7839 | 2006-04-02 | 2975 |      |     20
  7369 | SMITH  | CLERK     | 7902 | 2015-12-17 |  800 |      |     20
  7876 | ADAMS  | CLERK     | 7788 | 2008-01-12 | 1100 |      |     20
  7902 | FORD   | ANALYST   | 7566 | 2006-12-03 | 3000 |      |     20
  7521 | WARD   | SALESMAN  | 7698 | 2006-02-22 | 1250 |  500 |     30
  7844 | TURNER | SALESMAN  | 7698 | 2006-09-08 | 1500 |    0 |     30
  7499 | ALLEN  | SALESMAN  | 7698 | 2006-01-20 | 1600 |  300 |     30
  7698 | BLAKE  | MANAGER   | 7839 | 2006-05-01 | 2850 |      |     30
  7654 | MARTIN | SALESMAN  | 7698 | 2006-09-28 | 1250 | 1400 |     30
  7900 | JAMES  | CLERK     | 7698 | 2006-12-03 |  950 |      |     30
(14 rows)
```

And the following `dept_2` table:

```SQL
CREATE TABLE dept_2 AS
  SELECT *
    FROM dept
   WHERE deptno IN (20,30);
```

```console
cookbook=# SELECT * FROM dept_2;
 deptno |  dname   |   loc
--------+----------+---------
     20 | RESEARCH | DALLAS
     30 | SALES    | CHICAGO
```

The output shows that `deptno` **10** is missing in table `dept_2`. Hence, we want to delete all records in table `emp` where `deptno` is not in table `dept_2`.

The resulting table `emp_2` must be the following:

```console
empno | ename  |   job    | mgr  |  hiredate  | sal  | comm | deptno
-------+--------+----------+------+------------+------+------+--------
 7369 | SMITH  | CLERK    | 7902 | 2015-12-17 |  800 |      |     20
 7499 | ALLEN  | SALESMAN | 7698 | 2006-01-20 | 1600 |  300 |     30
 7521 | WARD   | SALESMAN | 7698 | 2006-02-22 | 1250 |  500 |     30
 7566 | JONES  | MANAGER  | 7839 | 2006-04-02 | 2975 |      |     20
 7654 | MARTIN | SALESMAN | 7698 | 2006-09-28 | 1250 | 1400 |     30
 7698 | BLAKE  | MANAGER  | 7839 | 2006-05-01 | 2850 |      |     30
 7788 | SCOTT  | ANALYST  | 7566 | 2007-12-09 | 3000 |      |     20
 7844 | TURNER | SALESMAN | 7698 | 2006-09-08 | 1500 |    0 |     30
 7876 | ADAMS  | CLERK    | 7788 | 2008-01-12 | 1100 |      |     20
 7900 | JAMES  | CLERK    | 7698 | 2006-12-03 |  950 |      |     30
 7902 | FORD   | ANALYST  | 7566 | 2006-12-03 | 3000 |      |     20
```

## Solution

Use the `NOT EXISTS` predicate with a subquery to test the validity of department numbers:

```SQL
DELETE FROM emp_2
       WHERE NOT EXISTS (
         SELECT NULL
           FROM dept_2
          WHERE dept_2.deptno = emp_2.deptno
       );
```

Alternatively, you can write the query using a `NOT IN` predicate:

```SQL
DELETE FROM emp_2
      WHERE deptno NOT IN (SELECT deptno
                             FROM dept_2);
```

## Discussion

Deleting is really all about selecting: the real work lies in writing `WHERE` clause conditions to correctly describe those records that you want to delete.

The `NOT EXISTS` solution uses a correlated subquery to test for the existence of a record in `DEPT` having a `DEPTNO` matching that in a given `EMP` record. If such a record exists, then the `EMP` record is retained. Otherwise, it is deleted. Each `EMP` record is checked in this manner.

The `IN` solution uses a subquery to retrieve a list of valid department numbers. `DEPTNOs` from each `EMP` record are then checked against that list. When an `EMP` record is found with a `DEPTNO` not in the list, the `EMP` record is deleted.
