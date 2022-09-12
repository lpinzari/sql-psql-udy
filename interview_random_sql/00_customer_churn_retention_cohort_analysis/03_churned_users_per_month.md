# Churned Users per month

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

1. Write a query to find **how many users this month did not login the month before**. i.e. the `number of returning users`.

|year |      period       | cnt_returning_users|
|:---:|:-----------------:|:----------------:|
|2021 | SEPTEMBER-OCTOBER |                29|
|2021 | OCTOBER-NOVEMBER  |                25|
|2021 | NOVEMBER-DECEMBER |                24|
|2022 | DECEMBER-JANUARY  |                20|
|2022 | JANUARY-FEBRUARY  |                25|
|2022 | FEBRUARY-MARCH    |                28|
|2022 | MARCH-APRIL       |                15|
|2022 | APRIL-MAY         |                22|
|2022 | MAY-JUNE          |                26|
|2022 | JUNE-JULY         |                32|
|2022 | JULY-AUGUST       |                25|

For example, in year `2021` **29** users logged during the month of `OCTOBER` but they did not log the month before, (i.e `SEPTEMBER`).

2. Write a query to find **how many users last month did not come back this month**. i.e. the `number of churned users`.

|year |      period       | cnt_churned_users|
|:---:|:-----------------:|:----------------:|
|2021 | SEPTEMBER-OCTOBER |                21|
|2021 | OCTOBER-NOVEMBER  |                30|
|2021 | NOVEMBER-DECEMBER |                21|
|2021 | DECEMBER-JANUARY  |                22|
|2022 | JANUARY-FEBRUARY  |                29|
|2022 | FEBRUARY-MARCH    |                19|
|2022 | MARCH-APRIL       |                26|
|2022 | APRIL-MAY         |                24|
|2022 | MAY-JUNE          |                26|
|2022 | JUNE-JULY         |                18|
|2022 | JULY-AUGUST       |                29|
|2022 | AUGUST-SEPTEMBER  |                60|

For example, in year `2021` **21** users logged during the month of `SEPTEMBER` but they did not log the following month, (i.e `OCTOBER`).

In the previous [exercise](./02_retained_users_per_month.md) we calculated the number of retained users.

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



3. We want generate to generate a report table with the total count of:

- **returning_users**: calculated in `problem 1`.
- **churned_users**: calculated in  `problem 2`.
- **retained_users**: calculated [here](./02_retained_users_per_month.md)
- **not_logged_users**: logged users who did not log in the two months time window.
- **logged_users_cnt**: the number of logged users in the time window.
- **users_cnt**: the number of users who logged in the system.

For simplicity use the following abbreviations:

- `returning_u`
- `churned`
- `retained`
- `not_logged`
- `logged`
- `tot_cnt`

```console
year |      period       | returning_u | churned | retained | not_logged | logged | tot_cnt
------+-------------------+-------------+---------+----------+------------+--------+---------
 2021 | SEPTEMBER-OCTOBER |          29 |      21 |       33 |         13 |     87 |     100
 2021 | OCTOBER-NOVEMBER  |          25 |      30 |       32 |          6 |     94 |     100
 2021 | NOVEMBER-DECEMBER |          24 |      21 |       36 |          7 |     93 |     100
 2022 | DECEMBER-JANUARY  |          20 |      22 |       38 |          2 |     98 |     100
 2022 | JANUARY-FEBRUARY  |          25 |      29 |       29 |         13 |     87 |     100
 2022 | FEBRUARY-MARCH    |          28 |      19 |       35 |         11 |     89 |     100
 2022 | MARCH-APRIL       |          15 |      26 |       37 |          0 |    100 |     100
 2022 | APRIL-MAY         |          22 |      24 |       28 |         20 |     80 |     100
 2022 | MAY-JUNE          |          26 |      26 |       24 |         26 |     74 |     100
 2022 | JUNE-JULY         |          32 |      18 |       32 |         18 |     82 |     100
 2022 | JULY-AUGUST       |          25 |      29 |       35 |          1 |     99 |     100
```


## Solution

- **Problem 1**:

