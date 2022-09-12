# Daily, Weekly and Monthly Active Users (DAU, WAU, MAU)

The metrics for active users measure the number of unique customers that interact with your products or services during a given time frame—typically daily, weekly, or monthly.

To calculate these metrics, determine your criteria for “active.” It can mean anything from clicking on a link in a campaign email to downloading a document from your website.

- **How to measure DAU, WAU, and MAU ?**

**DAU**, **WAU**, and **MAU** evaluate the health of your product or service by assessing whether your customers are (or aren’t) actively using it. These measurements can also help `predict customer churn by revealing complications`, `drop-off` points, and `features` that users don’t find necessary.

- **Daily active users** (`DAU`): the number of consumers that meet your criteria for being active within the `last 24 hours`.
- **Weekly active users** (`WAU`): the number of consumers that meet your criteria for being active within the `last seven days`.
- **Monthly active users** (`MAU`): the number of consumers that meet your criteria for being active within the `last 30 days`.


You can track these metrics individually, or you can use the `DAU/MAU` ratio, which measures the **proportion of monthly active users who interact with your product or service within a 24-hour window**.


```console

             DAU                           WAU
  DAU/MAU = ----- * 100        WAU/MAU =  ----- * 100
             MAU                           MAU
```

For example, if Company `Y` has `100,000 daily users` and `500,000 monthly users`, Company Y’s **DAU/MAU ratio** is `20 percent`.

```console
             100,000
DAU/MAU =   ---------- * 100 = 20%
             500,000
```

- **Why are DAU, WAU, and MAU important?**

The `DAU/MAU` ratio helps companies understand how valuable their products and services are to their audience. The `DAU/WAU` does the same thing, only for a shorter period. The higher the ratio (percentage), the “stickier” your product or service. The `DAU/MAU` ratio is particularly helpful for early-stage companies, as it allows leadership teams to evaluate traction and predict revenue.

Using the ratio (rather than DAU, WAU, or MAU alone) provides you with context—a comparison point—so you can better understand the level of engagement with your products or services.

Pro tip: Rather than waiting for problems to arise, your team should offer proactive support. This will help increase DAU and reduce churn. Regular communication with your users will enable you to better understand their goals so you can optimize their experience.


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

The criteria adopted for the definition of `dau` and `mau` are:

- **Daily active users** (`DAU`): the number of consumers that had activity within the `24 hours of the last first month`.
- **Monthly active users** (`MAU`): the number of consumers that had activity within the `last first month`.

In the logins table the `last first month` is `July 2022`. The output table should have the following columns:


- `month`: 5 characters column indicating the year and month. The first and last two characters indicate the last two digits of the year and month, respectively. For example, the value `22-07` indicates the month of July, (**07**) in `20`**22**.
- `day`: The day of the month    
- `dau`: daily active users in this `day`
- `mau`: monthly active users in this `month`
- `dau_mau_ratio`: the daily/monthly active users ratio.

```console
month |    day     | dau | mau | dau_mau_ratio
------+------------+-----+-----+---------------
22-07 | 2022-07-01 |   4 |  64 |          6.25
22-07 | 2022-07-02 |   3 |  64 |          4.69
22-07 | 2022-07-03 |   1 |  64 |          1.56
22-07 | 2022-07-04 |   0 |  64 |          0.00
22-07 | 2022-07-05 |   3 |  64 |          4.69
22-07 | 2022-07-06 |   2 |  64 |          3.13
22-07 | 2022-07-07 |   6 |  64 |          9.38
22-07 | 2022-07-08 |   5 |  64 |          7.81
22-07 | 2022-07-09 |   1 |  64 |          1.56
22-07 | 2022-07-10 |   2 |  64 |          3.13
22-07 | 2022-07-11 |   5 |  64 |          7.81
22-07 | 2022-07-12 |   2 |  64 |          3.13
22-07 | 2022-07-13 |   0 |  64 |          0.00
22-07 | 2022-07-14 |   3 |  64 |          4.69
22-07 | 2022-07-15 |   4 |  64 |          6.25
22-07 | 2022-07-16 |   1 |  64 |          1.56
22-07 | 2022-07-17 |   1 |  64 |          1.56
22-07 | 2022-07-18 |   0 |  64 |          0.00
22-07 | 2022-07-19 |   5 |  64 |          7.81
22-07 | 2022-07-20 |   1 |  64 |          1.56
22-07 | 2022-07-21 |   1 |  64 |          1.56
22-07 | 2022-07-22 |   4 |  64 |          6.25
22-07 | 2022-07-23 |   4 |  64 |          6.25
22-07 | 2022-07-24 |   3 |  64 |          4.69
22-07 | 2022-07-25 |   3 |  64 |          4.69
22-07 | 2022-07-26 |   5 |  64 |          7.81
22-07 | 2022-07-27 |   1 |  64 |          1.56
22-07 | 2022-07-28 |   2 |  64 |          3.13
22-07 | 2022-07-29 |   4 |  64 |          6.25
22-07 | 2022-07-30 |   6 |  64 |          9.38
22-07 | 2022-07-31 |   2 |  64 |          3.13
(31 rows)
```

### Problem 2


We want to transform the format of the output table in Problem 1.

```console
wk |    mo     |    tu     |    we     |    th     |    fr     |    sa     |    su
---+-----------+-----------+-----------+-----------+-----------+-----------+-----------
 1 |           |           |           |           | 1 (6.25)  | 2 (4.69)  | 3 (1.56)
 2 | 4 (0.00)  | 5 (4.69)  | 6 (3.13)  | 7 (9.38)  | 8 (7.81)  | 9 (1.56)  | 10 (3.13)
 3 | 11 (7.81) | 12 (3.13) | 13 (0.00) | 14 (4.69) | 15 (6.25) | 16 (1.56) | 17 (1.56)
 4 | 18 (0.00) | 19 (7.81) | 20 (1.56) | 21 (1.56) | 22 (6.25) | 23 (6.25) | 24 (4.69)
 5 | 25 (4.69) | 26 (7.81) | 27 (1.56) | 28 (3.13) | 29 (6.25) | 30 (9.38) | 31 (3.13)
(5 rows)
```

The output table must have the following columns:

- `wk`: The week number of the month.
- `mo`: day of the week `Monday`, in the current month
- `tu`: day of the week `Tuesday`, in the current month
-  `we`,`th`,`fr`,`sa`, `su`: the remaining days of the week.

The values in these columns are the day of the month followed by the `dau/mau` ratio. For example, in the last week of the month `wk = 5`, the value `30 (9.38)` indicates that `Saturday 30th` of this month (`July 2022`) the `dau/mau` ratio is `9.38%`.

### Problem 3

```console
wk        |    mo     |    tu     |    we     |    th     |    fr     |    sa     |    su
----------+-----------+-----------+-----------+-----------+-----------+-----------+-----------
1 (9.38)  |           |           |           |           | 1 (6.25)  | 2 (4.69)  | 3 (1.56)
2 (28.13) | 4 (0.00)  | 5 (4.69)  | 6 (3.13)  | 7 (9.38)  | 8 (7.81)  | 9 (1.56)  | 10 (3.13)
3 (25.00) | 11 (7.81) | 12 (3.13) | 13 (0.00) | 14 (4.69) | 15 (6.25) | 16 (1.56) | 17 (1.56)
4 (26.56) | 18 (0.00) | 19 (7.81) | 20 (1.56) | 21 (1.56) | 22 (6.25) | 23 (6.25) | 24 (4.69)
5 (34.38) | 25 (4.69) | 26 (7.81) | 27 (1.56) | 28 (3.13) | 29 (6.25) | 30 (9.38) | 31 (3.13)
(5 rows)
```

