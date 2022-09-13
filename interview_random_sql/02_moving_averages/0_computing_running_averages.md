# Computing Running Averages

Some of us are familiar with the ubiquitous Daily Active Users metric. It’s a wonderful, concrete way to get a sense of your engagement.

Suppose we have the following table from the `parch_posey` sample database:

```console
parch_posey=# \d orders
                              Table "public.orders"
      Column      |            Type             | Collation | Nullable | Default
------------------+-----------------------------+-----------+----------+---------
 id               | integer                     |           | not null |
 account_id       | integer                     |           |          |
 occurred_at      | timestamp without time zone |           |          |
 standard_qty     | integer                     |           |          |
 gloss_qty        | integer                     |           |          |
 poster_qty       | integer                     |           |          |
 total            | integer                     |           |          |
 standard_amt_usd | numeric(10,2)               |           |          |
 gloss_amt_usd    | numeric(10,2)               |           |          |
 poster_amt_usd   | numeric(10,2)               |           |          |
 total_amt_usd    | numeric(10,2)               |           |          |
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
Foreign-key constraints:
    "orders_fkey_account" FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE
```

Here’s a simple query that will do the trick:

```SQL
WITH last_month AS (
  SELECT DATE_TRUNC('month',occurred_at)::DATE AS mth,
         COUNT(DISTINCT account_id) AS mau
    FROM orders
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
        , COUNT(DISTINCT o.account_id) AS dau
        , lm.mau AS mau
    FROM calendar c
    LEFT JOIN orders o
      ON c.day = DATE_TRUNC('day',o.occurred_at)::DATE
   INNER JOIN last_month lm
      ON c.month = lm.mth
   GROUP BY c.month, c.day, lm.mau
)
SELECT  TO_CHAR(month,'YY-MM') AS month
      , day
      , dau
      , mau
      , ROUND((100.00*dau)/mau,2) AS dau_mau_ratio
      , LPAD('*',dau::INTEGER,'*') AS dau_x
  FROM dau_mau
 ORDER BY day;
```


```console
month |    day     | dau | mau | dau_mau_ratio |        dau_x
------+------------+-----+-----+---------------+---------------------
16-12 | 2016-12-01 |  10 | 279 |          3.58 | **********
16-12 | 2016-12-02 |  12 | 279 |          4.30 | ************
16-12 | 2016-12-03 |  11 | 279 |          3.94 | ***********
16-12 | 2016-12-04 |   4 | 279 |          1.43 | ****
16-12 | 2016-12-05 |   3 | 279 |          1.08 | ***
16-12 | 2016-12-06 |  11 | 279 |          3.94 | ***********
16-12 | 2016-12-07 |   7 | 279 |          2.51 | *******
16-12 | 2016-12-08 |   7 | 279 |          2.51 | *******
16-12 | 2016-12-09 |   7 | 279 |          2.51 | *******
16-12 | 2016-12-10 |  11 | 279 |          3.94 | ***********
16-12 | 2016-12-11 |  11 | 279 |          3.94 | ***********
16-12 | 2016-12-12 |   6 | 279 |          2.15 | ******
16-12 | 2016-12-13 |   9 | 279 |          3.23 | *********
16-12 | 2016-12-14 |   6 | 279 |          2.15 | ******
16-12 | 2016-12-15 |  13 | 279 |          4.66 | *************
16-12 | 2016-12-16 |   8 | 279 |          2.87 | ********
16-12 | 2016-12-17 |  12 | 279 |          4.30 | ************
16-12 | 2016-12-18 |   9 | 279 |          3.23 | *********
16-12 | 2016-12-19 |   9 | 279 |          3.23 | *********
16-12 | 2016-12-20 |  12 | 279 |          4.30 | ************
16-12 | 2016-12-21 |  15 | 279 |          5.38 | ***************
16-12 | 2016-12-22 |  10 | 279 |          3.58 | **********
16-12 | 2016-12-23 |  11 | 279 |          3.94 | ***********
16-12 | 2016-12-24 |   8 | 279 |          2.87 | ********
16-12 | 2016-12-25 |   7 | 279 |          2.51 | *******
16-12 | 2016-12-26 |  14 | 279 |          5.02 | **************
16-12 | 2016-12-27 |   7 | 279 |          2.51 | *******
16-12 | 2016-12-28 |  14 | 279 |          5.02 | **************
16-12 | 2016-12-29 |   8 | 279 |          2.87 | ********
16-12 | 2016-12-30 |   7 | 279 |          2.51 | *******
16-12 | 2016-12-31 |  19 | 279 |          6.81 | *******************
(31 rows)
```

