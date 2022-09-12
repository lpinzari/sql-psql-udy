# Reactivated Churned users cohort study

**Reactivated Users** are users who `previously churned`, but have now come back. Perhaps they had a renewed need for the product, or perhaps your compelling email retention campaign swayed them.

In other words, reactivated users are customers who have been  `churned` users in the past and were not active the month before the current month.

Hence, we’re going to include all `active users` each month for whom:

1. **This is not their first month** (because then they'd be new).
2. **They were not active the previous month** (because then they’d be `retained`).

For example, let's look at the login history of user_id `19` starting from the first month date activity and ending in the period of `November 2021`.

```SQL
SELECT DATE_TRUNC('day',day)::DATE AS day
  FROM logins
 WHERE user_id = '19' AND DATE_TRUNC('month',day)::DATE < '2021-12-01'
 ORDER BY day;
```

```console
day
------------
2021-09-16 |           |
2021-09-30 | September | active     |
             October   | not active | churned user
2021-11-13   November  | active
```

The login history of user_id `19` shows that during the period of `November 2021` the first login occurred at `2021-11-13`. He was not active during the period of `October` and active before `October`. Thus, user `19` is a churned user of the period `September-October` that came back in `November`.

A reactivated user might be a `churned` user who has been not active for more than a single month. For example, let's look at the login history of user_id `12`.

```SQL
SELECT DATE_TRUNC('day',day)::DATE AS day
  FROM logins
 WHERE user_id = '12' AND DATE_TRUNC('month',day)::DATE <= '2021-12-01'
 ORDER BY day;
```

```console
day
------------
2021-09-15  | September | active     | Churned user
            | October   | not active |
            | November  | not active
2021-12-05  | December  | active
```

The login history of user_id `12` shows that the first log occured during the period of `September` and was not active during the period of `October` and `November` but came back in `December`. It follows that user_id `12` is a `reactivated` user of the period `DECEMBER 2021`.

To sum it up, we want to get users who:

- were active this month,
- were not active the month before, and
- are not new: `the first user's activity started in a time window behind the month before`.

## Problem

1. Count the number of `churned users` who were not active the month before the current month.

We want to return the following table:

```console
year |   month   | reactivated_users_cnt
-----+-----------+-----------------------
2021 | NOVEMBER  |                    14
2021 | DECEMBER  |                    21
2022 | JANUARY   |                    19
2022 | FEBRUARY  |                    23
2022 | MARCH     |                    28
2022 | APRIL     |                    15
2022 | MAY       |                    22
2022 | JUNE      |                    26
2022 | JULY      |                    32
2022 | AUGUST    |                    25
(10 rows)
```


2. Create a table of `churned users` who have been active in the past. If a reactivated user is active this month but then not active in the last month, then that user gets an entry for this month. We want to generate a table with the following columns:

We want to compute the following metrics for the current month:

2. **number of months a user had no activity in the past** and **number of months a user had activity in the past**.


For example, user_id `12` should return the following output table:

```console
user_id | year |   month   | past_active_cnt | past_not_active_cnt
--------+------+-----------+-----------------+---------------------
     12 | 2021 | SEPTEMBER |               0 |                   0
     12 | 2021 | OCTOBER   |               1 |                   0
     12 | 2021 | NOVEMBER  |               1 |                   1
     12 | 2021 | DECEMBER  |               1 |                   2
     12 | 2022 | JANUARY   |               2 |                   2
     12 | 2022 | FEBRUARY  |               3 |                   2
     12 | 2022 | MARCH     |               4 |                   2
     12 | 2022 | APRIL     |               5 |                   2
     12 | 2022 | MAY       |               6 |                   2
     12 | 2022 | JUNE      |               6 |                   3
     12 | 2022 | JULY      |               7 |                   3
     12 | 2022 | AUGUST    |               8 |                   3
(12 rows)
```

Explanation:

If we look at the monthly login history of user `12`:

```console
month ACTIVE      active  not_active
------------           |   |   # rpreceding ows
2021-09-01  SEPTEMBER  0   0   0
            OCTOBER    1 + 0   0
            NOVEMBER   1 + 1   2    (NOT ACTIVE OCTOBER)
2021-12-01  DECEMBER   1 + 2   3      (NOT ACTIVE OCTOBER + NOVEMBER)
2022-01-01  JANUARY    2 + 2   4
2022-02-01  FEBRUARY   3 + 2   5
2022-03-01  MARCH      4 + 2   6
2022-04-01  APRIL      5 + 2   7
            MAY        6 + 2   8
2022-06-01  JUNE       6 + 3   9       (NOT ACTIVE OCTOBER + NOV + MAY)
2022-07-01  JULY       7 + 3  10
2022-08-01  AUGUST     8 + 3  11

```

He did not have activity in `October`, `November` and `December`. Therefore, in the months before the current month `DECEMBER`, the number of not active months is `2` and the number of active months is `1`, (September).


3. **number of days a user had no activity in the previous months** and **number of days a user had activity in the previous months**.

This question is similar to the previous problem but the sql query is slightly different.

For example, user_id `19` should return the following table.

```console
user_id | year |   month   | prec_active_cnt | prec_not_active_cnt
--------+------+-----------+-----------------+---------------------
     19 | 2021 | SEPTEMBER |               0 |                   0
     19 | 2021 | OCTOBER   |               2 |                  13
     19 | 2021 | NOVEMBER  |               2 |                  44
     19 | 2021 | DECEMBER  |               3 |                  73
     19 | 2022 | JANUARY   |               4 |                 103
     19 | 2022 | FEBRUARY  |               4 |                 134
     19 | 2022 | MARCH     |               4 |                 162
     19 | 2022 | APRIL     |               4 |                 193
     19 | 2022 | MAY       |               6 |                 221
     19 | 2022 | JUNE      |               6 |                 252
     19 | 2022 | JULY      |               6 |                 282
     19 | 2022 | AUGUST    |               6 |                 313
(12 rows)
```

The following table shows the number of active and not_active days in each month.

```console
user_id |   month    | active_cnt | not_active_cnt
--------+------------+------------+----------------
     19 | 2021-09-01 |          2 |             13
     19 | 2021-10-01 |          0 |             31
     19 | 2021-11-01 |          1 |             29
     19 | 2021-12-01 |          1 |             30
     19 | 2022-01-01 |          0 |             31
     19 | 2022-02-01 |          0 |             28
     19 | 2022-03-01 |          0 |             31
     19 | 2022-04-01 |          2 |             28
     19 | 2022-05-01 |          0 |             31
     19 | 2022-06-01 |          0 |             30
     19 | 2022-07-01 |          0 |             31
     19 | 2022-08-01 |          1 |             13
(12 rows)
```

Explanation:

if we look at the login history of user_id `19`:

```console
                                PRECEDING MM
user_id |   month               active not_active
---------+------------               |      |
     19 | 2021-09-16  | SEPTEMBER    0      0
     19 | 2021-09-30  |
                      | OCTOBER      2      13 = 0  + 30 - 16 - 2
     19 | 2021-11-13  | NOVEMBER     2      44 = 13 + (31 - 0)
     19 | 2021-12-07  | DECEMBER     3      73 = 44 + (30 - 1)
                      | JANUARY      4     103 = 73 + (31 - 1)
                      | FEBRUARY     4     134 = 103 + (31 - 0)
                      | MARCH        4     162 = 134 + (28 - 0)
     19 | 2022-04-09  | APRIL        4     193 = 162 + (31 - 0)
     19 | 2022-04-19  | APRIL        
                      | MAY          6     221 = 193 + (30 - 2)
                      | JUNE         6     252 = 221 + (31 - 0)
                      | JULY         6     282 = 252 + (30 - 0)
     19 | 2022-08-14  | AUGUST       6     313 = 282 + (31 - 0)
(7 rows)
```


## Solution

1. **Count the number of churned users who were not active the month before and are active the current month.**

```SQL
WITH first_activity AS (
  SELECT  user_id
        , DATE_TRUNC('month',MIN(day))::DATE AS month
    FROM logins
   GROUP BY 1
),
active_not_log_last_mth AS (
  SELECT  DISTINCT DATE_TRUNC('month',u1.day)::DATE AS y_month
        , u1.user_id AS user_id
    FROM logins u1
    LEFT JOIN logins u2
      ON (u1.user_id = u2.user_id AND
          DATE_TRUNC('month',u2.day) = DATE_TRUNC('month',u1.day) - INTERVAL '1 month')
   WHERE (u2.user_id IS NULL AND DATE_TRUNC('month',u2.day)::DATE IS NULL)
),
reactivated_users AS (
  SELECT  cr_a.y_month AS y_month
        , COUNT(cr_a.user_id) AS reactivated_users_cnt
    FROM first_activity f_a
   INNER JOIN active_not_log_last_mth cr_a
      ON f_a.user_id = cr_a.user_id AND f_a.month != cr_a.y_month
   GROUP BY 1
)
SELECT  TO_CHAR(y_month,'YYYY') AS year
      , TO_CHAR(y_month,'MONTH') AS month
      , reactivated_users_cnt
  FROM reactivated_users
 ORDER BY y_month;
```

2. **number of months a user had no activity in the past** and **number of months a user had activity in the past**.

```SQL
WITH RECURSIVE temp (user_id, curr_mth, end_mth) AS (
  SELECT  r.user_id
        , r.start_mth AS curr_mth
        , r.end_mth  AS end_mth
    FROM  (SELECT  user_id
                 , DATE_TRUNC('month',MIN(day))::DATE AS start_mth
                 , DATE_TRUNC('month',MAX(day))::DATE As end_mth
             FROM logins
            GROUP BY 1) r
  UNION ALL
  SELECT  user_id
        , (curr_mth + INTERVAL '1 month')::DATE
        , end_mth
    FROM temp
   WHERE curr_mth < end_mth
),
log_history AS (
  SELECT DISTINCT user_id
         , DATE_TRUNC('month',day)::DATE AS month
    FROM logins
),
not_active_mm AS (
  SELECT  t.user_id
        , t.curr_mth AS month
        , lh.month AS log_month
        , CASE WHEN lh.month IS NULL
               THEN 1
               ELSE 0
          END AS not_active
    FROM temp t
    FULL OUTER JOIN log_history lh
      ON (t.user_id = lh.user_id AND t.curr_mth = lh.month)
),
not_active_sum AS (
  SELECT  user_id
        , month
        , COUNT(log_month) OVER(PARTITION BY user_id
                                   ORDER BY month
                                ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING )
          AS past_active_cnt
        , COALESCE(SUM(not_active) OVER(PARTITION BY user_id
                                   ORDER BY month
                               ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING),0)
          AS past_not_active_cnt
    FROM not_active_mm
)
SELECT  user_id
      , TO_CHAR(month,'YYYY') AS year
      , TO_CHAR(month,'MONTH') AS month
      , past_active_cnt
      , past_not_active_cnt
  FROM not_active_sum
 ORDER BY 1,2;
```

3. **number of days a user had no activity in the previous months** and **number of days a user had activity in the previous months**.

```SQL
WITH RECURSIVE temp (user_id, curr_mth_day, last_mth_day) AS (
  SELECT  r.user_id
        , r.start_mth AS curr_mth_day
        , r.end_mth  AS last_mth_day
    FROM  (SELECT  user_id
                 , DATE_TRUNC('day',MIN(day))::DATE AS start_mth
                 , DATE_TRUNC('day',MAX(day))::DATE AS end_mth
             FROM logins
            GROUP BY 1) r
  UNION ALL
  SELECT  user_id
        , (curr_mth_day + INTERVAL '1 day')::DATE
        , last_mth_day
    FROM temp
   WHERE curr_mth_day < last_mth_day
),
log_history AS (
  SELECT DISTINCT user_id
         , DATE_TRUNC('day',day)::DATE AS month_day
    FROM logins
),
not_active_mm AS (
  SELECT  t.user_id
        , DATE_TRUNC('month',t.curr_mth_day)::DATE AS month
        , t.curr_mth_day AS month_day
        , lh.month_day AS log_month_day
        , CASE WHEN lh.month_day IS NULL
               THEN 1
               ELSE 0
          END AS not_active
    FROM temp t
    FULL OUTER JOIN log_history lh
      ON (t.user_id = lh.user_id AND t.curr_mth_day = lh.month_day)
),
active_not_active_dy AS (
  SELECT  user_id
        , month
        , COUNT(log_month_day) OVER(PARTITION BY user_id, month
                                   ORDER BY month)
          AS active_cnt
        , COALESCE(SUM(not_active) OVER(PARTITION BY user_id, month
                                   ORDER BY month),0)
          AS not_active_cnt
    FROM not_active_mm

),
active_not_active_mm AS (
  SELECT  user_id
        , month
        , MAX(active_cnt) AS active_cnt
        , MAX(not_active_cnt) AS not_active_cnt
    FROM active_not_active_dy
   WHERE user_id = 19
   GROUP BY 1,2
),
prec_active_not_active_mm AS (
  SELECT  user_id
        , month AS month_mm
        , COALESCE(SUM(active_cnt) OVER (PARTITION BY user_id
                                    ORDER BY month
                                ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING),0)
          AS prec_active_cnt
        , COALESCE(SUM(not_active_cnt) OVER (PARTITION BY user_id
                                        ORDER BY month
                                    ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING),0)
          AS prec_not_active_cnt
    FROM active_not_active_mm
)
SELECT  user_id
      , TO_CHAR(month_mm,'YYYY') AS year
      , TO_CHAR(month_mm,'MONTH') AS month
      , prec_active_cnt
      , prec_not_active_cnt
  FROM prec_active_not_active_mm
 ORDER BY user_id, month_mm;
```

## Discussion

We introduce a new table, containing `users’ first active month`. Here it is:

```SQL
WITH first_activity AS (
  SELECT  user_id
        , DATE_TRUNC('month',MIN(day))::DATE AS month
    FROM logins
   GROUP BY 1
)
SELECT *
  FROM first_activity
 ORDER BY 1;
```

```console
user_id |   month
--------+------------
      1 | 2021-12-01
      2 | 2021-11-01
      3 | 2021-09-01
      4 | 2021-09-01
      5 | 2021-09-01
    ... | ...
     12 | 2021-09-01  <--
    ... | ...
     19 | 2021-09-01  <--
    ... | ...
```

We see that the base line of each user is different. The login history of each user starts somewhere in the past. The latest and earliest user activity is shown below:

```SQL
WITH first_activity AS (
  SELECT  user_id
        , DATE_TRUNC('day',MIN(day))::DATE AS day1st
    FROM logins
   GROUP BY 1
)
SELECT  MIN(day1st) AS min_date
      , MAX(day1st) AS max_date
  FROM first_activity
 ORDER BY 1;
```

```console
min_date   |  max_date
-----------+------------
2021-09-01 | 2022-02-27
```

The active user's activity starts in `2021-09-01` and the latest `new users` registered during the period of `February 2022`.

```SQL
SELECT TO_CHAR(DATE_TRUNC('month',day)::DATE,'YYYY-MM') AS mth,
       COUNT(DISTINCT user_id) AS mau
  FROM logins
 GROUP BY mth
 ORDER BY mth;
```

Listing the monthly active users' table:

```console
mth     | mau
--------+-----
2021-09 |  54
2021-10 |  62
2021-11 |  57
2021-12 |  60
2022-01 |  58
2022-02 |  54
2022-03 |  63
2022-04 |  52
2022-05 |  50
2022-06 |  50
2022-07 |  64
2022-08 |  60
(12 rows)
```

We see that the login table includes 12 months starting in `SEPTEMBER 2021`.


```console
mth      | mau     Reactivated users
---------+-----    +------------+
 2021-09 |  54     | active     |       SEPTEMBER - NOVEMBER                 
                   +            + ----> Churned user      
 2021-10 |  62     | not active |
+------------+     + -----------+   
|2021-11 |  57|<---| active     |
+------------+     +------------+
 2021-12 |  60       
 2022-01 |  58
 2022-02 |  54
 2022-03 |  63
 2022-04 |  52
 2022-05 |  50
 2022-06 |  50
 2022-07 |  64
 2022-08 |  60
(12 rows)
```
For example, the defintion of `reactivated user` in the period of `November 2021` is simple: a churned user who has been not active in the period of `October 2021` but has been active before.

Next, find the users who did not login the month before.

```SQL
WITH active_not_log_last_mth AS (
  SELECT  DATE_TRUNC('month',u1.day)::DATE AS y_month
        , u1.user_id AS user_id
    FROM logins u1
    LEFT JOIN logins u2
      ON (u1.user_id = u2.user_id AND
          DATE_TRUNC('month',u2.day) = DATE_TRUNC('month',u1.day) - INTERVAL '1 month')
   WHERE (u2.user_id IS NULL AND DATE_TRUNC('month',u2.day)::DATE IS NULL)
)

SELECT user_id
     , y_month As month
  FROM active_not_log_last_mth
 ORDER BY 1,2;   
```

```console
user_id |   month
--------+------------
      1 | 2021-12-01 <--
      1 | 2021-12-01 <--
      1 | 2021-12-01 <--
      1 | 2022-03-01
      1 | 2022-07-01
      2 | 2021-11-01
      2 | 2022-01-01 <--
      2 | 2022-01-01 <--
      2 | 2022-03-01
    ... | ...
     12 | 2021-09-01 <---
     12 | 2021-12-01
     12 | 2022-06-01 <--
     12 | 2022-06-01 <--
    ... | ...
     19 | 2021-09-01 <---
     19 | 2021-09-01 <--- Duplicates
     19 | 2021-11-01
     19 | 2022-04-01 <--
     19 | 2022-04-01 <--
     19 | 2022-08-01 <--
    ... | ...
```

We need to remove duplicate, because a user can obviously log more than a single time in a month.


```SQL
WITH active_not_log_last_mth AS (
  SELECT DISTINCT DATE_TRUNC('month',u1.day)::DATE AS y_month
        , u1.user_id AS user_id
    FROM logins u1
    LEFT JOIN logins u2
      ON (u1.user_id = u2.user_id AND
          DATE_TRUNC('month',u2.day) = DATE_TRUNC('month',u1.day) - INTERVAL '1 month')
   WHERE (u2.user_id IS NULL AND DATE_TRUNC('month',u2.day)::DATE IS NULL)
)

SELECT user_id
     , y_month As month
  FROM active_not_log_last_mth
 ORDER BY 1,2;   
```

```console
user_id |   month
--------+------------
      1 | 2021-12-01
      1 | 2022-03-01
      1 | 2022-07-01
      2 | 2021-11-01
      2 | 2022-01-01
      2 | 2022-03-01
      2 | 2022-08-01
    ... | ...
     12 | 2021-09-01
     12 | 2021-12-01
     12 | 2022-06-01
    ... | ...
     19 | 2021-09-01
     19 | 2021-11-01
     19 | 2022-04-01
     19 | 2022-08-01  
```

Lastly, join the `first_activity` and `active_not_log_last_mth` tables and select only users in the `first_activity` table that are not new users who joined the current month. The condition that exclude new users is a not equal comparison between the dates of both tables.

Let's test the condition for users `12` and `19` first.

```SQL
WITH first_activity AS (
  SELECT  user_id
        , DATE_TRUNC('month',MIN(day))::DATE AS month
    FROM logins
   GROUP BY 1
),
active_not_log_last_mth AS (
  SELECT  DISTINCT DATE_TRUNC('month',u1.day)::DATE AS y_month
        , u1.user_id AS user_id
    FROM logins u1
    LEFT JOIN logins u2
      ON (u1.user_id = u2.user_id AND
          DATE_TRUNC('month',u2.day) = DATE_TRUNC('month',u1.day) - INTERVAL '1 month')
   WHERE (u2.user_id IS NULL AND DATE_TRUNC('month',u2.day)::DATE IS NULL)
)
SELECT y_month AS month
      , cr_a.user_id AS user_id
  FROM first_activity f_a
 INNER JOIN active_not_log_last_mth cr_a
    ON f_a.user_id = cr_a.user_id AND f_a.month != cr_a.y_month
 ORDER BY 2, 1;  
```

```console
month      | user_id
-----------+---------
2021-12-01 |      12  DECEMBER  2021
2022-06-01 |      12  JUNE       2022
---------------------
2021-11-01 |      19  NOVEMBER 2021
2022-04-01 |      19  APRIL    2022
2022-08-01 |      19  AUGUST   2022
```

We can double check this result by looking at the monthly history login of user `12` or `19`. Let's check the time series of user `12`.

```SQL
SELECT DISTINCT DATE_TRUNC('month',day)::DATE AS month
  FROM logins
 WHERE user_id = '12'
 ORDER BY month;
```

```console
month
------------
2021-09-01  SEPTEMBER
            OCTOBER
            NOVEMBER
2021-12-01  DECEMBER <--
2022-01-01  JANUARY
2022-02-01  FEBRUARY
2022-03-01  MARCH
2022-04-01  APRIL
            MAY
2022-06-01  JUNE     <--
2022-07-01  JULY
2022-08-01  AUGUST
(9 rows)
```

Similarly, the history of user `19`:

```SQL
SELECT DISTINCT DATE_TRUNC('month',day)::DATE AS month
  FROM logins
 WHERE user_id = '19'
 ORDER BY month;
```

```console
month
------------
2021-09-01  SEPTEMBER
            OCTOBER
2021-11-01  NOVEMBER <--
2021-12-01  DECEMBER
            JANUARY
            FEBRUARY
            MARCH
2022-04-01  APRIL <--
            MAY
            JUNE
            JULY
2022-08-01  AUGUST <--
```

Confirms the results. Finally, we can count the number of `returned users`.

```SQL
WITH first_activity AS (
  SELECT  user_id
        , DATE_TRUNC('month',MIN(day))::DATE AS month
    FROM logins
   GROUP BY 1
),
active_not_log_last_mth AS (
  SELECT  DISTINCT DATE_TRUNC('month',u1.day)::DATE AS y_month
        , u1.user_id AS user_id
    FROM logins u1
    LEFT JOIN logins u2
      ON (u1.user_id = u2.user_id AND
          DATE_TRUNC('month',u2.day) = DATE_TRUNC('month',u1.day) - INTERVAL '1 month')
   WHERE (u2.user_id IS NULL AND DATE_TRUNC('month',u2.day)::DATE IS NULL)
),
reactivated_users AS (
  SELECT  cr_a.y_month AS y_month
        , COUNT(cr_a.user_id) AS reactivated_users_cnt
    FROM first_activity f_a
   INNER JOIN active_not_log_last_mth cr_a
      ON f_a.user_id = cr_a.user_id AND f_a.month != cr_a.y_month
   GROUP BY 1
)
SELECT  TO_CHAR(y_month,'YYYY') AS year
      , TO_CHAR(y_month,'MONTH') AS month
      , reactivated_users_cnt
  FROM reactivated_users
 ORDER BY y_month;
```

```console
year |   month   | reactivated_users_cnt
-----+-----------+-----------------------
2021 | NOVEMBER  |                    14
2021 | DECEMBER  |                    21
2022 | JANUARY   |                    19
2022 | FEBRUARY  |                    23
2022 | MARCH     |                    28
2022 | APRIL     |                    15
2022 | MAY       |                    22
2022 | JUNE      |                    26
2022 | JULY      |                    32
2022 | AUGUST    |                    25
(10 rows)
```


### Problem 2


Let's count the number of not active months in the past.

Generate a table with consecutive monthly dates starting from the first activity date of each user.

The first step is to generate for each user the first day of each month from the first month activity to the last month activity. Start using the DATE_TRUNC function on the MIN and MAX days to find the boundary months:

```SQL
WITH range AS (
  SELECT  user_id
        , DATE_TRUNC('month',MIN(day)) AS start_mth
        , DATE_TRUNC('month',MAX(day)) As end_mth
    FROM logins
   GROUP BY 1
)
```  

Your next step is to repeatedly add months to `START_MTH` to return all the months necessary for the final result set.

```SQL
WITH RECURSIVE temp (user_id, curr_mth, end_mth) AS (
  SELECT  r.user_id
        , r.start_mth AS curr_mth
        , r.end_mth  AS end_mth
    FROM  (SELECT  user_id
                 , DATE_TRUNC('month',MIN(day))::DATE AS start_mth
                 , DATE_TRUNC('month',MAX(day))::DATE As end_mth
             FROM logins
            GROUP BY 1) r
  UNION ALL
  SELECT  user_id
        , (curr_mth + INTERVAL '1 month')::DATE
        , end_mth
    FROM temp
   WHERE curr_mth < end_mth
)
SELECT *
  FROM temp
 WHERE user_id = '19';
```

```console
user_id |  curr_mth  |  end_mth
--------+------------+------------
     19 | 2021-09-01 | 2022-08-01
     19 | 2021-10-01 | 2022-08-01
     19 | 2021-11-01 | 2022-08-01
     19 | 2021-12-01 | 2022-08-01
     19 | 2022-01-01 | 2022-08-01
     19 | 2022-02-01 | 2022-08-01
     19 | 2022-03-01 | 2022-08-01
     19 | 2022-04-01 | 2022-08-01
     19 | 2022-05-01 | 2022-08-01
     19 | 2022-06-01 | 2022-08-01
     19 | 2022-07-01 | 2022-08-01
     19 | 2022-08-01 | 2022-08-01
(12 rows)
```

Next, we generate the month history login for each user in the logins table.

```SQL
SELECT DISTINCT user_id
       , DATE_TRUNC('month',day)::DATE AS month
  FROM logins
 WHERE user_id IN ('12','19')
 ORDER BY 1,2;
```

```console
user_id |   month
--------+------------
     12 | 2021-09-01
     12 | 2021-12-01
     12 | 2022-01-01
     12 | 2022-02-01
     12 | 2022-03-01
     12 | 2022-04-01
     12 | 2022-06-01
     12 | 2022-07-01
     12 | 2022-08-01
     ---------------
     19 | 2021-09-01
     19 | 2021-11-01
     19 | 2021-12-01
     19 | 2022-04-01
     19 | 2022-08-01
(14 rows)
```

Then we join the tables generated in the previous steps.

```SQL
WITH RECURSIVE temp (user_id, curr_mth, end_mth) AS (
  SELECT  r.user_id
        , r.start_mth AS curr_mth
        , r.end_mth  AS end_mth
    FROM  (SELECT  user_id
                 , DATE_TRUNC('month',MIN(day))::DATE AS start_mth
                 , DATE_TRUNC('month',MAX(day))::DATE As end_mth
             FROM logins
            GROUP BY 1) r
  UNION ALL
  SELECT  user_id
        , (curr_mth + INTERVAL '1 month')::DATE
        , end_mth
    FROM temp
   WHERE curr_mth < end_mth
),
log_history AS (
  SELECT DISTINCT user_id
         , DATE_TRUNC('month',day)::DATE AS month
    FROM logins
)

SELECT  t.user_id
      , t.curr_mth AS month
      , lh.month AS log_month
  FROM temp t
  FULL OUTER JOIN log_history lh
    ON (t.user_id = lh.user_id AND t.curr_mth = lh.month)
 WHERE t.user_id IN ('12','19')
 ORDER BY 1,2;
```

```console
user_id |   month    | log_month
---------+------------+------------
     12 | 2021-09-01 | 2021-09-01
     12 | 2021-10-01 |
     12 | 2021-11-01 |
     12 | 2021-12-01 | 2021-12-01
     12 | 2022-01-01 | 2022-01-01
     12 | 2022-02-01 | 2022-02-01
     12 | 2022-03-01 | 2022-03-01
     12 | 2022-04-01 | 2022-04-01
     12 | 2022-05-01 |
     12 | 2022-06-01 | 2022-06-01
     12 | 2022-07-01 | 2022-07-01
     12 | 2022-08-01 | 2022-08-01
     19 | 2021-09-01 | 2021-09-01
     19 | 2021-10-01 |
     19 | 2021-11-01 | 2021-11-01
     19 | 2021-12-01 | 2021-12-01
     19 | 2022-01-01 |
     19 | 2022-02-01 |
     19 | 2022-03-01 |
     19 | 2022-04-01 | 2022-04-01
     19 | 2022-05-01 |
     19 | 2022-06-01 |
     19 | 2022-07-01 |
     19 | 2022-08-01 | 2022-08-01
(24 rows)
```

Next, we create a flag column to indicate if a month is not active.

```SQL
WITH RECURSIVE temp (user_id, curr_mth, end_mth) AS (
  SELECT  r.user_id
        , r.start_mth AS curr_mth
        , r.end_mth  AS end_mth
    FROM  (SELECT  user_id
                 , DATE_TRUNC('month',MIN(day))::DATE AS start_mth
                 , DATE_TRUNC('month',MAX(day))::DATE As end_mth
             FROM logins
            GROUP BY 1) r
  UNION ALL
  SELECT  user_id
        , (curr_mth + INTERVAL '1 month')::DATE
        , end_mth
    FROM temp
   WHERE curr_mth < end_mth
),
log_history AS (
  SELECT DISTINCT user_id
         , DATE_TRUNC('month',day)::DATE AS month
    FROM logins
)

SELECT  t.user_id
      , t.curr_mth AS month
      , lh.month AS log_month
      , CASE WHEN lh.month IS NULL
             THEN 1
             ELSE 0
        END AS not_active
  FROM temp t
  FULL OUTER JOIN log_history lh
    ON (t.user_id = lh.user_id AND t.curr_mth = lh.month)
 WHERE t.user_id IN ('12','19')
 ORDER BY 1,2;
```

```console
user_id |   month    | log_month  | not_active
---------+------------+------------+------------
     12 | 2021-09-01 | 2021-09-01 |          0
     12 | 2021-10-01 |            |          1
     12 | 2021-11-01 |            |          1
     12 | 2021-12-01 | 2021-12-01 |          0
     12 | 2022-01-01 | 2022-01-01 |          0
     12 | 2022-02-01 | 2022-02-01 |          0
     12 | 2022-03-01 | 2022-03-01 |          0
     12 | 2022-04-01 | 2022-04-01 |          0
     12 | 2022-05-01 |            |          1
     12 | 2022-06-01 | 2022-06-01 |          0
     12 | 2022-07-01 | 2022-07-01 |          0
     12 | 2022-08-01 | 2022-08-01 |          0
     19 | 2021-09-01 | 2021-09-01 |          0
     19 | 2021-10-01 |            |          1
     19 | 2021-11-01 | 2021-11-01 |          0
     19 | 2021-12-01 | 2021-12-01 |          0
     19 | 2022-01-01 |            |          1
     19 | 2022-02-01 |            |          1
     19 | 2022-03-01 |            |          1
     19 | 2022-04-01 | 2022-04-01 |          0
     19 | 2022-05-01 |            |          1
     19 | 2022-06-01 |            |          1
     19 | 2022-07-01 |            |          1
     19 | 2022-08-01 | 2022-08-01 |          0
```

The next step is to calculate a running sum.

```SQL
WITH RECURSIVE temp (user_id, curr_mth, end_mth) AS (
  SELECT  r.user_id
        , r.start_mth AS curr_mth
        , r.end_mth  AS end_mth
    FROM  (SELECT  user_id
                 , DATE_TRUNC('month',MIN(day))::DATE AS start_mth
                 , DATE_TRUNC('month',MAX(day))::DATE As end_mth
             FROM logins
            GROUP BY 1) r
  UNION ALL
  SELECT  user_id
        , (curr_mth + INTERVAL '1 month')::DATE
        , end_mth
    FROM temp
   WHERE curr_mth < end_mth
),
log_history AS (
  SELECT DISTINCT user_id
         , DATE_TRUNC('month',day)::DATE AS month
    FROM logins
),
not_active_mm AS (
  SELECT  t.user_id
        , t.curr_mth AS month
        , CASE WHEN lh.month IS NULL
               THEN 1
               ELSE 0
          END AS not_active
    FROM temp t
    FULL OUTER JOIN log_history lh
      ON (t.user_id = lh.user_id AND t.curr_mth = lh.month)
)
SELECT  user_id
      , month
      , not_active
      , SUM(not_active) OVER(PARTITION BY user_id
                                 ORDER BY month) AS sum
  FROM not_active_mm
 WHERE user_id IN ('12','19')
 ORDER BY 1,2;
```

```console
user_id |   month    | not_active | sum
---------+------------+------------+-----
     12 | 2021-09-01 |          0 |   0
     12 | 2021-10-01 |          1 |   1
     12 | 2021-11-01 |          1 |   2
     12 | 2021-12-01 |          0 |   2
     12 | 2022-01-01 |          0 |   2
     12 | 2022-02-01 |          0 |   2
     12 | 2022-03-01 |          0 |   2
     12 | 2022-04-01 |          0 |   2
     12 | 2022-05-01 |          1 |   3
     12 | 2022-06-01 |          0 |   3
     12 | 2022-07-01 |          0 |   3
     12 | 2022-08-01 |          0 |   3
     19 | 2021-09-01 |          0 |   0
     19 | 2021-10-01 |          1 |   1
     19 | 2021-11-01 |          0 |   1
     19 | 2021-12-01 |          0 |   1
     19 | 2022-01-01 |          1 |   2
     19 | 2022-02-01 |          1 |   3
     19 | 2022-03-01 |          1 |   4
     19 | 2022-04-01 |          0 |   4
     19 | 2022-05-01 |          1 |   5
     19 | 2022-06-01 |          1 |   6
     19 | 2022-07-01 |          1 |   7
     19 | 2022-08-01 |          0 |   7
(24 rows)
```
We need to subtract the dates following the starting date.
Lastly, we format the date as requested:

```SQL
WITH RECURSIVE temp (user_id, curr_mth, end_mth) AS (
  SELECT  r.user_id
        , r.start_mth AS curr_mth
        , r.end_mth  AS end_mth
    FROM  (SELECT  user_id
                 , DATE_TRUNC('month',MIN(day))::DATE AS start_mth
                 , DATE_TRUNC('month',MAX(day))::DATE As end_mth
             FROM logins
            GROUP BY 1) r
  UNION ALL
  SELECT  user_id
        , (curr_mth + INTERVAL '1 month')::DATE
        , end_mth
    FROM temp
   WHERE curr_mth < end_mth
),
log_history AS (
  SELECT DISTINCT user_id
         , DATE_TRUNC('month',day)::DATE AS month
    FROM logins
),
not_active_mm AS (
  SELECT  t.user_id
        , t.curr_mth AS month
        , CASE WHEN lh.month IS NULL
               THEN 1
               ELSE 0
          END AS not_active
    FROM temp t
    FULL OUTER JOIN log_history lh
      ON (t.user_id = lh.user_id AND t.curr_mth = lh.month)
),
not_active_sum AS (
  SELECT  user_id
        , month
        , not_active
        , SUM(not_active) OVER(PARTITION BY user_id
                                   ORDER BY month) AS sum
    FROM not_active_mm
)
SELECT  user_id
      , TO_CHAR(month,'YYYY') AS year
      , TO_CHAR(month,'MONTH') AS month
      , sum - not_active AS past_not_active_cnt
  FROM not_active_sum
 WHERE user_id IN ('12','19')
 ORDER BY 1,2;
```

```console
user_id | year |   month   | past_not_active_cnt
---------+------+-----------+---------------------
     12 | 2021 | SEPTEMBER |                   0
     12 | 2021 | OCTOBER   |                   0
     12 | 2021 | NOVEMBER  |                   1
     12 | 2021 | DECEMBER  |                   2
     12 | 2022 | JANUARY   |                   2
     12 | 2022 | FEBRUARY  |                   2
     12 | 2022 | MARCH     |                   2
     12 | 2022 | APRIL     |                   2
     12 | 2022 | MAY       |                   2
     12 | 2022 | JUNE      |                   3
     12 | 2022 | JULY      |                   3
     12 | 2022 | AUGUST    |                   3
     19 | 2021 | SEPTEMBER |                   0
     19 | 2021 | OCTOBER   |                   0
     19 | 2021 | NOVEMBER  |                   1
     19 | 2021 | DECEMBER  |                   1
     19 | 2022 | JANUARY   |                   1
     19 | 2022 | FEBRUARY  |                   2
     19 | 2022 | MARCH     |                   3
     19 | 2022 | APRIL     |                   4
     19 | 2022 | MAY       |                   4
     19 | 2022 | JUNE      |                   5
     19 | 2022 | JULY      |                   6
     19 | 2022 | AUGUST    |                   7
(24 rows)
```

- **Solution with LAG option**:


Alternatively, it's possible to use directly the `LAG` option in the `SUM` window function to get the same result, as follow:

```SQL
WITH RECURSIVE temp (user_id, curr_mth, end_mth) AS (
  SELECT  r.user_id
        , r.start_mth AS curr_mth
        , r.end_mth  AS end_mth
    FROM  (SELECT  user_id
                 , DATE_TRUNC('month',MIN(day))::DATE AS start_mth
                 , DATE_TRUNC('month',MAX(day))::DATE As end_mth
             FROM logins
            GROUP BY 1) r
  UNION ALL
  SELECT  user_id
        , (curr_mth + INTERVAL '1 month')::DATE
        , end_mth
    FROM temp
   WHERE curr_mth < end_mth
),
log_history AS (
  SELECT DISTINCT user_id
         , DATE_TRUNC('month',day)::DATE AS month
    FROM logins
),
not_active_mm AS (
  SELECT  t.user_id
        , t.curr_mth AS month
        , CASE WHEN lh.month IS NULL
               THEN 1
               ELSE 0
          END AS not_active
    FROM temp t
    FULL OUTER JOIN log_history lh
      ON (t.user_id = lh.user_id AND t.curr_mth = lh.month)
),
not_active_sum AS (
  SELECT  user_id
        , month
        , not_active
        , SUM(not_active) OVER(PARTITION BY user_id
                                   ORDER BY month
                               ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) AS sum
    FROM not_active_mm
)
SELECT  user_id
      , TO_CHAR(month,'YYYY') AS year
      , TO_CHAR(month,'MONTH') AS month
      , sum  AS past_not_active_cnt
  FROM not_active_sum
 WHERE user_id IN ('12','19')
 ORDER BY 1,2;
```

```console
user_id | year |   month   | past_not_active_cnt
---------+------+-----------+---------------------
     12 | 2021 | SEPTEMBER |
     12 | 2021 | OCTOBER   |                   0
     12 | 2021 | NOVEMBER  |                   1
     12 | 2021 | DECEMBER  |                   2
     12 | 2022 | JANUARY   |                   2
     12 | 2022 | FEBRUARY  |                   2
     12 | 2022 | MARCH     |                   2
     12 | 2022 | APRIL     |                   2
     12 | 2022 | MAY       |                   2
     12 | 2022 | JUNE      |                   3
     12 | 2022 | JULY      |                   3
     12 | 2022 | AUGUST    |                   3
     19 | 2021 | SEPTEMBER |
     19 | 2021 | OCTOBER   |                   0
     19 | 2021 | NOVEMBER  |                   1
     19 | 2021 | DECEMBER  |                   1
     19 | 2022 | JANUARY   |                   1
     19 | 2022 | FEBRUARY  |                   2
     19 | 2022 | MARCH     |                   3
     19 | 2022 | APRIL     |                   4
     19 | 2022 | MAY       |                   4
     19 | 2022 | JUNE      |                   5
     19 | 2022 | JULY      |                   6
     19 | 2022 | AUGUST    |                   7
(24 rows)
```

```SQL
WITH RECURSIVE temp (user_id, curr_mth, end_mth) AS (
  SELECT  r.user_id
        , r.start_mth AS curr_mth
        , r.end_mth  AS end_mth
    FROM  (SELECT  user_id
                 , DATE_TRUNC('month',MIN(day))::DATE AS start_mth
                 , DATE_TRUNC('month',MAX(day))::DATE As end_mth
             FROM logins
            GROUP BY 1) r
  UNION ALL
  SELECT  user_id
        , (curr_mth + INTERVAL '1 month')::DATE
        , end_mth
    FROM temp
   WHERE curr_mth < end_mth
),
log_history AS (
  SELECT DISTINCT user_id
         , DATE_TRUNC('month',day)::DATE AS month
    FROM logins
),
not_active_mm AS (
  SELECT  t.user_id
        , t.curr_mth AS month
        , CASE WHEN lh.month IS NULL
               THEN 1
               ELSE 0
          END AS not_active
    FROM temp t
    FULL OUTER JOIN log_history lh
      ON (t.user_id = lh.user_id AND t.curr_mth = lh.month)
),
not_active_sum AS (
  SELECT  user_id
        , month
        , not_active
        , SUM(not_active) OVER(PARTITION BY user_id
                                   ORDER BY month
                               ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) AS sum
    FROM not_active_mm
)
SELECT  user_id
      , TO_CHAR(month,'YYYY') AS year
      , TO_CHAR(month,'MONTH') AS month
      , CASE WHEN sum IS NULL
             THEN 0
             ELSE sum  
        END AS past_not_active_cnt
  FROM not_active_sum
 WHERE user_id IN ('12','19')
 ORDER BY 1,2;
```


- **Include the number of months a user had no activity**.

```SQL
WITH RECURSIVE temp (user_id, curr_mth, end_mth) AS (
  SELECT  r.user_id
        , r.start_mth AS curr_mth
        , r.end_mth  AS end_mth
    FROM  (SELECT  user_id
                 , DATE_TRUNC('month',MIN(day))::DATE AS start_mth
                 , DATE_TRUNC('month',MAX(day))::DATE As end_mth
             FROM logins
            GROUP BY 1) r
  UNION ALL
  SELECT  user_id
        , (curr_mth + INTERVAL '1 month')::DATE
        , end_mth
    FROM temp
   WHERE curr_mth < end_mth
),
log_history AS (
  SELECT DISTINCT user_id
         , DATE_TRUNC('month',day)::DATE AS month
    FROM logins
),
not_active_mm AS (
  SELECT  t.user_id
        , t.curr_mth AS month
        , lh.month AS log_month
        , CASE WHEN lh.month IS NULL
               THEN 1
               ELSE 0
          END AS not_active
    FROM temp t
    FULL OUTER JOIN log_history lh
      ON (t.user_id = lh.user_id AND t.curr_mth = lh.month)
),
not_active_sum AS (
  SELECT  user_id
        , month
        , COUNT(log_month) OVER(PARTITION BY user_id
                                   ORDER BY month
                                ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING )
          AS past_active_cnt
        , SUM(not_active) OVER(PARTITION BY user_id
                                   ORDER BY month
                               ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING)
          AS past_not_active_cnt
    FROM not_active_mm
)
SELECT  user_id
      , TO_CHAR(month,'YYYY') AS year
      , TO_CHAR(month,'MONTH') AS month
      , past_active_cnt
      , CASE WHEN past_not_active_cnt IS NULL
             THEN 0
             ELSE past_not_active_cnt  
        END AS past_not_active_cnt
  FROM not_active_sum
 WHERE user_id IN ('12','19')
 ORDER BY 1,2;
```

```console
user_id | year |   month   | past_active_cnt | past_not_active_cnt
--------+------+-----------+-----------------+---------------------
     12 | 2021 | SEPTEMBER |               0 |                   0
     12 | 2021 | OCTOBER   |               1 |                   0
     12 | 2021 | NOVEMBER  |               1 |                   1
     12 | 2021 | DECEMBER  |               1 |                   2
     12 | 2022 | JANUARY   |               2 |                   2
     12 | 2022 | FEBRUARY  |               3 |                   2
     12 | 2022 | MARCH     |               4 |                   2
     12 | 2022 | APRIL     |               5 |                   2
     12 | 2022 | MAY       |               6 |                   2
     12 | 2022 | JUNE      |               6 |                   3
     12 | 2022 | JULY      |               7 |                   3
     12 | 2022 | AUGUST    |               8 |                   3
     19 | 2021 | SEPTEMBER |               0 |                   0
     19 | 2021 | OCTOBER   |               1 |                   0
     19 | 2021 | NOVEMBER  |               1 |                   1
     19 | 2021 | DECEMBER  |               2 |                   1
     19 | 2022 | JANUARY   |               3 |                   1
     19 | 2022 | FEBRUARY  |               3 |                   2
     19 | 2022 | MARCH     |               3 |                   3
     19 | 2022 | APRIL     |               3 |                   4
     19 | 2022 | MAY       |               4 |                   4
     19 | 2022 | JUNE      |               4 |                   5
     19 | 2022 | JULY      |               4 |                   6
     19 | 2022 | AUGUST    |               4 |                   7
(24 rows)
```

We can replace the `CASE` statement with a `COALESCE` statement.

```SQL
WITH RECURSIVE temp (user_id, curr_mth, end_mth) AS (
  SELECT  r.user_id
        , r.start_mth AS curr_mth
        , r.end_mth  AS end_mth
    FROM  (SELECT  user_id
                 , DATE_TRUNC('month',MIN(day))::DATE AS start_mth
                 , DATE_TRUNC('month',MAX(day))::DATE As end_mth
             FROM logins
            GROUP BY 1) r
  UNION ALL
  SELECT  user_id
        , (curr_mth + INTERVAL '1 month')::DATE
        , end_mth
    FROM temp
   WHERE curr_mth < end_mth
),
log_history AS (
  SELECT DISTINCT user_id
         , DATE_TRUNC('month',day)::DATE AS month
    FROM logins
),
not_active_mm AS (
  SELECT  t.user_id
        , t.curr_mth AS month
        , lh.month AS log_month
        , CASE WHEN lh.month IS NULL
               THEN 1
               ELSE 0
          END AS not_active
    FROM temp t
    FULL OUTER JOIN log_history lh
      ON (t.user_id = lh.user_id AND t.curr_mth = lh.month)
),
not_active_sum AS (
  SELECT  user_id
        , month
        , COUNT(log_month) OVER(PARTITION BY user_id
                                   ORDER BY month
                                ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING )
          AS past_active_cnt
        , COALESCE(SUM(not_active) OVER(PARTITION BY user_id
                                   ORDER BY month
                               ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING),0)
          AS past_not_active_cnt
    FROM not_active_mm
)
SELECT  user_id
      , TO_CHAR(month,'YYYY') AS year
      , TO_CHAR(month,'MONTH') AS month
      , past_active_cnt
      , past_not_active_cnt
  FROM not_active_sum
 WHERE user_id IN ('12','19')
 ORDER BY 1,2;
```

### Problem 3


3. **Number of active and not active days in the previous months**


The problem is somehow similar to problem 2. We could apply the technique used in problem 2 and change the `month` increment with the `day` increment.

```SQL
WITH RECURSIVE temp (user_id, curr_mth_day, last_mth_day) AS (
  SELECT  r.user_id
        , r.start_mth AS curr_mth_day
        , r.end_mth  AS last_mth_day
    FROM  (SELECT  user_id
                 , DATE_TRUNC('day',MIN(day))::DATE AS start_mth
                 , DATE_TRUNC('day',MAX(day))::DATE AS end_mth
             FROM logins
            GROUP BY 1) r
  UNION ALL
  SELECT  user_id
        , (curr_mth_day + INTERVAL '1 day')::DATE
        , last_mth_day
    FROM temp
   WHERE curr_mth_day < last_mth_day
)
SELECT *
  FROM temp
 WHERE user_id = '19' AND (curr_mth_day < '2021-10-01'::DATE  
                           OR curr_mth_day >= '2022-08-01'::DATE)
 ORDER BY curr_mth_day;
```

```console
user_id | curr_mth_day | last_mth_day
---------+--------------+--------------
     19 | 2021-09-16   | 2022-08-14
     19 | 2021-09-17   | 2022-08-14
     19 | 2021-09-18   | 2022-08-14
     19 | 2021-09-19   | 2022-08-14
     19 | 2021-09-20   | 2022-08-14
     19 | 2021-09-21   | 2022-08-14
     19 | 2021-09-22   | 2022-08-14
     19 | 2021-09-23   | 2022-08-14
     19 | 2021-09-24   | 2022-08-14
     19 | 2021-09-25   | 2022-08-14
     19 | 2021-09-26   | 2022-08-14
     19 | 2021-09-27   | 2022-08-14
     19 | 2021-09-28   | 2022-08-14
     19 | 2021-09-29   | 2022-08-14
     19 | 2021-09-30   | 2022-08-14
     19 | 2022-08-01   | 2022-08-14
     19 | 2022-08-02   | 2022-08-14
     19 | 2022-08-03   | 2022-08-14
     19 | 2022-08-04   | 2022-08-14
     19 | 2022-08-05   | 2022-08-14
     19 | 2022-08-06   | 2022-08-14
     19 | 2022-08-07   | 2022-08-14
     19 | 2022-08-08   | 2022-08-14
     19 | 2022-08-09   | 2022-08-14
     19 | 2022-08-10   | 2022-08-14
     19 | 2022-08-11   | 2022-08-14
     19 | 2022-08-12   | 2022-08-14
     19 | 2022-08-13   | 2022-08-14
     19 | 2022-08-14   | 2022-08-14
(29 rows)
```

Next, we generate the day history login for each user in the logins table.

```SQL
SELECT DISTINCT user_id
       , DATE_TRUNC('day',day)::DATE AS month_day
  FROM logins
 WHERE user_id = 19
 ORDER BY 1,2;
```

```console
user_id |   month_day
---------+------------
     19 | 2021-09-16
     19 | 2021-09-30
     19 | 2021-11-13
     19 | 2021-12-07
     19 | 2022-04-09
     19 | 2022-04-19
     19 | 2022-08-14
(7 rows)
```

Then we join the tables generated in the previous steps.

```SQL
WITH RECURSIVE temp (user_id, curr_mth_day, last_mth_day) AS (
  SELECT  r.user_id
        , r.start_mth AS curr_mth_day
        , r.end_mth  AS last_mth_day
    FROM  (SELECT  user_id
                 , DATE_TRUNC('day',MIN(day))::DATE AS start_mth
                 , DATE_TRUNC('day',MAX(day))::DATE AS end_mth
             FROM logins
            GROUP BY 1) r
  UNION ALL
  SELECT  user_id
        , (curr_mth_day + INTERVAL '1 day')::DATE
        , last_mth_day
    FROM temp
   WHERE curr_mth_day < last_mth_day
),
log_history AS (
  SELECT DISTINCT user_id
         , DATE_TRUNC('day',day)::DATE AS month_day
    FROM logins
)

SELECT  t.user_id
      , DATE_TRUNC('month',t.curr_mth_day)::DATE AS month
      , t.curr_mth_day AS month_day
      , lh.month_day AS log_month_day
  FROM temp t
  FULL OUTER JOIN log_history lh
    ON (t.user_id = lh.user_id AND t.curr_mth_day = lh.month_day)
 WHERE t.user_id = 19 AND (t.curr_mth_day < '2021-10-01'::DATE  
                           OR t.curr_mth_day >= '2022-08-01'::DATE)
 ORDER BY 1,2;
```

```console
user_id |   month    | month_day  | log_month_day
--------+------------+------------+---------------
     19 | 2021-09-01 | 2021-09-16 | 2021-09-16
     19 | 2021-09-01 | 2021-09-17 |
     19 | 2021-09-01 | 2021-09-18 |
     19 | 2021-09-01 | 2021-09-19 |
     19 | 2021-09-01 | 2021-09-20 |
     19 | 2021-09-01 | 2021-09-21 |
     19 | 2021-09-01 | 2021-09-22 |
     19 | 2021-09-01 | 2021-09-23 |
     19 | 2021-09-01 | 2021-09-24 |
     19 | 2021-09-01 | 2021-09-25 |
     19 | 2021-09-01 | 2021-09-26 |
     19 | 2021-09-01 | 2021-09-27 |
     19 | 2021-09-01 | 2021-09-28 |
     19 | 2021-09-01 | 2021-09-29 |
     19 | 2021-09-01 | 2021-09-30 | 2021-09-30
     19 | 2022-08-01 | 2022-08-01 |
     19 | 2022-08-01 | 2022-08-02 |
     19 | 2022-08-01 | 2022-08-03 |
     19 | 2022-08-01 | 2022-08-04 |
     19 | 2022-08-01 | 2022-08-05 |
     19 | 2022-08-01 | 2022-08-06 |
     19 | 2022-08-01 | 2022-08-07 |
     19 | 2022-08-01 | 2022-08-08 |
     19 | 2022-08-01 | 2022-08-09 |
     19 | 2022-08-01 | 2022-08-10 |
     19 | 2022-08-01 | 2022-08-11 |
     19 | 2022-08-01 | 2022-08-12 |
     19 | 2022-08-01 | 2022-08-13 |
     19 | 2022-08-01 | 2022-08-14 | 2022-08-14
(29 rows)
```

Next, we create a flag column to indicate if a month_day is not active.

```SQL
WITH RECURSIVE temp (user_id, curr_mth_day, last_mth_day) AS (
  SELECT  r.user_id
        , r.start_mth AS curr_mth_day
        , r.end_mth  AS last_mth_day
    FROM  (SELECT  user_id
                 , DATE_TRUNC('day',MIN(day))::DATE AS start_mth
                 , DATE_TRUNC('day',MAX(day))::DATE AS end_mth
             FROM logins
            GROUP BY 1) r
  UNION ALL
  SELECT  user_id
        , (curr_mth_day + INTERVAL '1 day')::DATE
        , last_mth_day
    FROM temp
   WHERE curr_mth_day < last_mth_day
),
log_history AS (
  SELECT DISTINCT user_id
         , DATE_TRUNC('day',day)::DATE AS month_day
    FROM logins
)

SELECT  t.user_id
      , DATE_TRUNC('month',t.curr_mth_day)::DATE AS month
      , t.curr_mth_day AS month_day
      , lh.month_day AS log_month_day
      , CASE WHEN lh.month_day IS NULL
             THEN 1
             ELSE 0
        END AS not_active
  FROM temp t
  FULL OUTER JOIN log_history lh
    ON (t.user_id = lh.user_id AND t.curr_mth_day = lh.month_day)
 WHERE t.user_id = 19 AND (t.curr_mth_day < '2021-10-01'::DATE  
                           OR t.curr_mth_day >= '2022-08-01'::DATE)
 ORDER BY 1,2;
```

```console
user_id |   month    | month_day  | log_month_day | not_active
--------+------------+------------+---------------+------------
     19 | 2021-09-01 | 2021-09-16 | 2021-09-16    |          0
     19 | 2021-09-01 | 2021-09-17 |               |          1
     19 | 2021-09-01 | 2021-09-18 |               |          1
     19 | 2021-09-01 | 2021-09-19 |               |          1
     19 | 2021-09-01 | 2021-09-20 |               |          1
     19 | 2021-09-01 | 2021-09-21 |               |          1
     19 | 2021-09-01 | 2021-09-22 |               |          1
     19 | 2021-09-01 | 2021-09-23 |               |          1
     19 | 2021-09-01 | 2021-09-24 |               |          1
     19 | 2021-09-01 | 2021-09-25 |               |          1
     19 | 2021-09-01 | 2021-09-26 |               |          1
     19 | 2021-09-01 | 2021-09-27 |               |          1
     19 | 2021-09-01 | 2021-09-28 |               |          1
     19 | 2021-09-01 | 2021-09-29 |               |          1
     19 | 2021-09-01 | 2021-09-30 | 2021-09-30    |          0
     19 | 2022-08-01 | 2022-08-01 |               |          1
     19 | 2022-08-01 | 2022-08-02 |               |          1
     19 | 2022-08-01 | 2022-08-03 |               |          1
     19 | 2022-08-01 | 2022-08-04 |               |          1
     19 | 2022-08-01 | 2022-08-05 |               |          1
     19 | 2022-08-01 | 2022-08-06 |               |          1
     19 | 2022-08-01 | 2022-08-07 |               |          1
     19 | 2022-08-01 | 2022-08-08 |               |          1
     19 | 2022-08-01 | 2022-08-09 |               |          1
     19 | 2022-08-01 | 2022-08-10 |               |          1
     19 | 2022-08-01 | 2022-08-11 |               |          1
     19 | 2022-08-01 | 2022-08-12 |               |          1
     19 | 2022-08-01 | 2022-08-13 |               |          1
     19 | 2022-08-01 | 2022-08-14 | 2022-08-14    |          0
(29 rows)
```

The next step is to calculate a running sum to compute the number of not active days and count the number of active days for the current month.

```SQL
WITH RECURSIVE temp (user_id, curr_mth_day, last_mth_day) AS (
  SELECT  r.user_id
        , r.start_mth AS curr_mth_day
        , r.end_mth  AS last_mth_day
    FROM  (SELECT  user_id
                 , DATE_TRUNC('day',MIN(day))::DATE AS start_mth
                 , DATE_TRUNC('day',MAX(day))::DATE AS end_mth
             FROM logins
            GROUP BY 1) r
  UNION ALL
  SELECT  user_id
        , (curr_mth_day + INTERVAL '1 day')::DATE
        , last_mth_day
    FROM temp
   WHERE curr_mth_day < last_mth_day
),
log_history AS (
  SELECT DISTINCT user_id
         , DATE_TRUNC('day',day)::DATE AS month_day
    FROM logins
),
not_active_mm AS (
  SELECT  t.user_id
        , DATE_TRUNC('month',t.curr_mth_day)::DATE AS month
        , t.curr_mth_day AS month_day
        , lh.month_day AS log_month_day
        , CASE WHEN lh.month_day IS NULL
               THEN 1
               ELSE 0
          END AS not_active
    FROM temp t
    FULL OUTER JOIN log_history lh
      ON (t.user_id = lh.user_id AND t.curr_mth_day = lh.month_day)
)
SELECT  user_id
      , month
      , COUNT(log_month_day) OVER(PARTITION BY user_id, month
                                 ORDER BY month)
        AS active_cnt
      , COALESCE(SUM(not_active) OVER(PARTITION BY user_id, month
                                 ORDER BY month),0)
        AS not_active_cnt
  FROM not_active_mm
  WHERE user_id = 19 AND (month = '2021-09-01'::DATE  
                            OR month = '2022-08-01'::DATE)
  ORDER BY 1,2;
```

```console
user_id |   month    | active_cnt      | not_active_cnt
--------+------------+-----------------+---------------------
     19 | 2021-09-01 |               2 |                  13
     19 | 2021-09-01 |               2 |                  13
     19 | 2021-09-01 |               2 |                  13
     19 | 2021-09-01 |               2 |                  13
     19 | 2021-09-01 |               2 |                  13
     19 | 2021-09-01 |               2 |                  13
     19 | 2021-09-01 |               2 |                  13
     19 | 2021-09-01 |               2 |                  13
     19 | 2021-09-01 |               2 |                  13
     19 | 2021-09-01 |               2 |                  13
     19 | 2021-09-01 |               2 |                  13
     19 | 2021-09-01 |               2 |                  13
     19 | 2021-09-01 |               2 |                  13
     19 | 2021-09-01 |               2 |                  13
     19 | 2021-09-01 |               2 |                  13
     19 | 2022-08-01 |               1 |                  13
     19 | 2022-08-01 |               1 |                  13
     19 | 2022-08-01 |               1 |                  13
     19 | 2022-08-01 |               1 |                  13
     19 | 2022-08-01 |               1 |                  13
     19 | 2022-08-01 |               1 |                  13
     19 | 2022-08-01 |               1 |                  13
     19 | 2022-08-01 |               1 |                  13
     19 | 2022-08-01 |               1 |                  13
     19 | 2022-08-01 |               1 |                  13
     19 | 2022-08-01 |               1 |                  13
     19 | 2022-08-01 |               1 |                  13
     19 | 2022-08-01 |               1 |                  13
     19 | 2022-08-01 |               1 |                  13
(29 rows)
```

We want to group by user_id and month.


```SQL
WITH RECURSIVE temp (user_id, curr_mth_day, last_mth_day) AS (
  SELECT  r.user_id
        , r.start_mth AS curr_mth_day
        , r.end_mth  AS last_mth_day
    FROM  (SELECT  user_id
                 , DATE_TRUNC('day',MIN(day))::DATE AS start_mth
                 , DATE_TRUNC('day',MAX(day))::DATE AS end_mth
             FROM logins
            GROUP BY 1) r
  UNION ALL
  SELECT  user_id
        , (curr_mth_day + INTERVAL '1 day')::DATE
        , last_mth_day
    FROM temp
   WHERE curr_mth_day < last_mth_day
),
log_history AS (
  SELECT DISTINCT user_id
         , DATE_TRUNC('day',day)::DATE AS month_day
    FROM logins
),
not_active_mm AS (
  SELECT  t.user_id
        , DATE_TRUNC('month',t.curr_mth_day)::DATE AS month
        , t.curr_mth_day AS month_day
        , lh.month_day AS log_month_day
        , CASE WHEN lh.month_day IS NULL
               THEN 1
               ELSE 0
          END AS not_active
    FROM temp t
    FULL OUTER JOIN log_history lh
      ON (t.user_id = lh.user_id AND t.curr_mth_day = lh.month_day)
),
active_not_active_dy AS (
  SELECT  user_id
        , month
        , COUNT(log_month_day) OVER(PARTITION BY user_id, month
                                   ORDER BY month)
          AS active_cnt
        , COALESCE(SUM(not_active) OVER(PARTITION BY user_id, month
                                   ORDER BY month),0)
          AS not_active_cnt
    FROM not_active_mm

)
SELECT  user_id
      , month
      , MAX(active_cnt) AS active_cnt
      , MAX(not_active_cnt) AS not_active_cnt
  FROM active_not_active_dy
 WHERE user_id = 19
 GROUP BY 1,2  
 ORDER BY 1,2;
```

```console
user_id |   month    | active_cnt | not_active_cnt
--------+------------+------------+----------------
     19 | 2021-09-01 |          2 |             13
     19 | 2021-10-01 |          0 |             31
     19 | 2021-11-01 |          1 |             29
     19 | 2021-12-01 |          1 |             30
     19 | 2022-01-01 |          0 |             31
     19 | 2022-02-01 |          0 |             28
     19 | 2022-03-01 |          0 |             31
     19 | 2022-04-01 |          2 |             28
     19 | 2022-05-01 |          0 |             31
     19 | 2022-06-01 |          0 |             30
     19 | 2022-07-01 |          0 |             31
     19 | 2022-08-01 |          1 |             13
(12 rows)
```

Lastly, compute the cumulative sum of the past_active and past_not_active days in the preceding months.


```SQL
WITH RECURSIVE temp (user_id, curr_mth_day, last_mth_day) AS (
  SELECT  r.user_id
        , r.start_mth AS curr_mth_day
        , r.end_mth  AS last_mth_day
    FROM  (SELECT  user_id
                 , DATE_TRUNC('day',MIN(day))::DATE AS start_mth
                 , DATE_TRUNC('day',MAX(day))::DATE AS end_mth
             FROM logins
            GROUP BY 1) r
  UNION ALL
  SELECT  user_id
        , (curr_mth_day + INTERVAL '1 day')::DATE
        , last_mth_day
    FROM temp
   WHERE curr_mth_day < last_mth_day
),
log_history AS (
  SELECT DISTINCT user_id
         , DATE_TRUNC('day',day)::DATE AS month_day
    FROM logins
),
not_active_mm AS (
  SELECT  t.user_id
        , DATE_TRUNC('month',t.curr_mth_day)::DATE AS month
        , t.curr_mth_day AS month_day
        , lh.month_day AS log_month_day
        , CASE WHEN lh.month_day IS NULL
               THEN 1
               ELSE 0
          END AS not_active
    FROM temp t
    FULL OUTER JOIN log_history lh
      ON (t.user_id = lh.user_id AND t.curr_mth_day = lh.month_day)
),
active_not_active_dy AS (
  SELECT  user_id
        , month
        , COUNT(log_month_day) OVER(PARTITION BY user_id, month
                                   ORDER BY month)
          AS active_cnt
        , COALESCE(SUM(not_active) OVER(PARTITION BY user_id, month
                                   ORDER BY month),0)
          AS not_active_cnt
    FROM not_active_mm

),
active_not_active_mm AS (
  SELECT  user_id
        , month
        , MAX(active_cnt) AS active_cnt
        , MAX(not_active_cnt) AS not_active_cnt
    FROM active_not_active_dy
   WHERE user_id = 19
   GROUP BY 1,2
)
SELECT  user_id
      , month
      , COALESCE(SUM(active_cnt) OVER (PARTITION BY user_id
                                  ORDER BY month
                              ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING),0)
        AS prec_active_cnt
      , COALESCE(SUM(not_active_cnt) OVER (PARTITION BY user_id
                                      ORDER BY month
                                  ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING),0)
        AS prec_not_active_cnt
  FROM active_not_active_mm
 WHERE user_id = 19
 ORDER BY 1,2;
```

```console
user_id |   month    | prec_active_cnt | prec_not_active_cnt
--------+------------+-----------------+---------------------
     19 | 2021-09-01 |               0 |                   0
     19 | 2021-10-01 |               2 |                  13
     19 | 2021-11-01 |               2 |                  44
     19 | 2021-12-01 |               3 |                  73
     19 | 2022-01-01 |               4 |                 103
     19 | 2022-02-01 |               4 |                 134
     19 | 2022-03-01 |               4 |                 162
     19 | 2022-04-01 |               4 |                 193
     19 | 2022-05-01 |               6 |                 221
     19 | 2022-06-01 |               6 |                 252
     19 | 2022-07-01 |               6 |                 282
     19 | 2022-08-01 |               6 |                 313
(12 rows)
```

The query below displays the output in a more readable format.

```SQL
WITH RECURSIVE temp (user_id, curr_mth_day, last_mth_day) AS (
  SELECT  r.user_id
        , r.start_mth AS curr_mth_day
        , r.end_mth  AS last_mth_day
    FROM  (SELECT  user_id
                 , DATE_TRUNC('day',MIN(day))::DATE AS start_mth
                 , DATE_TRUNC('day',MAX(day))::DATE AS end_mth
             FROM logins
            GROUP BY 1) r
  UNION ALL
  SELECT  user_id
        , (curr_mth_day + INTERVAL '1 day')::DATE
        , last_mth_day
    FROM temp
   WHERE curr_mth_day < last_mth_day
),
log_history AS (
  SELECT DISTINCT user_id
         , DATE_TRUNC('day',day)::DATE AS month_day
    FROM logins
),
not_active_mm AS (
  SELECT  t.user_id
        , DATE_TRUNC('month',t.curr_mth_day)::DATE AS month
        , t.curr_mth_day AS month_day
        , lh.month_day AS log_month_day
        , CASE WHEN lh.month_day IS NULL
               THEN 1
               ELSE 0
          END AS not_active
    FROM temp t
    FULL OUTER JOIN log_history lh
      ON (t.user_id = lh.user_id AND t.curr_mth_day = lh.month_day)
),
active_not_active_dy AS (
  SELECT  user_id
        , month
        , COUNT(log_month_day) OVER(PARTITION BY user_id, month
                                   ORDER BY month)
          AS active_cnt
        , COALESCE(SUM(not_active) OVER(PARTITION BY user_id, month
                                   ORDER BY month),0)
          AS not_active_cnt
    FROM not_active_mm

),
active_not_active_mm AS (
  SELECT  user_id
        , month
        , MAX(active_cnt) AS active_cnt
        , MAX(not_active_cnt) AS not_active_cnt
    FROM active_not_active_dy
   WHERE user_id = 19
   GROUP BY 1,2
),
prec_active_not_active_mm AS (
  SELECT  user_id
        , month AS month_mm
        , COALESCE(SUM(active_cnt) OVER (PARTITION BY user_id
                                    ORDER BY month
                                ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING),0)
          AS prec_active_cnt
        , COALESCE(SUM(not_active_cnt) OVER (PARTITION BY user_id
                                        ORDER BY month
                                    ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING),0)
          AS prec_not_active_cnt
    FROM active_not_active_mm
)
SELECT  user_id
      , TO_CHAR(month_mm,'YYYY') AS year
      , TO_CHAR(month_mm,'MONTH') AS month
      , prec_active_cnt
      , prec_not_active_cnt
  FROM prec_active_not_active_mm
 WHERE user_id = 19
 ORDER BY user_id, month_mm;
```

```console
user_id | year |   month   | prec_active_cnt | prec_not_active_cnt
--------+------+-----------+-----------------+---------------------
     19 | 2021 | SEPTEMBER |               0 |                   0
     19 | 2021 | OCTOBER   |               2 |                  13
     19 | 2021 | NOVEMBER  |               2 |                  44
     19 | 2021 | DECEMBER  |               3 |                  73
     19 | 2022 | JANUARY   |               4 |                 103
     19 | 2022 | FEBRUARY  |               4 |                 134
     19 | 2022 | MARCH     |               4 |                 162
     19 | 2022 | APRIL     |               4 |                 193
     19 | 2022 | MAY       |               6 |                 221
     19 | 2022 | JUNE      |               6 |                 252
     19 | 2022 | JULY      |               6 |                 282
     19 | 2022 | AUGUST    |               6 |                 313
(12 rows)
```
----------------------------------

************************

You want to do a cohort analysis of active users who have been a `reactivated user` in the past. Create a table of users who have been `churned` users in the past and list the first last date they logged in and the first last day they logged in after a period longer than a month, (`last churned user date`). How long he has been not active ?


```SQL
SELECT *
  FROM logins
 WHERE DATE_TRUNC('month',day) = (SELECT MAX(DATE_TRUNC('month',day)) FROM logins);
```


```SQL
SELECT user_id, DATE_TRUNC('day',day)::DATE AS day
  FROM logins
 WHERE DATE_TRUNC('month',day) = (SELECT MAX(DATE_TRUNC('month',day)) FROM logins)
       AND user_id = 1
 ORDER BY day;
```

```console
user_id |    day
---------+------------
      1 | 2022-08-01
      1 | 2022-08-05
      1 | 2022-08-29
      1 | 2022-08-31
(4 rows)
```

```SQL
SELECT u1.user_id AS u1
      ,u2.user_id AS u2
      ,DATE_TRUNC('month',u1.day)::DATE AS current_month
      ,DATE_TRUNC('month',u2.day)::DATE AS previous_month
  FROM logins u1
  LEFT JOIN logins u2
    ON (u1.user_id = u2.user_id AND
        DATE_TRUNC('month',u2.day) = DATE_TRUNC('month',u1.day) - INTERVAL '1 month')
 WHERE (u2.user_id IS NULL AND DATE_TRUNC('month',u2.day)::DATE IS NULL) AND
       (u1.user_id = 1)
 ORDER BY 1, 2,3,4;
```

```console
u1 | u2 |    dy1     | dy2
----+----+------------+-----
 1 |    | 2021-12-01 |      He did not login
 1 |    | 2021-12-01 |       2021-11-01
 1 |    | 2021-12-01 |
 -----------------------
 1 |    | 2022-03-01 |       2022-02-01
 -----------------------
 1 |    | 2022-07-01 |       2022-06-01 <---
```

The first last month he did logged in after a period longer than a month was `July 2022`.

If we analyze the login history of user_id `1`:

```SQL
SELECT user_id, DATE_TRUNC('day',day)::DATE AS day
  FROM logins
 WHERE DATE_TRUNC('day',day)::DATE < '2022-08-01'::DATE
       AND user_id = 1
 ORDER BY day DESC;
```

```console
user_id |    day
---------+------------
      1 | 2022-07-31 <---  He has been not active for 66 days
      1 | 2022-05-26 <---
      1 | 2022-05-12
      1 | 2022-04-25
      1 | 2022-04-19
      1 | 2022-03-04
      1 | 2022-01-27
      1 | 2022-01-16
      1 | 2021-12-24
      1 | 2021-12-07
      1 | 2021-12-05
(11 rows)
```

```SQL
SELECT '2022-07-31'::DATE - '2022-05-26'::DATE; -- 66 days
```

```SQL
SELECT user_id, DATE_TRUNC('day',day)::DATE AS day
  FROM logins
 WHERE DATE_TRUNC('day',day)::DATE < '2022-09-01'::DATE
       AND user_id = 1
 ORDER BY day DESC;
```

Calculate the average number of days a user has been not active after the last churned date.


-----

We first create a table listing the monthly active users;

```SQL
WITH monthly_activity AS (
  SELECT  DISTINCT DATE_TRUNC('month',day)::DATE AS month
        , user_id
    FROM logins
)
SELECT month, user_id
  FROM monthly_activity
  ORDER BY 1,2;
```

```console
month      | user_id
-----------+---------
2021-09-01 |       3
2021-09-01 |       4
2021-09-01 |       5
2021-09-01 |       6
2021-09-01 |       7
2021-09-01 |      10
2021-09-01 |      12
2021-09-01 |      13
2021-09-01 |      16
2021-09-01 |      17
  ....     |      ...
2021-09-01 |      99
-----------+----------
2021-10-01 |      3
  ....     |      ...  
```

As mentioned in the problem statement section, we introduce a new table, containing `users’ first active day`. Here it is:

```SQL
WITH first_activity AS (
  SELECT  user_id
        , DATE_TRUNC('day',MIN(day))::DATE AS day
    FROM logins
   GROUP BY 1
)
SELECT *
  FROM first_activity
 ORDER BY 1;
```

```console
user_id |    day
--------+------------
      1 | 2021-12-05
      2 | 2021-11-14
      3 | 2021-09-06
      4 | 2021-09-20
      5 | 2021-09-02
      6 | 2021-09-08
      7 | 2021-09-15
      8 | 2021-10-31
      9 | 2021-10-11
      ..| ...
     28 | 2021-09-24
```

Next, we create a table






Next, we create a table of `monthly churned users` with the first login day.

```SQL
WITH monthly_churned AS (
  SELECT  DATE_TRUNC('month',u1.day)::DATE AS y_month
        , u1.user_id AS churned_user_id
        , DATE_TRUNC('day',MIN(u1.day))::DATE AS day1stlog
    FROM logins u1
    LEFT JOIN logins u2
      ON (u1.user_id = u2.user_id AND
          DATE_TRUNC('month',u2.day) = DATE_TRUNC('month',u1.day) + INTERVAL '1 month')
   WHERE (u2.user_id IS NULL AND DATE_TRUNC('month',u2.day)::DATE IS NULL)
   GROUP BY y_month, churned_user_id
   ORDER BY y_month, churned_user_id
)

SELECT  churned_user_id
      , y_month AS month
      , day1stlog
  FROM monthly_churned
 ORDER BY 1;
```

```console
churned_user_id |   month    | day1stlog
----------------+------------+------------
              1 | 2022-01-01 | 2022-01-16
              1 | 2022-05-01 | 2022-05-12
              1 | 2022-08-01 | 2022-08-01
              2 | 2022-05-01 | 2022-05-13
              2 | 2022-01-01 | 2022-01-20
              2 | 2021-11-01 | 2021-11-14
              2 | 2022-08-01 | 2022-08-16
              3 | 2022-01-01 | 2022-01-25
              3 | 2022-04-01 | 2022-04-04
              3 | 2022-08-01 | 2022-08-30
            ... |   ...      | ...
             26 | 2021-11-01 | 2021-11-29
             26 | 2022-05-01 | 2022-05-22
             26 | 2022-08-01 | 2022-08-23
            ... |   ...      | ...
```

Finally, we join the `monthly_churned` user and `first_activity` tables to exclude new users who joined the current month earlier than a period of a month since the first activity day.

```SQL
WITH first_activity AS (
  SELECT  user_id
        , DATE_TRUNC('day',MIN(day))::DATE AS day
    FROM logins
   GROUP BY 1
),
monthly_churned AS (
  SELECT  DATE_TRUNC('month',u1.day)::DATE AS y_month
        , u1.user_id AS churned_user_id
        , DATE_TRUNC('day',MIN(u1.day))::DATE AS day1stlog
    FROM logins u1
    LEFT JOIN logins u2
      ON (u1.user_id = u2.user_id AND
          DATE_TRUNC('month',u2.day) = DATE_TRUNC('month',u1.day) + INTERVAL '1 month')
   WHERE (u2.user_id IS NULL AND DATE_TRUNC('month',u2.day)::DATE IS NULL)
   GROUP BY y_month, churned_user_id
   ORDER BY y_month, churned_user_id
)
SELECT  c.y_month AS month
      , COUNT(c.churned_user_id) AS churned_cnt
  FROM first_activity f
 INNER JOIN monthly_churned c
    ON f.user_id = c.churned_user_id AND c.day1stlog > (f.day + INTERVAL '1 month')::DATE
 GROUP BY 1
 ORDER BY 1;
```


SELECT DISTINCT user_id
       , DATE_TRUNC('day',day)::DATE AS month
  FROM logins
 WHERE user_id = 19
 ORDER BY 1,2;
