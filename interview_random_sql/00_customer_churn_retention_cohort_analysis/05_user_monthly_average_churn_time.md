# User Monthly Average Churn Time

In problem [3](./03_churned_users_per_month.md), we defined the notion of churned user and explained how to compute the monthly number of churned users, as the number of users who had activity last month but did not come back the current month.

In this section we want to compute statistics about the number of activity and no activity days for consecutive logins and churned periods.


## Problem

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

### Problem 1

We want to return the following columns for each user:

- `user_id`: the identification number of this user
- `login_period`: the ordinal identifier of a no activity period or churn_period
- `month`: the month of this `login_period`.
- `login_start`: the starting date of this `login_period`
- `login_end`: the ending date of this `login_period`
- `churn_start`: the starting date of the churn period next to this `login_period`
- `churn_end`: the ending date of the churn period next to this `login_period`


:warning: If a month does not have a login period is considered as a **login period record with NULL values** in the columns `login_start` and `login_end`. On the other hand, the `churn_start` and `churn_end` will not be NULL. Similarly, if a month starts with a `churn` period the `login_start` and `login_end` columns will be NULL and the `churn_start` and `churn_end` columns will not be NULL.

Let's analyse the login history of a single user. For example, we want to track the login history of user `41`.

```console
period_id | user_id |   month    | login_start | login_end  | churn_start | churn_end
----------+---------+------------+-------------+------------+-------------+------------
        1 |      41 | 2021-09-01 | 2021-09-04  | 2021-09-04 | 2021-09-05  | 2021-09-19
        2 |      41 | 2021-09-01 | 2021-09-20  | 2021-09-20 | 2021-09-21  | 2021-09-30
        3 |      41 | 2021-10-01 |             |            | 2021-10-01  | 2021-10-10
        4 |      41 | 2021-10-01 | 2021-10-11  | 2021-10-11 | 2021-10-12  | 2021-10-26
        5 |      41 | 2021-10-01 | 2021-10-27  | 2021-10-27 | 2021-10-28  | 2021-10-31
        6 |      41 | 2021-11-01 |             |            | 2021-11-01  | 2021-11-12
        7 |      41 | 2021-11-01 | 2021-11-13  | 2021-11-13 | 2021-11-14  | 2021-11-24
        8 |      41 | 2021-11-01 | 2021-11-25  | 2021-11-25 | 2021-11-26  | 2021-11-30
        9 |      41 | 2021-12-01 |             |            | 2021-12-01  | 2021-12-03
       10 |      41 | 2021-12-01 | 2021-12-04  | 2021-12-05 | 2021-12-06  | 2021-12-08
       11 |      41 | 2021-12-01 | 2021-12-09  | 2021-12-09 | 2021-12-10  | 2021-12-22
       12 |      41 | 2021-12-01 | 2021-12-23  | 2021-12-23 | 2021-12-24  | 2021-12-27
       13 |      41 | 2021-12-01 | 2021-12-28  | 2021-12-28 | 2021-12-29  | 2021-12-31
       14 |      41 | 2022-01-01 |             |            | 2022-01-01  | 2022-01-14
       15 |      41 | 2022-01-01 | 2022-01-15  | 2022-01-15 | 2022-01-16  | 2022-01-31
       16 |      41 | 2022-02-01 |             |            | 2022-02-01  | 2022-02-13
       17 |      41 | 2022-02-01 | 2022-02-14  | 2022-02-14 | 2022-02-15  | 2022-02-28
       18 |      41 | 2022-03-01 |             |            | 2022-03-01  | 2022-03-09
       19 |      41 | 2022-03-01 | 2022-03-10  | 2022-03-10 | 2022-03-11  | 2022-03-22
       20 |      41 | 2022-03-01 | 2022-03-23  | 2022-03-23 | 2022-03-24  | 2022-03-31
       21 |      41 | 2022-04-01 |             |            | 2022-04-01  | 2022-04-30
       22 |      41 | 2022-05-01 |             |            | 2022-05-01  | 2022-05-31
       23 |      41 | 2022-06-01 |             |            | 2022-06-01  | 2022-06-30
       24 |      41 | 2022-07-01 |             |            | 2022-07-01  | 2022-07-31
       25 |      41 | 2022-08-01 |             |            | 2022-08-01  | 2022-08-14
       26 |      41 | 2022-08-01 | 2022-08-15  | 2022-08-15 | 2022-08-16  | 2022-08-17
       27 |      41 | 2022-08-01 | 2022-08-18  | 2022-08-18 | 2022-08-19  | 2022-08-31
(27 rows)
```

The output table shows that user `41` has 27 churn periods. The `period_id` numbers `3`,`6`,`14`,`16`,`18` and `25` identify a record with NULL values in the `login_start` and `login_end` columns indicating that these records starts at the beginning of the month with a churn period. Similarly, the `21`,`22` and `23` indicates a month starting with a churn period. In particular, these month do not have activity. This means that in the period of `April`, `May`, `June` and `July` user `41` did not login.
The first record is the day a user subscribed to the channel, or first activity day.  In this case we do not consider the first days of the month.

## Problem 2

We want to return the following columns for each user:

- `user_id`: the identification number of this user
- `month`: The month this user logged in
- `login_periods_cnt`: number of periods a user has been active. A period is an interval of consecutive days this user has been active in the current `month`.
- `churned_periods_cnt`: number of periods a user has not been active. A period is an interval of consecutive days this user has not been active in the current `month`.
- `login_days_cnt`: number of days a user logged in this `month`.
- `churn_days_cnt`: number of days a user did not log this `month`.
- `min_login_duration`: minimum number of consecutive days a user has been active this `month`.
- `max_login_duration`: maximum number of consecutive days a user has been active this `month`.
- `min_churn_duration`: minimum number of consecutive days a user has not been active this `month`.
- `max_churn_duration`: maximum number of consecutive days a user has not been active this `month`.
- `login_days_avg`: The number of days a user on average has been active this `month`.
- `churn_days_avg`: The number of days a user on average has been not active this `month`.
- `std_p_login_duration`: population standard deviation of consecutive days a user has been active this `month`.
- `std_p_churn_duration`: population standard deviation of consecutive days a user has not been active this `month`.

All number are rounded integer values.



```console
user_id |   month    | login_periods_cnt | churn_periods_cnt | login_days_cnt | churn_days_cnt | min_login_duration | max_login_duration | min_churn_duration | max_churn_duration | avg_login_duration | avg_churn_duration | std_p_login_duration | std_p_churn_duration
--------+------------+-------------------+-------------------+----------------+----------------+--------------------+--------------------+--------------------+--------------------+--------------------+--------------------+----------------------+----------------------
     41 | 2021-09-01 |                 2 |                 2 |              2 |             25 |                  1 |                  1 |                 10 |                 15 |                  1 |                 13 |                    0 |                    3
     41 | 2021-10-01 |                 2 |                 3 |              2 |             29 |                  0 |                  1 |                  4 |                 15 |                  1 |                 10 |                    0 |                    4
     41 | 2021-11-01 |                 2 |                 3 |              2 |             28 |                  0 |                  1 |                  5 |                 12 |                  1 |                  9 |                    0 |                    3
     41 | 2021-12-01 |                 4 |                 5 |              5 |             26 |                  0 |                  2 |                  3 |                 13 |                  1 |                  5 |                    1 |                    4
     41 | 2022-01-01 |                 1 |                 2 |              1 |             30 |                  0 |                  1 |                 14 |                 16 |                  1 |                 15 |                    1 |                    1
     41 | 2022-02-01 |                 1 |                 2 |              1 |             27 |                  0 |                  1 |                 13 |                 14 |                  1 |                 14 |                    1 |                    1
     41 | 2022-03-01 |                 2 |                 3 |              2 |             29 |                  0 |                  1 |                  8 |                 12 |                  1 |                 10 |                    0 |                    2
     41 | 2022-04-01 |                 0 |                 1 |              0 |             30 |                  0 |                  0 |                 30 |                 30 |                  0 |                 30 |                    0 |                    0
     41 | 2022-05-01 |                 0 |                 1 |              0 |             31 |                  0 |                  0 |                 31 |                 31 |                  0 |                 31 |                    0 |                    0
     41 | 2022-06-01 |                 0 |                 1 |              0 |             30 |                  0 |                  0 |                 30 |                 30 |                  0 |                 30 |                    0 |                    0
     41 | 2022-07-01 |                 0 |                 1 |              0 |             31 |                  0 |                  0 |                 31 |                 31 |                  0 |                 31 |                    0 |                    0
     41 | 2022-08-01 |                 2 |                 3 |              2 |             29 |                  0 |                  1 |                  2 |                 14 |                  1 |                 10 |                    0 |                    5
(12 rows)
```


## Solution


We provide the solution to Problem 1, 2.

### Solution  1

