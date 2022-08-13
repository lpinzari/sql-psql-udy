# Determining the Number of Business Days Between Two Dates

**Given two dates**, you want to find **how many** “`working`” **days are between them**. The number of `working` or `business` days is zero if the dates are equal.

## Problem

For this recipe, a “**business day**” is defined as:
- any day that is not `Saturday` or `Sunday`.

For example, if `2006-04-02` is a `Sunday` and `2006-04-09` is a `Sunday`, then the **number of working days between these two dates** is `5`:

|day     |    dow    |
|:---------:|:---------:|
|2006-04-02 | SUNDAY    |
|**2006-04-03** | **MONDAY**    |
|**2006-04-04** | **TUESDAY**   |
|**2006-04-05** | **WEDNESDAY** |
|**2006-04-06** | **THURSDAY**  |
|**2006-04-07** | **FRIDAY**    |
|2006-04-08 | SATURDAY  |
|2006-04-09 | SUNDAY    |

## Problem 1

Find the number of business days between the HIREDATEs of `BLAKE` and `JONES` in the `emp` table.

```console
cookbook=> \d emp
                        Table "public.emp"
  Column  |         Type          | Collation | Nullable | Default
----------+-----------------------+-----------+----------+---------
 empno    | integer               |           | not null |
 ename    | character varying(10) |           |          |
 job      | character varying(9)  |           |          |
 mgr      | integer               |           |          |
 hiredate | date                  |           |          |
 sal      | integer               |           |          |
 comm     | integer               |           |          |
 deptno   | integer               |           |          |
Indexes:
    "emp_pkey" PRIMARY KEY, btree (empno)
```


```SQL
SELECT ename, hiredate
  FROM emp
 WHERE ename = 'BLAKE' OR ename = 'JONES'
 ORDER BY hiredate;
```

|ename |  hiredate|
|:----:|:---------:|
|JONES | 2006-04-02|
|BLAKE | 2006-05-01|

**Output**

|blake_hd  |  jones_hd  | b_day|
|:---------:|:---------:|:-----:|
|2006-05-01 | 2006-04-02 |    21|


**Explanation**

| SUNDAY   | MONDAY   | TUESDAY  | WEDNESDAY | THURSDAY | FRIDAY | SATURDAY |
|:--------:|:--------:|:--------:|:---------:|:--------:|:------:|:---------:|
|2006-04-02|**2006-04-03**|**2006-04-04**|**2006-04-05**|**2006-04-06**|**2006-04-07**|2006-04-08|
|2006-04-09|**2006-04-10**|**2006-04-11**|**2006-04-12**|**2006-04-13**|**2006-04-14**|2006-04-15|
|2006-04-16|**2006-04-17**|**2006-04-18**|**2006-04-19**|**2006-04-20**|**2006-04-21**|2006-04-22|
|2006-04-23|**2006-04-24**|**2006-04-25**|**2006-04-26**|**2006-04-27**|**2006-04-28**|2006-04-29|
|2006-04-30|**2006-05-01**|          |          |          |          |          |

This table shows that the number of **business** days between the two dates are:

- `5 + 4*4` = **21**

On the other hand, the number of days between the tow dates are:

- `21`+ 8 = **29**

## Problem 2

Suppose, we want to exclude the following dates (holydays :smile:):  

- `2006-04-11`, `2006-04-19`, `2006-04-27`.

the number of **business** days between the two dates are **18**.

**Output**

|blake_hd  |  jones_hd  | b_day|
|:---------:|:---------:|:-----:|
|2006-05-01 | 2006-04-02 |    18|



## Solution

- **Problem 1**

```SQL
WITH hds AS (
  SELECT MAX(CASE WHEN ename = 'BLAKE'
                  THEN hiredate
                  END) AS blake_hd,
         MAX(CASE WHEN ename = 'JONES'
                  THEN hiredate
                  END) AS jones_hd
    FROM emp
   WHERE ename in ('BLAKE','JONES')
),
totDays AS (
  SELECT CASE WHEN jones_hd > blake_hd
              THEN (jones_hd - blake_hd + 1)
              ELSE (blake_hd - jones_hd + 1)
         END AS n_days
    FROM hds
),
idDays AS (
  SELECT generate_series(1,n_days) AS n
    FROM totDays
)
SELECT blake_hd, jones_hd,
       SUM(CASE WHEN jones_hd > blake_hd
                THEN CASE WHEN TRIM(TO_CHAR(blake_hd + n - 1,'DAY')) IN ('SATURDAY','SUNDAY')
                         THEN 0 ELSE 1
                     END
                WHEN jones_hd < blake_hd
                THEN CASE WHEN TRIM(TO_CHAR(jones_hd + n - 1,'DAY')) IN ('SATURDAY','SUNDAY')
                         THEN 0 ELSE 1
                     END
                ELSE 0
           END) AS b_day
 FROM hds, idDays
GROUP BY blake_hd, jones_hd;
```
To determine the number of business days between two dates, you can use a pivot table to return a row for each day between the two dates (including the start and end dates). Then count each day that is not a weekend. Use the `TO_CHAR` function to obtain the weekday name of each date:

Having done that, finding the number of business days is simply counting the dates returned that are not Saturday or Sunday.

Then count each day that is not a weekend. Use the TO_CHAR function to obtain the weekday name of each date.

- **Problem 2**:


```SQL
WITH hl AS (
  SELECT '2006-04-11'::DATE AS h_day
  UNION ALL
  SELECT '2006-04-19'::DATE AS h_day
  UNION ALL
  SELECT '2006-04-27'::DATE AS h_day
),
hds AS (
  SELECT MAX(CASE WHEN ename = 'BLAKE'
                  THEN hiredate
                  END) AS blake_hd,
         MAX(CASE WHEN ename = 'JONES'
                  THEN hiredate
                  END) AS jones_hd
    FROM emp
   WHERE ename in ('BLAKE','JONES')
),
totDays AS (
  SELECT CASE WHEN jones_hd > blake_hd
              THEN (jones_hd - blake_hd + 1)
              ELSE (blake_hd - jones_hd + 1)
         END AS n_days
    FROM hds
),
idDays AS (
  SELECT generate_series(1,n_days) AS n
    FROM totDays
)
SELECT blake_hd, jones_hd,
       SUM(CASE WHEN jones_hd > blake_hd
                THEN CASE WHEN TRIM(TO_CHAR(blake_hd + n - 1,'DAY')) IN ('SATURDAY','SUNDAY') OR (blake_hd + n -1) IN (SELECT h_day FROM hl)
                         THEN 0 ELSE 1
                     END
                WHEN jones_hd < blake_hd
                THEN CASE WHEN TRIM(TO_CHAR(jones_hd + n - 1,'DAY')) IN ('SATURDAY','SUNDAY') OR (jones_hd + n - 1) IN (SELECT h_day FROM hl)
                         THEN 0 ELSE 1
                     END
                ELSE 0
           END) AS b_day
 FROM hds, idDays
GROUP BY blake_hd, jones_hd;
```

If you want to exclude holidays as well, you can create a HOLIDAYS, `hl` table.

## Discussion

This solution does use a pivot idDays generated as a sequence of numbers using the `generate_series` function provided by PostgreSQL.

For instance, to generate a sequence of 5 integer values we could simply create a CTE as follow:

```SQL
WITH t5 AS (
  SELECT generate_series(1,5) AS pos
)
SELECT pos, pg_typeof(pos)
  FROM t5;
```

|pos | pg_typeof|
|:--:|:---------:|
|  1 | integer|
|  2 | integer|
|  3 | integer|
|  4 | integer|
|  5 | integer|


The solution can be broken into two steps:

1. Return the days between the start date and end date (inclusive).
2. Count how many days (i.e., rows) there are, excluding weekends.

### STEP 0

The first CTE,`hds`, returns the two dates to be compared:

```SQL
SELECT MAX(CASE WHEN ename = 'BLAKE'
                THEN hiredate
                END) AS blake_hd,
       MAX(CASE WHEN ename = 'JONES'
                THEN hiredate
                END) AS jones_hd
  FROM emp
 WHERE ename in ('BLAKE','JONES');
```

|blake_hd  |  jones_hd|
|:--------:|:----------:|
|2006-05-01 | 2006-04-02|

If you examine this query, you’ll notice the use of the aggregate function `MAX`, which the recipe uses to remove `NULLs`. If the use of `MAX` is unclear, the following output might help you understand. The output shows the results from the previous query without `MAX`:

```SQL
SELECT CASE WHEN ename = 'BLAKE'
            THEN hiredate
            END AS blake_hd,
       CASE WHEN ename = 'JONES'
            THEN hiredate
            END AS jones_hd
  FROM emp
 WHERE ename in ('BLAKE','JONES');
```

|blake_hd  |  jones_hd|
|:---------:|:---------:|
|NULL       | 2006-04-02|
|2006-05-01 | NULL|

