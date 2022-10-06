# The Chi-square Distribution Continued

In the previous section we introduced the `chi-square` distribution as a sum of squared normal standard random variables. We illustrated how to generate `1000` chi-square random variables to approximate the chi-square distribution.

In this section we increase the number of observation to better approximate the shape of the chi-square distribution.

## Problem 1: Simulating random chi-square variables 1 DOF (4000 samples)

Let's study first the simple case of `v=1`.

- X<sup>2</sup> = X<sup>2</sup><sub>1</sub>

In this section, we’ll show you how to generate **4000** `chi-square` random variables by squaring random standard normal variables.

First, generate `4000` random values in the range `[1 1,000,000]`.

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

Next, randomly select `with replacement` 4000 observations from a standard normal distribution and squared the result.

```SQL
WITH samples AS (
  SELECT  t.id AS id
        , t.rw_nm * FLOOR(RANDOM()*1000000)::INTEGER + 1 AS rw_nm
  FROM (SELECT *
          FROM GENERATE_SERIES(1,4000) AS id, (SELECT 1 AS rw_nm) x ) t
)
SELECT  ob_id
      , z
      , ROUND(POWER(z,2)::NUMERIC,2) AS chi_sq_x
 FROM normal_z_1M_obs nz
INNER JOIN samples s
   ON nz.ob_id = s.rw_nm
ORDER BY chi_sq_x,z,ob_id;
```

Let's save the `chi-square` distribution with one degree of freedom.

```SQL
CREATE TABLE chi_squared_dof1 AS (
WITH samples AS (
  SELECT  t.id AS id
        , t.rw_nm * FLOOR(RANDOM()*1000000)::INTEGER + 1 AS rw_nm
  FROM (SELECT *
          FROM GENERATE_SERIES(1,4000) AS id, (SELECT 1 AS rw_nm) x ) t
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
SELECT 'n' AS stats
      , n AS emp_val
      , n AS theo_val
  FROM pop_sk_krt
UNION ALL
SELECT 'mean' AS stats
      , ROUND(mean::NUMERIC,2) AS emp_val
      , 1.0 AS theo_val
  FROM pop_sk_krt
UNION ALL
SELECT 'median' AS stats
      , ROUND(median::NUMERIC,2) AS emp_val
      , ROUND((1.0*POWER((1 - 2/(9*1.0)),3))::NUMERIC,2) AS theo_val
  FROM pop_sk_krt
UNION ALL
SELECT 'sample_std' AS stats
      , ROUND(std,2) AS emp_val
      , ROUND(SQRT(2*1.0)::NUMERIC,2) AS theo_val
  FROM pop_sk_krt
UNION ALL
SELECT 'sample_skw' AS stats
      , ROUND((SQRT(n*(n-1.0))/(n-2.0))*skw,2) AS emp_val
      , ROUND(SQRT(8/1.0)::NUMERIC,2) AS theo_val
  FROM pop_sk_krt
UNION ALL
SELECT 'ex_kurt' AS stats
      , ROUND((n - 1)*((n + 1)*execess_krt + 6)/((n-2)*(n-3)),2) AS emp_val
      , ROUND((12/1.0)::NUMERIC,2) AS theo_val
  FROM pop_sk_krt;
```

```console
stats      | emp_val | theo_val
-----------+---------+----------
n          |    4000 |     4000
mean       |    1.01 |      1.0
median     |    0.49 |     0.47
sample_std |    1.44 |     1.41
sample_skw |    2.75 |     2.83
ex_kurt    |   10.30 |    12.00
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
       , ROUND((100*(freq/4000.0))::NUMERIC,0) AS prob
       , LPAD('*',ROUND((100*(freq/4000.0))::NUMERIC,0)::INTEGER ,'*') AS freq_plot
  FROM histogram
  ORDER BY id;
```

```console
id |   bin   | freq | prob |                                freq_plot
---+---------+------+------+-------------------------------------------------------------------------
 1 | (0 1]   | 2825 |   71 | ***********************************************************************
 2 | (1 2]   |  596 |   15 | ***************
 3 | (2 3]   |  254 |    6 | ******
 4 | (3 4]   |  157 |    4 | ****
 5 | (4 5]   |   65 |    2 | **
 6 | (5 6]   |   41 |    1 | *
 7 | (6 7]   |   26 |    1 | *
 8 | (7 8]   |   13 |    0 |
 9 | (8 9]   |   14 |    0 |
10 | (9 10]  |    3 |    0 |
11 | (10 11] |    3 |    0 |
12 | (11 12] |    2 |    0 |
13 | (12 13] |    1 |    0 |
(13 rows)
```


## Problem 2: Simulating random chi-square variables 2 DOF (4000 samples)

Let's study the case of `v=2`.

