# The Chi-square Distribution

The Chi-square distribution results when `v` independent variables with standard normal distribution are squared and summed:

Let `v` be the number of independent variables with standard normal distribution X<sub>1</sub>, X<sub>2</sub>, ..., X<sub>v</sub> with mean (mu = 0) and standard deviation (sigma = 1), then the chi-square random variable distribution is:

- X<sup>2</sup> =  X<sup>2</sup><sub>1</sub> + X<sup>2</sup><sub>2</sub> + ... + X<sup>2</sup><sub>v</sub>.

## Problem 1: Simulating random chi-square variables 1 DOF

Let's study first the simple case of `v=1`.

- X<sup>2</sup> = X<sup>2</sup><sub>1</sub>

In this section, we’ll show you how to generate **1000** `chi-square` random variables by squaring random standard normal variables.

1. Generate `1,000,000` random standard variables z.


```SQL
WITH RECURSIVE normal AS (
  SELECT '(-inf -4.7]' AS bin
        , -4.75 AS z_inf
        , -4.8 AS z
        , (pnorm(-4.7)::NUMERIC(7,6)*1000000)::INTEGER AS freq
  UNION ALL
  SELECT '(' || z_inf::TEXT || ' ' || (z_inf + 0.1)::TEXT || ']'
        , z_inf + 0.1 AS z_inf
        , z_inf + 0.05 AS z
        , CASE WHEN z = 4.7
               THEN  (((1 - pnorm(z))::NUMERIC(7,6))*1000000)::INTEGER
               ELSE
              ((pnorm(z_inf + 0.1)::NUMERIC(7,6) - pnorm(z_inf)::NUMERIC(7,6))*1000000)::INTEGER
          END AS freq
    FROM normal
   WHERE z <= 4.7
)
 SELECT  z
       , freq
   FROM normal
  ORDER BY 1;
```

```console
z     | freq
------+-------
-4.8  |     1
-4.70 |     1
-4.60 |     1
-4.50 |     1
-4.40 |     3
-4.30 |     4
-4.20 |     6
-4.10 |     9
-4.00 |    13
-3.90 |    20
-3.80 |    30
-3.70 |    42
-3.60 |    62
-3.50 |    87
-3.40 |   124
-3.30 |   173
-3.20 |   239
-3.10 |   328
-3.00 |   445
-2.90 |   597
-2.80 |   794
-2.70 |  1044
-2.60 |  1362
-2.50 |  1757
-2.40 |  2244
-2.30 |  2838
-2.20 |  3553
-2.10 |  4404
-2.00 |  5406
-1.90 |  6569
-1.80 |  7902
-1.70 |  9412
-1.60 | 11100
-1.50 | 12958
-1.40 | 14979
-1.30 | 17142
-1.20 | 19422
-1.10 | 21787
-1.00 | 24197
-0.90 | 26607
-0.80 | 28964
-0.70 | 31219
-0.60 | 33314
-0.50 | 35195
-0.40 | 36814
-0.30 | 38125
-0.20 | 39088
-0.10 | 39679
0.00  | 39878
0.10  | 39679
0.20  | 39088
```

Let's save the query as a view.

```SQL
CREATE VIEW normal_z_1M AS (
WITH RECURSIVE normal AS (
  SELECT '(-inf -4.7]' AS bin
        , -4.75 AS z_inf
        , -4.8 AS z
        , (pnorm(-4.7)::NUMERIC(7,6)*1000000)::INTEGER AS freq
  UNION ALL
  SELECT '(' || z_inf::TEXT || ' ' || (z_inf + 0.1)::TEXT || ']'
        , z_inf + 0.1 AS z_inf
        , z_inf + 0.05 AS z
        , CASE WHEN z = 4.7
               THEN  (((1 - pnorm(z))::NUMERIC(7,6))*1000000)::INTEGER
               ELSE
              ((pnorm(z_inf + 0.1)::NUMERIC(7,6) - pnorm(z_inf)::NUMERIC(7,6))*1000000)::INTEGER
          END AS freq
    FROM normal
   WHERE z <= 4.7
)
 SELECT  z
       , freq
   FROM normal
  ORDER BY 1
);
```


Let's expand the frequency vector to a vector of `1,000,000` zscore observation values.


```SQL
WITH RECURSIVE duplicate_val AS (
  SELECT *
    FROM normal_z_1M
   UNION ALL
  SELECT v.z AS z
        , v.freq - 1 AS freq
    FROM duplicate_val v
   INNER JOIN normal_z_1M w
      ON v.z = w.z
   WHERE v.freq > 1
)
SELECT *
  FROM duplicate_val
 ORDER BY z, freq;
```

```console
z     | freq
------+-------
-4.8  |     1
-4.70 |     1
-4.60 |     1
-4.50 |     1
-4.40 |     1
-4.40 |     2
-4.40 |     3
-4.30 |     1
-4.30 |     2
-4.30 |     3
-4.30 |     4
-4.20 |     1
-4.20 |     2
-4.20 |     3
-4.20 |     4
-4.20 |     5
-4.20 |     6
-4.10 |     1
-4.10 |     2
-4.10 |     3
-4.10 |     4
-4.10 |     5
-4.10 |     6
-4.10 |     7
-4.10 |     8
-4.10 |     9
```

Let's enumerate the zscore observation.

```SQL
WITH RECURSIVE duplicate_val AS (
  SELECT *
    FROM normal_z_1M
   UNION ALL
  SELECT v.z AS z
        , v.freq - 1 AS freq
    FROM duplicate_val v
   INNER JOIN normal_z_1M w
      ON v.z = w.z
   WHERE v.freq > 1
)
SELECT  ROW_NUMBER() OVER(ORDER BY z, freq) AS ob_id
      , z
  FROM duplicate_val
 ORDER BY ob_id;
```

```console
ob_id |   z
------+-------
    1 |  -4.8
    2 | -4.70
    3 | -4.60
    4 | -4.50
    5 | -4.40
    6 | -4.40
    7 | -4.40
    8 | -4.30
    9 | -4.30
   10 | -4.30
   11 | -4.30
   12 | -4.20
   13 | -4.20
   14 | -4.20
   15 | -4.20
   16 | -4.20
   17 | -4.20
   18 | -4.10
   19 | -4.10
   20 | -4.10
   21 | -4.10
   22 | -4.10
   23 | -4.10
   24 | -4.10
   25 | -4.10
   26 | -4.10
```

Let's create a view of the previous query.

```SQL
CREATE VIEW normal_z_1M_obs AS (
WITH RECURSIVE duplicate_val AS (
  SELECT *
    FROM normal_z_1M
   UNION ALL
  SELECT v.z AS z
        , v.freq - 1 AS freq
    FROM duplicate_val v
   INNER JOIN normal_z_1M w
      ON v.z = w.z
   WHERE v.freq > 1
)
SELECT  ROW_NUMBER() OVER(ORDER BY z, freq) AS ob_id
      , z
  FROM duplicate_val
 ORDER BY ob_id
);
```

Now we have `1,000,000` zscore samples.

```console
dvdrental=# SELECT COUNT(*) FROM normal_z_1M_obs;
  count
---------
 1000000
(1 row)
```

Let's check the mean and standard deviation.

```SQL
SELECT ROUND(AVG(z),2) AS mean
     , ROUND(STDDEV_POP(z),2) AS std_p
  FROM normal_z_1M_obs;
```

```console
mean | std_p
-----+-------
0.00 |  1.00
```

2. Randomly select an observation from a standard normal distribution with a mean zero and standard deviation  of 1 and square the result. The result squared is an observation from a `chi-square` distribution with `1` degree of freedom.

```SQL
WITH samples AS (
  SELECT FLOOR(RANDOM()*1000000)::INTEGER + 1 AS rw_nm
)
SELECT (SELECT rw_nm FROM samples)
      , ob_id
      , z
      , ROUND(POWER(z,2),2) AS chi_sq_x
 FROM normal_z_1M_obs
WHERE ob_id = (SELECT rw_nm FROM samples);
```

```console
rw_nm  | ob_id  |  z   | chi_sq_x
-------+--------+------+----------
871692 | 871692 | 1.10 |     1.21
```

3. Now let's repeat this 1000 times and make a histogram:

First, generate `1000` random values in the range `[1 1,000,000]`.

```SQL
WITH samples AS (
  SELECT  t.id AS id
        , t.rw_nm * FLOOR(RANDOM()*1000000)::INTEGER + 1 AS rw_nm
  FROM (SELECT *
          FROM GENERATE_SERIES(1,1000) AS id, (SELECT 1 AS rw_nm) x ) t
)
SELECT *
  FROM samples
 ORDER BY id;
```

```console
id  | rw_nm
----+--------
  1 | 750899
  2 | 807822
  3 | 317935
  4 |  88451
  5 | 295362
  6 | 316929
  7 | 138962
  8 | 421594
  9 | 775450
 10 | 157827
 11 | 435657
 12 | 506378
 13 | 684846
 14 | 332414
 15 | 176097
 16 | 726721
 17 | 104039
 18 | 836660
 19 | 652705
 20 | 925271
```

Next, randomly select `with replacement` 1000 observations from a standard normal distribution and squared the result.

```SQL
WITH samples AS (
  SELECT  t.id AS id
        , t.rw_nm * FLOOR(RANDOM()*1000000)::INTEGER + 1 AS rw_nm
  FROM (SELECT *
          FROM GENERATE_SERIES(1,1000) AS id, (SELECT 1 AS rw_nm) x ) t
)
SELECT  ob_id
      , z
      , ROUND(POWER(z,2)::NUMERIC,2) AS chi_sq_x
 FROM normal_z_1M_obs nz
INNER JOIN samples s
   ON nz.ob_id = s.rw_nm
ORDER BY chi_sq_x,z,ob_id;
```

