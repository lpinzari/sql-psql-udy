# Calculating a Median

You want to **calculate the median** (for those of who do not recall, **the median is the value of the middle member of a set of ordered elements**) value for a column of numeric values.

## Problem

For example, you want to find the `median` of the `salaries` in `DEPTNO 20`. Based on the following salaries:

```SQL
SELECT sal
  FROM emp
 WHERE deptno = 20
 ORDER BY sal;
```

|sal|
|:--:|
| 800|
|1100|
|**2975**|
|3000|
|3000|

**(5 rows)**

The median is **2975**.

```SQL
SELECT sal
  FROM emp
 WHERE deptno = 30
 ORDER BY sal;
```

|sal|
|:----:|
| 950|
|1250|
|**1250**|
|**1500**|
|1600|
|2850|

**(6 rows)**

The median is:

- `(1250 + 1500 )/2` = **1375.00**.

## Solution

Other than the Oracle solution (which uses supplied functions to compute a median), the introduction of window functions allows for a more efficient solution compared to the traditional self-join.

**DB2 and PostgreSQL**

Use the window function [PERCENTILE_CONT](https://www.postgresql.org/docs/11/functions-aggregate.html) to find the median:

```SQL
SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY sal)
  FROM emp
 WHERE deptno = 20;
```

```SQL
SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY sal)
  FROM emp
 WHERE deptno = 30;
```


**Using** [ROW_NUMBER](https://github.com/lpinzari/sql-psql-udy/blob/master/08_window_functions/12_row_number.md) function.


```SQL
WITH rank_tab AS (
  SELECT sal,
         ROW_NUMBER() OVER(ORDER BY sal) AS row_index
    FROM emp
   WHERE deptno = 20
),
middle AS (
  SELECT *
    FROM rank_tab
   WHERE row_index IN (
     CEIL( (SELECT COUNT(sal) FROM rank_tab)/(2*1.0) ) + 1 -
      MOD( (SELECT COUNT(sal) FROM rank_tab),2),
     CEIL( (SELECT COUNT(sal) FROM rank_tab)/(2*1.0) )
   )
)
SELECT CASE WHEN COUNT(*) = 2 THEN ROUND(AVG(sal),4)
            WHEN COUNT(*) = 1 THEN SUM(sal)
       END
  FROM middle;
```

```SQL
WITH rank_tab AS (
  SELECT sal,
         ROW_NUMBER() OVER(ORDER BY sal) AS row_index
    FROM emp
   WHERE deptno = 30
),
middle AS (
  SELECT *
    FROM rank_tab
   WHERE row_index IN (
     CEIL( (SELECT COUNT(sal) FROM rank_tab)/(2*1.0) ) + 1 -
      MOD( (SELECT COUNT(sal) FROM rank_tab),2),
     CEIL( (SELECT COUNT(sal) FROM rank_tab)/(2*1.0) )
   )
)
SELECT CASE WHEN COUNT(*) = 2 THEN ROUND(AVG(sal),2)
            WHEN COUNT(*) = 1 THEN SUM(sal)
       END
  FROM middle;
```

**Using** [PERCENT_RANK](https://github.com/lpinzari/sql-psql-udy/blob/master/08_window_functions/10_percent_rank.md):

```SQL
WITH rank_tab AS (
  SELECT sal,
  ROUND(CAST (PERCENT_RANK() OVER (ORDER BY sal) AS numeric),2) rank_sal
    FROM emp
   WHERE deptno = 20
),
middle AS (
  SELECT MIN(sal) AS sal
    FROM rank_tab
   WHERE rank_sal >= 0.5
  UNION
  SELECT MAX(sal) AS sal
    FROM rank_tab
   WHERE rank_sal <= 0.5
)
SELECT CASE WHEN COUNT(*) = 2 THEN ROUND(AVG(sal),2)
            WHEN COUNT(*) = 1 THEN SUM(sal)
       END
  FROM middle;
```
```SQL
WITH rank_tab AS (
  SELECT sal,
  ROUND(CAST (PERCENT_RANK() OVER (ORDER BY sal) AS numeric),2) rank_sal
    FROM emp
   WHERE deptno = 30
),
middle AS (
  SELECT MIN(sal) AS sal
    FROM rank_tab
   WHERE rank_sal >= 0.5
  UNION
  SELECT MAX(sal) AS sal
    FROM rank_tab
   WHERE rank_sal <= 0.5
)
SELECT CASE WHEN COUNT(*) = 2 THEN ROUND(AVG(sal),2)
            WHEN COUNT(*) = 1 THEN SUM(sal)
       END
  FROM middle;
```

## Discussion

```SQL
SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY sal)
  FROM emp
 WHERE deptno = 20;
```

The `PERCENTILE_CONT` function allows you to directly apply the definition of a median, as the median is by definition the **50th percentile**. Hence, applying this function with the appropriate syntax and using `0.5` as the argument finds the median.
Of course, other percentiles are also available from this function. For example, you can look for the `5th` and/or `95th` percentiles to find outliers (another method of finding outliers is outlined later in this chapter when we discuss the median absolute deviation).

```SQL
WITH rank_tab AS (
  SELECT sal,
         ROW_NUMBER() OVER(ORDER BY sal) AS row_index
    FROM emp
   WHERE deptno = 20
),
middle AS (
  SELECT *
    FROM rank_tab
   WHERE row_index IN (
     CEIL( (SELECT COUNT(sal) FROM rank_tab)/(2*1.0) ) + 1 -
      MOD( (SELECT COUNT(sal) FROM rank_tab),2),
     CEIL( (SELECT COUNT(sal) FROM rank_tab)/(2*1.0) )
   )
)
SELECT CASE WHEN COUNT(*) = 2 THEN ROUND(AVG(sal),4)
            WHEN COUNT(*) = 1 THEN SUM(sal)
       END
  FROM middle;
```

```SQL
WITH rank_tab AS (
  SELECT sal,
         ROW_NUMBER() OVER(ORDER BY sal) AS row_index
    FROM emp
   WHERE deptno = 30
),
middle AS (
  SELECT *
    FROM rank_tab
   WHERE row_index IN (
     CEIL( (SELECT COUNT(sal) FROM rank_tab)/(2*1.0) ) + 1 -
      MOD( (SELECT COUNT(sal) FROM rank_tab),2),
     CEIL( (SELECT COUNT(sal) FROM rank_tab)/(2*1.0) )
   )
)
SELECT CASE WHEN COUNT(*) = 2 THEN ROUND(AVG(sal),2)
            WHEN COUNT(*) = 1 THEN SUM(sal)
       END
  FROM middle;
```

Since the median represents the value that separates the higher half and the lower half of a data sample, you need to sort the values from the smallest to the largest.

If the data set has an even number of values the median is the average of two values in position (size/2, Size/2 + 1), otherwise is the middle value in position size/2.


```SQL
WITH rank_tab AS (
  SELECT sal,
  ROUND(CAST (PERCENT_RANK() OVER (ORDER BY sal) AS numeric),2) rank_sal
    FROM emp
   WHERE deptno = 20
),
middle AS (
  SELECT MIN(sal) AS sal
    FROM rank_tab
   WHERE rank_sal >= 0.5
  UNION
  SELECT MAX(sal) AS sal
    FROM rank_tab
   WHERE rank_sal <= 0.5
)
SELECT CASE WHEN COUNT(*) = 2 THEN ROUND(AVG(sal),2)
            WHEN COUNT(*) = 1 THEN SUM(sal)
       END
  FROM middle;
```

To find the median, the values for `SAL` must be ordered from lowest to highest. The `PERCENT_RANK` function achieves this goal and labels each row with its percentile. Hence, it can be used to achieve the same outcome as the `PERCENTILE_CONT` function used in the solution for the other databases.
The only difficulty is that the `PERCENT_RANK` function is not permitted in a `WHERE` clause. As a result, you need to apply it first in a CTE.

```SQL
middle AS (
  SELECT MIN(sal) AS sal
    FROM rank_tab
   WHERE rank_sal >= 0.5
  UNION
  SELECT MAX(sal) AS sal
    FROM rank_tab
   WHERE rank_sal <= 0.5
)
```

The only trap here is that if the number of rows is even, there won’t be a row exactly on the median. Hence, the solution is written to **find the average** of the **highest value below or equal to the median**, and **the lowest value above or equal to the median**. This method works for both odd and even numbers of rows, and if there is an odd number of rows giving an exact median, it will take average of two numbers that are equal.