We wan to include to the output table of `problem 2` an additional column indicating the week number along with the `WAU/MAU`. For example, the value `5 (34.38)` in the column `wk` of this table indicates that in the last week `34.38%` of monthly activer users logged in.

## Solution

```SQL
-- Calculate the number of distinct users in the month before the current month
WITH last_month AS (
  SELECT DATE_TRUNC('month',day)::DATE AS mth,
         COUNT(DISTINCT user_id) AS mau
    FROM logins
   GROUP BY mth
   ORDER BY mth DESC
   OFFSET 1 ROW
   FETCH FIRST 1 ROW ONLY
) -- Generate a weekly day calendar for the last month
,calendar AS (
  SELECT  DATE_TRUNC('month',s.day_mth)::DATE AS month
        , s.day_mth::DATE AS day
    FROM GENERATE_SERIES((SELECT mth FROM last_month),
                         (SELECT (mth + INTERVAL '1 month')::DATE - 1 FROM last_month),
                          INTERVAL '1 day') AS s(day_mth)
) -- Calculate the DAU/MAU
,dau_mau AS (
  SELECT  c.month AS month
        , c.day AS day
        , COUNT(DISTINCT l.user_id) AS dau
        , lm.mau AS mau
    FROM calendar c
    LEFT JOIN logins l
      ON c.day = DATE_TRUNC('day',l.day)::DATE
   INNER JOIN last_month lm
      ON c.month = lm.mth
   GROUP BY c.month, c.day, lm.mau
)
SELECT  TO_CHAR(month,'YY-MM') AS month
      , day
      , dau
      , mau
      , ROUND((100.00*dau)/mau,2) AS dau_mau_ratio
  FROM dau_mau
 ORDER BY day;
```

### Problem 2

```SQL
WITH last_month AS (
  SELECT DATE_TRUNC('month',day)::DATE AS mth,
         COUNT(DISTINCT user_id) AS mau
    FROM logins
   GROUP BY mth
   ORDER BY mth DESC
   OFFSET 1 ROW
   FETCH FIRST 1 ROW ONLY
)
,calendar AS (
  SELECT  DATE_TRUNC('month',s.day_mth)::DATE AS month
        , s.day_mth::DATE AS day
    FROM GENERATE_SERIES((SELECT mth FROM last_month),
                         (SELECT (mth + INTERVAL '1 month')::DATE - 1 FROM last_month),
                          INTERVAL '1 day') AS s(day_mth)
)
,dau_mau AS (
  SELECT  c.month AS month
        , c.day AS day
        , COUNT(DISTINCT l.user_id) AS dau
        , lm.mau AS mau
    FROM calendar c
    LEFT JOIN logins l
      ON c.day = DATE_TRUNC('day',l.day)::DATE
   INNER JOIN last_month lm
      ON c.month = lm.mth
   GROUP BY c.month, c.day, lm.mau
)
,dau_mau_ratio AS (
  SELECT  EXTRACT('DAY' FROM day) AS day
        , EXTRACT('DOW' FROM day) AS dow
        , EXTRACT('WEEK' FROM day) AS wk
        , ROUND((100.00*dau)/mau,2) AS dau_mau_ratio
    FROM dau_mau
)
,dmr AS (
  SELECT *
        , day::TEXT || ' (' || dau_mau_ratio::TEXT || ')' AS day_dmr
    FROM dau_mau_ratio
)
SELECT  ROW_NUMBER() OVER(ORDER BY wk) AS Wk
       ,MAX(CASE WHEN dow = 1 THEN day_dmr END )AS Mo
       ,MAX(CASE WHEN dow = 2 THEN day_dmr END )AS Tu
       ,MAX(CASE WHEN dow = 3 THEN day_dmr END )AS We
       ,MAX(CASE WHEN dow = 4 THEN day_dmr END )AS Th
       ,MAX(CASE WHEN dow = 5 THEN day_dmr END )AS Fr
       ,MAX(CASE WHEN dow = 6 THEN day_dmr END )AS Sa
       ,MAX(CASE WHEN dow = 0 THEN day_dmr END )AS Su
  FROM dmr
 GROUP BY wk
 ORDER BY wk;
```

### Problem 3

```SQL
WITH last_month AS (
  SELECT DATE_TRUNC('month',day)::DATE AS mth,
         COUNT(DISTINCT user_id) AS mau
    FROM logins
   GROUP BY mth
   ORDER BY mth DESC
   OFFSET 1 ROW
   FETCH FIRST 1 ROW ONLY
)
,calendar AS (
  SELECT  DATE_TRUNC('month',s.day_mth)::DATE AS month
        , s.day_mth::DATE AS day
    FROM GENERATE_SERIES((SELECT mth FROM last_month),
                         (SELECT (mth + INTERVAL '1 month')::DATE - 1 FROM last_month),
                          INTERVAL '1 day') AS s(day_mth)
)
,logins_mau AS (
  SELECT  c.month AS month
        , EXTRACT('WEEK' FROM c.day) AS wk
        , EXTRACT('DOW' FROM c.day) AS dow
        , EXTRACT('DAY' FROM c.day) AS day
        , l.user_id AS user_id
        , lm.mau AS mau
    FROM calendar c
    LEFT JOIN logins l
      ON c.day = DATE_TRUNC('day',l.day)::DATE
   INNER JOIN last_month lm
      ON c.month = lm.mth
)
,wau_mau AS (
  SELECT  month
        , wk
        , COUNT(DISTINCT user_id) AS wau
        , mau
    FROM logins_mau
   GROUP BY month, wk, mau
   ORDER BY month, wk
)
,dau_mau AS (
  SELECT  month
        , wk
        , dow
        , day
        , COUNT(DISTINCT user_id) AS dau
        , mau
    FROM logins_mau
   GROUP BY month, wk, dow, day, mau
   ORDER BY month, wk, day
)
, wau_dau_mau AS (
  SELECT  wm.month AS month
        , wm.wk AS wk
        , dm.dow AS dow
        , dm.day AS day
        , wm.wau AS wau
        , dm.dau AS dau
        , wm.mau AS mau
        , ROUND((100.00*wau)/wm.mau,2) AS wau_mau_ratio
        , ROUND((100.00*dau)/wm.mau,2) AS dau_mau_ratio
    FROM wau_mau wm
   INNER JOIN dau_mau dm
      ON wm.wk = dm.wk
)
,mr AS (
  SELECT  wk
        , dow
        , ' (' || wau_mau_ratio::TEXT || ')' AS week_wmr
        , day::TEXT || ' (' || dau_mau_ratio::TEXT || ')' AS day_dmr
    FROM wau_dau_mau
)
SELECT  ROW_NUMBER() OVER(ORDER BY wk, week_wmr) || week_wmr AS Wk
       ,MAX(CASE WHEN dow = 1 THEN day_dmr END )AS Mo
       ,MAX(CASE WHEN dow = 2 THEN day_dmr END )AS Tu
       ,MAX(CASE WHEN dow = 3 THEN day_dmr END )AS We
       ,MAX(CASE WHEN dow = 4 THEN day_dmr END )AS Th
       ,MAX(CASE WHEN dow = 5 THEN day_dmr END )AS Fr
       ,MAX(CASE WHEN dow = 6 THEN day_dmr END )AS Sa
       ,MAX(CASE WHEN dow = 0 THEN day_dmr END )AS Su
  FROM mr
 GROUP BY wk, week_wmr
 ORDER BY wk;
```



## Discussion

First we create some synthetic data for our query. You can do the same on your system.

```SQL
SELECT NOW() - ((FLOOR(RANDOM() * 120) + 1) * INTERVAL '1 day') AS day;
```
This function generate a random date in the last 120 days.