```console
ob_id  |   z   | chi_sq_x
-------+-------+----------
480953 |  0.00 |     0.00
481769 |  0.00 |     0.00
481934 |  0.00 |     0.00
482739 |  0.00 |     0.00
483332 |  0.00 |     0.00
483838 |  0.00 |     0.00
484574 |  0.00 |     0.00
485669 |  0.00 |     0.00
486203 |  0.00 |     0.00
488127 |  0.00 |     0.00
488764 |  0.00 |     0.00
489641 |  0.00 |     0.00
489828 |  0.00 |     0.00
490186 |  0.00 |     0.00
490368 |  0.00 |     0.00
491019 |  0.00 |     0.00
491703 |  0.00 |     0.00
492237 |  0.00 |     0.00
493803 |  0.00 |     0.00
496862 |  0.00 |     0.00
497225 |  0.00 |     0.00
499053 |  0.00 |     0.00
500194 |  0.00 |     0.00
500275 |  0.00 |     0.00
504491 |  0.00 |     0.00
505189 |  0.00 |     0.00
505639 |  0.00 |     0.00
506317 |  0.00 |     0.00
509181 |  0.00 |     0.00
509869 |  0.00 |     0.00
510346 |  0.00 |     0.00
511646 |  0.00 |     0.00
512216 |  0.00 |     0.00
513219 |  0.00 |     0.00
513592 |  0.00 |     0.00
516557 |  0.00 |     0.00
518059 |  0.00 |     0.00
519068 |  0.00 |     0.00
441173 | -0.10 |     0.01
441628 | -0.10 |     0.01
442195 | -0.10 |     0.01
443087 | -0.10 |     0.01
443811 | -0.10 |     0.01
445919 | -0.10 |     0.01
446812 | -0.10 |     0.01
446919 | -0.10 |     0.01
446968 | -0.10 |     0.01
449356 | -0.10 |     0.01
449423 | -0.10 |     0.01
452840 | -0.10 |     0.01
453717 | -0.10 |     0.01
455055 | -0.10 |     0.01
455429 | -0.10 |     0.01
456187 | -0.10 |     0.01
457389 | -0.10 |     0.01
457742 | -0.10 |     0.01
458308 | -0.10 |     0.01
458867 | -0.10 |     0.01
460283 | -0.10 |     0.01
461103 | -0.10 |     0.01
462931 | -0.10 |     0.01
463956 | -0.10 |     0.01
463972 | -0.10 |     0.01
464134 | -0.10 |     0.01
464427 | -0.10 |     0.01
465686 | -0.10 |     0.01
465947 | -0.10 |     0.01
466504 | -0.10 |     0.01
467472 | -0.10 |     0.01
468075 | -0.10 |     0.01
473792 | -0.10 |     0.01
474136 | -0.10 |     0.01
474494 | -0.10 |     0.01
474763 | -0.10 |     0.01
475078 | -0.10 |     0.01
476552 | -0.10 |     0.01
477690 | -0.10 |     0.01
478203 | -0.10 |     0.01
479676 | -0.10 |     0.01
519941 |  0.10 |     0.01
523468 |  0.10 |     0.01
523550 |  0.10 |     0.01
525503 |  0.10 |     0.01
526330 |  0.10 |     0.01
527287 |  0.10 |     0.01
527391 |  0.10 |     0.01
528554 |  0.10 |     0.01
528616 |  0.10 |     0.01
528717 |  0.10 |     0.01
530075 |  0.10 |     0.01
530509 |  0.10 |     0.01
531357 |  0.10 |     0.01
534072 |  0.10 |     0.01
535894 |  0.10 |     0.01
537633 |  0.10 |     0.01
537638 |  0.10 |     0.01
540417 |  0.10 |     0.01
541073 |  0.10 |     0.01
542607 |  0.10 |     0.01
542800 |  0.10 |     0.01
544428 |  0.10 |     0.01
544626 |  0.10 |     0.01
544860 |  0.10 |     0.01
545214 |  0.10 |     0.01
546490 |  0.10 |     0.01
547415 |  0.10 |     0.01
547499 |  0.10 |     0.01
547864 |  0.10 |     0.01
549086 |  0.10 |     0.01
550227 |  0.10 |     0.01
551605 |  0.10 |     0.01
552120 |  0.10 |     0.01
552317 |  0.10 |     0.01
552577 |  0.10 |     0.01
553544 |  0.10 |     0.01
554357 |  0.10 |     0.01
556932 |  0.10 |     0.01
557563 |  0.10 |     0.01
402027 | -0.20 |     0.04
```

Let's save the `chi-square` distribution with one degree of freedom.

```SQL
CREATE TABLE chi_squared_dof1 AS (
WITH samples AS (
  SELECT  t.id AS id
        , t.rw_nm * FLOOR(RANDOM()*1000000)::INTEGER + 1 AS rw_nm
  FROM (SELECT *
          FROM GENERATE_SERIES(1,1000) AS id, (SELECT 1 AS rw_nm) x ) t
),
chi_squared_samples AS (
  SELECT  z
        , ROUND(POWER(z,2)::NUMERIC,2) AS chi_sq_x
   FROM normal_z_1M_obs nz
  INNER JOIN samples s
     ON nz.ob_id = s.rw_nm
)
SELECT chi_sq_x
  FROM chi_squared_samples
);

WITH diff AS (
  SELECT chi_sq_x AS x
       , COUNT(chi_sq_x) OVER() AS n
       , AVG(chi_sq_x) OVER() AS mean
       , STDDEV_POP(chi_sq_x) OVER() AS std_p
       , STDDEV(chi_sq_x) OVER() AS std
    FROM chi_squared_dof1
),
comp_sk_krt AS (
  SELECT n
       , PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY x) AS median
       , mean
       , std
       , SUM(POWER(x - mean,3))/(COUNT(x))  AS num_sk
       , POWER(std_p,3) AS den_sk
       , SUM(POWER(x - mean,4))/(COUNT(x))  AS num_krt
       , POWER(std_p,4) AS den_krt
    FROM diff
   GROUP BY n, mean, std, std_p
),
pop_sk_krt AS (
  SELECT  n
        , median
        , mean
        , std
        , num_sk/den_sk AS skw
        , num_krt/den_krt - 3 AS execess_krt
    FROM comp_sk_krt
)
SELECT  n
      , ROUND(median::NUMERIC,2) AS median
      , ROUND(mean,2) AS mean
      , ROUND(std,2) AS sample_std
      , ROUND((SQRT(n*(n-1.0))/(n-2.0))*skw,2) AS sample_skeweness
      , ROUND((n - 1)*((n + 1)*execess_krt + 6)/((n-2)*(n-3)),2) AS ex_kurt
  FROM pop_sk_krt;
```

```console
n    | median | mean | sample_std | sample_skeweness | ex_kurt
-----+--------+------+------------+------------------+---------
1000 |   0.49 | 1.02 |       1.39 |             2.51 |    8.12
```

Let's count the values' frequency.

```SQL
SELECT chi_sq_x
     , COUNT(chi_sq_x)
  FROM chi_squared_dof1
 GROUP BY 1
 ORDER BY 1;
```

```console
chi_sq_x | count
---------+-------
    0.00 |    27
    0.01 |    86
    0.04 |    65
    0.09 |    86
    0.16 |    67
    0.25 |    62
    0.36 |    73
    0.49 |    68
    0.64 |    62
    0.81 |    58
    1.00 |    48
    1.21 |    36
    1.44 |    36
    1.69 |    42
    1.96 |    30
    2.25 |    34
    2.56 |    26
    2.89 |    13
    3.24 |    14
    3.61 |    17
    4.00 |     6
    4.41 |     8
    4.84 |     9
    5.29 |     6
    5.76 |     5
    6.25 |     8
    6.76 |     2
    7.29 |     1
    7.84 |     2
    9.61 |     2
   10.24 |     1
```


```SQL
WITH chi_squared_cnt AS (
  SELECT chi_sq_x
       , COUNT(chi_sq_x) AS cnt
    FROM chi_squared_dof1
   GROUP BY 1
)
SELECT  CASE WHEN chi_sq_x <= 1
             THEN 1
             WHEN FLOOR(chi_sq_x)::INTEGER = CEIL(chi_sq_x)::INTEGER
             THEN (FLOOR(chi_sq_x)::INTEGER - 1) + 1
             ELSE FLOOR(chi_sq_x)::INTEGER + 1
        END AS id
       ,CASE WHEN chi_sq_x <= 1
            THEN '(0 1]'
            WHEN FLOOR(chi_sq_x)::INTEGER = CEIL(chi_sq_x)::INTEGER
            THEN '(' || (FLOOR(chi_sq_x)::INTEGER - 1)::TEXT || ' ' ||  (FLOOR(chi_sq_x)::INTEGER)::TEXT || ']'
            ELSE '(' || (FLOOR(chi_sq_x)::INTEGER)::TEXT || ' ' || (CEIL(chi_sq_x)::INTEGER)::TEXT || ']'
        END AS bin
      , chi_sq_x
      , cnt
  FROM chi_squared_cnt
 ORDER BY chi_sq_x;
```

```console
id  |   bin   | chi_sq_x | cnt
----+---------+----------+-----
  1 | (0 1]   |     0.00 |  27
  1 | (0 1]   |     0.01 |  86
  1 | (0 1]   |     0.04 |  65
  1 | (0 1]   |     0.09 |  86
  1 | (0 1]   |     0.16 |  67
  1 | (0 1]   |     0.25 |  62
  1 | (0 1]   |     0.36 |  73
  1 | (0 1]   |     0.49 |  68
  1 | (0 1]   |     0.64 |  62
  1 | (0 1]   |     0.81 |  58
  1 | (0 1]   |     1.00 |  48
  2 | (1 2]   |     1.21 |  36
  2 | (1 2]   |     1.44 |  36
  2 | (1 2]   |     1.69 |  42
  2 | (1 2]   |     1.96 |  30
  3 | (2 3]   |     2.25 |  34
  3 | (2 3]   |     2.56 |  26
  3 | (2 3]   |     2.89 |  13
  4 | (3 4]   |     3.24 |  14
  4 | (3 4]   |     3.61 |  17
  4 | (3 4]   |     4.00 |   6
  5 | (4 5]   |     4.41 |   8
  5 | (4 5]   |     4.84 |   9
  6 | (5 6]   |     5.29 |   6
  6 | (5 6]   |     5.76 |   5
  7 | (6 7]   |     6.25 |   8
  7 | (6 7]   |     6.76 |   2
  8 | (7 8]   |     7.29 |   1
  8 | (7 8]   |     7.84 |   2
 10 | (9 10]  |     9.61 |   2
 11 | (10 11] |    10.24 |   1
```


Let's plot the histogram:


```SQL
WITH chi_squared_cnt AS (
  SELECT chi_sq_x
       , COUNT(chi_sq_x) AS cnt
    FROM chi_squared_dof1
   GROUP BY 1
),
binning AS (
  SELECT  CASE WHEN chi_sq_x <= 1
               THEN 1
               WHEN FLOOR(chi_sq_x)::INTEGER = CEIL(chi_sq_x)::INTEGER
               THEN (FLOOR(chi_sq_x)::INTEGER - 1) + 1
               ELSE FLOOR(chi_sq_x)::INTEGER + 1
          END AS id
         ,CASE WHEN chi_sq_x <= 1
              THEN '(0 1]'
              WHEN FLOOR(chi_sq_x)::INTEGER = CEIL(chi_sq_x)::INTEGER
              THEN '(' || (FLOOR(chi_sq_x)::INTEGER - 1)::TEXT || ' ' ||  (FLOOR(chi_sq_x)::INTEGER)::TEXT || ']'
              ELSE '(' || (FLOOR(chi_sq_x)::INTEGER)::TEXT || ' ' || (CEIL(chi_sq_x)::INTEGER)::TEXT || ']'
          END AS bin
        , chi_sq_x
        , cnt
    FROM chi_squared_cnt
),
histogram AS (
  SELECT   id
         , bin
         , SUM(cnt) AS freq
    FROM binning
   GROUP BY id, bin
)
SELECT   id
       , bin
       , freq
       , ROUND((freq/10.0)::NUMERIC,0)::INTEGER
       , LPAD('*',ROUND((freq/10.0)::NUMERIC,0)::INTEGER ,'*') AS freq_plot
  FROM histogram
  ORDER BY id;
```