Holy noise in the data, Batman! It certainly seems to be going up, but it’s hard to identify the trends. If only there were a way to smooth it out.

## Problem 1

To smooth this out, let’s look at `Daily Active Users by Week`, which is a weekly average of your `DAUs`. Note this is not the same as Weekly Active Users: Both are valid, yet measure different things.

```console
wk_avg   |   mo    |   tu    |   we    |   th    |   fr    |   sa    |   su    |    wk_avg
---------+---------+---------+---------+---------+---------+---------+---------+--------------
1 (9.25)  |         |         |         | 1 (10)  | 2 (12)  | 3 (11)  | 4 (4)   | *********
2 (8.14)  | 5 (3)   | 6 (11)  | 7 (7)   | 8 (7)   | 9 (7)   | 10 (11) | 11 (11) | ********
3 (9.00)  | 12 (6)  | 13 (9)  | 14 (6)  | 15 (13) | 16 (8)  | 17 (12) | 18 (9)  | *********
4 (10.29) | 19 (9)  | 20 (12) | 21 (15) | 22 (10) | 23 (11) | 24 (8)  | 25 (7)  | **********
5 (11.50) | 26 (14) | 27 (7)  | 28 (14) | 29 (8)  | 30 (7)  | 31 (19) |         | ************
(5 rows)
```

In the output table the first column is simply the average of the daily active users in the week days on the right. For example, the value `(9.25)` is the result of:

```console
       10 + 12 + 11 + 4      37
9.25 = ----------------- =  ----
              4               4
```

Thus, the first week of the month has 4 days of the week. The number of distinct active users were `10`,`12`,`11` and `4`. The average is, therefore, `9.25`. The horizontal histogram in the last column is basically a rounded integer of the weekly average. The first row is, therefore, nine  `*` symbols. 

## Problem  2

Here we’ll use a preceding average which means that the metric for the 7th day of the month would be the average of the preceding 6 days and that day itself.

```console
month      |    day     | dau | m7days_avg | rounded_avg |     rounded_dau
-----------+------------+-----+------------+-------------+---------------------
2016-12-01 | 2016-12-07 |   7 |       8.29 | ********    | xxxxxxx
2016-12-01 | 2016-12-08 |   7 |       7.86 | ********    | xxxxxxx
2016-12-01 | 2016-12-09 |   7 |       7.14 | *******     | xxxxxxx
2016-12-01 | 2016-12-10 |  11 |       7.14 | *******     | xxxxxxxxxxx
2016-12-01 | 2016-12-11 |  11 |       8.14 | ********    | xxxxxxxxxxx
2016-12-01 | 2016-12-12 |   6 |       8.57 | *********   | xxxxxx
2016-12-01 | 2016-12-13 |   9 |       8.29 | ********    | xxxxxxxxx
2016-12-01 | 2016-12-14 |   6 |       8.14 | ********    | xxxxxx
2016-12-01 | 2016-12-15 |  13 |       9.00 | *********   | xxxxxxxxxxxxx
2016-12-01 | 2016-12-16 |   8 |       9.14 | *********   | xxxxxxxx
2016-12-01 | 2016-12-17 |  12 |       9.29 | *********   | xxxxxxxxxxxx
2016-12-01 | 2016-12-18 |   9 |       9.00 | *********   | xxxxxxxxx
2016-12-01 | 2016-12-19 |   9 |       9.43 | *********   | xxxxxxxxx
2016-12-01 | 2016-12-20 |  12 |       9.86 | **********  | xxxxxxxxxxxx
2016-12-01 | 2016-12-21 |  15 |      11.14 | *********** | xxxxxxxxxxxxxxx
2016-12-01 | 2016-12-22 |  10 |      10.71 | *********** | xxxxxxxxxx
2016-12-01 | 2016-12-23 |  11 |      11.14 | *********** | xxxxxxxxxxx
2016-12-01 | 2016-12-24 |   8 |      10.57 | *********** | xxxxxxxx
2016-12-01 | 2016-12-25 |   7 |      10.29 | **********  | xxxxxxx
2016-12-01 | 2016-12-26 |  14 |      11.00 | *********** | xxxxxxxxxxxxxx
2016-12-01 | 2016-12-27 |   7 |      10.29 | **********  | xxxxxxx
2016-12-01 | 2016-12-28 |  14 |      10.14 | **********  | xxxxxxxxxxxxxx
2016-12-01 | 2016-12-29 |   8 |       9.86 | **********  | xxxxxxxx
2016-12-01 | 2016-12-30 |   7 |       9.29 | *********   | xxxxxxx
2016-12-01 | 2016-12-31 |  19 |      10.86 | *********** | xxxxxxxxxxxxxxxxxxx
(25 rows)
```