- X<sup>2</sup> = X<sup>2</sup><sub>1</sub> + X<sup>2</sup><sub>2</sub>

Randomly select two observations from a standard normal distribution with a mean zero and standard deviation  of 1. Next, square each value and sum them all up. The result is an observation from a `chi-square` distribution with `2` degree of freedom.

First, generate `8000` random values in the range `[1 1,000,000]`.

```SQL
WITH samples AS (
  SELECT  t.id AS id
        , t.rw_nm * FLOOR(RANDOM()*1000000)::INTEGER + 1 AS rw_nm
  FROM (SELECT *
          FROM GENERATE_SERIES(1,8000) AS id, (SELECT 1 AS rw_nm) x ) t
)
SELECT *
  FROM samples
 ORDER BY id;
```

Next, randomly select `with replacement` 8000 observations from a standard normal distribution and squared the result.

```SQL
WITH samples AS (
  SELECT  t.id AS id
        , t.rw_nm * FLOOR(RANDOM()*1000000)::INTEGER + 1 AS rw_nm
  FROM (SELECT *
          FROM GENERATE_SERIES(1,8000) AS id, (SELECT 1 AS rw_nm) x ) t
)
SELECT  s.id
      , z
      , ROUND(POWER(z,2)::NUMERIC,2) AS chi_sq_x
 FROM normal_z_1M_obs nz
INNER JOIN samples s
   ON nz.ob_id = s.rw_nm
ORDER BY id;
```

Next, partition the table rows in 4000 groups of two samples.

```SQL
WITH samples AS (
  SELECT  t.id AS id
        , t.rw_nm * FLOOR(RANDOM()*1000000)::INTEGER + 1 AS rw_nm
  FROM (SELECT *
          FROM GENERATE_SERIES(1,8000) AS id, (SELECT 1 AS rw_nm) x ) t
),
normal_sampling AS (
  SELECT  s.id AS id
        , z
        , ROUND(POWER(z,2)::NUMERIC,2) AS chi_sq_x
   FROM normal_z_1M_obs nz
  INNER JOIN samples s
     ON nz.ob_id = s.rw_nm
)
SELECT  NTILE (4000) OVER (ORDER BY id) AS grp
      , id
      , z
      , chi_sq_x
 FROM normal_sampling
ORDER BY id;
```

```console
grp  |  id  |   z   | chi_sq_x
-----+------+-------+----------
   1 |    1 | -0.10 |     0.01
   1 |    2 | -0.40 |     0.16
   2 |    3 |  0.10 |     0.01
   2 |    4 | -0.40 |     0.16
```

Let's create a table with the random variables.

```SQL
CREATE TABLE chi_squared_dof2 AS (
WITH samples AS (
  SELECT  t.id AS id
        , t.rw_nm * FLOOR(RANDOM()*1000000)::INTEGER + 1 AS rw_nm
  FROM (SELECT *
          FROM GENERATE_SERIES(1,8000) AS id, (SELECT 1 AS rw_nm) x ) t
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
  SELECT  NTILE (4000) OVER (ORDER BY id) AS grp
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
SELECT 'n' AS stats
      , n AS emp_val
      , n AS theo_val
  FROM pop_sk_krt
UNION ALL
SELECT 'mean' AS stats
      , ROUND(mean::NUMERIC,2) AS emp_val
      , 2.0 AS theo_val
  FROM pop_sk_krt
UNION ALL
SELECT 'median' AS stats
      , ROUND(median::NUMERIC,2) AS emp_val
      , ROUND((2.0*POWER((1 - 2/(9*2.0)),3))::NUMERIC,2) AS theo_val
  FROM pop_sk_krt
UNION ALL
SELECT 'sample_std' AS stats
      , ROUND(std,2) AS emp_val
      , ROUND(SQRT(2*2.0)::NUMERIC,2) AS theo_val
  FROM pop_sk_krt
UNION ALL
SELECT 'sample_skw' AS stats
      , ROUND((SQRT(n*(n-1.0))/(n-2.0))*skw,2) AS emp_val
      , ROUND(SQRT(8/2.0)::NUMERIC,2) AS theo_val
  FROM pop_sk_krt
UNION ALL
SELECT 'ex_kurt' AS stats
      , ROUND((n - 1)*((n + 1)*execess_krt + 6)/((n-2)*(n-3)),2) AS emp_val
      , ROUND((12/2.0)::NUMERIC,2) AS theo_val
  FROM pop_sk_krt;
```

```console
stats      | emp_val | theo_val
-----------+---------+----------
n          |    4000 |     4000
mean       |    1.93 |      2.0
median     |    1.37 |     1.40
sample_std |    1.88 |     2.00
sample_skw |    2.04 |     2.00
ex_kurt    |    6.49 |     6.00
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
       , ROUND((100*(freq/4000.0))::NUMERIC,0) AS prob
       , LPAD('*',ROUND((100*(freq/4000.0))::NUMERIC,0)::INTEGER ,'*') AS freq_plot
  FROM histogram
  ORDER BY id;
```