```SQL
WITH first_activity AS (
  SELECT  user_id
        , DATE_TRUNC('month',MIN(day))::DATE AS month
    FROM logins
   GROUP BY 1
),
calendar AS (
  SELECT s.month::DATE AS month
    FROM GENERATE_SERIES((SELECT DATE_TRUNC('month',MIN(day))::DATE FROM logins),
                         (SELECT DATE_TRUNC('month',MAX(day))::DATE FROM logins),
                          INTERVAL '1 month') AS s(month)
),
user_calendar AS (
  SELECT f.user_id AS user_id
       , c.month AS month
    FROM first_activity f
   INNER JOIN calendar c
      ON f.month <= c.month
),
user_log_day_calendar AS (
  SELECT DISTINCT
         uc.user_id AS user_id
       , uc.month AS month
       , l.day::DATE AS login_day
    FROM user_calendar uc
    LEFT JOIN logins l
      ON uc.user_id = l.user_id AND
         uc.month = DATE_TRUNC('month',l.day)::DATE
),
user_log AS (
  SELECT user_id
       , month
       , login_day
       , CASE WHEN LAG(month,1) OVER (ORDER BY user_id, month, login_day) = month
              THEN CASE WHEN login_day - (LAG(login_day,1) OVER (ORDER BY user_id, login_day)) > 1
                        THEN 1 -- the user did not login the previous day
                        ELSE 0 -- the user login the previous day
                   END
              ELSE CASE WHEN login_day IS NULL
                        THEN 0 -- month with no activity
                        ELSE 1 -- first day of the month
                   END
         END AS s_active
    FROM user_log_day_calendar
),
log_table AS (
  SELECT x.*
       , CASE WHEN LEAD(month,1) OVER (ORDER BY user_id, month, login_day) = month
              THEN CASE WHEN LEAD(s_active,1) OVER (ORDER BY user_id, month, login_day) = 1
                        THEN 1 -- the following day is not active, end of active
                        ELSE 0 -- the following day is active
                   END
              ELSE CASE WHEN login_day IS NULL
                        THEN 0 -- month with no activity
                        ELSE 1 -- the last day of activity in this month
                   END
         END AS e_active
    FROM user_log x
),
log_table2 AS (
  SELECT *
    FROM log_table
   WHERE login_day IS NULL OR (s_active = 1 OR e_active = 1)
),
log_table3 AS (
  SELECT user_id
        , month
        , login_day AS login_start
        , CASE WHEN s_active = e_active
               THEN login_day
               ELSE CASE WHEN login_day IS NOT NULL AND
                              LEAD(s_active,1) OVER (ORDER BY user_id, month, login_day) = 0 AND
                              LEAD(e_active,1) OVER (ORDER BY user_id, month, login_day) = 1
                         THEN LEAD(login_day,1) OVER (ORDER BY user_id, month, login_day)
                         ELSE NULL
                    END
          END AS login_end
    FROM log_table2
),
log_table4 AS (
  SELECT *
    FROM log_table3
   WHERE (login_start IS NOT NULL AND login_end iS NOT NULL) OR
         (login_start IS NULL AND login_end IS NULL)
),
log_table5 AS (
  SELECT  lt.*
        , CASE WHEN login_start IS NULL AND login_end IS NULL
               THEN month
               ELSE CASE WHEN login_end != (month + INTERVAL '1 month')::DATE - 1
                         THEN login_end + 1
                         ELSE NULL
                    END
          END AS churn_start
        , CASE WHEN login_start IS NULL AND login_end IS NULL
               THEN (month + INTERVAL '1 month')::DATE - 1
               ELSE CASE WHEN LEAD(month,1) OVER (ORDER BY user_id, month, login_start) = month
                         THEN LEAD(login_start,1) OVER (ORDER BY user_id, month, login_start) - 1
                         ELSE CASE WHEN login_end != (month + INTERVAL '1 month')::DATE - 1
                                   THEN (month + INTERVAL '1 month')::DATE - 1
                                   ELSE NULL
                              END
                    END
          END AS churn_end
    FROM log_table4 lt
),
user_log_calendar AS (
  SELECT  user_id
        , month
        , login_start
        , login_end
        , churn_start
        , churn_end
        , CASE WHEN LAG(month,1) OVER (ORDER BY user_id, month, login_start) > month
               THEN 0
               ELSE CASE WHEN LAG(month,1) OVER (ORDER BY user_id, month, login_start)!= month AND login_start > month -- the login is not the first day of the month
                         THEN 1
                         ELSE 0
                    END
          END AS churn_1stm_period
    FROM log_table5
),
user_calendar_dup AS (
  SELECT  user_id
        , month
        , s.i
    FROM user_calendar, GENERATE_SERIES(1,2) s(i)
),
logins_period AS (
  SELECT  ROW_NUMBER() OVER (PARTITION BY ulc.user_id
                             ORDER BY ulc.month, churn_1stm_period DESC, ud.i, ulc.login_start )
          AS period_id
        , ulc.user_id
        , ulc.month
        , CASE WHEN ulc.churn_1stm_period = 1
               THEN CASE WHEN ud.i = 1
                         THEN NULL
                         ELSE ulc.login_start
                    END
               ELSE ulc.login_start
          END AS login_start
        , CASE WHEN ulc.churn_1stm_period = 1
               THEN CASE WHEN ud.i = 1
                         THEN NULL
                         ELSE ulc.login_end
                    END
               ELSE ulc.login_end
          END AS login_end
        , CASE WHEN ulc.churn_1stm_period = 1
               THEN CASE WHEN ud.i = 1
                         THEN ulc.month
                         ELSE ulc.churn_start
                    END
               ELSE ulc.churn_start
          END AS churn_start
        , CASE WHEN ulc.churn_1stm_period = 1
               THEN CASE WHEN ud.i = 1
                         THEN login_start - 1
                         ELSE ulc.churn_end
                    END
               ELSE ulc.churn_end
          END AS churn_end
    FROM user_log_calendar ulc
   INNER JOIN user_calendar_dup ud
      ON ulc.user_id = ud.user_id AND ulc.month = ud.month
   WHERE ((ud.i = 1) OR (ud.i = 2 AND ulc.churn_1stm_period = 1))
)

SELECT *
FROM logins_period
ORDER BY period_id;
```


### Solution 2

```SQL
WITH first_activity AS (
  SELECT  user_id
        , DATE_TRUNC('month',MIN(day))::DATE AS month
    FROM logins
   GROUP BY 1
),
calendar AS (
  SELECT s.month::DATE AS month
    FROM GENERATE_SERIES((SELECT DATE_TRUNC('month',MIN(day))::DATE FROM logins),
                         (SELECT DATE_TRUNC('month',MAX(day))::DATE FROM logins),
                          INTERVAL '1 month') AS s(month)
),
user_calendar AS (
  SELECT f.user_id AS user_id
       , c.month AS month
    FROM first_activity f
   INNER JOIN calendar c
      ON f.month <= c.month
),
user_log_day_calendar AS (
  SELECT DISTINCT
         uc.user_id AS user_id
       , uc.month AS month
       , l.day::DATE AS login_day
    FROM user_calendar uc
    LEFT JOIN logins l
      ON uc.user_id = l.user_id AND
         uc.month = DATE_TRUNC('month',l.day)::DATE
),
user_log AS (
  SELECT user_id
       , month
       , login_day
       , CASE WHEN LAG(month,1) OVER (ORDER BY user_id, month, login_day) = month
              THEN CASE WHEN login_day - (LAG(login_day,1) OVER (ORDER BY user_id, login_day)) > 1
                        THEN 1 -- the user did not login the previous day
                        ELSE 0 -- the user login the previous day
                   END
              ELSE CASE WHEN login_day IS NULL
                        THEN 0 -- month with no activity
                        ELSE 1 -- first day of the month
                   END
         END AS s_active
    FROM user_log_day_calendar
),
log_table AS (
  SELECT x.*
       , CASE WHEN LEAD(month,1) OVER (ORDER BY user_id, month, login_day) = month
              THEN CASE WHEN LEAD(s_active,1) OVER (ORDER BY user_id, month, login_day) = 1
                        THEN 1 -- the following day is not active, end of active
                        ELSE 0 -- the following day is active
                   END
              ELSE CASE WHEN login_day IS NULL
                        THEN 0 -- month with no activity
                        ELSE 1 -- the last day of activity in this month
                   END
         END AS e_active
    FROM user_log x
),
log_table2 AS (
  SELECT *
    FROM log_table
   WHERE login_day IS NULL OR (s_active = 1 OR e_active = 1)
),
log_table3 AS (
  SELECT user_id
        , month
        , login_day AS login_start
        , CASE WHEN s_active = e_active
               THEN login_day
               ELSE CASE WHEN login_day IS NOT NULL AND
                              LEAD(s_active,1) OVER (ORDER BY user_id, month, login_day) = 0 AND
                              LEAD(e_active,1) OVER (ORDER BY user_id, month, login_day) = 1
                         THEN LEAD(login_day,1) OVER (ORDER BY user_id, month, login_day)
                         ELSE NULL
                    END
          END AS login_end
    FROM log_table2
),
log_table4 AS (
  SELECT *
    FROM log_table3
   WHERE (login_start IS NOT NULL AND login_end iS NOT NULL) OR
         (login_start IS NULL AND login_end IS NULL)
),
log_table5 AS (
  SELECT  lt.*
        , CASE WHEN login_start IS NULL AND login_end IS NULL
               THEN month
               ELSE CASE WHEN login_end != (month + INTERVAL '1 month')::DATE - 1
                         THEN login_end + 1
                         ELSE NULL
                    END
          END AS churn_start
        , CASE WHEN login_start IS NULL AND login_end IS NULL
               THEN (month + INTERVAL '1 month')::DATE - 1
               ELSE CASE WHEN LEAD(month,1) OVER (ORDER BY user_id, month, login_start) = month
                         THEN LEAD(login_start,1) OVER (ORDER BY user_id, month, login_start) - 1
                         ELSE CASE WHEN login_end != (month + INTERVAL '1 month')::DATE - 1
                                   THEN (month + INTERVAL '1 month')::DATE - 1
                                   ELSE NULL
                              END
                    END
          END AS churn_end
    FROM log_table4 lt
),
user_log_calendar AS (
  SELECT  user_id
        , month
        , login_start
        , login_end
        , churn_start
        , churn_end
        , CASE WHEN LAG(month,1) OVER (ORDER BY user_id, month, login_start) > month
               THEN 0
               ELSE CASE WHEN LAG(month,1) OVER (ORDER BY user_id, month, login_start)!= month AND login_start > month -- the login is not the first day of the month
                         THEN 1
                         ELSE 0
                    END
          END AS churn_1stm_period
    FROM log_table5
),
user_calendar_dup AS (
  SELECT  user_id
        , month
        , s.i
    FROM user_calendar, GENERATE_SERIES(1,2) s(i)
),
logins_period AS (
  SELECT  ROW_NUMBER() OVER (PARTITION BY ulc.user_id
                             ORDER BY ulc.month, churn_1stm_period DESC, ud.i, ulc.login_start )
          AS period_id
        , ulc.user_id
        , ulc.month
        , CASE WHEN ulc.churn_1stm_period = 1
               THEN CASE WHEN ud.i = 1
                         THEN NULL
                         ELSE ulc.login_start
                    END
               ELSE ulc.login_start
          END AS login_start
        , CASE WHEN ulc.churn_1stm_period = 1
               THEN CASE WHEN ud.i = 1
                         THEN NULL
                         ELSE ulc.login_end
                    END
               ELSE ulc.login_end
          END AS login_end
        , CASE WHEN ulc.churn_1stm_period = 1
               THEN CASE WHEN ud.i = 1
                         THEN ulc.month
                         ELSE ulc.churn_start
                    END
               ELSE ulc.churn_start
          END AS churn_start
        , CASE WHEN ulc.churn_1stm_period = 1
               THEN CASE WHEN ud.i = 1
                         THEN login_start - 1
                         ELSE ulc.churn_end
                    END
               ELSE ulc.churn_end
          END AS churn_end
    FROM user_log_calendar ulc
   INNER JOIN user_calendar_dup ud
      ON ulc.user_id = ud.user_id AND ulc.month = ud.month
   WHERE ((ud.i = 1) OR (ud.i = 2 AND ulc.churn_1stm_period = 1))
),
logins_period_cnt AS (
  SELECT  period_id
        , user_id
        , month
        , login_start
        , login_end
        , churn_start
        , churn_end
        , COALESCE(login_end - login_start + 1,0) AS login_days_duration
        , COALESCE(churn_end - churn_start + 1,0) AS churn_days_duration
    FROM logins_period
)
SELECT  user_id
      , month
      , COUNT(login_start) AS login_periods_cnt
      , COUNT(churn_start) AS churn_periods_cnt
      , SUM(login_days_duration) AS login_days_cnt
      , SUM(churn_days_duration) AS churn_days_cnt
      , MIN(login_days_duration) AS min_login_duration
      , MAX(login_days_duration) AS max_login_duration
      , MIN(churn_days_duration) AS min_churn_duration
      , MAX(churn_days_duration) AS max_churn_duration
      , ROUND(AVG(login_days_duration),0) AS avg_login_duration
      , ROUND(AVG(churn_days_duration),0) AS avg_churn_duration
      , ROUND(STDDEV_POP(login_days_duration),0) AS std_p_login_duration
      , ROUND(STDDEV_POP(churn_days_duration),0) AS std_p_churn_duration
  FROM logins_period_cnt
 GROUP BY user_id, month
 ORDER BY user_id, month;
```

