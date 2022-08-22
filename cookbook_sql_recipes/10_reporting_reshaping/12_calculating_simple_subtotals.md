# Calculating Simple Subtotals

For the purposes of this recipe, a `simple subtotal` is defined as a result set that **contains values from the aggregation of one column** `along with` a **grand total value for the table**.

## Problem

An example would be a result set that `sums the salaries` in table `EMP` **by JOB** and that also includes the `sum of all salaries` **in table** `EMP`.

The `summed salaries` **by JOB** are the `subtotals`, and the `sum of all salaries` **in table** `EMP` is the `grand total`.

Such a result set should look as follows:

|job    |  sal|
|:---------:|:----:|
|CLERK     |  4150|
|PRESIDENT |  5000|
|SALESMAN  |  5600|
|ANALYST   |  6000|
|MANAGER   |  8275|
|TOTAL     | 29025|

## Solution

The [ROLLUP](https://github.com/lpinzari/sql-psql-udy/blob/master/04_sql_aggregations/13_rollup.md) extension to the `GROUP BY` clause solves this problem perfectly. If `ROLLUP` is not available for your RDBMS, you can solve the problem, albeit with more difficulty, using a scalar subquery or a `UNION` query.

```SQL
SELECT COALESCE(job,'TOTAL') AS job,
       SUM(sal) AS sal
  FROM emp
 GROUP BY ROLLUP(job)
 ORDER BY sal;
```

- **Solution 2**:

```SQL
WITH subtotals AS (
  SELECT job,
         SUM(sal) AS sal
    FROM emp
   GROUP BY job
),
grandtotal AS (
  SELECT 'TOTAL' AS job,
         SUM(sal) AS sal
    FROM emp
)
SELECT *
  FROM subtotals
UNION ALL
SELECT *
  FROM grandtotal; 
```

## Discussion

The first step is to use the aggregate function `SUM`, grouping by `JOB` in order to sum the `salaries by JOB`:

```SQL
SELECT job,
       SUM(sal) AS sal
  FROM emp
 GROUP BY job
 ORDER BY sal;
```

|job    | sal|
|:--------:|:---:|
|CLERK     | 4150|
|PRESIDENT | 5000|
|SALESMAN  | 5600|
|ANALYST   | 6000|
|MANAGER   | 8275|

The next step is to use the `ROLLUP` extension to `GROUP BY` to produce a grand total for all salaries along with the subtotals for each `JOB`:

```SQL
SELECT job,
       SUM(sal) AS sal
  FROM emp
 GROUP BY ROLLUP(job)
 ORDER BY sal;
```

|job    |  sal|
|:--------:|:----:|
|CLERK     |  4150|
|PRESIDENT |  5000|
|SALESMAN  |  5600|
|ANALYST   |  6000|
|MANAGER   |  8275|
|       | 29025|

The last step is to use the `COEALESCE` function against the `JOB` column. If the value of `JOB` is `NULL`, the value for `SAL` is the grand total created by `ROLLUP`. If the value of `JOB` is not `NULL`, the value for SAL is the result of the “regular” `GROUP BY`, not the `ROLLUP`:

```SQL
SELECT COALESCE(job,'TOTAL') AS job,
       SUM(sal) AS sal
  FROM emp
 GROUP BY ROLLUP(job)
 ORDER BY sal;
```
