# Acquisition Cohort Retention Analysis

Create a table to do an acquisition cohort analysis of `new active users` that logged in and shows the **percentage remaining users** from that `cohort` (i.e. `the first activity month period a new user logged in`) **logged after each month**.

The `period` of analysis can be `week, month, year or other`. In this case scenario, the period of analysis is a **month**.

The metric of analysis is called `Retention Rate` and can be calculated as follow:

```console
                  CE - CN
Retention Rate =  -------- * 100
                    CS
```

Where:
- **C<sub>S</sub>** : Number of users acquired in the period of the `first month activity`. It's basically the group of users who joined the platform in the fist month activity. This period of time is, therefore, the **subscription month** that defines the group of users in our cohort analysis. From now on we refer to this group as `first month activity users`. The `CS` stands for `Customer Counts Start`.
- **C<sub>E</sub>** : Number of users at the `end` of the `month`. In this case scenario, this number is the total count of users who had activity in the current month (`monthly active users`). From now on we refer to this group as `last month activity users`. The `CE` stands for `Customer Counts End`.
- **C<sub>N</sub>** : Number of `monthly active users` acquired after the `first month activity`. In this case scenario, this number is the total count of users who had activity in the current month but joined the platform after the first month activity of our cohort group.


Here's a simple retention rate calculation for the users subscribed in the period of `SEPTEMBER 2021` and logged in `DECEMBER 2021`. In this example:

- **C<sub>S</sub>**: Number of `new` users logged in `SEPTEMBER 2021`.
- **C<sub>E</sub>**: Number of users who logged in `DECEMBER 2021`
- **C<sub>N</sub>**: Number of users who logged in `DECEMBER 2021` but joined the platform after `SEPTEMBER 2021`.

```console

                                           3 MONTHS SINCE ACCOUNT CREATION     
                               |START     |<------------------------------>|  
                               |<-------->|                     |<-------->| END
                               |SEPTEMBER | OCTOBER  | NOVEMBER | DECEMBER |
----------------+-----------+  +----------+----------+----------+----------+
Cohort          | Cohort cnt|  |      MONTHS SINCE ACCOUNT CREATION        |
----------------+-----------+  +----------+----------+----------+----------+
SUBSCRIPTION MONTH             |    0     |    1     |     2    |    3     | Cohort
----------------------------+  +----------+----------+----------+----------+
                |           |  |customers |                     |customers | ACTIVE users
2021 SEPTEMBER  |   200     |  |  200     |                     | 180      | COUNT
----------------+-----------+  +----------+----------+          +----------+-> 220 - 40
                |           |             | customers|                             |    
2021 OCTOBER    |    40     |             |   40     |5----------------->40--------+     
----------------+-----------+             +----------+----------+         |     
                |           |                        | customers|---------+----+
2021 NOVEMBER   |    20     |                        |    20    |15            |
----------------+-----------+                        +----------+----------+   |
                |           |                                   | customers|---+
2021 DECEMBER   |    10     |                                   |    10    |10
----------------+-----------+                                   +----------+
```

In this example, the cohort group is the set of users who subscribed during the period of `2021 SEPTEMBER`. So we started with 200 customers.

Next, `40` customers joined the platform and logged during the period of `DECEMBER`. This set of users can be broken down as follow:

- `5` subscribers from the cohort group of `OCTOBER`
- `15` subscribers from the cohort group of `NOVEMBER`
- `10` subscribers from the cohort group of `DECEMBER`

Lastly, the number of active users in the current month of `DECEMBER` is `220`.

At the end of the period you have therefore, **180** customers from your cohort group:

```console
Cohort SEPTEMBER 2021      220 - 40           180
Retention Rate DECEMBER =  -------- * 100 = ------- % = 90 %
                              200              2
```

So you lost 20 customers from your cohort group and gained 40 customers who joined after the cohort group.  It follows that the retained rate in your cohort group is `90 %`. On the other hand, if we consider the total number of customers that joined the platform in the first three months then the `retention rate` is:


```console
Cohort SEPT-NOV 2021       220 - 10           210
Retention Rate DECEMBER =  -------- * 100 = ------- % =  80.77 %
                              260             260
```

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

We want to generate an aquisition cohort retention rate table for the `logins` data. The output table is formatted as follow:

```console
grp   | subscription | subscriber_cnt |   m0   |  m1   |   m2   |   m3   |   m4   |   m5   |   m6   |   m7   |  m8   |  m9   |  m10  |  m11
------+--------------+----------------+--------+-------+--------+--------+--------+--------+--------+--------+-------+-------+-------+-------
21-09 | SEPTEMBER    |             54 | 100.00 | 61.11 |  59.26 |  72.22 |  55.56 |  57.41 |  66.67 |  46.30 | 51.85 | 50.00 | 61.11 | 62.96
21-10 | OCTOBER      |             29 | 100.00 | 48.28 |  37.93 |  62.07 |  51.72 |  68.97 |  58.62 |  44.83 | 51.72 | 62.07 | 48.28 |
21-11 | NOVEMBER     |             11 | 100.00 | 63.64 |  63.64 |  45.45 |  45.45 |  54.55 |  45.45 |  45.45 | 72.73 | 63.64 |       |
21-12 | DECEMBER     |              3 | 100.00 | 66.67 |  33.33 |  33.33 |  66.67 |  66.67 |  33.33 |  66.67 | 66.67 |       |       |
22-01 | JANUARY      |              1 | 100.00 |  0.00 | 100.00 |   0.00 |   0.00 |   0.00 | 100.00 | 100.00 |       |       |       |
22-02 | FEBRUARY     |              2 | 100.00 |  0.00 | 100.00 | 100.00 | 100.00 | 100.00 | 100.00 |        |       |       |       |
(6 rows)
```

In this table the columns are:

- `grp`: 5 characters column indicating the cohort group. The first and last two characters indicate the last two digits of the year and month of the cohort group, respectively. For example, the first row value `21-09` indicates the month of Septmber, (**09**) in `20`**21**.
- `subscription`: It's simply the full month name.
- `subscriber_cnt`: The number of subscriptions in the subscription month. It's basically the size of the cohort group population.
- `m0`, `m1`, .., `m11`: The retention rate calculation for each month period after the subscription month. For example, the `m0` is the trivial subscription month and, therefore, `100%` of the population in the cohort group had activity in the subscription month. `m1` indicates the percentage of the population in the cohort group retained in the first month after the subscription. Similarly, `m11` relates to the percentage of the cohort group population retained eleven months after the subscription month.

How should we read this table ?

If you’re new to cohort charts, they can be a little confusing at first glance. But they’re actually pretty easy to read once you know what you’re looking at.

From left to right the first row indicates that `54` people subscribed in the period of `SEPTEMBER 2021` and `61.11 %`, (`m1`), came back the month after their subscription. It follows that `61.11 %` had activity in the period of `OCTOBER 2021`. Each column after that shows the percentage remaining customers from that cohort after each month. So from the `m2` column, we can see that `59.26 %` of the original `54` subscribers came back in the period of `NOVEMBER 2021`, two months after their subscription month.

