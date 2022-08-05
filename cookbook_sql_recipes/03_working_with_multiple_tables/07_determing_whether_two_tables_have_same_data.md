# Determining Whether Two Tables Have the Same Data Problem

You want to know whether two tables or views have the same data (**cardinality and values**). Consider the following view:

```SQL
CREATE VIEW v AS
    SELECT * FROM emp WHERE deptno != 10
     UNION ALL
    SELECT * FROM emp WHERE ename = 'WARD';
```
```console
cookbook=> SELECT * FROM v;
```

| empno | ename  |   job    | mgr  |  hiredate  | sal  | comm  | deptno|
|:-----:|:-------:|:-------:|:-----:|:---------:|:----:|:------:|:----:|
|  7369 | SMITH  | CLERK    | 7902 | 2015-12-17 |  800 | NULL; |     20|
|  7499 | ALLEN  | SALESMAN | 7698 | 2006-01-20 | 1600 |   300 |     30|
|  **7521** | **WARD**   | SALESMAN | 7698 | 2006-02-22 | 1250 |   500 |     30|
|  7566 | JONES  | MANAGER  | 7839 | 2006-04-02 | 2975 | NULL; |     20|
|  7654 | MARTIN | SALESMAN | 7698 | 2006-09-28 | 1250 |  1400 |     30|
|  7698 | BLAKE  | MANAGER  | 7839 | 2006-05-01 | 2850 | NULL; |     30|
|  7788 | SCOTT  | ANALYST  | 7566 | 2007-12-09 | 3000 | NULL; |     20|
|  7844 | TURNER | SALESMAN | 7698 | 2006-09-08 | 1500 |     0 |     30|
|  7876 | ADAMS  | CLERK    | 7788 | 2008-01-12 | 1100 | NULL; |     20|
|  7900 | JAMES  | CLERK    | 7698 | 2006-12-03 |  950 | NULL; |     30|
|  7902 | FORD   | ANALYST  | 7566 | 2006-12-03 | 3000 | NULL; |     20|
|  **7521** | **WARD**   | SALESMAN | 7698 | 2006-02-22 | 1250 |   500 |     30|

**(12 rows)**

You want to determine whether this view has exactly the same data as table `EMP`. The row for employee `WARD` is duplicated **to show that the solution will reveal not only different data but duplicates as well**. Based on the rows in table `EMP`, the `difference will be the three rows for employees in department` **10** and `the two rows for employee WARD`. You want to return the following result set:

|empno | ename  |    job    |  mgr  |  hiredate  | sal  | comm  | deptno | cnt|
|:----:|:------:|:---------:|:-----:|:----------:|:----:|:-----:|:------:|:--:|
| 7521 | WARD   | SALESMAN  |  7698 | 2006-02-22 | 1250 |   500 |     30 |   2|
| 7782 | CLARK  | MANAGER   |  7839 | 2006-06-09 | 2450 | NULL; |     10 |   1|
| 7521 | WARD   | SALESMAN  |  7698 | 2006-02-22 | 1250 |   500 |     30 |   1|
| 7839 | KING   | PRESIDENT | NULL; | 2006-11-17 | 5000 | NULL; |     10 |   1|
| 7934 | MILLER | CLERK     |  7782 | 2007-01-23 | 1300 | NULL; |     10 |   1|

**(5 rows)**

# Solution

Functions that perform EXCEPT, depending on your DBMS, make the problem of comparing tables a relatively easy one to solve. If your DBMS does not offer such functions, you can use a correlated subquery.

**DB2 and PostgreSQL**

Use the set operations `EXCEPT` and `UNION ALL` to find the difference between view V and table EMP combined with the difference between table EMP and view V:

```SQL
(
  SELECT empno, ename, job, mgr, hiredate, sal, comm, deptno,
         count(*) as cnt
    FROM v
   GROUP BY empno, ename, job, mgr, hiredate, sal, comm, deptno
  EXCEPT
  SELECT empno, ename, job, mgr, hiredate, sal, comm, deptno,
         count(*) as cnt
    FROM emp
   GROUP BY empno, ename, job, mgr, hiredate, sal, comm, deptno
)
UNION ALL
(
  SELECT empno, ename, job, mgr, hiredate, sal, comm, deptno,
         count(*) as cnt
    FROM emp
   GROUP BY empno, ename, job, mgr, hiredate, sal, comm, deptno
  EXCEPT
  SELECT empno, ename, job, mgr, hiredate, sal, comm, deptno,
         count(*) as cnt
    FROM v
   GROUP BY empno, ename, job, mgr, hiredate, sal, comm, deptno
);
```

## Discussion

1. Find rows in view table `v` that do not exist in  emp.

|empno | ename |   job    | mgr  |  hiredate  | sal  | comm | deptno | cnt|
|:----:|:-----:|:--------:|:----:|:----------:|:----:|:----:|:------:|:---:|
| 7521 | WARD  | SALESMAN | 7698 | 2006-02-22 | 1250 |  500 |     30 |   2|

The result set represents a row found in view V that is either not in table EMP, or has a different cardinality than that same row in table EMP. In this case, the duplicate row for employee WARD is found and returned. If you’re still having trouble understanding how the result set is produced, run each query on either side of EXCEPT individally. You’ll notice the only difference between the two result sets is the CNT for employee WARD returned by view V.

2. Combine (UNION ALL) those rows with rows from table `emp` that do not exist in view table `v`.

The portion of the query after the UNION ALL does the opposite of the query pre‐ ceding UNION ALL. The query returns rows in table EMP not in view V:

|empno | ename  |    job    |  mgr  |  hiredate  | sal  | comm  | deptno | cnt|
|:----:|:------:|:---------:|:-----:|:----------:|:----:|:-----:|:------:|:--:|
| 7782 | CLARK  | MANAGER   |  7839 | 2006-06-09 | 2450 | NULL; |     10 |   1|
| 7521 | WARD   | SALESMAN  |  7698 | 2006-02-22 | 1250 |   500 |     30 |   1|
| 7839 | KING   | PRESIDENT | NULL; | 2006-11-17 | 5000 | NULL; |     10 |   1|
| 7934 | MILLER | CLERK     |  7782 | 2007-01-23 | 1300 | NULL; |     10 |   1|

If the tables in question are equal, then no rows are returned. If the tables are different, the rows causing the difference are returned. As an easy first step when comparing tables, you can compare the cardinalities alone rather than including them with the data comparison.

The following query is a simple example of this and will work on all DBMSs:

```SQL
SELECT COUNT(*)
  FROM emp
UNION
SELECT COUNT(*)
  FROM dept;
```

|count|
|:---:|
|    4|
|   14|

Because UNION will filter out duplicates, only one row will be returned if the tables’ cardinalities are the same. Because two rows are returned in this example, you know that the tables do not contain identical rowsets.
