# Extracting Units of Time from a Date

You want to **break** the `current date` down into **8 parts**:
1. year,
2. month,
3. day,
4. hour,
5. minute,
6. second,
7. microsecond,
8. millisecond.

You want the results to be returned as numbers.

## Problem 1

For example, the eight parts of the current timezone:

- `2022-08-14 20:52:25.974558` are:

|curr_time          |  yr  | mth | day | hr | min | sec | ms  |  mcs|
|:-------------------------:|:----:|:---:|:----:|:---:|:----:|:----:|:----:|:------:|
|2022-08-14 20:52:25.974558 | 2022 |   8 |  14 | 20 |  52 |  25 | 974 | 974558|

## Problem 2

Give the `current date` of your timezone. Return the local time zone of `Rome`,`New york` and `Greenwich`.

```console
cookbook=> SHOW TIMEZONE;
     TimeZone
------------------
 Australia/Sydney
```

The current timezone is `Australia/Sydney`.

The `offset` time zone string for postgresql are available on the following link:

- [offset time zone](https://www.postgresql.org/docs/7.2/timezones.html)

|city    |         local_time         |          utc_time          | utc_off_set | sydney_off_set|
|:----------:|:----------------------------:|:----------------------------:|:-------------:|:---------------:|
|New York  | 2022-08-14 09:16:01.122779 | 2022-08-14 13:16:01.122779 | -04:00:00   | 14:00:00|
|Greenwich | 2022-08-14 13:16:01.122779 | 2022-08-14 13:16:01.122779 | 00:00:00    | 10:00:00|
|Rome      | 2022-08-14 15:16:01.122779 | 2022-08-14 13:16:01.122779 | 02:00:00    | 08:00:00|
|Sydney    | 2022-08-14 23:16:01.122779 | 2022-08-14 13:16:01.122779 | 10:00:00    | 00:00:00|

In this example the local time (the server local time, the one on my laptop) is `Sydney`. The local time of Sydney is `+10` hours ahead of the `UTC` (Universal Time Coordinate).

The local time of `Rome`is two hours ahead of the `UTC` and `Sydney` is `8` hours ahead of the timezone in `Rome`.

## Solution

- **Problem 1**:

```SQL
WITH cTime AS (
  SELECT CURRENT_TIMESTAMP::TIMESTAMP AS curr_time
)
SELECT curr_time,
       TO_NUMBER(TO_CHAR(curr_time,'yyyy'),'9999') AS yr,
       TO_NUMBER(TO_CHAR(curr_time,'mm'),'99') AS mth,
       TO_NUMBER(TO_CHAR(curr_time,'dd'),'99') AS day,
       TO_NUMBER(TO_CHAR(curr_time,'hh24'),'99') AS hr,
       TO_NUMBER(TO_CHAR(curr_time,'mi'),'99') AS min,
       TO_NUMBER(TO_CHAR(curr_time,'ss'),'99') AS sec,
       TO_NUMBER(TO_CHAR(curr_time,'ms'),'999') AS ms,
       TO_NUMBER(TO_CHAR(curr_time,'us'),'999999') AS mcs
  FROM cTime;
```

- **Problem 2**:

```SQL
SELECT 'Sydney' AS city,
       CURRENT_TIMESTAMP::TIMESTAMP AS local_time,
       TIMEZONE('UTC',CURRENT_TIMESTAMP) AS utc_time,
       CURRENT_TIMESTAMP - TIMEZONE('UTC',CURRENT_TIMESTAMP) AS utc_off_set,
       CURRENT_TIMESTAMP - CURRENT_TIMESTAMP AS sydney_off_set
UNION ALL
SELECT 'Rome' AS city,
       TIMEZONE('CETDST',CURRENT_TIMESTAMP)::TIMESTAMP,
       TIMEZONE('UTC',CURRENT_TIMESTAMP),
       TIMEZONE('CETDST',CURRENT_TIMESTAMP) - TIMEZONE('UTC',CURRENT_TIMESTAMP),
       CURRENT_TIMESTAMP - TIMEZONE('CETDST',CURRENT_TIMESTAMP) AS sydney_off_set
UNION ALL
SELECT 'New York' AS city,
       TIMEZONE('EDT',CURRENT_TIMESTAMP)::TIMESTAMP,
       TIMEZONE('UTC',CURRENT_TIMESTAMP),
       TIMEZONE('EDT',CURRENT_TIMESTAMP) - TIMEZONE('UTC',CURRENT_TIMESTAMP),
       CURRENT_TIMESTAMP - TIMEZONE('EDT',CURRENT_TIMESTAMP) AS sydney_off_set
UNION ALL
SELECT 'Greenwich' AS city,
       TIMEZONE('GMT',CURRENT_TIMESTAMP)::TIMESTAMP,
       TIMEZONE('UTC',CURRENT_TIMESTAMP),
       TIMEZONE('GMT',CURRENT_TIMESTAMP) - TIMEZONE('UTC',CURRENT_TIMESTAMP),
       CURRENT_TIMESTAMP - TIMEZONE('GMT',CURRENT_TIMESTAMP) AS sydney_off_set
ORDER BY utc_off_set;
```

## Discussion

Use functions `TO_CHAR` and `TO_NUMBER` to return specific units of time from a date

```SQL
WITH cTime AS (
  SELECT CURRENT_TIMESTAMP::TIMESTAMP AS curr_time
)
SELECT curr_time, pg_typeof(curr_time)
  FROM cTime;
```


|curr_time       |        pg_typeof|
|:----------------------------:|:------------------------:|
|2022-08-14 19:33:34.515635+10 | timestamp with time zone|


The `CURRENT_TIMESTAMP` function return a `TIMESTAMP with time zone` data type. The time zone is `+10` hours before the `UTC` time zone or `GMT` (Greenwich Mean Timezone).

```SQL
SELECT '2022-08-14 19:33:34.515635+10'::TIMESTAMP,
       TO_CHAR('2022-08-14 19:33:34.515635+10'::TIMESTAMP,'HH24') AS hr,
       pg_typeof(TO_CHAR('2022-08-14 19:33:34.515635+10'::TIMESTAMP,'HH24'));
```

|timestamp          | hr | pg_typeof|
|:-------------------------:|:--:|:---------:|
|2022-08-14 19:33:34.515635 | 19 | text|

Convert to `TIMESTAMP` without time zone.

```SQL
SELECT '2022-08-14 19:33:34.515635+10'::TIMESTAMP,
       TO_NUMBER(TO_CHAR('2022-08-14 19:33:34.515635+10'::TIMESTAMP,'HH24'),'99') AS hr,
       pg_typeof(TO_NUMBER(TO_CHAR('2022-08-14 19:33:34.515635+10'::TIMESTAMP,'HH24'),'99'));
```

|timestamp          | hr | pg_typeof|
|:-------------------------:|:---:|:---------:|
|2022-08-14 19:33:34.515635 | 19 | numeric|

Convert to numeric type.

Similar to the other conversion.