```SQL
WITH c_users AS (
  SELECT  DATE_TRUNC('month',u1.day)::DATE AS y_month
        , COUNT(DISTINCT u1.user_id) returning_users
    FROM logins u1
    LEFT JOIN logins u2
      ON (u1.user_id = u2.user_id AND
          DATE_TRUNC('month',u2.day) = DATE_TRUNC('month',u1.day) - INTERVAL '1 month')
   WHERE (u2.user_id IS NULL AND DATE_TRUNC('month',u2.day)::DATE IS NULL)
   GROUP BY y_month
)
SELECT  TO_CHAR(y_month,'YYYY') AS year
      , REPLACE(TO_CHAR((y_month - INTERVAL '1 month')::DATE,'MONTH') || '-' ||
                TO_CHAR(y_month,'MONTH')
                ,' ','')
        AS period
      , returning_users AS cnt_returning_users
  FROM c_users
 WHERE y_month > (SELECT MIN(y_month) FROM c_users)
 ORDER BY y_month;
```

- **Problem 2**:

```SQL
WITH c_users AS (
  SELECT  DATE_TRUNC('month',u1.day)::DATE AS y_month
        , COUNT(DISTINCT u1.user_id) churned_users
    FROM logins u1
    LEFT JOIN logins u2
      ON (u1.user_id = u2.user_id AND
          DATE_TRUNC('month',u2.day) = DATE_TRUNC('month',u1.day) + INTERVAL '1 month')
   WHERE (u2.user_id IS NULL AND DATE_TRUNC('month',u2.day)::DATE IS NULL)
   GROUP BY y_month
)
SELECT  TO_CHAR(y_month,'YYYY') AS year
      , REPLACE(TO_CHAR(y_month,'MONTH') || '-' ||
                TO_CHAR((y_month + INTERVAL '1 month')::DATE,'MONTH')
                ,' ','')
        AS period
      , churned_users AS cnt_churned_users
  FROM c_users
 WHERE y_month < (SELECT MAX(y_month) FROM c_users)
 ORDER BY y_month;
```

- **Problem 3**:

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
),
retained AS (
  SELECT  TO_CHAR(current_ymth,'YYYY') AS year
        , REPLACE (TO_CHAR(previous_ymth,'MONTH') || '-' ||
                   TO_CHAR(current_ymth,'MONTH')
                   ,' ','')
          AS period
        , retained_users AS cnt_retained_users
    FROM r_users
   ORDER BY current_ymth
),
report AS (
  SELECT  CASE WHEN (rc.year IS NULL AND rc.period IS NULL)
               THEN  rd.year
               ELSE  rc.year
          END AS year
        , CASE WHEN (rc.period IS NULL AND rc.year IS NULL)
               THEN  rd.period
               ELSE  rc.period
          END AS period
        , cnt_returning_users AS returning_u
        , cnt_churned_users AS churned
        , cnt_retained_users AS retained
        , cnt_retained_users + cnt_churned_users + cnt_retained_users AS logged
        , (SELECT COUNT(DISTINCT user_id) FROM logins) AS tot_cnt
    FROM returned_churned AS rc
    FULL OUTER JOIN retained AS rd
      ON (rc.year = rd.year AND rc.period = rd.period)
)
SELECT  year
      , period
      , returning_u
      , churned
      , retained
      , tot_cnt - logged AS not_logged
      , logged
      , tot_cnt
  FROM report;
```

For the definition of table `returned_churned` please check the discussion section.

## Discussion

Let's analyse the login history of a single user. For example, we want to track the login history of user `1` and find out the periods this user did not login the month before.

```SQL
SELECT u1.user_id AS u1
      ,u2.user_id AS u2
      ,DATE_TRUNC('month',u1.day)::DATE AS dy1
      ,DATE_TRUNC('month',u2.day)::DATE AS dy2
  FROM logins u1
  LEFT JOIN logins u2
    ON (u1.user_id = u2.user_id AND
        DATE_TRUNC('month',u2.day) = DATE_TRUNC('month',u1.day) - INTERVAL '1 month')
 WHERE (u2.user_id IS NULL AND DATE_TRUNC('month',u2.day)::DATE IS NULL) AND
       (u1.user_id = 1)
 ORDER BY 1, 2,3,4;
