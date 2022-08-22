# Performing Aggregations over a Moving Range of Values

You want to compute a **moving aggregation**, such as a `moving sum` on the salaries in table `EMP`.

## Problem

```SQL
SELECT hiredate, sal
  FROM emp
 ORDER BY hiredate;
```

|hiredate  | sal|
|:---------:|:---:|
|2006-01-20 | 1600|
|2006-02-22 | 1250|
|2006-04-02 | 2975|
|2006-05-01 | 2850|
|2006-06-09 | 2450|
|2006-09-08 | 1500|
|2006-09-28 | 1250|
|2006-11-17 | 5000|
|2006-12-03 | 3000|
|2006-12-03 |  950|
|2007-01-23 | 1300|
|2007-12-09 | 3000|
|2008-01-12 | 1100|
|2015-12-17 |  800|

You want to compute `a sum` **for every 90 days**, starting with the `HIREDATE` of the first employee.

You want to see how spending has fluctuated for `every 90-day period` **between the first and last employee hired**.

You want to return the following result set:

|hiredate  | sal  | spending_pattern|
|:----------:|:---:|:----------------:|
|2006-01-20 | 1600 |             1600|
|2006-02-22 | 1250 |             2850|
|2006-04-02 | 2975 |             5825|
|2006-05-01 | 2850 |             7075|
|2006-06-09 | 2450 |             8275|
|2006-09-08 | 1500 |             1500|
|2006-09-28 | 1250 |             2750|
|2006-11-17 | 5000 |             7750|
|2006-12-03 | 3000 |            11700|
|2006-12-03 |  950 |            11700|
|2007-01-23 | 1300 |            10250|
|2007-12-09 | 3000 |             3000|
|2008-01-12 | 1100 |             4100|
|2015-12-17 |  800 |              800|


## Solution

- **Using self-join**:


```SQL
WITH temp AS (
  SELECT DISTINCT DENSE_RANK() OVER(ORDER BY e.hiredate) AS window,
         e.hiredate AS current_hiredate,
         d.hiredate AS hiredate_within_90_days,
         d.sal AS sals_used_for_sum
    FROM emp e
    JOIN emp d ON(d.hiredate BETWEEN e.hiredate - 90 AND e.hiredate)
)
SELECT current_hiredate AS hiredate,
       SUM(sals_used_for_sum) AS spending_pattern
  FROM temp t
 GROUP BY hiredate
 ORDER BY hiredate;
```


Use a **scalar subquery** to sum the salaries of all employees hired up to 90 days prior to the day each employee was hired:

```SQL
SELECT e.hiredate,
       e.sal,
       --e.hiredate - 90 AS lag_90days,
       (SELECT SUM(sal)
          FROM emp d
         WHERE d.hiredate BETWEEN e.hiredate - 90
                              AND e.hiredate) AS spending_pattern
  FROM emp e
 ORDER BY 1;
```

- **More efficient solution Window function**

```SQL
WITH date_base AS (
  SELECT (MIN(hiredate) - INTERVAL '90 days')::DATE AS off_set
    FROM emp
), emp2 AS (
  SELECT e.hiredate AS hiredate,
         e.hiredate - off_set AS hr_val,
         e.sal
    FROM emp e, date_base d
)
SELECT hiredate,
       sal,
       SUM(sal) OVER(ORDER BY hr_val
                     RANGE BETWEEN 90 PRECEDING
                     AND CURRENT ROW) AS spending_pattern
  FROM emp2
 ORDER BY hiredate;
```

## Discussion

- **Solution 1**:

```SQL
SELECT DISTINCT DENSE_RANK() OVER(ORDER BY e.hiredate) AS window,
       e.hiredate AS current_hiredate,
       d.hiredate AS hiredate_within_90_days,
       d.sal AS sals_used_for_sum
  FROM emp e
  JOIN emp d ON(d.hiredate BETWEEN e.hiredate - 90 AND e.hiredate)
 ORDER BY 1;
```

