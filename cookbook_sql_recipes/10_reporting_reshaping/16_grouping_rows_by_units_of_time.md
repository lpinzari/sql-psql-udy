# Grouping Rows by Units of Time

You want to `summarize data` by **some interval of time**.

## Problem

For example, you have a `transaction log` and want to **summarize transactions** `by five-second intervals`. The rows in table `TRX_LOG` are shown here:

```SQL
CREATE TABLE trx_log (
  trx_id INTEGER PRIMARY KEY,
  trx_date TIMESTAMP,
  trx_cnt INTEGER
);

INSERT INTO trx_log
       (trx_id, trx_date, trx_cnt)
VALUES (1,'2020-07-28 19:03:07',44),
       (2,'2020-07-28 19:03:08',18),
       (3,'2020-07-28 19:03:09',23),
       (4,'2020-07-28 19:03:10',29),
       (5,'2020-07-28 19:03:11',27),
       (6,'2020-07-28 19:03:12',45),
       (7,'2020-07-28 19:03:13',45),
       (8,'2020-07-28 19:03:14',32),
       (9,'2020-07-28 19:03:15',41),
       (10,'2020-07-28 19:03:16',15),
       (11,'2020-07-28 19:03:17',24),
       (12,'2020-07-28 19:03:18',47),
       (13,'2020-07-28 19:03:19',37),
       (14,'2020-07-28 19:03:20',48),
       (15,'2020-07-28 19:03:21',46),
       (16,'2020-07-28 19:03:22',44),
       (17,'2020-07-28 19:03:23',36),
       (18,'2020-07-28 19:03:24',41),
       (19,'2020-07-28 19:03:25',33),
       (20,'2020-07-28 19:03:26',19);
```

```SQL
SELECT *
  FROM trx_log
 ORDER BY trx_date;
```

|trx_id |      trx_date       | trx_cnt|
|:-----:|:-------------------:|:------:|
|     1 | 2020-07-28 19:03:07 |      44|
|     2 | 2020-07-28 19:03:08 |      18|
|     3 | 2020-07-28 19:03:09 |      23|
|     4 | 2020-07-28 19:03:10 |      29|
|     5 | 2020-07-28 19:03:11 |      27|
|     6 | 2020-07-28 19:03:12 |      45|
|     7 | 2020-07-28 19:03:13 |      45|
|     8 | 2020-07-28 19:03:14 |      32|
|     9 | 2020-07-28 19:03:15 |      41|
|    10 | 2020-07-28 19:03:16 |      15|
|    11 | 2020-07-28 19:03:17 |      24|
|    12 | 2020-07-28 19:03:18 |      47|
|    13 | 2020-07-28 19:03:19 |      37|
|    14 | 2020-07-28 19:03:20 |      48|
|    15 | 2020-07-28 19:03:21 |      46|
|    16 | 2020-07-28 19:03:22 |      44|
|    17 | 2020-07-28 19:03:23 |      36|
|    18 | 2020-07-28 19:03:24 |      41|
|    19 | 2020-07-28 19:03:25 |      33|
|    20 | 2020-07-28 19:03:26 |      19|

You want to return the following result set:

|grp |      trx_start      |       trx_end       | total|
|:--:|:-------------------:|:-------------------:|:----:|
|  1 | 2020-07-28 19:03:07 | 2020-07-28 19:03:11 |   141|
|  2 | 2020-07-28 19:03:12 | 2020-07-28 19:03:16 |   178|
|  3 | 2020-07-28 19:03:17 | 2020-07-28 19:03:21 |   202|
|  4 | 2020-07-28 19:03:22 | 2020-07-28 19:03:26 |   173|



## Solution

```SQL
SELECT CEIL(trx_id/5.0) AS grp,
       MIN(trx_date) AS trx_start,
       MAX(trx_date) AS trx_end,
       SUM(trx_cnt) AS total
  FROM trx_log
 GROUP BY grp
 ORDER BY grp;
```

**Solution 2**