```

The above query will output all, (all the unmatched rows of the left join  in table login), the users who logged in a specific month but did not login the month before. The `ON` condition of the above query indicates all the existing rows in table login such that the same user `u1.user_id = u2.user_id` logged in the month before:

- `DATE_TRUNC('month',u2.day) = DATE_TRUNC('month',u1.day) - INTERVAL '1 month'`

```console
u1 | u2 |    dy1     | dy2
----+----+------------+-----
 1 |    | 2021-12-01 |      He did not login
 1 |    | 2021-12-01 |       2021-11-01
 1 |    | 2021-12-01 |
 -----------------------
 1 |    | 2022-03-01 |       2022-02-01
 -----------------------
 1 |    | 2022-07-01 |       2022-06-01
```

The output shows that user `1` logged in three times in `December 2021` but did not login the month before `November 2021`. Then, in `March 2022` and `July 2022` he did a single login and did not login the month before, (`February 2022`,`June 2022`).

How can we check this out?

Let's filter the login history of user `1` for these periods of time:

- `2021-11-01`: **November 2021**
- `2022-02-01`: **February 2022**
- `2022-06-01`: **June 2022**

```SQL
SELECT user_id
      ,TO_CHAR(DATE_TRUNC('month',day)::DATE,'MONTH YYYY') AS mthy
  FROM logins
 WHERE (DATE_TRUNC('month',day)::DATE = '2021-11-01' OR
        DATE_TRUNC('month',day)::DATE = '2022-02-01' OR
        DATE_TRUNC('month',day)::DATE = '2022-06-01') AND
        user_id = 1;
```

```console
user_id  | mthy
---------+------
(0 rows)
```
As expected, user `1` did not login in the three months indicated by the sql query.

The last step is to count the number of returning users using an aggregation COUNT query.

```SQL
WITH c_users AS (
  SELECT  DATE_TRUNC('month',u1.day)::DATE AS y_month
        , COUNT(DISTINCT u1.user_id) returning_users
    FROM logins u1
    LEFT JOIN logins u2
      ON (u1.user_id = u2.user_id AND
          DATE_TRUNC('month',u2.day) = DATE_TRUNC('month',u1.day) - INTERVAL '1 month')
   WHERE (u2.user_id IS NULL AND DATE_TRUNC('month',u2.day)::DATE IS NULL)
   GROUP BY y_month
)
SELECT  TO_CHAR(y_month,'YYYY') AS year
      , TO_CHAR(y_month,'MONTH') AS month
      , returning_users AS cnt_returning_users
  FROM c_users;
```

```console
year |   month   | cnt_returning_users
-----+-----------+-------------------
2021 | SEPTEMBER |                54 <--- Exclude
2021 | OCTOBER   |                29
2021 | NOVEMBER  |                25
2021 | DECEMBER  |                24
2022 | JANUARY   |                20
2022 | FEBRUARY  |                25
2022 | MARCH     |                28
2022 | APRIL     |                15
2022 | MAY       |                22
2022 | JUNE      |                26
2022 | JULY      |                32
2022 | AUGUST    |                25
```

We have to exclude the earliest date (`SEPTEMBER 2021`) since we do not have data for the month before (`AUGUST 2021`) and all the users who logged in that period are returning users.

```SQL
SELECT DATE_TRUNC('month',day)::DATE AS mth,
       COUNT(DISTINCT user_id) AS mau
  FROM logins
 GROUP BY mth
 ORDER BY mth;
```
This is clear if we look at the monthly active users output table.

```console
mth        | mau
-----------+-----
2021-09-01 |  54 <-----
2021-10-01 |  62
2021-11-01 |  57
2021-12-01 |  60
2022-01-01 |  58
2022-02-01 |  54
2022-03-01 |  63
2022-04-01 |  52
2022-05-01 |  50
2022-06-01 |  50
2022-07-01 |  64
2022-08-01 |  60
(12 rows)
```

Let's include the condition in the `WHERE` clause:

```SQL
WITH c_users AS (
  SELECT  DATE_TRUNC('month',u1.day)::DATE AS y_month
        , COUNT(DISTINCT u1.user_id) returning_users
    FROM logins u1
    LEFT JOIN logins u2
      ON (u1.user_id = u2.user_id AND
          DATE_TRUNC('month',u2.day) = DATE_TRUNC('month',u1.day) - INTERVAL '1 month')
   WHERE (u2.user_id IS NULL AND DATE_TRUNC('month',u2.day)::DATE IS NULL)
   GROUP BY y_month
)
SELECT  TO_CHAR(y_month,'YYYY') AS year
      , REPLACE(TO_CHAR((y_month - INTERVAL '1 month')::DATE,'MONTH') || '-' ||
                TO_CHAR(y_month,'MONTH')
                ,' ','')
        AS period
      , returning_users AS cnt_returning_users
  FROM c_users
 WHERE y_month > (SELECT MIN(y_month) FROM c_users)
 ORDER BY y_month;