```console
id |   bin   | freq | round |                               freq_plot
---+---------+------+-------+-------------------------------------------------------------------------
 1 | (0 1]   |  702 |    70 | **********************************************************************
 2 | (1 2]   |  144 |    14 | **************
 3 | (2 3]   |   73 |     7 | *******
 4 | (3 4]   |   37 |     4 | ****
 5 | (4 5]   |   17 |     2 | **
 6 | (5 6]   |   11 |     1 | *
 7 | (6 7]   |   10 |     1 | *
 8 | (7 8]   |    3 |     0 |
10 | (9 10]  |    2 |     0 |
11 | (10 11] |    1 |     0 |
(10 rows)
```

## Problem 2: Simulating random chi-square variables 2 DOF

Let's study the case of `v=2`.

- X<sup>2</sup> = X<sup>2</sup><sub>1</sub> + X<sup>2</sup><sub>2</sub>

Randomly select two observations from a standard normal distribution with a mean zero and standard deviation  of 1. Next, square each value and sum them all up. The result is an observation from a `chi-square` distribution with `2` degree of freedom.

```SQL
WITH samples AS (
  SELECT FLOOR(RANDOM()*1000000)::INTEGER + 1 AS rw_nm
  UNION ALL
  SELECT FLOOR(RANDOM()*1000000)::INTEGER + 1 AS rw_nm
),
sampling AS (
  SELECT  z
        , ROUND(POWER(z,2),2) AS chi_sq_x
   FROM normal_z_1M_obs
  WHERE ob_id IN (SELECT rw_nm FROM samples)
)
SELECT  z
      , chi_sq_x
      , SUM(chi_sq_x) OVER () AS chi_sq_x_dof2
 FROM sampling;
```

```console
z    | chi_sq_x | chi_sq_x_dof2
-----+----------+---------------
0.80 |     0.64 |          1.85
1.10 |     1.21 |          1.85
```

- Now let's repeat this 1000 times and make a histogram:

First, generate `2000` random values in the range `[1 1,000,000]`.

```SQL
WITH samples AS (
  SELECT  t.id AS id
        , t.rw_nm * FLOOR(RANDOM()*1000000)::INTEGER + 1 AS rw_nm
  FROM (SELECT *
          FROM GENERATE_SERIES(1,2000) AS id, (SELECT 1 AS rw_nm) x ) t
)
SELECT *
  FROM samples
 ORDER BY id;
```

Next, randomly select `with replacement` 2000 observations from a standard normal distribution and squared the result.

```SQL
WITH samples AS (
  SELECT  t.id AS id
        , t.rw_nm * FLOOR(RANDOM()*1000000)::INTEGER + 1 AS rw_nm
  FROM (SELECT *
          FROM GENERATE_SERIES(1,2000) AS id, (SELECT 1 AS rw_nm) x ) t
)
SELECT  s.id
      , z
      , ROUND(POWER(z,2)::NUMERIC,2) AS chi_sq_x
 FROM normal_z_1M_obs nz
INNER JOIN samples s
   ON nz.ob_id = s.rw_nm
ORDER BY id;
```

```console
id  |   z   | chi_sq_x
----+-------+----------
  1 | -0.10 |     0.01
  2 |  0.10 |     0.01
  3 |  0.40 |     0.16
  4 | -0.20 |     0.04
  5 | -0.40 |     0.16
  6 |  0.80 |     0.64
  7 |  0.00 |     0.00
  8 |  1.10 |     1.21
  9 |  0.40 |     0.16
 10 | -0.20 |     0.04
 11 | -0.10 |     0.01
 12 | -1.90 |     3.61
 13 |  1.60 |     2.56
 14 |  0.90 |     0.81
 15 | -2.10 |     4.41
 16 | -0.70 |     0.49
 17 | -0.20 |     0.04
 18 | -0.40 |     0.16
 19 |  0.00 |     0.00
 20 |  0.80 |     0.64
 21 | -0.60 |     0.36
 22 |  1.40 |     1.96
```

Next, partition the table rows in 1000 groups of two samples.

```SQL
WITH samples AS (
  SELECT  t.id AS id
        , t.rw_nm * FLOOR(RANDOM()*1000000)::INTEGER + 1 AS rw_nm
  FROM (SELECT *
          FROM GENERATE_SERIES(1,2000) AS id, (SELECT 1 AS rw_nm) x ) t
),
normal_sampling AS (
  SELECT  s.id AS id
        , z
        , ROUND(POWER(z,2)::NUMERIC,2) AS chi_sq_x
   FROM normal_z_1M_obs nz
  INNER JOIN samples s
     ON nz.ob_id = s.rw_nm
)
SELECT  NTILE (1000) OVER (ORDER BY id) AS grp
      , id
      , z
      , chi_sq_x
 FROM normal_sampling
ORDER BY id;
```

```console
grp  |  id  |   z   | chi_sq_x
-----+------+-------+----------
   1 |    1 |  0.10 |     0.01
   1 |    2 |  0.10 |     0.01
   2 |    3 | -1.60 |     2.56
   2 |    4 |  0.10 |     0.01
   3 |    5 | -1.90 |     3.61
   3 |    6 |  0.60 |     0.36
   4 |    7 |  1.60 |     2.56
   4 |    8 | -0.30 |     0.09
   5 |    9 |  0.00 |     0.00
   5 |   10 |  3.60 |    12.96
   6 |   11 | -0.80 |     0.64
   6 |   12 | -0.50 |     0.25
   7 |   13 | -1.30 |     1.69
   7 |   14 | -0.60 |     0.36
   8 |   15 | -0.10 |     0.01
   8 |   16 | -0.90 |     0.81
   9 |   17 |  0.10 |     0.01
   9 |   18 | -0.50 |     0.25
  10 |   19 | -1.30 |     1.69
  10 |   20 | -0.70 |     0.49
  11 |   21 |  0.20 |     0.04
  11 |   22 | -1.20 |     1.44
  12 |   23 | -0.60 |     0.36
  12 |   24 |  1.20 |     1.44
```

Next, sum the last column values for each group `grp`.

```SQL
WITH samples AS (
  SELECT  t.id AS id
        , t.rw_nm * FLOOR(RANDOM()*1000000)::INTEGER + 1 AS rw_nm
  FROM (SELECT *
          FROM GENERATE_SERIES(1,2000) AS id, (SELECT 1 AS rw_nm) x ) t
),
normal_sampling AS (
  SELECT  s.id AS id
        , z
        , ROUND(POWER(z,2)::NUMERIC,2) AS chi_sq_x
   FROM normal_z_1M_obs nz
  INNER JOIN samples s
     ON nz.ob_id = s.rw_nm
),
grouping_samples AS (
  SELECT  NTILE (1000) OVER (ORDER BY id) AS grp
        , chi_sq_x
   FROM normal_sampling
)
SELECT  grp AS id
      , SUM(chi_sq_x) AS chi_sq_x_dof2
 FROM grouping_samples
GROUP BY grp
ORDER BY chi_sq_x_dof2;
```

```console
id  | chi_sq_x_dof2
----+---------------
320 |          0.00
772 |          0.00
495 |          0.01
326 |          0.01
141 |          0.01
116 |          0.01
163 |          0.01
797 |          0.02
643 |          0.02
743 |          0.02
994 |          0.02
379 |          0.02
 14 |          0.02
641 |          0.02
748 |          0.02
219 |          0.04
133 |          0.04
691 |          0.04
 25 |          0.04
120 |          0.04
758 |          0.04
391 |          0.04
374 |          0.04
984 |          0.04
640 |          0.05
104 |          0.05
302 |          0.05
394 |          0.05
444 |          0.05
541 |          0.05
770 |          0.05
  7 |          0.05
904 |          0.05
```

Now, we have a table with `1000` chi-square random variables with two dof.

Let's create a table with the random variables.

```SQL
CREATE TABLE chi_squared_dof2 AS (
WITH samples AS (
  SELECT  t.id AS id
        , t.rw_nm * FLOOR(RANDOM()*1000000)::INTEGER + 1 AS rw_nm
  FROM (SELECT *
          FROM GENERATE_SERIES(1,2000) AS id, (SELECT 1 AS rw_nm) x ) t
),
normal_sampling AS (
  SELECT  s.id AS id
        , z
        , ROUND(POWER(z,2)::NUMERIC,2) AS chi_sq_x
   FROM normal_z_1M_obs nz
  INNER JOIN samples s
     ON nz.ob_id = s.rw_nm
),
grouping_samples AS (
  SELECT  NTILE (1000) OVER (ORDER BY id) AS grp
        , chi_sq_x
   FROM normal_sampling
),
chi_sq_samples AS (
  SELECT  grp AS id
        , SUM(chi_sq_x) AS chi_sq_x_dof2
   FROM grouping_samples
  GROUP BY grp
)
SELECT chi_sq_x_dof2
  FROM chi_sq_samples
);

WITH diff AS (
  SELECT chi_sq_x_dof2 AS x
       , COUNT(chi_sq_x_dof2) OVER() AS n
       , AVG(chi_sq_x_dof2) OVER() AS mean
       , STDDEV_POP(chi_sq_x_dof2) OVER() AS std_p
       , STDDEV(chi_sq_x_dof2) OVER() AS std
    FROM chi_squared_dof2
),
comp_sk_krt AS (
  SELECT n
       , PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY x) AS median
       , mean
       , std
       , SUM(POWER(x - mean,3))/(COUNT(x))  AS num_sk
       , POWER(std_p,3) AS den_sk
       , SUM(POWER(x - mean,4))/(COUNT(x))  AS num_krt
       , POWER(std_p,4) AS den_krt
    FROM diff
   GROUP BY n, mean, std, std_p
),
pop_sk_krt AS (
  SELECT  n
        , median
        , mean
        , std
        , num_sk/den_sk AS skw
        , num_krt/den_krt - 3 AS execess_krt
    FROM comp_sk_krt
)
SELECT  n
      , ROUND(median::NUMERIC,2) AS median
      , ROUND(mean,2) AS mean
      , ROUND(std,2) AS sample_std
      , ROUND((SQRT(n*(n-1.0))/(n-2.0))*skw,2) AS sample_skeweness
      , ROUND((n - 1)*((n + 1)*execess_krt + 6)/((n-2)*(n-3)),2) AS ex_kurt
  FROM pop_sk_krt;
```