Moving a row below, the number `29` indicates the number of subscribers in the period of `OCTOBER 2021` and `48.28 %`, (`m1`), came back in `NOVEMBER 2021`.



## Solution

The basic decisions of any cohort analysis are:

1. The selection of the cohort groups.
2. The time frame window. This window identifies the time when the analysis starts and ends.
3. The number of time periods within the time frame window.
4. The duration of each period
5. The metric or statistic to track within the time frame window and computed for each time period bucket.

In this example, the cohort analysis components are:

1. Month subscription: The total number of users in the logins table is partitioned in distinct groups based on the first activity month. In other words, the grouping is based on an event that corresponds to the subscription month.
2. The first and last date activity: The first and last date a cohort group logged in the system.
3. The number of elapsed months between the first and last date activity: This number includes the trivial month of subscription and the last month activity.
4. Monthly analysis: the analysis of each period will consider all the days in a single month.
5. Customer Retention rate.  

```SQL
WITH first_activity AS (
  SELECT  user_id
        , DATE_TRUNC('month',MIN(day))::DATE AS month
    FROM logins
   GROUP BY 1
),
month_activity AS (
  SELECT  DISTINCT DATE_TRUNC('month',day)::DATE AS month
        , user_id AS user_id
    FROM logins
),
grp_month_activity AS (
  SELECT  fau.user_id AS user_id
        , fau.month AS month_grp
        , mau.month AS month_login
    FROM first_activity AS fau
   INNER JOIN month_activity AS mau
      ON fau.user_id = mau.user_id
),
grp_month_count AS (
  SELECT  month_grp AS subscription
        , month_login
        , COUNT(user_id) AS user_cnt
    FROM grp_month_activity
   GROUP BY month_grp, month_login
),
grp_month_count_max AS (
  SELECT  subscription AS subscription_m
        , month_login
        , MAX(user_cnt) OVER (PARTITION BY subscription) AS subscriber_cnt
        , user_cnt AS login_cnt
    FROM grp_month_count
),
grp_month_period AS (
  SELECT  TO_CHAR(subscription_m,'YY-MM') AS grp
        , TO_CHAR(subscription_m,'MONTH') AS subscription
        , CASE WHEN EXTRACT(YEAR FROM month_login) = EXTRACT(YEAR FROM subscription_m)
               THEN (EXTRACT(MONTH FROM month_login) -
                     EXTRACT(MONTH FROM subscription_m))::INTEGER
               ELSE (12 - EXTRACT(MONTH FROM subscription_m) +
                          EXTRACT(MONTH FROM month_login)::INTEGER
          ) END AS period_login
        , subscriber_cnt
        , login_cnt
        , ROUND(100.0*login_cnt/(subscriber_cnt),2) AS retention_rate
    FROM grp_month_count_max
),
grp_retention AS (
  SELECT  grp
        , subscription
        , period_login
        , subscriber_cnt
        , login_cnt
        , CASE WHEN period_login = 0 THEN retention_rate ELSE NULL END AS m0
        , CASE WHEN period_login = 1 THEN retention_rate ELSE NULL END AS m1
        , CASE WHEN period_login = 2 THEN retention_rate ELSE NULL END AS m2
        , CASE WHEN period_login = 3 THEN retention_rate ELSE NULL END AS m3
        , CASE WHEN period_login = 4 THEN retention_rate ELSE NULL END AS m4
        , CASE WHEN period_login = 5 THEN retention_rate ELSE NULL END AS m5
        , CASE WHEN period_login = 6 THEN retention_rate ELSE NULL END AS m6
        , CASE WHEN period_login = 7 THEN retention_rate ELSE NULL END AS m7
        , CASE WHEN period_login = 8 THEN retention_rate ELSE NULL END AS m8
        , CASE WHEN period_login = 9 THEN retention_rate ELSE NULL END AS m9
        , CASE WHEN period_login = 10 THEN retention_rate ELSE NULL END AS m10
        , CASE WHEN period_login = 11 THEN retention_rate ELSE NULL END AS m11
        , retention_rate
    FROM grp_month_period
),
grp_retention_pivot AS (
  SELECT  grp
        , subscription
        , subscriber_cnt
        , MAX(m0) AS m0
        , MAX(m1) AS m1
        , MAX(m2) AS m2
        , MAX(m3) AS m3
        , MAX(m4) AS m4
        , MAX(m5) AS m5
        , MAX(m6) AS m6
        , MAX(m7) AS m7
        , MAX(m8) AS m8
        , MAX(m9) AS m9
        , MAX(m10) AS m10
        , MAX(m11) AS m11
    FROM grp_retention
   GROUP BY 1,2,3
)
SELECT  gr.grp
      , subscription
      , subscriber_cnt
      , m0
      , CASE WHEN p.last_login > 1  THEN COALESCE(m1,0.00) ELSE m1 END AS m1
      , CASE WHEN p.last_login > 2  THEN COALESCE(m2,0.00) ELSE m2 END AS m2
      , CASE WHEN p.last_login > 3  THEN COALESCE(m3,0.00) ELSE m3 END AS m3
      , CASE WHEN p.last_login > 4  THEN COALESCE(m4,0.00) ELSE m4 END AS m4
      , CASE WHEN p.last_login > 5  THEN COALESCE(m5,0.00) ELSE m5 END AS m5
      , CASE WHEN p.last_login > 6  THEN COALESCE(m6,0.00) ELSE m6 END AS m6
      , CASE WHEN p.last_login > 7  THEN COALESCE(m7,0.00) ELSE m7 END AS m7
      , CASE WHEN p.last_login > 8  THEN COALESCE(m8,0.00) ELSE m8 END AS m8
      , CASE WHEN p.last_login > 9  THEN COALESCE(m9,0.00) ELSE m9 END AS m9
      , CASE WHEN p.last_login > 10 THEN COALESCE(m10,0.00) ELSE m10 END AS m10
      , CASE WHEN p.last_login > 11 THEN COALESCE(m11,0.00) ELSE m11 END AS m11
  FROM grp_retention_pivot gr
 INNER JOIN (SELECT  grp
                   , MAX(period_login) AS last_login
               FROM grp_month_period
              GROUP BY grp) p
    ON gr.grp = p.grp
 ORDER BY grp;
```

## Discussion

We introduce a new table containing `users' first active month` to segment customers in distinct groups of analysis.

```SQL
WITH first_activity AS (
  SELECT  user_id
        , DATE_TRUNC('month',MIN(day))::DATE AS month
    FROM logins
   GROUP BY 1
)
SELECT month AS sub_month
      , user_id
  FROM first_activity
 ORDER BY 1, 2;
```

```console
sub_month  | user_id
-----------+---------
2021-09-01 |       3
2021-09-01 |       4
2021-09-01 |       5
2021-09-01 |       6
2021-09-01 |       7
2021-09-01 |     ...
-----------+---------
2021-10-01 |       8
2021-10-01 |       9
2021-10-01 |      14
2021-10-01 |     ...
-----------+---------
2021-11-01 |       2
2021-11-01 |      11
2021-11-01 |      15
...        |     ...
```

