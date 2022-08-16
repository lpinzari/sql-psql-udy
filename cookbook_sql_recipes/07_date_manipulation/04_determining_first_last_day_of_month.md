# Determining the First and Last Days of a Month

You want to determine the **first** and **last** `days` for the `current month`.

For example, suppose that the current date is: `2022-08-15`.

The first and last days are:

|first_dy  |  last_dy|
|:---------:|:----------:|
|2022-08-01 | 2022-08-31|



## Solution

The solutions presented here are for finding first and last days for the current month. Using the current month is arbitrary. With a bit of adjustment, you can make the solutions work for any month.

Use the `DATE_TRUNC` function to truncate the current date to the first of the cur‐ rent month. Once you have the first day of the month, add one month and subtract one day to find the end of the current month:

```SQL
WITH cMth AS (
  SELECT DATE_TRUNC('MONTH',CURRENT_DATE)::DATE first_dy
)
SELECT first_dy,
       (first_dy + INTERVAL '1 month' - INTERVAL '1 day')::DATE last_dy
  FROM cMth;
```

Apply the same technique to determine whether the current year is a leap year:


```SQL
WITH feb1st AS (
  SELECT ((DATE_TRUNC('YEAR',CURRENT_DATE)::DATE) + (INTERVAL '1 months'))::DATE AS fdy
),
feb AS (
  SELECT EXTRACT('YEAR' FROM fdy) AS year,
         EXTRACT('DAY' FROM (fdy + INTERVAL '1 month' - INTERVAL '1 day')::DATE) last_day
    FROM feb1st f
)
SELECT f.year, f.last_day,
       CASE WHEN f.last_day = 29
            THEN 1 ELSE 0
             END
       AS is_leap_yr
  FROM feb f;
```

|year | last_day | is_leap_yr|
|:---:|:--------:|:---------:|
|2022 |       28 |          0|


## Discussion


To find the first day of the current month, use the `DATE_TRUNC` function with “`MONTH`” as the second argument to “truncate” the current date down to the first of the month.

```SQL
WITH cMth AS (
  SELECT DATE_TRUNC('MONTH',CURRENT_DATE)::DATE first_dy
)
SELECT (first_dy + INTERVAL '1 month' - INTERVAL '1 day')::DATE
  FROM cMth;
```

|date|
|:---------:|
|2022-08-31|



```SQL
WITH cMth AS (
  SELECT DATE_TRUNC('MONTH',CURRENT_DATE)::DATE first_dy
)
SELECT * FROM cMth;
```

|first_dy|
|:--------:|
|2022-08-01|

**Step 2**:

To find the last day of the current month, add one month to the first day of the month, and then subtract one day.

```SQL
WITH cMth AS (
  SELECT DATE_TRUNC('MONTH',CURRENT_DATE)::DATE first_dy
)
SELECT (first_dy + INTERVAL '1 month')::DATE
  FROM cMth;
```

|date|
|:----------:|
|2022-09-01|

```SQL
WITH cMth AS (
  SELECT DATE_TRUNC('MONTH',CURRENT_DATE)::DATE first_dy
)
SELECT first_dy,
       (first_dy + INTERVAL '1 month' - INTERVAL '1 day')::DATE last_dy
  FROM cMth;
```

|date|
|:---------:|
|2022-08-31|