```console
n    | median | mean | sample_std | sample_skeweness | ex_kurt
-----+--------+------+------------+------------------+---------
1000 |   1.46 | 2.04 |       2.04 |             2.01 |    5.92
```

Let's count the values' frequency.

```SQL
WITH chi_squared_cnt AS (
  SELECT chi_sq_x_dof2 AS chi_sq_x
       , COUNT(chi_sq_x_dof2) AS cnt
    FROM chi_squared_dof2
   GROUP BY 1
)
SELECT  CASE WHEN chi_sq_x <= 1
             THEN 1
             WHEN FLOOR(chi_sq_x)::INTEGER = CEIL(chi_sq_x)::INTEGER
             THEN (FLOOR(chi_sq_x)::INTEGER - 1) + 1
             ELSE FLOOR(chi_sq_x)::INTEGER + 1
        END AS id
       ,CASE WHEN chi_sq_x <= 1
            THEN '(0 1]'
            WHEN FLOOR(chi_sq_x)::INTEGER = CEIL(chi_sq_x)::INTEGER
            THEN '(' || (FLOOR(chi_sq_x)::INTEGER - 1)::TEXT || ' ' ||  (FLOOR(chi_sq_x)::INTEGER)::TEXT || ']'
            ELSE '(' || (FLOOR(chi_sq_x)::INTEGER)::TEXT || ' ' || (CEIL(chi_sq_x)::INTEGER)::TEXT || ']'
        END AS bin
      , chi_sq_x
      , cnt
  FROM chi_squared_cnt
 ORDER BY chi_sq_x;
```

```console
id |   bin   | chi_sq_x | cnt
---+---------+----------+-----
 1 | (0 1]   |     0.00 |   2
 1 | (0 1]   |     0.01 |   4
 1 | (0 1]   |     0.02 |   8
 1 | (0 1]   |     0.04 |   4
 1 | (0 1]   |     0.05 |   7
 1 | (0 1]   |     0.08 |   3
 1 | (0 1]   |     0.09 |   9
 1 | (0 1]   |     0.10 |  11
 1 | (0 1]   |     0.13 |  13
 1 | (0 1]   |     0.16 |   7
 1 | (0 1]   |     0.17 |  11
 1 | (0 1]   |     0.18 |   7
 1 | (0 1]   |     0.20 |  10
 1 | (0 1]   |     0.25 |  15
 1 | (0 1]   |     0.26 |  13
 1 | (0 1]   |     0.29 |  13
 1 | (0 1]   |     0.32 |   4
 1 | (0 1]   |     0.34 |  12
 1 | (0 1]   |     0.36 |  11
 1 | (0 1]   |     0.37 |  10
 1 | (0 1]   |     0.40 |   7
 1 | (0 1]   |     0.41 |   9
 1 | (0 1]   |     0.45 |   8
 1 | (0 1]   |     0.49 |   6
 1 | (0 1]   |     0.50 |  16
 1 | (0 1]   |     0.52 |   5
 1 | (0 1]   |     0.53 |  12
 1 | (0 1]   |     0.58 |  13
 1 | (0 1]   |     0.61 |  11
 1 | (0 1]   |     0.64 |   8
 1 | (0 1]   |     0.65 |  18
 1 | (0 1]   |     0.68 |  10
 1 | (0 1]   |     0.72 |   9
 1 | (0 1]   |     0.73 |   6
 1 | (0 1]   |     0.74 |   7
 1 | (0 1]   |     0.80 |   4
 1 | (0 1]   |     0.81 |   6
 1 | (0 1]   |     0.82 |   7
 1 | (0 1]   |     0.85 |  13
 1 | (0 1]   |     0.89 |   8
 1 | (0 1]   |     0.90 |   4
 1 | (0 1]   |     0.97 |  12
 1 | (0 1]   |     0.98 |   3
 1 | (0 1]   |     1.00 |   8
 2 | (1 2]   |     1.01 |   8
 2 | (1 2]   |     1.04 |   6
 2 | (1 2]   |     1.06 |   4
 2 | (1 2]   |     1.09 |   8
 2 | (1 2]   |     1.13 |   8
```

Let's plot the histogram:


```SQL
WITH chi_squared_cnt AS (
  SELECT chi_sq_x_dof2 AS chi_sq_x
       , COUNT(chi_sq_x_dof2) AS cnt
    FROM chi_squared_dof2
   GROUP BY 1
),
binning AS (
  SELECT  CASE WHEN chi_sq_x <= 1
               THEN 1
               WHEN FLOOR(chi_sq_x)::INTEGER = CEIL(chi_sq_x)::INTEGER
               THEN (FLOOR(chi_sq_x)::INTEGER - 1) + 1
               ELSE FLOOR(chi_sq_x)::INTEGER + 1
          END AS id
         ,CASE WHEN chi_sq_x <= 1
              THEN '(0 1]'
              WHEN FLOOR(chi_sq_x)::INTEGER = CEIL(chi_sq_x)::INTEGER
              THEN '(' || (FLOOR(chi_sq_x)::INTEGER - 1)::TEXT || ' ' ||  (FLOOR(chi_sq_x)::INTEGER)::TEXT || ']'
              ELSE '(' || (FLOOR(chi_sq_x)::INTEGER)::TEXT || ' ' || (CEIL(chi_sq_x)::INTEGER)::TEXT || ']'
          END AS bin
        , chi_sq_x
        , cnt
    FROM chi_squared_cnt
),
histogram AS (
  SELECT   id
         , bin
         , SUM(cnt) AS freq
    FROM binning
   GROUP BY id, bin
)
SELECT   id
       , bin
       , freq
       , ROUND((freq/10.0)::NUMERIC,0)::INTEGER
       , LPAD('*',ROUND((freq/10.0)::NUMERIC,0)::INTEGER ,'*') AS freq_plot
  FROM histogram
  ORDER BY id;
```

```console
id |   bin   | freq | round |               freq_plot
---+---------+------+-------+----------------------------------------
 1 | (0 1]   |  384 |    38 | **************************************
 2 | (1 2]   |  250 |    25 | *************************
 3 | (2 3]   |  145 |    15 | ***************
 4 | (3 4]   |   77 |     8 | ********
 5 | (4 5]   |   53 |     5 | *****
 6 | (5 6]   |   39 |     4 | ****
 7 | (6 7]   |   22 |     2 | **
 8 | (7 8]   |   10 |     1 | *
 9 | (8 9]   |    5 |     1 | *
10 | (9 10]  |    9 |     1 | *
11 | (10 11] |    2 |     0 |
12 | (11 12] |    2 |     0 |
13 | (12 13] |    1 |     0 |
17 | (16 17] |    1 |     0 |
```

## Problem 3: Simulating random chi-square variables 3 DOF

Let's study the case of `v=3`.

- X<sup>2</sup> = X<sup>2</sup><sub>1</sub> + X<sup>2</sup><sub>2</sub> + X<sup>2</sup><sub>3</sub>

Randomly select three observations from a standard normal distribution with a mean zero and standard deviation  of 1. Next, square each value and sum them all up. The result is an observation from a `chi-square` distribution with `3` degree of freedom.

```SQL
WITH samples AS (
  SELECT FLOOR(RANDOM()*1000000)::INTEGER + 1 AS rw_nm
  UNION ALL
  SELECT FLOOR(RANDOM()*1000000)::INTEGER + 1 AS rw_nm
  UNION ALL
  SELECT FLOOR(RANDOM()*1000000)::INTEGER + 1 AS rw_nm
),
sampling AS (
  SELECT  z
        , ROUND(POWER(z,2),2) AS chi_sq_x
   FROM normal_z_1M_obs
  WHERE ob_id IN (SELECT rw_nm FROM samples)
)
SELECT  z
      , chi_sq_x
      , SUM(chi_sq_x) OVER () AS chi_sq_x_dof3
 FROM sampling;
```

```console
z    | chi_sq_x | chi_sq_x_dof3
-----+----------+---------------
0.60 |     0.36 |          1.81
0.80 |     0.64 |          1.81
0.90 |     0.81 |          1.81
```

- Now let's repeat this 1000 times and make a histogram:

First, generate `3000` random values in the range `[1 1,000,000]`.

```SQL
WITH samples AS (
  SELECT  t.id AS id
        , t.rw_nm * FLOOR(RANDOM()*1000000)::INTEGER + 1 AS rw_nm
  FROM (SELECT *
          FROM GENERATE_SERIES(1,3000) AS id, (SELECT 1 AS rw_nm) x ) t
)
SELECT *
  FROM samples
 ORDER BY id;
```

Next, randomly select `with replacement` 3000 observations from a standard normal distribution and squared the result.

```SQL
WITH samples AS (
  SELECT  t.id AS id
        , t.rw_nm * FLOOR(RANDOM()*1000000)::INTEGER + 1 AS rw_nm
  FROM (SELECT *
          FROM GENERATE_SERIES(1,3000) AS id, (SELECT 1 AS rw_nm) x ) t
)
SELECT  s.id
      , z
      , ROUND(POWER(z,2)::NUMERIC,2) AS chi_sq_x
 FROM normal_z_1M_obs nz
INNER JOIN samples s
   ON nz.ob_id = s.rw_nm
ORDER BY id;
```

```console
id  |   z   | chi_sq_x
----+-------+----------
  1 | -1.20 |     1.44
  2 | -0.20 |     0.04
  3 |  1.40 |     1.96
  4 | -2.20 |     4.84
  5 | -0.90 |     0.81
  6 | -1.80 |     3.24
  7 | -1.50 |     2.25
  8 |  2.10 |     4.41
  9 |  0.90 |     0.81
 10 |  1.10 |     1.21
 11 |  0.30 |     0.09
 12 | -1.30 |     1.69
 13 |  0.20 |     0.04
 14 |  1.30 |     1.69
 15 |  0.00 |     0.00
```

Next, partition the table rows in 1000 groups of three samples each.

```SQL
WITH samples AS (
  SELECT  t.id AS id
        , t.rw_nm * FLOOR(RANDOM()*1000000)::INTEGER + 1 AS rw_nm
  FROM (SELECT *
          FROM GENERATE_SERIES(1,3000) AS id, (SELECT 1 AS rw_nm) x ) t
),
normal_sampling AS (
  SELECT  s.id AS id
        , z
        , ROUND(POWER(z,2)::NUMERIC,2) AS chi_sq_x
   FROM normal_z_1M_obs nz
  INNER JOIN samples s
     ON nz.ob_id = s.rw_nm
)
SELECT  NTILE (1000) OVER (ORDER BY id) AS grp
      , id
      , z
      , chi_sq_x
 FROM normal_sampling
ORDER BY id;
```

