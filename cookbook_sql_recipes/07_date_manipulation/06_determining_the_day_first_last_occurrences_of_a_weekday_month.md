# Determining the Date of the First and Last Occurrences of a Specific Weekday in a Month

You want to find, for example, the **first** and **last** `Mondays` of the **current month**.

## Problem

For example, the dates for Mondays in august `2022` are:

|monday|
|:--------:|
|2022-08-01| <---- first monday
|2022-08-08|
|2022-08-15|
|2022-08-22|
|2022-08-29| <----- last monday

|first_monday | last_monday|
|:-----------:|:----------:|
|2022-08-01   | 2022-08-29|

## Solution

Use the recursive WITH clause to generate each day in the current month and use a CASE expression to flag all Mondays. The first and last Mondays will be the earliest and latest of the flagged dates:

```SQL
WITH RECURSIVE cMthM (dy,mth,is_Monday) AS (
  SELECT dy,
         EXTRACT('MONTH' FROM dy),
         CASE WHEN EXTRACT('DOW' FROM dy)::INTEGER = 1
              THEN 1
              ELSE 0
         END
    FROM (SELECT CURRENT_DATE - EXTRACT('DAY' FROM CURRENT_DATE)::INTEGER + 1 AS dy) t
  UNION ALL
  SELECT dy + 1,
         EXTRACT('MONTH' FROM dy + 1),
         CASE WHEN EXTRACT('DOW' FROM dy + 1)::INTEGER = 1
              THEN 1
              ELSE 0
         END
    FROM cMthM
   WHERE EXTRACT('MONTH' FROM dy + 1) = mth
)
SELECT MIN(dy) AS first_monday,
       MAX(dy) AS last_monday
  FROM cMthM
 WHERE is_Monday = 1;
```

More clean and shorter version:

```SQL
WITH RECURSIVE cMthM (dy,mth,dow) AS (
  SELECT dy,
         EXTRACT('MONTH' FROM dy),
         EXTRACT('DOW' FROM dy)::INTEGER
    FROM (SELECT CURRENT_DATE - EXTRACT('DAY' FROM CURRENT_DATE)::INTEGER + 1 AS dy) t
  UNION ALL
  SELECT dy + 1,
         EXTRACT('MONTH' FROM dy + 1),
         EXTRACT('DOW' FROM dy + 1)::INTEGER
    FROM cMthM
   WHERE EXTRACT('MONTH' FROM dy + 1) = mth
)
SELECT MIN(dy) AS first_monday,
       MAX(dy) AS last_monday
  FROM cMthM
 WHERE dow = 1; -- 1 is code for Monday
```

- **Solution 2**:


```SQL
WITH RECURSIVE cMthM (monday, mth) AS (
  SELECT CASE WHEN dow = 0 THEN first_dy + 1
              WHEN dow = 1 THEN first_dy
              WHEN dow = 2 THEN first_dy + 6
              WHEN dow = 3 THEN first_dy + 5
              WHEN dow = 4 THEN first_dy + 4
              WHEN dow = 5 THEN first_dy + 3
              ELSE first_dy + 2
         END AS monday,
         EXTRACT('MONTH' FROM first_dy)
    FROM (SELECT first_dy,
                 EXTRACT('MONTH' FROM first_dy) AS mth,
                 EXTRACT('DOW' FROM first_dy)::INTEGER AS dow
            FROM (SELECT DATE_TRUNC('MONTH',CURRENT_DATE)::DATE first_dy) t)t2
  UNION ALL
  SELECT monday + 7,
         EXTRACT('MONTH' FROM monday + 7)
    FROM cMthM
   WHERE EXTRACT('MONTH' FROM monday + 7) = mth
)
SELECT MIN(monday) AS first_monday,
       MAX(monday) AS last_monday
  FROM cMthM;
```

- **Solution 3**:

```SQL
WITH RECURSIVE cMthM (monday, mth) AS (
 SELECT CASE WHEN SIGN(dow - 1) = -1 THEN first_dy + 1
             WHEN SIGN(dow - 1) =  0 THEN first_dy
             ELSE first_dy + (7 - dow)
        END AS monday,
        EXTRACT('MONTH' FROM first_dy)
   FROM (SELECT first_dy,
                EXTRACT('MONTH' FROM first_dy) AS mth,
                EXTRACT('DOW' FROM first_dy)::INTEGER AS dow
           FROM (SELECT DATE_TRUNC('MONTH',CURRENT_DATE)::DATE first_dy) AS t
         ) AS t2
 UNION ALL
 SELECT monday + 7,
        EXTRACT('MONTH' FROM monday + 7)
   FROM cMthM
  WHERE EXTRACT('MONTH' FROM monday + 7) = mth                
)
SELECT MIN(monday) AS first_monday,
       MAX(monday) AS last_monday
  FROM cMthM;
```