```console
day
-------------------------------
2022-05-04 01:28:34.815546+10
```

Next we want to generate 100 users and 1000 logins. In other words, we generate 1000 random records with two columns:

- id: A number between `1-100`
- day: A random date in the last 365 days.

```SQL
CREATE TABLE logins AS
WITH log_id AS (
  SELECT GENERATE_SERIES(1,1000) AS id
)
SELECT  id
      , (FLOOR(RANDOM() * 100) + 1)::INTEGER AS user_id
      , (NOW() - ((FLOOR(RANDOM() * 365) + 1) * INTERVAL '1 day'))::TIMESTAMP AS day
  FROM log_id;
```

If you want to code along with me  create the `logins` table as follow:

```SQL
CREATE TABLE logins (
  id INTEGER,
  user_id INTEGER,
  day TIMESTAMP
);
```

And populate the table using the [insert_logins.sql](./insert_logins.sql) file. 

Now, we can solve the **Problem**.

## Monthly and Daily Active Users

```SQL
SELECT DATE_TRUNC('month',day)::DATE AS mth,
       COUNT(DISTINCT user_id) AS mau
  FROM logins
 GROUP BY mth
 ORDER BY mth;
```

First we count for each month the number of distinct users.

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
2022-07-01 |  64 <---
2022-08-01 |  60
(12 rows)
```

Suppose, we want to track only the users' activity in the first last month. In this case, the month of `July 2022`.

```SQL
WITH last_month AS (
  SELECT DATE_TRUNC('month',day)::DATE AS mth,
         COUNT(DISTINCT user_id) AS mau
    FROM logins
   GROUP BY mth
   ORDER BY mth DESC
   OFFSET 1 ROW
   FETCH FIRST 1 ROW ONLY
)
SELECT *
  FROM last_month;
```

```console
mth        | mau
-----------+-----
2022-07-01 |  64
```

Next, count the daily number of distinct users in `JULY 2022`. In order to do that we need to create a daily calendar of July as we are not absolutely sure users had activity in each day of the month.


```SQL
WITH last_month AS (
  SELECT DATE_TRUNC('month',day)::DATE AS mth,
         COUNT(DISTINCT user_id) AS mau
    FROM logins
   GROUP BY mth
   ORDER BY mth DESC
   OFFSET 1 ROW
   FETCH FIRST 1 ROW ONLY
)
,calendar AS (
  SELECT  DATE_TRUNC('month',s.day_mth)::DATE AS month
        , s.day_mth::DATE AS day
    FROM GENERATE_SERIES((SELECT mth FROM last_month),
                         (SELECT (mth + INTERVAL '1 month')::DATE - 1 FROM last_month),
                          INTERVAL '1 day') AS s(day_mth)
)
SELECT *
  FROM calendar;
```

```console
month      |    day
-----------+------------
2022-07-01 | 2022-07-01
2022-07-01 | 2022-07-02
2022-07-01 | 2022-07-03
2022-07-01 | 2022-07-04
2022-07-01 | 2022-07-05
2022-07-01 | 2022-07-06
2022-07-01 | 2022-07-07
2022-07-01 | 2022-07-08
2022-07-01 | 2022-07-09
2022-07-01 | 2022-07-10
2022-07-01 | 2022-07-11
2022-07-01 | 2022-07-12
2022-07-01 | 2022-07-13
2022-07-01 | 2022-07-14
2022-07-01 | 2022-07-15
2022-07-01 | 2022-07-16
2022-07-01 | 2022-07-17
2022-07-01 | 2022-07-18
2022-07-01 | 2022-07-19
2022-07-01 | 2022-07-20
2022-07-01 | 2022-07-21
2022-07-01 | 2022-07-22
2022-07-01 | 2022-07-23
2022-07-01 | 2022-07-24
2022-07-01 | 2022-07-25
2022-07-01 | 2022-07-26
2022-07-01 | 2022-07-27
2022-07-01 | 2022-07-28
2022-07-01 | 2022-07-29
2022-07-01 | 2022-07-30
2022-07-01 | 2022-07-31
(31 rows)
```


Next, join the calendar table with the logins user table based on the login day.

```SQL
WITH last_month AS (
  SELECT DATE_TRUNC('month',day)::DATE AS mth,
         COUNT(DISTINCT user_id) AS mau
    FROM logins
   GROUP BY mth
   ORDER BY mth DESC
   OFFSET 1 ROW
   FETCH FIRST 1 ROW ONLY
)
,calendar AS (
  SELECT  DATE_TRUNC('month',s.day_mth)::DATE AS month
        , s.day_mth::DATE AS day
    FROM GENERATE_SERIES((SELECT mth FROM last_month),
                         (SELECT (mth + INTERVAL '1 month')::DATE - 1 FROM last_month),
                          INTERVAL '1 day') AS s(day_mth)
)
SELECT  c.month AS month
      , c.day AS day
      , l.user_id AS user_id
  FROM calendar c
  LEFT JOIN logins l
    ON c.day = DATE_TRUNC('day',l.day)::DATE
 ORDER BY day;