```console
grp  |  id  |   z   | chi_sq_x
-----+------+-------+----------
   1 |    1 | -1.80 |     3.24
   1 |    2 |  2.10 |     4.41
   1 |    3 |  1.30 |     1.69
   2 |    4 |  1.00 |     1.00
   2 |    5 |  0.10 |     0.01
   2 |    6 | -0.30 |     0.09
   3 |    7 |  1.30 |     1.69
   3 |    8 |  0.40 |     0.16
   3 |    9 | -0.40 |     0.16
   4 |   10 |  1.10 |     1.21
   4 |   11 |  0.50 |     0.25
   4 |   12 | -0.30 |     0.09
   5 |   13 | -0.20 |     0.04
   5 |   14 |  1.50 |     2.25
   5 |   15 |  0.20 |     0.04
   6 |   16 |  1.50 |     2.25
   6 |   17 |  0.70 |     0.49
   6 |   18 |  0.50 |     0.25
   7 |   19 | -0.70 |     0.49
   7 |   20 | -1.70 |     2.89
   7 |   21 | -0.20 |     0.04
   8 |   22 | -0.30 |     0.09
```

Next, sum the last column values for each group `grp`.

```SQL
WITH samples AS (
  SELECT  t.id AS id
        , t.rw_nm * FLOOR(RANDOM()*1000000)::INTEGER + 1 AS rw_nm
  FROM (SELECT *
          FROM GENERATE_SERIES(1,3000) AS id, (SELECT 1 AS rw_nm) x ) t
),
normal_sampling AS (
  SELECT  s.id AS id
        , z
        , ROUND(POWER(z,2)::NUMERIC,2) AS chi_sq_x
   FROM normal_z_1M_obs nz
  INNER JOIN samples s
     ON nz.ob_id = s.rw_nm
),
grouping_samples AS (
  SELECT  NTILE (1000) OVER (ORDER BY id) AS grp
        , chi_sq_x
   FROM normal_sampling
)
SELECT  grp AS id
      , SUM(chi_sq_x) AS chi_sq_x_dof3
 FROM grouping_samples
GROUP BY grp
ORDER BY chi_sq_x_dof3;
```

```console
id  | chi_sq_x_dof3
----+---------------
324 |          0.02
758 |          0.02
166 |          0.05
474 |          0.05
 39 |          0.05
815 |          0.05
742 |          0.05
  3 |          0.05
218 |          0.06
475 |          0.06
523 |          0.08
302 |          0.08
278 |          0.09
469 |          0.10
718 |          0.11
470 |          0.13
839 |          0.13
 84 |          0.13
399 |          0.14
972 |          0.14
 96 |          0.16
225 |          0.17
```

Now, we have a table with `1000` chi-square random variables with three dof.

Let's create a table with the random variables.

```SQL
CREATE TABLE chi_squared_dof3 AS (
WITH samples AS (
  SELECT  t.id AS id
        , t.rw_nm * FLOOR(RANDOM()*1000000)::INTEGER + 1 AS rw_nm
  FROM (SELECT *
          FROM GENERATE_SERIES(1,3000) AS id, (SELECT 1 AS rw_nm) x ) t
),
normal_sampling AS (
  SELECT  s.id AS id
        , z
        , ROUND(POWER(z,2)::NUMERIC,2) AS chi_sq_x
   FROM normal_z_1M_obs nz
  INNER JOIN samples s
     ON nz.ob_id = s.rw_nm
),
grouping_samples AS (
  SELECT  NTILE (1000) OVER (ORDER BY id) AS grp
        , chi_sq_x
   FROM normal_sampling
),
chi_sq_samples AS (
  SELECT  grp AS id
        , SUM(chi_sq_x) AS chi_sq_x_dof3
   FROM grouping_samples
  GROUP BY grp
)
SELECT chi_sq_x_dof3
  FROM chi_sq_samples
);

WITH diff AS (
  SELECT chi_sq_x_dof3 AS x
       , COUNT(chi_sq_x_dof3) OVER() AS n
       , AVG(chi_sq_x_dof3) OVER() AS mean
       , STDDEV_POP(chi_sq_x_dof3) OVER() AS std_p
       , STDDEV(chi_sq_x_dof3) OVER() AS std
    FROM chi_squared_dof3
),
comp_sk_krt AS (
  SELECT n
       , PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY x) AS median
       , mean
       , std
       , SUM(POWER(x - mean,3))/(COUNT(x))  AS num_sk
       , POWER(std_p,3) AS den_sk
       , SUM(POWER(x - mean,4))/(COUNT(x))  AS num_krt
       , POWER(std_p,4) AS den_krt
    FROM diff
   GROUP BY n, mean, std, std_p
),
pop_sk_krt AS (
  SELECT  n
        , median
        , mean
        , std
        , num_sk/den_sk AS skw
        , num_krt/den_krt - 3 AS execess_krt
    FROM comp_sk_krt
)
SELECT  n
      , ROUND(median::NUMERIC,2) AS median
      , ROUND(mean,2) AS mean
      , ROUND(std,2) AS sample_std
      , ROUND((SQRT(n*(n-1.0))/(n-2.0))*skw,2) AS sample_skeweness
      , ROUND((n - 1)*((n + 1)*execess_krt + 6)/((n-2)*(n-3)),2) AS ex_kurt
  FROM pop_sk_krt;
```

```console
n    | median | mean | sample_std | sample_skeweness | ex_kurt
-----+--------+------+------------+------------------+---------
1000 |   2.28 | 2.91 |       2.46 |             1.68 |    3.95
```

Let's count the values' frequency.

```SQL
WITH chi_squared_cnt AS (
  SELECT chi_sq_x_dof3 AS chi_sq_x
       , COUNT(chi_sq_x_dof3) AS cnt
    FROM chi_squared_dof3
   GROUP BY 1
)
SELECT  CASE WHEN chi_sq_x <= 1
             THEN 1
             WHEN FLOOR(chi_sq_x)::INTEGER = CEIL(chi_sq_x)::INTEGER
             THEN (FLOOR(chi_sq_x)::INTEGER - 1) + 1
             ELSE FLOOR(chi_sq_x)::INTEGER + 1
        END AS id
       ,CASE WHEN chi_sq_x <= 1
            THEN '(0 1]'
            WHEN FLOOR(chi_sq_x)::INTEGER = CEIL(chi_sq_x)::INTEGER
            THEN '(' || (FLOOR(chi_sq_x)::INTEGER - 1)::TEXT || ' ' ||  (FLOOR(chi_sq_x)::INTEGER)::TEXT || ']'
            ELSE '(' || (FLOOR(chi_sq_x)::INTEGER)::TEXT || ' ' || (CEIL(chi_sq_x)::INTEGER)::TEXT || ']'
        END AS bin
      , chi_sq_x
      , cnt
  FROM chi_squared_cnt
 ORDER BY chi_sq_x;
```

```console
id |   bin   | chi_sq_x | cnt
---+---------+----------+-----
 1 | (0 1]   |     0.02 |   1
 1 | (0 1]   |     0.03 |   1
 1 | (0 1]   |     0.05 |   2
 1 | (0 1]   |     0.06 |   3
 1 | (0 1]   |     0.08 |   1
 1 | (0 1]   |     0.09 |   2
 1 | (0 1]   |     0.10 |   2
 1 | (0 1]   |     0.11 |   1
 1 | (0 1]   |     0.13 |   1
 1 | (0 1]   |     0.14 |   4
 1 | (0 1]   |     0.17 |   5
 1 | (0 1]   |     0.18 |   2
 1 | (0 1]   |     0.19 |   5
 1 | (0 1]   |     0.20 |   1
 1 | (0 1]   |     0.24 |   1
 1 | (0 1]   |     0.25 |   2
 1 | (0 1]   |     0.26 |   6
 1 | (0 1]   |     0.29 |   8
 1 | (0 1]   |     0.30 |   2
 1 | (0 1]   |     0.32 |   1
 1 | (0 1]   |     0.33 |   2
 1 | (0 1]   |     0.34 |   4
 1 | (0 1]   |     0.35 |   3
 1 | (0 1]   |     0.36 |   3
 1 | (0 1]   |     0.37 |   1
 1 | (0 1]   |     0.38 |   5
 1 | (0 1]   |     0.40 |   1
 1 | (0 1]   |     0.41 |   7
 1 | (0 1]   |     0.42 |   1
 1 | (0 1]   |     0.44 |   1
 1 | (0 1]   |     0.45 |   4
 1 | (0 1]   |     0.46 |   5
 1 | (0 1]   |     0.49 |   1
 1 | (0 1]   |     0.50 |   5
 1 | (0 1]   |     0.51 |   2
 1 | (0 1]   |     0.52 |   2
 1 | (0 1]   |     0.53 |   2
 1 | (0 1]   |     0.54 |   5
 1 | (0 1]   |     0.56 |   4
 1 | (0 1]   |     0.57 |   3
 1 | (0 1]   |     0.58 |   2
 1 | (0 1]   |     0.59 |   3
 1 | (0 1]   |     0.61 |   6
 1 | (0 1]   |     0.62 |   5
 1 | (0 1]   |     0.65 |   6
 1 | (0 1]   |     0.66 |   5
 1 | (0 1]   |     0.68 |   3
 1 | (0 1]   |     0.69 |   2
 1 | (0 1]   |     0.70 |   4
 1 | (0 1]   |     0.72 |   1
 1 | (0 1]   |     0.73 |   4
 1 | (0 1]   |     0.74 |   6
 1 | (0 1]   |     0.75 |   1
 1 | (0 1]   |     0.76 |   2
 1 | (0 1]   |     0.77 |   1
 1 | (0 1]   |     0.78 |   3
 1 | (0 1]   |     0.80 |   1
 1 | (0 1]   |     0.81 |   8
 1 | (0 1]   |     0.82 |   1
 1 | (0 1]   |     0.83 |   6
 1 | (0 1]   |     0.84 |   2
 1 | (0 1]   |     0.85 |   2
 1 | (0 1]   |     0.86 |   2
 1 | (0 1]   |     0.88 |   1
 1 | (0 1]   |     0.89 |  10
 1 | (0 1]   |     0.90 |   2
 1 | (0 1]   |     0.91 |   1
 1 | (0 1]   |     0.93 |   2
 1 | (0 1]   |     0.94 |   4
 1 | (0 1]   |     0.96 |   2
 1 | (0 1]   |     0.98 |   2
 1 | (0 1]   |     0.99 |   3
 1 | (0 1]   |     1.00 |   1
 2 | (1 2]   |     1.01 |   6
 2 | (1 2]   |     1.02 |   3
 2 | (1 2]   |     1.04 |   4
 2 | (1 2]   |     1.05 |   2
```