- **Solution 4**:


Use the function DATE_TRUNC to find the first day of the month. Once you have the first day of the month, you can use simple arithmetic involving the numeric values of weekdays (Sun–Sat is 1–7) to find the first and last Mondays of the current month:

```SQL
WITH t AS (
  SELECT first_dy,
         EXTRACT('MONTH' FROM first_dy) AS mth,
         EXTRACT('DOW' FROM first_dy)::INTEGER AS dow
    FROM (SELECT DATE_TRUNC('MONTH',CURRENT_DATE)::DATE first_dy ) x
),
t2 AS (
  SELECT CASE WHEN SIGN(dow - 1) = -1 THEN first_dy + 1
              WHEN SIGN(dow - 1) =  0 THEN first_dy
              ELSE first_dy + (7 - dow)
         END AS first_monday,
         mth
    FROM t
)
SELECT first_monday,
       CASE WHEN EXTRACT('MONTH' FROM first_monday + 28) = mth
            THEN first_monday + 28
            ELSE first_monday + 21
       END last_monday
  FROM t2;
```


## Discussion

```SQL
SELECT CURRENT_DATE,
       EXTRACT('DAY' FROM CURRENT_DATE)::INTEGER AS day_th,
       CURRENT_DATE - EXTRACT('DAY' FROM CURRENT_DATE)::INTEGER + 1 AS f_dy;
```

|current_date | day_th |    f_dy|
|:-----------:|:---:|:---------:|
|2022-08-15   |  15 | 2022-08-01|


```SQL
SELECT dy,
       EXTRACT('MONTH' FROM dy) AS mth,
       TO_CHAR(dy,'DAY') dow,
       CASE WHEN EXTRACT('DOW' FROM dy)::INTEGER = 1
            THEN 1
            ELSE 0
       END is_Monday
  FROM (SELECT CURRENT_DATE - EXTRACT('DAY' FROM CURRENT_DATE)::INTEGER + 1 AS dy) t;
```

|dy     | mth |    dow    | is_monday|
|:---------:|:---:|:---------:|:---------:|
|2022-08-01 |   8 | MONDAY    |         1|

```SQL
WITH RECURSIVE cMthM (dy,mth,is_Monday) AS (
  SELECT dy,
         EXTRACT('MONTH' FROM dy),
         CASE WHEN EXTRACT('DOW' FROM dy)::INTEGER = 1
              THEN 1
              ELSE 0
         END
    FROM (SELECT CURRENT_DATE - EXTRACT('DAY' FROM CURRENT_DATE)::INTEGER + 1 AS dy) t
  UNION ALL
  SELECT dy + 1,
         EXTRACT('MONTH' FROM dy + 1),
         CASE WHEN EXTRACT('DOW' FROM dy + 1)::INTEGER = 1
              THEN 1
              ELSE 0
         END
    FROM cMthM
   WHERE EXTRACT('MONTH' FROM dy + 1) = mth
)
SELECT *
  FROM cMthM;
```

```console
|dy     | mth | is_monday|
|:---------:|:---:|:--------:|
|2022-08-01 |   8 |         1|<---- first Monday
|2022-08-02 |   8 |         0|
|2022-08-03 |   8 |         0|
|2022-08-04 |   8 |         0|
|2022-08-05 |   8 |         0|
|2022-08-06 |   8 |         0|
|2022-08-07 |   8 |         0|
|2022-08-08 |   8 |         1|<---- 2nd Monday = first Monday + 7
|2022-08-09 |   8 |         0|
|2022-08-10 |   8 |         0|
|2022-08-11 |   8 |         0|
|2022-08-12 |   8 |         0|
|2022-08-13 |   8 |         0|
|2022-08-14 |   8 |         0|
|2022-08-15 |   8 |         1|<---- 3rd Monday = first Monday + 14
|2022-08-16 |   8 |         0|
|2022-08-17 |   8 |         0|
|2022-08-18 |   8 |         0|
|2022-08-19 |   8 |         0|
|2022-08-20 |   8 |         0|
|2022-08-21 |   8 |         0|
|2022-08-22 |   8 |         1|<----- last Monday = first Monday + 21
|2022-08-23 |   8 |         0|
|2022-08-24 |   8 |         0|
|2022-08-25 |   8 |         0|
|2022-08-26 |   8 |         0|
|2022-08-27 |   8 |         0|
|2022-08-28 |   8 |         0|
|2022-08-29 |   8 |         1|<----- first Monday + 28
|2022-08-30 |   8 |         0|
|2022-08-31 |   8 |         0|
```