```

```console
month      |    day     | user_id
-----------+------------+---------
2022-07-01 | 2022-07-01 |      27
2022-07-01 | 2022-07-01 |      23
2022-07-01 | 2022-07-01 |      80
2022-07-01 | 2022-07-01 |      95
2022-07-01 | 2022-07-02 |      80
2022-07-01 | 2022-07-02 |      22
2022-07-01 | 2022-07-02 |      28
2022-07-01 | 2022-07-03 |      22
2022-07-01 | 2022-07-04 |
2022-07-01 | 2022-07-05 |      64
2022-07-01 | 2022-07-05 |      44
2022-07-01 | 2022-07-05 |      60
2022-07-01 | 2022-07-06 |      88
2022-07-01 | 2022-07-06 |      77
2022-07-01 | 2022-07-07 |      13
2022-07-01 | 2022-07-07 |      74
2022-07-01 | 2022-07-07 |      31
2022-07-01 | 2022-07-07 |      21
2022-07-01 | 2022-07-07 |      88
2022-07-01 | 2022-07-07 |      67
2022-07-01 | 2022-07-08 |      35
2022-07-01 | 2022-07-08 |      98
2022-07-01 | 2022-07-08 |      69
2022-07-01 | 2022-07-08 |      57
2022-07-01 | 2022-07-08 |      20
2022-07-01 | 2022-07-09 |       3
2022-07-01 | 2022-07-10 |      92
2022-07-01 | 2022-07-10 |      95
2022-07-01 | 2022-07-11 |      63
2022-07-01 | 2022-07-11 |      67
2022-07-01 | 2022-07-11 |      34
2022-07-01 | 2022-07-11 |       7
2022-07-01 | 2022-07-11 |      39
2022-07-01 | 2022-07-12 |      58
2022-07-01 | 2022-07-12 |      14
2022-07-01 | 2022-07-13 |
2022-07-01 | 2022-07-14 |      37
2022-07-01 | 2022-07-14 |      84
2022-07-01 | 2022-07-14 |      69
2022-07-01 | 2022-07-15 |      43
2022-07-01 | 2022-07-15 |      49
2022-07-01 | 2022-07-15 |      72
2022-07-01 | 2022-07-15 |      17
2022-07-01 | 2022-07-16 |      48
2022-07-01 | 2022-07-17 |      90
2022-07-01 | 2022-07-18 |
2022-07-01 | 2022-07-19 |      15
2022-07-01 | 2022-07-19 |      27
2022-07-01 | 2022-07-19 |      85
2022-07-01 | 2022-07-19 |      82
2022-07-01 | 2022-07-19 |      42
2022-07-01 | 2022-07-20 |      95
2022-07-01 | 2022-07-21 |      54
2022-07-01 | 2022-07-22 |      12
2022-07-01 | 2022-07-22 |      46
2022-07-01 | 2022-07-22 |      33
2022-07-01 | 2022-07-22 |      55
2022-07-01 | 2022-07-23 |      28
2022-07-01 | 2022-07-23 |      67
2022-07-01 | 2022-07-23 |      28
2022-07-01 | 2022-07-23 |      27
2022-07-01 | 2022-07-23 |      44
2022-07-01 | 2022-07-24 |      13
2022-07-01 | 2022-07-24 |      96
2022-07-01 | 2022-07-24 |      11
2022-07-01 | 2022-07-25 |      73
2022-07-01 | 2022-07-25 |      18
2022-07-01 | 2022-07-25 |      45
2022-07-01 | 2022-07-26 |      32
2022-07-01 | 2022-07-26 |      22
2022-07-01 | 2022-07-26 |      40
2022-07-01 | 2022-07-26 |      83
2022-07-01 | 2022-07-26 |      68
2022-07-01 | 2022-07-27 |      37
2022-07-01 | 2022-07-28 |      26
2022-07-01 | 2022-07-28 |      96
2022-07-01 | 2022-07-29 |      29
2022-07-01 | 2022-07-29 |      75
2022-07-01 | 2022-07-29 |      82
2022-07-01 | 2022-07-29 |      79
2022-07-01 | 2022-07-30 |     100
2022-07-01 | 2022-07-30 |      49
2022-07-01 | 2022-07-30 |       4
2022-07-01 | 2022-07-30 |      52
2022-07-01 | 2022-07-30 |      64
2022-07-01 | 2022-07-30 |       9
2022-07-01 | 2022-07-31 |      73
2022-07-01 | 2022-07-31 |       1
(88 rows)
```

Next, count the number of daily distinct users in the current month,`dau`.

```SQL
WITH last_month AS (
  SELECT DATE_TRUNC('month',day)::DATE AS mth,
         COUNT(DISTINCT user_id) AS mau
    FROM logins
   GROUP BY mth
   ORDER BY mth DESC
   OFFSET 1 ROW
   FETCH FIRST 1 ROW ONLY
)
,calendar AS (
  SELECT  DATE_TRUNC('month',s.day_mth)::DATE AS month
        , s.day_mth::DATE AS day
    FROM GENERATE_SERIES((SELECT mth FROM last_month),
                         (SELECT (mth + INTERVAL '1 month')::DATE - 1 FROM last_month),
                          INTERVAL '1 day') AS s(day_mth)
)
SELECT  c.month AS month
      , c.day AS day
      , COUNT(DISTINCT l.user_id) AS dau
  FROM calendar c
  LEFT JOIN logins l
    ON c.day = DATE_TRUNC('day',l.day)::DATE
 GROUP BY c.month, c.day
 ORDER BY day;
```

```console
month      |    day     | dau
-----------+------------+-----
2022-07-01 | 2022-07-01 |   4
2022-07-01 | 2022-07-02 |   3
2022-07-01 | 2022-07-03 |   1
2022-07-01 | 2022-07-04 |   0
2022-07-01 | 2022-07-05 |   3
2022-07-01 | 2022-07-06 |   2
2022-07-01 | 2022-07-07 |   6
2022-07-01 | 2022-07-08 |   5
2022-07-01 | 2022-07-09 |   1
2022-07-01 | 2022-07-10 |   2
2022-07-01 | 2022-07-11 |   5
2022-07-01 | 2022-07-12 |   2
2022-07-01 | 2022-07-13 |   0
2022-07-01 | 2022-07-14 |   3
2022-07-01 | 2022-07-15 |   4
2022-07-01 | 2022-07-16 |   1
2022-07-01 | 2022-07-17 |   1
2022-07-01 | 2022-07-18 |   0
2022-07-01 | 2022-07-19 |   5
2022-07-01 | 2022-07-20 |   1
2022-07-01 | 2022-07-21 |   1
2022-07-01 | 2022-07-22 |   4
2022-07-01 | 2022-07-23 |   4
2022-07-01 | 2022-07-24 |   3
2022-07-01 | 2022-07-25 |   3
2022-07-01 | 2022-07-26 |   5
2022-07-01 | 2022-07-27 |   1
2022-07-01 | 2022-07-28 |   2
2022-07-01 | 2022-07-29 |   4
2022-07-01 | 2022-07-30 |   6
2022-07-01 | 2022-07-31 |   2
(31 rows)
```

Next, compute the monthly active users and the final ratio. We can remove the count operation in the `last_month` table.


```SQL
WITH last_month AS (
  SELECT DATE_TRUNC('month',day)::DATE AS mth,
         COUNT(DISTINCT user_id) AS mau
    FROM logins
   GROUP BY mth
   ORDER BY mth DESC
   OFFSET 1 ROW
   FETCH FIRST 1 ROW ONLY
)
,calendar AS (
  SELECT  DATE_TRUNC('month',s.day_mth)::DATE AS month
        , s.day_mth::DATE AS day
    FROM GENERATE_SERIES((SELECT mth FROM last_month),
                         (SELECT (mth + INTERVAL '1 month')::DATE - 1 FROM last_month),
                          INTERVAL '1 day') AS s(day_mth)
)
SELECT  c.month AS month
      , c.day AS day
      , COUNT(DISTINCT l.user_id) AS dau
      , lm.mau AS mau
  FROM calendar c
  LEFT JOIN logins l
    ON c.day = DATE_TRUNC('day',l.day)::DATE
 INNER JOIN last_month lm
    ON c.month = lm.mth
 GROUP BY c.month, c.day, lm.mau
 ORDER BY day;
```

```console
month      |    day     | dau | mau
-----------+------------+-----+-----
2022-07-01 | 2022-07-01 |   4 |  64
2022-07-01 | 2022-07-02 |   3 |  64
2022-07-01 | 2022-07-03 |   1 |  64
2022-07-01 | 2022-07-04 |   0 |  64
2022-07-01 | 2022-07-05 |   3 |  64
2022-07-01 | 2022-07-06 |   2 |  64
2022-07-01 | 2022-07-07 |   6 |  64
2022-07-01 | 2022-07-08 |   5 |  64
2022-07-01 | 2022-07-09 |   1 |  64
2022-07-01 | 2022-07-10 |   2 |  64
2022-07-01 | 2022-07-11 |   5 |  64
2022-07-01 | 2022-07-12 |   2 |  64
2022-07-01 | 2022-07-13 |   0 |  64
2022-07-01 | 2022-07-14 |   3 |  64
2022-07-01 | 2022-07-15 |   4 |  64
2022-07-01 | 2022-07-16 |   1 |  64
2022-07-01 | 2022-07-17 |   1 |  64
2022-07-01 | 2022-07-18 |   0 |  64
2022-07-01 | 2022-07-19 |   5 |  64
2022-07-01 | 2022-07-20 |   1 |  64
2022-07-01 | 2022-07-21 |   1 |  64
2022-07-01 | 2022-07-22 |   4 |  64
2022-07-01 | 2022-07-23 |   4 |  64
2022-07-01 | 2022-07-24 |   3 |  64
2022-07-01 | 2022-07-25 |   3 |  64
2022-07-01 | 2022-07-26 |   5 |  64
2022-07-01 | 2022-07-27 |   1 |  64
2022-07-01 | 2022-07-28 |   2 |  64
2022-07-01 | 2022-07-29 |   4 |  64
2022-07-01 | 2022-07-30 |   6 |  64
2022-07-01 | 2022-07-31 |   2 |  64
(31 rows)
```

Finally, compute the dau/mau ratio.

```SQL
WITH last_month AS (
  SELECT DATE_TRUNC('month',day)::DATE AS mth,
         COUNT(DISTINCT user_id) AS mau
    FROM logins
   GROUP BY mth
   ORDER BY mth DESC
   OFFSET 1 ROW
   FETCH FIRST 1 ROW ONLY
)
,calendar AS (
  SELECT  DATE_TRUNC('month',s.day_mth)::DATE AS month
        , s.day_mth::DATE AS day
    FROM GENERATE_SERIES((SELECT mth FROM last_month),
                         (SELECT (mth + INTERVAL '1 month')::DATE - 1 FROM last_month),
                          INTERVAL '1 day') AS s(day_mth)
)
,dau_mau AS (
  SELECT  c.month AS month
        , c.day AS day
        , COUNT(DISTINCT l.user_id) AS dau
        , lm.mau AS mau
    FROM calendar c
    LEFT JOIN logins l
      ON c.day = DATE_TRUNC('day',l.day)::DATE
   INNER JOIN last_month lm
      ON c.month = lm.mth
   GROUP BY c.month, c.day, lm.mau
)
SELECT  TO_CHAR(month,'YY-MM') AS month
      , day
      , dau
      , mau
      , ROUND((100.00*dau)/mau,2) AS dau_mau_ratio
  FROM dau_mau
 ORDER BY day;