Without `MAX`, two rows are returned. By using `MAX` you return only one row instead of two, and the `NULLs` are eliminated.

### STEP 1

```SQL
WITH hds AS (
  SELECT MAX(CASE WHEN ename = 'BLAKE'
                  THEN hiredate
                  END) AS blake_hd,
         MAX(CASE WHEN ename = 'JONES'
                  THEN hiredate
                  END) AS jones_hd
    FROM emp
   WHERE ename in ('BLAKE','JONES')
)
SELECT blake_hd - jones_hd  AS days
  FROM hds;
```

|days|
|:---:|
|  29|

The number of days between the two dates here is `29`. In this query we've hard coded the difference without checking the start and ending date.

```SQL
WITH hds AS (
  SELECT MAX(CASE WHEN ename = 'BLAKE'
                  THEN hiredate
                  END) AS blake_hd,
         MAX(CASE WHEN ename = 'JONES'
                  THEN hiredate
                  END) AS jones_hd
    FROM emp
   WHERE ename in ('BLAKE','JONES')
)
SELECT jones_hd - blake_hd  AS days
  FROM hds;
```

|days|
|:---:|
|  -29|

We have to compare the dates and use a `CASE` statement before computing the difference.


### STEP 2

```SQL
WITH hds AS (
  SELECT MAX(CASE WHEN ename = 'BLAKE'
                  THEN hiredate
                  END) AS blake_hd,
         MAX(CASE WHEN ename = 'JONES'
                  THEN hiredate
                  END) AS jones_hd
    FROM emp
   WHERE ename in ('BLAKE','JONES')
)
SELECT CASE WHEN jones_hd > blake_hd
            THEN (jones_hd - blake_hd + 1)
            ELSE (blake_hd - jones_hd + 1)
       END AS days_plus_one
  FROM hds;
```
The difference between the two dates here is `30`.


### STEP 3

```SQL
WITH hds AS (
  SELECT MAX(CASE WHEN ename = 'BLAKE'
                  THEN hiredate
                  END) AS blake_hd,
         MAX(CASE WHEN ename = 'JONES'
                  THEN hiredate
                  END) AS jones_hd
    FROM emp
   WHERE ename in ('BLAKE','JONES')
),
totDays AS (
  SELECT CASE WHEN jones_hd > blake_hd
              THEN (jones_hd - blake_hd + 1)
              ELSE (blake_hd - jones_hd + 1)
         END AS n_days
    FROM hds
),
idDays AS (
  SELECT generate_series(1,n_days) AS n
    FROM totDays
)
SELECT blake_hd, jones_hd, n
  FROM hds, idDays
 WHERE n >= 29;
```

In case the dates are equal the difference returns `1` in the **CTE** `tot_days`. (When we sum we subtract 1 in the final solution).

Use a pivot table idDays to generate the required number of rows (days) between the two dates.

|blake_hd  |  jones_hd  | n|
|:---------:|:----------:|:--:|
|2006-05-01 | 2006-04-02 |  1|
|2006-05-01 | 2006-04-02 |  2|
|2006-05-01 | 2006-04-02 |  3|
|2006-05-01 | 2006-04-02 |  4|
|2006-05-01 | 2006-04-02 |  5|
|2006-05-01 | 2006-04-02 |  6|
|2006-05-01 | 2006-04-02 |  7|
|2006-05-01 | 2006-04-02 |  8|
|...|...|...|
|2006-05-01 | 2006-04-02 | 29|
|2006-05-01 | 2006-04-02 | 30|

The `n` column is a supporting column that will help us to increment the starting date.

### STEP 4

```SQL
SELECT '2006-04-02'::DATE AS day,
       TO_CHAR('2006-04-02':: DATE,'DAY') AS dow,
       0 AS bday
UNION ALL
SELECT '2006-04-02'::DATE + 1 AS day,
       TO_CHAR('2006-04-02':: DATE + 1,'DAY') AS dow,
       1 AS bday
UNION ALL
SELECT '2006-04-02'::DATE + 2 AS day,
       TO_CHAR('2006-04-02':: DATE + 2,'DAY') AS dow,
       1 AS bday
UNION ALL
SELECT '2006-04-02'::DATE + 3 AS day,
       TO_CHAR('2006-04-02':: DATE + 3,'DAY') AS dow,
       1 AS bday
UNION ALL
SELECT '2006-04-02'::DATE + 4 AS day,
       TO_CHAR('2006-04-02':: DATE + 4,'DAY') AS dow,
       1 AS bday
UNION ALL
SELECT '2006-04-02'::DATE + 5 AS day,
       TO_CHAR('2006-04-02':: DATE + 5,'DAY') AS dow,
       1 AS bday
UNION ALL
SELECT '2006-04-02'::DATE + 6 AS day,
       TO_CHAR('2006-04-02':: DATE + 6,'DAY') AS dow,
       0 AS bday
UNION ALL
SELECT '2006-04-02'::DATE + 7 AS day,
       TO_CHAR('2006-04-02':: DATE + 7,'DAY') AS dow,
       0 AS bday;
```