```SQL
WITH RECURSIVE cMthM (dy,mth,is_Monday) AS (
  SELECT dy,
         EXTRACT('MONTH' FROM dy),
         CASE WHEN EXTRACT('DOW' FROM dy)::INTEGER = 1
              THEN 1
              ELSE 0
         END
    FROM (SELECT CURRENT_DATE - EXTRACT('DAY' FROM CURRENT_DATE)::INTEGER + 1 AS dy) t
  UNION ALL
  SELECT dy + 1,
         EXTRACT('MONTH' FROM dy + 1),
         CASE WHEN EXTRACT('DOW' FROM dy + 1)::INTEGER = 1
              THEN 1
              ELSE 0
         END
    FROM cMthM
   WHERE EXTRACT('MONTH' FROM dy + 1) = mth
)
SELECT dy AS monday
  FROM cMthM
 WHERE is_Monday = 1;
```

|monday|
|:--------:|
|2022-08-01|
|2022-08-08|
|2022-08-15|
|2022-08-22|
|2022-08-29|

```SQL
WITH RECURSIVE cMthM (dy,mth,dow) AS (
  SELECT dy,
         EXTRACT('MONTH' FROM dy),
         EXTRACT('DOW' FROM dy)::INTEGER
    FROM (SELECT CURRENT_DATE - EXTRACT('DAY' FROM CURRENT_DATE)::INTEGER + 1 AS dy) t
  UNION ALL
  SELECT dy + 1,
         EXTRACT('MONTH' FROM dy + 1),
         EXTRACT('DOW' FROM dy + 1)::INTEGER
    FROM cMthM
   WHERE EXTRACT('MONTH' FROM dy + 1) = mth
)
SELECT dy AS monday
  FROM cMthM
 WHERE dow = 1; -- 1 is code for Monday
```

### Solution 2

```SQL
WITH RECURSIVE cMthM (dy,mth,dow) AS (
  SELECT dy,
         EXTRACT('MONTH' FROM dy),
         EXTRACT('DOW' FROM dy)::INTEGER
    FROM (SELECT CURRENT_DATE - EXTRACT('DAY' FROM CURRENT_DATE)::INTEGER + 1 AS dy) t
  UNION ALL
  SELECT dy + 1,
         EXTRACT('MONTH' FROM dy + 1),
         EXTRACT('DOW' FROM dy + 1)::INTEGER
    FROM cMthM
   WHERE EXTRACT('MONTH' FROM dy + 1) = mth
)
SELECT dy AS monday
  FROM cMthM
 WHERE dow = 1; -- 1 is code for Monday
```

```SQL
SELECT CASE WHEN dow = 0 THEN first_dy + 1
            WHEN dow = 1 THEN first_dy
            WHEN dow = 2 THEN first_dy + 6
            WHEN dow = 3 THEN first_dy + 5
            WHEN dow = 4 THEN first_dy + 4
            WHEN dow = 5 THEN first_dy + 3
            ELSE first_dy + 2
       END AS first_monday
  FROM (SELECT first_dy,
               EXTRACT('MONTH' FROM first_dy) AS mth,
               EXTRACT('DOW' FROM first_dy)::INTEGER AS dow
          FROM (SELECT DATE_TRUNC('MONTH',CURRENT_DATE)::DATE first_dy) t)t2

```

|first_monday|
|:-----------:|
|2022-08-01|

## Solution 3

```SQL
SELECT CASE WHEN SIGN(dow - 1) = -1 THEN first_dy + 1
            WHEN SIGN(dow - 1) =  0 THEN first_dy
            ELSE first_dy + (7 - dow)
       END AS monday,
       EXTRACT('MONTH' FROM first_dy)
  FROM (SELECT first_dy,
               EXTRACT('MONTH' FROM first_dy) AS mth,
               EXTRACT('DOW' FROM first_dy)::INTEGER AS dow
          FROM (SELECT DATE_TRUNC('MONTH',CURRENT_DATE)::DATE first_dy) AS t
        ) AS t2;
```

If the result from SIGN is <= 0, then the first day of the month falls between Sunday and Monday (inclusive). When the first day of the month has a numeric value greater than 0 subtract from 7 the numeric value of dow, and then add that value to the first day of the month. You will have arrived at the day of the week that you are after, in this case Monday.


|monday   | date_part|
|:---------:|:---------:|
|2022-08-01 |         8|


```console
       (dow - 1)
SUN 0    -1 ----> first_day + 1
MON 1     0 ----> first_day
               (7 - dow)   (7 - dow) + (first_day)
TUE 2     1       6          Monday
WED 3     2       5
THU 4     3       4
FRY 5     4       3
SAT 6     5       2
```

You can extend the solution by adding 7 and 14 days to find the second and third Mondays of the month, respectively.
