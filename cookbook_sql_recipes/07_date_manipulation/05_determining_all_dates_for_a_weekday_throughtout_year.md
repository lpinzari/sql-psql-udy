# Determining All Dates for a Particular Weekday Throughout a Year


You want to find **all the dates in a year** that correspond to a **given day of the week**.

## Problem

For example, you may want to generate a **list of Fridays** for the **current year**.


The partial output for the year `2022`:

|friday|
|:--------:|
|2022-01-07|
|2022-01-14|
|..........|
|2022-12-30|


**Explanation**

```console
dy     |    dow
------------+-----------
2022-01-01 | SATURDAY
2022-01-02 | SUNDAY
2022-01-03 | MONDAY
2022-01-04 | TUESDAY
2022-01-05 | WEDNESDAY
2022-01-06 | THURSDAY
2022-01-07 | FRIDAY <------
2022-01-08 | SATURDAY
2022-01-09 | SUNDAY
2022-01-10 | MONDAY
2022-01-11 | TUESDAY
2022-01-12 | WEDNESDAY
2022-01-13 | THURSDAY
2022-01-14 | FRIDAY <-------
2022-01-15 | SATURDAY
.......... | ........
2022-12-28 | WEDNESDAY
2022-12-29 | THURSDAY
2022-12-30 | FRIDAY <--------
2022-12-31 | SATURDAY
````

## Solution

Use a recursive CTE to generate every day of the year, and filter out days that aren’t Fridays.  You can use simple arithmetic involving the numeric values of weekdays (Sun–Sat is 0–6). Friday is `5`. 

```SQL
WITH RECURSIVE temp (dy) AS (
  SELECT CURRENT_DATE - (EXTRACT('DOY' FROM CURRENT_DATE)::INTEGER - 1)
  UNION ALL
  SELECT dy + 1
    FROM temp
   WHERE EXTRACT('YEAR' FROM dy) = EXTRACT('YEAR' FROM dy + 1)
)
SELECT dy AS friday
  FROM temp
 WHERE EXTRACT('DOW' FROM dy)::INTEGER = 5;
```

## Discussion


To find all the Fridays in the current year, you must be able to return every day in the current year. The first step is to find the first day of the year

```SQL
SELECT CURRENT_DATE;
```

|current_date|
|:----------:|
|2022-08-15|

```SQL
SELECT EXTRACT('DOY' FROM CURRENT_DATE)::INTEGER dyr;
```

It returns the day of year. The day of year ranges from 1 to 366.

|dyr|
|:--:|
|227|


```SQL
SELECT CURRENT_DATE - (EXTRACT('DOY' FROM CURRENT_DATE)::INTEGER - 1) jan1st;
```

Compute the first date of the year. January 1st of current year.

|jan1st|
|:---------:|
|2022-01-01|

Now that you have the first day of the year, use the WITH clause to repeatedly add one day to the first day of the year until you are no longer in the current year. The result set will be every day in the current year.

**STEP 1**

```SQL
WITH temp AS (
  SELECT CURRENT_DATE - (EXTRACT('DOY' FROM CURRENT_DATE)::INTEGER - 1) AS dy
)
SELECT dy FROM temp
UNION All
SELECT dy + 1 FROM temp;  
```

|dy|
|:---------:|
|2022-01-01|
|2022-01-02|

**STEP 2**

```SQL
WITH temp AS (
  SELECT CURRENT_DATE - (EXTRACT('DOY' FROM CURRENT_DATE)::INTEGER - 1) AS dy
)
SELECT dy FROM temp
UNION ALL
SELECT dy + 1 FROM temp
UNION ALL
SELECT dy + 2 FROM temp;  
```

|dy|
|:--------:|
|2022-01-01|
|2022-01-02|
|2022-01-03|


**Terminating condition**

```SQL
WITH temp AS (
  SELECT CURRENT_DATE - (EXTRACT('DOY' FROM CURRENT_DATE)::INTEGER - 1) AS dy
)
SELECT dy, EXTRACT('YEAR' FROM dy) FROM temp -- step 0
UNION ALL
SELECT dy + 1, EXTRACT('YEAR' FROM dy+1) FROM temp -- step 1
UNION ALL
SELECT dy + 2, EXTRACT('YEAR' FROM dy+2) FROM temp -- step 3
UNION ALL
-- ....
SELECT dy + 363, EXTRACT('YEAR' FROM dy+363) FROM temp -- step  
UNION ALL
SELECT dy + 364, EXTRACT('YEAR' FROM dy+364) FROM temp -- step  
UNION ALL
SELECT dy + 365, EXTRACT('YEAR' FROM dy+365) FROM temp;   
```

```console
|dy     | date_part|
|:---------:|:---------:|
|2022-01-01 |      2022|
|2022-01-02 |      2022|
|2022-01-03 |      2022|
|.......... |      2022|
|2022-12-30 |      2022|
|2022-12-31 |      2022|<------ STOP       
|2023-01-01 |      2023|
````