|day     |    dow    | bday|
|:--------:|:----------:|:----:|
|2006-04-02 | SUNDAY    |    0|
|2006-04-03 | MONDAY    |    1|
|2006-04-04 | TUESDAY   |    1|
|2006-04-05 | WEDNESDAY |    1|
|2006-04-06 | THURSDAY  |    1|
|2006-04-07 | FRIDAY    |    1|
|2006-04-08 | SATURDAY  |    0|
|2006-04-09 | SUNDAY    |    0|

The objective is to increment the starting date by one and checking if `day` is a **business day**. We'll show how to do this in the next step.

### STEP 5

```SQL
WITH hds AS (
  SELECT MAX(CASE WHEN ename = 'BLAKE'
                  THEN hiredate
                  END) AS blake_hd,
         MAX(CASE WHEN ename = 'JONES'
                  THEN hiredate
                  END) AS jones_hd
    FROM emp
   WHERE ename in ('BLAKE','JONES')
),
totDays AS (
  SELECT CASE WHEN jones_hd > blake_hd
              THEN (jones_hd - blake_hd + 1)
              ELSE (blake_hd - jones_hd + 1)
         END AS n_days
    FROM hds
),
idDays AS (
  SELECT generate_series(1,n_days) AS n
    FROM totDays
)
SELECT n,blake_hd, jones_hd,
       CASE WHEN jones_hd > blake_hd THEN blake_hd + n - 1
            ELSE jones_hd + n - 1
       END AS day,
       CASE WHEN jones_hd > blake_hd THEN TRIM(TO_CHAR(blake_hd + n - 1,'DAY'))
            ELSE TRIM(TO_CHAR(jones_hd + n - 1,'DAY'))
       END AS dow,
       CASE WHEN jones_hd > blake_hd
            THEN CASE WHEN TRIM(TO_CHAR(blake_hd + n - 1,'DAY')) IN ('SATURDAY','SUNDAY')
                      THEN 0 ELSE 1
                 END
            ELSE CASE WHEN TRIM(TO_CHAR(jones_hd + n - 1,'DAY')) IN ('SATURDAY','SUNDAY')
                      THEN 0 ELSE 1
                 END
       END AS b_day
 FROM hds, idDays
WHERE n >= 27;
```


|n |  blake_hd  |  jones_hd  |    day     |    dow    | b_day|
|:-:|:---------:|:----------:|:-----------:|:--------:|:-----:|
|1 | 2006-05-01 | 2006-04-02 | 2006-04-02 | SUNDAY    |     0|
|2 | 2006-05-01 | 2006-04-02 | 2006-04-03 | MONDAY    |     1|
|3 | 2006-05-01 | 2006-04-02 | 2006-04-04 | TUESDAY   |     1|
|4 | 2006-05-01 | 2006-04-02 | 2006-04-05 | WEDNESDAY |     1|
|5 | 2006-05-01 | 2006-04-02 | 2006-04-06 | THURSDAY  |     1|
|6 | 2006-05-01 | 2006-04-02 | 2006-04-07 | FRIDAY    |     1|
|7 | 2006-05-01 | 2006-04-02 | 2006-04-08 | SATURDAY  |     0|
|8 | 2006-05-01 | 2006-04-02 | 2006-04-09 | SUNDAY    |     0|
|... | ... | ... | ... | ...    |   ...|
|29 | 2006-05-01 | 2006-04-02 | 2006-04-30 | SUNDAY |     0|
|30 | 2006-05-01 | 2006-04-02 | 2006-05-01 | MONDAY |     1|

### STEP 6