```console
id |   bin   | freq | prob |                freq_plot
---+---------+------+------+-----------------------------------------
 1 | (0 1]   | 1543 |   39 | ***************************************
 2 | (1 2]   | 1007 |   25 | *************************
 3 | (2 3]   |  613 |   15 | ***************
 4 | (3 4]   |  335 |    8 | ********
 5 | (4 5]   |  235 |    6 | ******
 6 | (5 6]   |  116 |    3 | ***
 7 | (6 7]   |   57 |    1 | *
 8 | (7 8]   |   34 |    1 | *
 9 | (8 9]   |   22 |    1 | *
10 | (9 10]  |   18 |    0 |
11 | (10 11] |    7 |    0 |
12 | (11 12] |    4 |    0 |
13 | (12 13] |    3 |    0 |
14 | (13 14] |    2 |    0 |
15 | (14 15] |    2 |    0 |
16 | (15 16] |    1 |    0 |
17 | (16 17] |    1 |    0 |
(17 rows)
```

## Problem 2: Simulating random chi-square variables 3 DOF (4000 samples)

Let's study the case of `v=3`.

- X<sup>2</sup> = X<sup>2</sup><sub>1</sub> + X<sup>2</sup><sub>2</sub> + X<sup>2</sup><sub>3</sub>

Randomly select three observations from a standard normal distribution with a mean zero and standard deviation  of 1. Next, square each value and sum them all up. The result is an observation from a `chi-square` distribution with `3` degree of freedom.


Partition the table rows in `4000` groups of `3` samples. We need `12,000` samples.

```SQL
WITH samples AS (
  SELECT  t.id AS id
        , t.rw_nm * FLOOR(RANDOM()*1000000)::INTEGER + 1 AS rw_nm
  FROM (SELECT *
          FROM GENERATE_SERIES(1,12000) AS id, (SELECT 1 AS rw_nm) x ) t
),
normal_sampling AS (
  SELECT  s.id AS id
        , z
        , ROUND(POWER(z,2)::NUMERIC,2) AS chi_sq_x
   FROM normal_z_1M_obs nz
  INNER JOIN samples s
     ON nz.ob_id = s.rw_nm
)
SELECT  NTILE (4000) OVER (ORDER BY id) AS grp
      , id
      , z
      , chi_sq_x
 FROM normal_sampling
ORDER BY id;
```

```console
grp  |  id   |   z   | chi_sq_x
-----+-------+-------+----------
   1 |     1 |  2.10 |     4.41
   1 |     2 | -0.50 |     0.25
   1 |     3 | -0.30 |     0.09
   2 |     4 | -0.30 |     0.09
   2 |     5 |  0.20 |     0.04
   2 |     6 | -1.60 |     2.56
```

Let's create a table with the random variables.

```SQL
CREATE TABLE chi_squared_dof3 AS (
WITH samples AS (
  SELECT  t.id AS id
        , t.rw_nm * FLOOR(RANDOM()*1000000)::INTEGER + 1 AS rw_nm
  FROM (SELECT *
          FROM GENERATE_SERIES(1,12000) AS id, (SELECT 1 AS rw_nm) x ) t
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
  SELECT  NTILE (4000) OVER (ORDER BY id) AS grp
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
SELECT 'n' AS stats
      , n AS emp_val
      , n AS theo_val
  FROM pop_sk_krt
UNION ALL
SELECT 'mean' AS stats
      , ROUND(mean::NUMERIC,2) AS emp_val
      , 3.0 AS theo_val
  FROM pop_sk_krt
UNION ALL
SELECT 'median' AS stats
      , ROUND(median::NUMERIC,2) AS emp_val
      , ROUND((3.0*POWER((1 - 2/(9*3.0)),3))::NUMERIC,2) AS theo_val
  FROM pop_sk_krt
UNION ALL
SELECT 'sample_std' AS stats
      , ROUND(std,2) AS emp_val
      , ROUND(SQRT(2*3.0)::NUMERIC,2) AS theo_val
  FROM pop_sk_krt
UNION ALL
SELECT 'sample_skw' AS stats
      , ROUND((SQRT(n*(n-1.0))/(n-2.0))*skw,2) AS emp_val
      , ROUND(SQRT(8/3.0)::NUMERIC,2) AS theo_val
  FROM pop_sk_krt
UNION ALL
SELECT 'ex_kurt' AS stats
      , ROUND((n - 1)*((n + 1)*execess_krt + 6)/((n-2)*(n-3)),2) AS emp_val
      , ROUND((12/3.0)::NUMERIC,2) AS theo_val
  FROM pop_sk_krt;
```

