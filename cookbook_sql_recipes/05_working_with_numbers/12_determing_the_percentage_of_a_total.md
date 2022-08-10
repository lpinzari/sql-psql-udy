# Determining the Percentage of a Total 

You want to determine the **percentage that values in a specific column represent against a total**.

## Problem

Determine the percentage of all salaries in each department of the `emp` table.

```SQL
SELECT deptno, sal
  FROM emp
 ORDER BY deptno, sal;
```

|deptno | sal|
|:-----:|:----:|
|    10 | 1300|
|    10 | 2450|
|    10 | 5000|
|    20 |  800|
|    20 | 1100|
|    20 | 2975|
|    20 | 3000|
|    20 | 3000|
|    30 |  950|
|    30 | 1250|
|    30 | 1250|
|    30 | 1500|
|    30 | 1600|
|    30 | 2850|


For example, **the percentage that DEPTNO 10 salaries contribute to the total** is:

```SQL
SELECT SUM(sal) AS tot
  FROM emp;
```

|tot|
|:-----:|
|29025|

```SQL
SELECT sal AS sal_dept10
  FROM emp
 WHERE deptno = 10;
```

|sal_dept10|
|:--:|
|2450|
|5000|
|1300|

```SQL
SELECT ROUND(SUM(CASE WHEN deptno = 10 THEN sal END)/(SUM(sal)*1.0)*100,2) AS pct10
  FROM emp;
```

The percentage is `100 * (2450 + 5000 + 1300)/(29025*1.0)` = **30.15**

|deptno | perc|
|:-----:|:----:|
|    10 | 30.15|
|    20 | 37.47|
|    30 | 32.38|

## Solution

```SQL
WITH dep_sums AS (
  SELECT DISTINCT deptno,
         SUM(sal) OVER() AS total,
         SUM(sal) OVER(PARTITION BY deptno) AS dep_total
    FROM emp
)


SELECT deptno,
       ROUND(100 * dep_total/(total*1.0),2) AS dep_perc
  FROM dep_sums
 ORDER BY deptno;
```

**No Rounding Error** Solution:

```SQL
WITH dep_sums AS (
  SELECT DISTINCT deptno,
        SUM(sal) OVER() AS total,
        SUM(sal) OVER(PARTITION BY deptno) AS dep_total
   FROM emp
),
percentages AS (
  SELECT deptno,
         (100 * dep_total/(total*1.0)) AS dep_perc
    FROM dep_sums
   ORDER BY deptno
),
round_perc AS (
  SELECT deptno, dep_perc,
         ROUND(SUM(dep_perc) OVER(ORDER BY dep_perc),2) AS round_sum_percent
    FROM percentages
   ORDER BY dep_perc
),
prev_sum_run_perc AS (
  SELECT deptno, dep_perc, round_sum_percent,
         LAG(round_sum_percent,1,0.00) OVER (ORDER BY dep_perc) AS prev_sum_percent
    FROM round_perc
)
SELECT deptno,
       round_sum_percent - prev_sum_percent AS perc
  FROM prev_sum_run_perc
 ORDER BY deptno;
```

## Discussion


In general, computing a percentage against a total in SQL is no different than doing so on paper: simply divide, then multiply. In this example you want to find the percentage of total salaries in table `EMP` that come from `DEPTNO` `10`.

To do that, simply

- find the salaries for `DEPTNO 10`, and then
- **divide by the total salary for the table**.
- As the last step, **multiply by 100** to return a value that represents a percent.

**MySQL and PostgreSQL**

Divide the sum of the salaries in DEPTNO 10 by the sum of all salaries:

```SQL
SELECT ROUND(SUM(CASE WHEN deptno = 10 THEN sal END)/(SUM(sal)*1.0)*100,2) AS pct10
  FROM emp;
```

|pct|
|:---:|
|30.15|

Similarly, the percentage salary for the other two departments are:

```SQL
SELECT ROUND(SUM(CASE WHEN deptno = 20 THEN sal END)/(SUM(sal)*1.0)*100,2) AS pct20
  FROM emp;
```

|pct20|
|:---:|
|37.47|

```SQL
SELECT ROUND(SUM(CASE WHEN deptno = 30 THEN sal END)/(SUM(sal)*1.0)*100,2) AS pct30
  FROM emp;
```

|pct30|
|:---:|
|32.39|

A naive solution is:

```SQL
WITH dep_sums AS (
  SELECT DISTINCT deptno,
         SUM(sal) OVER() AS total,
         SUM(sal) OVER(PARTITION BY deptno) AS dep_total
    FROM emp
)


SELECT deptno,
       ROUND(100 * dep_total/(total*1.0),2) AS dep_perc
  FROM dep_sums
 ORDER BY deptno;
```

|deptno | dep_perc|
|:-----:|:-------:|
|    10 |    30.15|
|    20 |    37.47|
|    30 |    32.39|

Ohps! the result is not correct. Why? The wrong result is due to **ROUNDING ERROR** in the computation of the percentage. The percentage summation `30.15 + 37.47 + 32.39` does not return `100.00`.


The following solution solve the **ROUNDING ERROR** problem:

```SQL
WITH dep_sums AS (
  SELECT DISTINCT deptno,
        SUM(sal) OVER() AS total,
        SUM(sal) OVER(PARTITION BY deptno) AS dep_total
   FROM emp
),
percentages AS (
  SELECT deptno,
         (100 * dep_total/(total*1.0)) AS dep_perc
    FROM dep_sums
   ORDER BY deptno
),
round_perc AS (
  SELECT deptno, dep_perc,
         ROUND(SUM(dep_perc) OVER(ORDER BY dep_perc),2) AS round_sum_percent
    FROM percentages
   ORDER BY dep_perc
),
prev_sum_run_perc AS (
  SELECT deptno, dep_perc, round_sum_percent,
         LAG(round_sum_percent,1,0.00) OVER (ORDER BY dep_perc) AS prev_sum_percent
    FROM round_perc
)
SELECT deptno,
       round_sum_percent - prev_sum_percent AS perc
  FROM prev_sum_run_perc
 ORDER BY deptno;
```

The code below shows the steps implemented to adjust the rounding errors in the computation of percentages.

```SQL
WITH dep_sums AS (
  SELECT DISTINCT deptno,
        SUM(sal) OVER() AS total,
        SUM(sal) OVER(PARTITION BY deptno) AS dep_total
   FROM emp
),
percentages AS (
  SELECT deptno,
         (100 * dep_total/(total*1.0)) AS dep_perc
    FROM dep_sums
   ORDER BY deptno
),
round_perc AS (
  SELECT deptno, dep_perc,
         ROUND(SUM(dep_perc) OVER(ORDER BY dep_perc),2) AS round_sum_percent
    FROM percentages
   ORDER BY dep_perc
),
prev_sum_run_perc AS (
  SELECT deptno, dep_perc, round_sum_percent,
         LAG(round_sum_percent,1,0.00) OVER (ORDER BY dep_perc) AS prev_sum_percent
    FROM round_perc
)
SELECT deptno, dep_perc, round_sum_percent, prev_sum_percent,
       round_sum_percent - prev_sum_percent AS perc
  FROM prev_sum_run_perc;

```


|deptno |      dep_perc       | round_sum_percent | prev_sum_percent | perc|
|:-----:|:-------------------:|:-----------------:|:----------------:|:----:|
|    10 | 30.1464254952627046 |             30.15 |             0.00 | 30.15|
|    30 | 32.3858742463393626 |             62.53 |            30.15 | 32.38|
|    20 | 37.4677002583979328 |            100.00 |            62.53 | 37.47|
