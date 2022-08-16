# Listing Quarter Start and End Dates for the Year

You want to return the **start** and **end** `dates` for **each of the four quarters of a given year**.


## Problem


For example, the start and end `dates` for each of the four quarters of `2022` are:

|q |  q_start   |   q_end|
|:-:|:---------:|:---------:|
|1 | 2022-01-01 | 2022-03-31|
|2 | 2022-04-01 | 2022-06-30|
|3 | 2022-07-01 | 2022-09-30|
|4 | 2022-10-01 | 2022-12-31|

## Solution

Find the first day of the year based on the current date, and use a recursive CTE to fill in the first date of the remaining three quarters before finding the last day of each quarter:

```SQL
WITH RECURSIVE startQ (dy,q) AS (
  SELECT (DATE_TRUNC('YEAR',CURRENT_DATE)::DATE),
         1
  UNION ALL
  SELECT (dy + INTERVAL '3 months')::DATE,
         q + 1
    FROM startQ
   WHERE q + 1 <= 4
)
SELECT q,
       dy AS q_start,
       (dy + INTERVAL '3 months')::DATE - 1 AS q_end
  FROM startQ;
```

- **Solution 2**

```SQL
WITH cYearQ AS (
  SELECT (DATE_TRUNC('YEAR',CURRENT_DATE)::DATE) AS q1_year
),
qS AS (
  SELECT id + 1 AS q,
         (q1_year + id*INTERVAL '3 months')::DATE AS q_start
    FROM cYearQ, GENERATE_SERIES(0,3) x(id)
)
SELECT q,
       q_start,
       (q_start + INTERVAL '3 months')::DATE - 1 AS q_end
  FROM qS;
```

## Discussion


```SQL
WITH cYearQ AS (
  SELECT (DATE_TRUNC('YEAR',CURRENT_DATE)::DATE) AS curr_year
)
SELECT *
  FROM cYearQ;
```

The first step is to find the first day of the current year.
To do that, invoke the DATE_ TRUNC function.

|curr_year|
|:----------:|
|2022-01-01|

Then add `3` months,

```SQL
WITH cYearQ AS (
  SELECT (DATE_TRUNC('YEAR',CURRENT_DATE)::DATE) AS dy,
         1 AS cnt
)
SELECT *
  FROM cYearQ
UNION ALL
SELECT (dy + INTERVAL '3 months')::DATE,
       cnt + 1
  FROM cYearQ;
```

|dy     | cnt|
|:---------:|:---:|
|2022-01-01 |   1|
|2022-04-01 |   2|


hen add `3` months,

```SQL
WITH cYearQ AS (
  SELECT (DATE_TRUNC('YEAR',CURRENT_DATE)::DATE) AS dy,
         1 AS cnt
),
cYearQ1 AS (
  SELECT (dy + INTERVAL '3 months')::DATE AS dy,
         cnt + 1 AS cnt
    FROM cYearQ
)
SELECT *
  FROM cYearQ
UNION ALL
SELECT *
  FROM cYearQ1
UNION ALL
SELECT (dy + INTERVAL '3 months')::DATE,
       cnt + 1
  FROM cYearQ1;
```

|dy     | cnt|
|:---------:|:--:|
|2022-01-01 |   1|
|2022-04-01 |   2|
|2022-07-01 |   3|

hen add `3` months,

```SQL
WITH cYearQ AS (
  SELECT (DATE_TRUNC('YEAR',CURRENT_DATE)::DATE) AS dy,
         1 AS cnt
),
cYearQ1 AS (
  SELECT (dy + INTERVAL '3 months')::DATE AS dy,
         cnt + 1 AS cnt
    FROM cYearQ
),
CYearQ2 AS (
  SELECT (dy + INTERVAL '3 months')::DATE AS dy,
         cnt + 1 AS cnt
    FROM cYearQ1
)
SELECT *
  FROM cYearQ
UNION ALL
SELECT *
  FROM cYearQ1
UNION ALL
SELECT *
  FROM cYearQ2
UNION ALL
SELECT (dy + INTERVAL '3 months')::DATE,
       cnt + 1
  FROM cYearQ2;
```

|dy     | cnt|
|:---------:|:--:|
|2022-01-01 |   1|
|2022-04-01 |   2|
|2022-07-01 |   3|
|2022-10-01 |   4|

Put all the previous steps together in a `RECURSIVE` procedure:

```SQL
WITH RECURSIVE startQ (dy,q) AS (
  SELECT (DATE_TRUNC('YEAR',CURRENT_DATE)::DATE),
         1
  UNION ALL
  SELECT (dy + INTERVAL '3 months')::DATE,
         q + 1
    FROM startQ
   WHERE q + 1 <= 4
)
SELECT *
  FROM startQ;
```

The resulting table list the beginning of each quarter.

|dy     | q|
|:---------:|:--:|
|2022-01-01 | 1|
|2022-04-01 | 2|
|2022-07-01 | 3|
|2022-10-01 | 4|

Finally, computes the ending date of each quarter.

```SQL
WITH RECURSIVE startQ (dy,q) AS (
  SELECT (DATE_TRUNC('YEAR',CURRENT_DATE)::DATE),
         1
  UNION ALL
  SELECT (dy + INTERVAL '3 months')::DATE,
         q + 1
    FROM startQ
   WHERE q + 1 <= 4
)
SELECT q,
       dy AS q_start,
       (dy + INTERVAL '3 months')::DATE - 1 AS q_end
  FROM startQ;
```

### Solution 2

```SQL
WITH cYearQ AS (
  SELECT (DATE_TRUNC('YEAR',CURRENT_DATE)::DATE) AS q1_year
)
SELECT id + 1 AS q,
       (q1_year + id*INTERVAL '3 months')::DATE AS q_start
  FROM cYearQ, GENERATE_SERIES(0,3) x(id);
```

|q |  q_start|
|:-:|:--------:|
|1 | 2022-01-01|
|2 | 2022-04-01|
|3 | 2022-07-01|
|4 | 2022-10-01|