```

```console
month |    day     | dau | mau | dau_mau_ratio
------+------------+-----+-----+---------------
22-07 | 2022-07-01 |   4 |  64 |          6.25
22-07 | 2022-07-02 |   3 |  64 |          4.69
22-07 | 2022-07-03 |   1 |  64 |          1.56
22-07 | 2022-07-04 |   0 |  64 |          0.00
22-07 | 2022-07-05 |   3 |  64 |          4.69
22-07 | 2022-07-06 |   2 |  64 |          3.13
22-07 | 2022-07-07 |   6 |  64 |          9.38
22-07 | 2022-07-08 |   5 |  64 |          7.81
22-07 | 2022-07-09 |   1 |  64 |          1.56
22-07 | 2022-07-10 |   2 |  64 |          3.13
22-07 | 2022-07-11 |   5 |  64 |          7.81
22-07 | 2022-07-12 |   2 |  64 |          3.13
22-07 | 2022-07-13 |   0 |  64 |          0.00
22-07 | 2022-07-14 |   3 |  64 |          4.69
22-07 | 2022-07-15 |   4 |  64 |          6.25
22-07 | 2022-07-16 |   1 |  64 |          1.56
22-07 | 2022-07-17 |   1 |  64 |          1.56
22-07 | 2022-07-18 |   0 |  64 |          0.00
22-07 | 2022-07-19 |   5 |  64 |          7.81
22-07 | 2022-07-20 |   1 |  64 |          1.56
22-07 | 2022-07-21 |   1 |  64 |          1.56
22-07 | 2022-07-22 |   4 |  64 |          6.25
22-07 | 2022-07-23 |   4 |  64 |          6.25
22-07 | 2022-07-24 |   3 |  64 |          4.69
22-07 | 2022-07-25 |   3 |  64 |          4.69
22-07 | 2022-07-26 |   5 |  64 |          7.81
22-07 | 2022-07-27 |   1 |  64 |          1.56
22-07 | 2022-07-28 |   2 |  64 |          3.13
22-07 | 2022-07-29 |   4 |  64 |          6.25
22-07 | 2022-07-30 |   6 |  64 |          9.38
22-07 | 2022-07-31 |   2 |  64 |          3.13
(31 rows)
```

## Problem 2

```SQL
WITH last_month AS (
  SELECT DATE_TRUNC('month',day)::DATE AS mth,
         COUNT(DISTINCT user_id) AS mau
    FROM logins
   GROUP BY mth
   ORDER BY mth DESC
   OFFSET 1 ROW
   FETCH FIRST 1 ROW ONLY
)
,calendar AS (
  SELECT  DATE_TRUNC('month',s.day_mth)::DATE AS month
        , s.day_mth::DATE AS day
    FROM GENERATE_SERIES((SELECT mth FROM last_month),
                         (SELECT (mth + INTERVAL '1 month')::DATE - 1 FROM last_month),
                          INTERVAL '1 day') AS s(day_mth)
)
,dau_mau AS (
  SELECT  c.month AS month
        , c.day AS day
        , COUNT(DISTINCT l.user_id) AS dau
        , lm.mau AS mau
    FROM calendar c
    LEFT JOIN logins l
      ON c.day = DATE_TRUNC('day',l.day)::DATE
   INNER JOIN last_month lm
      ON c.month = lm.mth
   GROUP BY c.month, c.day, lm.mau
)
,dau_mau_ratio AS (
  SELECT  EXTRACT('DAY' FROM day) AS day
        , EXTRACT('DOW' FROM day) AS dow
        , EXTRACT('WEEK' FROM day) AS wk
        , ROUND((100.00*dau)/mau,2) AS dau_mau_ratio
    FROM dau_mau
)
SELECT *
      , day::TEXT || ' (' || dau_mau_ratio::TEXT || ')' AS day_dmr
  FROM dau_mau_ratio
 ORDER BY day;
```

```console
day | dow | wk | dau_mau_ratio |  day_dmr
-----+-----+----+---------------+-----------
  1 |   5 | 26 |          6.25 | 1 (6.25)
  2 |   6 | 26 |          4.69 | 2 (4.69)
  3 |   0 | 26 |          1.56 | 3 (1.56)
  4 |   1 | 27 |          0.00 | 4 (0.00)
  5 |   2 | 27 |          4.69 | 5 (4.69)
  6 |   3 | 27 |          3.13 | 6 (3.13)
  7 |   4 | 27 |          9.38 | 7 (9.38)
  8 |   5 | 27 |          7.81 | 8 (7.81)
  9 |   6 | 27 |          1.56 | 9 (1.56)
 10 |   0 | 27 |          3.13 | 10 (3.13)
 11 |   1 | 28 |          7.81 | 11 (7.81)
 12 |   2 | 28 |          3.13 | 12 (3.13)
 13 |   3 | 28 |          0.00 | 13 (0.00)
 14 |   4 | 28 |          4.69 | 14 (4.69)
 15 |   5 | 28 |          6.25 | 15 (6.25)
 16 |   6 | 28 |          1.56 | 16 (1.56)
 17 |   0 | 28 |          1.56 | 17 (1.56)
 18 |   1 | 29 |          0.00 | 18 (0.00)
 19 |   2 | 29 |          7.81 | 19 (7.81)
 20 |   3 | 29 |          1.56 | 20 (1.56)
 21 |   4 | 29 |          1.56 | 21 (1.56)
 22 |   5 | 29 |          6.25 | 22 (6.25)
 23 |   6 | 29 |          6.25 | 23 (6.25)
 24 |   0 | 29 |          4.69 | 24 (4.69)
 25 |   1 | 30 |          4.69 | 25 (4.69)
 26 |   2 | 30 |          7.81 | 26 (7.81)
 27 |   3 | 30 |          1.56 | 27 (1.56)
 28 |   4 | 30 |          3.13 | 28 (3.13)
 29 |   5 | 30 |          6.25 | 29 (6.25)
 30 |   6 | 30 |          9.38 | 30 (9.38)
 31 |   0 | 30 |          3.13 | 31 (3.13)