To give an idea of the population and cohort groups size we run the following query:

```SQL
WITH first_activity AS (
  SELECT  user_id
        , DATE_TRUNC('month',MIN(day))::DATE AS month
    FROM logins
   GROUP BY 1
)
SELECT month AS sub_month
      , COUNT(user_id) AS subscriber_cnt
  FROM first_activity
 GROUP BY 1
 ORDER BY 1;
```

```console
sub_month  | subscriber_cnt
------------+----------------
2021-09-01 |             54
2021-10-01 |             29
2021-11-01 |             11
2021-12-01 |              3
2022-01-01 |              1
2022-02-01 |              2
(6 rows)
```
The number of month cohort groups is `6`, as users joined the system for the first time during the period of four months in `2021` and two months in `2022`. The total number of users is `100`.  

Next, we create a table of monthly active users:

```SQL
WITH month_activity AS (
  SELECT DISTINCT DATE_TRUNC('month',day)::DATE AS month,
         user_id AS user_id
    FROM logins
)
SELECT *
  FROM month_activity
 WHERE month = '2021-10-01'::DATE
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
2021-09-01 |     ...
-----------+--------
2021-10-01 |       3
2021-10-01 |       4
2021-10-01 |       5
2021-10-01 |       6
2021-10-01 |       7
2021-10-01 |       8
2021-10-01 |       9
2021-10-01 |      10
2021-10-01 |      13
2021-10-01 |      14
...        |     ...
```

Next, join `month_activity` and `first_activity` tables on the `user_id` column. This query will help us to identify which user cohort joined the system in the following months.

```SQL
WITH first_activity AS (
  SELECT  user_id
        , DATE_TRUNC('month',MIN(day))::DATE AS month
    FROM logins
   GROUP BY 1
),
month_activity AS (
  SELECT  DISTINCT DATE_TRUNC('month',day)::DATE AS month
        , user_id AS user_id
    FROM logins
)
SELECT  fau.user_id AS user_id
      , fau.month AS month_grp
      , mau.month AS month_login
  FROM first_activity AS fau
 INNER JOIN month_activity AS mau
    ON fau.user_id = mau.user_id
 ORDER BY 2,1,3;
```

This query will show three columns to indicate the `user_id` and their cohort group with their login history.

```console
user_id | month_grp  | month_login
--------+------------+-------------
      3 | 2021-09-01 | 2021-09-01
      3 | 2021-09-01 | 2021-10-01
      3 | 2021-09-01 | 2021-11-01
      3 | 2021-09-01 | 2021-12-01
      3 | 2021-09-01 | 2022-01-01
      3 | 2021-09-01 | 2022-03-01
      3 | 2021-09-01 | 2022-04-01
      3 | 2021-09-01 | 2022-06-01
      3 | 2021-09-01 | 2022-07-01
      3 | 2021-09-01 | 2022-08-01
      4 | 2021-09-01 | 2021-09-01
      4 | 2021-09-01 | 2021-10-01
      4 | 2021-09-01 | 2022-01-01
      4 | 2021-09-01 | 2022-05-01
      4 | 2021-09-01 | 2022-07-01
```

For example, in the first cohort group, (the users who subscribed in `SEPTEMBER 2021`), user_id `3` logged in the system during the period of `SEPTEMBER` (obviously: 2021-09-01), `NOVEMBER`(2021-10-01),`DECEMBER`(2021-12-01),`JANUARY`(2022-01-01),`MARCH`(2022-03-01),`APRIL`(2022-04-01),`JUNE`(2022-04-01), `JULY`(2022-07-01) and `AUGUST`(2022-08-01). This user, therefore, will be in the count of users who subscribed in `SEPTEMBER 2021` and logged in the above mentioned periods.

Next, use the aggragation function `COUNT` group by `month_grp`, the cohort group month, and `month_login`.

```SQL
WITH first_activity AS (
  SELECT  user_id
        , DATE_TRUNC('month',MIN(day))::DATE AS month
    FROM logins
   GROUP BY 1
),
month_activity AS (
  SELECT  DISTINCT DATE_TRUNC('month',day)::DATE AS month
        , user_id AS user_id
    FROM logins
),
grp_month_activity AS (
  SELECT  fau.user_id AS user_id
        , fau.month AS month_grp
        , mau.month AS month_login
    FROM first_activity AS fau
   INNER JOIN month_activity AS mau
      ON fau.user_id = mau.user_id
)
SELECT  month_grp AS subscription
      , month_login
      , COUNT(user_id) AS user_cnt
  FROM grp_month_activity
 GROUP BY month_grp, month_login
 ORDER BY 1,2;
```

```console
subscription | month_login | user_cnt
-------------+-------------+----------
2021-09-01   | 2021-09-01  |       54
2021-09-01   | 2021-10-01  |       33
2021-09-01   | 2021-11-01  |       32
2021-09-01   | 2021-12-01  |       39
2021-09-01   | 2022-01-01  |       30
2021-09-01   | 2022-02-01  |       31
2021-09-01   | 2022-03-01  |       36
2021-09-01   | 2022-04-01  |       25
2021-09-01   | 2022-05-01  |       28
2021-09-01   | 2022-06-01  |       27
2021-09-01   | 2022-07-01  |       33
2021-09-01   | 2022-08-01  |       34
```
Next, include an additional column with the size of the cohort group. The number of subscribers.

```SQL
WITH first_activity AS (
  SELECT  user_id
        , DATE_TRUNC('month',MIN(day))::DATE AS month
    FROM logins
   GROUP BY 1
),
month_activity AS (
  SELECT  DISTINCT DATE_TRUNC('month',day)::DATE AS month
        , user_id AS user_id
    FROM logins
),
grp_month_activity AS (
  SELECT  fau.user_id AS user_id
        , fau.month AS month_grp
        , mau.month AS month_login
    FROM first_activity AS fau
   INNER JOIN month_activity AS mau
      ON fau.user_id = mau.user_id
),
grp_month_count AS (
  SELECT  month_grp AS subscription
        , month_login
        , COUNT(user_id) AS user_cnt
    FROM grp_month_activity
   GROUP BY month_grp, month_login
)
SELECT  subscription
      , month_login
      , MAX(user_cnt) OVER (PARTITION BY subscription) AS subscriber_cnt
      , user_cnt AS login_cnt
  FROM grp_month_count
 ORDER BY 1,2;
```

```console
subscription | month_login | subscriber_cnt | login_cnt
-------------+-------------+----------------+-----------
2021-09-01   | 2021-09-01  |             54 |        54
2021-09-01   | 2021-10-01  |             54 |        33
2021-09-01   | 2021-11-01  |             54 |        32
2021-09-01   | 2021-12-01  |             54 |        39
2021-09-01   | 2022-01-01  |             54 |        30
2021-09-01   | 2022-02-01  |             54 |        31
2021-09-01   | 2022-03-01  |             54 |        36
2021-09-01   | 2022-04-01  |             54 |        25
2021-09-01   | 2022-05-01  |             54 |        28
2021-09-01   | 2022-06-01  |             54 |        27
2021-09-01   | 2022-07-01  |             54 |        33
2021-09-01   | 2022-08-01  |             54 |        34
```