```

|year |      period       | cnt_returning_users|
|:---:|:-----------------:|:----------------:|
|2021 | SEPTEMBER-OCTOBER |                29|
|2021 | OCTOBER-NOVEMBER  |                25|
|2021 | NOVEMBER-DECEMBER |                24|
|2022 | DECEMBER-JANUARY  |                20|
|2022 | JANUARY-FEBRUARY  |                25|
|2022 | FEBRUARY-MARCH    |                28|
|2022 | MARCH-APRIL       |                15|
|2022 | APRIL-MAY         |                22|
|2022 | MAY-JUNE          |                26|
|2022 | JUNE-JULY         |                32|
|2022 | JULY-AUGUST       |                25|

### Number of Churned users

The problem is somehow similar to problem 1. This time we take into account `1 month` later rather than `1 month earlier` in the join condition.

Let's analyse the login history of a single user. For example, we want to track the login history of user `1` and find out the periods this user did not login the following month.

```SQL
SELECT u1.user_id AS u1
      ,u2.user_id AS u2
      ,DATE_TRUNC('month',u1.day)::DATE AS dy1
      ,DATE_TRUNC('month',u2.day)::DATE AS dy2
  FROM logins u1
  LEFT JOIN logins u2
    ON (u1.user_id = u2.user_id AND
        DATE_TRUNC('month',u2.day) = DATE_TRUNC('month',u1.day) + INTERVAL '1 month')
 WHERE (u2.user_id IS NULL AND DATE_TRUNC('month',u2.day)::DATE IS NULL) AND
       (u1.user_id = 1)
 ORDER BY 1, 2,3,4;
```

```console
u1 | u2 |    dy1     | dy2
----+----+------------+-----
 1 |    | 2022-01-01 |        He did not login
 1 |    | 2022-01-01 |   <--- 2022-02
 -------------------------
 1 |    | 2022-05-01 |
 1 |    | 2022-05-01 |   <--- 2022-06
 ------------------------
 1 |    | 2022-08-01 |
 1 |    | 2022-08-01 |
 1 |    | 2022-08-01 |   <--- 2022-09
 1 |    | 2022-08-01 |
(8 rows)
```

The output shows that user `1` logged in two times in `January 2022` but did not login the following month `February 2022`. Then, in `May 2022` and `August 2022` he logged in but did not login the following month , (`June 2022`,`September 2022`).

How can we check this out?

Let's filter the login history of user `1` for these periods of time:

- `2022-02-01`: **February 2022**
- `2022-06-01`: **June 2022**
- `2022-09-01`: **September 2022**

```SQL
SELECT user_id
      ,TO_CHAR(DATE_TRUNC('month',day)::DATE,'MONTH YYYY') AS mthy
  FROM logins
 WHERE (DATE_TRUNC('month',day)::DATE = '2022-02-01' OR
        DATE_TRUNC('month',day)::DATE = '2022-06-01' OR
        DATE_TRUNC('month',day)::DATE = '2022-09-01') AND
        user_id = 1;
```

```console
user_id  | mthy
---------+------
(0 rows)
```
As expected, user `1` did not login in the three months indicated by the sql query.

The last step is to count the number of `churned` users using an aggregation COUNT query.

```SQL
SELECT  DATE_TRUNC('month',u1.day)::DATE AS y_month
      , COUNT(DISTINCT u1.user_id) churned_users
  FROM logins u1
  LEFT JOIN logins u2
    ON (u1.user_id = u2.user_id AND
        DATE_TRUNC('month',u2.day) = DATE_TRUNC('month',u1.day) + INTERVAL '1 month')
 WHERE (u2.user_id IS NULL AND DATE_TRUNC('month',u2.day)::DATE IS NULL)
 GROUP BY y_month;