Let's plot the histogram:


```SQL
WITH chi_squared_cnt AS (
  SELECT chi_sq_x_dof3 AS chi_sq_x
       , COUNT(chi_sq_x_dof3) AS cnt
    FROM chi_squared_dof3
   GROUP BY 1
),
binning AS (
  SELECT  CASE WHEN chi_sq_x <= 1
               THEN 1
               WHEN FLOOR(chi_sq_x)::INTEGER = CEIL(chi_sq_x)::INTEGER
               THEN (FLOOR(chi_sq_x)::INTEGER - 1) + 1
               ELSE FLOOR(chi_sq_x)::INTEGER + 1
          END AS id
         ,CASE WHEN chi_sq_x <= 1
              THEN '(0 1]'
              WHEN FLOOR(chi_sq_x)::INTEGER = CEIL(chi_sq_x)::INTEGER
              THEN '(' || (FLOOR(chi_sq_x)::INTEGER - 1)::TEXT || ' ' ||  (FLOOR(chi_sq_x)::INTEGER)::TEXT || ']'
              ELSE '(' || (FLOOR(chi_sq_x)::INTEGER)::TEXT || ' ' || (CEIL(chi_sq_x)::INTEGER)::TEXT || ']'
          END AS bin
        , chi_sq_x
        , cnt
    FROM chi_squared_cnt
),
histogram AS (
  SELECT   id
         , bin
         , SUM(cnt) AS freq
    FROM binning
   GROUP BY id, bin
)
SELECT   id
       , bin
       , freq
       , ROUND((freq/10.0)::NUMERIC,0)::INTEGER
       , LPAD('*',ROUND((freq/10.0)::NUMERIC,0)::INTEGER ,'*') AS freq_plot
  FROM histogram
  ORDER BY id;
```

```console
id |   bin   | freq | round |        freq_plot
---+---------+------+-------+--------------------------
 1 | (0 1]   |  216 |    22 | **********************
 2 | (1 2]   |  237 |    24 | ************************
 3 | (2 3]   |  172 |    17 | *****************
 4 | (3 4]   |  130 |    13 | *************
 5 | (4 5]   |   75 |     8 | ********
 6 | (5 6]   |   62 |     6 | ******
 7 | (6 7]   |   42 |     4 | ****
 8 | (7 8]   |   25 |     3 | ***
 9 | (8 9]   |    8 |     1 | *
10 | (9 10]  |   12 |     1 | *
11 | (10 11] |    7 |     1 | *
12 | (11 12] |    6 |     1 | *
13 | (12 13] |    2 |     0 |
14 | (13 14] |    3 |     0 |
16 | (15 16] |    2 |     0 |
18 | (17 18] |    1 |     0 |
(16 rows)
```

## Problem 4: Simulating random chi-square variables 4 DOF

Let's study the case of `v=4`.

- X<sup>2</sup> = X<sup>2</sup><sub>1</sub> + X<sup>2</sup><sub>2</sub> + X<sup>2</sup><sub>3</sub> + X<sup>2</sup><sub>4</sub>

Randomly select four observations from a standard normal distribution with a mean zero and standard deviation  of 1. Next, square each value and sum them all up. The result is an observation from a `chi-square` distribution with `4` degree of freedom.

```SQL
WITH samples AS (
  SELECT FLOOR(RANDOM()*1000000)::INTEGER + 1 AS rw_nm
  UNION ALL
  SELECT FLOOR(RANDOM()*1000000)::INTEGER + 1 AS rw_nm
  UNION ALL
  SELECT FLOOR(RANDOM()*1000000)::INTEGER + 1 AS rw_nm
  UNION ALL
  SELECT FLOOR(RANDOM()*1000000)::INTEGER + 1 AS rw_nm
),
sampling AS (
  SELECT  z
        , ROUND(POWER(z,2),2) AS chi_sq_x
   FROM normal_z_1M_obs
  WHERE ob_id IN (SELECT rw_nm FROM samples)
)
SELECT  z
      , chi_sq_x
      , SUM(chi_sq_x) OVER () AS chi_sq_x_dof4
 FROM sampling;
```

```console
z     | chi_sq_x | chi_sq_x_dof4
------+----------+---------------
-2.30 |     5.29 |          7.03
0.10  |     0.01 |          7.03
0.20  |     0.04 |          7.03
1.30  |     1.69 |          7.03
```

- Now let's repeat this 1000 times and make a histogram:

First, generate `4000` random values in the range `[1 1,000,000]`.

```SQL
WITH samples AS (
  SELECT  t.id AS id
        , t.rw_nm * FLOOR(RANDOM()*1000000)::INTEGER + 1 AS rw_nm
  FROM (SELECT *
          FROM GENERATE_SERIES(1,4000) AS id, (SELECT 1 AS rw_nm) x ) t
)
SELECT *
  FROM samples
 ORDER BY id;
```

Next, randomly select `with replacement` 4000 observations from a standard normal distribution and squared the result.

```SQL
WITH samples AS (
  SELECT  t.id AS id
        , t.rw_nm * FLOOR(RANDOM()*1000000)::INTEGER + 1 AS rw_nm
  FROM (SELECT *
          FROM GENERATE_SERIES(1,4000) AS id, (SELECT 1 AS rw_nm) x ) t
)
SELECT  s.id
      , z
      , ROUND(POWER(z,2)::NUMERIC,2) AS chi_sq_x
 FROM normal_z_1M_obs nz
INNER JOIN samples s
   ON nz.ob_id = s.rw_nm
ORDER BY id;
```

```console
id  |   z   | chi_sq_x
----+-------+----------
  1 | -0.50 |     0.25
  2 | -0.20 |     0.04
  3 |  0.80 |     0.64
  4 |  0.50 |     0.25
  5 |  1.10 |     1.21
  6 | -0.70 |     0.49
  7 | -1.40 |     1.96
  8 | -1.30 |     1.69
  9 |  0.30 |     0.09
 10 |  0.50 |     0.25
```

Next, partition the table rows in 1000 groups of four samples each.

```SQL
WITH samples AS (
  SELECT  t.id AS id
        , t.rw_nm * FLOOR(RANDOM()*1000000)::INTEGER + 1 AS rw_nm
  FROM (SELECT *
          FROM GENERATE_SERIES(1,4000) AS id, (SELECT 1 AS rw_nm) x ) t
),
normal_sampling AS (
  SELECT  s.id AS id
        , z
        , ROUND(POWER(z,2)::NUMERIC,2) AS chi_sq_x
   FROM normal_z_1M_obs nz
  INNER JOIN samples s
     ON nz.ob_id = s.rw_nm
)
SELECT  NTILE (1000) OVER (ORDER BY id) AS grp
      , id
      , z
      , chi_sq_x
 FROM normal_sampling
ORDER BY id;
```

```console
grp  |  id  |   z   | chi_sq_x
-----+------+-------+----------
   1 |    1 | -0.60 |     0.36
   1 |    2 | -0.20 |     0.04
   1 |    3 |  0.00 |     0.00
   1 |    4 |  0.50 |     0.25
   2 |    5 |  1.40 |     1.96
   2 |    6 | -0.30 |     0.09
   2 |    7 | -0.20 |     0.04
   2 |    8 | -0.20 |     0.04
   3 |    9 | -0.30 |     0.09
   3 |   10 | -0.50 |     0.25
   3 |   11 |  0.90 |     0.81
   3 |   12 |  1.10 |     1.21
```

Next, sum the last column values for each group `grp`.

```SQL
WITH samples AS (
  SELECT  t.id AS id
        , t.rw_nm * FLOOR(RANDOM()*1000000)::INTEGER + 1 AS rw_nm
  FROM (SELECT *
          FROM GENERATE_SERIES(1,4000) AS id, (SELECT 1 AS rw_nm) x ) t
),
normal_sampling AS (
  SELECT  s.id AS id
        , z
        , ROUND(POWER(z,2)::NUMERIC,2) AS chi_sq_x
   FROM normal_z_1M_obs nz
  INNER JOIN samples s
     ON nz.ob_id = s.rw_nm
),
grouping_samples AS (
  SELECT  NTILE (1000) OVER (ORDER BY id) AS grp
        , chi_sq_x
   FROM normal_sampling
)
SELECT  grp AS id
      , SUM(chi_sq_x) AS chi_sq_x_dof4
 FROM grouping_samples
GROUP BY grp
ORDER BY chi_sq_x_dof4;
```

```console
id  | chi_sq_x_dof4
----+---------------
917 |          0.23
287 |          0.24
900 |          0.29
504 |          0.31
831 |          0.33
170 |          0.34
308 |          0.34
581 |          0.35
983 |          0.37
 32 |          0.41
183 |          0.42
977 |          0.42
542 |          0.43
471 |          0.43
573 |          0.44
389 |          0.45
691 |          0.45
 23 |          0.45
```

Now, we have a table with `1000` chi-square random variables with four dof.

Let's create a table with the random variables.

```SQL
CREATE TABLE chi_squared_dof4 AS (
WITH samples AS (
  SELECT  t.id AS id
        , t.rw_nm * FLOOR(RANDOM()*1000000)::INTEGER + 1 AS rw_nm
  FROM (SELECT *
          FROM GENERATE_SERIES(1,4000) AS id, (SELECT 1 AS rw_nm) x ) t
),
normal_sampling AS (
  SELECT  s.id AS id
        , z
        , ROUND(POWER(z,2)::NUMERIC,2) AS chi_sq_x
   FROM normal_z_1M_obs nz
  INNER JOIN samples s
     ON nz.ob_id = s.rw_nm
),
grouping_samples AS (
  SELECT  NTILE (1000) OVER (ORDER BY id) AS grp
        , chi_sq_x
   FROM normal_sampling
),
chi_sq_samples AS (
  SELECT  grp AS id
        , SUM(chi_sq_x) AS chi_sq_x_dof4
   FROM grouping_samples
  GROUP BY grp
)
SELECT chi_sq_x_dof4
  FROM chi_sq_samples
);

WITH diff AS (
  SELECT chi_sq_x_dof4 AS x
       , COUNT(chi_sq_x_dof4) OVER() AS n
       , AVG(chi_sq_x_dof4) OVER() AS mean
       , STDDEV_POP(chi_sq_x_dof4) OVER() AS std_p
       , STDDEV(chi_sq_x_dof4) OVER() AS std
    FROM chi_squared_dof4
),
comp_sk_krt AS (
  SELECT n
       , PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY x) AS median
       , mean
       , std
       , SUM(POWER(x - mean,3))/(COUNT(x))  AS num_sk
       , POWER(std_p,3) AS den_sk
       , SUM(POWER(x - mean,4))/(COUNT(x))  AS num_krt
       , POWER(std_p,4) AS den_krt
    FROM diff
   GROUP BY n, mean, std, std_p
),
pop_sk_krt AS (
  SELECT  n
        , median
        , mean
        , std
        , num_sk/den_sk AS skw
        , num_krt/den_krt - 3 AS execess_krt
    FROM comp_sk_krt
)
SELECT  n
      , ROUND(median::NUMERIC,2) AS median
      , ROUND(mean,2) AS mean
      , ROUND(std,2) AS sample_std
      , ROUND((SQRT(n*(n-1.0))/(n-2.0))*skw,2) AS sample_skeweness
      , ROUND((n - 1)*((n + 1)*execess_krt + 6)/((n-2)*(n-3)),2) AS ex_kurt
  FROM pop_sk_krt;
```