The last step is basically a ratio of the `logins` in a given month and the `subscribers` count.

```SQL
WITH first_activity AS (
  SELECT  user_id
        , DATE_TRUNC('month',MIN(day))::DATE AS month
    FROM logins
   GROUP BY 1
),
month_activity AS (
  SELECT  DISTINCT DATE_TRUNC('month',day)::DATE AS month
        , user_id AS user_id
    FROM logins
),
grp_month_activity AS (
  SELECT  fau.user_id AS user_id
        , fau.month AS month_grp
        , mau.month AS month_login
    FROM first_activity AS fau
   INNER JOIN month_activity AS mau
      ON fau.user_id = mau.user_id
),
grp_month_count AS (
  SELECT  month_grp AS subscription
        , month_login
        , COUNT(user_id) AS user_cnt
    FROM grp_month_activity
   GROUP BY month_grp, month_login
),
grp_month_count_max AS (
  SELECT  subscription
        , month_login
        , MAX(user_cnt) OVER (PARTITION BY subscription) AS subscriber_cnt
        , user_cnt AS login_cnt
    FROM grp_month_count
)
SELECT  TO_CHAR(subscription,'YYYY-MM') AS subscription
      , TO_CHAR(month_login,'YYYY-MM') AS month_login
      , subscriber_cnt
      , login_cnt
      , ROUND(100.0*login_cnt/(subscriber_cnt),2) AS retention_rate
  FROM grp_month_count_max
 ORDER BY 1,2;
```

```console
subscription | month_login | subscriber_cnt | login_cnt | retention_rate
-------------+-------------+----------------+-----------+----------------
2021-09      | 2021-09     |             54 |        54 |         100.00
2021-09      | 2021-10     |             54 |        33 |          61.11
2021-09      | 2021-11     |             54 |        32 |          59.26
2021-09      | 2021-12     |             54 |        39 |          72.22
2021-09      | 2022-01     |             54 |        30 |          55.56
2021-09      | 2022-02     |             54 |        31 |          57.41
2021-09      | 2022-03     |             54 |        36 |          66.67
2021-09      | 2022-04     |             54 |        25 |          46.30
2021-09      | 2022-05     |             54 |        28 |          51.85
2021-09      | 2022-06     |             54 |        27 |          50.00
2021-09      | 2022-07     |             54 |        33 |          61.11
2021-09      | 2022-08     |             54 |        34 |          62.96
-------------------------------------------------------------------------       
2021-10      | 2021-10     |             29 |        29 |         100.00
2021-10      | 2021-11     |             29 |        14 |          48.28
2021-10      | 2021-12     |             29 |        11 |          37.93
2021-10      | 2022-01     |             29 |        18 |          62.07
2021-10      | 2022-02     |             29 |        15 |          51.72
2021-10      | 2022-03     |             29 |        20 |          68.97
2021-10      | 2022-04     |             29 |        17 |          58.62
2021-10      | 2022-05     |             29 |        13 |          44.83
2021-10      | 2022-06     |             29 |        15 |          51.72
2021-10      | 2022-07     |             29 |        18 |          62.07
2021-10      | 2022-08     |             29 |        14 |          48.28
--------------------------------------------------------------------------
2021-11      | 2021-11     |             11 |        11 |         100.00
2021-11      | 2021-12     |             11 |         7 |          63.64
2021-11      | 2022-01     |             11 |         7 |          63.64
2021-11      | 2022-02     |             11 |         5 |          45.45
2021-11      | 2022-03     |             11 |         5 |          45.45
2021-11      | 2022-04     |             11 |         6 |          54.55
2021-11      | 2022-05     |             11 |         5 |          45.45
2021-11      | 2022-06     |             11 |         5 |          45.45
2021-11      | 2022-07     |             11 |         8 |          72.73
2021-11      | 2022-08     |             11 |         7 |          63.64
-------------------------------------------------------------------------
2021-12      | 2021-12     |              3 |         3 |         100.00
2021-12      | 2022-01     |              3 |         2 |          66.67
2021-12      | 2022-02     |              3 |         1 |          33.33
2021-12      | 2022-03     |              3 |         1 |          33.33
2021-12      | 2022-04     |              3 |         2 |          66.67
2021-12      | 2022-05     |              3 |         2 |          66.67
2021-12      | 2022-06     |              3 |         1 |          33.33
2021-12      | 2022-07     |              3 |         2 |          66.67
2021-12      | 2022-08     |              3 |         2 |          66.67
--------------------------------------------------------------------------
2022-01      | 2022-01     |              1 |         1 |         100.00

2022-01      | 2022-03     |              1 |         1 |         100.00



2022-01      | 2022-07     |              1 |         1 |         100.00
2022-01      | 2022-08     |              1 |         1 |         100.00
--------------------------------------------------------------------------
2022-02      | 2022-02     |              2 |         2 |         100.00

2022-02      | 2022-04     |              2 |         2 |         100.00
2022-02      | 2022-05     |              2 |         2 |         100.00
2022-02      | 2022-06     |              2 |         2 |         100.00
2022-02      | 2022-07     |              2 |         2 |         100.00
2022-02      | 2022-08     |              2 |         2 |         100.00
(52 rows)
```

AS you can see in `2022` the months of `February`,`April`,`May` and `June` are missing in the cohort group of **2022-01**, `January 2022`. Similarly, the month of `March` is missing in the cohort group of **2022-02**,`February 2022`. To fill the gaps we can replace the `month_login` column with an integer value column indicating the number of months after the subscription date. The integer value column will be named `period_login`, where a value of:

- `0`: indicates 0 months after subscription
- `1`: indicates 1 month after subscription
- `2`: indicates 2 months after subscription
- ... : ...
- `n`: indicates n months after subscription

The first step is to include this new column and then fill the gaps with the missing periods.

```SQL
WITH first_activity AS (
  SELECT  user_id
        , DATE_TRUNC('month',MIN(day))::DATE AS month
    FROM logins
   GROUP BY 1
),
month_activity AS (
  SELECT  DISTINCT DATE_TRUNC('month',day)::DATE AS month
        , user_id AS user_id
    FROM logins
),
grp_month_activity AS (
  SELECT  fau.user_id AS user_id
        , fau.month AS month_grp
        , mau.month AS month_login
    FROM first_activity AS fau
   INNER JOIN month_activity AS mau
      ON fau.user_id = mau.user_id
),
grp_month_count AS (
  SELECT  month_grp AS subscription
        , month_login
        , COUNT(user_id) AS user_cnt
    FROM grp_month_activity
   GROUP BY month_grp, month_login
),
grp_month_count_max AS (
  SELECT  subscription
        , month_login
        , MAX(user_cnt) OVER (PARTITION BY subscription) AS subscriber_cnt
        , user_cnt AS login_cnt
    FROM grp_month_count
)
SELECT  TO_CHAR(subscription,'YYYY-MM') AS subscription
      , TO_CHAR(month_login,'YYYY-MM') AS month_login
      , CASE WHEN EXTRACT(YEAR FROM month_login) = EXTRACT(YEAR FROM subscription)
             THEN (EXTRACT(MONTH FROM month_login) -
                   EXTRACT(MONTH FROM subscription))::INTEGER
             ELSE (12 - EXTRACT(MONTH FROM subscription) +
                        EXTRACT(MONTH FROM month_login)
        ) END AS period_login
      , subscriber_cnt
      , login_cnt
      , ROUND(100.0*login_cnt/(subscriber_cnt),2) AS retention_rate
  FROM grp_month_count_max
 ORDER BY 1,2;
```

