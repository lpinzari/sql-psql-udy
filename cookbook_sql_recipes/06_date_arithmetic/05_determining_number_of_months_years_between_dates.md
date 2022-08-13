# Determining the Number of Months or Years Between Two Dates

You want to **find the difference between two dates** in terms of either **months** or **years**.


## Problem

For example, you want to find the number of `days` and `months` **between the first and last employees hired**, and you also want to express that value as some number of `years`.

```SQL
SELECT MAX(hiredate) AS max_hd,
       MIN(hiredate) AS min_hd
  FROM emp;
```

|max_hd   |   min_hd|
|:---------:|:---------:|
|2015-12-17 | 2006-01-20|

**Output**

|max_hd   |   min_hd   |     time_difference     | years | months | days|
|:--------:|:----------:|:-----------------------:|:-----:|:-----:|:-----:|
|2015-12-17 | 2006-01-20 | 9 years 10 mons 28 days |     9 |     10 |   28|


## Solution

```SQL
WITH dates AS (
  SELECT MAX(hiredate) AS max_hd,
         MIN(hiredate) AS min_hd,
         AGE(MAX(hiredate),MIN(hiredate)) AS time_difference
    FROM emp
)
SELECT max_hd, min_hd, time_difference,
       EXTRACT(YEAR FROM time_difference) AS years,
       EXTRACT(MONTH FROM time_difference) AS months,
       EXTRACT(DAY FROM time_difference) AS days  
  FROM dates;
```

Use the function `AGE` to find the difference between two dates, and use the `EXTRACT` function to specify months and years as the time units returned.

## Discussion

Use the PostgreSQL **AGE()** function to retrieve the interval between two `timestamps` or `dates`.

This function takes two arguments: the `first` is the **end date** (`max_hd`) and the `second` is the **start date**.


- `AGE(MAX(hiredate),MIN(hiredate)) AS time_difference`

```console
9 years 10 mons 28 days
```

The difference between dates is returned as an interval in `years, months, days, hours, etc`. 