## Discussion

Let's analyse the login history of a single user. For example, we want to track the login history of user `41` and find out the periods this user had activity and did not ahve activity.

```SQL
SELECT DISTINCT DATE_TRUNC('day',day)::DATE AS day
  FROM logins
 WHERE user_id = '41'
 ORDER BY day;
```

```console
day                                          PERIOD   DURATION
-------------------------------------------
2021-09-04    First activity log ------------> 1            
           05 <-+ 2021-09-05---------------+
           06   |                          |
           ..   | First not active period  |   
           ..   | Duration 16 days         |
           19 <-+ 2021-09-19---------------+
2021-09-20    Second activity log --> 2      
           21 <-+ 2021-09-21---------------+
           22   |                          |
           ..   | Second not active period |   
           ..   | Duration 9 days          |
***********10 <-+ 2021-09-30---------------+
-------------------------------------------
***********01 <-+ 2021-10-01  START MONTH--+
           02   |                          |
           ..   | Third not active period  |   
           ..   | Duration 10 days         |
           10 <-+ 2021-10-10---------------+
2021-10-11    Third activity log ------------> 3
           12 <-+ 2021-10-12---------------+
           06   |                          |
           ..   | fourth not active period |   
           ..   | Duration 16 days         |
           26 <-+ 2021-10-26---------------+
2021-10-27     4th Activity log -------------> 4
           28 <-+ 2021-10-28---------------+
                |                          |
                | fifth not active period  |   
                | Duration 4 days          |
***********31 <-+ 2021-10-31  END MONTH----+
--------------------------------------------
***********01 <-+ 2021-11-01  START MONTH--+
                |                          |
                | 6th not active period    |   
                | Duration 12 days         |
           12 <-+ 2021-11-12---------------+
2021-11-13     5th Activity log --------------> 5
           14 <-+ 2021-11-14---------------+
                |                          |
                | 7th not active period    |   
                | Duration 10 days         |
           24 <-+ 2021-11-24---------------+
2021-11-25     6th Activity log --------------> 6
           26 <-+ 2021-11-26---------------+
                |                          |
                | 8th not active period    |   
                | Duration  4 days         |
***********30 <-+ 2021-11-30 END MONTH-----+
--------------------------------------------
***********01 <-+ 2021-12-01  START MONTH--+
                |                          |
                | 9th not active period    |  
                | Duration  3 days         |
           03 <-+ 2021-12-03---------------+
2021-12-04     7th Activity log --------------> 7
2021-12-05      | Duration 2 days
           06 <-+ 2021-12-06---------------+
                |                          |
                | 10th not active period   |  
                | Duration   2 days        |
           08 <-+ 2021-12-08---------------+
2021-12-09     8th Activity log -------------> 8
           10 <-+ 2021-12-10---------------+
                |                          |
                | 11th not active period   |   
                | Duration   8 days        |
           22 <-+ 2021-12-11---------------+
2021-12-23     9th Activity log -------------> 9
           24 <-+ 2021-12-24---------------+
                |                          |
                | 12th not active period   |   
                | Duration   4 days        |
           27 <-+ 2021-12-27---------------+
2021-12-28     10th Activity log ------------> 10
           29 <-+ 2021-12-29---------------+
                |                          |
                | 13th not active period   |   
                | Duration    3 days       |
***********31 <-+ 2021-12-31  END MONTH----+
--------------------------------------------
***********01 <-+ 2022-01-01  START MONTH--+
                |                          |
                | 14th not active period   |   
                | Duration 14 days         |
           14 <-+ 2022-01-14---------------+
2022-01-15     11th Activity log ------------> 11
           16 <-+ 2022-01-16---------------+
                |                          |
                | 15th not active period   |   
                | Duration 16 days         |
***********31 <-+ 2022-01-31  END MONTH----+
--------------------------------------------
***********01 <-+ 2022-02-01  START MONTH--+
                |                          |
                | 16th not active period   |   
                | Duration 13 days         |
           13 <-+ 2022-02-13---------------+
2022-02-14     12th Activity log -----------> 12
           15 <-+ 2022-02-15---------------+
                |                          |
                | 17th not active period   |   
                | Duration  14 days        |
***********28 <-+ 2022-02-28  END MONTH----+
--------------------------------------------
***********01 <-+ 2022-03-01  START MONTH--+
                |                          |
                | 18th not active period   |   
                | Duration 9 days          |
           09 <-+ 2022-03-09---------------+
2022-03-10     13th Activity log -----------> 13
           11 <-+ 2022-03-11---------------+
                |                          |
                | 19th not active period   |   
                | Duration 11 days         |
           22 <-+ 2022-03-22---------------+
2022-03-23     14th Activity log -----------> 14
           24 <-+ 2022-03-24---------------+
                |                          |
                | 20th not active period   |   
                | Duration 7 days          |
***********31 <-+ 2022-03-31  END MONTH----+
--------------------------------------------
***********01 <-+ 2022-04-01  START MONTH--+
                |                          |
                | 21th not active period   |-> 15   
                | Duration 30 days         |
***********30 <-+ 2022-04-30  END MONTH----+
--------------------------------------------
***********01 <-+ 2022-05-01  START MONTH--+
                |                          |
                | 22th not active period   |-> 16
                | Duration 31 days         |
***********31 <-+ 2022-05-31  END MONTH----+
--------------------------------------------
***********01 <-+ 2022-06-01  START MONTH--+
                |                          |
                | 23th not active period   |-> 17
                | Duration 30 days         |
***********31 <-+ 2022-06-31  END MONTH----+
--------------------------------------------
***********01 <-+ 2022-07-01  START MONTH--+
                |                          |
                | 24th not active period   |-> 18
                | Duration 31 days         |
***********31 <-+ 2022-07-31  END MONTH----+
--------------------------------------------
***********01 <-+ 2022-08-01  START MONTH--+
                |                          |
                | 25th not active period   |   
                | Duration 14 days         |
           14 <-+ 2022-08-14 --------------+
2022-08-15       15th Activity log ----------> 19
           16 <-+ 2022-08-16---------------+
                |                          |
                | 26th not active period   |   
                | Duration 2 days          |
           17 <-+ 2022-08-17---------------+
2022-08-18       16th Activity log ----------> 20
           19 <-+ 2022-08-19---------------+
                |                          |
                | 27th not active period   |   
                | Duration 12 days         |
***********31 <-+ 2021-07-31  END MONTH----+
(17 rows)
```


First, we create a table of `first activity` users.

```SQL
WITH first_activity AS (
  SELECT  user_id
        , DATE_TRUNC('month',MIN(day))::DATE AS month
    FROM logins
   GROUP BY 1
)
```

Next, generate a monthly calendar table starting the first month of activity in table logins and ending in the latest month.

```SQL
SELECT s.month::DATE AS month
  FROM GENERATE_SERIES((SELECT DATE_TRUNC('month',MIN(day))::DATE FROM logins),
                       (SELECT DATE_TRUNC('month',MAX(day))::DATE FROM logins),
                        INTERVAL '1 month') AS s(month);
```

```console
month
------------
2021-09-01
2021-10-01
2021-11-01
2021-12-01
2022-01-01
2022-02-01
2022-03-01
2022-04-01
2022-05-01
2022-06-01
2022-07-01
2022-08-01
(12 rows)
```

Next, join `first_activity` user and the monthly calendar table.

```SQL
WITH first_activity AS (
  SELECT  user_id
        , DATE_TRUNC('month',MIN(day))::DATE AS month
    FROM logins
   GROUP BY 1
),
calendar AS (
  SELECT s.month::DATE AS month
    FROM GENERATE_SERIES((SELECT DATE_TRUNC('month',MIN(day))::DATE FROM logins),
                         (SELECT DATE_TRUNC('month',MAX(day))::DATE FROM logins),
                          INTERVAL '1 month') AS s(month)
)
SELECT f.user_id
     , c.month AS month
  FROM first_activity f
 INNER JOIN calendar c
    ON f.month <= c.month
 WHERE user_id = 41
 ORDER BY month;
```

The output will be the calendar table of each user. It's worth noting that the first activity month depends on the user's activity. The number of rows for each users is equal to the number of months between the first user's activity month and the last activity month in the data set.

```console
user_id |   month
--------+------------
     41 | 2021-09-01
     41 | 2021-10-01
     41 | 2021-11-01
     41 | 2021-12-01
     41 | 2022-01-01
     41 | 2022-02-01
     41 | 2022-03-01
     41 | 2022-04-01
     41 | 2022-05-01
     41 | 2022-06-01
     41 | 2022-07-01
     41 | 2022-08-01
(12 rows)
```

