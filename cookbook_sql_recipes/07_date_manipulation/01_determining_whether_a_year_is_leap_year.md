# Determining Whether a Year Is a Leap Year

You want to determine whether **the current year is a leap year**.

## Problem

If you’ve worked on SQL for some time, there’s no doubt that you’ve come across sev‐ eral techniques for solving this problem. Just about all the solutions we’ve encoun‐ tered work well, but the one presented in this recipe is probably the simplest. This solution simply
- **checks the last day of February**; if it is the `29th`, then **the current year is a leap year**.

For example, the last day of February in `2022`,(current year, the time I wrote the document :smile:) is the `28th`. The Output is, therefore:

|year | feb_last_day | is_leap_yr|
|:---:|:------------:|:---------:|
|2022 |           28 |          0|

The value in the last column, `is_leap_yr`, is zero; meaning that `2022` is not a leap year.  

**Problem 2**:

Try out, these three inputs: `2020`, `2021`, `2022`.

|yr  | feb_last_day | is_leap_yr|
|:---:|:------------:|:----------:|
|2020 |           29 |          1|
|2021 |           28 |          0|
|2022 |           28 |          0|


## Solution

Use the function `GENERATE_SERIES` to return each day in February, and then use the aggregate function `MAX` to find the last day in February:


- **Problem 1**:

```SQL
WITH feb1st AS (
  SELECT ((DATE_TRUNC('YEAR',CURRENT_DATE)::DATE) + (INTERVAL '1 months'))::DATE AS dy
),
febM AS (
  SELECT dy + id AS dy, TO_CHAR(dy,'MM') AS mth
    FROM feb1st, GENERATE_SERIES(1,29) x(id)
),
febLdy AS(
  SELECT MAX(dy) AS dy_max
    FROM febM
   WHERE TO_CHAR(dy,'MM') = mth
)
SELECT EXTRACT('YEAR' FROM dy_max) AS year,
       EXTRACT('DAY' FROM dy_max) AS feb_last_day,
       CASE WHEN EXTRACT('DAY' FROM dy_max) = 29
            THEN 1
            ELSE 0
       END is_leap_yr
  FROM febLdy;
```

**Solution 2**

```SQL
WITH RECURSIVE x (dy, mth) AS (
  SELECT ((DATE_TRUNC('YEAR',CURRENT_DATE)::DATE) + (INTERVAL '1 months'))::DATE,
         TO_CHAR(((DATE_TRUNC('YEAR',CURRENT_DATE)::DATE) + (INTERVAL '1 months'))::DATE,'MM')
  UNION ALL
  SELECT dy + 1, mth
    FROM x
   WHERE TO_CHAR(dy + 1,'MM') = mth
)
SELECT EXTRACT('YEAR' FROM MAX(dy)) AS year,
       EXTRACT('DAY' FROM MAX(dy)) AS feb_last_day,
       CASE WHEN EXTRACT('DAY' FROM MAX(dy)) = 29
            THEN 1
            ELSE 0
       END is_leap_yr
  FROM x;
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
  SELECT TO_CHAR(dy,'YYYY') AS yr,
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
SELECT f.*,
       CASE WHEN feb_last_day = 29
            THEN 1
            ELSE 0
        END is_leap_yr
  FROM febMDy f
 ORDER BY yr;
```


## Discussion

- **Solution 1**:

**Step 1**: Use the `CURRENT_DATE` function to return the current date:

```SQL
SELECT CURRENT_DATE, pg_typeof(CURRENT_DATE);
```

|current_date | pg_typeof|
|:----------:|:---------:|
|2022-08-14   | date|

**Step 2**: Use the DATE_TRUNC function to find the beginning of the current year. and cast that result as a DATE:


```SQL
SELECT DATE_TRUNC('YEAR',CURRENT_DATE), pg_typeof(DATE_TRUNC('YEAR',CURRENT_DATE));
```

|date_trunc       |        pg_typeof|
|:---------------------:|:-----------------------:|
|2022-01-01 00:00:00+11 | timestamp with time zone|


**Step 3**: The next step is to cast the previous result as a DATE add one month to the first day of the current year to get the first day in February, casting the result as a date:

```SQL
SELECT (DATE_TRUNC('YEAR',CURRENT_DATE)::DATE) + (INTERVAL '1 months') AS february;
```

|february|
|:-----------------:|
|2022-02-01 00:00:00|

```SQL
SELECT ((DATE_TRUNC('YEAR',CURRENT_DATE)::DATE) + (INTERVAL '1 months'))::DATE AS dy;
```

|dy|
|:--------:|
|2022-02-01|

Return the numeric month by using the `TO_CHAR` function. The column `mnth` is used later as a flag to filter the table.

```SQL
WITH feb1st AS (
  SELECT ((DATE_TRUNC('YEAR',CURRENT_DATE)::DATE) + (INTERVAL '1 months'))::DATE AS dy
)
SELECT dy, TO_CHAR(dy,'MM') AS mth
  FROM feb1st;
```