```

```console
y_month    | churned_users
-----------+---------------
2021-09-01 |            21
2021-10-01 |            30
2021-11-01 |            21
2021-12-01 |            22
2022-01-01 |            29
2022-02-01 |            19
2022-03-01 |            26
2022-04-01 |            24
2022-05-01 |            26
2022-06-01 |            18
2022-07-01 |            29
2022-08-01 |            60 <--- Excluded
(12 rows)
```

We have to exclude the latest date (`AUGUST 2022`) since we do not have data for the following month (`SEPTEMBER 2022`) and all the users who logged in that period are churned users.

```SQL
SELECT DATE_TRUNC('month',day)::DATE AS mth,
       COUNT(DISTINCT user_id) AS mau
  FROM logins
 GROUP BY mth
 ORDER BY mth;
```
This is clear if we look at the monthly active users output table.

```console
mth        | mau
-----------+-----
2021-09-01 |  54
2021-10-01 |  62
2021-11-01 |  57
2021-12-01 |  60
2022-01-01 |  58
2022-02-01 |  54
2022-03-01 |  63
2022-04-01 |  52
2022-05-01 |  50
2022-06-01 |  50
2022-07-01 |  64
2022-08-01 |  60 <---
(12 rows)
```

Let's include the condition in the `WHERE` clause.


```SQL
WITH c_users AS (
  SELECT  DATE_TRUNC('month',u1.day)::DATE AS y_month
        , COUNT(DISTINCT u1.user_id) churned_users
    FROM logins u1
    LEFT JOIN logins u2
      ON (u1.user_id = u2.user_id AND
          DATE_TRUNC('month',u2.day) = DATE_TRUNC('month',u1.day) + INTERVAL '1 month')
   WHERE (u2.user_id IS NULL AND DATE_TRUNC('month',u2.day)::DATE IS NULL)
   GROUP BY y_month
)
SELECT  TO_CHAR(y_month + INTERVAL '1 month','YYYY') AS year
      , REPLACE(TO_CHAR(y_month,'MONTH') || '-' ||
                TO_CHAR((y_month + INTERVAL '1 month')::DATE,'MONTH')
                ,' ','')
        AS period
      , churned_users AS cnt_churned_users
  FROM c_users
 WHERE y_month < (SELECT MAX(y_month) FROM c_users)
 ORDER BY y_month;
```

```console
year |      period       | cnt_churned_users
-----+-------------------+-------------------
2021 | SEPTEMBER-OCTOBER |                21
2021 | OCTOBER-NOVEMBER  |                30
2021 | NOVEMBER-DECEMBER |                21
2022 | DECEMBER-JANUARY  |                22
2022 | JANUARY-FEBRUARY  |                29
2022 | FEBRUARY-MARCH    |                19
2022 | MARCH-APRIL       |                26
2022 | APRIL-MAY         |                24
2022 | MAY-JUNE          |                26
2022 | JUNE-JULY         |                18
2022 | JULY-AUGUST       |                29
(11 rows)
```


For example, in year `2021` **21** users logged during the month of `SEPTEMBER` but they did not log the following month, (i.e `OCTOBER`).

## Problem 3

```SQL
WITH c_users AS (
  SELECT  DATE_TRUNC('month',u1.day)::DATE AS y_month
        , COUNT(DISTINCT u1.user_id) returning_users
    FROM logins u1
    LEFT JOIN logins u2
      ON (u1.user_id = u2.user_id AND
          DATE_TRUNC('month',u2.day) = DATE_TRUNC('month',u1.day) - INTERVAL '1 month')
   WHERE (u2.user_id IS NULL AND DATE_TRUNC('month',u2.day)::DATE IS NULL)
   GROUP BY y_month
),
ret_users AS (
  SELECT  TO_CHAR(y_month,'YYYY') AS year
        , REPLACE(TO_CHAR((y_month - INTERVAL '1 month')::DATE,'MONTH') || '-' ||
                  TO_CHAR(y_month,'MONTH')
                  ,' ','')
          AS period
        , returning_users AS cnt_returning_users
    FROM c_users
   WHERE y_month > (SELECT MIN(y_month) FROM c_users)
),
c2_users AS (
  SELECT  DATE_TRUNC('month',u1.day)::DATE AS y_month
        , COUNT(DISTINCT u1.user_id) churned_users
    FROM logins u1
    LEFT JOIN logins u2
      ON (u1.user_id = u2.user_id AND
          DATE_TRUNC('month',u2.day) = DATE_TRUNC('month',u1.day) + INTERVAL '1 month')
   WHERE (u2.user_id IS NULL AND DATE_TRUNC('month',u2.day)::DATE IS NULL)
   GROUP BY y_month
),
chu_users AS (
  SELECT  y_month
        , TO_CHAR(y_month + INTERVAL '1 month','YYYY') AS year
        , REPLACE(TO_CHAR(y_month,'MONTH') || '-' ||
                  TO_CHAR((y_month + INTERVAL '1 month')::DATE,'MONTH')
                  ,' ','')
          AS period
        , churned_users AS cnt_churned_users
    FROM c2_users
   WHERE y_month < (SELECT MAX(y_month) FROM c_users)
)