The cohort analysis time frame is 12 months and, therefore we just need to find out a value between 0-11.

```console
subscription | month_login | period_login | subscriber_cnt | login_cnt | retention_rate
--------------+-------------+--------------+----------------+-----------+----------------
2021-09      | 2021-09     |            0 |             54 |        54 |         100.00
2021-09      | 2021-10     |            1 |             54 |        33 |          61.11
2021-09      | 2021-11     |            2 |             54 |        32 |          59.26
2021-09      | 2021-12     |            3 |             54 |        39 |          72.22
2021-09      | 2022-01     |            4 |             54 |        30 |          55.56
2021-09      | 2022-02     |            5 |             54 |        31 |          57.41
2021-09      | 2022-03     |            6 |             54 |        36 |          66.67
2021-09      | 2022-04     |            7 |             54 |        25 |          46.30
2021-09      | 2022-05     |            8 |             54 |        28 |          51.85
2021-09      | 2022-06     |            9 |             54 |        27 |          50.00
2021-09      | 2022-07     |           10 |             54 |        33 |          61.11
2021-09      | 2022-08     |           11 |             54 |        34 |          62.96
```

We can now change the string formatting:

```SQL
WITH first_activity AS (
  SELECT  user_id
        , DATE_TRUNC('month',MIN(day))::DATE AS month
    FROM logins
   GROUP BY 1
),
month_activity AS (
  SELECT  DISTINCT DATE_TRUNC('month',day)::DATE AS month
        , user_id AS user_id
    FROM logins
),
grp_month_activity AS (
  SELECT  fau.user_id AS user_id
        , fau.month AS month_grp
        , mau.month AS month_login
    FROM first_activity AS fau
   INNER JOIN month_activity AS mau
      ON fau.user_id = mau.user_id
),
grp_month_count AS (
  SELECT  month_grp AS subscription
        , month_login
        , COUNT(user_id) AS user_cnt
    FROM grp_month_activity
   GROUP BY month_grp, month_login
),
grp_month_count_max AS (
  SELECT  subscription AS subscription_m
        , month_login
        , MAX(user_cnt) OVER (PARTITION BY subscription) AS subscriber_cnt
        , user_cnt AS login_cnt
    FROM grp_month_count
)
SELECT  TO_CHAR(subscription_m,'YYYY MONTH') AS subscription
      , CASE WHEN EXTRACT(YEAR FROM month_login) = EXTRACT(YEAR FROM subscription_m)
             THEN (EXTRACT(MONTH FROM month_login) -
                   EXTRACT(MONTH FROM subscription_m))::INTEGER
             ELSE (12 - EXTRACT(MONTH FROM subscription_m) +
                        EXTRACT(MONTH FROM month_login)
        ) END AS period_login
      , subscriber_cnt
      , login_cnt
      , ROUND(100.0*login_cnt/(subscriber_cnt),2) AS retention_rate
  FROM grp_month_count_max
 ORDER BY subscription_m ,period_login;
```

```console
subscription  | period_login | subscriber_cnt | login_cnt | retention_rate
----------------+--------------+----------------+-----------+----------------
2021 SEPTEMBER |            0 |             54 |        54 |         100.00
2021 SEPTEMBER |            1 |             54 |        33 |          61.11
2021 SEPTEMBER |            2 |             54 |        32 |          59.26
2021 SEPTEMBER |            3 |             54 |        39 |          72.22
2021 SEPTEMBER |            4 |             54 |        30 |          55.56
2021 SEPTEMBER |            5 |             54 |        31 |          57.41
2021 SEPTEMBER |            6 |             54 |        36 |          66.67
2021 SEPTEMBER |            7 |             54 |        25 |          46.30
2021 SEPTEMBER |            8 |             54 |        28 |          51.85
2021 SEPTEMBER |            9 |             54 |        27 |          50.00
2021 SEPTEMBER |           10 |             54 |        33 |          61.11
2021 SEPTEMBER |           11 |             54 |        34 |          62.96
2021 OCTOBER   |            0 |             29 |        29 |         100.00
2021 OCTOBER   |            1 |             29 |        14 |          48.28
2021 OCTOBER   |            2 |             29 |        11 |          37.93
```

Next, generate the additional numbered columns, (0-11), indicating the period of months after the subscription. The values in this column corresponds to the corresponding retention_rate as indicated in the last field of each row in the above table. For example, the first row will have a value **100** in the column `0` and **0** in the remaining `1-11` columns.

```SQL
WITH first_activity AS (
  SELECT  user_id
        , DATE_TRUNC('month',MIN(day))::DATE AS month
    FROM logins
   GROUP BY 1
),
month_activity AS (
  SELECT  DISTINCT DATE_TRUNC('month',day)::DATE AS month
        , user_id AS user_id
    FROM logins
),
grp_month_activity AS (
  SELECT  fau.user_id AS user_id
        , fau.month AS month_grp
        , mau.month AS month_login
    FROM first_activity AS fau
   INNER JOIN month_activity AS mau
      ON fau.user_id = mau.user_id
),
grp_month_count AS (
  SELECT  month_grp AS subscription
        , month_login
        , COUNT(user_id) AS user_cnt
    FROM grp_month_activity
   GROUP BY month_grp, month_login
),
grp_month_count_max AS (
  SELECT  subscription AS subscription_m
        , month_login
        , MAX(user_cnt) OVER (PARTITION BY subscription) AS subscriber_cnt
        , user_cnt AS login_cnt
    FROM grp_month_count
),
grp_month_period AS (
  SELECT  TO_CHAR(subscription_m,'YY-MM') AS grp
        , TO_CHAR(subscription_m,'MONTH') AS subscription
        , CASE WHEN EXTRACT(YEAR FROM month_login) = EXTRACT(YEAR FROM subscription_m)
               THEN (EXTRACT(MONTH FROM month_login) -
                     EXTRACT(MONTH FROM subscription_m))::INTEGER
               ELSE (12 - EXTRACT(MONTH FROM subscription_m) +
                          EXTRACT(MONTH FROM month_login)::INTEGER
          ) END AS period_login
        , subscriber_cnt
        , login_cnt
        , ROUND(100.0*login_cnt/(subscriber_cnt),2) AS retention_rate
    FROM grp_month_count_max
)
SELECT  grp
      , subscription
      , period_login
      , subscriber_cnt
      , login_cnt
      , CASE WHEN period_login = 0 THEN retention_rate ELSE NULL END AS m0
      , CASE WHEN period_login = 1 THEN retention_rate ELSE NULL END AS m1
      , CASE WHEN period_login = 2 THEN retention_rate ELSE NULL END AS m2
      , CASE WHEN period_login = 3 THEN retention_rate ELSE NULL END AS m3
      , CASE WHEN period_login = 4 THEN retention_rate ELSE NULL END AS m4
      , CASE WHEN period_login = 5 THEN retention_rate ELSE NULL END AS m5
      , CASE WHEN period_login = 6 THEN retention_rate ELSE NULL END AS m6
      , CASE WHEN period_login = 7 THEN retention_rate ELSE NULL END AS m7
      , CASE WHEN period_login = 8 THEN retention_rate ELSE NULL END AS m8
      , CASE WHEN period_login = 9 THEN retention_rate ELSE NULL END AS m9
      , CASE WHEN period_login = 10 THEN retention_rate ELSE NULL END AS m10
      , CASE WHEN period_login = 11 THEN retention_rate ELSE NULL END AS m11
      , retention_rate
  FROM grp_month_period
 WHERE grp = '21-09'
 ORDER BY subscription ,period_login;
```

