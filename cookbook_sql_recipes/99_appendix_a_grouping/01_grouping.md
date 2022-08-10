# Grouping

Before moving on to window functions, it is crucial that you understand how **grouping works in** SQL — the concept of grouping results in SQL can be difficult to master. The problems stem from not fully understanding how the `GROUP BY` clause works and why certain queries return certain results when using `GROUP BY`.

Simply stated, grouping is a way to **organize like rows together**. When you use `GROUP BY` in a query, `each row` in the result set **is a group** and `represents` **one or more rows with the same values in one or more columns that you specify**. That’s the gist of it.

If a group is simply a unique instance of a row that represents one or more rows with the same value for a particular column (or columns), then practical examples of groups from table `EMP` include
- all employees in `department 10` (the common value for these employees that enables them to be in the same group is `DEPTNO=10`) or
- all clerks (the common value for these employees that enables them to be in the same group is `JOB=CLERK`).

Consider the following queries.

```SQL
SELECT deptno,
       ename
  FROM emp
 WHERE deptno = 10;
```

|deptno | ename|
|:-----:|:-----:|
|    10 | CLARK|
|    10 | KING|
|    10 | MILLER|

The first shows all employees in department 10;

```SQL
SELECT deptno,
       COUNT(*) AS cnt,
       MAX(sal) AS hi_sal,
       MIN(sal) AS lo_sal
  FROM emp
 WHERE deptno = 10
 GROUP BY deptno;
```
|deptno | cnt | hi_sal | lo_sal|
|:-----:|:---:|:------:|:-----:|
|    10 |   3 |   5000 |   1300|

the second query groups the employees in department 10 and returns the following information about the group: the number of rows (members) in the group, the highest salary, and the lowest salary.

If you were not able to group the employees in department 10 together, to get the information in the second query, you would have to manually inspect the rows for that department (trivial if there are only three rows, but what if there were three mil‐ lion rows?). So, why would anyone want to group? Reasons for doing so vary; perhaps you want to see how many different groups exist or how many members (rows) are in each group. As you can see from this simple example, grouping allows you to get information about many rows in a table without having to inspect them one by one.
