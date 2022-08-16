# Determining Quarter Start and End Dates for a Given Quarter

When given a year and quarter in the format of **YYYYQ** (`four-digit` **year**, `one-digit` **quarter**), you want to return the **quarter’s start and end dates**.


## Problem 1

```SQL
SELECT '20051' AS yrq UNION ALL  
SELECT '20052' AS yrq UNION ALL  
SELECT '20053' AS yrq UNION ALL  
SELECT '20054' AS yrq;
```

|yrq|
|:-----:|
|20051|
|20052|
|20053|


**Output**:


|q |  q_start   |   q_end|
|:-:|:---------:|:---------:|
|1 | 2005-01-01 | 2005-03-31|
|2 | 2005-04-01 | 2005-06-30|
|3 | 2005-07-01 | 2005-09-30|
|4 | 2005-10-01 | 2005-12-31|

- **Problem 2**

Solve the same problem with numeric data type conversion.

```SQL
SELECT 20051 AS yrq UNION ALL  
SELECT 20052 AS yrq UNION ALL  
SELECT 20053 AS yrq UNION ALL  
SELECT 20054 AS yrq;
```

|yrq|
|:-----:|
|20051|
|20052|
|20053|

## Solution

Use the function `LEFT` and `RIGHT` to return the year and quarter from the yrq string. Use the `MOD` function to determine which quarter you are looking for:

```SQL
WITH x AS (
  SELECT '20051' AS yrq UNION ALL  
  SELECT '20052' AS yrq UNION ALL  
  SELECT '20053' AS yrq UNION ALL  
  SELECT '20054' AS yrq
),
qE AS (
  SELECT RIGHT(yrq,1) AS q,
         TO_DATE(LEFT(yrq,4) || MOD(yrq::INTEGER,10)*3,'YYYYMM') AS q_end
    FROM x
)
SELECT q,
       (q_end - INTERVAL '2 months')::DATE AS q_start,
       (q_end + INTERVAL '1 month')::DATE - 1 AS q_end
  FROM qE;
```

In case the of numeric data type.

Use the function `SUBSTR` to return the year and quarter from the yrq string. Use the `MOD` function to determine which quarter you are looking for:

```SQL
WITH x AS (
  SELECT 20051 AS yrq UNION ALL  
  SELECT 20052 AS yrq UNION ALL  
  SELECT 20053 AS yrq UNION ALL  
  SELECT 20054 AS yrq
),
qE AS (
  SELECT SUBSTR(yrq,5,5) AS q,
         TO_DATE(SUBSTR(yrq,1,4) || MOD(yrq,10)*3,'YYYYMM') AS q_end
    FROM x
)
SELECT q,
       (q_end - INTERVAL '2 months')::DATE AS q_start,
       (q_end + INTERVAL '1 month')::DATE - 1 AS q_end
  FROM qE;
```

## Discussion

```SQL
WITH x AS (
  SELECT '20051' AS yrq UNION ALL  
  SELECT '20052' AS yrq UNION ALL  
  SELECT '20053' AS yrq UNION ALL  
  SELECT '20054' AS yrq
)
SELECT LEFT(yrq,4) AS yr,
       MOD(yrq::INTEGER,10)*3 AS mth_end
  FROM x;
```

|yr  | mth_end|
|:----:|:-----:|
|2005 |       3|
|2005 |       6|
|2005 |       9|
|2005 |      12|

```SQL
WITH x AS (
  SELECT '20051' AS yrq UNION ALL  
  SELECT '20052' AS yrq UNION ALL  
  SELECT '20053' AS yrq UNION ALL  
  SELECT '20054' AS yrq
)
SELECT LEFT(yrq,4) AS yr,
       RIGHT(yrq,1) AS q,
       MOD(yrq::INTEGER,10)*3 AS mth_end,
       TO_DATE(LEFT(yrq,4) || MOD(yrq::INTEGER,10)*3,'YYYYMM') AS q_end
  FROM x;
```

|yr  | q | mth_end |   q_end|
|:---:|:--:|:--------:|:-----------:|
|2005 | 1 |       3 | 2005-03-01|
|2005 | 2 |       6 | 2005-06-01|
|2005 | 3 |       9 | 2005-09-01|
|2005 | 4 |      12 | 2005-12-01|


```SQL
WITH x AS (
  SELECT '20051' AS yrq UNION ALL  
  SELECT '20052' AS yrq UNION ALL  
  SELECT '20053' AS yrq UNION ALL  
  SELECT '20054' AS yrq
),
qE AS (
  SELECT RIGHT(yrq,1) AS q,
         TO_DATE(LEFT(yrq,4) || MOD(yrq::INTEGER,10)*3,'YYYYMM') AS q_end
    FROM x
)
SELECT q,
       (q_end - INTERVAL '2 months')::DATE AS q_start,
       (q_end + INTERVAL '1 month')::DATE - 1 AS q_end
  FROM qE;
```