```SQL
WITH hds AS (
  SELECT MAX(CASE WHEN ename = 'BLAKE'
                  THEN hiredate
                  END) AS blake_hd,
         '2006-05-01'::DATE AS jones_hd
    FROM emp
   WHERE ename in ('BLAKE','JONES')
),
totDays AS (
  SELECT CASE WHEN jones_hd > blake_hd
              THEN (jones_hd - blake_hd + 1)
              ELSE (blake_hd - jones_hd + 1)
         END AS n_days
    FROM hds
),
idDays AS (
  SELECT generate_series(1,n_days) AS n
    FROM totDays
)
SELECT n,blake_hd, jones_hd,
       CASE WHEN jones_hd > blake_hd THEN blake_hd + n - 1
            ELSE jones_hd + n - 1
       END AS day,
       CASE WHEN jones_hd > blake_hd THEN TRIM(TO_CHAR(blake_hd + n - 1,'DAY'))
            ELSE TRIM(TO_CHAR(jones_hd + n - 1,'DAY'))
       END AS dow,
       CASE WHEN jones_hd > blake_hd
            THEN CASE WHEN TRIM(TO_CHAR(blake_hd + n - 1,'DAY')) IN ('SATURDAY','SUNDAY')
                      THEN 0 ELSE 1
                 END
            ELSE CASE WHEN TRIM(TO_CHAR(jones_hd + n - 1,'DAY')) IN ('SATURDAY','SUNDAY')
                      THEN 0 ELSE 1
                 END
       END AS b_day
 FROM hds, idDays;
```

|n |  blake_hd  |  jones_hd  |    day     |  dow   | b_day|
|:-:|:---------:|:----------:|:----------:|:------:|:----:|
|1 | 2006-05-01 | 2006-05-01 | 2006-05-01 | MONDAY |     1|

This table output shows that we need to consider the edge case of equal dates.

### STEP 7

```SQL
WITH hds AS (
  SELECT MAX(CASE WHEN ename = 'BLAKE'
                  THEN hiredate
                  END) AS blake_hd,
         '2006-05-01'::DATE AS jones_hd
    FROM emp
   WHERE ename in ('BLAKE','JONES')
),
totDays AS (
  SELECT CASE WHEN jones_hd > blake_hd
              THEN (jones_hd - blake_hd + 1)
              ELSE (blake_hd - jones_hd + 1)
         END AS n_days
    FROM hds
),
idDays AS (
  SELECT generate_series(1,n_days) AS n
    FROM totDays
)
SELECT blake_hd, jones_hd,
       SUM(CASE WHEN jones_hd > blake_hd
                THEN CASE WHEN TRIM(TO_CHAR(blake_hd + n - 1,'DAY')) IN ('SATURDAY','SUNDAY')
                         THEN 0 ELSE 1
                     END
                WHEN jones_hd < blake_hd
                THEN CASE WHEN TRIM(TO_CHAR(jones_hd + n - 1,'DAY')) IN ('SATURDAY','SUNDAY')
                         THEN 0 ELSE 1
                     END
                ELSE 0 -- Equal dates
           END) AS b_day
 FROM hds, idDays
GROUP BY blake_hd, jones_hd;
```

|blake_hd  |  jones_hd  | b_day|
|:---------:|:----------:|:-----:|
|2006-05-01 | 2006-05-01 |     0|

Once you generate the number of rows required for the result set, use a CASE expres‐ sion to “flag” whether each of the days returned is weekday or weekend (return a 1 for a weekday and a 0 for a weekend). The final step is to use the aggregate function `SUM` to tally up the number of `1s` to get the final answer.

Now we can sum the values in the `b_day` column.

```SQL
WITH hds AS (
  SELECT MAX(CASE WHEN ename = 'BLAKE'
                  THEN hiredate
                  END) AS blake_hd,
         MAX(CASE WHEN ename = 'JONES'
                  THEN hiredate
                  END) AS jones_hd
    FROM emp
   WHERE ename in ('BLAKE','JONES')
),
totDays AS (
  SELECT CASE WHEN jones_hd > blake_hd
              THEN (jones_hd - blake_hd + 1)
              ELSE (blake_hd - jones_hd + 1)
         END AS n_days
    FROM hds
),
idDays AS (
  SELECT generate_series(1,n_days) AS n
    FROM totDays
)
SELECT blake_hd, jones_hd,
       SUM(CASE WHEN jones_hd > blake_hd
                THEN CASE WHEN TRIM(TO_CHAR(blake_hd + n - 1,'DAY')) IN ('SATURDAY','SUNDAY')
                         THEN 0 ELSE 1
                     END
                WHEN jones_hd < blake_hd
                THEN CASE WHEN TRIM(TO_CHAR(jones_hd + n - 1,'DAY')) IN ('SATURDAY','SUNDAY')
                         THEN 0 ELSE 1
                     END
                ELSE 0
           END) AS b_day
 FROM hds, idDays
GROUP BY blake_hd, jones_hd;
```