If we save the file as `cookbook_retention_test.sql`, it is possible to execute the file from the system terminal and save it to a txt file. The table is saved in the `cookbook` sample database:

```console
$ psql cookbook -f cookbook_retention_test.sql > retention_rate_logins.txt
```

Output:

```console
grp   | subscription | period_login | subscriber_cnt | login_cnt |   m0   |  m1   |  m2   |  m3   |  m4   |  m5   |  m6   |  m7   |  m8   |  m9   |  m10  |  m11  | retention_rate
-------+-------------+--------------+----------------+-----------+--------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+----------------
21-09 | SEPTEMBER    |            0 |             54 |        54 | 100.00 |       |       |       |       |       |       |       |       |       |       |       |         100.00
21-09 | SEPTEMBER    |            1 |             54 |        33 |        | 61.11 |       |       |       |       |       |       |       |       |       |       |          61.11
21-09 | SEPTEMBER    |            2 |             54 |        32 |        |       | 59.26 |       |       |       |       |       |       |       |       |       |          59.26
21-09 | SEPTEMBER    |            3 |             54 |        39 |        |       |       | 72.22 |       |       |       |       |       |       |       |       |          72.22
21-09 | SEPTEMBER    |            4 |             54 |        30 |        |       |       |       | 55.56 |       |       |       |       |       |       |       |          55.56
21-09 | SEPTEMBER    |            5 |             54 |        31 |        |       |       |       |       | 57.41 |       |       |       |       |       |       |          57.41
21-09 | SEPTEMBER    |            6 |             54 |        36 |        |       |       |       |       |       | 66.67 |       |       |       |       |       |          66.67
21-09 | SEPTEMBER    |            7 |             54 |        25 |        |       |       |       |       |       |       | 46.30 |       |       |       |       |          46.30
21-09 | SEPTEMBER    |            8 |             54 |        28 |        |       |       |       |       |       |       |       | 51.85 |       |       |       |          51.85
21-09 | SEPTEMBER    |            9 |             54 |        27 |        |       |       |       |       |       |       |       |       | 50.00 |       |       |          50.00
21-09 | SEPTEMBER    |           10 |             54 |        33 |        |       |       |       |       |       |       |       |       |       | 61.11 |       |          61.11
21-09 | SEPTEMBER    |           11 |             54 |        34 |        |       |       |       |       |       |       |       |       |       |       | 62.96 |          62.96
(12 rows)
```

The output shows that the number of rows for the first cohort group `21-09`, `2021 SEPTEMBER`, is 12 and the all the 12 columns indicating the number of months after the subscription have at least one not NULL value. This means that the cohort group has no gaps between the first and last month activity.

However, this is not always the case. For example, filtering the `WHERE` condition with cohort grp `22-01`:

```console
grp   | subscription | period_login | subscriber_cnt | login_cnt |   m0   | m1 |   m2   | m3 | m4 | m5 |   m6   |   m7   | m8 | m9 | m10 | m11 | retention_rate
------+--------------+--------------+----------------+-----------+--------+----+--------+----+----+----+--------+--------+----+----+-----+-----+----------------
22-01 | JANUARY      |            0 |              1 |         1 | 100.00 |    |        |    |    |    |        |        |    |    |     |     |         100.00
22-01 | JANUARY      |            2 |              1 |         1 |        |    | 100.00 |    |    |    |        |        |    |    |     |     |         100.00
22-01 | JANUARY      |            6 |              1 |         1 |        |    |        |    |    |    | 100.00 |        |    |    |     |     |         100.00
22-01 | JANUARY      |            7 |              1 |         1 |        |    |        |    |    |    |        | 100.00 |    |    |     |     |         100.00
```

In this simple example the cohort group `22-01` has only a user and a time frame of six months after the subscription month (`m0 - m6`). During this time frame the only activity was in the second and sixth month after the subscription month. It follows that `m1`,`m3`,`m4` and `m5` have no activity. We want to fill the blank spaces with zero values indicating the abscense of activity.

In order to do that we need to pivot the table first and keep track of the last period login.

```SQL
WITH first_activity AS (
  SELECT  user_id
        , DATE_TRUNC('month',MIN(day))::DATE AS month
    FROM logins
   GROUP BY 1
),
month_activity AS (
  SELECT  DISTINCT DATE_TRUNC('month',day)::DATE AS month
        , user_id AS user_id
    FROM logins
),
grp_month_activity AS (
  SELECT  fau.user_id AS user_id
        , fau.month AS month_grp
        , mau.month AS month_login
    FROM first_activity AS fau
   INNER JOIN month_activity AS mau
      ON fau.user_id = mau.user_id
),
grp_month_count AS (
  SELECT  month_grp AS subscription
        , month_login
        , COUNT(user_id) AS user_cnt
    FROM grp_month_activity
   GROUP BY month_grp, month_login
),
grp_month_count_max AS (
  SELECT  subscription AS subscription_m
        , month_login
        , MAX(user_cnt) OVER (PARTITION BY subscription) AS subscriber_cnt
        , user_cnt AS login_cnt
    FROM grp_month_count
),
grp_month_period AS (
  SELECT  TO_CHAR(subscription_m,'YY-MM') AS grp
        , TO_CHAR(subscription_m,'MONTH') AS subscription
        , CASE WHEN EXTRACT(YEAR FROM month_login) = EXTRACT(YEAR FROM subscription_m)
               THEN (EXTRACT(MONTH FROM month_login) -
                     EXTRACT(MONTH FROM subscription_m))::INTEGER
               ELSE (12 - EXTRACT(MONTH FROM subscription_m) +
                          EXTRACT(MONTH FROM month_login)::INTEGER
          ) END AS period_login
        , subscriber_cnt
        , login_cnt
        , ROUND(100.0*login_cnt/(subscriber_cnt),2) AS retention_rate
    FROM grp_month_count_max
),
grp_retention AS (
  SELECT  grp
        , subscription
        , period_login
        , subscriber_cnt
        , login_cnt
        , CASE WHEN period_login = 0 THEN retention_rate ELSE NULL END AS m0
        , CASE WHEN period_login = 1 THEN retention_rate ELSE NULL END AS m1
        , CASE WHEN period_login = 2 THEN retention_rate ELSE NULL END AS m2
        , CASE WHEN period_login = 3 THEN retention_rate ELSE NULL END AS m3
        , CASE WHEN period_login = 4 THEN retention_rate ELSE NULL END AS m4
        , CASE WHEN period_login = 5 THEN retention_rate ELSE NULL END AS m5
        , CASE WHEN period_login = 6 THEN retention_rate ELSE NULL END AS m6
        , CASE WHEN period_login = 7 THEN retention_rate ELSE NULL END AS m7
        , CASE WHEN period_login = 8 THEN retention_rate ELSE NULL END AS m8
        , CASE WHEN period_login = 9 THEN retention_rate ELSE NULL END AS m9
        , CASE WHEN period_login = 10 THEN retention_rate ELSE NULL END AS m10
        , CASE WHEN period_login = 11 THEN retention_rate ELSE NULL END AS m11
        , retention_rate
    FROM grp_month_period
)
SELECT  grp
      , subscription
      , subscriber_cnt
      , MAX(m0) AS m0
      , MAX(m1) AS m1
      , MAX(m2) AS m2
      , MAX(m3) AS m3
      , MAX(m4) AS m4
      , MAX(m5) AS m5
      , MAX(m6) AS m6
      , MAX(m7) AS m7
      , MAX(m8) AS m8
      , MAX(m9) AS m9
      , MAX(m10) AS m10
      , MAX(m11) AS m11
  FROM grp_retention
 GROUP BY 1,2,3
 ORDER BY grp;
```