Next, join the output table with the logins table.

```SQL
WITH first_activity AS (
  SELECT  user_id
        , DATE_TRUNC('month',MIN(day))::DATE AS month
    FROM logins
   GROUP BY 1
),
calendar AS (
  SELECT s.month::DATE AS month
    FROM GENERATE_SERIES((SELECT DATE_TRUNC('month',MIN(day))::DATE FROM logins),
                         (SELECT DATE_TRUNC('month',MAX(day))::DATE FROM logins),
                          INTERVAL '1 month') AS s(month)
),
user_calendar AS (
  SELECT f.user_id AS user_id
       , c.month AS month
    FROM first_activity f
   INNER JOIN calendar c
      ON f.month <= c.month
)
SELECT DISTINCT
       uc.user_id AS user_id
     , uc.month AS month
     , l.day::DATE AS login_day
  FROM user_calendar uc
  LEFT JOIN logins l
    ON uc.user_id = l.user_id AND
       uc.month = DATE_TRUNC('month',l.day)::DATE
 WHERE uc.user_id = 41
 ORDER BY uc.month, login_day;
```

The output will be the login history of each user joined with the calendar month. The idea is to group by month the login day. We may have notice the `DISTINCT` keyword in the `SELECT` statement. This keyword is needed since there might be more than a single login in a day.

```console
user_id |   month    | login_day
---------+------------+------------
     41 | 2021-09-01 | 2021-09-04
     41 | 2021-09-01 | 2021-09-20
     ----------------------------
     41 | 2021-10-01 | 2021-10-11
     41 | 2021-10-01 | 2021-10-27
     ----------------------------
     41 | 2021-11-01 | 2021-11-13
     41 | 2021-11-01 | 2021-11-25
     ----------------------------
     41 | 2021-12-01 | 2021-12-04
     41 | 2021-12-01 | 2021-12-05
     41 | 2021-12-01 | 2021-12-09
     41 | 2021-12-01 | 2021-12-23
     41 | 2021-12-01 | 2021-12-28
     ----------------------------
     41 | 2022-01-01 | 2022-01-15
     ----------------------------
     41 | 2022-02-01 | 2022-02-14
     ----------------------------
     41 | 2022-03-01 | 2022-03-10
     41 | 2022-03-01 | 2022-03-23
     ----------------------------
     41 | 2022-04-01 |
     ----------------------------
     41 | 2022-05-01 |
     ----------------------------
     41 | 2022-06-01 |
     ----------------------------
     41 | 2022-07-01 |
     ----------------------------
     41 | 2022-08-01 | 2022-08-15
     41 | 2022-08-01 | 2022-08-18
(21 rows)
```

The output table shows that the month of `April`,`May`,`June` and `July` had no activity as there is a **NULL** value in the login_day column. We want to identify the starting and ending date of active and not_active periods in each month.

First, create a flag column `s_active` to indicate if a logins date is the starting date of an active period.


```SQL
WITH first_activity AS (
  SELECT  user_id
        , DATE_TRUNC('month',MIN(day))::DATE AS month
    FROM logins
   GROUP BY 1
),
calendar AS (
  SELECT s.month::DATE AS month
    FROM GENERATE_SERIES((SELECT DATE_TRUNC('month',MIN(day))::DATE FROM logins),
                         (SELECT DATE_TRUNC('month',MAX(day))::DATE FROM logins),
                          INTERVAL '1 month') AS s(month)
),
user_calendar AS (
  SELECT f.user_id AS user_id
       , c.month AS month
    FROM first_activity f
   INNER JOIN calendar c
      ON f.month <= c.month
),
user_log_day_calendar AS (
  SELECT DISTINCT
         uc.user_id AS user_id
       , uc.month AS month
       , l.day::DATE AS login_day
    FROM user_calendar uc
    LEFT JOIN logins l
      ON uc.user_id = l.user_id AND
         uc.month = DATE_TRUNC('month',l.day)::DATE
)
SELECT user_id
     , month
     , login_day
     , CASE WHEN LAG(month,1) OVER (ORDER BY user_id, login_day) = month
            THEN CASE WHEN login_day - (LAG(login_day,1) OVER (ORDER BY user_id, login_day)) > 1
                      THEN 1 -- the user did not login the previous day
                      ELSE 0 -- the user login the previous day
                 END
            WHEN login_day IS NULL
            THEN 0 -- month with no activity
            ELSE 1 -- first day of the month
       END AS s_active
  FROM user_log_calendar
 WHERE user_id = 41
 ORDER BY user_id, login_day;
```

The basic idea is to indicate which records is the beginning of an activity period. Keep in mind that an activity period can have a group of consecutive `login_day`. The objective will be to identify the starting and ending date of an activity period.

```console
user_id |   month    | login_day  | s_active
---------+------------+------------+----------
     41 | 2021-09-01 | 2021-09-20 |        1

     41 | 2021-09-01 | 2021-09-04 |        1
     -----------------------------------------
     41 | 2021-10-01 | 2021-10-11 |        1

     41 | 2021-10-01 | 2021-10-27 |        1
     ------------------------------------------
     41 | 2021-11-01 | 2021-11-13 |        1

     41 | 2021-11-01 | 2021-11-25 |        1
     ------------------------------------------
     41 | 2021-12-01 | 2021-12-28 |        1

     41 | 2021-12-01 | 2021-12-04 |        1
     41 | 2021-12-01 | 2021-12-05 |        0

     41 | 2021-12-01 | 2021-12-09 |        1

     41 | 2021-12-01 | 2021-12-23 |        1
     -----------------------------------------
     41 | 2022-01-01 | 2022-01-15 |        1
     -----------------------------------------
     41 | 2022-02-01 | 2022-02-14 |        1
     -----------------------------------------
     41 | 2022-03-01 | 2022-03-10 |        1

     41 | 2022-03-01 | 2022-03-23 |        1
     ----------------------------------------
     41 | 2022-04-01 |            |        0
     ----------------------------------------
     41 | 2022-05-01 |            |        0
     ----------------------------------------
     41 | 2022-06-01 |            |        0
     ----------------------------------------
     41 | 2022-07-01 |            |        0
     -----------------------------------------
     41 | 2022-08-01 | 2022-08-18 |        1

     41 | 2022-08-01 | 2022-08-15 |        1
(21 rows)
```


Next, create a column that indicates the end of an activity period in a month.

```SQL
WITH first_activity AS (
  SELECT  user_id
        , DATE_TRUNC('month',MIN(day))::DATE AS month
    FROM logins
   GROUP BY 1
),
calendar AS (
  SELECT s.month::DATE AS month
    FROM GENERATE_SERIES((SELECT DATE_TRUNC('month',MIN(day))::DATE FROM logins),
                         (SELECT DATE_TRUNC('month',MAX(day))::DATE FROM logins),
                          INTERVAL '1 month') AS s(month)
),
user_calendar AS (
  SELECT f.user_id AS user_id
       , c.month AS month
    FROM first_activity f
   INNER JOIN calendar c
      ON f.month <= c.month
),
user_log_day_calendar AS (
  SELECT DISTINCT
         uc.user_id AS user_id
       , uc.month AS month
       , l.day::DATE AS login_day
    FROM user_calendar uc
    LEFT JOIN logins l
      ON uc.user_id = l.user_id AND
         uc.month = DATE_TRUNC('month',l.day)::DATE
),
user_log AS (
  SELECT user_id
       , month
       , login_day
       , CASE WHEN LAG(month,1) OVER (ORDER BY user_id, login_day) = month
              THEN CASE WHEN login_day - (LAG(login_day,1) OVER (ORDER BY user_id, login_day)) > 1
                        THEN 1 -- the user did not login the previous day
                        ELSE 0 -- the user login the previous day
                   END
              ELSE CASE WHEN login_day IS NULL
                        THEN 0 -- month with no activity
                        ELSE 1 -- first day of the month
                   END
         END AS s_active
    FROM user_log_day_calendar
)
SELECT x.*
     , CASE WHEN LEAD(month,1) OVER (ORDER BY user_id, login_day) = month
            THEN CASE WHEN LEAD(s_active,1) OVER (ORDER BY user_id, login_day) = 1
                      THEN 1 -- the following day is not active, end of active
                      ELSE 0 -- the following day is active
                 END
            ELSE CASE WHEN login_day IS NULL
                      THEN 0 -- month with no activity
                      ELSE 1 -- the last day of activity in this month
                 END
       END AS e_active
  FROM user_log x
 WHERE user_id = 41
 ORDER BY user_id, month, login_day;
```

```console
user_id |   month    | login_day  | s_active | e_active
---------+------------+------------+----------+----------
     41 | 2021-09-01 | 2021-09-04 |        1 |        1
     41 | 2021-09-01 | 2021-09-20 |        1 |        1
     41 | 2021-10-01 | 2021-10-11 |        1 |        1
     41 | 2021-10-01 | 2021-10-27 |        1 |        1
     41 | 2021-11-01 | 2021-11-13 |        1 |        1
     41 | 2021-11-01 | 2021-11-25 |        1 |        1
     41 | 2021-12-01 | 2021-12-04 |        1 |        0
     41 | 2021-12-01 | 2021-12-05 |        0 |        1
     41 | 2021-12-01 | 2021-12-09 |        1 |        1
     41 | 2021-12-01 | 2021-12-23 |        1 |        1
     41 | 2021-12-01 | 2021-12-28 |        1 |        1
     41 | 2022-01-01 | 2022-01-15 |        1 |        1
     41 | 2022-02-01 | 2022-02-14 |        1 |        1
     41 | 2022-03-01 | 2022-03-10 |        1 |        1
     41 | 2022-03-01 | 2022-03-23 |        1 |        1
     41 | 2022-04-01 |            |        0 |        0
     41 | 2022-05-01 |            |        0 |        0
     41 | 2022-06-01 |            |        0 |        0
     41 | 2022-07-01 |            |        0 |        0
     41 | 2022-08-01 | 2022-08-15 |        1 |        1
     41 | 2022-08-01 | 2022-08-18 |        1 |        1
(21 rows)
```

The output shows that all the acitvity periods last only a single day except the dates `2021-12-04` and `2021-12-05`. The goal is to group these two rexords in a single record.