|dy     | mth|
|:---------:|:----:|
|2022-02-01 | 02|


**Step 4**: Your next step is to use the extremely useful function `GENERATE_SERIES` to return 29 rows (values 1 through 29). Every row returned by `GENERATE_SERIES` (aliased X) is added to `dy`.

```SQL
WITH feb1st AS (
  SELECT ((DATE_TRUNC('YEAR',CURRENT_DATE)::DATE) + (INTERVAL '1 months'))::DATE AS dy
),
febM AS (
  SELECT id,dy + id AS dy, TO_CHAR(dy,'MM') AS mth
    FROM feb1st, GENERATE_SERIES(1,29) x(id)
)
SELECT * FROM febM;
```

|id |     dy     | mth|
|:-:|:----------:|:--:|
| 1 | 2022-02-02 | 02|
| 2 | 2022-02-03 | 02|
| 3 | 2022-02-04 | 02|
| 4 | 2022-02-05 | 02|
| 5 | 2022-02-06 | 02|
|...|............|...|
|27 | 2022-02-**28** | 02|
|28 | 2022-**03**-01 | 02|
|29 | 2022-**03**-02 | 02|

**(29 rows)**

**Step 5**: Use the `mnth` column value to filter the table,

```SQL
WITH feb1st AS (
  SELECT ((DATE_TRUNC('YEAR',CURRENT_DATE)::DATE) + (INTERVAL '1 months'))::DATE AS dy
),
febM AS (
  SELECT id,dy + id AS dy, TO_CHAR(dy,'MM') AS mth
    FROM feb1st, GENERATE_SERIES(1,29) x(id)
)
SELECT *
  FROM febM
 WHERE TO_CHAR(dy,'MM') = mth;
```

|id |     dy     | mth|
|:-:|:----------:|:--:|
| 1 | 2022-02-02 | 02|
| 2 | 2022-02-03 | 02|
| 3 | 2022-02-04 | 02|
| 4 | 2022-02-05 | 02|
| 5 | 2022-02-06 | 02|
|...|............|...|
|27 | 2022-02-**28** | 02|


The **final step** is to use the `MAX` function to return the last day in February. The function `TO_CHAR` is applied to that value and will return either 28 or 29.

```SQL
WITH feb1st AS (
  SELECT ((DATE_TRUNC('YEAR',CURRENT_DATE)::DATE) + (INTERVAL '1 months'))::DATE AS dy
),
febM AS (
  SELECT id,dy + id AS dy, TO_CHAR(dy,'MM') AS mth
    FROM feb1st, GENERATE_SERIES(1,29) x(id)
)
SELECT MAX(dy) AS dy_max
  FROM febM
 WHERE TO_CHAR(dy,'MM') = mth;
```

|dy_max|
|:--------:|
|2022-02-28|

```SQL
WITH feb1st AS (
  SELECT ((DATE_TRUNC('YEAR',CURRENT_DATE)::DATE) + (INTERVAL '1 months'))::DATE AS dy
),
febM AS (
  SELECT id,dy + id AS dy, TO_CHAR(dy,'MM') AS mth
    FROM feb1st, GENERATE_SERIES(1,29) x(id)
),
febLdy AS(
  SELECT MAX(dy) AS dy_max
    FROM febM
   WHERE TO_CHAR(dy,'MM') = mth
)
SELECT EXTRACT('YEAR' FROM dy_max) AS year,
       EXTRACT('DAY' FROM dy_max) AS feb_last_day,
       CASE WHEN EXTRACT('DAY' FROM dy_max) = 29
            THEN 1
            ELSE 0
       END is_leap_yr
  FROM febLdy;
```

- **Solution 2**:

Use the recursive WITH clause to return each day in February. Use the aggregate function MAX to determine the last day in February.

### Problem 2:

The solution is similar to the problem 1 except that we used the `GROUP BY` clause to the following data set.

```SQL
WITH feb1st (dy) AS (
  SELECT (('2020-01-01'::DATE) + (INTERVAL '1 months'))::DATE
  UNION ALL
  SELECT (('2021-01-01'::DATE) + (INTERVAL '1 months'))::DATE
  UNION ALL
  SELECT (('2022-01-01'::DATE) + (INTERVAL '1 months'))::DATE
),
febM AS (
  SELECT TO_CHAR(dy,'YYYY') AS yr,
         dy + id AS dy
    FROM feb1st, GENERATE_SERIES(1,29) x(id)
   WHERE TO_CHAR(dy + id,'MM') = '02'
)
SELECT *
  FROM febM;
```

|yr|dy     |
|:--:|:---------:|
|2020|2020-02-02 |
|2020|...........|
|2020|2020-02-29 |
|2021|2021-02-02 |
|2021|...........|
|2021|2021-02-28 |
|2022|2022-02-02 |
|2022|...........|
|2022|2022-02-28 |
