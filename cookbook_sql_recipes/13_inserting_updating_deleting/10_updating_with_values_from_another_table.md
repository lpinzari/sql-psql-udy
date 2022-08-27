# Updating with Values from Another Table

You want to **update rows** in `one table` using **values** `from another`.

## Problem

For example, you have a table called `NEW_SAL`, which holds the new salaries for certain employees. The contents of table `NEW_SAL` are as follows:

```SQL
CREATE TABLE new_sal (
  deptno INTEGER PRIMARY KEY,
  sal INTEGER
);

INSERT INTO new_sal
       (deptno, sal)
VALUES (10, 4000);
```

|deptno | sal|
|:-----:|:----:|
|    10 | 4000|

Column `DEPTNO` is the primary key of table `NEW_SAL`. You want to update the salaries and commission of certain employees in table `EMP` using values table `NEW_SAL` if there is a match between `EMP.DEPTNO` and `NEW_SAL.DEPTNO`, update `EMP.SAL` to `NEW_SAL.SAL`, and update `EMP.COMM` to `50%` of `NEW_SAL.SAL`.

The rows in `EMP` are as follows:

```SQL
SELECT deptno, ename, comm
  FROM emp
 ORDER BY deptno, comm;
```

|deptno | ename  | comm |
|:-----:|:-------:|:---:|
|    10 | MILLER ||
|    10 | CLARK  ||
|    10 | KING   ||
|    20 | SCOTT  ||
|    20 | JONES  ||
|    20 | SMITH  ||
|    20 | ADAMS  ||
|    20 | FORD   ||
|    30 | TURNER |    0|
|    30 | ALLEN  |  300|
|    30 | WARD   |  500|
|    30 | MARTIN | 1400|
|    30 | BLAKE  ||
|    30 | JAMES  ||

The updated table is:

|deptno | ename  | comm|
|:-----:|:------:|:-----:|
|    10 | KING   | 2000|
|    10 | CLARK  | 2000|
|    10 | MILLER | 2000|
|    20 | ADAMS  ||
|    20 | JONES  ||
|    20 | SCOTT  ||
|    20 | FORD   ||
|    20 | SMITH  ||
|    30 | TURNER |    0|
|    30 | ALLEN  |  300|
|    30 | WARD   |  500|
|    30 | MARTIN | 1400|
|    30 | JAMES  ||
|    30 | BLAKE  ||


## Solution

Use a `join` between `NEW_SAL` and `EMP` to find and return the new `COMM` values to the `UPDATE` statement. It is quite common for updates such as this one to be per‐ formed via correlated subquery or alternatively using a `CTE`. Another technique involves creating a `view` (traditional or inline, depending on what your database supports) and then updating that view.

```SQL
UPDATE emp_2
   SET sal = ns.sal,
       comm = ns.sal/2
  FROM new_sal AS ns
 WHERE ns.deptno = emp_2.deptno;  
```

## Discussion

Before discussing the different solutions, it’s worth mentioning something important regarding updates that use queries to supply new values. A `WHERE` clause in the subquery of a correlated update is not the same as the `WHERE` clause of the table being updated.

If you look at the `UPDATE` statement in the “Problem” section, the join on `DEPTNO` between `EMP` and `NEW_SAL` is done and returns rows to the `SET` clause of the `UPDATE` statement. For employees in `DEPTNO 10`, valid values are returned because there is a matching `DEPTNO` in table `NEW_SAL`.

But what about employees in the other departments? `NEW_SAL` does not have any other departments, so the `SAL` and `COMM` for employees in `DEPTNOs 20` and `30` are set to `NULL`. Unless you are doing so via `LIMIT` or `TOP` or whatever mechanism your vendor supplies for limiting the number of rows returned in a result set, the only way to restrict rows from a table in SQL is to use a `WHERE` clause. To correctly perform this `UPDATE`, use a `WHERE` clause on the table being updated along with a `WHERE` clause in the correlated subquery.
