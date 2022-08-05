# Retrieving Rows from One Table That Do Not Correspond to Rows in Another


You want to find **rows that are in one table that do not have a match in another table, for two tables that have common keys**.

## Problem

For example, you want to find which departments have no employees. The result set should be the following:

|deptno |   dname    |   loc|
|:-----:|:----------:|:--------:|
|    40 | OPERATIONS | BOSTON|

Finding the department each employee works in requires an `equi-join` on `DEPTNO` from `EMP` to `DEPT`. The `DEPTNO` column represents the common value between tables. Unfortunately, an `equi-join` will not show you which department has no employees.

That’s because by `equi-joining` `EMP` and `DEPT` you are returning all rows that satisfy the join condition. Instead, **you want only those rows from** `DEPT` **that do not satisfy the join condition**.

This is a subtly different problem than in the preceding recipe, though at first glance they may seem the same. **The difference is that the preceding recipe yields only a list of department numbers not represented in table** `EMP`.

Using this recipe, however, you **can easily return other columns from** the `DEPT` table; you can return more than just department numbers.

## Solution

Return all rows from one table along with rows from another that may or may not have a match on the common column. Then, keep only those rows with no match.

**DB2, MySQL, PostgreSQL, and SQL Server**

Use an outer join and filter for NULLs (keyword OUTER is optional):

```SQL
SELECT d.*
  FROM dept d
  LEFT JOIN emp e ON (d.deptno = e.deptno)
 WHERE e.deptno IS NULL;
```

## Discussion

This solution works by outer joining and then **keeping only rows that have no match**. This sort of operation is sometimes called an `anti-join`. To get a better idea of how an `anti-join` works, first examine the result set without filtering for `NULLs`:

```SQL
SELECT e.ename,
       e.deptno AS emp_deptno,
       d.*
  FROM dept d
  LEFT JOIN emp e ON (d.deptno = e.deptno);
```

|ename  | emp_deptno | deptno |   dname    |   loc|
|:-----:|:-----------:|:-----:|:----------:|:------:|
|SMITH  |         20 |     20 | RESEARCH   | DALLAS|
|ALLEN  |         30 |     30 | SALES      | CHICAGO|
|WARD   |         30 |     30 | SALES      | CHICAGO|
|JONES  |         20 |     20 | RESEARCH   | DALLAS|
|MARTIN |         30 |     30 | SALES      | CHICAGO|
|BLAKE  |         30 |     30 | SALES      | CHICAGO|
|CLARK  |         10 |     10 | ACCOUNTING | NEW YORK|
|SCOTT  |         20 |     20 | RESEARCH   | DALLAS|
|KING   |         10 |     10 | ACCOUNTING | NEW YORK|
|TURNER |         30 |     30 | SALES      | CHICAGO|
|ADAMS  |         20 |     20 | RESEARCH   | DALLAS|
|JAMES  |         30 |     30 | SALES      | CHICAGO|
|FORD   |         20 |     20 | RESEARCH   | DALLAS|
|MILLER |         10 |     10 | ACCOUNTING | NEW YORK|
|NULL;  |      NULL; |     40 | OPERATIONS | BOSTON|

**(15 rows)**

Notice, the last row has a `NULL` value for `EMP.ENAME` and `EMP_DEPTNO`. That’s because no employees work in department `40`. The solution uses the WHERE clause to keep only rows where `EMP_DEPTNO` is `NULL` (thus keeping only rows from DEPT that have no match in EMP).