```console
stats      | emp_val | theo_val
-----------+---------+----------
n          |    4000 |     4000
mean       |    2.99 |      3.0
median     |    2.37 |     2.38
sample_std |    2.43 |     2.45
sample_skw |    1.52 |     1.63
ex_kurt    |    2.96 |     4.00
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
       , ROUND((100*(freq/4000.0))::NUMERIC,0) AS prob
       , LPAD('*',ROUND((100*(freq/4000.0))::NUMERIC,0)::INTEGER ,'*') AS freq_plot
  FROM histogram
  ORDER BY id;
```

```console
id |   bin   | freq | prob |       freq_plot
---+---------+------+------+------------------------
 1 | (0 1]   |  808 |   20 | ********************
 2 | (1 2]   |  882 |   22 | **********************
 3 | (2 3]   |  730 |   18 | ******************
 4 | (3 4]   |  518 |   13 | *************
 5 | (4 5]   |  390 |   10 | **********
 6 | (5 6]   |  244 |    6 | ******
 7 | (6 7]   |  135 |    3 | ***
 8 | (7 8]   |   98 |    2 | **
 9 | (8 9]   |   73 |    2 | **
10 | (9 10]  |   43 |    1 | *
11 | (10 11] |   33 |    1 | *
12 | (11 12] |   22 |    1 | *
13 | (12 13] |    8 |    0 |
14 | (13 14] |    7 |    0 |
15 | (14 15] |    4 |    0 |
16 | (15 16] |    3 |    0 |
17 | (16 17] |    1 |    0 |
18 | (17 18] |    1 |    0 |
```

## Problem 4: Simulating random chi-square variables 4 DOF

Let's study the case of `v=4`.

- X<sup>2</sup> = X<sup>2</sup><sub>1</sub> + X<sup>2</sup><sub>2</sub> + X<sup>2</sup><sub>3</sub> + X<sup>2</sup><sub>4</sub>

Randomly select four observations from a standard normal distribution with a mean zero and standard deviation  of 1. Next, square each value and sum them all up. The result is an observation from a `chi-square` distribution with `4` degree of freedom.

Partition the table rows in `4000` groups of `4` samples. We need `16,000` samples.

```SQL
WITH samples AS (
  SELECT  t.id AS id
        , t.rw_nm * FLOOR(RANDOM()*1000000)::INTEGER + 1 AS rw_nm
  FROM (SELECT *
          FROM GENERATE_SERIES(1,16000) AS id, (SELECT 1 AS rw_nm) x ) t
),
normal_sampling AS (
  SELECT  s.id AS id
        , z
        , ROUND(POWER(z,2)::NUMERIC,2) AS chi_sq_x
   FROM normal_z_1M_obs nz
  INNER JOIN samples s
     ON nz.ob_id = s.rw_nm
)
SELECT  NTILE (4000) OVER (ORDER BY id) AS grp
      , id
      , z
      , chi_sq_x
 FROM normal_sampling
ORDER BY id;
```

```console
grp  |  id   |   z   | chi_sq_x
-----+-------+-------+----------
   1 |     1 | -1.00 |     1.00
   1 |     2 | -0.50 |     0.25
   1 |     3 | -0.30 |     0.09
   1 |     4 | -1.90 |     3.61
   2 |     5 | -2.70 |     7.29
   2 |     6 | -0.40 |     0.16
   2 |     7 |  0.90 |     0.81
   2 |     8 | -1.60 |     2.56
```

Let's create a table with the random variables.

```SQL
CREATE TABLE chi_squared_dof4 AS (
WITH samples AS (
  SELECT  t.id AS id
        , t.rw_nm * FLOOR(RANDOM()*1000000)::INTEGER + 1 AS rw_nm
  FROM (SELECT *
          FROM GENERATE_SERIES(1,16000) AS id, (SELECT 1 AS rw_nm) x ) t
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
  SELECT  NTILE (4000) OVER (ORDER BY id) AS grp
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
SELECT 'n' AS stats
      , n AS emp_val
      , n AS theo_val
  FROM pop_sk_krt
UNION ALL
SELECT 'mean' AS stats
      , ROUND(mean::NUMERIC,2) AS emp_val
      , 4.0 AS theo_val
  FROM pop_sk_krt
UNION ALL
SELECT 'median' AS stats
      , ROUND(median::NUMERIC,2) AS emp_val
      , ROUND((4.0*POWER((1 - 2/(9*4.0)),3))::NUMERIC,2) AS theo_val
  FROM pop_sk_krt
UNION ALL
SELECT 'sample_std' AS stats
      , ROUND(std,2) AS emp_val
      , ROUND(SQRT(2*4.0)::NUMERIC,2) AS theo_val
  FROM pop_sk_krt
UNION ALL
SELECT 'sample_skw' AS stats
      , ROUND((SQRT(n*(n-1.0))/(n-2.0))*skw,2) AS emp_val
      , ROUND(SQRT(8/4.0)::NUMERIC,2) AS theo_val
  FROM pop_sk_krt
UNION ALL
SELECT 'ex_kurt' AS stats
      , ROUND((n - 1)*((n + 1)*execess_krt + 6)/((n-2)*(n-3)),2) AS emp_val
      , ROUND((12/4.0)::NUMERIC,2) AS theo_val
  FROM pop_sk_krt;
```