```console
n    | median | mean | sample_std | sample_skeweness | ex_kurt
-----+--------+------+------------+------------------+---------
1000 |   3.30 | 3.99 |       2.86 |             1.45 |    3.10
```

Let's plot the histogram:


```SQL
WITH chi_squared_cnt AS (
  SELECT chi_sq_x_dof4 AS chi_sq_x
       , COUNT(chi_sq_x_dof4) AS cnt
    FROM chi_squared_dof4
   GROUP BY 1
),
binning AS (
  SELECT  CASE WHEN chi_sq_x <= 1
               THEN 1
               WHEN FLOOR(chi_sq_x)::INTEGER = CEIL(chi_sq_x)::INTEGER
               THEN (FLOOR(chi_sq_x)::INTEGER - 1) + 1
               ELSE FLOOR(chi_sq_x)::INTEGER + 1
          END AS id
         ,CASE WHEN chi_sq_x <= 1
              THEN '(0 1]'
              WHEN FLOOR(chi_sq_x)::INTEGER = CEIL(chi_sq_x)::INTEGER
              THEN '(' || (FLOOR(chi_sq_x)::INTEGER - 1)::TEXT || ' ' ||  (FLOOR(chi_sq_x)::INTEGER)::TEXT || ']'
              ELSE '(' || (FLOOR(chi_sq_x)::INTEGER)::TEXT || ' ' || (CEIL(chi_sq_x)::INTEGER)::TEXT || ']'
          END AS bin
        , chi_sq_x
        , cnt
    FROM chi_squared_cnt
),
histogram AS (
  SELECT   id
         , bin
         , SUM(cnt) AS freq
    FROM binning
   GROUP BY id, bin
)
SELECT   id
       , bin
       , freq
       , ROUND((freq/10.0)::NUMERIC,0)::INTEGER
       , LPAD('*',ROUND((freq/10.0)::NUMERIC,0)::INTEGER ,'*') AS freq_plot
  FROM histogram
  ORDER BY id;
```

```console
id |   bin   | freq | round |     freq_plot
---+---------+------+-------+--------------------
 1 | (0 1]   |   91 |     9 | *********
 2 | (1 2]   |  175 |    18 | ******************
 3 | (2 3]   |  176 |    18 | ******************
 4 | (3 4]   |  169 |    17 | *****************
 5 | (4 5]   |  112 |    11 | ***********
 6 | (5 6]   |   78 |     8 | ********
 7 | (6 7]   |   60 |     6 | ******
 8 | (7 8]   |   39 |     4 | ****
 9 | (8 9]   |   28 |     3 | ***
10 | (9 10]  |   29 |     3 | ***
11 | (10 11] |   16 |     2 | **
12 | (11 12] |   14 |     1 | *
13 | (12 13] |    5 |     1 | *
15 | (14 15] |    2 |     0 |
16 | (15 16] |    4 |     0 |
20 | (19 20] |    1 |     0 |
22 | (21 22] |    1 |     0 |
```

## Problem 5: Simulating random chi-square variables 5 DOF

```SQL
CREATE TABLE chi_squared_dof5 AS (
WITH samples AS (
  SELECT  t.id AS id
        , t.rw_nm * FLOOR(RANDOM()*1000000)::INTEGER + 1 AS rw_nm
  FROM (SELECT *
          FROM GENERATE_SERIES(1,5000) AS id, (SELECT 1 AS rw_nm) x ) t
),
normal_sampling AS (
  SELECT  s.id AS id
        , z
        , ROUND(POWER(z,2)::NUMERIC,2) AS chi_sq_x
   FROM normal_z_1M_obs nz
  INNER JOIN samples s
     ON nz.ob_id = s.rw_nm
),
grouping_samples AS (
  SELECT  NTILE (1000) OVER (ORDER BY id) AS grp
        , chi_sq_x
   FROM normal_sampling
),
chi_sq_samples AS (
  SELECT  grp AS id
        , SUM(chi_sq_x) AS chi_sq_x_dof5
   FROM grouping_samples
  GROUP BY grp
)
SELECT chi_sq_x_dof5
  FROM chi_sq_samples
);

WITH diff AS (
  SELECT chi_sq_x_dof5 AS x
       , COUNT(chi_sq_x_dof5) OVER() AS n
       , AVG(chi_sq_x_dof5) OVER() AS mean
       , STDDEV_POP(chi_sq_x_dof5) OVER() AS std_p
       , STDDEV(chi_sq_x_dof5) OVER() AS std
    FROM chi_squared_dof5
),
comp_sk_krt AS (
  SELECT n
       , PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY x) AS median
       , mean
       , std
       , SUM(POWER(x - mean,3))/(COUNT(x))  AS num_sk
       , POWER(std_p,3) AS den_sk
       , SUM(POWER(x - mean,4))/(COUNT(x))  AS num_krt
       , POWER(std_p,4) AS den_krt
    FROM diff
   GROUP BY n, mean, std, std_p
),
pop_sk_krt AS (
  SELECT  n
        , median
        , mean
        , std
        , num_sk/den_sk AS skw
        , num_krt/den_krt - 3 AS execess_krt
    FROM comp_sk_krt
)
SELECT  n
      , ROUND(median::NUMERIC,2) AS median
      , ROUND(mean,2) AS mean
      , ROUND(std,2) AS sample_std
      , ROUND((SQRT(n*(n-1.0))/(n-2.0))*skw,2) AS sample_skeweness
      , ROUND((n - 1)*((n + 1)*execess_krt + 6)/((n-2)*(n-3)),2) AS ex_kurt
  FROM pop_sk_krt;
```

```console
n    | median | mean | sample_std | sample_skeweness | ex_kurt
-----+--------+------+------------+------------------+---------
1000 |   4.34 | 5.01 |       3.20 |             1.13 |    1.34
```

Let's plot the histogram:


```SQL
WITH chi_squared_cnt AS (
  SELECT chi_sq_x_dof5 AS chi_sq_x
       , COUNT(chi_sq_x_dof5) AS cnt
    FROM chi_squared_dof5
   GROUP BY 1
),
binning AS (
  SELECT  CASE WHEN chi_sq_x <= 1
               THEN 1
               WHEN FLOOR(chi_sq_x)::INTEGER = CEIL(chi_sq_x)::INTEGER
               THEN (FLOOR(chi_sq_x)::INTEGER - 1) + 1
               ELSE FLOOR(chi_sq_x)::INTEGER + 1
          END AS id
         ,CASE WHEN chi_sq_x <= 1
              THEN '(0 1]'
              WHEN FLOOR(chi_sq_x)::INTEGER = CEIL(chi_sq_x)::INTEGER
              THEN '(' || (FLOOR(chi_sq_x)::INTEGER - 1)::TEXT || ' ' ||  (FLOOR(chi_sq_x)::INTEGER)::TEXT || ']'
              ELSE '(' || (FLOOR(chi_sq_x)::INTEGER)::TEXT || ' ' || (CEIL(chi_sq_x)::INTEGER)::TEXT || ']'
          END AS bin
        , chi_sq_x
        , cnt
    FROM chi_squared_cnt
),
histogram AS (
  SELECT   id
         , bin
         , SUM(cnt) AS freq
    FROM binning
   GROUP BY id, bin
)
SELECT   id
       , bin
       , freq
       , ROUND((freq/10.0)::NUMERIC,0)::INTEGER
       , LPAD('*',ROUND((freq/10.0)::NUMERIC,0)::INTEGER ,'*') AS freq_plot
  FROM histogram
  ORDER BY id;
```

```console
id |   bin   | freq | round |     freq_plot
---+---------+------+-------+-------------------
 1 | (0 1]   |   36 |     4 | ****
 2 | (1 2]   |  114 |    11 | ***********
 3 | (2 3]   |  168 |    17 | *****************
 4 | (3 4]   |  135 |    14 | **************
 5 | (4 5]   |  135 |    14 | **************
 6 | (5 6]   |  105 |    11 | ***********
 7 | (6 7]   |   74 |     7 | *******
 8 | (7 8]   |   75 |     8 | ********
 9 | (8 9]   |   45 |     5 | *****
10 | (9 10]  |   29 |     3 | ***
11 | (10 11] |   31 |     3 | ***
12 | (11 12] |   12 |     1 | *
13 | (12 13] |   16 |     2 | **
14 | (13 14] |   11 |     1 | *
15 | (14 15] |    4 |     0 |
16 | (15 16] |    5 |     1 | *
17 | (16 17] |    1 |     0 |
18 | (17 18] |    2 |     0 |
19 | (18 19] |    1 |     0 |
20 | (19 20] |    1 |     0 |
```

## Problem 6: Simulating random chi-square variables 6 DOF

