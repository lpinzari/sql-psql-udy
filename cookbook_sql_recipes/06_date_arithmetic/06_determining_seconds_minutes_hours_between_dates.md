# Determining the Number of Seconds, Minutes, or Hours Between Two Dates

You want to return the difference in seconds, minutes and hours between two dates.

## Problem

For example, you want to return the difference between the `HIREDATEs` of `ALLEN` and `WARD` in **seconds, minutes, hours and days**.

|ward_hd   |  allen_hd|
|:---------:|:---------:|
|2006-02-22 | 2006-01-20|

**Output**

|start_date |  end_date  | days | hours | minutes | seconds|
|:---------:|:----------:|:----:|:-----:|:-------:|:------:|
|2006-01-20 | 2006-02-22 |   33 |   792 |   47520 | 2851200|


## Solution

If you can find the number of days between two dates, you can find seconds, minutes, and hours as they are the units of time that make up a day.

```SQL
WITH hd_dates AS (
  SELECT MAX(CASE WHEN ename = 'WARD' THEN hiredate END) AS ward_hd,
         MAX(CASE WHEN ename = 'ALLEN' THEN hiredate END) AS allen_hd
    FROM emp
),
dates AS (
  SELECT CASE WHEN ward_hd <= allen_hd THEN ward_hd
              ELSE allen_hd END AS start_date,
         CASE WHEN ward_hd > allen_hd THEN ward_hd
              ELSE allen_hd END AS end_date
    FROM hd_dates
)
SELECT start_date, end_date, days,
       days*24 AS hours,
       days*24*60 AS minutes,
       days*24*60*60 AS seconds
  FROM (SELECT start_date, end_date,
               (end_date - start_date) AS days
          FROM dates) x;
```

Use subtraction to return the number of days between `ALLEN_HD` and `WARD_ HD`. Then multiply to find each unit of time.

## Discussion

Multiply the number of days between WARD_HD and ALLEN_HD by 24 (hours in a day), 24*60 = 1440 (minutes in a day), and (24 * 60 * 60) = 86400 (seconds in a day).
