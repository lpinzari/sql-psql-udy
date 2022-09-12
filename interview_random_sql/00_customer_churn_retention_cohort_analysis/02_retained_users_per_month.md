# Retained Users per Month

Say we have a table logins in the form:

```SQL
CREATE TABLE logins (
  id INTEGER,
  user_id INTEGER,
  day TIMESTAMP
);
```

|user_id |            day|
|:------:|:-------------------------:|
|    100 | 2022-08-13 02:01:23.197028|
|     35 | 2022-06-25 02:01:23.197028|
|     86 | 2022-01-01 02:01:23.197028|
|     44 | 2022-04-04 02:01:23.197028|
|     39 | 2021-09-01 02:01:23.197028|
|     27 | 2022-08-13 02:01:23.197028|
|      7 | 2022-03-01 02:01:23.197028|
|     40 | 2022-05-13 02:01:23.197028|
|     19 | 2022-04-19 02:01:23.197028|
|     87 | 2021-11-14 02:01:23.197028|
| ....   |  ....                     |

Basically, it's the same table of the previous problem.

## Problem

1. Write a query that gets the number of **retained users per month**. In this case, `retention for a given month` is defined as the **number of users who logged in that month who also logged in the immediately previous month**.

|current_year |      period       | retained_users|
|:------------|:------------------|--------------:|
|2021         | SEPTEMBER-OCTOBER |             33|
|2021         | OCTOBER-NOVEMBER  |             32|
|2021         | NOVEMBER-DECEMBER |             36|
|2022         | DECEMBER-JANUARY  |             38|
|2022         | JANUARY-FEBRUARY  |             29|
|2022         | FEBRUARY-MARCH    |             35|
|2022         | MARCH-APRIL       |             37|
|2022         | APRIL-MAY         |             28|
|2022         | MAY-JUNE          |             24|
|2022         | JUNE-JULY         |             32|
|2022         | JULY-AUGUST       |             35|

For example, the number of retained users in the period `MAY-JUNE` of `2022` is `24`. Thus, `24` users who logged in the month of `JUNE` also logged the month before, `MAY`.

2. Find the retained users in a given period of time. For example, find the `24` retained users in the period `MAY-JUNE` of `2022`.

```console
retained_users_id_22_may_june
----------------------------
                         21
                         24
                         27
                         28
                         29
                         38
                         52
                         59
                         61
                         62
                         63
                         64
                         65
                         71
                         72
                         75
                         79
                         81
                         84
                         86
                         91
                         92
                         93
                         99
(24 rows)
```

## Solution

```SQL
WITH r_users AS (
  SELECT  COUNT(DISTINCT u1.user_id) AS retained_users
        , DATE_TRUNC('month',u1.day)::DATE AS current_ymth
        , DATE_TRUNC('month',u2.day)::DATE AS previous_ymth
    FROM logins u1
   INNER JOIN logins u2
      ON (u1.user_id = u2.user_id AND
          DATE_TRUNC('month',u2.day) = DATE_TRUNC('month',u1.day) - INTERVAL '1 month')
   GROUP BY current_ymth, previous_ymth
)
SELECT  TO_CHAR(current_ymth,'YYYY') AS current_year
      , REPLACE (TO_CHAR(previous_ymth,'MONTH') || '-' ||
                 TO_CHAR(current_ymth,'MONTH')
                 ,' ','')
        AS period
      , retained_users
  FROM r_users
 ORDER BY current_ymth;
```

- Problem **2**

```SQL
WITH r_users AS (
  SELECT  u1.user_id AS user_id
        , DATE_TRUNC('month',u1.day)::DATE AS current_mth
        , DATE_TRUNC('month',u2.day)::DATE AS previous_mth
    FROM logins u1
   INNER JOIN logins u2
      ON (u1.user_id = u2.user_id AND
          DATE_TRUNC('month',u2.day) = DATE_TRUNC('month',u1.day) - INTERVAL '1 month')
   WHERE  DATE_TRUNC('month',u1.day) = '2022-06-01 00:00:00'::TIMESTAMP
   GROUP BY 1, 2, 3
)
SELECT  user_id AS retained_user_id_22_May_June
  FROM  r_users;
```

