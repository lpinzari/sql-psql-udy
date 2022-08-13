# Counting the Occurrences of Weekdays in a Year

You want to count **the number of times each weekday** occurs in the current year.

## Problem 1

For example in the year `2022` the number of weekdays are:

|weekday  | count_weekdays|
|:--------:|:--------------:|
|SUNDAY    |             53|
|MONDAY    |             52|
|TUESDAY   |             52|
|WEDNESDAY |             52|
|THURSDAY  |             52|
|FRIDAY    |             52|
|SATURDAY  |             52|

The resulting table is sorted on the chronological order of weekday, beginning with `SUNDAY`.

## Problem 2

Count the number of times each weekday occurs in the year `2022`, along with the first and last date. The resulting table is sorted by the first date of each weekday.

|weekday  | first_date | last_date  |  end_date  | count_weekday|
|:--------:|:----------:|:---------:|:----------:|:-------------:|
|SATURDAY  | 2022-01-01 | 2022-12-31 | 2022-12-31 |            53|
|SUNDAY    | 2022-01-02 | 2022-12-25 | 2022-12-31 |            52|
|MONDAY    | 2022-01-03 | 2022-12-26 | 2022-12-31 |            52|
|TUESDAY   | 2022-01-04 | 2022-12-27 | 2022-12-31 |            52|
|WEDNESDAY | 2022-01-05 | 2022-12-28 | 2022-12-31 |            52|
|THURSDAY  | 2022-01-06 | 2022-12-29 | 2022-12-31 |            52|
|FRIDAY    | 2022-01-07 | 2022-12-30 | 2022-12-31 |            52|

The first weekday of `2022` is `SATURDAY` (`2022-01-01`) followed by `SUNDAY`, ...,`FRIDAY`. The last weekday is `SATURDAY` (`2022-12-31`).

## Solution

To find the number of occurrences of each weekday in a year, you must:

1. Generate all possible dates in the year.
2. Format the dates such that they resolve to the name of their respective weekdays.
3. Count the occurrence of each weekday name.

- **Solution 1**:

```SQL
WITH stYr (start) AS (
  SELECT CAST(DATE_TRUNC('YEAR',CURRENT_DATE) AS DATE)
),
gs (id) AS (
  SELECT GENERATE_SERIES(1,366)
),
dys (days) AS (
  SELECT ((start + INTERVAL '12 month')::DATE) - start AS days
    FROM stYr
)
SELECT TO_CHAR(start + gs.id,'DAY') AS weekday,
       COUNT(*) AS count_weekdays
  FROM stYr, gs
 WHERE gs.id <= (SELECT days FROM dys)
 GROUP BY TO_CHAR(start + gs.id,'D'),weekday
 ORDER BY TO_CHAR(start + gs.id,'D');
```

Use the built-in function `GENERATE_SERIES` to generate one row for every day in the year. Then use the `TO_CHAR` function to obtain the weekday name of each date. Finally, count the occurrence of each weekday name.

- **Solution Problem 2**:

```SQL
WITH RECURSIVE temp(weekday, curr_date, end_date) AS (
  SELECT TO_CHAR(curr_date,'DAY'),
         t.curr_date,
         (curr_date + INTERVAL '12 months' - INTERVAL '1 days')::DATE
    FROM (SELECT (DATE_TRUNC('YEAR',CURRENT_DATE)::DATE) AS curr_date) t
  UNION ALL
  SELECT TO_CHAR(curr_date + 1,'DAY'),
         curr_date + 1,
         end_date
    FROM temp
   WHERE curr_date < end_date
)
SELECT weekday,
       MIN(curr_date) AS first_date,
       MAX(curr_date) AS last_date,
       MAX(end_date) AS end_date,
       COUNT(*) AS count_weekday
  FROM temp
 GROUP BY weekday
 ORDER BY first_date;
```

Use the `WITH RECURSIVE` to avoid the need to SELECT against a table with at least 366 rows. Use the `TO_CHAR` function to obtain the weekday name of each date, and then count the occurrence of each name.


## Discussion Solution 1

```SQL
SELECT CURRENT_DATE AS today,
       CAST( DATE_TRUNC('YEAR',CURRENT_DATE) AS DATE) AS start_date;
```

Returns the first day of the current year and is shown here as `start_date`:

|today    | start_date|
|:---------:|:---------:|
|2022-08-12 | 2022-01-01|

```SQL
WITH gs AS (
  SELECT generate_series(1,366) AS id
)
SELECT * FROM gs;
```

Generate a series of `366` integers:

|id|
|:--:|
| 1|
| 2|
| 3|
| 4|
| 5|
| 6|
| 7|
| 8|
| 9|
|10|
|..|
|366|

The next step is to select against a row source (any table expression, really) with at least 366 rows. The solution uses the function GENERATE_SERIES as the row source.