```console
stats      | emp_val | theo_val
-----------+---------+----------
n          |    4000 |     4000
mean       |    4.06 |      4.0
median     |    3.41 |     3.37
sample_std |    2.86 |     2.83
sample_skw |    1.37 |     1.41
ex_kurt    |    2.81 |     3.00
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
       , ROUND((100*(freq/4000.0))::NUMERIC,0) AS prob
       , LPAD('*',ROUND((100*(freq/4000.0))::NUMERIC,0)::INTEGER ,'*') AS freq_plot
  FROM histogram
  ORDER BY id;
```

```console
id |   bin   | freq | prob |     freq_plot
---+---------+------+------+--------------------
 1 | (0 1]   |  348 |    9 | *********
 2 | (1 2]   |  685 |   17 | *****************
 3 | (2 3]   |  710 |   18 | ******************
 4 | (3 4]   |  585 |   15 | ***************
 5 | (4 5]   |  486 |   12 | ************
 6 | (5 6]   |  363 |    9 | *********
 7 | (6 7]   |  256 |    6 | ******
 8 | (7 8]   |  173 |    4 | ****
 9 | (8 9]   |  124 |    3 | ***
10 | (9 10]  |  108 |    3 | ***
11 | (10 11] |   51 |    1 | *
12 | (11 12] |   46 |    1 | *
13 | (12 13] |   23 |    1 | *
14 | (13 14] |   10 |    0 |
15 | (14 15] |   10 |    0 |
16 | (15 16] |   10 |    0 |
17 | (16 17] |    5 |    0 |
18 | (17 18] |    2 |    0 |
19 | (18 19] |    2 |    0 |
22 | (21 22] |    1 |    0 |
23 | (22 23] |    2 |    0 |
```

## Problem 5: Simulating random chi-square variables 5 DOF

```SQL
CREATE TABLE chi_squared_dof5 AS (
WITH samples AS (
  SELECT  t.id AS id
        , t.rw_nm * FLOOR(RANDOM()*1000000)::INTEGER + 1 AS rw_nm
  FROM (SELECT *
          FROM GENERATE_SERIES(1,20000) AS id, (SELECT 1 AS rw_nm) x ) t
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
  SELECT  NTILE (4000) OVER (ORDER BY id) AS grp
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
SELECT 'n' AS stats
      , n AS emp_val
      , n AS theo_val
  FROM pop_sk_krt
UNION ALL
SELECT 'mean' AS stats
      , ROUND(mean::NUMERIC,2) AS emp_val
      , 5.0 AS theo_val
  FROM pop_sk_krt
UNION ALL
SELECT 'median' AS stats
      , ROUND(median::NUMERIC,2) AS emp_val
      , ROUND((5.0*POWER((1 - 2/(9*5.0)),3))::NUMERIC,2) AS theo_val
  FROM pop_sk_krt
UNION ALL
SELECT 'sample_std' AS stats
      , ROUND(std,2) AS emp_val
      , ROUND(SQRT(2*5.0)::NUMERIC,2) AS theo_val
  FROM pop_sk_krt
UNION ALL
SELECT 'sample_skw' AS stats
      , ROUND((SQRT(n*(n-1.0))/(n-2.0))*skw,2) AS emp_val
      , ROUND(SQRT(8/5.0)::NUMERIC,2) AS theo_val
  FROM pop_sk_krt
UNION ALL
SELECT 'ex_kurt' AS stats
      , ROUND((n - 1)*((n + 1)*execess_krt + 6)/((n-2)*(n-3)),2) AS emp_val
      , ROUND((12/5.0)::NUMERIC,2) AS theo_val
  FROM pop_sk_krt;
```

```console
stats      | emp_val | theo_val
-----------+---------+----------
n          |    4000 |     4000
mean       |    4.98 |      5.0
median     |    4.30 |     4.36
sample_std |    3.21 |     3.16
sample_skw |    1.24 |     1.26
ex_kurt    |    2.18 |     2.40
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
       , ROUND((100*(freq/4000.0))::NUMERIC,0) AS prob
       , LPAD('*',ROUND((100*(freq/4000.0))::NUMERIC,0)::INTEGER ,'*') AS freq_plot
  FROM histogram
  ORDER BY id;
```