## Solution

- **Problem 1**:

```SQL
WITH last_month AS (
  SELECT DATE_TRUNC('month',occurred_at)::DATE AS mth,
         COUNT(DISTINCT account_id) AS mau
    FROM orders
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
        , o.account_id AS user_id
        , lm.mau AS mau
    FROM calendar c
    LEFT JOIN orders o
      ON c.day = DATE_TRUNC('day',o.occurred_at)::DATE
   INNER JOIN last_month lm
      ON c.month = lm.mth
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
, wau_avg AS (
  SELECT  month
        , wk
        , ROUND(AVG(dau),2) AS wk_avg
    FROM dau_mau
   GROUP BY month, wk
)
, wau_dau_mau AS (
  SELECT  w.month AS month
        , w.wk AS wk
        , dm.dow AS dow
        , dm.day AS day
        , w.wk_avg AS avg_wau
        , dm.dau AS dau
    FROM wau_avg w
   INNER JOIN dau_mau dm
      ON w.wk = dm.wk
)
,mr AS (
  SELECT  wk
        , dow
        , ROUND(avg_wau,0) AS val
        , ' (' || avg_wau::TEXT || ')' AS avg_wau
        , day::TEXT || ' (' || dau::TEXT || ')' AS dau
    FROM wau_dau_mau
)
SELECT  ROW_NUMBER() OVER(ORDER BY wk, avg_wau) || avg_wau AS Wk_avg
       ,MAX(CASE WHEN dow = 1 THEN dau END )AS Mo
       ,MAX(CASE WHEN dow = 2 THEN dau END )AS Tu
       ,MAX(CASE WHEN dow = 3 THEN dau END )AS We
       ,MAX(CASE WHEN dow = 4 THEN dau END )AS Th
       ,MAX(CASE WHEN dow = 5 THEN dau END )AS Fr
       ,MAX(CASE WHEN dow = 6 THEN dau END )AS Sa
       ,MAX(CASE WHEN dow = 0 THEN dau END )AS Su
       ,LPAD('*',val::INTEGER,'*') AS wk_avg
  FROM mr
 GROUP BY wk, avg_wau, val
 ORDER BY wk;
```

- **Problem 2**:

```SQL
WITH last_month AS ( -- Count the number daily active users in the last month
  SELECT DATE_TRUNC('day',occurred_at)::DATE AS day,
         COUNT(DISTINCT account_id) AS dau
    FROM orders
   WHERE DATE_TRUNC('month',occurred_at)::DATE = '2016-12-01'::DATE
   GROUP BY day
),
mavg AS (
  SELECT  l1.day AS day
        , ROUND(AVG(l2.dau),2) AS m7days_avg
    FROM last_month l1
    JOIN last_month l2
      ON l1.day <= l2.day + INTERVAL '6 days' AND
         l1.day >= l2.day
   WHERE l1.day >= (SELECT (MIN(day) + INTERVAL '6 days')::DATE FROM last_month)
   GROUP BY l1.day
)
SELECT  DATE_TRUNC('month',lm.day)::DATE AS month
      , lm.day AS day
      , lm.dau AS dau
      , ma.m7days_avg AS m7days_avg
      ,LPAD('*',ROUND(m7days_avg,0)::INTEGER,'*') AS rounded_avg
      ,RPAD('x',ROUND(dau,0)::INTEGER,'x') AS rounded_dau
  FROM last_month lm
  JOIN mavg ma
    ON lm.day = ma.day
 ORDER BY lm.day;  
```

**Solution 2 with window function**

```SQL
WITH last_month AS (
  SELECT DATE_TRUNC('month',occurred_at)::DATE AS mth,
         COUNT(DISTINCT account_id) AS mau
    FROM orders
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
        , COUNT(DISTINCT o.account_id) AS dau
        , lm.mau AS mau
    FROM calendar c
    LEFT JOIN orders o
      ON c.day = DATE_TRUNC('day',o.occurred_at)::DATE
   INNER JOIN last_month lm
      ON c.month = lm.mth
   GROUP BY c.month, c.day, lm.mau
) -- Calculate 7 days moving average
,m7_avg AS (
  SELECT  month AS month
        , day AS day
        , dau AS dau
        , ROUND(AVG(dau) OVER(ORDER BY day
                        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),2)
          AS m7days_avg
    FROM dau_mau
)
SELECT  month
      , day
      , dau
      , m7days_avg
      ,LPAD('*',ROUND(m7days_avg,0)::INTEGER,'*') AS rounded_avg
      ,RPAD('x',ROUND(dau,0)::INTEGER,'x') AS rounded_dau
  FROM m7_avg
 WHERE day >= ((SELECT MIN(day) FROM dau_mau) + INTERVAL '6 days')::DATE  
 ORDER BY month, day;
```


## DISCUSSION

To smooth this out, let’s look at `Daily Active Users by Week`, which is a weekly average of your `DAUs`. Note this is not the same as Weekly Active Users: Both are valid, yet measure different things.

To compute DAU by Week, we’ll put our DAU query in a CTE, and wrap it in another query that takes a simple weekly average:

```SQL
WITH last_month AS (
  SELECT DATE_TRUNC('month',occurred_at)::DATE AS mth,
         COUNT(DISTINCT account_id) AS mau
    FROM orders
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
        , o.account_id AS user_id
        , lm.mau AS mau
    FROM calendar c
    LEFT JOIN orders o
      ON c.day = DATE_TRUNC('day',o.occurred_at)::DATE
   INNER JOIN last_month lm
      ON c.month = lm.mth
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
, wau_avg AS (
  SELECT  month
        , wk
        , ROUND(AVG(dau),2) AS wk_avg
    FROM dau_mau
   GROUP BY month, wk
)
, wau_dau_mau AS (
  SELECT  w.month AS month
        , w.wk AS wk
        , dm.dow AS dow
        , dm.day AS day
        , w.wk_avg AS avg_wau
        , dm.dau AS dau
    FROM wau_avg w
   INNER JOIN dau_mau dm
      ON w.wk = dm.wk
)
,mr AS (
  SELECT  wk
        , dow
        , ROUND(avg_wau,0) AS val
        , ' (' || avg_wau::TEXT || ')' AS avg_wau
        , day::TEXT || ' (' || dau::TEXT || ')' AS dau
    FROM wau_dau_mau
)
SELECT  ROW_NUMBER() OVER(ORDER BY wk, avg_wau) || avg_wau AS Wk_avg
       ,MAX(CASE WHEN dow = 1 THEN dau END )AS Mo
       ,MAX(CASE WHEN dow = 2 THEN dau END )AS Tu
       ,MAX(CASE WHEN dow = 3 THEN dau END )AS We
       ,MAX(CASE WHEN dow = 4 THEN dau END )AS Th
       ,MAX(CASE WHEN dow = 5 THEN dau END )AS Fr
       ,MAX(CASE WHEN dow = 6 THEN dau END )AS Sa
       ,MAX(CASE WHEN dow = 0 THEN dau END )AS Su
       ,LPAD('*',val::INTEGER,'*') AS wk_avg
  FROM mr
 GROUP BY wk, avg_wau, val
 ORDER BY wk;
```