Next, we want to keep only the records with NULL values in the  `login_day`, (They represent months of no activity) and all the records that have one in `s_active` OR in `e_active`.

To have a better understanding of this filtering let's play with a simple toy example.

```SQL
CREATE VIEW toy AS
SELECT 1 AS user_id
     , '2021-09-01'::DATE AS month
     , '2021-09-01'::DATE AS login_day
UNION ALL
SELECT 1, '2021-09-01'::DATE, '2021-09-02'::DATE
UNION ALL
SELECT 1, '2021-09-01'::DATE, '2021-09-03'::DATE
UNION ALL
SELECT 1, '2021-09-01'::DATE, '2021-09-04'::DATE  
UNION ALL
SELECT 1, '2021-09-01'::DATE, '2021-09-15'::DATE
UNION ALL
SELECT 1, '2021-09-01'::DATE, '2021-09-30'::DATE
UNION ALL
SELECT 1, '2021-10-01'::DATE, '2021-10-30'::DATE
UNION ALL
SELECT 1, '2021-11-01'::DATE, NULL
UNION ALL
SELECT 1, '2021-12-01'::DATE, NULL;
```

```console
user_id |   month    | login_day
---------+------------+------------
      1 | 2021-09-01 | 2021-09-01
      1 | 2021-09-01 | 2021-09-02
      1 | 2021-09-01 | 2021-09-03
      1 | 2021-09-01 | 2021-09-04
      1 | 2021-09-01 | 2021-09-15
      1 | 2021-09-01 | 2021-09-30
      1 | 2021-10-01 | 2021-10-30
      1 | 2021-11-01 |
      1 | 2021-12-01 |
(9 rows)
```

Now let's try the following snippet of code:

```SQL
WITH user_log AS (
  SELECT user_id
       , month
       , login_day
       , CASE WHEN LAG(month,1) OVER (ORDER BY user_id, login_day) = month
              THEN CASE WHEN login_day - (LAG(login_day,1) OVER (ORDER BY user_id, login_day)) > 1
                        THEN 1 -- the user did not login the previous day
                        ELSE 0 -- the user login the previous day
                   END
              ELSE CASE WHEN login_day IS NULL
                        THEN 0 -- month with no activity
                        ELSE 1 -- first day of the month
                   END
         END AS s_active
    FROM toy
)
SELECT x.*
     , CASE WHEN LEAD(month,1) OVER (ORDER BY user_id, login_day) = month
            THEN CASE WHEN LEAD(s_active,1) OVER (ORDER BY user_id, login_day) = 1
                      THEN 1 -- the following day is not active, end of active
                      ELSE 0 -- the following day is active
                 END
            ELSE CASE WHEN login_day IS NULL
                      THEN 0 -- month with no activity
                      ELSE 1 -- the last day of activity in this month
                 END
       END AS e_active
  FROM user_log x
 ORDER BY user_id, month, login_day;
```

```console
user_id |   month    | login_day  | s_active | e_active
--------+------------+------------+----------+----------
      1 | 2021-09-01 | 2021-09-01 |        1 |        0 <-- first       *
      1 | 2021-09-01 | 2021-09-02 |        0 |        0
      1 | 2021-09-01 | 2021-09-03 |        0 |        0
      1 | 2021-09-01 | 2021-09-04 |        0 |        1 <-- last         *
                      ---------------------------------
      1 | 2021-09-01 | 2021-09-15 |        1 |        1 <-- first, last  *
                      ---------------------------------
      1 | 2021-09-01 | 2021-09-30 |        1 |        1 <-- first, last  *
      -----------------------------------------------------------------
      1 | 2021-10-01 | 2021-10-30 |        1 |        1 <-- first, last  *
      -----------------------------------------------------------------
      1 | 2021-11-01 |            |        0 |        0   NO ACTIVITY    *
      -----------------------------------------------------------------
      1 | 2021-12-01 |            |        0 |        0   NO ACTIVITY    *
(9 rows)
```

Now let's keep only the records indicated above.

```SQL
WITH user_log AS (
  SELECT user_id
       , month
       , login_day
       , CASE WHEN LAG(month,1) OVER (ORDER BY user_id, login_day) = month
              THEN CASE WHEN login_day - (LAG(login_day,1) OVER (ORDER BY user_id, login_day)) > 1
                        THEN 1 -- the user did not login the previous day
                        ELSE 0 -- the user login the previous day
                   END
              ELSE CASE WHEN login_day IS NULL
                        THEN 0 -- month with no activity
                        ELSE 1 -- first day of the month
                   END
         END AS s_active
    FROM toy
),
log_table AS (
  SELECT x.*
       , CASE WHEN LEAD(month,1) OVER (ORDER BY user_id, login_day) = month
              THEN CASE WHEN LEAD(s_active,1) OVER (ORDER BY user_id, login_day) = 1
                        THEN 1 -- the following day is not active, end of active
                        ELSE 0 -- the following day is active
                   END
              ELSE CASE WHEN login_day IS NULL
                        THEN 0 -- month with no activity
                        ELSE 1 -- the last day of activity in this month
                   END
         END AS e_active
    FROM user_log x
)
SELECT *
  FROM log_table
 WHERE login_day IS NULL OR (s_active = 1 OR e_active = 1)
 ORDER BY user_id, month, login_day;
```

```console
user_id |   month    | login_day  | s_active | e_active
---------+------------+------------+----------+----------
      1 | 2021-09-01 | 2021-09-01 |        1 |        0  <---+
                                                             |
      1 | 2021-09-01 | 2021-09-04 |        0 |        1  ----+
      1 | 2021-09-01 | 2021-09-15 |        1 |        1
      1 | 2021-09-01 | 2021-09-30 |        1 |        1
      1 | 2021-10-01 | 2021-10-30 |        1 |        1
      1 | 2021-11-01 |            |        0 |        0
      1 | 2021-12-01 |            |        0 |        0
(7 rows)
```

Next, we want to include the ending date of the activity period in all the rows where the `s_active` is equal to `1`.

```SQL
WITH user_log AS (
  SELECT user_id
       , month
       , login_day
       , CASE WHEN LAG(month,1) OVER (ORDER BY user_id, login_day) = month
              THEN CASE WHEN login_day - (LAG(login_day,1) OVER (ORDER BY user_id, login_day)) > 1
                        THEN 1 -- the user did not login the previous day
                        ELSE 0 -- the user login the previous day
                   END
              ELSE CASE WHEN login_day IS NULL
                        THEN 0 -- month with no activity
                        ELSE 1 -- first day of the month
                   END
         END AS s_active
    FROM toy
),
log_table AS (
  SELECT x.*
       , CASE WHEN LEAD(month,1) OVER (ORDER BY user_id, login_day) = month
              THEN CASE WHEN LEAD(s_active,1) OVER (ORDER BY user_id, login_day) = 1
                        THEN 1 -- the following day is not active, end of active
                        ELSE 0 -- the following day is active
                   END
              ELSE CASE WHEN login_day IS NULL
                        THEN 0 -- month with no activity
                        ELSE 1 -- the last day of activity in this month
                   END
         END AS e_active
    FROM user_log x
),
log_table2 AS (
  SELECT *
    FROM log_table
   WHERE login_day IS NULL OR (s_active = 1 OR e_active = 1)
)
SELECT user_id
      , month
      , login_day AS login_start
      , CASE WHEN s_active = e_active
             THEN login_day
             ELSE CASE WHEN login_day IS NOT NULL AND
                            LEAD(s_active,1) OVER (ORDER BY user_id, login_day) = 0 AND
                            LEAD(e_active,1) OVER (ORDER BY user_id, login_day) = 1
                       THEN LEAD(login_day,1) OVER (ORDER BY user_id, login_day)
                       ELSE NULL
                  END
        END AS login_end
  FROM log_table2
 ORDER BY user_id, month, login_start;
```

```console
user_id |   month    | login_start | login_end
---------+------------+-------------+------------
      1 | 2021-09-01 | 2021-09-01  | 2021-09-04
      1 | 2021-09-01 | 2021-09-04  |            <--- Remove
      1 | 2021-09-01 | 2021-09-15  | 2021-09-15
      1 | 2021-09-01 | 2021-09-30  | 2021-09-30
      1 | 2021-10-01 | 2021-10-30  | 2021-10-30
      1 | 2021-11-01 |             |
      1 | 2021-12-01 |             |
```

Next, remove the rows with no `login_end`.

```SQL
WITH user_log AS (
  SELECT user_id
       , month
       , login_day
       , CASE WHEN LAG(month,1) OVER (ORDER BY user_id, login_day) = month
              THEN CASE WHEN login_day - (LAG(login_day,1) OVER (ORDER BY user_id, login_day)) > 1
                        THEN 1 -- the user did not login the previous day
                        ELSE 0 -- the user login the previous day
                   END
              ELSE CASE WHEN login_day IS NULL
                        THEN 0 -- month with no activity
                        ELSE 1 -- first day of the month
                   END
         END AS s_active
    FROM toy
),
log_table AS (
  SELECT x.*
       , CASE WHEN LEAD(month,1) OVER (ORDER BY user_id, login_day) = month
              THEN CASE WHEN LEAD(s_active,1) OVER (ORDER BY user_id, login_day) = 1
                        THEN 1 -- the following day is not active, end of active
                        ELSE 0 -- the following day is active
                   END
              ELSE CASE WHEN login_day IS NULL
                        THEN 0 -- month with no activity
                        ELSE 1 -- the last day of activity in this month
                   END
         END AS e_active
    FROM user_log x
),
log_table2 AS (
  SELECT *
    FROM log_table
   WHERE login_day IS NULL OR (s_active = 1 OR e_active = 1)
),
log_table3 AS (
  SELECT user_id
        , month
        , login_day AS login_start
        , CASE WHEN s_active = e_active
               THEN login_day
               ELSE CASE WHEN login_day IS NOT NULL AND
                              LEAD(s_active,1) OVER (ORDER BY user_id, login_day) = 0 AND
                              LEAD(e_active,1) OVER (ORDER BY user_id, login_day) = 1
                         THEN LEAD(login_day,1) OVER (ORDER BY user_id, login_day)
                         ELSE NULL
                    END
          END AS login_end
    FROM log_table2
)
SELECT *
  FROM log_table3
 WHERE (login_start IS NOT NULL AND login_end iS NOT NULL) OR
       (login_start IS NULL AND login_end IS NULL)
 ORDER BY user_id, month, login_start;
```

