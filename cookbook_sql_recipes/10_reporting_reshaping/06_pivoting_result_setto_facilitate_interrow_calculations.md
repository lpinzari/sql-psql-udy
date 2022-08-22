# Pivoting a Result Set to Facilitate Inter-Row Calculations

You want to make calculations involving data from multiple rows. To make your job easier, you want to **pivot those rows into columns** such that **all values you need are then in a single row**.

## Problem

In this example data, `DEPTNO 20` is the department with the highest combined `salary`, which you can confirm by executing the following query:

```SQL
SELECT deptno,
       SUM(sal) AS sal
  FROM emp
 GROUP BY deptno
 ORDER bY deptno;
```

|deptno |  sal|
|:-----:|:----:|
|    10 |  8750|
|    20 | 10875|
|    30 |  9400|

You want to calculate the `difference between` the salaries of `DEPTNO 20` and `DEPTNO 10` and between `DEPTNO 20` and `DEPTNO 30`.


The final result will look like this:

|d20_d10_diff | d20_d30_diff|
|:-----------:|:-----------:|
|        2125 |         1475|

## Solution

```SQL
WITH dsal AS (
  SELECT SUM(CASE WHEN deptno = 10 THEN sal END) AS d10_sal,
         SUM(CASE WHEN deptno = 20 THEN sal END) AS d20_sal,
         SUM(CASE WHEN deptno = 30 THEN sal END) AS d30_sal
    FROM emp
)
SELECT d20_sal - d10_sal AS d20_d10_diff,
       d20_sal - d30_sal AS d20_d30_diff
  FROM dsal;
```

## Discussion

The first step is to **pivot the salaries** for each `DEPTNO` from **rows to columns** by using a `CASE` expression:

```SQL
SELECT CASE WHEN deptno = 10 THEN sal END AS d10_sal,
       CASE WHEN deptno = 20 THEN sal END AS d20_sal,
       CASE WHEN deptno = 30 THEN sal END AS d30_sal
  FROM emp;
```

```console
d10_sal | d20_sal | d30_sal
---------+---------+---------
        |     800 |
        |         |    1600
        |         |    1250
        |    2975 |
        |         |    1250
        |         |    2850
   2450 |         |
        |    3000 |
   5000 |         |
        |         |    1500
        |    1100 |
        |         |     950
        |    3000 |
   1300 |         |
```

The next step is to **sum all the salaries** for each `DEPTNO` by applying the aggregate function `SUM` to each `CASE` expression:

```SQL
SELECT SUM(CASE WHEN deptno = 10 THEN sal END) AS d10_sal,
       SUM(CASE WHEN deptno = 20 THEN sal END) AS d20_sal,
       SUM(CASE WHEN deptno = 30 THEN sal END) AS d30_sal
  FROM emp;
```

|d10_sal | d20_sal | d30_sal|
|:------:|:-------:|:------:|
|   8750 |   10875 |    9400|

The final step is to simply wrap the previous SQL in an CTE and perform the subtractions.

```SQL
WITH dsal AS (
  SELECT SUM(CASE WHEN deptno = 10 THEN sal END) AS d10_sal,
         SUM(CASE WHEN deptno = 20 THEN sal END) AS d20_sal,
         SUM(CASE WHEN deptno = 30 THEN sal END) AS d30_sal
    FROM emp
)
SELECT d20_sal - d10_sal AS d20_d10_diff,
       d20_sal - d30_sal AS d20_d30_diff
  FROM dsal;
```

|d20_d10_diff | d20_d30_diff|
|:-----------:|:-----------:|
|        2125 |         1475|