```console
id |   bin   | freq | prob |    freq_plot
---+---------+------+------+-----------------
 1 | (0 1]   |  172 |    4 | ****
 2 | (1 2]   |  472 |   12 | ************
 3 | (2 3]   |  593 |   15 | ***************
 4 | (3 4]   |  600 |   15 | ***************
 5 | (4 5]   |  511 |   13 | *************
 6 | (5 6]   |  427 |   11 | ***********
 7 | (6 7]   |  318 |    8 | ********
 8 | (7 8]   |  279 |    7 | *******
 9 | (8 9]   |  171 |    4 | ****
10 | (9 10]  |  149 |    4 | ****
11 | (10 11] |   89 |    2 | **
12 | (11 12] |   71 |    2 | **
13 | (12 13] |   51 |    1 | *
14 | (13 14] |   39 |    1 | *
15 | (14 15] |   19 |    0 |
16 | (15 16] |   11 |    0 |
17 | (16 17] |    9 |    0 |
18 | (17 18] |    7 |    0 |
19 | (18 19] |    4 |    0 |
20 | (19 20] |    2 |    0 |
21 | (20 21] |    4 |    0 |
23 | (22 23] |    1 |    0 |
28 | (27 28] |    1 |    0 |
(23 rows)
```

## Problem 6: Simulating random chi-square variables 6 DOF

```SQL
CREATE TABLE chi_squared_dof6 AS (
WITH samples AS (
  SELECT  t.id AS id
        , t.rw_nm * FLOOR(RANDOM()*1000000)::INTEGER + 1 AS rw_nm
  FROM (SELECT *
          FROM GENERATE_SERIES(1,24000) AS id, (SELECT 1 AS rw_nm) x ) t
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
  SELECT  NTILE (4000) OVER (ORDER BY id) AS grp
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
SELECT 'n' AS stats
      , n AS emp_val
      , n AS theo_val
  FROM pop_sk_krt
UNION ALL
SELECT 'mean' AS stats
      , ROUND(mean::NUMERIC,2) AS emp_val
      , 6.0 AS theo_val
  FROM pop_sk_krt
UNION ALL
SELECT 'median' AS stats
      , ROUND(median::NUMERIC,2) AS emp_val
      , ROUND((6.0*POWER((1 - 2/(9*6.0)),3))::NUMERIC,2) AS theo_val
  FROM pop_sk_krt
UNION ALL
SELECT 'sample_std' AS stats
      , ROUND(std,2) AS emp_val
      , ROUND(SQRT(2*6.0)::NUMERIC,2) AS theo_val
  FROM pop_sk_krt
UNION ALL
SELECT 'sample_skw' AS stats
      , ROUND((SQRT(n*(n-1.0))/(n-2.0))*skw,2) AS emp_val
      , ROUND(SQRT(8/6.0)::NUMERIC,2) AS theo_val
  FROM pop_sk_krt
UNION ALL
SELECT 'ex_kurt' AS stats
      , ROUND((n - 1)*((n + 1)*execess_krt + 6)/((n-2)*(n-3)),2) AS emp_val
      , ROUND((12/6.0)::NUMERIC,2) AS theo_val
  FROM pop_sk_krt;
```

```console
stats      | emp_val | theo_val
-----------+---------+----------
n          |    4000 |     4000
mean       |    6.09 |      6.0
median     |    5.46 |     5.36
sample_std |    3.50 |     3.46
sample_skw |    1.15 |     1.15
ex_kurt    |    1.98 |     2.00
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
       , ROUND((100*(freq/4000.0))::NUMERIC,0) AS prob
       , LPAD('*',ROUND((100*(freq/4000.0))::NUMERIC,0)::INTEGER ,'*') AS freq_plot
  FROM histogram
  ORDER BY id;
```

```console
id |   bin   | freq | prob |   freq_plot
---+---------+------+------+---------------
 1 | (0 1]   |   63 |    2 | **
 2 | (1 2]   |  252 |    6 | ******
 3 | (2 3]   |  431 |   11 | ***********
 4 | (3 4]   |  496 |   12 | ************
 5 | (4 5]   |  532 |   13 | *************
 6 | (5 6]   |  490 |   12 | ************
 7 | (6 7]   |  410 |   10 | **********
 8 | (7 8]   |  366 |    9 | *********
 9 | (8 9]   |  262 |    7 | *******
10 | (9 10]  |  194 |    5 | *****
11 | (10 11] |  140 |    4 | ****
12 | (11 12] |  110 |    3 | ***
13 | (12 13] |   64 |    2 | **
14 | (13 14] |   62 |    2 | **
15 | (14 15] |   40 |    1 | *
16 | (15 16] |   29 |    1 | *
17 | (16 17] |   19 |    0 |
18 | (17 18] |   12 |    0 |
19 | (18 19] |    9 |    0 |
20 | (19 20] |    9 |    0 |
21 | (20 21] |    2 |    0 |
22 | (21 22] |    1 |    0 |
23 | (22 23] |    1 |    0 |
24 | (23 24] |    1 |    0 |
25 | (24 25] |    5 |    0 |
(25 rows)
```

