# Histogram Standard Deviations

In lesson [desc_stats](./00_desc_stats.md), we summarized the main descriptive statics to analyse the duration of movies in the `film` table of the `dvdrental` sample database.

```console
median |  mean  | sample_std | sample_skeweness | sample_kurt
-------+--------+------------+------------------+-------------
   114 | 115.27 |      40.43 |             0.03 |       -1.17
```

The findings of the median, mean and skeweness describe an approximately symmetric distribution, (the mean is closed to the median and the sample skeweness indicates a distribution a bit skewed to the right but almost symmetric). The excess of kurtosis indicates an almost flat distribution compared to the normal distribution.

To visualize the meaning of those values, we want to plot the histograms of film duration values within bucket of standard deviations units away from the mean.


First, calculate the mean and standard deviation of `length` variable in the `film` table.

```SQL
WITH mean_std AS (
  SELECT ROUND(AVG(length),2) AS mu
       , ROUND(STDDEV(length),2) AS sigma
    FROM film
)
SELECT  mu
      , sigma
  FROM mean_std;
```

```console
mu     | sigma
-------+-------
115.27 | 40.43
```

Next, partition the distribution of values in separate intervals.

```SQL
WITH mean_std AS (
  SELECT ROUND(AVG(length),2) AS mu
       , ROUND(STDDEV(length),2) AS sigma
    FROM film
)
SELECT  f.length AS x
      , CASE WHEN f.length < ROUND(m.mu - 3*sigma,2)
             THEN '(-inf ' || ' ' || ROUND(m.mu - 3*sigma,2)::TEXT || ')'
             WHEN f.length < ROUND(m.mu - 2*sigma,2)
             THEN '[' || ROUND(m.mu - 3*sigma,2)::TEXT || ' ' || ROUND(m.mu - 2*sigma,2)::TEXT || ')'
             WHEN f.length < ROUND(m.mu - sigma,2)
             THEN '[' || ROUND(m.mu - 2*sigma,2)::TEXT || ' ' || ROUND(m.mu - sigma,2)::TEXT || ')'
             WHEN f.length < m.mu
             THEN '[' || ROUND(m.mu - sigma,2)::TEXT || ' ' || m.mu::TEXT || ')'
             WHEN f.length = m.mu
             THEN '[' || m.mu::TEXT || ']'
             WHEN f.length <= ROUND(m.mu + sigma,2)
             THEN '(' || m.mu::TEXT || ' ' || ROUND(m.mu + sigma,2)::TEXT || ']'
             WHEN f.length <= ROUND(m.mu + 2*sigma,2)
             THEN '(' || ROUND(m.mu + sigma,2)::TEXT || ' ' || ROUND(m.mu + 2*sigma,2)::TEXT || ']'
             WHEN f.length <= ROUND(m.mu + 3*sigma,2)
             THEN '(' || ROUND(m.mu + 2*sigma,2)::TEXT || ' ' || ROUND(m.mu + 3*sigma,2) || ']'
             ELSE '(' || ROUND(m.mu + 3*sigma,2)::TEXT || ' ' || '+inf)'
        END AS bin
      , CASE WHEN f.length < ROUND(m.mu - 3*sigma,2) THEN -4
             WHEN f.length < ROUND(m.mu - 2*sigma,2) THEN -3
             WHEN f.length < ROUND(m.mu - sigma,2) THEN -2
             WHEN f.length < m.mu THEN -1
             WHEN f.length = m.mu THEN 0
             WHEN f.length <= ROUND(m.mu + sigma,2) THEN 1
             WHEN f.length <= ROUND(m.mu + 2*sigma,2) THEN 2
             WHEN f.length <= ROUND(m.mu + 3*sigma,2) THEN 3
             ELSE 4
        END AS class_id
  FROM film f, mean_std m
  ORDER BY x;
```

The `class_id` number indicates how many standard deviations away is the data point (x) from the mean. For example, the value `-2` indicates that the point is less than two standard deviations away from the mean. More precisely, it indicates the following bucket `[mu -2s   mu-s)`. Similarly, the value `2` indicates the following interval `(mu + s   mu + 2s]`. The value `0` indicates the mean.

```console
x  |       bin       | class_id
---+-----------------+----------
46 | [34.41 74.84)   |       -2
46 | [34.41 74.84)   |       -2
46 | [34.41 74.84)   |       -2
46 | [34.41 74.84)   |       -2
46 | [34.41 74.84)   |       -2
47 | [34.41 74.84)   |       -2
47 | [34.41 74.84)   |       -2
47 | [34.41 74.84)   |       -2
47 | [34.41 74.84)   |       -2
47 | [34.41 74.84)   |       -2
..      ..                   ..

```


