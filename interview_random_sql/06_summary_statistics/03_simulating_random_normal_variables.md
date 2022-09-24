# Simulating Random Normal Variables

If you’ve ever had to generate sample data in your database, odds are you’ve started with random() or its equivalent. It’s fast and it’s reliable. Unfortunately, it’s also evenly distributed. You’re just as likely to get 0.5 as 0.9. Most real-world data is not like this.

After an even distribution, your most basic distribution of random numbers is a normal distribution. In this section, we’ll show you how to use the [Marsaglia Polar Method](https://epubs.siam.org/doi/10.1137/1006063) to convert random()’s uniform distribution into a normal distribution. Reference [Marsaglia Polar Method](https://www.alanzucconi.com/2015/09/16/how-to-sample-from-a-gaussian-distribution/).

## Two random Numbers are better than One

The Marsaglia method converts a `pair of uniformly distributed random numbers` into a `pair of normally distributed random numbers`.

First, we need a list of random numbers. We’ll use generate_series for brevity.

The Marsaglia method requires numbers between `-1` and `1`. We’ll generate `100,000` of them:

uniform random variables drawn between -1 and 1:

```SQL
WITH numbers AS (
  SELECT  2 * RANDOM() - 1 AS x
        , 2 * RANDOM() - 1 AS y
    FROM GENERATE_SERIES(0, 100000)
),
```

The Marsaglia method is a type of rejection sampling, which is a fancy way of saying that it throws away inputs that don’t fit the distribution.


Since it’s based on polar coordinates, the sum of the squares of the numbers needs to be less than one. This ends up filtering out about (21%) of the data, so make you generate enough numbers at the outset.

```SQL
polar_points AS (
  SELECT  x
        , y
        , x*x + y*y AS s
    FROM numbers
   WHERE x*x + y*y < 1
),
```

Now we know we have the right set of inputs, so we can turn them into normally distributed pairs. We’ll compute the new pairs separately, and then union the lists together to get one long list of normally distributed numbers.

The formulas are straightforward:

```console
    +-             -+ 1/2    +-             -+ 1/2
    |               |        |               |
    |   -2 * ln(s)  |        |    -2 * ln(s) |
x * | ------------- | ,   y* |  ------------ |
    |      s        |        |       s       |
    |               |        |               |
    +-             -+        +-             -+
```

Translating these to SQL, we get:


```SQL
marsaglia AS (
  SELECT x * sqrt((-2 * ln(s))/s) AS n
    FROM polar_points
  UNION
  SELECT y * sqrt((-2 * ln(s))/s) AS n
    FROM polar_points
)
```

## Bringing It All Together

To make a pretty graph of your distribution, combine the previous steps and then bucket and count the numbers (by rounding them) like so:


```SQL
WITH numbers AS (
  SELECT  2 * RANDOM() - 1 AS x
        , 2 * RANDOM() - 1 AS y
    FROM GENERATE_SERIES(0, 100000)
),
polar_points AS (
  SELECT  x
        , y
        , x*x + y*y AS s
    FROM numbers
   WHERE x*x + y*y < 1
),
marsaglia AS (
  SELECT x * sqrt((-2 * ln(s))/s) AS n
    FROM polar_points
  UNION
  SELECT y * sqrt((-2 * ln(s))/s) AS n
    FROM polar_points
),
freq AS (
  SELECT  ROUND(n::NUMERIC,1) AS val
        , COUNT(1) AS cont
    FROM marsaglia
   GROUP BY 1
),
histogram AS (
  SELECT  *
        , ROUND(1000.0*cont/SUM(cont) OVER(),1)::INTEGER AS freq
    FROM freq
)
SELECT  *
      , LPAD('*',freq::INTEGER,'*') AS freq_plot
  FROM histogram
 ORDER BY 1;
```

```console
val  | cont | freq |                freq_plot
------+------+------+------------------------------------------
-4.6 |    1 |    0 |
-4.4 |    1 |    0 |
-4.2 |    1 |    0 |
-4.0 |    3 |    0 |
-3.9 |    3 |    0 |
-3.8 |    8 |    0 |
-3.7 |    4 |    0 |
-3.6 |   10 |    0 |
-3.5 |   14 |    0 |
-3.4 |   21 |    0 |
-3.3 |   22 |    0 |
-3.2 |   38 |    0 |
-3.1 |   53 |    0 |
-3.0 |   67 |    0 |
-2.9 |   96 |    1 | *
-2.8 |  141 |    1 | *
-2.7 |  173 |    1 | *
-2.6 |  193 |    1 | *
-2.5 |  258 |    2 | **
-2.4 |  362 |    2 | **
-2.3 |  458 |    3 | ***
-2.2 |  547 |    4 | ****
-2.1 |  694 |    4 | ****
-2.0 |  845 |    5 | *****
-1.9 | 1079 |    7 | *******
-1.8 | 1246 |    8 | ********
-1.7 | 1429 |    9 | *********
-1.6 | 1777 |   11 | ***********
-1.5 | 2042 |   13 | *************
-1.4 | 2358 |   15 | ***************
-1.3 | 2695 |   17 | *****************
-1.2 | 3050 |   19 | *******************
-1.1 | 3467 |   22 | **********************
-1.0 | 3841 |   24 | ************************
-0.9 | 4144 |   26 | **************************
-0.8 | 4683 |   30 | ******************************
-0.7 | 4959 |   32 | ********************************
-0.6 | 5213 |   33 | *********************************
-0.5 | 5471 |   35 | ***********************************
-0.4 | 5712 |   36 | ************************************
-0.3 | 5886 |   37 | *************************************
-0.2 | 6182 |   39 | ***************************************
-0.1 | 6271 |   40 | ****************************************
 0.0 | 6231 |   40 | ****************************************
 0.1 | 6272 |   40 | ****************************************
 0.2 | 6119 |   39 | ***************************************
 0.3 | 5983 |   38 | **************************************
 0.4 | 5806 |   37 | *************************************
 0.5 | 5487 |   35 | ***********************************
 0.6 | 5209 |   33 | *********************************
 0.7 | 5012 |   32 | ********************************
 0.8 | 4475 |   29 | *****************************
 0.9 | 4139 |   26 | **************************
 1.0 | 3957 |   25 | *************************
 1.1 | 3429 |   22 | **********************
 1.2 | 3096 |   20 | ********************
 1.3 | 2717 |   17 | *****************
 1.4 | 2334 |   15 | ***************
 1.5 | 2034 |   13 | *************
 1.6 | 1743 |   11 | ***********
 1.7 | 1554 |   10 | **********
 1.8 | 1192 |    8 | ********
 1.9 |  937 |    6 | ******
 2.0 |  819 |    5 | *****
 2.1 |  667 |    4 | ****
 2.2 |  560 |    4 | ****
 2.3 |  436 |    3 | ***
 2.4 |  371 |    2 | **
 2.5 |  286 |    2 | **
 2.6 |  205 |    1 | *
 2.7 |  177 |    1 | *
 2.8 |  128 |    1 | *
 2.9 |   93 |    1 | *
 3.0 |   75 |    1 | *
 3.1 |   48 |    0 |
 3.2 |   39 |    0 |
 3.3 |   28 |    0 |
 3.4 |   12 |    0 |
 3.5 |   13 |    0 |
 3.6 |    9 |    0 |
 3.7 |    7 |    0 |
 3.8 |    2 |    0 |
 3.9 |    5 |    0 |
 4.0 |    3 |    0 |
 4.2 |    2 |    0 |
 4.3 |    2 |    0 |
 4.6 |    1 |    0 |
(87 rows)
```

## Summary Statistics

```SQL
WITH numbers AS (
  SELECT  2 * RANDOM() - 1 AS x
        , 2 * RANDOM() - 1 AS y
    FROM GENERATE_SERIES(0, 100000)
),
polar_points AS (
  SELECT  x
        , y
        , x*x + y*y AS s
    FROM numbers
   WHERE x*x + y*y < 1
),
marsaglia AS (
  SELECT x * sqrt((-2 * ln(s))/s) AS n
    FROM polar_points
  UNION
  SELECT y * sqrt((-2 * ln(s))/s) AS n
    FROM polar_points
),
diff AS (
  SELECT n AS x
       , COUNT(n) OVER() AS n
       , AVG(n) OVER() AS mean
       , STDDEV_POP(n) OVER() AS std_p
       , STDDEV(n) OVER() AS std
    FROM marsaglia
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
SELECT  ROUND(median::NUMERIC,2) AS median
      , ROUND(mean::NUMERIC,2) AS mean
      , ROUND(std::NUMERIC,2) AS sample_std
      , ROUND(((SQRT(n*(n-1.0))/(n-2.0))*skw)::NUMERIC,2) AS sample_skeweness
      , ROUND(((n - 1)*((n + 1)*execess_krt + 6)/((n-2)*(n-3)))::NUMERIC,2) AS sample_kurt
  FROM pop_sk_krt;
```

```console
median | mean | sample_std | sample_skeweness | sample_kurt
-------+------+------------+------------------+-------------
  0.00 | 0.00 |       1.00 |             0.00 |        0.01
```

## Mapping to Arbitrary Gaussian Curves

The algorithm described previously provides a way to sample from A normal distribution with `mean=0` and `std=1`. We can transform that into any arbitrary Gaussian (mu,sigma) like this:

```console
           +-             -+ 1/2                  +-             -+ 1/2
           |               |                      |               |
           |   -2 * ln(s)  |                      |    -2 * ln(s) |
mean + x * | ------------- |* sigma ,  mean + y * |  ------------ |* sigma
           |      s        |                      |       s       |
           |               |                      |               |
           +-             -+                      +-             -+
```

Let's try with `mean = 0` and `std = 0.5`.

```SQL
WITH numbers AS (
  SELECT  2 * RANDOM() - 1 AS x
        , 2 * RANDOM() - 1 AS y
    FROM GENERATE_SERIES(0, 100000)
),
polar_points AS (
  SELECT  x
        , y
        , x*x + y*y AS s
    FROM numbers
   WHERE x*x + y*y < 1
),
marsaglia AS (
  SELECT (x * sqrt((-2 * ln(s))/s))*0.5 AS n
    FROM polar_points
  UNION
  SELECT (y * sqrt((-2 * ln(s))/s))*0.5 AS n
    FROM polar_points
),
freq AS (
  SELECT  ROUND(n::NUMERIC,1) AS val
        , COUNT(1) AS cont
    FROM marsaglia
   GROUP BY 1
),
histogram AS (
  SELECT  *
        , ROUND(1000.0*cont/SUM(cont) OVER(),1)::INTEGER AS freq
    FROM freq
)
SELECT  *
      , LPAD('*',freq::INTEGER,'*') AS freq_plot
  FROM histogram
 ORDER BY 1;
```

```console
val  | cont  | freq |                                     freq_plot
-----+-------+------+-----------------------------------------------------------------------------------
-2.1 |     1 |    0 |
-2.0 |     6 |    0 |
-1.9 |    13 |    0 |
-1.8 |    22 |    0 |
-1.7 |    38 |    0 |
-1.6 |    64 |    0 |
-1.5 |   140 |    1 | *
-1.4 |   269 |    2 | **
-1.3 |   431 |    3 | ***
-1.2 |   724 |    5 | *****
-1.1 |  1070 |    7 | *******
-1.0 |  1676 |   11 | ***********
-0.9 |  2491 |   16 | ****************
-0.8 |  3542 |   23 | ***********************
-0.7 |  4692 |   30 | ******************************
-0.6 |  5966 |   38 | **************************************
-0.5 |  7589 |   48 | ************************************************
-0.4 |  9085 |   58 | **********************************************************
-0.3 | 10445 |   67 | *******************************************************************
-0.2 | 11502 |   73 | *************************************************************************
-0.1 | 12353 |   79 | *******************************************************************************
 0.0 | 12652 |   81 | *********************************************************************************
 0.1 | 12208 |   78 | ******************************************************************************
 0.2 | 11528 |   74 | **************************************************************************
 0.3 | 10342 |   66 | ******************************************************************
 0.4 |  8975 |   57 | *********************************************************
 0.5 |  7645 |   49 | *************************************************
 0.6 |  6102 |   39 | ***************************************
 0.7 |  4667 |   30 | ******************************
 0.8 |  3550 |   23 | ***********************
 0.9 |  2485 |   16 | ****************
 1.0 |  1692 |   11 | ***********
 1.1 |  1109 |    7 | *******
 1.2 |   734 |    5 | *****
 1.3 |   415 |    3 | ***
 1.4 |   243 |    2 | **
 1.5 |   130 |    1 | *
 1.6 |    62 |    0 |
 1.7 |    45 |    0 |
 1.8 |    12 |    0 |
 1.9 |     8 |    0 |
 2.0 |     5 |    0 |
 2.1 |     2 |    0 |
 2.3 |     1 |    0 |
 2.4 |     1 |    0 |
```

Let's try with `mean = 0` and `std = 1.5`.

```SQL
WITH numbers AS (
  SELECT  2 * RANDOM() - 1 AS x
        , 2 * RANDOM() - 1 AS y
    FROM GENERATE_SERIES(0, 100000)
),
polar_points AS (
  SELECT  x
        , y
        , x*x + y*y AS s
    FROM numbers
   WHERE x*x + y*y < 1
),
marsaglia AS (
  SELECT (x * sqrt((-2 * ln(s))/s))*1.5 AS n
    FROM polar_points
  UNION
  SELECT (y * sqrt((-2 * ln(s))/s))*1.5 AS n
    FROM polar_points
),
freq AS (
  SELECT  ROUND(n::NUMERIC,1) AS val
        , COUNT(1) AS cont
    FROM marsaglia
   GROUP BY 1
),
histogram AS (
  SELECT  *
        , ROUND(1000.0*cont/SUM(cont) OVER(),1)::INTEGER AS freq
    FROM freq
)
SELECT  *
      , LPAD('*',freq::INTEGER,'*') AS freq_plot
  FROM histogram
 ORDER BY 1;
```

```console
val  | cont | freq |          freq_plot
-----+------+------+-----------------------------
-6.5 |    1 |    0 |
-6.4 |    1 |    0 |
-6.3 |    1 |    0 |
-6.2 |    3 |    0 |
-6.1 |    1 |    0 |
-6.0 |    2 |    0 |
-5.9 |    1 |    0 |
-5.8 |    3 |    0 |
-5.7 |    4 |    0 |
-5.6 |    4 |    0 |
-5.5 |    5 |    0 |
-5.4 |    6 |    0 |
-5.3 |    8 |    0 |
-5.2 |   11 |    0 |
-5.1 |   20 |    0 |
-5.0 |   13 |    0 |
-4.9 |   19 |    0 |
-4.8 |   27 |    0 |
-4.7 |   23 |    0 |
-4.6 |   37 |    0 |
-4.5 |   47 |    0 |
-4.4 |   66 |    0 |
-4.3 |   71 |    1 | *
-4.2 |   87 |    1 | *
-4.1 |   95 |    1 | *
-4.0 |  129 |    1 | *
-3.9 |  109 |    1 | *
-3.8 |  188 |    1 | *
-3.7 |  206 |    1 | *
-3.6 |  216 |    1 | *
-3.5 |  290 |    2 | **
-3.4 |  360 |    2 | **
-3.3 |  353 |    2 | **
-3.2 |  436 |    3 | ***
-3.1 |  485 |    3 | ***
-3.0 |  550 |    4 | ****
-2.9 |  630 |    4 | ****
-2.8 |  750 |    5 | *****
-2.7 |  777 |    5 | *****
-2.6 |  967 |    6 | ******
-2.5 | 1036 |    7 | *******
-2.4 | 1150 |    7 | *******
-2.3 | 1285 |    8 | ********
-2.2 | 1396 |    9 | *********
-2.1 | 1575 |   10 | **********
-2.0 | 1682 |   11 | ***********
-1.9 | 1919 |   12 | ************
-1.8 | 2064 |   13 | *************
-1.7 | 2245 |   14 | **************
-1.6 | 2320 |   15 | ***************
-1.5 | 2416 |   15 | ***************
-1.4 | 2668 |   17 | *****************
-1.3 | 2786 |   18 | ******************
-1.2 | 2957 |   19 | *******************
-1.1 | 3275 |   21 | *********************
-1.0 | 3387 |   22 | **********************
-0.9 | 3464 |   22 | **********************
-0.8 | 3545 |   23 | ***********************
-0.7 | 3708 |   24 | ************************
-0.6 | 3855 |   25 | *************************
-0.5 | 3894 |   25 | *************************
-0.4 | 4040 |   26 | **************************
-0.3 | 4034 |   26 | **************************
-0.2 | 4275 |   27 | ***************************
-0.1 | 4186 |   27 | ***************************
 0.0 | 4202 |   27 | ***************************
 0.1 | 4207 |   27 | ***************************
 0.2 | 4177 |   27 | ***************************
 0.3 | 4112 |   26 | **************************
 0.4 | 4188 |   27 | ***************************
 0.5 | 4068 |   26 | **************************
 0.6 | 3859 |   25 | *************************
 0.7 | 3778 |   24 | ************************
 0.8 | 3632 |   23 | ***********************
 0.9 | 3421 |   22 | **********************
 1.0 | 3496 |   22 | **********************
 1.1 | 3033 |   19 | *******************
 1.2 | 2961 |   19 | *******************
 1.3 | 2841 |   18 | ******************
 1.4 | 2623 |   17 | *****************
 1.5 | 2550 |   16 | ****************
 1.6 | 2307 |   15 | ***************
 1.7 | 2156 |   14 | **************
 1.8 | 2077 |   13 | *************
 1.9 | 1823 |   12 | ************
 2.0 | 1713 |   11 | ***********
 2.1 | 1571 |   10 | **********
 2.2 | 1415 |    9 | *********
 2.3 | 1251 |    8 | ********
 2.4 | 1215 |    8 | ********
 2.5 | 1033 |    7 | *******
 2.6 |  935 |    6 | ******
 2.7 |  870 |    6 | ******
 2.8 |  737 |    5 | *****
 2.9 |  641 |    4 | ****
 3.0 |  548 |    4 | ****
 3.1 |  478 |    3 | ***
 3.2 |  449 |    3 | ***
 3.3 |  398 |    3 | ***
 3.4 |  355 |    2 | **
 3.5 |  267 |    2 | **
 3.6 |  231 |    2 | **
 3.7 |  184 |    1 | *
 3.8 |  157 |    1 | *
 3.9 |  157 |    1 | *
 4.0 |  103 |    1 | *
 4.1 |   87 |    1 | *
 4.2 |   76 |    1 | *
 4.3 |   59 |    0 |
 4.4 |   65 |    0 |
 4.5 |   42 |    0 |
 4.6 |   45 |    0 |
 4.7 |   28 |    0 |
 4.8 |   26 |    0 |
 4.9 |   23 |    0 |
 5.0 |   12 |    0 |
 5.1 |    8 |    0 |
 5.2 |   10 |    0 |
 5.3 |    6 |    0 |
 5.4 |    6 |    0 |
 5.5 |    3 |    0 |
 5.6 |    6 |    0 |
 5.7 |    7 |    0 |
 5.8 |    3 |    0 |
 5.9 |    4 |    0 |
 6.1 |    1 |    0 |
 6.2 |    1 |    0 |
 6.5 |    1 |    0 |
 7.3 |    2 |    0 |
```

Let's try with `mean = 100` and `std = 0.25`.

```SQL
WITH numbers AS (
  SELECT  2 * RANDOM() - 1 AS x
        , 2 * RANDOM() - 1 AS y
    FROM GENERATE_SERIES(0, 100000)
),
polar_points AS (
  SELECT  x
        , y
        , x*x + y*y AS s
    FROM numbers
   WHERE x*x + y*y < 1
),
marsaglia AS (
  SELECT 100 + (x * sqrt((-2 * ln(s))/s))*0.25 AS n
    FROM polar_points
  UNION
  SELECT 100 + (y * sqrt((-2 * ln(s))/s))*0.25 AS n
    FROM polar_points
),
freq AS (
  SELECT  ROUND(n::NUMERIC,1) AS val
        , COUNT(1) AS cont
    FROM marsaglia
   GROUP BY 1
),
histogram AS (
  SELECT  *
        , ROUND(1000.0*cont/SUM(cont) OVER(),1)::INTEGER AS freq
    FROM freq
)
SELECT  *
      , LPAD('*',freq::INTEGER,'*') AS freq_plot
  FROM histogram
 ORDER BY 1;
```

```console
val  | cont  | freq |                                                                            freq_plot
------+-------+------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------
98.9 |     2 |    0 |
99.0 |     8 |    0 |
99.1 |    36 |    0 |
99.2 |   163 |    1 | *
99.3 |   532 |    3 | ***
99.4 |  1464 |    9 | *********
99.5 |  3455 |   22 | **********************
99.6 |  7033 |   45 | *********************************************
99.7 | 12223 |   78 | ******************************************************************************
99.8 | 17925 |  114 | ******************************************************************************************************************
99.9 | 22961 |  146 | **************************************************************************************************************************************************
100.0 | 24912 |  159 | ***************************************************************************************************************************************************************
100.1 | 23035 |  147 | ***************************************************************************************************************************************************
100.2 | 18310 |  117 | *********************************************************************************************************************
100.3 | 12344 |   79 | *******************************************************************************
100.4 |  6962 |   44 | ********************************************
100.5 |  3496 |   22 | **********************
100.6 |  1433 |    9 | *********
100.7 |   527 |    3 | ***
100.8 |   151 |    1 | *
100.9 |    47 |    0 |
101.0 |     7 |    0 |
101.1 |     4 |    0 |
```