## Problem 7: Simulating random chi-square variables 9 DOF

```SQL
CREATE TABLE chi_squared_dof9 AS (
WITH samples AS (
  SELECT  t.id AS id
        , t.rw_nm * FLOOR(RANDOM()*1000000)::INTEGER + 1 AS rw_nm
  FROM (SELECT *
          FROM GENERATE_SERIES(1,36000) AS id, (SELECT 1 AS rw_nm) x ) t
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
  SELECT  NTILE (4000) OVER (ORDER BY id) AS grp
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
SELECT 'n' AS stats
      , n AS emp_val
      , n AS theo_val
  FROM pop_sk_krt
UNION ALL
SELECT 'mean' AS stats
      , ROUND(mean::NUMERIC,2) AS emp_val
      , 9.0 AS theo_val
  FROM pop_sk_krt
UNION ALL
SELECT 'median' AS stats
      , ROUND(median::NUMERIC,2) AS emp_val
      , ROUND((9.0*POWER((1 - 2/(9*9.0)),3))::NUMERIC,2) AS theo_val
  FROM pop_sk_krt
UNION ALL
SELECT 'sample_std' AS stats
      , ROUND(std,2) AS emp_val
      , ROUND(SQRT(2*9.0)::NUMERIC,2) AS theo_val
  FROM pop_sk_krt
UNION ALL
SELECT 'sample_skw' AS stats
      , ROUND((SQRT(n*(n-1.0))/(n-2.0))*skw,2) AS emp_val
      , ROUND(SQRT(8/9.0)::NUMERIC,2) AS theo_val
  FROM pop_sk_krt
UNION ALL
SELECT 'ex_kurt' AS stats
      , ROUND((n - 1)*((n + 1)*execess_krt + 6)/((n-2)*(n-3)),2) AS emp_val
      , ROUND((12/9.0)::NUMERIC,2) AS theo_val
  FROM pop_sk_krt;
```

```console
stats      | emp_val | theo_val
-----------+---------+----------
n          |    4000 |     4000
mean       |    8.99 |      9.0
median     |    8.35 |     8.35
sample_std |    4.34 |     4.24
sample_skw |    0.98 |     0.94
ex_kurt    |    1.46 |     1.33
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
       , ROUND((100*(freq/4000.0))::NUMERIC,0) AS prob
       , LPAD('*',ROUND((100*(freq/4000.0))::NUMERIC,0)::INTEGER ,'*') AS freq_plot
  FROM histogram
  ORDER BY id;
```

```console
id |   bin   | freq | prob | freq_plot
---+---------+------+------+------------
 1 | (0 1]   |    2 |    0 |
 2 | (1 2]   |   40 |    1 | *
 3 | (2 3]   |  111 |    3 | ***
 4 | (3 4]   |  228 |    6 | ******
 5 | (4 5]   |  330 |    8 | ********
 6 | (5 6]   |  357 |    9 | *********
 7 | (6 7]   |  397 |   10 | **********
 8 | (7 8]   |  411 |   10 | **********
 9 | (8 9]   |  382 |   10 | **********
10 | (9 10]  |  342 |    9 | *********
11 | (10 11] |  289 |    7 | *******
12 | (11 12] |  249 |    6 | ******
13 | (12 13] |  197 |    5 | *****
14 | (13 14] |  166 |    4 | ****
15 | (14 15] |  116 |    3 | ***
16 | (15 16] |  110 |    3 | ***
17 | (16 17] |   69 |    2 | **
18 | (17 18] |   60 |    2 | **
19 | (18 19] |   42 |    1 | *
20 | (19 20] |   27 |    1 | *
21 | (20 21] |   17 |    0 |
22 | (21 22] |   19 |    0 |
23 | (22 23] |   10 |    0 |
24 | (23 24] |    5 |    0 |
25 | (24 25] |    6 |    0 |
26 | (25 26] |    5 |    0 |
27 | (26 27] |    4 |    0 |
28 | (27 28] |    2 |    0 |
29 | (28 29] |    4 |    0 |
30 | (29 30] |    1 |    0 |
33 | (32 33] |    2 |    0 |
(31 rows)
```

## Problem 7: Simulating random chi-square variables 12 DOF