```SQL
WITH temp AS (
  SELECT '2022-12-31'::DATE dy
)
SELECT dy + 1, EXTRACT('YEAR' FROM dy) AS yr_dy, EXTRACT('YEAR' FROM dy+1) yr_dy1 FROM temp;   
```

|dy  |  yr_dy  | yr_dy1|
|:---------:|:----:|:--------:|
|2023-01-01 | 2022 |      2023|


```SQL
WITH RECURSIVE temp (dy) AS (
  SELECT '2022-12-20'::DATE dy
  UNION ALL
  SELECT dy + 1
    FROM temp
   WHERE EXTRACT('YEAR' FROM dy) = EXTRACT('YEAR' FROM dy + 1)
)
SELECT *
  FROM temp;  
```

|dy|
|:---------:|
|2022-12-20|
|2022-12-21|
|2022-12-22|
|2022-12-23|
|2022-12-24|
|2022-12-25|
|2022-12-26|
|2022-12-27|
|2022-12-28|
|2022-12-29|
|2022-12-30|
|2022-12-31|

```SQL
WITH RECURSIVE temp (dy) AS (
  SELECT '2022-12-20'::DATE dy
  UNION ALL
  SELECT dy + 1
    FROM temp
   WHERE EXTRACT('YEAR' FROM dy) = EXTRACT('YEAR' FROM dy + 1)
)
SELECT dy, TO_CHAR(dy,'DAY') dow, EXTRACT('DOW' FROM dy) dow_id
  FROM temp;  
```

|dy     |  dow  | dow_id|
|:---------:|:---------:|:-----------|
|2022-12-20 | TUESDAY   |         2|
|2022-12-21 | WEDNESDAY |         3|
|2022-12-22 | THURSDAY  |         4|
|**2022-12-23** | **FRIDAY**    |         **5**|
|2022-12-24 | SATURDAY  |         6|
|2022-12-25 | SUNDAY    |         0|
|2022-12-26 | MONDAY    |         1|
|2022-12-27 | TUESDAY   |         2|
|2022-12-28 | WEDNESDAY |         3|
|2022-12-29 | THURSDAY  |         4|
|**2022-12-30** | **FRIDAY**    |         **5**|
|2022-12-31 | SATURDAY  |         6|

```SQL
WITH RECURSIVE temp (dy) AS (
  SELECT '2022-12-20'::DATE dy
  UNION ALL
  SELECT dy + 1
    FROM temp
   WHERE EXTRACT('YEAR' FROM dy) = EXTRACT('YEAR' FROM dy + 1)
)
SELECT dy, TO_CHAR(dy,'DAY') dow, EXTRACT('DOW' FROM dy) dow_id
  FROM temp
 WHERE EXTRACT('DOW' FROM dy)::INTEGER = 5;
```

|dy     |    dow    | dow_id|
|:---------:|:---------:|:-----:|
|2022-12-23 | FRIDAY    |      5|
|2022-12-30 | FRIDAY    |      5|