Next, count the number of samples in each bucket.

```SQL
WITH mean_std AS (
  SELECT ROUND(AVG(length),2) AS mu
       , ROUND(STDDEV(length),2) AS sigma
    FROM film
),
binning AS (
  SELECT  f.length AS x
        , CASE WHEN f.length < ROUND(m.mu - 3*sigma,2)
               THEN '(-inf ' || ' ' || ROUND(m.mu - 3*sigma,2)::TEXT || ')'
               WHEN f.length < ROUND(m.mu - 2*sigma,2)
               THEN '[' || ROUND(m.mu - 3*sigma,2)::TEXT || ' ' || ROUND(m.mu - 2*sigma,2)::TEXT || ')'
               WHEN f.length < ROUND(m.mu - sigma,2)
               THEN '[' || ROUND(m.mu - 2*sigma,2)::TEXT || ' ' || ROUND(m.mu - sigma,2)::TEXT || ')'
               WHEN f.length < m.mu
               THEN '[' || ROUND(m.mu - sigma,2)::TEXT || ' ' || m.mu::TEXT || ')'
               WHEN f.length = m.mu
               THEN '[' || m.mu::TEXT || ']'
               WHEN f.length <= ROUND(m.mu + sigma,2)
               THEN '(' || m.mu::TEXT || ' ' || ROUND(m.mu + sigma,2)::TEXT || ']'
               WHEN f.length <= ROUND(m.mu + 2*sigma,2)
               THEN '(' || ROUND(m.mu + sigma,2)::TEXT || ' ' || ROUND(m.mu + 2*sigma,2)::TEXT || ']'
               WHEN f.length <= ROUND(m.mu + 3*sigma,2)
               THEN '(' || ROUND(m.mu + 2*sigma,2)::TEXT || ' ' || ROUND(m.mu + 3*sigma,2) || ']'
               ELSE '(' || ROUND(m.mu + 3*sigma,2)::TEXT || ' ' || '+inf)'
          END AS bin
        , CASE WHEN f.length < ROUND(m.mu - 3*sigma,2) THEN -4
               WHEN f.length < ROUND(m.mu - 2*sigma,2) THEN -3
               WHEN f.length < ROUND(m.mu - sigma,2) THEN -2
               WHEN f.length < m.mu THEN -1
               WHEN f.length = m.mu THEN 0
               WHEN f.length <= ROUND(m.mu + sigma,2) THEN 1
               WHEN f.length <= ROUND(m.mu + 2*sigma,2) THEN 2
               WHEN f.length <= ROUND(m.mu + 3*sigma,2) THEN 3
               ELSE 4
          END AS class_id
        , CASE WHEN f.length < ROUND(m.mu - 3*sigma,2) THEN '(-inf     mu - 3s)'
                 WHEN f.length < ROUND(m.mu - 2*sigma,2) THEN '[mu - 3s  mu - 2s)'
                 WHEN f.length < ROUND(m.mu - sigma,2) THEN '[mu - 2s   mu - s)'
                 WHEN f.length < m.mu THEN '[mu - s   mu)'
                 WHEN f.length = m.mu THEN '[mu]'
                 WHEN f.length <= ROUND(m.mu + sigma,2) THEN '(mu   mu + s]'
                 WHEN f.length <= ROUND(m.mu + 2*sigma,2) THEN '(mu + s   mu + 2s]'
                 WHEN f.length <= ROUND(m.mu + 3*sigma,2) THEN '(mu + 2s  mu + 3s]'
                 ELSE '(mu + 3s   +inf)'
            END AS class
    FROM film f, mean_std m
)
SELECT  class_id
      , class
      , bin
      , COUNT(x) AS x_cnt
  FROM  binning
 GROUP BY class_id, class, bin
 ORDER BY class_id;
```

```console
class_id |       class        |       bin       | x_cnt
---------+--------------------+-----------------+-------
      -2 | [mu - 2s   mu - s) | [34.41 74.84)   |   208
      -1 | [mu - s   mu)      | [74.84 115.27)  |   303
       1 | (mu   mu + s]      | (115.27 155.70] |   285
       2 | (mu + s   mu + 2s] | (155.70 196.13] |   204
(4 rows)
```

Next, compute the relative frequency count. The value is rounded to the closest integer.