```SQL
WITH x AS (
  SELECT trx_date, trx_cnt,
         MIN(trx_date) OVER() AS min_trx_date
    FROM trx_log
),
logs AS (
  SELECT trx_date,
         trx_cnt,
         CEIL(((EXTRACT('EPOCH' FROM (trx_date - min_trx_date ))+1)/5.0)::NUMERIC) AS grp
    FROM x
)
SELECT grp,
       MIN(trx_date) AS trx_start,
       MAX(trx_date) AS trx_end,
       SUM(trx_cnt) AS total
  FROM logs
 GROUP BY grp
 ORDER BY grp;
```


## Discussion

The first step, and the key to the whole solution, is to logically group the rows together. By `dividing by five` and **taking the smallest whole number greater than the quotient**, you can create logical groups. For example:

```SQL
SELECT trx_id,
       trx_date,
       trx_cnt,
       ROUND(trx_id/5.0,2) AS val,
       CEIL(trx_id/5.0) AS grp
  FROM trx_log;
```

|trx_id |      trx_date       | trx_cnt | val  | grp|
|:-----:|:-------------------:|:--------:|:----:|:--:|
|     1 | 2020-07-28 19:03:07 |      44 | 0.20 |   1|
|     2 | 2020-07-28 19:03:08 |      18 | 0.40 |   1|
|     3 | 2020-07-28 19:03:09 |      23 | 0.60 |   1|
|     4 | 2020-07-28 19:03:10 |      29 | 0.80 |   1|
|     5 | 2020-07-28 19:03:11 |      27 | 1.00 |   1|
|     6 | 2020-07-28 19:03:12 |      45 | 1.20 |   2|
|     7 | 2020-07-28 19:03:13 |      45 | 1.40 |   2|
|     8 | 2020-07-28 19:03:14 |      32 | 1.60 |   2|
|     9 | 2020-07-28 19:03:15 |      41 | 1.80 |   2|
|    10 | 2020-07-28 19:03:16 |      15 | 2.00 |   2|
|    11 | 2020-07-28 19:03:17 |      24 | 2.20 |   3|
|    12 | 2020-07-28 19:03:18 |      47 | 2.40 |   3|
|    13 | 2020-07-28 19:03:19 |      37 | 2.60 |   3|
|    14 | 2020-07-28 19:03:20 |      48 | 2.80 |   3|
|    15 | 2020-07-28 19:03:21 |      46 | 3.00 |   3|
|    16 | 2020-07-28 19:03:22 |      44 | 3.20 |   4|
|    17 | 2020-07-28 19:03:23 |      36 | 3.40 |   4|
|    18 | 2020-07-28 19:03:24 |      41 | 3.60 |   4|
|    19 | 2020-07-28 19:03:25 |      33 | 3.80 |   4|
|    20 | 2020-07-28 19:03:26 |      19 | 4.00 |   4|

The last step is to apply the appropriate aggregate functions to find the total number of transactions per five seconds, along with the start and end times for each transaction:

```SQL
SELECT CEIL(trx_id/5.0) AS grp,
       MIN(trx_date) AS trx_start,
       MAX(trx_date) AS trx_end,
       SUM(trx_cnt) AS total
  FROM trx_log
 GROUP BY grp
 ORDER BY grp;
```

|grp |      trx_start      |       trx_end       | total|
|:--:|:-------------------:|:-------------------:|:----:|
|  1 | 2020-07-28 19:03:07 | 2020-07-28 19:03:11 |   141|
|  2 | 2020-07-28 19:03:12 | 2020-07-28 19:03:16 |   178|
|  3 | 2020-07-28 19:03:17 | 2020-07-28 19:03:21 |   202|
|  4 | 2020-07-28 19:03:22 | 2020-07-28 19:03:26 |   173|


The following query returns all rows from `TRX_LOG` along with a running total for `TRX_CNT` by logical “group,” and the TOTAL for `TRX_CNT` for each row in the “group”