(31 rows)
```

Next, pivot the table on the basis of week and day of the week.

```SQL
WITH last_month AS (
  SELECT DATE_TRUNC('month',day)::DATE AS mth,
         COUNT(DISTINCT user_id) AS mau
    FROM logins
   GROUP BY mth
   ORDER BY mth DESC
   OFFSET 1 ROW
   FETCH FIRST 1 ROW ONLY
)
,calendar AS (
  SELECT  DATE_TRUNC('month',s.day_mth)::DATE AS month
        , s.day_mth::DATE AS day
    FROM GENERATE_SERIES((SELECT mth FROM last_month),
                         (SELECT (mth + INTERVAL '1 month')::DATE - 1 FROM last_month),
                          INTERVAL '1 day') AS s(day_mth)
)
,dau_mau AS (
  SELECT  c.month AS month
        , c.day AS day
        , COUNT(DISTINCT l.user_id) AS dau
        , lm.mau AS mau
    FROM calendar c
    LEFT JOIN logins l
      ON c.day = DATE_TRUNC('day',l.day)::DATE
   INNER JOIN last_month lm
      ON c.month = lm.mth
   GROUP BY c.month, c.day, lm.mau
)
,dau_mau_ratio AS (
  SELECT  EXTRACT('DAY' FROM day) AS day
        , EXTRACT('DOW' FROM day) AS dow
        , EXTRACT('WEEK' FROM day) AS wk
        , ROUND((100.00*dau)/mau,2) AS dau_mau_ratio
    FROM dau_mau
)
,dmr AS (
  SELECT *
        , day::TEXT || ' (' || dau_mau_ratio::TEXT || ')' AS day_dmr
    FROM dau_mau_ratio
)
SELECT  ROW_NUMBER() OVER(ORDER BY wk) AS Wk
       ,MAX(CASE WHEN dow = 1 THEN day_dmr END )AS Mo
       ,MAX(CASE WHEN dow = 2 THEN day_dmr END )AS Tu
       ,MAX(CASE WHEN dow = 3 THEN day_dmr END )AS We
       ,MAX(CASE WHEN dow = 4 THEN day_dmr END )AS Th
       ,MAX(CASE WHEN dow = 5 THEN day_dmr END )AS Fr
       ,MAX(CASE WHEN dow = 6 THEN day_dmr END )AS Sa
       ,MAX(CASE WHEN dow = 0 THEN day_dmr END )AS Su
  FROM dmr
 GROUP BY wk
 ORDER BY wk;
```

```console
wk |    mo     |    tu     |    we     |    th     |    fr     |    sa     |    su
---+-----------+-----------+-----------+-----------+-----------+-----------+-----------
 1 |           |           |           |           | 1 (6.25)  | 2 (4.69)  | 3 (1.56)
 2 | 4 (0.00)  | 5 (4.69)  | 6 (3.13)  | 7 (9.38)  | 8 (7.81)  | 9 (1.56)  | 10 (3.13)
 3 | 11 (7.81) | 12 (3.13) | 13 (0.00) | 14 (4.69) | 15 (6.25) | 16 (1.56) | 17 (1.56)
 4 | 18 (0.00) | 19 (7.81) | 20 (1.56) | 21 (1.56) | 22 (6.25) | 23 (6.25) | 24 (4.69)
 5 | 25 (4.69) | 26 (7.81) | 27 (1.56) | 28 (3.13) | 29 (6.25) | 30 (9.38) | 31 (3.13)
(5 rows)
```

## Problem 3

```SQL
WITH last_month AS (
  SELECT DATE_TRUNC('month',day)::DATE AS mth,
         COUNT(DISTINCT user_id) AS mau
    FROM logins
   GROUP BY mth
   ORDER BY mth DESC
   OFFSET 1 ROW
   FETCH FIRST 1 ROW ONLY
)
,calendar AS (
  SELECT  DATE_TRUNC('month',s.day_mth)::DATE AS month
        , s.day_mth::DATE AS day
    FROM GENERATE_SERIES((SELECT mth FROM last_month),
                         (SELECT (mth + INTERVAL '1 month')::DATE - 1 FROM last_month),
                          INTERVAL '1 day') AS s(day_mth)
)
,logins_mau AS (
  SELECT  c.month AS month
        , EXTRACT('WEEK' FROM c.day) AS wk
        , EXTRACT('DAY' FROM c.day) AS day
        , l.user_id AS user_id
        , lm.mau AS mau
    FROM calendar c
    LEFT JOIN logins l
      ON c.day = DATE_TRUNC('day',l.day)::DATE
   INNER JOIN last_month lm
      ON c.month = lm.mth
)
,wau_mau AS(
  SELECT  month
        , wk
        , COUNT(DISTINCT user_id) AS wau
        , mau
    FROM logins_mau
   GROUP BY month, wk, mau
   ORDER BY month, wk
)

SELECT *
  FROM wau_mau;
```

Let's first compute the `WAU/MAU`:

```console
month      | wk | wau | mau
-----------+----+-----+-----
2022-07-01 | 26 |   6 |  64
2022-07-01 | 27 |  18 |  64
2022-07-01 | 28 |  16 |  64
2022-07-01 | 29 |  17 |  64
2022-07-01 | 30 |  22 |  64
(5 rows)
```

Next, compute the `DAU/MAU`:

```SQL
WITH last_month AS (
  SELECT DATE_TRUNC('month',day)::DATE AS mth,
         COUNT(DISTINCT user_id) AS mau
    FROM logins
   GROUP BY mth
   ORDER BY mth DESC
   OFFSET 1 ROW
   FETCH FIRST 1 ROW ONLY
)
,calendar AS (
  SELECT  DATE_TRUNC('month',s.day_mth)::DATE AS month
        , s.day_mth::DATE AS day
    FROM GENERATE_SERIES((SELECT mth FROM last_month),
                         (SELECT (mth + INTERVAL '1 month')::DATE - 1 FROM last_month),
                          INTERVAL '1 day') AS s(day_mth)
)
,logins_mau AS (
  SELECT  c.month AS month
        , EXTRACT('WEEK' FROM c.day) AS wk
        , EXTRACT('DAY' FROM c.day) AS day
        , l.user_id AS user_id
        , lm.mau AS mau
    FROM calendar c
    LEFT JOIN logins l
      ON c.day = DATE_TRUNC('day',l.day)::DATE
   INNER JOIN last_month lm
      ON c.month = lm.mth
)
,wau_mau AS (
  SELECT  month
        , wk
        , COUNT(DISTINCT user_id) AS wau
        , mau
    FROM logins_mau
   GROUP BY month, wk, mau
   ORDER BY month, wk
)
,dau_mau AS (
  SELECT  month
        , wk
        , day
        , COUNT(DISTINCT user_id) AS dau
        , mau
    FROM logins_mau
   GROUP BY month, wk, day, mau
   ORDER BY month, wk, day
)
SELECT *
  FROM dau_mau;