SELECT  CASE WHEN (rtu.year IS NULL AND rtu.period IS NULL)
             THEN  chu.year
             ELSE  rtu.year
        END AS year
      , CASE WHEN (rtu.period IS NULL AND rtu.year IS NULL)
             THEN  chu.period
             ELSE  rtu.period
        END AS period
      , cnt_returning_users
      , cnt_churned_users
  FROM ret_users rtu
  FULL OUTER JOIN chu_users chu
    ON (rtu.year = chu.year AND rtu.period = chu.period)
 ORDER BY chu.y_month;
```

The use of a `FULL OUTER JOIN` is to consider the edge case of only churned users or returning users in the time window frame. In this case, all the time windows have both type of users as confirmed by the output table below:

```console
year |      period       | cnt_returning_users | cnt_churned_users
-----+-------------------+---------------------+-------------------
2021 | SEPTEMBER-OCTOBER |                  29 |                21
2021 | OCTOBER-NOVEMBER  |                  25 |                30
2021 | NOVEMBER-DECEMBER |                  24 |                21
2022 | DECEMBER-JANUARY  |                  20 |                22
2022 | JANUARY-FEBRUARY  |                  25 |                29
2022 | FEBRUARY-MARCH    |                  28 |                19
2022 | MARCH-APRIL       |                  15 |                26
2022 | APRIL-MAY         |                  22 |                24
2022 | MAY-JUNE          |                  26 |                26
2022 | JUNE-JULY         |                  32 |                18
2022 | JULY-AUGUST       |                  25 |                29
(11 rows)
```

The next step is the inclusion of retained users column in the output table.


```SQL
CREATE VIEW returned_churned AS
WITH c_users AS (
  SELECT  DATE_TRUNC('month',u1.day)::DATE AS y_month
        , COUNT(DISTINCT u1.user_id) returning_users
    FROM logins u1
    LEFT JOIN logins u2
      ON (u1.user_id = u2.user_id AND
          DATE_TRUNC('month',u2.day) = DATE_TRUNC('month',u1.day) - INTERVAL '1 month')
   WHERE (u2.user_id IS NULL AND DATE_TRUNC('month',u2.day)::DATE IS NULL)
   GROUP BY y_month
),
ret_users AS (
  SELECT  TO_CHAR(y_month,'YYYY') AS year
        , REPLACE(TO_CHAR((y_month - INTERVAL '1 month')::DATE,'MONTH') || '-' ||
                  TO_CHAR(y_month,'MONTH')
                  ,' ','')
          AS period
        , returning_users AS cnt_returning_users
    FROM c_users
   WHERE y_month > (SELECT MIN(y_month) FROM c_users)
),
c2_users AS (
  SELECT  DATE_TRUNC('month',u1.day)::DATE AS y_month
        , COUNT(DISTINCT u1.user_id) churned_users
    FROM logins u1
    LEFT JOIN logins u2
      ON (u1.user_id = u2.user_id AND
          DATE_TRUNC('month',u2.day) = DATE_TRUNC('month',u1.day) + INTERVAL '1 month')
   WHERE (u2.user_id IS NULL AND DATE_TRUNC('month',u2.day)::DATE IS NULL)
   GROUP BY y_month
),
chu_users AS (
  SELECT  y_month
        , TO_CHAR(y_month + INTERVAL '1 month','YYYY') AS year
        , REPLACE(TO_CHAR(y_month,'MONTH') || '-' ||
                  TO_CHAR((y_month + INTERVAL '1 month')::DATE,'MONTH')
                  ,' ','')
          AS period
        , churned_users AS cnt_churned_users
    FROM c2_users
   WHERE y_month < (SELECT MAX(y_month) FROM c_users)
)