```SQL
SELECT trx_date, trx_cnt,
       SUM(trx_cnt) OVER(PARTITION BY CEIL(trx_id/5.0)
                             ORDER BY trx_date
                             RANGE BETWEEN UNBOUNDED PRECEDING
                                       AND CURRENT ROW)
       AS running_total,
       SUM(trx_cnt) OVER(PARTITION BY CEIL(trx_id/5.0)) AS total,
       CASE WHEN MOD(trx_id,5.0) = 0 THEN 'X' END grp_end
  FROM trx_log;
```

|trx_date       | trx_cnt | running_total | total | grp_end|
|:-------------:|:-------:|:-------------:|:------:|:-----:|
|2020-07-28 19:03:07 |      44 |            44 |   141 ||
|2020-07-28 19:03:08 |      18 |            62 |   141 ||
|2020-07-28 19:03:09 |      23 |            85 |   141 ||
|2020-07-28 19:03:10 |      29 |           114 |   141 ||
|2020-07-28 19:03:11 |      27 |           141 |   141 | X|
|2020-07-28 19:03:12 |      45 |            45 |   178 ||
|2020-07-28 19:03:13 |      45 |            90 |   178 ||
|2020-07-28 19:03:14 |      32 |           122 |   178 ||
|2020-07-28 19:03:15 |      41 |           163 |   178 ||
|2020-07-28 19:03:16 |      15 |           178 |   178 | X|
|2020-07-28 19:03:17 |      24 |            24 |   202 ||
|2020-07-28 19:03:18 |      47 |            71 |   202 ||
|2020-07-28 19:03:19 |      37 |           108 |   202 ||
|2020-07-28 19:03:20 |      48 |           156 |   202 ||
|2020-07-28 19:03:21 |      46 |           202 |   202 | X|
|2020-07-28 19:03:22 |      44 |            44 |   173 ||
|2020-07-28 19:03:23 |      36 |            80 |   173 ||
|2020-07-28 19:03:24 |      41 |           121 |   173 ||
|2020-07-28 19:03:25 |      33 |           154 |   173 ||
|2020-07-28 19:03:26 |      19 |           173 |   173 | X|

- **Solution 2**:


If your data is slightly different (perhaps you `don’t have an ID for each row`), you can always “group” by **dividing the seconds of each** `TRX_DATE` row **by five** to create a similar grouping. This time, however, the numerator is the difference between the `trx_date` and the first transaction `min_trx_date`. The following is an example of this technique.


```SQL
WITH x AS (
SELECT trx_date, trx_cnt,
       MIN(trx_date) OVER() AS min_trx_date
  FROM trx_log
)
SELECT trx_date,
       EXTRACT('EPOCH' FROM (trx_date - min_trx_date )) AS seconds,
       ROUND((EXTRACT('EPOCH' FROM (trx_date - min_trx_date ))/5.0)::NUMERIC,2) AS val,
       CEIL((EXTRACT('EPOCH' FROM (trx_date - min_trx_date ))/5.0)::NUMERIC) AS grp
  FROM x;
```

|trx_date       | seconds | val  | grp|
|:------------------:|:-------:|:----:|:---:|
|2020-07-28 19:03:07 |       0 | 0.00 |   0|
|2020-07-28 19:03:08 |       1 | 0.20 |   1|
|2020-07-28 19:03:09 |       2 | 0.40 |   1|
|2020-07-28 19:03:10 |       3 | 0.60 |   1|
|2020-07-28 19:03:11 |       4 | 0.80 |   1|
|2020-07-28 19:03:12 |       5 | 1.00 |   1|
|2020-07-28 19:03:13 |       6 | 1.20 |   2|
|2020-07-28 19:03:14 |       7 | 1.40 |   2|
|2020-07-28 19:03:15 |       8 | 1.60 |   2|
|2020-07-28 19:03:16 |       9 | 1.80 |   2|
|2020-07-28 19:03:17 |      10 | 2.00 |   2|
|2020-07-28 19:03:18 |      11 | 2.20 |   3|
|2020-07-28 19:03:19 |      12 | 2.40 |   3|
|2020-07-28 19:03:20 |      13 | 2.60 |   3|
|2020-07-28 19:03:21 |      14 | 2.80 |   3|
|2020-07-28 19:03:22 |      15 | 3.00 |   3|
|2020-07-28 19:03:23 |      16 | 3.20 |   4|
|2020-07-28 19:03:24 |      17 | 3.40 |   4|
|2020-07-28 19:03:25 |      18 | 3.60 |   4|
|2020-07-28 19:03:26 |      19 | 3.80 |   4|