```

```console
month      | wk | day | dau | mau
-----------+----+-----+-----+-----
2022-07-01 | 26 |   1 |   4 |  64
2022-07-01 | 26 |   2 |   3 |  64
2022-07-01 | 26 |   3 |   1 |  64
2022-07-01 | 27 |   4 |   0 |  64
2022-07-01 | 27 |   5 |   3 |  64
2022-07-01 | 27 |   6 |   2 |  64
2022-07-01 | 27 |   7 |   6 |  64
2022-07-01 | 27 |   8 |   5 |  64
2022-07-01 | 27 |   9 |   1 |  64
2022-07-01 | 27 |  10 |   2 |  64
2022-07-01 | 28 |  11 |   5 |  64
2022-07-01 | 28 |  12 |   2 |  64
2022-07-01 | 28 |  13 |   0 |  64
2022-07-01 | 28 |  14 |   3 |  64
2022-07-01 | 28 |  15 |   4 |  64
2022-07-01 | 28 |  16 |   1 |  64
2022-07-01 | 28 |  17 |   1 |  64
2022-07-01 | 29 |  18 |   0 |  64
2022-07-01 | 29 |  19 |   5 |  64
2022-07-01 | 29 |  20 |   1 |  64
2022-07-01 | 29 |  21 |   1 |  64
2022-07-01 | 29 |  22 |   4 |  64
2022-07-01 | 29 |  23 |   4 |  64
2022-07-01 | 29 |  24 |   3 |  64
2022-07-01 | 30 |  25 |   3 |  64
2022-07-01 | 30 |  26 |   5 |  64
2022-07-01 | 30 |  27 |   1 |  64
2022-07-01 | 30 |  28 |   2 |  64
2022-07-01 | 30 |  29 |   4 |  64
2022-07-01 | 30 |  30 |   6 |  64
2022-07-01 | 30 |  31 |   2 |  64
(31 rows)
```

Next, join both tables and compute the `DAU/MAU` and `WAU/MAU` metrics.

```SQL
WITH last_month AS (
  SELECT DATE_TRUNC('month',day)::DATE AS mth,
         COUNT(DISTINCT user_id) AS mau
    FROM logins
   GROUP BY mth
   ORDER BY mth DESC
   OFFSET 1 ROW
   FETCH FIRST 1 ROW ONLY
)
,calendar AS (
  SELECT  DATE_TRUNC('month',s.day_mth)::DATE AS month
        , s.day_mth::DATE AS day
    FROM GENERATE_SERIES((SELECT mth FROM last_month),
                         (SELECT (mth + INTERVAL '1 month')::DATE - 1 FROM last_month),
                          INTERVAL '1 day') AS s(day_mth)
)
,logins_mau AS (
  SELECT  c.month AS month
        , EXTRACT('WEEK' FROM c.day) AS wk
        , EXTRACT('DOW' FROM c.day) AS dow
        , EXTRACT('DAY' FROM c.day) AS day
        , l.user_id AS user_id
        , lm.mau AS mau
    FROM calendar c
    LEFT JOIN logins l
      ON c.day = DATE_TRUNC('day',l.day)::DATE
   INNER JOIN last_month lm
      ON c.month = lm.mth
)
,wau_mau AS (
  SELECT  month
        , wk
        , COUNT(DISTINCT user_id) AS wau
        , mau
    FROM logins_mau
   GROUP BY month, wk, mau
   ORDER BY month, wk
)
,dau_mau AS (
  SELECT  month
        , wk
        , dow
        , day
        , COUNT(DISTINCT user_id) AS dau
        , mau
    FROM logins_mau
   GROUP BY month, wk, dow, day, mau
   ORDER BY month, wk, day
)
SELECT  wm.month AS month
      , wm.wk AS wk
      , dm.dow AS dow
      , dm.day AS day
      , wm.wau AS wau
      , dm.dau AS dau
      , wm.mau AS mau
      , ROUND((100.00*wau)/wm.mau,2) AS wau_mau_ratio
      , ROUND((100.00*dau)/wm.mau,2) AS dau_mau_ratio
  FROM wau_mau wm
 INNER JOIN dau_mau dm
    ON wm.wk = dm.wk
 ORDER BY wm.month, wm.wk, dm.day;
```

```console
month      | wk | dow | day | wau | dau | mau | wau_mau_ratio | dau_mau_ratio
-----------+----+-----+-----+-----+-----+-----+---------------+---------------
2022-07-01 | 26 |   5 |   1 |   6 |   4 |  64 |          9.38 |          6.25
2022-07-01 | 26 |   6 |   2 |   6 |   3 |  64 |          9.38 |          4.69
2022-07-01 | 26 |   0 |   3 |   6 |   1 |  64 |          9.38 |          1.56
2022-07-01 | 27 |   1 |   4 |  18 |   0 |  64 |         28.13 |          0.00
2022-07-01 | 27 |   2 |   5 |  18 |   3 |  64 |         28.13 |          4.69
2022-07-01 | 27 |   3 |   6 |  18 |   2 |  64 |         28.13 |          3.13
2022-07-01 | 27 |   4 |   7 |  18 |   6 |  64 |         28.13 |          9.38
2022-07-01 | 27 |   5 |   8 |  18 |   5 |  64 |         28.13 |          7.81
2022-07-01 | 27 |   6 |   9 |  18 |   1 |  64 |         28.13 |          1.56
2022-07-01 | 27 |   0 |  10 |  18 |   2 |  64 |         28.13 |          3.13
2022-07-01 | 28 |   1 |  11 |  16 |   5 |  64 |         25.00 |          7.81
2022-07-01 | 28 |   2 |  12 |  16 |   2 |  64 |         25.00 |          3.13
2022-07-01 | 28 |   3 |  13 |  16 |   0 |  64 |         25.00 |          0.00
2022-07-01 | 28 |   4 |  14 |  16 |   3 |  64 |         25.00 |          4.69
2022-07-01 | 28 |   5 |  15 |  16 |   4 |  64 |         25.00 |          6.25
2022-07-01 | 28 |   6 |  16 |  16 |   1 |  64 |         25.00 |          1.56
2022-07-01 | 28 |   0 |  17 |  16 |   1 |  64 |         25.00 |          1.56
2022-07-01 | 29 |   1 |  18 |  17 |   0 |  64 |         26.56 |          0.00
2022-07-01 | 29 |   2 |  19 |  17 |   5 |  64 |         26.56 |          7.81
2022-07-01 | 29 |   3 |  20 |  17 |   1 |  64 |         26.56 |          1.56
2022-07-01 | 29 |   4 |  21 |  17 |   1 |  64 |         26.56 |          1.56
2022-07-01 | 29 |   5 |  22 |  17 |   4 |  64 |         26.56 |          6.25
2022-07-01 | 29 |   6 |  23 |  17 |   4 |  64 |         26.56 |          6.25
2022-07-01 | 29 |   0 |  24 |  17 |   3 |  64 |         26.56 |          4.69
2022-07-01 | 30 |   1 |  25 |  22 |   3 |  64 |         34.38 |          4.69
2022-07-01 | 30 |   2 |  26 |  22 |   5 |  64 |         34.38 |          7.81
2022-07-01 | 30 |   3 |  27 |  22 |   1 |  64 |         34.38 |          1.56
2022-07-01 | 30 |   4 |  28 |  22 |   2 |  64 |         34.38 |          3.13
2022-07-01 | 30 |   5 |  29 |  22 |   4 |  64 |         34.38 |          6.25
2022-07-01 | 30 |   6 |  30 |  22 |   6 |  64 |         34.38 |          9.38
2022-07-01 | 30 |   0 |  31 |  22 |   2 |  64 |         34.38 |          3.13
(31 rows)
```

```SQL
WITH last_month AS (
  SELECT DATE_TRUNC('month',day)::DATE AS mth,
         COUNT(DISTINCT user_id) AS mau
    FROM logins
   GROUP BY mth
   ORDER BY mth DESC
   OFFSET 1 ROW
   FETCH FIRST 1 ROW ONLY
)
,calendar AS (
  SELECT  DATE_TRUNC('month',s.day_mth)::DATE AS month
        , s.day_mth::DATE AS day
    FROM GENERATE_SERIES((SELECT mth FROM last_month),
                         (SELECT (mth + INTERVAL '1 month')::DATE - 1 FROM last_month),
                          INTERVAL '1 day') AS s(day_mth)
)
,logins_mau AS (
  SELECT  c.month AS month
        , EXTRACT('WEEK' FROM c.day) AS wk
        , EXTRACT('DOW' FROM c.day) AS dow
        , EXTRACT('DAY' FROM c.day) AS day
        , l.user_id AS user_id
        , lm.mau AS mau
    FROM calendar c
    LEFT JOIN logins l
      ON c.day = DATE_TRUNC('day',l.day)::DATE
   INNER JOIN last_month lm
      ON c.month = lm.mth
)
,wau_mau AS (
  SELECT  month
        , wk
        , COUNT(DISTINCT user_id) AS wau
        , mau
    FROM logins_mau
   GROUP BY month, wk, mau
   ORDER BY month, wk
)
,dau_mau AS (
  SELECT  month
        , wk
        , dow
        , day
        , COUNT(DISTINCT user_id) AS dau
        , mau
    FROM logins_mau
   GROUP BY month, wk, dow, day, mau
   ORDER BY month, wk, day
)
, wau_dau_mau AS (
  SELECT  wm.month AS month
        , wm.wk AS wk
        , dm.dow AS dow
        , dm.day AS day
        , wm.wau AS wau
        , dm.dau AS dau
        , wm.mau AS mau
        , ROUND((100.00*wau)/wm.mau,2) AS wau_mau_ratio
        , ROUND((100.00*dau)/wm.mau,2) AS dau_mau_ratio
    FROM wau_mau wm
   INNER JOIN dau_mau dm
      ON wm.wk = dm.wk
)
,mr AS (
  SELECT  wk
        , dow
        , ' (' || wau_mau_ratio::TEXT || ')' AS week_wmr
        , day::TEXT || ' (' || dau_mau_ratio::TEXT || ')' AS day_dmr
    FROM wau_dau_mau
)
SELECT *
  FROM mr
 ORDER BY wk, dow;