```console
user_id |   month    | login_start | login_end
--------+------------+-------------+------------
      1 | 2021-09-01 | 2021-09-01  | 2021-09-04
      1 | 2021-09-01 | 2021-09-15  | 2021-09-15
      1 | 2021-09-01 | 2021-09-30  | 2021-09-30
      1 | 2021-10-01 | 2021-10-30  | 2021-10-30
      1 | 2021-11-01 |             |
      1 | 2021-12-01 |             |
(6 rows)
```

The final step is to include the `churn_start` and `churn_end` date and the duration of the `activity` period and `no_activity` period.

```SQL
WITH user_log AS (
  SELECT user_id
       , month
       , login_day
       , CASE WHEN LAG(month,1) OVER (ORDER BY user_id, login_day) = month
              THEN CASE WHEN login_day - (LAG(login_day,1) OVER (ORDER BY user_id, login_day)) > 1
                        THEN 1 -- the user did not login the previous day
                        ELSE 0 -- the user login the previous day
                   END
              ELSE CASE WHEN login_day IS NULL
                        THEN 0 -- month with no activity
                        ELSE 1 -- first day of the month
                   END
         END AS s_active
    FROM toy
),
log_table AS (
  SELECT x.*
       , CASE WHEN LEAD(month,1) OVER (ORDER BY user_id, login_day) = month
              THEN CASE WHEN LEAD(s_active,1) OVER (ORDER BY user_id, login_day) = 1
                        THEN 1 -- the following day is not active, end of active
                        ELSE 0 -- the following day is active
                   END
              ELSE CASE WHEN login_day IS NULL
                        THEN 0 -- month with no activity
                        ELSE 1 -- the last day of activity in this month
                   END
         END AS e_active
    FROM user_log x
),
log_table2 AS (
  SELECT *
    FROM log_table
   WHERE login_day IS NULL OR (s_active = 1 OR e_active = 1)
),
log_table3 AS (
  SELECT user_id
        , month
        , login_day AS login_start
        , CASE WHEN s_active = e_active
               THEN login_day
               ELSE CASE WHEN login_day IS NOT NULL AND
                              LEAD(s_active,1) OVER (ORDER BY user_id, login_day) = 0 AND
                              LEAD(e_active,1) OVER (ORDER BY user_id, login_day) = 1
                         THEN LEAD(login_day,1) OVER (ORDER BY user_id, login_day)
                         ELSE NULL
                    END
          END AS login_end
    FROM log_table2
),
log_table4 AS (
  SELECT *
    FROM log_table3
   WHERE (login_start IS NOT NULL AND login_end iS NOT NULL) OR
         (login_start IS NULL AND login_end IS NULL)
)
SELECT  lt.*
      , CASE WHEN login_start IS NULL AND login_end IS NULL
             THEN month
             ELSE CASE WHEN login_end != (month + INTERVAL '1 month')::DATE - 1
                       THEN login_end + 1
                       ELSE NULL
                  END
        END AS churn_start
      , CASE WHEN login_start IS NULL AND login_end IS NULL
             THEN (month + INTERVAL '1 month')::DATE - 1
             ELSE CASE WHEN LEAD(month,1) OVER (ORDER BY user_id, login_start) = month
                       THEN LEAD(login_start,1) OVER (ORDER BY user_id, login_start) - 1
                       ELSE CASE WHEN login_end != (month + INTERVAL '1 month')::DATE - 1
                                 THEN (month + INTERVAL '1 month')::DATE - 1
                                 ELSE NULL
                            END
                  END
        END AS churn_end
  FROM log_table4 lt
 ORDER BY user_id, month, login_start;
```

```console
user_id |   month    | login_start | login_end  | churn_start | churn_end
--------+------------+-------------+------------+-------------+------------
      1 | 2021-09-01 | 2021-09-01  | 2021-09-04 | 2021-09-05  | 2021-09-14
      1 | 2021-09-01 | 2021-09-15  | 2021-09-15 | 2021-09-16  | 2021-09-29
      1 | 2021-09-01 | 2021-09-30  | 2021-09-30 |             |
      1 | 2021-10-01 | 2021-10-30  | 2021-10-30 | 2021-10-31  | 2021-10-31
      1 | 2021-11-01 |             |            | 2021-11-01  | 2021-11-30
      1 | 2021-12-01 |             |            | 2021-12-01  | 2021-12-31
(6 rows)
```

Let's test the solution to the logins table:

```SQL
WITH first_activity AS (
  SELECT  user_id
        , DATE_TRUNC('month',MIN(day))::DATE AS month
    FROM logins
   GROUP BY 1
),
calendar AS (
  SELECT s.month::DATE AS month
    FROM GENERATE_SERIES((SELECT DATE_TRUNC('month',MIN(day))::DATE FROM logins),
                         (SELECT DATE_TRUNC('month',MAX(day))::DATE FROM logins),
                          INTERVAL '1 month') AS s(month)
),
user_calendar AS (
  SELECT f.user_id AS user_id
       , c.month AS month
    FROM first_activity f
   INNER JOIN calendar c
      ON f.month <= c.month
),
user_log_day_calendar AS (
  SELECT DISTINCT
         uc.user_id AS user_id
       , uc.month AS month
       , l.day::DATE AS login_day
    FROM user_calendar uc
    LEFT JOIN logins l
      ON uc.user_id = l.user_id AND
         uc.month = DATE_TRUNC('month',l.day)::DATE
),
user_log AS (
  SELECT user_id
       , month
       , login_day
       , CASE WHEN LAG(month,1) OVER (ORDER BY user_id, login_day) = month
              THEN CASE WHEN login_day - (LAG(login_day,1) OVER (ORDER BY user_id, login_day)) > 1
                        THEN 1 -- the user did not login the previous day
                        ELSE 0 -- the user login the previous day
                   END
              ELSE CASE WHEN login_day IS NULL
                        THEN 0 -- month with no activity
                        ELSE 1 -- first day of the month
                   END
         END AS s_active
    FROM user_log_day_calendar
),
log_table AS (
  SELECT x.*
       , CASE WHEN LEAD(month,1) OVER (ORDER BY user_id, login_day) = month
              THEN CASE WHEN LEAD(s_active,1) OVER (ORDER BY user_id, login_day) = 1
                        THEN 1 -- the following day is not active, end of active
                        ELSE 0 -- the following day is active
                   END
              ELSE CASE WHEN login_day IS NULL
                        THEN 0 -- month with no activity
                        ELSE 1 -- the last day of activity in this month
                   END
         END AS e_active
    FROM user_log x
),
log_table2 AS (
  SELECT *
    FROM log_table
   WHERE login_day IS NULL OR (s_active = 1 OR e_active = 1)
),
log_table3 AS (
  SELECT user_id
        , month
        , login_day AS login_start
        , CASE WHEN s_active = e_active
               THEN login_day
               ELSE CASE WHEN login_day IS NOT NULL AND
                              LEAD(s_active,1) OVER (ORDER BY user_id, login_day) = 0 AND
                              LEAD(e_active,1) OVER (ORDER BY user_id, login_day) = 1
                         THEN LEAD(login_day,1) OVER (ORDER BY user_id, login_day)
                         ELSE NULL
                    END
          END AS login_end
    FROM log_table2
),
log_table4 AS (
  SELECT *
    FROM log_table3
   WHERE (login_start IS NOT NULL AND login_end iS NOT NULL) OR
         (login_start IS NULL AND login_end IS NULL)
)
SELECT  lt.*
      , CASE WHEN login_start IS NULL AND login_end IS NULL
             THEN month
             ELSE CASE WHEN login_end != (month + INTERVAL '1 month')::DATE - 1
                       THEN login_end + 1
                       ELSE NULL
                  END
        END AS churn_start
      , CASE WHEN login_start IS NULL AND login_end IS NULL
             THEN (month + INTERVAL '1 month')::DATE - 1
             ELSE CASE WHEN LEAD(month,1) OVER (ORDER BY user_id, login_start) = month
                       THEN LEAD(login_start,1) OVER (ORDER BY user_id, login_start) - 1
                       ELSE CASE WHEN login_end != (month + INTERVAL '1 month')::DATE - 1
                                 THEN (month + INTERVAL '1 month')::DATE - 1
                                 ELSE NULL
                            END
                  END
        END AS churn_end
  FROM log_table4 lt
 ORDER BY user_id, month, login_start;
```

```console
user_id |   month    | login_start | login_end  | churn_start | churn_end
--------+------------+-------------+------------+-------------+------------
     41 | 2021-09-01 | 2021-09-04  | 2021-09-04 | 2021-09-05  | 2021-09-19
     41 | 2021-09-01 | 2021-09-20  | 2021-09-20 | 2021-09-21  | 2021-09-30
     ---------------------------------------------------------------------
                      INCLUDE ->     2021-10-01   2021-10-10           
     41 | 2021-10-01 | 2021-10-11  | 2021-10-11 | 2021-10-12  | 2021-10-26
     41 | 2021-10-01 | 2021-10-27  | 2021-10-27 | 2021-10-28  | 2021-10-31
     ---------------------------------------------------------------------
                       INCLUDE ->    2021-11-01   2021-11-12
     41 | 2021-11-01 | 2021-11-13  | 2021-11-13 | 2021-11-14  | 2021-11-24
     41 | 2021-11-01 | 2021-11-25  | 2021-11-25 | 2021-11-26  | 2021-11-30
     ---------------------------------------------------------------------
                       INCLUDE ->    2021-12-01   2021-12-03
     41 | 2021-12-01 | 2021-12-04  | 2021-12-05 | 2021-12-06  | 2021-12-08
     41 | 2021-12-01 | 2021-12-09  | 2021-12-09 | 2021-12-10  | 2021-12-22
     41 | 2021-12-01 | 2021-12-23  | 2021-12-23 | 2021-12-24  | 2021-12-27
     41 | 2021-12-01 | 2021-12-28  | 2021-12-28 | 2021-12-29  | 2021-12-31
     ---------------------------------------------------------------------
                       INCLUDE ->    2021-01-01   2021-01-14
     41 | 2022-01-01 | 2022-01-15  | 2022-01-15 | 2022-01-16  | 2022-01-31
     ---------------------------------------------------------------------
                       INCLUDE ->    2022-02-01   2022-02-13
     41 | 2022-02-01 | 2022-02-14  | 2022-02-14 | 2022-02-15  | 2022-02-28
     ---------------------------------------------------------------------
                       INCLUDE ->    2022-03-01   2022-03-09
     41 | 2022-03-01 | 2022-03-10  | 2022-03-10 | 2022-03-11  | 2022-03-22
     41 | 2022-03-01 | 2022-03-23  | 2022-03-23 | 2022-03-24  | 2022-03-31
     ---------------------------------------------------------------------
     41 | 2022-04-01 |             |            | 2022-04-01  | 2022-04-30
     41 | 2022-05-01 |             |            | 2022-05-01  | 2022-05-31
     41 | 2022-06-01 |             |            | 2022-06-01  | 2022-06-30
     41 | 2022-07-01 |             |            | 2022-07-01  | 2022-07-31
     ---------------------------------------------------------------------
                       INCLUDE ->    2022-08-01   2022-08-14
     41 | 2022-08-01 | 2022-08-15  | 2022-08-15 | 2022-08-16  | 2022-08-17
     41 | 2022-08-01 | 2022-08-18  | 2022-08-18 | 2022-08-19  | 2022-08-31
(20 rows)
```