## Discussion

First we need to find the users who logged in the system the month before. Let's look at a specific date.

```SQL
SELECT  u1.user_id AS user_id
      , DATE_TRUNC('month',u1.day) AS current_mth
      , DATE_TRUNC('month',u2.day) AS previous_mth
  FROM logins u1
 INNER JOIN logins u2
    ON (u1.user_id = u2.user_id AND
        DATE_TRUNC('month',u2.day) = DATE_TRUNC('month',u1.day) - INTERVAL '1 month')
 ORDER BY 2, 1;
```

```console
user_id |     current_mth     |    previous_mth
--------+---------------------+---------------------
      3 | 2021-10-01 00:00:00 | 2021-09-01 00:00:00
      3 | 2021-10-01 00:00:00 | 2021-09-01 00:00:00
      ----------------------------------------------- <- 1
      4 | 2021-10-01 00:00:00 | 2021-09-01 00:00:00
      ----------------------------------------------- <- 4
      5 | 2021-10-01 00:00:00 | 2021-09-01 00:00:00
      5 | 2021-10-01 00:00:00 | 2021-09-01 00:00:00
      ----------------------------------------------- <- 5
      6 | 2021-10-01 00:00:00 | 2021-09-01 00:00:00
      ----------------------------------------------- <- 6
      7 | 2021-10-01 00:00:00 | 2021-09-01 00:00:00
      ----------------------------------------------- <- 7
     10 | 2021-10-01 00:00:00 | 2021-09-01 00:00:00
     10 | 2021-10-01 00:00:00 | 2021-09-01 00:00:00
     10 | 2021-10-01 00:00:00 | 2021-09-01 00:00:00
     10 | 2021-10-01 00:00:00 | 2021-09-01 00:00:00
     -------------------------------------------------<- 10
     13 | 2021-10-01 00:00:00 | 2021-09-01 00:00:00
     13 | 2021-10-01 00:00:00 | 2021-09-01 00:00:00
     ------------------------------------------------ <- 13
     16 | 2021-10-01 00:00:00 | 2021-09-01 00:00:00
     ...
```

We want to count the number of distinct user who logged in for two months in a row.
In the picture above we see that at least 7 users logged in the system in the period of `2021-09-01` and `2021-10-01`.

The next step is to use an aggregation count.

```SQL
SELECT  COUNT(DISTINCT u1.user_id) AS retained_users
      , DATE_TRUNC('month',u1.day)::DATE AS current_mth
      , DATE_TRUNC('month',u2.day)::DATE AS previous_mth
  FROM logins u1
 INNER JOIN logins u2
    ON (u1.user_id = u2.user_id AND
        DATE_TRUNC('month',u2.day) = DATE_TRUNC('month',u1.day) - INTERVAL '1 month')
 GROUP BY current_mth, previous_mth
 ORDER BY current_mth;
```

```console
retained_users | current_mth | previous_mth
---------------+-------------+--------------
            33 | 2021-10-01  | 2021-09-01
            32 | 2021-11-01  | 2021-10-01
            36 | 2021-12-01  | 2021-11-01
            38 | 2022-01-01  | 2021-12-01
            29 | 2022-02-01  | 2022-01-01
            35 | 2022-03-01  | 2022-02-01
            37 | 2022-04-01  | 2022-03-01
            28 | 2022-05-01  | 2022-04-01
            24 | 2022-06-01  | 2022-05-01
            32 | 2022-07-01  | 2022-06-01
            35 | 2022-08-01  | 2022-07-01
(11 rows)
```

Let's change the date format for a more readable output.

```SQL
WITH r_users AS (
  SELECT  COUNT(DISTINCT u1.user_id) AS retained_users
        , DATE_TRUNC('month',u1.day)::DATE AS current_ymth
        , DATE_TRUNC('month',u2.day)::DATE AS previous_ymth
    FROM logins u1
   INNER JOIN logins u2
      ON (u1.user_id = u2.user_id AND
          DATE_TRUNC('month',u2.day) = DATE_TRUNC('month',u1.day) - INTERVAL '1 month')
   GROUP BY current_ymth, previous_ymth
)
SELECT  TO_CHAR(current_ymth,'YYYY') AS current_year
      , REPLACE (TO_CHAR(previous_ymth,'MONTH') || '-' ||
                 TO_CHAR(current_ymth,'MONTH')
                 ,' ','')
        AS period
      , retained_users
  FROM r_users
 ORDER BY current_ymth;
```