Regardless of the actual values for `GRP`, the key here is that you are grouping for every five seconds.

```SQL
WITH x AS (
SELECT trx_date, trx_cnt,
       MIN(trx_date) OVER() AS min_trx_date
  FROM trx_log
)
SELECT trx_date,
       EXTRACT('EPOCH' FROM (trx_date - min_trx_date )) + 1 AS seconds,
       ROUND(((EXTRACT('EPOCH' FROM (trx_date - min_trx_date ))+1)/5.0)::NUMERIC,2) AS val,
       CEIL(((EXTRACT('EPOCH' FROM (trx_date - min_trx_date ))+1)/5.0)::NUMERIC) AS grp
  FROM x;
```

```console
|trx_date       | seconds | val  | grp|
|:------------------:|:-------:|:----:|:---:|
|2020-07-28 19:03:07 |       1 | 0.20 |   1|
|2020-07-28 19:03:08 |       2 | 0.40 |   1|
|2020-07-28 19:03:09 |       3 | 0.60 |   1|
|2020-07-28 19:03:10 |       4 | 0.80 |   1|
|2020-07-28 19:03:11 |       5 | 1.00 |   1|
|2020-07-28 19:03:12 |       6 | 1.20 |   2|
|2020-07-28 19:03:13 |       7 | 1.40 |   2|
|2020-07-28 19:03:14 |       8 | 1.60 |   2|
|2020-07-28 19:03:15 |       9 | 1.80 |   2|
|2020-07-28 19:03:16 |      10 | 2.00 |   2|
|2020-07-28 19:03:17 |      11 | 2.20 |   3|
|2020-07-28 19:03:18 |      12 | 2.40 |   3|
|2020-07-28 19:03:19 |      13 | 2.60 |   3|
|2020-07-28 19:03:20 |      14 | 2.80 |   3|
|2020-07-28 19:03:21 |      15 | 3.00 |   3|
|2020-07-28 19:03:22 |      16 | 3.20 |   4|
|2020-07-28 19:03:23 |      17 | 3.40 |   4|
|2020-07-28 19:03:24 |      18 | 3.60 |   4|
|2020-07-28 19:03:25 |      19 | 3.80 |   4|
|2020-07-28 19:03:26 |      20 | 4.00 |   4|
```

From there you can apply the aggregate functions in the same way as in the original solution:

```SQL
WITH x AS (
  SELECT trx_date, trx_cnt,
         MIN(trx_date) OVER() AS min_trx_date
    FROM trx_log
),
logs AS (
  SELECT trx_date,
         trx_cnt,
         CEIL(((EXTRACT('EPOCH' FROM (trx_date - min_trx_date ))+1)/5.0)::NUMERIC) AS grp
    FROM x
)
SELECT grp,
       MIN(trx_date) AS trx_start,
       MAX(trx_date) AS trx_end,
       SUM(trx_cnt) AS total
  FROM logs
 GROUP BY grp
 ORDER BY grp;
```

|grp |      trx_start      |       trx_end       | total|
|:--:|:-------------------:|:-------------------:|:----:|
|  1 | 2020-07-28 19:03:07 | 2020-07-28 19:03:11 |   141|
|  2 | 2020-07-28 19:03:12 | 2020-07-28 19:03:16 |   178|
|  3 | 2020-07-28 19:03:17 | 2020-07-28 19:03:21 |   202|
|  4 | 2020-07-28 19:03:22 | 2020-07-28 19:03:26 |   173|