SELECT  CASE WHEN (rtu.year IS NULL AND rtu.period IS NULL)
             THEN  chu.year
             ELSE  rtu.year
        END AS year
      , CASE WHEN (rtu.period IS NULL AND rtu.year IS NULL)
             THEN  chu.period
             ELSE  rtu.period
        END AS period
      , cnt_returning_users
      , cnt_churned_users
  FROM ret_users rtu
  FULL OUTER JOIN chu_users chu
    ON (rtu.year = chu.year AND rtu.period = chu.period)
 ORDER BY chu.y_month;
```


We first create a temporary view for convenience and readability.

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
),
retained AS (
  SELECT  TO_CHAR(current_ymth,'YYYY') AS year
        , REPLACE (TO_CHAR(previous_ymth,'MONTH') || '-' ||
                   TO_CHAR(current_ymth,'MONTH')
                   ,' ','')
          AS period
        , retained_users AS cnt_retained_users
    FROM r_users
   ORDER BY current_ymth
)
SELECT  CASE WHEN (rc.year IS NULL AND rc.period IS NULL)
             THEN  rd.year
             ELSE  rc.year
        END AS year
      , CASE WHEN (rc.period IS NULL AND rc.year IS NULL)
             THEN  rd.period
             ELSE  rc.period
        END AS period
      , cnt_returning_users
      , cnt_churned_users
      , cnt_retained_users
  FROM returned_churned AS rc
  FULL OUTER JOIN retained AS rd
    ON (rc.year = rd.year AND rc.period = rd.period);
```

```console
year |      period       | cnt_returning_users | cnt_churned_users | cnt_retained_users
-----+-------------------+---------------------+-------------------+--------------------
2021 | SEPTEMBER-OCTOBER |                  29 |                21 |                 33
2021 | OCTOBER-NOVEMBER  |                  25 |                30 |                 32
2021 | NOVEMBER-DECEMBER |                  24 |                21 |                 36
2022 | DECEMBER-JANUARY  |                  20 |                22 |                 38
2022 | JANUARY-FEBRUARY  |                  25 |                29 |                 29
2022 | FEBRUARY-MARCH    |                  28 |                19 |                 35
2022 | MARCH-APRIL       |                  15 |                26 |                 37
2022 | APRIL-MAY         |                  22 |                24 |                 28
2022 | MAY-JUNE          |                  26 |                26 |                 24
2022 | JUNE-JULY         |                  32 |                18 |                 32
2022 | JULY-AUGUST       |                  25 |                29 |                 35
(11 rows)
```

By looking at the last three columns of the resulting table can we guess the number of distinct users in the following periods of `2021`:

- `SEPTEMBER` ?
- `OCTOBER` ?
- `SEPTEMBER - OCTOBER` ?

Think carefully about the definition of returning, churned and retained users.  

- `returning`:  number of users who logged this month (`OCTOBER`) but did not login the month before, (`SEPTEMBER`).
- `churned`: number of users who logged last month but did not come back this month.
- `retained`: number of users who logged in that month who also logged in the immediately previous month.

```SQL
WITH log_sep AS (
  SELECT 'SEPTEMBER' AS period
        , COUNT(DISTINCT user_id) AS cnt
    FROM logins
   WHERE DATE_TRUNC('month',day)::DATE = '2021-09-01'
),
log_oct AS (
  SELECT 'OCTOBER' AS period
        , COUNT(DISTINCT user_id) AS cnt
    FROM logins
   WHERE DATE_TRUNC('month',day)::DATE = '2021-10-01'
),
log_sep_oct AS (
  SELECT 'SEPTEMBER-OCTOBER' AS period
        , COUNT(DISTINCT user_id) AS cnt
    FROM logins
   WHERE DATE_TRUNC('month',day)::DATE = '2021-09-01' OR
         DATE_TRUNC('month',day)::DATE = '2021-10-01'
)
SELECT *
  FROM log_sep
UNION ALL
SELECT *
  FROM log_oct
UNION ALL
SELECT *
  FROM log_sep_oct;
```