```console
wk_avg   |   mo    |   tu    |   we    |   th    |   fr    |   sa    |   su    |    wk_avg
---------+---------+---------+---------+---------+---------+---------+---------+--------------
1 (9.25)  |         |         |         | 1 (10)  | 2 (12)  | 3 (11)  | 4 (4)   | *********
2 (8.14)  | 5 (3)   | 6 (11)  | 7 (7)   | 8 (7)   | 9 (7)   | 10 (11) | 11 (11) | ********
3 (9.00)  | 12 (6)  | 13 (9)  | 14 (6)  | 15 (13) | 16 (8)  | 17 (12) | 18 (9)  | *********
4 (10.29) | 19 (9)  | 20 (12) | 21 (15) | 22 (10) | 23 (11) | 24 (8)  | 25 (7)  | **********
5 (11.50) | 26 (14) | 27 (7)  | 28 (14) | 29 (8)  | 30 (7)  | 31 (19) |         | ************
(5 rows)
```

### Daily Running Averages

Weekly averages are all well and good, but they are very coarse-grained! There should be a way to show smoothed-out daily data.

For that, we’ll use a Trailing 7-Day Average. Here we’ll use a preceding average which means that the metric for the 7th day of the month would be the average of the preceding 6 days and that day itself.

To do this in SQL, we’ll turn to our favorite trick, the window function:

```SQL
WITH last_month AS (
  SELECT DATE_TRUNC('month',occurred_at)::DATE AS mth,
         COUNT(DISTINCT account_id) AS mau
    FROM orders
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
        , COUNT(DISTINCT o.account_id) AS dau
        , lm.mau AS mau
    FROM calendar c
    LEFT JOIN orders o
      ON c.day = DATE_TRUNC('day',o.occurred_at)::DATE
   INNER JOIN last_month lm
      ON c.month = lm.mth
   GROUP BY c.month, c.day, lm.mau
) -- Calculate 7 days moving average
,m7_avg AS (
  SELECT  month AS month
        , day AS day
        , dau AS dau
        , ROUND(AVG(dau) OVER(ORDER BY day
                        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),2)
          AS m7days_avg
    FROM dau_mau
)
SELECT  month
      , day
      , dau
      , m7days_avg
      ,LPAD('*',ROUND(m7days_avg,0)::INTEGER,'*') AS rounded_avg
      ,RPAD('x',ROUND(dau,0)::INTEGER,'x') AS rounded_dau
  FROM m7_avg
 WHERE day >= ((SELECT MIN(day) FROM dau_mau) + INTERVAL '6 days')::DATE  
 ORDER BY month, day;
```