```console
current_year |      period       | retained_users
-------------+-------------------+----------------
2021         | SEPTEMBER-OCTOBER |             33
2021         | OCTOBER-NOVEMBER  |             32
2021         | NOVEMBER-DECEMBER |             36
2022         | DECEMBER-JANUARY  |             38
2022         | JANUARY-FEBRUARY  |             29
2022         | FEBRUARY-MARCH    |             35
2022         | MARCH-APRIL       |             37
2022         | APRIL-MAY         |             28
2022         | MAY-JUNE          |             24
2022         | JUNE-JULY         |             32
2022         | JULY-AUGUST       |             35
(11 rows)
```



This is more clear if we look at specific months

```SQL
SELECT  u1.user_id AS user_id
      , DATE_TRUNC('month',u1.day)::DATE AS current_mth
      , DATE_TRUNC('month',u2.day)::DATE AS previous_mth
  FROM logins u1
 INNER JOIN logins u2
    ON (u1.user_id = u2.user_id AND
        DATE_TRUNC('month',u2.day) = DATE_TRUNC('month',u1.day) - INTERVAL '1 month')
 WHERE  DATE_TRUNC('month',u1.day) = '2022-06-01 00:00:00'::TIMESTAMP
 GROUP BY 1, 2, 3;
```

For example, if we want to see all the `24` retained users  in the period `2022-06` and `2022-05`.

```console
user_id | current_mth | previous_mth
--------+-------------+--------------
     21 | 2022-06-01  | 2022-05-01
     24 | 2022-06-01  | 2022-05-01
     27 | 2022-06-01  | 2022-05-01
     28 | 2022-06-01  | 2022-05-01
     29 | 2022-06-01  | 2022-05-01
     38 | 2022-06-01  | 2022-05-01
     52 | 2022-06-01  | 2022-05-01
     59 | 2022-06-01  | 2022-05-01
     61 | 2022-06-01  | 2022-05-01
     62 | 2022-06-01  | 2022-05-01
     63 | 2022-06-01  | 2022-05-01
     64 | 2022-06-01  | 2022-05-01
     65 | 2022-06-01  | 2022-05-01
     71 | 2022-06-01  | 2022-05-01
     72 | 2022-06-01  | 2022-05-01
     75 | 2022-06-01  | 2022-05-01
     79 | 2022-06-01  | 2022-05-01
     81 | 2022-06-01  | 2022-05-01
     84 | 2022-06-01  | 2022-05-01
     86 | 2022-06-01  | 2022-05-01
     91 | 2022-06-01  | 2022-05-01
     92 | 2022-06-01  | 2022-05-01
     93 | 2022-06-01  | 2022-05-01
     99 | 2022-06-01  | 2022-05-01
(24 rows)
```

```SQL
WITH r_users AS (
  SELECT  u1.user_id AS user_id
        , DATE_TRUNC('month',u1.day)::DATE AS current_mth
        , DATE_TRUNC('month',u2.day)::DATE AS previous_mth
    FROM logins u1
   INNER JOIN logins u2
      ON (u1.user_id = u2.user_id AND
          DATE_TRUNC('month',u2.day) = DATE_TRUNC('month',u1.day) - INTERVAL '1 month')
   WHERE  DATE_TRUNC('month',u1.day) = '2022-06-01 00:00:00'::TIMESTAMP
   GROUP BY 1, 2, 3
)
SELECT  user_id AS retained_user_id_22_May_June
  FROM  r_users;
```

```console
retained_user_id_22_may_june
----------------------------
                         21
                         24
                         27
                         28
                         29
                         38
                         52
                         59
                         61
                         62
                         63
                         64
                         65
                         71
                         72
                         75
                         79
                         81
                         84
                         86
                         91
                         92
                         93
                         99
(24 rows)
```
