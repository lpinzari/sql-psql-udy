# Partitions

Use the `PARTITION BY` clause to define **a partition** or **group of rows** to `perform an` **aggregation over**.

As we’ve seen already, if you use `empty parentheses`, then **the entire result set is the** `partition` that **a window function aggregation will be computed over**.

You can think of the `PARTITION BY` clause as a “**moving GROUP BY**” because unlike a traditional `GROUP BY`, a group created by `PARTITION BY` is **not distinct** in a result set. You can use `PARTITION BY` to **compute an aggregation over a defined group of rows** (resetting when a new group is encountered), and rather than having one group represent all instances of that value in the table, each value (each member in each group) is returned.

Consider the following query:

```SQL
SELECT ename,
       deptno,
       COUNT(*) OVER(PARTITION BY deptno) AS cnt
  FROM emp
 ORDER BY 2,1;
```

|ename  | deptno | cnt|
|:-----:|:------:|:---:|
|CLARK  |     10 |   3|
|KING   |     10 |   3|
|MILLER |     10 |   3|
|ADAMS  |     20 |   5|
|FORD   |     20 |   5|
|JONES  |     20 |   5|
|SCOTT  |     20 |   5|
|SMITH  |     20 |   5|
|ALLEN  |     30 |   6|
|BLAKE  |     30 |   6|
|JAMES  |     30 |   6|
|MARTIN |     30 |   6|
|TURNER |     30 |   6|
|WARD   |     30 |   6|

This query still returns **14 rows**, but now the `COUNT` is performed for each department as a result of the `PARTITION BY DEPTNO` clause.

```console
|ename  | deptno | cnt|
|:-----:|:------:|:---:|
|CLARK  |     10 |   3|
|KING   |     10 |   3|   WINDOW 1
|MILLER |     10 |   3|
--------------------------
|ADAMS  |     20 |   5|
|FORD   |     20 |   5|
|JONES  |     20 |   5|   WINDOW 2
|SCOTT  |     20 |   5|
|SMITH  |     20 |   5|
---------------------------
|ALLEN  |     30 |   6|
|BLAKE  |     30 |   6|
|JAMES  |     30 |   6|
|MARTIN |     30 |   6|   WINDOW 3
|TURNER |     30 |   6|
|WARD   |     30 |   6|
```



Each employee in the same department (in the same partition) will have the same value for `CNT`, because the aggregation will not reset (recompute) until a new department is encountered. Also note that you are returning information about each group, along with the members of each group. You can think of the preceding query as a more efficient version of the following:

```SQL
SELECT e.ename,
       e.deptno,
       (SELECT COUNT(*)
          FROM emp d
         WHERE e.deptno = d.deptno) AS cnt
  FROM emp e
 ORDER BY 2,1;
```

Additionally, what’s nice about the `PARTITION BY` clause is that **it performs its computations independently of other window functions**, partitioning by different columns in the same `SELECT` statement.

Consider the following query, which returns each `employee`, their `department`,`the number of employees in their respective department`, their `job`, and `the number of employees with the same job`:

```SQL
SELECT ename,
       deptno,
       COUNT(*) OVER (PARTITION BY deptno) AS dept_cnt,
       job,
       COUNT(*) OVER (PARTITION BY job) AS job_cnt
  FROM emp
 ORDER BY 2;  
```

|ename  | deptno | dept_cnt |    job    | job_cnt|
|:------:|:------:|:--------:|:---------:|:-------:|
| MILLER |     10 |        3 | CLERK     |       4|
| CLARK  |     10 |        3 | MANAGER   |       3|
| KING   |     10 |        3 | PRESIDENT |       1|
| ADAMS  |     20 |        5 | CLERK     |       4|
| JONES  |     20 |        5 | MANAGER   |       3|
| SCOTT  |     20 |        5 | ANALYST   |       2|
| FORD   |     20 |        5 | ANALYST   |       2|
| SMITH  |     20 |        5 | CLERK     |       4|
| BLAKE  |     30 |        6 | MANAGER   |       3|
| JAMES  |     30 |        6 | CLERK     |       4|
| ALLEN  |     30 |        6 | SALESMAN  |       4|
| WARD   |     30 |        6 | SALESMAN  |       4|
| TURNER |     30 |        6 | SALESMAN  |       4|
| MARTIN |     30 |        6 | SALESMAN  |       4|

In this result set, you can see that employees in the same department have the same value for `DEPT_CNT`,

Departments
- 10: 3 employees
- 20: 5 employees
- 30: 6 employees

jobs
- CLERK: 4 employees
- MANAGER: 3 employees
- ANALYST: 2 employees
- SALESMAN: 4 employees

and that employees who have the same job position have the same value for JOB_CNT.

By now it should be clear that the PARTITION BY clause works like a GROUP BY clause, but it does so **without being affected by the other items in the** `SELECT` clause and without requiring you to write a `GROUP BY` clause.
