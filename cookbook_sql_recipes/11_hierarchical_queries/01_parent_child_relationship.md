# Expressing a Parent-Child Relationship

You want to include **parent information along with data from child records**.

```SQL
SELECT *
  FROM emp;
```

|empno | ename  |    job    | mgr  |  hiredate  | sal  | comm | deptno|
|:----:|:------:|:---------:|:----:|:----------:|:----:|:----:|:-----:|
| 7369 | SMITH  | CLERK     | 7902 | 2015-12-17 |  800 |      |     20|
| 7499 | ALLEN  | SALESMAN  | 7698 | 2006-01-20 | 1600 |  300 |     30|
| 7521 | WARD   | SALESMAN  | 7698 | 2006-02-22 | 1250 |  500 |     30|
| 7566 | JONES  | MANAGER   | 7839 | 2006-04-02 | 2975 |      |     20|
| 7654 | MARTIN | SALESMAN  | 7698 | 2006-09-28 | 1250 | 1400 |     30|
| 7698 | BLAKE  | MANAGER   | 7839 | 2006-05-01 | 2850 |      |     30|
| 7782 | CLARK  | MANAGER   | 7839 | 2006-06-09 | 2450 |      |     10|
| 7788 | SCOTT  | ANALYST   | 7566 | 2007-12-09 | 3000 |      |     20|
| 7839 | KING   | PRESIDENT |      | 2006-11-17 | 5000 |      |     10|
| 7844 | TURNER | SALESMAN  | 7698 | 2006-09-08 | 1500 |    0 |     30|
| 7876 | ADAMS  | CLERK     | 7788 | 2008-01-12 | 1100 |      |     20|
| 7900 | JAMES  | CLERK     | 7698 | 2006-12-03 |  950 |      |     30|
| 7902 | FORD   | ANALYST   | 7566 | 2006-12-03 | 3000 |      |     20|
| 7934 | MILLER | CLERK     | 7782 | 2007-01-23 | 1300 |      |     10|

For example, you want to display each employee’s name along with the name of their manager. You want to return the following result set:


|emps_and_mgrs|
|:------------------:|
|SMITH works for FORD|
|ALLEN works for BLAKE|
|WARD works for BLAKE|
|JONES works for KING|
|MARTIN works for BLAKE|
|BLAKE works for KING|
|CLARK works for KING|
|SCOTT works for JONES|
|TURNER works for BLAKE|
|ADAMS works for SCOTT|
|JAMES works for BLAKE|
|FORD works for JONES|
|MILLER works for CLARK|

## Solution

Self-join `EMP` on `MGR` and `EMPNO` to find the name of each employee’s manager. Then use your RDBMS’s supplied function(s) for string concatenation to generate the strings in the desired result set.

```SQL
SELECT e1.ename || ' works for ' || e2.ename AS emps_and_mgrs
  FROM emp e1
 INNER JOIN emp e2 ON e1.mgr = e2.empno;
```

## Discussion

Before starting, examine table `EMP` and the hierarchical relationship between `EMPNO` and `MGR`:

```SQL
SELECT empno, mgr
  FROM emp
 ORDER BY 2;
```

|empno | mgr|
|:----:|:---:|
| 7902 | 7566|
| 7788 | 7566|
| 7521 | 7698|
| 7844 | 7698|
| 7654 | 7698|
| 7900 | 7698|
| 7499 | 7698|
| 7934 | 7782|
| 7876 | 7788|
| 7782 | 7839|
| 7698 | 7839|
| 7566 | 7839|
| 7369 | 7902|
| 7839 ||

If you look carefully, you will see that each value for `MGR` is also an `EMPNO`, meaning the manager of each employee in table `EMP` is also an employee in table `EMP` and not stored somewhere else. The relationship between `MGR` and `EMPNO` is a **parent-child relationship** in that the value for `MGR` **is the most immediate parent for a given** `EMPNO` (it is also possible that the manager for a specific employee can have a manager as well, and those managers can in turn have managers, and so on, creating an` n- tier hierarchy`). If an employee has no manager, then `MGR` is `NULL`.

The key is the join between `MGR` and `EMPNO`. The first step is to build a **Cartesian product** by joining `EMP` to itself (only a portion of the rows returned by the Cartesian product is shown here):

```SQL
SELECT e1.mgr, e2.empno
  FROM emp e1, emp e2
 ORDER BY e1.mgr, e2.empno;
```

```console
|mgr  | empno|
|:---:|:----:|
|7566 |  7369|
|7566 |  7369|
|7566 |  7499|
|7566 |  7499|
|7566 |  7521|
|7566 |  7521|
|7566 |  7566|<--
|7566 |  7566|<--
|7566 |  7654|
|7566 |  7654|
|.... | .... |
|7698 |  7698|<--
|7698 |  7698|<--
|7698 |  7698|<--
|7698 |  7698|<--
|7698 |  7698|<--
|.... | .... |
```

As you can see, by using a Cartesian product you are returning every possible EMPNO/EMPNO combination.
The next step is to filter the results such that you return only each employee and their manager’s EMPNO. Accomplish this by joining on MGR and EMPNO:

```SQL
SELECT e1.mgr, e2.empno
  FROM emp e1, emp e2
 WHERE e1.mgr = e2.empno
 ORDER BY e1.mgr;
```

```console
mgr  | empno
------+-------
7566 |  7566
7566 |  7566
7698 |  7698
7698 |  7698
7698 |  7698
7698 |  7698
7698 |  7698
7782 |  7782
7788 |  7788
7839 |  7839
7839 |  7839
7839 |  7839
7902 |  7902
```

Now that you have each employee and the EMPNO of their manager, you can return the name of each manager. You can use a scalar subquery rather than a self-join to get the answer:


```SQL
select a.ename,
       (select b.ename
          from emp b
         where b.empno = a.mgr) as mgr
from emp a;
```

|ename  |  mgr|
|:-----:|:----:|
|SMITH  | FORD|
|ALLEN  | BLAKE|
|WARD   | BLAKE|
|JONES  | KING|
|MARTIN | BLAKE|
|BLAKE  | KING|
|CLARK  | KING|
|SCOTT  | JONES|
|KING   ||
|TURNER | BLAKE|
|ADAMS  | SCOTT|
|JAMES  | BLAKE|
|FORD   | JONES|
|MILLER | CLARK|