```SQL
CREATE TABLE chi_squared_dof6 AS (
WITH samples AS (
  SELECT  t.id AS id
        , t.rw_nm * FLOOR(RANDOM()*1000000)::INTEGER + 1 AS rw_nm
  FROM (SELECT *
          FROM GENERATE_SERIES(1,6000) AS id, (SELECT 1 AS rw_nm) x ) t
),
normal_sampling AS (
  SELECT  s.id AS id
        , z
        , ROUND(POWER(z,2)::NUMERIC,2) AS chi_sq_x
   FROM normal_z_1M_obs nz
  INNER JOIN samples s
     ON nz.ob_id = s.rw_nm
),
grouping_samples AS (
  SELECT  NTILE (1000) OVER (ORDER BY id) AS grp
        , chi_sq_x
   FROM normal_sampling
),
chi_sq_samples AS (
  SELECT  grp AS id
        , SUM(chi_sq_x) AS chi_sq_x_dof6
   FROM grouping_samples
  GROUP BY grp
)
SELECT chi_sq_x_dof6
  FROM chi_sq_samples
);

WITH diff AS (
  SELECT chi_sq_x_dof6 AS x
       , COUNT(chi_sq_x_dof6) OVER() AS n
       , AVG(chi_sq_x_dof6) OVER() AS mean
       , STDDEV_POP(chi_sq_x_dof6) OVER() AS std_p
       , STDDEV(chi_sq_x_dof6) OVER() AS std
    FROM chi_squared_dof6
),
comp_sk_krt AS (
  SELECT n
       , PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY x) AS median
       , mean
       , std
       , SUM(POWER(x - mean,3))/(COUNT(x))  AS num_sk
       , POWER(std_p,3) AS den_sk
       , SUM(POWER(x - mean,4))/(COUNT(x))  AS num_krt
       , POWER(std_p,4) AS den_krt
    FROM diff
   GROUP BY n, mean, std, std_p
),
pop_sk_krt AS (
  SELECT  n
        , median
        , mean
        , std
        , num_sk/den_sk AS skw
        , num_krt/den_krt - 3 AS execess_krt
    FROM comp_sk_krt
)
SELECT  n
      , ROUND(median::NUMERIC,2) AS median
      , ROUND(mean,2) AS mean
      , ROUND(std,2) AS sample_std
      , ROUND((SQRT(n*(n-1.0))/(n-2.0))*skw,2) AS sample_skeweness
      , ROUND((n - 1)*((n + 1)*execess_krt + 6)/((n-2)*(n-3)),2) AS ex_kurt
  FROM pop_sk_krt;
```

```console
n    | median | mean | sample_std | sample_skeweness | ex_kurt
-----+--------+------+------------+------------------+---------
1000 |   5.40 | 5.99 |       3.34 |             1.17 |    2.17
```

Let's plot the histogram:


```SQL
WITH chi_squared_cnt AS (
  SELECT chi_sq_x_dof6 AS chi_sq_x
       , COUNT(chi_sq_x_dof6) AS cnt
    FROM chi_squared_dof6
   GROUP BY 1
),
binning AS (
  SELECT  CASE WHEN chi_sq_x <= 1
               THEN 1
               WHEN FLOOR(chi_sq_x)::INTEGER = CEIL(chi_sq_x)::INTEGER
               THEN (FLOOR(chi_sq_x)::INTEGER - 1) + 1
               ELSE FLOOR(chi_sq_x)::INTEGER + 1
          END AS id
         ,CASE WHEN chi_sq_x <= 1
              THEN '(0 1]'
              WHEN FLOOR(chi_sq_x)::INTEGER = CEIL(chi_sq_x)::INTEGER
              THEN '(' || (FLOOR(chi_sq_x)::INTEGER - 1)::TEXT || ' ' ||  (FLOOR(chi_sq_x)::INTEGER)::TEXT || ']'
              ELSE '(' || (FLOOR(chi_sq_x)::INTEGER)::TEXT || ' ' || (CEIL(chi_sq_x)::INTEGER)::TEXT || ']'
          END AS bin
        , chi_sq_x
        , cnt
    FROM chi_squared_cnt
),
histogram AS (
  SELECT   id
         , bin
         , SUM(cnt) AS freq
    FROM binning
   GROUP BY id, bin
)
SELECT   id
       , bin
       , freq
       , ROUND((freq/10.0)::NUMERIC,0)::INTEGER
       , LPAD('*',ROUND((freq/10.0)::NUMERIC,0)::INTEGER ,'*') AS freq_plot
  FROM histogram
  ORDER BY id;
```

```console
id |   bin   | freq | round |    freq_plot
---+---------+------+-------+-----------------
 1 | (0 1]   |    9 |     1 | *
 2 | (1 2]   |   67 |     7 | *******
 3 | (2 3]   |   97 |    10 | **********
 4 | (3 4]   |  130 |    13 | *************
 5 | (4 5]   |  150 |    15 | ***************
 6 | (5 6]   |  126 |    13 | *************
 7 | (6 7]   |  113 |    11 | ***********
 8 | (7 8]   |   74 |     7 | *******
 9 | (8 9]   |   63 |     6 | ******
10 | (9 10]  |   52 |     5 | *****
11 | (10 11] |   43 |     4 | ****
12 | (11 12] |   16 |     2 | **
13 | (12 13] |   20 |     2 | **
14 | (13 14] |   14 |     1 | *
15 | (14 15] |   11 |     1 | *
16 | (15 16] |    4 |     0 |
17 | (16 17] |    4 |     0 |
18 | (17 18] |    1 |     0 |
19 | (18 19] |    2 |     0 |
20 | (19 20] |    1 |     0 |
23 | (22 23] |    2 |     0 |
24 | (23 24] |    1 |     0 |
(22 rows)
```

## Problem 7: Simulating random chi-square variables 9 DOF


```SQL
CREATE TABLE chi_squared_dof9 AS (
WITH samples AS (
  SELECT  t.id AS id
        , t.rw_nm * FLOOR(RANDOM()*1000000)::INTEGER + 1 AS rw_nm
  FROM (SELECT *
          FROM GENERATE_SERIES(1,9000) AS id, (SELECT 1 AS rw_nm) x ) t
),
normal_sampling AS (
  SELECT  s.id AS id
        , z
        , ROUND(POWER(z,2)::NUMERIC,2) AS chi_sq_x
   FROM normal_z_1M_obs nz
  INNER JOIN samples s
     ON nz.ob_id = s.rw_nm
),
grouping_samples AS (
  SELECT  NTILE (1000) OVER (ORDER BY id) AS grp
        , chi_sq_x
   FROM normal_sampling
),
chi_sq_samples AS (
  SELECT  grp AS id
        , SUM(chi_sq_x) AS chi_sq_x_dof9
   FROM grouping_samples
  GROUP BY grp
)
SELECT chi_sq_x_dof9
  FROM chi_sq_samples
);

WITH diff AS (
  SELECT chi_sq_x_dof9 AS x
       , COUNT(chi_sq_x_dof9) OVER() AS n
       , AVG(chi_sq_x_dof9) OVER() AS mean
       , STDDEV_POP(chi_sq_x_dof9) OVER() AS std_p
       , STDDEV(chi_sq_x_dof9) OVER() AS std
    FROM chi_squared_dof9
),
comp_sk_krt AS (
  SELECT n
       , PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY x) AS median
       , mean
       , std
       , SUM(POWER(x - mean,3))/(COUNT(x))  AS num_sk
       , POWER(std_p,3) AS den_sk
       , SUM(POWER(x - mean,4))/(COUNT(x))  AS num_krt
       , POWER(std_p,4) AS den_krt
    FROM diff
   GROUP BY n, mean, std, std_p
),
pop_sk_krt AS (
  SELECT  n
        , median
        , mean
        , std
        , num_sk/den_sk AS skw
        , num_krt/den_krt - 3 AS execess_krt
    FROM comp_sk_krt
)
SELECT  n
      , ROUND(median::NUMERIC,2) AS median
      , ROUND(mean,2) AS mean
      , ROUND(std,2) AS sample_std
      , ROUND((SQRT(n*(n-1.0))/(n-2.0))*skw,2) AS sample_skeweness
      , ROUND((n - 1)*((n + 1)*execess_krt + 6)/((n-2)*(n-3)),2) AS ex_kurt
  FROM pop_sk_krt;
```

```console
n    | median | mean | sample_std | sample_skeweness | ex_kurt
-----+--------+------+------------+------------------+---------
1000 |   8.05 | 8.81 |       4.18 |             0.97 |    1.59
```

Let's plot the histogram:


```SQL
WITH chi_squared_cnt AS (
  SELECT chi_sq_x_dof9 AS chi_sq_x
       , COUNT(chi_sq_x_dof9) AS cnt
    FROM chi_squared_dof9
   GROUP BY 1
),
binning AS (
  SELECT  CASE WHEN chi_sq_x <= 1
               THEN 1
               WHEN FLOOR(chi_sq_x)::INTEGER = CEIL(chi_sq_x)::INTEGER
               THEN (FLOOR(chi_sq_x)::INTEGER - 1) + 1
               ELSE FLOOR(chi_sq_x)::INTEGER + 1
          END AS id
         ,CASE WHEN chi_sq_x <= 1
              THEN '(0 1]'
              WHEN FLOOR(chi_sq_x)::INTEGER = CEIL(chi_sq_x)::INTEGER
              THEN '(' || (FLOOR(chi_sq_x)::INTEGER - 1)::TEXT || ' ' ||  (FLOOR(chi_sq_x)::INTEGER)::TEXT || ']'
              ELSE '(' || (FLOOR(chi_sq_x)::INTEGER)::TEXT || ' ' || (CEIL(chi_sq_x)::INTEGER)::TEXT || ']'
          END AS bin
        , chi_sq_x
        , cnt
    FROM chi_squared_cnt
),
histogram AS (
  SELECT   id
         , bin
         , SUM(cnt) AS freq
    FROM binning
   GROUP BY id, bin
)
SELECT   id
       , bin
       , freq
       , ROUND((freq/10.0)::NUMERIC,0)::INTEGER
       , LPAD('*',ROUND((freq/10.0)::NUMERIC,0)::INTEGER ,'*') AS freq_plot
  FROM histogram
  ORDER BY id;
```

```console
id |   bin   | freq | round |  freq_plot
---+---------+------+-------+--------------
 2 | (1 2]   |   16 |     2 | **
 3 | (2 3]   |   25 |     3 | ***
 4 | (3 4]   |   53 |     5 | *****
 5 | (4 5]   |   74 |     7 | *******
 6 | (5 6]   |  102 |    10 | **********
 7 | (6 7]   |  109 |    11 | ***********
 8 | (7 8]   |  118 |    12 | ************
 9 | (8 9]   |   93 |     9 | *********
10 | (9 10]  |   74 |     7 | *******
11 | (10 11] |   64 |     6 | ******
12 | (11 12] |   65 |     7 | *******
13 | (12 13] |   58 |     6 | ******
14 | (13 14] |   44 |     4 | ****
15 | (14 15] |   26 |     3 | ***
16 | (15 16] |   19 |     2 | **
17 | (16 17] |   20 |     2 | **
18 | (17 18] |    8 |     1 | *
19 | (18 19] |    8 |     1 | *
20 | (19 20] |    8 |     1 | *
21 | (20 21] |    7 |     1 | *
22 | (21 22] |    1 |     0 |
23 | (22 23] |    4 |     0 |
25 | (24 25] |    1 |     0 |
27 | (26 27] |    1 |     0 |
30 | (29 30] |    1 |     0 |
31 | (30 31] |    1 |     0 |
(26 rows)
```