```console
month      |    day     | dau | m7days_avg | rounded_avg |     rounded_dau
-----------+------------+-----+------------+-------------+---------------------
2016-12-01 | 2016-12-07 |   7 |       8.29 | ********    | xxxxxxx
2016-12-01 | 2016-12-08 |   7 |       7.86 | ********    | xxxxxxx
2016-12-01 | 2016-12-09 |   7 |       7.14 | *******     | xxxxxxx
2016-12-01 | 2016-12-10 |  11 |       7.14 | *******     | xxxxxxxxxxx
2016-12-01 | 2016-12-11 |  11 |       8.14 | ********    | xxxxxxxxxxx
2016-12-01 | 2016-12-12 |   6 |       8.57 | *********   | xxxxxx
2016-12-01 | 2016-12-13 |   9 |       8.29 | ********    | xxxxxxxxx
2016-12-01 | 2016-12-14 |   6 |       8.14 | ********    | xxxxxx
2016-12-01 | 2016-12-15 |  13 |       9.00 | *********   | xxxxxxxxxxxxx
2016-12-01 | 2016-12-16 |   8 |       9.14 | *********   | xxxxxxxx
2016-12-01 | 2016-12-17 |  12 |       9.29 | *********   | xxxxxxxxxxxx
2016-12-01 | 2016-12-18 |   9 |       9.00 | *********   | xxxxxxxxx
2016-12-01 | 2016-12-19 |   9 |       9.43 | *********   | xxxxxxxxx
2016-12-01 | 2016-12-20 |  12 |       9.86 | **********  | xxxxxxxxxxxx
2016-12-01 | 2016-12-21 |  15 |      11.14 | *********** | xxxxxxxxxxxxxxx
2016-12-01 | 2016-12-22 |  10 |      10.71 | *********** | xxxxxxxxxx
2016-12-01 | 2016-12-23 |  11 |      11.14 | *********** | xxxxxxxxxxx
2016-12-01 | 2016-12-24 |   8 |      10.57 | *********** | xxxxxxxx
2016-12-01 | 2016-12-25 |   7 |      10.29 | **********  | xxxxxxx
2016-12-01 | 2016-12-26 |  14 |      11.00 | *********** | xxxxxxxxxxxxxx
2016-12-01 | 2016-12-27 |   7 |      10.29 | **********  | xxxxxxx
2016-12-01 | 2016-12-28 |  14 |      10.14 | **********  | xxxxxxxxxxxxxx
2016-12-01 | 2016-12-29 |   8 |       9.86 | **********  | xxxxxxxx
2016-12-01 | 2016-12-30 |   7 |       9.29 | *********   | xxxxxxx
2016-12-01 | 2016-12-31 |  19 |      10.86 | *********** | xxxxxxxxxxxxxxxxxxx
(25 rows)
```

Boom! The lines are smoothed out to show macro trends, but not so much that we can’t see daily variations.

In the case the number of days between rows is not fixed (in the example is 1 day), we cannot use the window function utility. The only solution is a self join.


```SQL
WITH last_month AS ( -- Count the number daily active users in the last month
  SELECT DATE_TRUNC('day',occurred_at)::DATE AS day,
         COUNT(DISTINCT account_id) AS dau
    FROM orders
   WHERE DATE_TRUNC('month',occurred_at)::DATE = '2016-12-01'::DATE
   GROUP BY day
)
SELECT  l1.day AS end_day
      , l2.day AS prev_day
      , l2.dau AS prev_dau
  FROM last_month l1
  JOIN last_month l2
    ON l1.day <= l2.day + INTERVAL '6 days' AND
       l1.day >= l2.day
 WHERE l1.day >= (SELECT (MIN(day) + INTERVAL '6 days')::DATE FROM last_month)
```

```console
end_day    |  prev_day  | prev_dau
-----------+------------+----------         l1.day     <= l2.day + INTERVAL '6 days'
2016-12-07 | 2016-12-01 |       10          2016-12-07 <= 2016-12-01 + 6 -> 2016-12-07
2016-12-07 | 2016-12-02 |       12                     <= 2016-12-02 + 6 -> 2016-12-08
2016-12-07 | 2016-12-03 |       11                     <= 2016-12-03 + 6 -> 2016-12-09
2016-12-07 | 2016-12-04 |        4                     <= 2016-12-04 + 6 -> 2016-12-10
2016-12-07 | 2016-12-05 |        3                     <= 2016-12-05 + 6 -> 2016-12-11
2016-12-07 | 2016-12-06 |       11                     <= 2016-12-06 + 6 -> 2016-12-12
2016-12-07 | 2016-12-07 |        7                     <= 2016-12-07 + 6 -> 2016-12-13
-----------+**********************          l1.day     >= l2.day
2016-12-08 | 2016-12-02 |       12
2016-12-08 | 2016-12-03 |       11
2016-12-08 | 2016-12-04 |        4
2016-12-08 | 2016-12-05 |        3
2016-12-08 | 2016-12-06 |       11
2016-12-08 | 2016-12-07 |        7
2016-12-08 | 2016-12-08 |        7
-----------+***********************
2016-12-09 | 2016-12-03 |       11
2016-12-09 | 2016-12-04 |        4
2016-12-09 | 2016-12-05 |        3
2016-12-09 | 2016-12-06 |       11
2016-12-09 | 2016-12-07 |        7
2016-12-09 | 2016-12-08 |        7
2016-12-09 | 2016-12-09 |        7
-----------+***********************
2016-12-10 | 2016-12-04 |        4
2016-12-10 | 2016-12-05 |        3
2016-12-10 | 2016-12-06 |       11
2016-12-10 | 2016-12-07 |        7
2016-12-10 | 2016-12-08 |        7
2016-12-10 | 2016-12-09 |        7
2016-12-10 | 2016-12-10 |       11
-----------+***********************
 ....            ....
```