```SQL
WITH mean_std AS (
  SELECT ROUND(AVG(length),2) AS mu
       , ROUND(STDDEV(length),2) AS sigma
    FROM film
),
binning AS (
  SELECT  f.length AS x
        , CASE WHEN f.length < ROUND(m.mu - 3*sigma,2)
               THEN '(-inf ' || ' ' || ROUND(m.mu - 3*sigma,2)::TEXT || ')'
               WHEN f.length < ROUND(m.mu - 2*sigma,2)
               THEN '[' || ROUND(m.mu - 3*sigma,2)::TEXT || ' ' || ROUND(m.mu - 2*sigma,2)::TEXT || ')'
               WHEN f.length < ROUND(m.mu - sigma,2)
               THEN '[' || ROUND(m.mu - 2*sigma,2)::TEXT || ' ' || ROUND(m.mu - sigma,2)::TEXT || ')'
               WHEN f.length < m.mu
               THEN '[' || ROUND(m.mu - sigma,2)::TEXT || ' ' || m.mu::TEXT || ')'
               WHEN f.length = m.mu
               THEN '[' || m.mu::TEXT || ']'
               WHEN f.length <= ROUND(m.mu + sigma,2)
               THEN '(' || m.mu::TEXT || ' ' || ROUND(m.mu + sigma,2)::TEXT || ']'
               WHEN f.length <= ROUND(m.mu + 2*sigma,2)
               THEN '(' || ROUND(m.mu + sigma,2)::TEXT || ' ' || ROUND(m.mu + 2*sigma,2)::TEXT || ']'
               WHEN f.length <= ROUND(m.mu + 3*sigma,2)
               THEN '(' || ROUND(m.mu + 2*sigma,2)::TEXT || ' ' || ROUND(m.mu + 3*sigma,2) || ']'
               ELSE '(' || ROUND(m.mu + 3*sigma,2)::TEXT || ' ' || '+inf)'
          END AS bin
        , CASE WHEN f.length < ROUND(m.mu - 3*sigma,2) THEN -4
               WHEN f.length < ROUND(m.mu - 2*sigma,2) THEN -3
               WHEN f.length < ROUND(m.mu - sigma,2) THEN -2
               WHEN f.length < m.mu THEN -1
               WHEN f.length = m.mu THEN 0
               WHEN f.length <= ROUND(m.mu + sigma,2) THEN 1
               WHEN f.length <= ROUND(m.mu + 2*sigma,2) THEN 2
               WHEN f.length <= ROUND(m.mu + 3*sigma,2) THEN 3
               ELSE 4
          END AS class_id
        , CASE WHEN f.length < ROUND(m.mu - 3*sigma,2) THEN '(-inf     mu - 3s)'
                 WHEN f.length < ROUND(m.mu - 2*sigma,2) THEN '[mu - 3s  mu - 2s)'
                 WHEN f.length < ROUND(m.mu - sigma,2) THEN '[mu - 2s   mu - s)'
                 WHEN f.length < m.mu THEN '[mu - s   mu)'
                 WHEN f.length = m.mu THEN '[mu]'
                 WHEN f.length <= ROUND(m.mu + sigma,2) THEN '(mu   mu + s]'
                 WHEN f.length <= ROUND(m.mu + 2*sigma,2) THEN '(mu + s   mu + 2s]'
                 WHEN f.length <= ROUND(m.mu + 3*sigma,2) THEN '(mu + 2s  mu + 3s]'
                 ELSE '(mu + 3s   +inf)'
            END AS class
    FROM film f, mean_std m
),
frequency AS (
  SELECT  class_id
        , class
        , bin
        , COUNT(x) AS x_cnt
    FROM  binning
   GROUP BY class_id, class, bin
)
SELECT  class_id
      , class
      , bin
      , x_cnt
      , ROUND((100.0*x_cnt/(1.0*SUM(x_cnt) OVER())),0) AS f_cnt
  FROM  frequency
 ORDER BY class_id;
```

```console
class_id |       class        |       bin       | x_cnt | f_cnt
---------+--------------------+-----------------+-------+-------
      -2 | [mu - 2s   mu - s) | [34.41 74.84)   |   208 |    21
      -1 | [mu - s   mu)      | [74.84 115.27)  |   303 |    30
       1 | (mu   mu + s]      | (115.27 155.70] |   285 |    29
       2 | (mu + s   mu + 2s] | (155.70 196.13] |   204 |    20
(4 rows)
```

Finally, plot the approximated frequency histogram.