```console
period            | cnt
------------------+-----     returning  churned  retained
SEPTEMBER         |  54 <--               21    +   33
OCTOBER           |  62 <--     29              +   33
SEPTEMBER-OCTOBER |  83 <--     29     +  21    +   33
(3 rows)
```

Let's include the additional columns.

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
),
retained AS (
  SELECT  TO_CHAR(current_ymth,'YYYY') AS year
        , REPLACE (TO_CHAR(previous_ymth,'MONTH') || '-' ||
                   TO_CHAR(current_ymth,'MONTH')
                   ,' ','')
          AS period
        , retained_users AS cnt_retained_users
    FROM r_users
   ORDER BY current_ymth
)
SELECT  CASE WHEN (rc.year IS NULL AND rc.period IS NULL)
             THEN  rd.year
             ELSE  rc.year
        END AS year
      , CASE WHEN (rc.period IS NULL AND rc.year IS NULL)
             THEN  rd.period
             ELSE  rc.period
        END AS period
      , cnt_returning_users AS returning
      , cnt_churned_users AS churned
      , cnt_retained_users AS retained
      , cnt_retained_users + cnt_churned_users + cnt_retained_users AS logged
  FROM returned_churned AS rc
  FULL OUTER JOIN retained AS rd
    ON (rc.year = rd.year AND rc.period = rd.period);
```

```console
year |      period       | returning | churned | retained | logged
-----+-------------------+-----------+---------+----------+--------
2021 | SEPTEMBER-OCTOBER |        29 |      21 |       33 |     87
2021 | OCTOBER-NOVEMBER  |        25 |      30 |       32 |     94
2021 | NOVEMBER-DECEMBER |        24 |      21 |       36 |     93
2022 | DECEMBER-JANUARY  |        20 |      22 |       38 |     98
2022 | JANUARY-FEBRUARY  |        25 |      29 |       29 |     87
2022 | FEBRUARY-MARCH    |        28 |      19 |       35 |     89
2022 | MARCH-APRIL       |        15 |      26 |       37 |    100
2022 | APRIL-MAY         |        22 |      24 |       28 |     80
2022 | MAY-JUNE          |        26 |      26 |       24 |     74
2022 | JUNE-JULY         |        32 |      18 |       32 |     82
2022 | JULY-AUGUST       |        25 |      29 |       35 |     99
(11 rows)
```

The last step is to include the users who did not logged in the time window.

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
),
retained AS (
  SELECT  TO_CHAR(current_ymth,'YYYY') AS year
        , REPLACE (TO_CHAR(previous_ymth,'MONTH') || '-' ||
                   TO_CHAR(current_ymth,'MONTH')
                   ,' ','')
          AS period
        , retained_users AS cnt_retained_users
    FROM r_users
   ORDER BY current_ymth
),
report AS (
  SELECT  CASE WHEN (rc.year IS NULL AND rc.period IS NULL)
               THEN  rd.year
               ELSE  rc.year
          END AS year
        , CASE WHEN (rc.period IS NULL AND rc.year IS NULL)
               THEN  rd.period
               ELSE  rc.period
          END AS period
        , cnt_returning_users AS returning_u
        , cnt_churned_users AS churned
        , cnt_retained_users AS retained
        , cnt_retained_users + cnt_churned_users + cnt_retained_users AS logged
        , (SELECT COUNT(DISTINCT user_id) FROM logins) AS tot_cnt
    FROM returned_churned AS rc
    FULL OUTER JOIN retained AS rd
      ON (rc.year = rd.year AND rc.period = rd.period)
)
SELECT  year
      , period
      , returning_u
      , churned
      , retained
      , tot_cnt - logged AS not_logged
      , logged
      , tot_cnt
  FROM report;
```
