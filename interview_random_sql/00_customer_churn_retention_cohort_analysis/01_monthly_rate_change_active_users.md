# Monthly Active Users Percent Change

Oftentimes it’s useful to know how much a key metric, such as monthly active users  **changes between months**. Say we have a table logins in the form:

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

We want to calculate the percentage change of users between each month.

|perevious_mth  |  current_mth   | percent_change|
|:--------------|:---------------|--------------:|
|2021 SEPTEMBER | 2021 OCTOBER   |          12.90|
|2021 OCTOBER   | 2021 NOVEMBER  |          -8.77|
|2021 NOVEMBER  | 2021 DECEMBER  |           5.00|
|2021 DECEMBER  | 2022 JANUARY   |          -3.45|
|2022 JANUARY   | 2022 FEBRUARY  |          -7.41|
|2022 FEBRUARY  | 2022 MARCH     |          14.29|
|2022 MARCH     | 2022 APRIL     |         -21.15|
|2022 APRIL     | 2022 MAY       |          -4.00|
|2022 MAY       | 2022 JUNE      |           0.00|
|2022 JUNE      | 2022 JULY      |          21.88|
|2022 JULY      | 2022 AUGUST    |          -6.67|


(11 rows).


### Problem 2

Format the the output table of problem 1 in the following format:

|current_year |      period       | percent_change|
|:------------|:----------------- |--------------:|
|2021         | SEPTEMBER-OCTOBER |          12.90|
|2021         | OCTOBER-NOVEMBER  |          -8.77|
|2021         | NOVEMBER-DECEMBER |           5.00|
|2022         | DECEMBER-JANUARY  |          -3.45|
|2022         | JANUARY-FEBRUARY  |          -7.41|
|2022         | FEBRUARY-MARCH    |          14.29|
|2022         | MARCH-APRIL       |         -21.15|
|2022         | APRIL-MAY         |          -4.00|
|2022         | MAY-JUNE          |           0.00|
|2022         | JUNE-JULY         |          21.88|
|2022         | JULY-AUGUST       |          -6.67|


## Solution

```SQL
WITH mau AS (
  SELECT  DATE_TRUNC('month',day) AS mth
        , COUNT(DISTINCT user_id) AS cnt
    FROM logins
   GROUP BY mth
)
SELECT  TO_CHAR(m2.mth::DATE,'YYYY-MM') AS perevious_mth
      , TO_CHAR(m1.mth::DATE,'YYYY-MM') AS current_mth
      , ROUND((100.0 * (m1.cnt - m2.cnt)/(1.0 * m1.cnt)),2) AS percent_change
  FROM mau m1
 INNER JOIN mau m2
    ON m2.mth = m1.mth - INTERVAL '1 month'
 ORDER BY m1.mth;
```

- **Problem 2**:

```SQL
WITH mau AS (
  SELECT  DATE_TRUNC('month',day) AS mth
        , COUNT(DISTINCT user_id) AS cnt
    FROM logins
   GROUP BY mth
)
SELECT  TO_CHAR(m1.mth::DATE,'YYYY') AS current_year
      , REPLACE(TO_CHAR(m2.mth::DATE,'MONTH') || '-' ||
                TO_CHAR(m1.mth::DATE,'MONTH')
                ,' ','')
        AS period
      , ROUND((100.0 * (m1.cnt - m2.cnt)/(1.0 * m1.cnt)),2) AS percent_change
  FROM mau m1
 INNER JOIN mau m2
    ON m2.mth = m1.mth - INTERVAL '1 month'
 ORDER BY m1.mth;
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

Now, we can solve the **Problem**.

### Problem Monthly user percentage change

```SQL
SELECT DATE_TRUNC('month',day) AS mth,
       COUNT(DISTINCT user_id) AS mau
  FROM logins
 GROUP BY mth
 ORDER BY mth;
```

First we count for each month the number of distinct users.

```console
mth                 | mau
--------------------+-----
2021-09-01 00:00:00 |  54
2021-10-01 00:00:00 |  62
2021-11-01 00:00:00 |  57
2021-12-01 00:00:00 |  60
2022-01-01 00:00:00 |  58
2022-02-01 00:00:00 |  54
2022-03-01 00:00:00 |  63
2022-04-01 00:00:00 |  52
2022-05-01 00:00:00 |  50 <--
2022-06-01 00:00:00 |  50 <--
2022-07-01 00:00:00 |  64
2022-08-01 00:00:00 |  60
12 rows
```

We see that number of users in `2022-05` and `2022-06` was 50. Thus, the percentage change is `0.0`.


Next, we wrap the query in a CTE and compute the percentage change.

```SQL
WITH mau AS (
  SELECT  TO_CHAR(DATE_TRUNC('month',day),'YYYY-MM') AS y_mth,
        , COUNT(DISTINCT user_id) AS cnt
    FROM logins
   GROUP BY y_mth
)
SELECT  m1.mth::DATE AS current_mth
      , m2.mth::DATE AS perevious_mth
      , ROUND((100.0 * (m1.cnt - m2.cnt)/(1.0 * m1.cnt)),2) AS percent_change
  FROM mau m1
 INNER JOIN mau m2
    ON m2.mth = m1.mth - INTERVAL '1 month'
 ORDER BY m1.mth;
