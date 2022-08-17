# Determining the Number of Days in a Year

You want to count the **number of days** in the **current year**.

For example, if the current year is `2022` then the number of days is:

|year | days|
|:---:|:---:|
|2022 |  365|


**Problem 2**:

Given the following list of years: `2020`, `2021`, `2022`. Return a table with the following 4 columns:

|year | days | is_leap_yr|
|:---:|:----:|:----------:|
|2020 |  366 |          1|
|2021 |  365 |          0|
|2022 |  365 |          0|


## Solution

The number of days in the current year is the difference between the first day of the next year and the first day of the current year (in days). For each solution the steps are:

1. Find the first day of the current year.
2. Add one year to that date (to get the first day of the next year).
3. Subtract the current year from the result of Step 2.

- **Problem 1**:

```SQL
WITH cYear AS (
  SELECT (DATE_TRUNC('YEAR',CURRENT_DATE)::DATE) AS curr_year
)
SELECT EXTRACT('YEAR' FROM curr_year) AS year,
       (curr_year + INTERVAL '1 year')::DATE - curr_year AS days
  FROM cYear;
```

- **Problem 2**:

```SQL
WITH feb1st (dy) AS (
  SELECT (('2020-01-01'::DATE) + (INTERVAL '1 months'))::DATE
  UNION ALL
  SELECT (('2021-01-01'::DATE) + (INTERVAL '1 months'))::DATE
  UNION ALL
  SELECT (('2022-01-01'::DATE) + (INTERVAL '1 months'))::DATE
),
febM AS (
  SELECT dy AS yr,
         dy + id AS dy
    FROM feb1st, GENERATE_SERIES(1,29) x(id)
   WHERE TO_CHAR(dy + id,'MM') = '02'
),
febMDy AS (
  SELECT yr,
         EXTRACT('DAY' FROM MAX(dy)) AS feb_last_day
    FROM febM
   GROUP BY yr
)
SELECT TO_CHAR(yr,'YYYY') AS year,
       (yr + INTERVAL '1 year')::DATE - yr AS days,
       CASE WHEN feb_last_day = 29
            THEN 1
            ELSE 0
        END is_leap_yr
  FROM febMDy f
 ORDER BY yr;
```


## Discussion


Use the function `DATE_TRUNC` to find the beginning of the current year. Then use interval arithmetic to determine the beginning of next year:

```SQL
WITH cYear AS (
  SELECT (DATE_TRUNC('YEAR',CURRENT_DATE)::DATE) AS curr_year
)
SELECT *
  FROM cYear;
```

The first step is to find the first day of the current year.
To do that, invoke the DATE_ TRUNC function.

|curr_year|
|:----------:|
|2022-01-01|

```SQL
WITH cYear AS (
  SELECT (DATE_TRUNC('YEAR',CURRENT_DATE)::DATE) AS curr_year
)
SELECT EXTRACT('YEAR' FROM curr_year) AS year,
       (curr_year + INTERVAL '1 year')::DATE - curr_year AS days
  FROM cYear;
```
You can then easily add a year to compute the first day of next year. Then all you need to do is to subtract the two dates. Be sure to subtract the earlier date from the later date. The result will be the number of days in the current year.