The output shows that rows are missing. The rows missing are those indicating the start of a churn period at the beginning of the month.

A possible solution is to duplicate the months user calendar in order to include the missing row.

Take for example, user `41`:

```SQL
SELECT *
  FROM user_calendar, GENERATE_SERIES(1,2) s(i)
 WHERE user_id = 41;
```

```console
user_id |   month    | i
--------+------------+---
     41 | 2021-09-01 | 1
     41 | 2021-09-01 | 2
     41 | 2021-10-01 | 1
     41 | 2021-10-01 | 2
     41 | 2021-11-01 | 1
     41 | 2021-11-01 | 2
     41 | 2021-12-01 | 1
     41 | 2021-12-01 | 2
     41 | 2022-01-01 | 1
     41 | 2022-01-01 | 2
     41 | 2022-02-01 | 1
     41 | 2022-02-01 | 2
     41 | 2022-03-01 | 1
     41 | 2022-03-01 | 2
     41 | 2022-04-01 | 1
     41 | 2022-04-01 | 2
     41 | 2022-05-01 | 1
     41 | 2022-05-01 | 2
     41 | 2022-06-01 | 1
     41 | 2022-06-01 | 2
     41 | 2022-07-01 | 1
     41 | 2022-07-01 | 2
     41 | 2022-08-01 | 1
     41 | 2022-08-01 | 2
(24 rows)
```

The last step is to join the duplicate calendar table with the `user_log_calendar` table:

```SQL
...
),
log_table4 AS (
  SELECT *
    FROM log_table3
   WHERE (login_start IS NOT NULL AND login_end iS NOT NULL) OR
         (login_start IS NULL AND login_end IS NULL)
),
log_table5 AS (
  SELECT  lt.*
        , CASE WHEN login_start IS NULL AND login_end IS NULL
               THEN month
               ELSE CASE WHEN login_end != (month + INTERVAL '1 month')::DATE - 1
                         THEN login_end + 1
                         ELSE NULL
                    END
          END AS churn_start
        , CASE WHEN login_start IS NULL AND login_end IS NULL
               THEN (month + INTERVAL '1 month')::DATE - 1
               ELSE CASE WHEN LEAD(month,1) OVER (ORDER BY user_id, month, login_start) = month
                         THEN LEAD(login_start,1) OVER (ORDER BY user_id, month, login_start) - 1
                         ELSE CASE WHEN login_end != (month + INTERVAL '1 month')::DATE - 1
                                   THEN (month + INTERVAL '1 month')::DATE - 1
                                   ELSE NULL
                              END
                    END
          END AS churn_end
    FROM log_table4 lt
),
user_log_calendar AS (
  SELECT  user_id
        , month
        , login_start
        , login_end
        , churn_start
        , churn_end
        , CASE WHEN LAG(month,1) OVER (ORDER BY user_id, month, login_start) > month
               THEN 0
               ELSE CASE WHEN LAG(month,1) OVER (ORDER BY user_id, month, login_start)!= month AND login_start > month -- the login is not the first day of the month
                         THEN 1
                         ELSE 0
                    END
          END AS churn_1stm_period
    FROM log_table5
),
user_calendar_dup AS (
  SELECT  user_id
        , month
        , s.i
    FROM user_calendar, GENERATE_SERIES(1,2) s(i)
),
logins_period AS (
  SELECT  ROW_NUMBER() OVER (PARTITION BY ulc.user_id
                             ORDER BY ulc.month, churn_1stm_period DESC, ud.i, ulc.login_start )
          AS period_id
        , ulc.user_id
        , ulc.month
        , CASE WHEN ulc.churn_1stm_period = 1
               THEN CASE WHEN ud.i = 1
                         THEN NULL
                         ELSE ulc.login_start
                    END
               ELSE ulc.login_start
          END AS login_start
        , CASE WHEN ulc.churn_1stm_period = 1
               THEN CASE WHEN ud.i = 1
                         THEN NULL
                         ELSE ulc.login_end
                    END
               ELSE ulc.login_end
          END AS login_end
        , CASE WHEN ulc.churn_1stm_period = 1
               THEN CASE WHEN ud.i = 1
                         THEN ulc.month
                         ELSE ulc.churn_start
                    END
               ELSE ulc.churn_start
          END AS churn_start
        , CASE WHEN ulc.churn_1stm_period = 1
               THEN CASE WHEN ud.i = 1
                         THEN login_start - 1
                         ELSE ulc.churn_end
                    END
               ELSE ulc.churn_end
          END AS churn_end
    FROM user_log_calendar ulc
   INNER JOIN user_calendar_dup ud
      ON ulc.user_id = ud.user_id AND ulc.month = ud.month
   WHERE ((ud.i = 1) OR (ud.i = 2 AND ulc.churn_1stm_period = 1))
)

SELECT *
FROM logins_period
WHERE user_id = 41
ORDER BY period_id;
```

In the code above the column `churn_1stm_period` in the CTE `user_log_calendar` indicates:

- `churn_1stm_period`: A flag column with a value of `1` or `0`. The value `1` indicates that this `login_period` is preceded by a churn period starting the first day of the month, otherwise the value zero indicates that this `login_period` is preceded by a churn period not starting at the beginning of the month.

The combination of values in the `i` and `churn_1stm_period` columns are used to add the additional row in the output table.

```console
period_id | user_id |   month    | login_start | login_end  | churn_start | churn_end  | churn_1stm_period | i
----------+---------+------------+-------------+------------+-------------+------------+-------------------+---
        1 |      41 | 2021-09-01 | 2021-09-04  | 2021-09-04 | 2021-09-05  | 2021-09-19 |                 0 | 1
        2 |      41 | 2021-09-01 | 2021-09-20  | 2021-09-20 | 2021-09-21  | 2021-09-30 |                 0 | 1
        3 |      41 | 2021-10-01 |             |            | 2021-10-01  | 2021-10-10 |                 1 | 1
        4 |      41 | 2021-10-01 | 2021-10-11  | 2021-10-11 | 2021-10-12  | 2021-10-26 |                 1 | 2
        5 |      41 | 2021-10-01 | 2021-10-27  | 2021-10-27 | 2021-10-28  | 2021-10-31 |                 0 | 1
        6 |      41 | 2021-11-01 |             |            | 2021-11-01  | 2021-11-12 |                 1 | 1
        7 |      41 | 2021-11-01 | 2021-11-13  | 2021-11-13 | 2021-11-14  | 2021-11-24 |                 1 | 2
        8 |      41 | 2021-11-01 | 2021-11-25  | 2021-11-25 | 2021-11-26  | 2021-11-30 |                 0 | 1
        9 |      41 | 2021-12-01 |             |            | 2021-12-01  | 2021-12-03 |                 1 | 1
       10 |      41 | 2021-12-01 | 2021-12-04  | 2021-12-05 | 2021-12-06  | 2021-12-08 |                 1 | 2
       11 |      41 | 2021-12-01 | 2021-12-09  | 2021-12-09 | 2021-12-10  | 2021-12-22 |                 0 | 1
       12 |      41 | 2021-12-01 | 2021-12-23  | 2021-12-23 | 2021-12-24  | 2021-12-27 |                 0 | 1
       13 |      41 | 2021-12-01 | 2021-12-28  | 2021-12-28 | 2021-12-29  | 2021-12-31 |                 0 | 1
       14 |      41 | 2022-01-01 |             |            | 2022-01-01  | 2022-01-14 |                 1 | 1
       15 |      41 | 2022-01-01 | 2022-01-15  | 2022-01-15 | 2022-01-16  | 2022-01-31 |                 1 | 2
       16 |      41 | 2022-02-01 |             |            | 2022-02-01  | 2022-02-13 |                 1 | 1
       17 |      41 | 2022-02-01 | 2022-02-14  | 2022-02-14 | 2022-02-15  | 2022-02-28 |                 1 | 2
       18 |      41 | 2022-03-01 |             |            | 2022-03-01  | 2022-03-09 |                 1 | 1
       19 |      41 | 2022-03-01 | 2022-03-10  | 2022-03-10 | 2022-03-11  | 2022-03-22 |                 1 | 2
       20 |      41 | 2022-03-01 | 2022-03-23  | 2022-03-23 | 2022-03-24  | 2022-03-31 |                 0 | 1
       21 |      41 | 2022-04-01 |             |            | 2022-04-01  | 2022-04-30 |                 0 | 1
       22 |      41 | 2022-05-01 |             |            | 2022-05-01  | 2022-05-31 |                 0 | 1
       23 |      41 | 2022-06-01 |             |            | 2022-06-01  | 2022-06-30 |                 0 | 1
       24 |      41 | 2022-07-01 |             |            | 2022-07-01  | 2022-07-31 |                 0 | 1
       25 |      41 | 2022-08-01 |             |            | 2022-08-01  | 2022-08-14 |                 1 | 1
       26 |      41 | 2022-08-01 | 2022-08-15  | 2022-08-15 | 2022-08-16  | 2022-08-17 |                 1 | 2
       27 |      41 | 2022-08-01 | 2022-08-18  | 2022-08-18 | 2022-08-19  | 2022-08-31 |                 0 | 1
(27 rows)
```