```

```SQL
WITH mau AS (
  SELECT  DATE_TRUNC('month',day) AS mth
        , COUNT(DISTINCT user_id) AS cnt
    FROM logins
   GROUP BY mth
)
SELECT  m1.mth::DATE AS current_mth
      , m2.mth::DATE AS perevious_mth
      , ROUND((100.0 * (m1.cnt - m2.cnt)/(1.0 * m1.cnt)),2) AS percent_change
  FROM mau m1
 INNER JOIN mau m2
    ON m2.mth = m1.mth - INTERVAL '1 month'
 ORDER BY m1.mth;
```

|current_mth | perevious_mth | percent_change|
|:----------:|:-------------:|:-------------:|
|2021-10-01  | 2021-09-01    |          12.90|
|2021-11-01  | 2021-10-01    |          -8.77|
|2021-12-01  | 2021-11-01    |           5.00|
|2022-01-01  | 2021-12-01    |          -3.45|
|2022-02-01  | 2022-01-01    |          -7.41|
|2022-03-01  | 2022-02-01    |          14.29|
|2022-04-01  | 2022-03-01    |         -21.15|
|2022-05-01  | 2022-04-01    |          -4.00|
|2022-06-01  | 2022-05-01    |           0.00|
|2022-07-01  | 2022-06-01    |          21.88|
|2022-08-01  | 2022-07-01    |          -6.67|

Let's change the output in a more readable format.

```SQL
WITH mau AS (
  SELECT  DATE_TRUNC('month',day) AS mth
        , COUNT(DISTINCT user_id) AS cnt
    FROM logins
   GROUP BY mth
)
SELECT  TO_CHAR(m2.mth::DATE,'YYYY-MM') AS perevious_mth
      , TO_CHAR(m1.mth::DATE,'YYYY-MM') AS current_mth
      , ROUND((100.0 * (m1.cnt - m2.cnt)/(1.0 * m1.cnt)),2) AS percent_change
  FROM mau m1
 INNER JOIN mau m2
    ON m2.mth = m1.mth - INTERVAL '1 month'
 ORDER BY m1.mth;
```

```console
perevious_mth | current_mth | percent_change
--------------+-------------+----------------
2021-09       | 2021-10     |          12.90
2021-10       | 2021-11     |          -8.77
2021-11       | 2021-12     |           5.00
2021-12       | 2022-01     |          -3.45
2022-01       | 2022-02     |          -7.41
2022-02       | 2022-03     |          14.29
2022-03       | 2022-04     |         -21.15
2022-04       | 2022-05     |          -4.00
2022-05       | 2022-06     |           0.00
2022-06       | 2022-07     |          21.88
2022-07       | 2022-08     |          -6.67
(11 rows)
```

```SQL
WITH mau AS (
  SELECT  DATE_TRUNC('month',day) AS mth
        , COUNT(DISTINCT user_id) AS cnt
    FROM logins
   GROUP BY mth
)
SELECT  TO_CHAR(m1.mth::DATE,'YYYY') AS current_year
      , REPLACE(TO_CHAR(m2.mth::DATE,'MONTH') || '-' ||
                TO_CHAR(m1.mth::DATE,'MONTH'),' ','')
        AS period
      , ROUND((100.0 * (m1.cnt - m2.cnt)/(1.0 * m1.cnt)),2) AS percent_change
  FROM mau m1
 INNER JOIN mau m2
    ON m2.mth = m1.mth - INTERVAL '1 month'
 ORDER BY m1.mth;
```

```console
current_year |      period       | percent_change
-------------+-------------------+----------------
2021         | SEPTEMBER-OCTOBER |          12.90
2021         | OCTOBER-NOVEMBER  |          -8.77
2021         | NOVEMBER-DECEMBER |           5.00
2022         | DECEMBER-JANUARY  |          -3.45
2022         | JANUARY-FEBRUARY  |          -7.41
2022         | FEBRUARY-MARCH    |          14.29
2022         | MARCH-APRIL       |         -21.15
2022         | APRIL-MAY         |          -4.00
2022         | MAY-JUNE          |           0.00
2022         | JUNE-JULY         |          21.88
2022         | JULY-AUGUST       |          -6.67
```