```console
grp   | subscription | subscriber_cnt |   m0   |  m1   |   m2   |   m3   |   m4   |   m5   |   m6   |   m7   |  m8   |  m9   |  m10  |  m11
------+--------------+----------------+--------+-------+--------+--------+--------+--------+--------+--------+-------+-------+-------+-------
21-09 | SEPTEMBER    |             54 | 100.00 | 61.11 |  59.26 |  72.22 |  55.56 |  57.41 |  66.67 |  46.30 | 51.85 | 50.00 | 61.11 | 62.96
21-10 | OCTOBER      |             29 | 100.00 | 48.28 |  37.93 |  62.07 |  51.72 |  68.97 |  58.62 |  44.83 | 51.72 | 62.07 | 48.28 |
21-11 | NOVEMBER     |             11 | 100.00 | 63.64 |  63.64 |  45.45 |  45.45 |  54.55 |  45.45 |  45.45 | 72.73 | 63.64 |       |
21-12 | DECEMBER     |              3 | 100.00 | 66.67 |  33.33 |  33.33 |  66.67 |  66.67 |  33.33 |  66.67 | 66.67 |       |       |
22-01 | JANUARY      |              1 | 100.00 |       | 100.00 |        |        |        | 100.00 | 100.00 |       |       |       |
22-02 | FEBRUARY     |              2 | 100.00 |       | 100.00 | 100.00 | 100.00 | 100.00 | 100.00 |        |       |       |       |
(6 rows)
```

The last step is filling the blank spaces between the subscription and last activity month.

```SQL
grp_retention AS (
  SELECT  grp
        , subscription
        , period_login
        , subscriber_cnt
        , login_cnt
        , CASE WHEN period_login = 0 THEN retention_rate ELSE NULL END AS m0
        , CASE WHEN period_login = 1 THEN retention_rate ELSE NULL END AS m1
        , CASE WHEN period_login = 2 THEN retention_rate ELSE NULL END AS m2
        , CASE WHEN period_login = 3 THEN retention_rate ELSE NULL END AS m3
        , CASE WHEN period_login = 4 THEN retention_rate ELSE NULL END AS m4
        , CASE WHEN period_login = 5 THEN retention_rate ELSE NULL END AS m5
        , CASE WHEN period_login = 6 THEN retention_rate ELSE NULL END AS m6
        , CASE WHEN period_login = 7 THEN retention_rate ELSE NULL END AS m7
        , CASE WHEN period_login = 8 THEN retention_rate ELSE NULL END AS m8
        , CASE WHEN period_login = 9 THEN retention_rate ELSE NULL END AS m9
        , CASE WHEN period_login = 10 THEN retention_rate ELSE NULL END AS m10
        , CASE WHEN period_login = 11 THEN retention_rate ELSE NULL END AS m11
        , retention_rate
    FROM grp_month_period
),
grp_retention_pivot AS (
  SELECT  grp
        , subscription
        , subscriber_cnt
        , MAX(m0) AS m0
        , MAX(m1) AS m1
        , MAX(m2) AS m2
        , MAX(m3) AS m3
        , MAX(m4) AS m4
        , MAX(m5) AS m5
        , MAX(m6) AS m6
        , MAX(m7) AS m7
        , MAX(m8) AS m8
        , MAX(m9) AS m9
        , MAX(m10) AS m10
        , MAX(m11) AS m11
    FROM grp_retention
   GROUP BY 1,2,3
)
SELECT  gr.grp
      , subscription
      , subscriber_cnt
      , p.last_login
      , m0
      , m1
      , m2
      , m3
      , m4
      , m5
      , m6
      , m7
      , m8
      , m9
      , m10
      , m11
  FROM grp_retention_pivot gr
 INNER JOIN (SELECT  grp
                   , MAX(period_login) AS last_login
               FROM grp_month_period
              GROUP BY grp) p
    ON gr.grp = p.grp
 ORDER BY grp;
```


```console
grp   | subscription | subscriber_cnt | last_login |   m0   |  m1   |   m2   |   m3   |   m4   |   m5   |   m6   |   m7   |  m8   |  m9   |  m10  |  m11
------+--------------+----------------+------------+--------+-------+--------+--------+--------+--------+--------+--------+-------+-------+-------+-------
21-09 | SEPTEMBER    |             54 |         11 | 100.00 | 61.11 |  59.26 |  72.22 |  55.56 |  57.41 |  66.67 |  46.30 | 51.85 | 50.00 | 61.11 | 62.96
21-10 | OCTOBER      |             29 |         10 | 100.00 | 48.28 |  37.93 |  62.07 |  51.72 |  68.97 |  58.62 |  44.83 | 51.72 | 62.07 | 48.28 |
21-11 | NOVEMBER     |             11 |          9 | 100.00 | 63.64 |  63.64 |  45.45 |  45.45 |  54.55 |  45.45 |  45.45 | 72.73 | 63.64 |       |
21-12 | DECEMBER     |              3 |          8 | 100.00 | 66.67 |  33.33 |  33.33 |  66.67 |  66.67 |  33.33 |  66.67 | 66.67 |       |       |
22-01 | JANUARY      |              1 |          7 | 100.00 |       | 100.00 |        |        |        | 100.00 | 100.00 |       |       |       |
22-02 | FEBRUARY     |              2 |          6 | 100.00 |       | 100.00 | 100.00 | 100.00 | 100.00 | 100.00 |        |       |       |       |
(6 rows)
```

