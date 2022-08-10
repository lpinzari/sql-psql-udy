# Computing Averages Without High and Low Values

You want to **compute an average**, but you want to **exclude the highest and lowest values to (hopefully) reduce the effect of skew**.

## Problem

In statistical language, this is known as a **trimmed mean**. For example, you want to compute the `average salary` of all employees **excluding the highest and lowest salaries**.

```SQL
SELECT sal
  FROM emp
 ORDER BY sal;
```

```console
sal
------
 800 <------ exclude
+-----+
| 950 |
|1100 |
|1250 |
|1250 |
|1300 |
|1500 |----> mean = 1935.42
|1600 |
|2450 |
|2850 |
|2975 |
|3000 |
|3000 |
+-----+
5000 <------- exclude
```

## Problem 2

Suppose we want to exclude the first three and last two values:

```console
sal   | rnk
------+-----
  800 |   1 |
  950 |   2 |<--- Excluded
 1100 |   3 |
+-----+
|1250 |    
|1250 |   
|1300 |   
|1500 |   
|1600 |----> mean =  1896.88
|2450 |   
|2850 |   
|2975 |  
+-----+
3000  |  11 |
3000  |  11 | <--- Excluded
5000  |  12 |
```

## Solution

**MySQL and PostgreSQL**

Use subqueries to exclude high and low values:

```SQL
SELECT ROUND(AVG(sal),2) AS avg_sal
  FROM emp
 WHERE sal NOT IN (
   (SELECT MIN(sal) FROM emp),
   (SELECT MAX(sal) FROM emp)
 );
```

|avg_sal|
|:-----:|
|1935.42|

The subqueries return the highest and lowest salaries in the table. By using `NOT IN` against the values returned, **you exclude the highest and lowest salaries from the average**.

Keep in mind that if there are `duplicates` (if multiple employees have the highest or lowest salaries), they will all be excluded from the average. If your goal is to exclude only a single instance of the high and low values, simply subtract them from the SUM and then divide:

```SQL
SELECT (SUM(sal) - MIN(sal) - MAX(sal))/(COUNT(*)-2)
  FROM emp;
```

The windowing functions `MAX OVER` and `MIN OVER` to generate a result set from which you can easily eliminate the high and low values:

```SQL
SELECT ROUND(AVG(sal),2) AS avg_sal
  FROM ( SELECT sal,
                MIN(sal) OVER() min_sal,
                MAX(sal) OVER() max_sal
           FROM emp
      ) x
 WHERE sal NOT IN (min_sal, max_sal);     
```

Inline view X returns each salary along with the highest and lowest salaries:

```SQL    
SELECT sal,
       MIN(sal) OVER() min_sal,
       MAX(sal) OVER() max_sal
  FROM emp;
```

|sal  | min_sal | max_sal|
|:---:|:-------:|:------:|
| 800 |     800 |    5000|
|1600 |     800 |    5000|
|1250 |     800 |    5000|
|2975 |     800 |    5000|
|1250 |     800 |    5000|
|2850 |     800 |    5000|
|2450 |     800 |    5000|
|3000 |     800 |    5000|
|5000 |     800 |    5000|
|1500 |     800 |    5000|
|1100 |     800 |    5000|
| 950 |     800 |    5000|
|3000 |     800 |    5000|
|1300 |     800 |    5000|

You can access the high and low salaries at every row, so finding which salaries are highest and/or lowest is trivial. The outer query filters the rows returned from inline view X such that any salary that matches either `MIN_SAL` or `MAX_SAL` is excluded from the average.

> Note: In statistical parlance, a mean calculated with the largest and smallest values removed is called a trimmed mean. This can be considered a safer estimate of the average, and is an example of a robust statistic, so called because they are less sensitive to problems such as bias. These approaches are valuable to someone analyzing data within an RDBMS because they don’t require the analyst to make assumptions that are difficult to test with the relatively limi‐ ted range of statistical tools available in SQL.

**Problem 2**:

```SQL
WITH sal_rnk AS (
SELECT sal,
       DENSE_RANK() OVER (ORDER BY sal) AS rnk
  FROM emp
)
SELECT ROUND(AVG(sal),2) AS avg_sal
  FROM sal_rnk
 WHERE rnk BETWEEN 4 AND (SELECT MAX(rnk) - 2 FROM sal_rnk);
```

|avg_sal|
|:-----:|
|1896.88|

```SQL
SELECT sal,
       DENSE_RANK() OVER (ORDER BY sal) AS rnk
  FROM emp;
```

In the CTE,**sal_rnk**, the `DENSE_RANK()` assigns a rank to every row in each partition of a result set.

|sal  | rnk|
|:---:|:--:|
|:heavy_multiplication_x: 800 |   1|
|:heavy_multiplication_x: 950 |   2|
|:heavy_multiplication_x:1100 |   3|
|**1250** |   **4**|
|**1250** |   **4**|
|**1300** |   **5**|
|**1500** |   **6**|
|**1600** |   **7**|
|**2450** |   **8**|
|**2850** |   **9**|
|:heavy_multiplication_x: 2975 |  10|
|:heavy_multiplication_x:3000 |  11|
|:heavy_multiplication_x:3000 |  11|
|:heavy_multiplication_x:5000 |  12|

```SQL
SELECT ROUND(AVG(sal),2) AS avg_sal
  FROM sal_rnk
 WHERE rnk BETWEEN 4 AND (SELECT MAX(rnk) - 2 FROM sal_rnk);
```

The outer query filters the rows returned from **sal_rnk** such that any salary's rank  below the third first lowest value or above the third last highest value is excluded (:heavy_multiplication_x:) from the average.