```console
|window | current_hiredate | hiredate_within_90_days | sals_used_for_sum|
|:-----:|:----------------:|:-----------------------:|:----------------:|
|     1 | 2006-01-20       | 2006-01-20              |              1600|
---------------------------------------------------------------------------
|     2 | 2006-02-22       | 2006-01-20              |              1600|
|     2 | 2006-02-22       | 2006-02-22              |              1250|
---------------------------------------------------------------------------
|     3 | 2006-04-02       | 2006-01-20              |              1600|
|     3 | 2006-04-02       | 2006-02-22              |              1250|
|     3 | 2006-04-02       | 2006-04-02              |              2975|
--------------------------------------------------------------------------
|     4 | 2006-05-01       | 2006-02-22              |              1250|
|     4 | 2006-05-01       | 2006-04-02              |              2975|
|     4 | 2006-05-01       | 2006-05-01              |              2850|
-------------------------------------------------------------------------
|     5 | 2006-06-09       | 2006-04-02              |              2975|
|     5 | 2006-06-09       | 2006-05-01              |              2850|
|     5 | 2006-06-09       | 2006-06-09              |              2450|
--------------------------------------------------------------------------
|     6 | 2006-09-08       | 2006-09-08              |              1500|
---------------------------------------------------------------------------
|     7 | 2006-09-28       | 2006-09-08              |              1500|
|     7 | 2006-09-28       | 2006-09-28              |              1250|
--------------------------------------------------------------------------
|     8 | 2006-11-17       | 2006-09-08              |              1500|
|     8 | 2006-11-17       | 2006-09-28              |              1250|
|     8 | 2006-11-17       | 2006-11-17              |              5000|
--------------------------------------------------------------------------
|     9 | 2006-12-03       | 2006-09-08              |              1500|
|     9 | 2006-12-03       | 2006-09-28              |              1250|
|     9 | 2006-12-03       | 2006-11-17              |              5000|
|     9 | 2006-12-03       | 2006-12-03              |               950|
|     9 | 2006-12-03       | 2006-12-03              |              3000|
--------------------------------------------------------------------------
|    10 | 2007-01-23       | 2006-11-17              |              5000|
|    10 | 2007-01-23       | 2006-12-03              |               950|
|    10 | 2007-01-23       | 2006-12-03              |              3000|
|    10 | 2007-01-23       | 2007-01-23              |              1300|
--------------------------------------------------------------------------
|    11 | 2007-12-09       | 2007-12-09              |              3000|
--------------------------------------------------------------------------
|    12 | 2008-01-12       | 2007-12-09              |              3000|
|    12 | 2008-01-12       | 2008-01-12              |              1100|
---------------------------------------------------------------------------
|    13 | 2015-12-17       | 2015-12-17              |               800|
```

If you look at the `WINDOW` column, only those rows with the same `WINDOW` value will be considered for each sum. Take, for example, `WINDOW 3`.

|hiredate  | sal  | spending_pattern|
|:----------:|:---:|:----------------:|  ----
|2006-01-20 | 1600 |             1600|     |
|2006-02-22 | 1250 |             2850|     | WINDOW 3
|2006-04-02 | 2975 |             5825| <---+

The salaries used for the `sum` for that window are `1600`, `1250`, and `2975`, which total **5825**. If you look at the final result set, you’ll see the `SPENDING_PATTERN` for `2006-04-02` (**WINDOW 3**) is **5825**.

```SQL
WITH temp AS (
  SELECT DISTINCT DENSE_RANK() OVER(ORDER BY e.hiredate) AS window,
         e.hiredate AS current_hiredate,
         d.hiredate AS hiredate_within_90_days,
         d.sal AS sals_used_for_sum
    FROM emp e
    JOIN emp d ON(d.hiredate BETWEEN e.hiredate - 90 AND e.hiredate)
)
SELECT current_hiredate AS hiredate,
       SUM(sals_used_for_sum) AS spending_pattern
  FROM temp t
 GROUP BY hiredate
 ORDER BY hiredate;
```

As proof, to verify that the previous self-join includes the correct salaries for the windows defined, simply sum the values in `SALS_USED_FOR_SUM` and **group by** `CURRENT_DATE`.

|hiredate  | spending_pattern|
|:---------:|:---------------:|
|2006-01-20 |             1600|
|2006-02-22 |             2850|
|2006-04-02 |             5825|
|2006-05-01 |             7075|
|2006-06-09 |             8275|
|2006-09-08 |             1500|
|2006-09-28 |             2750|
|2006-11-17 |             7750|
|2006-12-03 |            11700|
|2007-01-23 |            10250|
|2007-12-09 |             3000|
|2008-01-12 |             4100|
|2015-12-17 |              800|

- **Solution 2**:

Use a **scalar subquery** to sum the salaries of all employees hired up to 90 days prior to the day each employee was hired:

```SQL
SELECT e.hiredate,
       e.sal,
       --e.hiredate - 90 AS lag_90days,
       (SELECT SUM(sal)
          FROM emp d
         WHERE d.hiredate BETWEEN e.hiredate - 90
                              AND e.hiredate) AS spending_pattern
  FROM emp e
 ORDER BY 1;
```

- **Soltuon 3**:



```SQL
SELECT hiredate,
       sal,
       SUM(sal) OVER(ORDER BY hiredate
                     RANGE BETWEEN 90 PRECEDING
                     AND CURRENT ROW) AS spending_pattern
  FROM emp;
```

```console
ERROR:  RANGE with offset PRECEDING/FOLLOWING is not supported for column type date and offset type integer
LINE 4:                      RANGE BETWEEN 90 PRECEDING
                                           ^
HINT:  Cast the offset value to an appropriate type.
```

The Postgresql does not allow to specify `hiredate` in the `ORDER BY` clause of a WINDOW function. A `DATE` type cannot be compared to an integer offset `90`. A solution to this problem is the conversion of the `hiredate` column date type to an integer.

```SQL
SELECT MIN(hiredate) AS first_hiredate,
       MIN(hiredate) - INTERVAL '90 days' AS off_set
  FROM emp;
```

|first_hiredate |       off_set|
|:-------------:|:------------------:|
|2006-01-20     | 2005-10-22 00:00:00|

```SQL
WITH date_base AS (
  SELECT MIN(hiredate) AS first_hiredate,
         (MIN(hiredate) - INTERVAL '90 days')::DATE AS off_set
    FROM emp
)
SELECT first_hiredate, off_set,
       first_hiredate - off_set AS interval_days,
       pg_typeof(first_hiredate - off_set) As type
  FROM date_base;
```

|first_hiredate |  off_set   | interval_days |  type|
|:-------------:|:----------:|:-------------:|:------:|
|2006-01-20     | 2005-10-22 |            90 | integer|

Similarly, we can use the the `off_set` date `2005-10-22` to generate integer numbers for all the `hiredates` in the `emp` table as follows:

```SQL
WITH date_base AS (
  SELECT (MIN(hiredate) - INTERVAL '90 days')::DATE AS off_set
    FROM emp
)
SELECT e.hiredate AS hiredate,
       e.hiredate - off_set AS hr_val,
       e.sal
  FROM emp e, date_base d
 ORDER BY hiredate;
```

```console
hiredate  | hr_val | sal
------------+--------+------
2006-01-20 |     90 | 1600
2006-02-22 |    123 | 1250
2006-04-02 |    162 | 2975
2006-05-01 |    191 | 2850
2006-06-09 |    230 | 2450
2006-09-08 |    321 | 1500
2006-09-28 |    341 | 1250
2006-11-17 |    391 | 5000
2006-12-03 |    407 | 3000
2006-12-03 |    407 |  950
2007-01-23 |    458 | 1300
2007-12-09 |    778 | 3000
2008-01-12 |    812 | 1100
2015-12-17 |   3708 |  800
```

Now, it is possible to apply the window function `SUM OVER` ordered by `hr_val`.

```SQL
WITH date_base AS (
  SELECT (MIN(hiredate) - INTERVAL '90 days')::DATE AS off_set
    FROM emp
), emp2 AS (
  SELECT e.hiredate AS hiredate,
         e.hiredate - off_set AS hr_val,
         e.sal
    FROM emp e, date_base d
)
SELECT hiredate,
       sal,
       SUM(sal) OVER(ORDER BY hr_val
                     RANGE BETWEEN 90 PRECEDING
                     AND CURRENT ROW) AS spending_pattern
  FROM emp2
 ORDER BY hiredate;
```

This solution is more efficient compared to a scalar subquery or a self-join.

|hiredate  | sal  | spending_pattern|
|:---------:|:-----:|:--------------:|
|2006-01-20 | 1600 |             1600|
|2006-02-22 | 1250 |             2850|
|2006-04-02 | 2975 |             5825|
|2006-05-01 | 2850 |             7075|
|2006-06-09 | 2450 |             8275|
|2006-09-08 | 1500 |             1500|
|2006-09-28 | 1250 |             2750|
|2006-11-17 | 5000 |             7750|
|2006-12-03 | 3000 |            11700|
|2006-12-03 |  950 |            11700|
|2007-01-23 | 1300 |            10250|
|2007-12-09 | 3000 |             3000|
|2008-01-12 | 1100 |             4100|
|2015-12-17 |  800 |              800|