The final step is to fill the gaps based on the `last_login` column:

```SQL
WITH first_activity AS (
  SELECT  user_id
        , DATE_TRUNC('month',MIN(day))::DATE AS month
    FROM logins
   GROUP BY 1
),
month_activity AS (
  SELECT  DISTINCT DATE_TRUNC('month',day)::DATE AS month
        , user_id AS user_id
    FROM logins
),
grp_month_activity AS (
  SELECT  fau.user_id AS user_id
        , fau.month AS month_grp
        , mau.month AS month_login
    FROM first_activity AS fau
   INNER JOIN month_activity AS mau
      ON fau.user_id = mau.user_id
),
grp_month_count AS (
  SELECT  month_grp AS subscription
        , month_login
        , COUNT(user_id) AS user_cnt
    FROM grp_month_activity
   GROUP BY month_grp, month_login
),
grp_month_count_max AS (
  SELECT  subscription AS subscription_m
        , month_login
        , MAX(user_cnt) OVER (PARTITION BY subscription) AS subscriber_cnt
        , user_cnt AS login_cnt
    FROM grp_month_count
),
grp_month_period AS (
  SELECT  TO_CHAR(subscription_m,'YY-MM') AS grp
        , TO_CHAR(subscription_m,'MONTH') AS subscription
        , CASE WHEN EXTRACT(YEAR FROM month_login) = EXTRACT(YEAR FROM subscription_m)
               THEN (EXTRACT(MONTH FROM month_login) -
                     EXTRACT(MONTH FROM subscription_m))::INTEGER
               ELSE (12 - EXTRACT(MONTH FROM subscription_m) +
                          EXTRACT(MONTH FROM month_login)::INTEGER
          ) END AS period_login
        , subscriber_cnt
        , login_cnt
        , ROUND(100.0*login_cnt/(subscriber_cnt),2) AS retention_rate
    FROM grp_month_count_max
),
grp_retention AS (
  SELECT  grp
        , subscription
        , period_login
        , subscriber_cnt
        , login_cnt
        , CASE WHEN period_login = 0 THEN retention_rate ELSE NULL END AS m0
        , CASE WHEN period_login = 1 THEN retention_rate ELSE NULL END AS m1
        , CASE WHEN period_login = 2 THEN retention_rate ELSE NULL END AS m2
        , CASE WHEN period_login = 3 THEN retention_rate ELSE NULL END AS m3
        , CASE WHEN period_login = 4 THEN retention_rate ELSE NULL END AS m4
        , CASE WHEN period_login = 5 THEN retention_rate ELSE NULL END AS m5
        , CASE WHEN period_login = 6 THEN retention_rate ELSE NULL END AS m6
        , CASE WHEN period_login = 7 THEN retention_rate ELSE NULL END AS m7
        , CASE WHEN period_login = 8 THEN retention_rate ELSE NULL END AS m8
        , CASE WHEN period_login = 9 THEN retention_rate ELSE NULL END AS m9
        , CASE WHEN period_login = 10 THEN retention_rate ELSE NULL END AS m10
        , CASE WHEN period_login = 11 THEN retention_rate ELSE NULL END AS m11
        , retention_rate
    FROM grp_month_period
),
grp_retention_pivot AS (
  SELECT  grp
        , subscription
        , subscriber_cnt
        , MAX(m0) AS m0
        , MAX(m1) AS m1
        , MAX(m2) AS m2
        , MAX(m3) AS m3
        , MAX(m4) AS m4
        , MAX(m5) AS m5
        , MAX(m6) AS m6
        , MAX(m7) AS m7
        , MAX(m8) AS m8
        , MAX(m9) AS m9
        , MAX(m10) AS m10
        , MAX(m11) AS m11
    FROM grp_retention
   GROUP BY 1,2,3
)
SELECT  gr.grp
      , subscription
      , subscriber_cnt
      , m0
      , CASE WHEN p.last_login > 1  THEN COALESCE(m1,0.00) ELSE m1 END AS m1
      , CASE WHEN p.last_login > 2  THEN COALESCE(m2,0.00) ELSE m2 END AS m2
      , CASE WHEN p.last_login > 3  THEN COALESCE(m3,0.00) ELSE m3 END AS m3
      , CASE WHEN p.last_login > 4  THEN COALESCE(m4,0.00) ELSE m4 END AS m4
      , CASE WHEN p.last_login > 5  THEN COALESCE(m5,0.00) ELSE m5 END AS m5
      , CASE WHEN p.last_login > 6  THEN COALESCE(m6,0.00) ELSE m6 END AS m6
      , CASE WHEN p.last_login > 7  THEN COALESCE(m7,0.00) ELSE m7 END AS m7
      , CASE WHEN p.last_login > 8  THEN COALESCE(m8,0.00) ELSE m8 END AS m8
      , CASE WHEN p.last_login > 9  THEN COALESCE(m9,0.00) ELSE m9 END AS m9
      , CASE WHEN p.last_login > 10 THEN COALESCE(m10,0.00) ELSE m10 END AS m10
      , CASE WHEN p.last_login > 11 THEN COALESCE(m11,0.00) ELSE m11 END AS m11
  FROM grp_retention_pivot gr
 INNER JOIN (SELECT  grp
                   , MAX(period_login) AS last_login
               FROM grp_month_period
              GROUP BY grp) p
    ON gr.grp = p.grp
 ORDER BY grp;
```

```console
grp   | subscription | subscriber_cnt |   m0   |  m1   |   m2   |   m3   |   m4   |   m5   |   m6   |   m7   |  m8   |  m9   |  m10  |  m11
------+--------------+----------------+--------+-------+--------+--------+--------+--------+--------+--------+-------+-------+-------+-------
21-09 | SEPTEMBER    |             54 | 100.00 | 61.11 |  59.26 |  72.22 |  55.56 |  57.41 |  66.67 |  46.30 | 51.85 | 50.00 | 61.11 | 62.96
21-10 | OCTOBER      |             29 | 100.00 | 48.28 |  37.93 |  62.07 |  51.72 |  68.97 |  58.62 |  44.83 | 51.72 | 62.07 | 48.28 |
21-11 | NOVEMBER     |             11 | 100.00 | 63.64 |  63.64 |  45.45 |  45.45 |  54.55 |  45.45 |  45.45 | 72.73 | 63.64 |       |
21-12 | DECEMBER     |              3 | 100.00 | 66.67 |  33.33 |  33.33 |  66.67 |  66.67 |  33.33 |  66.67 | 66.67 |       |       |
22-01 | JANUARY      |              1 | 100.00 |  0.00 | 100.00 |   0.00 |   0.00 |   0.00 | 100.00 | 100.00 |       |       |       |
22-02 | FEBRUARY     |              2 | 100.00 |  0.00 | 100.00 | 100.00 | 100.00 | 100.00 | 100.00 |        |       |       |       |
(6 rows)
```