The combination of values in the last columns indicates if a row is a period of the beginning of the month with a churned period, (`1,1`) or an activity period (`1,2`). The remaining rows have value `1` in the i column. The total number of periods is 27.



## Problem 2


Next, compute the number of days in the activity and no_activity periods. In the output table these periods are indicated as `login` and `churn`.

```SQL
...
),
logins_period AS (
  SELECT  ROW_NUMBER() OVER (PARTITION BY ulc.user_id
                             ORDER BY ulc.month, churn_1stm_period DESC, ud.i, ulc.login_start )
          AS period_id
        , ulc.user_id
        , ulc.month
        , CASE WHEN ulc.churn_1stm_period = 1
               THEN CASE WHEN ud.i = 1
                         THEN NULL
                         ELSE ulc.login_start
                    END
               ELSE ulc.login_start
          END AS login_start
        , CASE WHEN ulc.churn_1stm_period = 1
               THEN CASE WHEN ud.i = 1
                         THEN NULL
                         ELSE ulc.login_end
                    END
               ELSE ulc.login_end
          END AS login_end
        , CASE WHEN ulc.churn_1stm_period = 1
               THEN CASE WHEN ud.i = 1
                         THEN ulc.month
                         ELSE ulc.churn_start
                    END
               ELSE ulc.churn_start
          END AS churn_start
        , CASE WHEN ulc.churn_1stm_period = 1
               THEN CASE WHEN ud.i = 1
                         THEN login_start - 1
                         ELSE ulc.churn_end
                    END
               ELSE ulc.churn_end
          END AS churn_end
    FROM user_log_calendar ulc
   INNER JOIN user_calendar_dup ud
      ON ulc.user_id = ud.user_id AND ulc.month = ud.month
   WHERE ((ud.i = 1) OR (ud.i = 2 AND ulc.churn_1stm_period = 1))
)

SELECT  period_id
      , user_id
      , month
      , login_start
      , login_end
      , churn_start
      , churn_end
      , COALESCE(login_end - login_start + 1,0) AS login_days_cnt
      , COALESCE(churn_end - churn_start + 1,0) AS churn_days_cnt
  FROM logins_period
 WHERE user_id = 41
 ORDER BY period_id;
```


```console
period_id | user_id |   month    | login_start | login_end  | churn_start | churn_end  | login_days_cnt | churn_days_cnt
-----------+---------+------------+-------------+------------+-------------+------------+----------------+----------------
        1 |      41 | 2021-09-01 | 2021-09-04  | 2021-09-04 | 2021-09-05  | 2021-09-19 |              1 |             15
        2 |      41 | 2021-09-01 | 2021-09-20  | 2021-09-20 | 2021-09-21  | 2021-09-30 |              1 |             10
        3 |      41 | 2021-10-01 |             |            | 2021-10-01  | 2021-10-10 |              0 |             10
        4 |      41 | 2021-10-01 | 2021-10-11  | 2021-10-11 | 2021-10-12  | 2021-10-26 |              1 |             15
        5 |      41 | 2021-10-01 | 2021-10-27  | 2021-10-27 | 2021-10-28  | 2021-10-31 |              1 |              4
        6 |      41 | 2021-11-01 |             |            | 2021-11-01  | 2021-11-12 |              0 |             12
        7 |      41 | 2021-11-01 | 2021-11-13  | 2021-11-13 | 2021-11-14  | 2021-11-24 |              1 |             11
        8 |      41 | 2021-11-01 | 2021-11-25  | 2021-11-25 | 2021-11-26  | 2021-11-30 |              1 |              5
        9 |      41 | 2021-12-01 |             |            | 2021-12-01  | 2021-12-03 |              0 |              3
       10 |      41 | 2021-12-01 | 2021-12-04  | 2021-12-05 | 2021-12-06  | 2021-12-08 |              2 |              3
       11 |      41 | 2021-12-01 | 2021-12-09  | 2021-12-09 | 2021-12-10  | 2021-12-22 |              1 |             13
       12 |      41 | 2021-12-01 | 2021-12-23  | 2021-12-23 | 2021-12-24  | 2021-12-27 |              1 |              4
       13 |      41 | 2021-12-01 | 2021-12-28  | 2021-12-28 | 2021-12-29  | 2021-12-31 |              1 |              3
       14 |      41 | 2022-01-01 |             |            | 2022-01-01  | 2022-01-14 |              0 |             14
       15 |      41 | 2022-01-01 | 2022-01-15  | 2022-01-15 | 2022-01-16  | 2022-01-31 |              1 |             16
       16 |      41 | 2022-02-01 |             |            | 2022-02-01  | 2022-02-13 |              0 |             13
       17 |      41 | 2022-02-01 | 2022-02-14  | 2022-02-14 | 2022-02-15  | 2022-02-28 |              1 |             14
       18 |      41 | 2022-03-01 |             |            | 2022-03-01  | 2022-03-09 |              0 |              9
       19 |      41 | 2022-03-01 | 2022-03-10  | 2022-03-10 | 2022-03-11  | 2022-03-22 |              1 |             12
       20 |      41 | 2022-03-01 | 2022-03-23  | 2022-03-23 | 2022-03-24  | 2022-03-31 |              1 |              8
       21 |      41 | 2022-04-01 |             |            | 2022-04-01  | 2022-04-30 |              0 |             30
       22 |      41 | 2022-05-01 |             |            | 2022-05-01  | 2022-05-31 |              0 |             31
       23 |      41 | 2022-06-01 |             |            | 2022-06-01  | 2022-06-30 |              0 |             30
       24 |      41 | 2022-07-01 |             |            | 2022-07-01  | 2022-07-31 |              0 |             31
       25 |      41 | 2022-08-01 |             |            | 2022-08-01  | 2022-08-14 |              0 |             14
       26 |      41 | 2022-08-01 | 2022-08-15  | 2022-08-15 | 2022-08-16  | 2022-08-17 |              1 |              2
       27 |      41 | 2022-08-01 | 2022-08-18  | 2022-08-18 | 2022-08-19  | 2022-08-31 |              1 |             13
(27 rows)
```

Next, compute the number of activity and no_activity periods. Then compute the following statistics for the duration of an activity and no activity periods in a month:

- Number of login and churn periods
- Number of days a user login and a user has been not active
- Minimum and Maximum Period duration
- Average duration
- Population Standard deviation  

```SQL
),
logins_period_cnt AS (
  SELECT  period_id
        , user_id
        , month
        , login_start
        , login_end
        , churn_start
        , churn_end
        , COALESCE(login_end - login_start + 1,0) AS login_days_duration
        , COALESCE(churn_end - churn_start + 1,0) AS churn_days_duration
    FROM logins_period
)
SELECT  user_id
      , month
      , COUNT(login_start) AS login_periods_cnt
      , COUNT(churn_start) AS churn_periods_cnt
      , SUM(login_days_duration) AS login_days_cnt
      , SUM(churn_days_duration) AS churn_days_cnt
      , MIN(login_days_duration) AS min_login_duration
      , MAX(login_days_duration) AS max_login_duration
      , MIN(churn_days_duration) AS min_churn_duration
      , MAX(churn_days_duration) AS max_churn_duration
      , ROUND(AVG(login_days_duration),0) AS avg_login_duration
      , ROUND(AVG(churn_days_duration),0) AS avg_churn_duration
      , ROUND(STDDEV_POP(login_days_duration),0) AS std_p_login_duration
      , ROUND(STDDEV_POP(churn_days_duration),0) AS std_p_churn_duration
  FROM logins_period_cnt
 WHERE user_id = 41
 GROUP BY user_id, month
 ORDER BY user_id, month;
```


```console
user_id |   month    | login_periods_cnt | churn_periods_cnt | login_days_cnt | churn_days_cnt | min_login_duration | max_login_duration | min_churn_duration | max_churn_duration | avg_login_duration | avg_churn_duration | std_p_login_duration | std_p_churn_duration
--------+------------+-------------------+-------------------+----------------+----------------+--------------------+--------------------+--------------------+--------------------+--------------------+--------------------+----------------------+----------------------
     41 | 2021-09-01 |                 2 |                 2 |              2 |             25 |                  1 |                  1 |                 10 |                 15 |                  1 |                 13 |                    0 |                    3
     41 | 2021-10-01 |                 2 |                 3 |              2 |             29 |                  0 |                  1 |                  4 |                 15 |                  1 |                 10 |                    0 |                    4
     41 | 2021-11-01 |                 2 |                 3 |              2 |             28 |                  0 |                  1 |                  5 |                 12 |                  1 |                  9 |                    0 |                    3
     41 | 2021-12-01 |                 4 |                 5 |              5 |             26 |                  0 |                  2 |                  3 |                 13 |                  1 |                  5 |                    1 |                    4
     41 | 2022-01-01 |                 1 |                 2 |              1 |             30 |                  0 |                  1 |                 14 |                 16 |                  1 |                 15 |                    1 |                    1
     41 | 2022-02-01 |                 1 |                 2 |              1 |             27 |                  0 |                  1 |                 13 |                 14 |                  1 |                 14 |                    1 |                    1
     41 | 2022-03-01 |                 2 |                 3 |              2 |             29 |                  0 |                  1 |                  8 |                 12 |                  1 |                 10 |                    0 |                    2
     41 | 2022-04-01 |                 0 |                 1 |              0 |             30 |                  0 |                  0 |                 30 |                 30 |                  0 |                 30 |                    0 |                    0
     41 | 2022-05-01 |                 0 |                 1 |              0 |             31 |                  0 |                  0 |                 31 |                 31 |                  0 |                 31 |                    0 |                    0
     41 | 2022-06-01 |                 0 |                 1 |              0 |             30 |                  0 |                  0 |                 30 |                 30 |                  0 |                 30 |                    0 |                    0
     41 | 2022-07-01 |                 0 |                 1 |              0 |             31 |                  0 |                  0 |                 31 |                 31 |                  0 |                 31 |                    0 |                    0
     41 | 2022-08-01 |                 2 |                 3 |              2 |             29 |                  0 |                  1 |                  2 |                 14 |                  1 |                 10 |                    0 |                    5
(12 rows)
```