```SQL
WITH mean_std AS (
  SELECT ROUND(AVG(length),2) AS mu
       , ROUND(STDDEV(length),2) AS sigma
    FROM film
),
binning AS (
  SELECT  f.length AS x
        , CASE WHEN f.length < ROUND(m.mu - 3*sigma,2)
               THEN '(-inf ' || ' ' || ROUND(m.mu - 3*sigma,2)::TEXT || ')'
               WHEN f.length < ROUND(m.mu - 2*sigma,2)
               THEN '[' || ROUND(m.mu - 3*sigma,2)::TEXT || ' ' || ROUND(m.mu - 2*sigma,2)::TEXT || ')'
               WHEN f.length < ROUND(m.mu - sigma,2)
               THEN '[' || ROUND(m.mu - 2*sigma,2)::TEXT || ' ' || ROUND(m.mu - sigma,2)::TEXT || ')'
               WHEN f.length < m.mu
               THEN '[' || ROUND(m.mu - sigma,2)::TEXT || ' ' || m.mu::TEXT || ')'
               WHEN f.length = m.mu
               THEN '[' || m.mu::TEXT || ']'
               WHEN f.length <= ROUND(m.mu + sigma,2)
               THEN '(' || m.mu::TEXT || ' ' || ROUND(m.mu + sigma,2)::TEXT || ']'
               WHEN f.length <= ROUND(m.mu + 2*sigma,2)
               THEN '(' || ROUND(m.mu + sigma,2)::TEXT || ' ' || ROUND(m.mu + 2*sigma,2)::TEXT || ']'
               WHEN f.length <= ROUND(m.mu + 3*sigma,2)
               THEN '(' || ROUND(m.mu + 2*sigma,2)::TEXT || ' ' || ROUND(m.mu + 3*sigma,2) || ']'
               ELSE '(' || ROUND(m.mu + 3*sigma,2)::TEXT || ' ' || '+inf)'
          END AS bin
        , CASE WHEN f.length < ROUND(m.mu - 3*sigma,2) THEN -4
               WHEN f.length < ROUND(m.mu - 2*sigma,2) THEN -3
               WHEN f.length < ROUND(m.mu - sigma,2) THEN -2
               WHEN f.length < m.mu THEN -1
               WHEN f.length = m.mu THEN 0
               WHEN f.length <= ROUND(m.mu + sigma,2) THEN 1
               WHEN f.length <= ROUND(m.mu + 2*sigma,2) THEN 2
               WHEN f.length <= ROUND(m.mu + 3*sigma,2) THEN 3
               ELSE 4
          END AS class_id
        , CASE WHEN f.length < ROUND(m.mu - 3*sigma,2) THEN '(-inf     mu - 3s)'
                 WHEN f.length < ROUND(m.mu - 2*sigma,2) THEN '[mu - 3s  mu - 2s)'
                 WHEN f.length < ROUND(m.mu - sigma,2) THEN '[mu - 2s   mu - s)'
                 WHEN f.length < m.mu THEN '[mu - s   mu)'
                 WHEN f.length = m.mu THEN '[mu]'
                 WHEN f.length <= ROUND(m.mu + sigma,2) THEN '(mu   mu + s]'
                 WHEN f.length <= ROUND(m.mu + 2*sigma,2) THEN '(mu + s   mu + 2s]'
                 WHEN f.length <= ROUND(m.mu + 3*sigma,2) THEN '(mu + 2s  mu + 3s]'
                 ELSE '(mu + 3s   +inf)'
            END AS class
    FROM film f, mean_std m
),
frequency AS (
  SELECT  class_id
        , class
        , bin
        , COUNT(x) AS x_cnt
    FROM  binning
   GROUP BY class_id, class, bin
),
histogram AS (
  SELECT  class_id
        , class
        , bin
        , x_cnt
        , ROUND((100.0*x_cnt/(1.0*SUM(x_cnt) OVER())),0) AS f_cnt
    FROM  frequency
)
SELECT h.*
      , SUM(f_cnt) OVER(ORDER BY class_id) AS f_cumul
      , LPAD('*',f_cnt::INTEGER,'*') AS f_cnt_plot
  FROM histogram h
 ORDER BY class_id;
```

```console
class_id |       class        |       bin       | x_cnt | f_cnt | f_cumul |           f_cnt_plot
---------+--------------------+-----------------+-------+-------+---------+--------------------------------
      -2 | [mu - 2s   mu - s) | [34.41 74.84)   |   208 |    21 |      21 | *********************
      -1 | [mu - s   mu)      | [74.84 115.27)  |   303 |    30 |      51 | ******************************
       1 | (mu   mu + s]      | (115.27 155.70] |   285 |    29 |      80 | *****************************
       2 | (mu + s   mu + 2s] | (155.70 196.13] |   204 |    20 |     100 | ********************
(4 rows)
```

The horizontal histogram shows that the distribution is approximately symmetric and 51% of the values are closer to the minimum. The conclusion is confirmed by the small positive value of the skeweness coefficient (`0.03`).