```SQL
WITH stYr (start) AS (
  SELECT CAST(DATE_TRUNC('YEAR',CURRENT_DATE) AS DATE)
),
gs (id) AS (
  SELECT GENERATE_SERIES(1,10)
)
SELECT ((start + INTERVAL '12 month')::DATE) - start AS days
  FROM stYr;
```

Returns the number of days in the current year:

|days|
|:--:|
| 365|


```SQL
WITH stYr (start) AS (
  SELECT CAST(DATE_TRUNC('YEAR',CURRENT_DATE) AS DATE)
),
gs (id) AS (
  SELECT GENERATE_SERIES(1,366)
),
dys (days) AS (
  SELECT ((start + INTERVAL '12 month')::DATE) - start AS days
    FROM stYr
)
SELECT TO_CHAR(start + gs.id,'DAY') AS weekday,
       COUNT(*) AS count_weekdays
  FROM stYr, gs
 WHERE gs.id <= (SELECT days FROM dys)
 GROUP BY weekday;
```
Then add `gs.id` to the first day of the current year until you return every day in the year.

The final step is to use the function `TO_CHAR` to return the weekday name for each date and then count the occurrence of each name.

## Discussion Solution 2

```SQL
WITH temp(weekday, curr_date, end_date) AS (
  SELECT TO_CHAR(curr_date,'DAY'),
         t.curr_date,
         (curr_date + INTERVAL '12 months')::DATE
    FROM (SELECT (DATE_TRUNC('YEAR',CURRENT_DATE)::DATE) AS curr_date) t
)
SELECT * FROM temp;
```
returns the first day of the current year and is shown here:

|weekday  | curr_date  |  end_date|
|:-------:|:-----------:|:----------:|
|SATURDAY  | 2022-01-01 | 2023-01-01|


```SQL
WITH temp(weekday, curr_date, end_date) AS (
  SELECT TO_CHAR(curr_date,'DAY'),
         t.curr_date,
         (curr_date + INTERVAL '12 months')::DATE
    FROM (SELECT (DATE_TRUNC('YEAR',CURRENT_DATE)::DATE) AS curr_date) t
)
SELECT * FROM temp
UNION ALL
SELECT TO_CHAR(curr_date + 1,'DAY'),
       curr_date + 1,
       end_date
  FROM temp;
```

Implementing the recursive step from the base case (CTE temp).

|weekday  | curr_date  |  end_date|
|:--------:|:----------:|:---------:|
|SATURDAY  | 2022-01-01 | 2023-01-01|
|SUNDAY    | 2022-01-02 | 2023-01-01|

```SQL
WITH RECURSIVE temp(weekday, curr_date, end_date) AS (
  SELECT TO_CHAR(curr_date,'DAY'),
         t.curr_date,
         (curr_date + INTERVAL '12 months')::DATE
    FROM (SELECT (DATE_TRUNC('YEAR',CURRENT_DATE)::DATE) AS curr_date) t
  UNION ALL
  SELECT TO_CHAR(curr_date + 1,'DAY'),
         curr_date + 1,
         end_date
    FROM temp
   WHERE curr_date < end_date
)
SELECT *
  FROM temp;
```

Testing the recursive query.

|weekday  | curr_date  |  end_date|
|:-------:|:-----------:|:---------:|
|SATURDAY  | 2022-01-01 | 2022-01-11|
|SUNDAY    | 2022-01-02 | 2022-01-11|
|MONDAY    | 2022-01-03 | 2022-01-11|
|TUESDAY   | 2022-01-04 | 2022-01-11|
|WEDNESDAY | 2022-01-05 | 2022-01-11|
|THURSDAY  | 2022-01-06 | 2022-01-11|
|FRIDAY    | 2022-01-07 | 2022-01-11|
|SATURDAY  | 2022-01-08 | 2022-01-11|
|SUNDAY    | 2022-01-09 | 2022-01-11|
|MONDAY    | 2022-01-10 | 2022-01-11|
|TUESDAY   | 2022-01-11 | 2022-01-11|
|......    | .......... | ..........|

```SQL
WITH RECURSIVE temp(weekday, curr_date, end_date) AS (
  SELECT TO_CHAR(curr_date,'DAY'),
         t.curr_date,
         (curr_date + INTERVAL '12 months' - INTERVAL '1 days')::DATE
    FROM (SELECT (DATE_TRUNC('YEAR',CURRENT_DATE)::DATE) AS curr_date) t
  UNION ALL
  SELECT TO_CHAR(curr_date + 1,'DAY'),
         curr_date + 1,
         end_date
    FROM temp
   WHERE curr_date < end_date
)
SELECT weekday,
       MIN(curr_date) AS first_date,
       MAX(curr_date) AS last_date,
       MAX(end_date) AS end_date,
       COUNT(*) AS count_weekday
  FROM temp
 GROUP BY weekday
 ORDER BY first_date;
```