```

```console
wk | dow | week_wmr |  day_dmr
---+-----+----------+-----------
26 |   0 |  (9.38)  | 3 (1.56)
26 |   5 |  (9.38)  | 1 (6.25)
26 |   6 |  (9.38)  | 2 (4.69)
27 |   0 |  (28.13) | 10 (3.13)
27 |   1 |  (28.13) | 4 (0.00)
27 |   2 |  (28.13) | 5 (4.69)
27 |   3 |  (28.13) | 6 (3.13)
27 |   4 |  (28.13) | 7 (9.38)
27 |   5 |  (28.13) | 8 (7.81)
27 |   6 |  (28.13) | 9 (1.56)
28 |   0 |  (25.00) | 17 (1.56)
28 |   1 |  (25.00) | 11 (7.81)
28 |   2 |  (25.00) | 12 (3.13)
28 |   3 |  (25.00) | 13 (0.00)
28 |   4 |  (25.00) | 14 (4.69)
28 |   5 |  (25.00) | 15 (6.25)
28 |   6 |  (25.00) | 16 (1.56)
29 |   0 |  (26.56) | 24 (4.69)
29 |   1 |  (26.56) | 18 (0.00)
29 |   2 |  (26.56) | 19 (7.81)
29 |   3 |  (26.56) | 20 (1.56)
29 |   4 |  (26.56) | 21 (1.56)
29 |   5 |  (26.56) | 22 (6.25)
29 |   6 |  (26.56) | 23 (6.25)
30 |   0 |  (34.38) | 31 (3.13)
30 |   1 |  (34.38) | 25 (4.69)
30 |   2 |  (34.38) | 26 (7.81)
30 |   3 |  (34.38) | 27 (1.56)
30 |   4 |  (34.38) | 28 (3.13)
30 |   5 |  (34.38) | 29 (6.25)
30 |   6 |  (34.38) | 30 (9.38)
(31 rows)
```

The final step is to pivot the table.

```SQL
WITH last_month AS (
  SELECT DATE_TRUNC('month',day)::DATE AS mth,
         COUNT(DISTINCT user_id) AS mau
    FROM logins
   GROUP BY mth
   ORDER BY mth DESC
   OFFSET 1 ROW
   FETCH FIRST 1 ROW ONLY
)
,calendar AS (
  SELECT  DATE_TRUNC('month',s.day_mth)::DATE AS month
        , s.day_mth::DATE AS day
    FROM GENERATE_SERIES((SELECT mth FROM last_month),
                         (SELECT (mth + INTERVAL '1 month')::DATE - 1 FROM last_month),
                          INTERVAL '1 day') AS s(day_mth)
)
,logins_mau AS (
  SELECT  c.month AS month
        , EXTRACT('WEEK' FROM c.day) AS wk
        , EXTRACT('DOW' FROM c.day) AS dow
        , EXTRACT('DAY' FROM c.day) AS day
        , l.user_id AS user_id
        , lm.mau AS mau
    FROM calendar c
    LEFT JOIN logins l
      ON c.day = DATE_TRUNC('day',l.day)::DATE
   INNER JOIN last_month lm
      ON c.month = lm.mth
)
,wau_mau AS (
  SELECT  month
        , wk
        , COUNT(DISTINCT user_id) AS wau
        , mau
    FROM logins_mau
   GROUP BY month, wk, mau
   ORDER BY month, wk
)
,dau_mau AS (
  SELECT  month
        , wk
        , dow
        , day
        , COUNT(DISTINCT user_id) AS dau
        , mau
    FROM logins_mau
   GROUP BY month, wk, dow, day, mau
   ORDER BY month, wk, day
)
, wau_dau_mau AS (
  SELECT  wm.month AS month
        , wm.wk AS wk
        , dm.dow AS dow
        , dm.day AS day
        , wm.wau AS wau
        , dm.dau AS dau
        , wm.mau AS mau
        , ROUND((100.00*wau)/wm.mau,2) AS wau_mau_ratio
        , ROUND((100.00*dau)/wm.mau,2) AS dau_mau_ratio
    FROM wau_mau wm
   INNER JOIN dau_mau dm
      ON wm.wk = dm.wk
)
,mr AS (
  SELECT  wk
        , dow
        , ' (' || wau_mau_ratio::TEXT || ')' AS week_wmr
        , day::TEXT || ' (' || dau_mau_ratio::TEXT || ')' AS day_dmr
    FROM wau_dau_mau
)
SELECT  ROW_NUMBER() OVER(ORDER BY wk, week_wmr) || week_wmr AS Wk
       ,MAX(CASE WHEN dow = 1 THEN day_dmr END )AS Mo
       ,MAX(CASE WHEN dow = 2 THEN day_dmr END )AS Tu
       ,MAX(CASE WHEN dow = 3 THEN day_dmr END )AS We
       ,MAX(CASE WHEN dow = 4 THEN day_dmr END )AS Th
       ,MAX(CASE WHEN dow = 5 THEN day_dmr END )AS Fr
       ,MAX(CASE WHEN dow = 6 THEN day_dmr END )AS Sa
       ,MAX(CASE WHEN dow = 0 THEN day_dmr END )AS Su
  FROM mr
 GROUP BY wk, week_wmr
 ORDER BY wk;
```

```console
(base) ludo  $  psql cookbook -f cookbook_dau_wau_mau_test0.sql
    wk     |    mo     |    tu     |    we     |    th     |    fr     |    sa     |    su
-----------+-----------+-----------+-----------+-----------+-----------+-----------+-----------
 1 (9.38)  |           |           |           |           | 1 (6.25)  | 2 (4.69)  | 3 (1.56)
 2 (28.13) | 4 (0.00)  | 5 (4.69)  | 6 (3.13)  | 7 (9.38)  | 8 (7.81)  | 9 (1.56)  | 10 (3.13)
 3 (25.00) | 11 (7.81) | 12 (3.13) | 13 (0.00) | 14 (4.69) | 15 (6.25) | 16 (1.56) | 17 (1.56)
 4 (26.56) | 18 (0.00) | 19 (7.81) | 20 (1.56) | 21 (1.56) | 22 (6.25) | 23 (6.25) | 24 (4.69)
 5 (34.38) | 25 (4.69) | 26 (7.81) | 27 (1.56) | 28 (3.13) | 29 (6.25) | 30 (9.38) | 31 (3.13)
(5 rows)
```