Next, compute the average grouping by the end date.

```SQL
WITH last_month AS ( -- Count the number daily active users in the last month
  SELECT DATE_TRUNC('day',occurred_at)::DATE AS day,
         COUNT(DISTINCT account_id) AS dau
    FROM orders
   WHERE DATE_TRUNC('month',occurred_at)::DATE = '2016-12-01'::DATE
   GROUP BY day
)
SELECT  l1.day AS day
      , ROUND(AVG(l2.dau),2) AS m7days_avg
  FROM last_month l1
  JOIN last_month l2
    ON l1.day <= l2.day + INTERVAL '6 days' AND
       l1.day >= l2.day
 WHERE l1.day >= (SELECT (MIN(day) + INTERVAL '6 days')::DATE FROM last_month)
 GROUP BY l1.day
 ORDER BY l1.day;  
```

```console
day        | m7days_avg
-----------+------------
2016-12-07 |       8.29
2016-12-08 |       7.86
2016-12-09 |       7.14
2016-12-10 |       7.14
2016-12-11 |       8.14
2016-12-12 |       8.57
2016-12-13 |       8.29
2016-12-14 |       8.14
2016-12-15 |       9.00
2016-12-16 |       9.14
2016-12-17 |       9.29
2016-12-18 |       9.00
2016-12-19 |       9.43
2016-12-20 |       9.86
2016-12-21 |      11.14
2016-12-22 |      10.71
2016-12-23 |      11.14
2016-12-24 |      10.57
2016-12-25 |      10.29
2016-12-26 |      11.00
2016-12-27 |      10.29
2016-12-28 |      10.14
2016-12-29 |       9.86
2016-12-30 |       9.29
2016-12-31 |      10.86
(25 rows)
```

```SQL
WITH last_month AS ( -- Count the number daily active users in the last month
  SELECT DATE_TRUNC('day',occurred_at)::DATE AS day,
         COUNT(DISTINCT account_id) AS dau
    FROM orders
   WHERE DATE_TRUNC('month',occurred_at)::DATE = '2016-12-01'::DATE
   GROUP BY day
),
mavg AS (
  SELECT  l1.day AS day
        , ROUND(AVG(l2.dau),2) AS m7days_avg
    FROM last_month l1
    JOIN last_month l2
      ON l1.day <= l2.day + INTERVAL '6 days' AND
         l1.day >= l2.day
   WHERE l1.day >= (SELECT (MIN(day) + INTERVAL '6 days')::DATE FROM last_month)
   GROUP BY l1.day
)
SELECT  DATE_TRUNC('month',lm.day)::DATE AS month
      , lm.day AS day
      , lm.dau AS dau
      , ma.m7days_avg AS m7days_avg
      ,LPAD('*',ROUND(m7days_avg,0)::INTEGER,'*') AS rounded_avg
      ,RPAD('x',ROUND(dau,0)::INTEGER,'x') AS rounded_dau
  FROM last_month lm
  JOIN mavg ma
    ON lm.day = ma.day
 ORDER BY lm.day;  
```