```SQL
CREATE TABLE chi_squared_dof12 AS (
WITH samples AS (
  SELECT  t.id AS id
        , t.rw_nm * FLOOR(RANDOM()*1000000)::INTEGER + 1 AS rw_nm
  FROM (SELECT *
          FROM GENERATE_SERIES(1,48000) AS id, (SELECT 1 AS rw_nm) x ) t
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
  SELECT  NTILE (4000) OVER (ORDER BY id) AS grp
        , chi_sq_x
   FROM normal_sampling
),
chi_sq_samples AS (
  SELECT  grp AS id
        , SUM(chi_sq_x) AS chi_sq_x_dof12
   FROM grouping_samples
  GROUP BY grp
)
SELECT chi_sq_x_dof12
  FROM chi_sq_samples
);

WITH diff AS (
  SELECT chi_sq_x_dof12 AS x
       , COUNT(chi_sq_x_dof12) OVER() AS n
       , AVG(chi_sq_x_dof12) OVER() AS mean
       , STDDEV_POP(chi_sq_x_dof12) OVER() AS std_p
       , STDDEV(chi_sq_x_dof12) OVER() AS std
    FROM chi_squared_dof12
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
SELECT 'n' AS stats
      , n AS emp_val
      , n AS theo_val
  FROM pop_sk_krt
UNION ALL
SELECT 'mean' AS stats
      , ROUND(mean::NUMERIC,2) AS emp_val
      , 12.0 AS theo_val
  FROM pop_sk_krt
UNION ALL
SELECT 'median' AS stats
      , ROUND(median::NUMERIC,2) AS emp_val
      , ROUND((12.0*POWER((1 - 2/(9*12.0)),3))::NUMERIC,2) AS theo_val
  FROM pop_sk_krt
UNION ALL
SELECT 'sample_std' AS stats
      , ROUND(std,2) AS emp_val
      , ROUND(SQRT(2*12.0)::NUMERIC,2) AS theo_val
  FROM pop_sk_krt
UNION ALL
SELECT 'sample_skw' AS stats
      , ROUND((SQRT(n*(n-1.0))/(n-2.0))*skw,2) AS emp_val
      , ROUND(SQRT(8/12.0)::NUMERIC,2) AS theo_val
  FROM pop_sk_krt
UNION ALL
SELECT 'ex_kurt' AS stats
      , ROUND((n - 1)*((n + 1)*execess_krt + 6)/((n-2)*(n-3)),2) AS emp_val
      , ROUND((12/12.0)::NUMERIC,2) AS theo_val
  FROM pop_sk_krt;
```

```console
stats      | emp_val | theo_val
-----------+---------+----------
n          |    4000 |     4000
mean       |   11.92 |     12.0
median     |   11.25 |    11.35
sample_std |    4.88 |     4.90
sample_skw |    0.81 |     0.82
ex_kurt    |    0.87 |     1.00
```

Let's plot the histogram:


```SQL
WITH chi_squared_cnt AS (
  SELECT chi_sq_x_dof12 AS chi_sq_x
       , COUNT(chi_sq_x_dof12) AS cnt
    FROM chi_squared_dof12
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
       , ROUND((100*(freq/4000.0))::NUMERIC,0) AS prob
       , LPAD('*',ROUND((100*(freq/4000.0))::NUMERIC,0)::INTEGER ,'*') AS freq_plot
  FROM histogram
  ORDER BY id;
```

```console
id |   bin   | freq | prob | freq_plot
---+---------+------+------+-----------
 2 | (1 2]   |    4 |    0 |
 3 | (2 3]   |   20 |    1 | *
 4 | (3 4]   |   49 |    1 | *
 5 | (4 5]   |   99 |    2 | **
 6 | (5 6]   |  154 |    4 | ****
 7 | (6 7]   |  230 |    6 | ******
 8 | (7 8]   |  317 |    8 | ********
 9 | (8 9]   |  353 |    9 | *********
10 | (9 10]  |  348 |    9 | *********
11 | (10 11] |  344 |    9 | *********
12 | (11 12] |  336 |    8 | ********
13 | (12 13] |  304 |    8 | ********
14 | (13 14] |  265 |    7 | *******
15 | (14 15] |  244 |    6 | ******
16 | (15 16] |  185 |    5 | *****
17 | (16 17] |  153 |    4 | ****
18 | (17 18] |  143 |    4 | ****
19 | (18 19] |  105 |    3 | ***
20 | (19 20] |   76 |    2 | **
21 | (20 21] |   59 |    1 | *
22 | (21 22] |   60 |    2 | **
23 | (22 23] |   49 |    1 | *
24 | (23 24] |   35 |    1 | *
25 | (24 25] |   20 |    1 | *
26 | (25 26] |    9 |    0 |
27 | (26 27] |   10 |    0 |
28 | (27 28] |    5 |    0 |
29 | (28 29] |    6 |    0 |
30 | (29 30] |    6 |    0 |
31 | (30 31] |    3 |    0 |
32 | (31 32] |    4 |    0 |
33 | (32 33] |    2 |    0 |
34 | (33 34] |    2 |    0 |
36 | (35 36] |    1 |    0 |
(34 rows)
```
