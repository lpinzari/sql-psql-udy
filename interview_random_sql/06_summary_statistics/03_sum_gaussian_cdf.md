# Integrating the Gaussian Distribution

In this lesson we'll plot the gaussian distribution:

```console    
                                +-              -+
                                |  (x - mu)^(2)  |
                              - | -------------- |
                  1             |  2 * sigma^(2) |
                                +-              -+
f(x) = ------------------- * e
        sigma * SQRT(2*pi)


N(mu,sigma)     mu = Mean,   sigma = standard deviation         
```

We'll be using the `gaussian` function. The function has been saved as [gaussian](./gaussian.sql). The gaussian function takes three arguments:

- `gaussian(x,mu,sigma)`.

To calculate the frequency in each bin of the distribution we'll apply the [midpoint integration rule](https://openstax.org/books/calculus-volume-2).

```SQL
WITH RECURSIVE gauss_pdf AS (
  SELECT  '[-3.25  -3.0)' AS class
        , -3.0 AS z
        , gaussian(-3.25 + 0.125,0,1)*0.25 AS prb
   UNION ALL
  SELECT CASE WHEN z = 3.0
              THEN '(3.0  3.25]'
              WHEN z < 0
              THEN  '[' || z::TEXT || '  ' || (z + 0.25)::TEXT || ')'
              ELSE  '(' || z::TEXT || '  ' || (z + 0.25)::TEXT || ']'
         END AS class
        , z + 0.25 AS z
        , gaussian(z + 0.125,0,1)*0.25 AS prb
    FROM gauss_pdf
   WHERE z <= 3.0
),
g_pdf AS (
  SELECT  class
        , z
        , prb
        , ROUND((1000.0*prb)::INTEGER,1)::INTEGER AS freq
    FROM gauss_pdf
)
SELECT  *
      , LPAD('*',freq::INTEGER,'*') AS freq_plot
  FROM g_pdf
 ORDER BY z;
```


```console
class      |   z   |         prb          | freq |                                              freq_plot
----------------+-------+----------------------+------+-----------------------------------------------------------------------------------------------------
[-3.25  -3.0)  |  -3.0 | 0.000755564508799689 |    1 | *
[-3.0  -2.75)  | -2.75 |  0.00159953007768089 |    2 | **
[-2.75  -2.50) | -2.50 |  0.00318104539920786 |    3 | ***
[-2.50  -2.25) | -2.25 |  0.00594297520747845 |    6 | ******
[-2.25  -2.00) | -2.00 |   0.0104302463140847 |   10 | **********
[-2.00  -1.75) | -1.75 |    0.017196568956673 |   17 | *****************
[-1.75  -1.50) | -1.50 |   0.0266345670326463 |   27 | ***************************
[-1.50  -1.25) | -1.25 |   0.0387530663645733 |   39 | ***************************************
[-1.25  -1.00) | -1.00 |   0.0529691614439249 |   53 | *****************************************************
[-1.00  -0.75) | -0.75 |   0.0680137495946359 |   68 | ********************************************************************
[-0.75  -0.50) | -0.50 |   0.0820402421375938 |   82 | **********************************************************************************
[-0.50  -0.25) | -0.25 |   0.0929637734674422 |   93 | *********************************************************************************************
[-0.25  0.00)  |  0.00 |   0.0989594217361874 |   99 | ***************************************************************************************************
(0.00  0.25]   |  0.25 |   0.0989594217361874 |   99 | ***************************************************************************************************
(0.25  0.50]   |  0.50 |   0.0929637734674422 |   93 | *********************************************************************************************
(0.50  0.75]   |  0.75 |   0.0820402421375938 |   82 | **********************************************************************************
(0.75  1.00]   |  1.00 |   0.0680137495946359 |   68 | ********************************************************************
(1.00  1.25]   |  1.25 |   0.0529691614439249 |   53 | *****************************************************
(1.25  1.50]   |  1.50 |   0.0387530663645733 |   39 | ***************************************
(1.50  1.75]   |  1.75 |   0.0266345670326463 |   27 | ***************************
(1.75  2.00]   |  2.00 |    0.017196568956673 |   17 | *****************
(2.00  2.25]   |  2.25 |   0.0104302463140847 |   10 | **********
(2.25  2.50]   |  2.50 |  0.00594297520747845 |    6 | ******
(2.50  2.75]   |  2.75 |  0.00318104539920786 |    3 | ***
(2.75  3.00]   |  3.00 |  0.00159953007768089 |    2 | **
(3.0  3.25]    |  3.25 | 0.000755564508799689 |    1 | *
(26 rows)
```

Let's increase the number of bins and reduce the width of each bin.

```SQL
WITH RECURSIVE gauss_pdf AS (
  SELECT  '[-4.7  -4.6)' AS class
        , -4.6 AS z
        , gaussian(-4.7 + 0.05,0,1)*0.1 AS prb
   UNION ALL
  SELECT CASE WHEN z = 4.6
              THEN '(4.6  4.7]'
              WHEN z < 0
              THEN  '[' || z::TEXT || '  ' || (z + 0.1)::TEXT || ')'
              ELSE  '(' || z::TEXT || '  ' || (z + 0.1)::TEXT || ']'
         END AS class
        , z + 0.1 AS z
        , gaussian(z + 0.05,0,1)*0.1 AS prb
    FROM gauss_pdf
   WHERE z <= 4.6
),
g_pdf AS (
  SELECT  class
        , z
        , prb
        , ROUND((1000.0*prb)::INTEGER,1)::INTEGER AS freq
    FROM gauss_pdf
)
SELECT  class
      , z
      , freq
      , LPAD('*',freq::INTEGER,'*') AS freq_plot
  FROM g_pdf
 ORDER BY z;
```

```console
class        |  z   | freq |                freq_plot
-------------+------+------+------------------------------------------
[-4.7  -4.6) | -4.6 |    0 |
[-4.6  -4.5) | -4.5 |    0 |
[-4.5  -4.4) | -4.4 |    0 |
[-4.4  -4.3) | -4.3 |    0 |
[-4.3  -4.2) | -4.2 |    0 |
[-4.2  -4.1) | -4.1 |    0 |
[-4.1  -4.0) | -4.0 |    0 |
[-4.0  -3.9) | -3.9 |    0 |
[-3.9  -3.8) | -3.8 |    0 |
[-3.8  -3.7) | -3.7 |    0 |
[-3.7  -3.6) | -3.6 |    0 |
[-3.6  -3.5) | -3.5 |    0 |
[-3.5  -3.4) | -3.4 |    0 |
[-3.4  -3.3) | -3.3 |    0 |
[-3.3  -3.2) | -3.2 |    0 |
[-3.2  -3.1) | -3.1 |    0 |
[-3.1  -3.0) | -3.0 |    0 |
[-3.0  -2.9) | -2.9 |    1 | *
[-2.9  -2.8) | -2.8 |    1 | *
[-2.8  -2.7) | -2.7 |    1 | *
[-2.7  -2.6) | -2.6 |    1 | *
[-2.6  -2.5) | -2.5 |    2 | **
[-2.5  -2.4) | -2.4 |    2 | **
[-2.4  -2.3) | -2.3 |    3 | ***
[-2.3  -2.2) | -2.2 |    3 | ***
[-2.2  -2.1) | -2.1 |    4 | ****
[-2.1  -2.0) | -2.0 |    5 | *****
[-2.0  -1.9) | -1.9 |    6 | ******
[-1.9  -1.8) | -1.8 |    7 | *******
[-1.8  -1.7) | -1.7 |    9 | *********
[-1.7  -1.6) | -1.6 |   10 | **********
[-1.6  -1.5) | -1.5 |   12 | ************
[-1.5  -1.4) | -1.4 |   14 | **************
[-1.4  -1.3) | -1.3 |   16 | ****************
[-1.3  -1.2) | -1.2 |   18 | ******************
[-1.2  -1.1) | -1.1 |   21 | *********************
[-1.1  -1.0) | -1.0 |   23 | ***********************
[-1.0  -0.9) | -0.9 |   25 | *************************
[-0.9  -0.8) | -0.8 |   28 | ****************************
[-0.8  -0.7) | -0.7 |   30 | ******************************
[-0.7  -0.6) | -0.6 |   32 | ********************************
[-0.6  -0.5) | -0.5 |   34 | **********************************
[-0.5  -0.4) | -0.4 |   36 | ************************************
[-0.4  -0.3) | -0.3 |   38 | **************************************
[-0.3  -0.2) | -0.2 |   39 | ***************************************
[-0.2  -0.1) | -0.1 |   39 | ***************************************
[-0.1  0.0)  |  0.0 |   40 | ****************************************
(0.0  0.1]   |  0.1 |   40 | ****************************************
(0.1  0.2]   |  0.2 |   39 | ***************************************
(0.2  0.3]   |  0.3 |   39 | ***************************************
(0.3  0.4]   |  0.4 |   38 | **************************************
(0.4  0.5]   |  0.5 |   36 | ************************************
(0.5  0.6]   |  0.6 |   34 | **********************************
(0.6  0.7]   |  0.7 |   32 | ********************************
(0.7  0.8]   |  0.8 |   30 | ******************************
(0.8  0.9]   |  0.9 |   28 | ****************************
(0.9  1.0]   |  1.0 |   25 | *************************
(1.0  1.1]   |  1.1 |   23 | ***********************
(1.1  1.2]   |  1.2 |   21 | *********************
(1.2  1.3]   |  1.3 |   18 | ******************
(1.3  1.4]   |  1.4 |   16 | ****************
(1.4  1.5]   |  1.5 |   14 | **************
(1.5  1.6]   |  1.6 |   12 | ************
(1.6  1.7]   |  1.7 |   10 | **********
(1.7  1.8]   |  1.8 |    9 | *********
(1.8  1.9]   |  1.9 |    7 | *******
(1.9  2.0]   |  2.0 |    6 | ******
(2.0  2.1]   |  2.1 |    5 | *****
(2.1  2.2]   |  2.2 |    4 | ****
(2.2  2.3]   |  2.3 |    3 | ***
(2.3  2.4]   |  2.4 |    3 | ***
(2.4  2.5]   |  2.5 |    2 | **
(2.5  2.6]   |  2.6 |    2 | **
(2.6  2.7]   |  2.7 |    1 | *
(2.7  2.8]   |  2.8 |    1 | *
(2.8  2.9]   |  2.9 |    1 | *
(2.9  3.0]   |  3.0 |    1 | *
(3.0  3.1]   |  3.1 |    0 |
(3.1  3.2]   |  3.2 |    0 |
(3.2  3.3]   |  3.3 |    0 |
(3.3  3.4]   |  3.4 |    0 |
(3.4  3.5]   |  3.5 |    0 |
(3.5  3.6]   |  3.6 |    0 |
(3.6  3.7]   |  3.7 |    0 |
(3.7  3.8]   |  3.8 |    0 |
(3.8  3.9]   |  3.9 |    0 |
(3.9  4.0]   |  4.0 |    0 |
(4.0  4.1]   |  4.1 |    0 |
(4.1  4.2]   |  4.2 |    0 |
(4.2  4.3]   |  4.3 |    0 |
(4.3  4.4]   |  4.4 |    0 |
(4.4  4.5]   |  4.5 |    0 |
(4.5  4.6]   |  4.6 |    0 |
(4.6  4.7]   |  4.7 |    0 |
(94 rows)
```

Let's increase the standard deviation of the distribution to `3`.

```SQL
WITH RECURSIVE gauss_pdf AS (
  SELECT  '[-7.0  -6.9)' AS class
        , -6.9 AS z
        , gaussian(-7.0 + 0.05,0,3)*0.1 AS prb
   UNION ALL
  SELECT CASE WHEN z = 6.9
              THEN '(6.9  7.0]'
              WHEN z < 0
              THEN  '[' || z::TEXT || '  ' || (z + 0.1)::TEXT || ')'
              ELSE  '(' || z::TEXT || '  ' || (z + 0.1)::TEXT || ']'
         END AS class
        , z + 0.1 AS z
        , gaussian(z + 0.05,0,3)*0.1 AS prb
    FROM gauss_pdf
   WHERE z <= 6.9
),
g_pdf AS (
  SELECT  class
        , z
        , prb
        , ROUND((1000.0*prb)::INTEGER,1)::INTEGER AS freq
    FROM gauss_pdf
)
SELECT  class
      , z
      , freq
      , LPAD('*',freq::INTEGER,'*') AS freq_plot
  FROM g_pdf
 ORDER BY z;
```

```console
class     |  z   | freq |   freq_plot
--------------+------+------+---------------
[-7.0  -6.9) | -6.9 |    1 | *
[-6.9  -6.8) | -6.8 |    1 | *
[-6.8  -6.7) | -6.7 |    1 | *
[-6.7  -6.6) | -6.6 |    1 | *
[-6.6  -6.5) | -6.5 |    1 | *
[-6.5  -6.4) | -6.4 |    1 | *
[-6.4  -6.3) | -6.3 |    1 | *
[-6.3  -6.2) | -6.2 |    2 | **
[-6.2  -6.1) | -6.1 |    2 | **
[-6.1  -6.0) | -6.0 |    2 | **
[-6.0  -5.9) | -5.9 |    2 | **
[-5.9  -5.8) | -5.8 |    2 | **
[-5.8  -5.7) | -5.7 |    2 | **
[-5.7  -5.6) | -5.6 |    2 | **
[-5.6  -5.5) | -5.5 |    2 | **
[-5.5  -5.4) | -5.4 |    3 | ***
[-5.4  -5.3) | -5.3 |    3 | ***
[-5.3  -5.2) | -5.2 |    3 | ***
[-5.2  -5.1) | -5.1 |    3 | ***
[-5.1  -5.0) | -5.0 |    3 | ***
[-5.0  -4.9) | -4.9 |    3 | ***
[-4.9  -4.8) | -4.8 |    4 | ****
[-4.8  -4.7) | -4.7 |    4 | ****
[-4.7  -4.6) | -4.6 |    4 | ****
[-4.6  -4.5) | -4.5 |    4 | ****
[-4.5  -4.4) | -4.4 |    4 | ****
[-4.4  -4.3) | -4.3 |    5 | *****
[-4.3  -4.2) | -4.2 |    5 | *****
[-4.2  -4.1) | -4.1 |    5 | *****
[-4.1  -4.0) | -4.0 |    5 | *****
[-4.0  -3.9) | -3.9 |    6 | ******
[-3.9  -3.8) | -3.8 |    6 | ******
[-3.8  -3.7) | -3.7 |    6 | ******
[-3.7  -3.6) | -3.6 |    6 | ******
[-3.6  -3.5) | -3.5 |    7 | *******
[-3.5  -3.4) | -3.4 |    7 | *******
[-3.4  -3.3) | -3.3 |    7 | *******
[-3.3  -3.2) | -3.2 |    7 | *******
[-3.2  -3.1) | -3.1 |    8 | ********
[-3.1  -3.0) | -3.0 |    8 | ********
[-3.0  -2.9) | -2.9 |    8 | ********
[-2.9  -2.8) | -2.8 |    8 | ********
[-2.8  -2.7) | -2.7 |    9 | *********
[-2.7  -2.6) | -2.6 |    9 | *********
[-2.6  -2.5) | -2.5 |    9 | *********
[-2.5  -2.4) | -2.4 |   10 | **********
[-2.4  -2.3) | -2.3 |   10 | **********
[-2.3  -2.2) | -2.2 |   10 | **********
[-2.2  -2.1) | -2.1 |   10 | **********
[-2.1  -2.0) | -2.0 |   11 | ***********
[-2.0  -1.9) | -1.9 |   11 | ***********
[-1.9  -1.8) | -1.8 |   11 | ***********
[-1.8  -1.7) | -1.7 |   11 | ***********
[-1.7  -1.6) | -1.6 |   11 | ***********
[-1.6  -1.5) | -1.5 |   12 | ************
[-1.5  -1.4) | -1.4 |   12 | ************
[-1.4  -1.3) | -1.3 |   12 | ************
[-1.3  -1.2) | -1.2 |   12 | ************
[-1.2  -1.1) | -1.1 |   12 | ************
[-1.1  -1.0) | -1.0 |   13 | *************
[-1.0  -0.9) | -0.9 |   13 | *************
[-0.9  -0.8) | -0.8 |   13 | *************
[-0.8  -0.7) | -0.7 |   13 | *************
[-0.7  -0.6) | -0.6 |   13 | *************
[-0.6  -0.5) | -0.5 |   13 | *************
[-0.5  -0.4) | -0.4 |   13 | *************
[-0.4  -0.3) | -0.3 |   13 | *************
[-0.3  -0.2) | -0.2 |   13 | *************
[-0.2  -0.1) | -0.1 |   13 | *************
[-0.1  0.0)  |  0.0 |   13 | *************
(0.0  0.1]   |  0.1 |   13 | *************
(0.1  0.2]   |  0.2 |   13 | *************
(0.2  0.3]   |  0.3 |   13 | *************
(0.3  0.4]   |  0.4 |   13 | *************
(0.4  0.5]   |  0.5 |   13 | *************
(0.5  0.6]   |  0.6 |   13 | *************
(0.6  0.7]   |  0.7 |   13 | *************
(0.7  0.8]   |  0.8 |   13 | *************
(0.8  0.9]   |  0.9 |   13 | *************
(0.9  1.0]   |  1.0 |   13 | *************
(1.0  1.1]   |  1.1 |   13 | *************
(1.1  1.2]   |  1.2 |   12 | ************
(1.2  1.3]   |  1.3 |   12 | ************
(1.3  1.4]   |  1.4 |   12 | ************
(1.4  1.5]   |  1.5 |   12 | ************
(1.5  1.6]   |  1.6 |   12 | ************
(1.6  1.7]   |  1.7 |   11 | ***********
(1.7  1.8]   |  1.8 |   11 | ***********
(1.8  1.9]   |  1.9 |   11 | ***********
(1.9  2.0]   |  2.0 |   11 | ***********
(2.0  2.1]   |  2.1 |   11 | ***********
(2.1  2.2]   |  2.2 |   10 | **********
(2.2  2.3]   |  2.3 |   10 | **********
(2.3  2.4]   |  2.4 |   10 | **********
(2.4  2.5]   |  2.5 |   10 | **********
(2.5  2.6]   |  2.6 |    9 | *********
(2.6  2.7]   |  2.7 |    9 | *********
(2.7  2.8]   |  2.8 |    9 | *********
(2.8  2.9]   |  2.9 |    8 | ********
(2.9  3.0]   |  3.0 |    8 | ********
(3.0  3.1]   |  3.1 |    8 | ********
(3.1  3.2]   |  3.2 |    8 | ********
(3.2  3.3]   |  3.3 |    7 | *******
(3.3  3.4]   |  3.4 |    7 | *******
(3.4  3.5]   |  3.5 |    7 | *******
(3.5  3.6]   |  3.6 |    7 | *******
(3.6  3.7]   |  3.7 |    6 | ******
(3.7  3.8]   |  3.8 |    6 | ******
(3.8  3.9]   |  3.9 |    6 | ******
(3.9  4.0]   |  4.0 |    6 | ******
(4.0  4.1]   |  4.1 |    5 | *****
(4.1  4.2]   |  4.2 |    5 | *****
(4.2  4.3]   |  4.3 |    5 | *****
(4.3  4.4]   |  4.4 |    5 | *****
(4.4  4.5]   |  4.5 |    4 | ****
(4.5  4.6]   |  4.6 |    4 | ****
(4.6  4.7]   |  4.7 |    4 | ****
(4.7  4.8]   |  4.8 |    4 | ****
(4.8  4.9]   |  4.9 |    4 | ****
(4.9  5.0]   |  5.0 |    3 | ***
(5.0  5.1]   |  5.1 |    3 | ***
(5.1  5.2]   |  5.2 |    3 | ***
(5.2  5.3]   |  5.3 |    3 | ***
(5.3  5.4]   |  5.4 |    3 | ***
(5.4  5.5]   |  5.5 |    3 | ***
(5.5  5.6]   |  5.6 |    2 | **
(5.6  5.7]   |  5.7 |    2 | **
(5.7  5.8]   |  5.8 |    2 | **
(5.8  5.9]   |  5.9 |    2 | **
(5.9  6.0]   |  6.0 |    2 | **
(6.0  6.1]   |  6.1 |    2 | **
(6.1  6.2]   |  6.2 |    2 | **
(6.2  6.3]   |  6.3 |    2 | **
(6.3  6.4]   |  6.4 |    1 | *
(6.4  6.5]   |  6.5 |    1 | *
(6.5  6.6]   |  6.6 |    1 | *
(6.6  6.7]   |  6.7 |    1 | *
(6.7  6.8]   |  6.8 |    1 | *
(6.8  6.9]   |  6.9 |    1 | *
(6.9  7.0]   |  7.0 |    1 | *
(140 rows)
```

# Generating Standard Normal variables using the Gaussian Distribution

```SQL
CREATE VIEW v2 AS (
WITH RECURSIVE gauss_pdf AS (
  SELECT  '[-4.7  -4.6)' AS class
        , -4.6 AS z
        , gaussian(-4.7 + 0.05,0,1)*0.1 AS prb
   UNION ALL
  SELECT CASE WHEN z = 4.6
              THEN '(4.6  4.7]'
              WHEN z < 0
              THEN  '[' || z::TEXT || '  ' || (z + 0.1)::TEXT || ')'
              ELSE  '(' || z::TEXT || '  ' || (z + 0.1)::TEXT || ']'
         END AS class
        , z + 0.1 AS z
        , gaussian(z + 0.05,0,1)*0.1 AS prb
    FROM gauss_pdf
   WHERE z <= 4.6
),
g_pdf AS (
  SELECT  class
        , z
        , prb
        , ROUND((1000.0*prb)::INTEGER,1)::INTEGER AS freq
    FROM gauss_pdf
)
  SELECT  ROW_NUMBER() OVER(ORDER BY z) + 115 - 30 AS x
        , freq
    FROM g_pdf
   WHERE freq > 0
);
SELECT  *
      , LPAD('*',freq::INTEGER,'*') AS freq_plot
  FROM v2;
```

```console
x   | freq |                freq_plot
----+------+------------------------------------------
86 |    1  | *
87 |    1  | *
88 |    1  | *
89 |    1  | *
90 |    2  | **
91 |    2  | **
92 |    3  | ***
93 |    3  | ***
94 |    4  | ****
95 |    5  | *****
96 |    6  | ******
97 |    7  | *******
98 |    9  | *********
99 |   10  | **********
100 |   12 | ************
101 |   14 | **************
102 |   16 | ****************
103 |   18 | ******************
104 |   21 | *********************
105 |   23 | ***********************
106 |   25 | *************************
107 |   28 | ****************************
108 |   30 | ******************************
109 |   32 | ********************************
110 |   34 | **********************************
111 |   36 | ************************************
112 |   38 | **************************************
113 |   39 | ***************************************
114 |   39 | ***************************************
115 |   40 | ****************************************
116 |   40 | ****************************************
117 |   39 | ***************************************
118 |   39 | ***************************************
119 |   38 | **************************************
120 |   36 | ************************************
121 |   34 | **********************************
122 |   32 | ********************************
123 |   30 | ******************************
124 |   28 | ****************************
125 |   25 | *************************
126 |   23 | ***********************
127 |   21 | *********************
128 |   18 | ******************
129 |   16 | ****************
130 |   14 | **************
131 |   12 | ************
132 |   10 | **********
133 |    9 | *********
134 |    7 | *******
135 |    6 | ******
136 |    5 | *****
137 |    4 | ****
138 |    3 | ***
139 |    3 | ***
140 |    2 | **
141 |    2 | **
142 |    1 | *
143 |    1 | *
144 |    1 | *
145 |    1 | *
```

Let's create the samples.

```SQL
WITH RECURSIVE duplicate_val AS (
  SELECT *
    FROM v2
   UNION ALL
  SELECT v.x AS x
        , v.freq - 1 AS freq
    FROM duplicate_val v
   INNER JOIN v2 w
      ON v.x = w.x
   WHERE v.freq > 1
)
SELECT *
  FROM duplicate_val
  ORDER BY x, freq;
```

```console
x  | freq
-----+------
86 |    1
87 |    1
88 |    1
89 |    1
90 |    1
90 |    2
91 |    1
91 |    2
92 |    1
92 |    2
92 |    3
93 |    1
93 |    2
93 |    3
94 |    1
94 |    2
94 |    3
94 |    4
95 |    1
95 |    2
95 |    3
95 |    4
95 |    5
```

```SQL
WITH RECURSIVE duplicate_val AS (
  SELECT *
    FROM v2
   UNION ALL
  SELECT v.x AS x
        , v.freq - 1 AS freq
    FROM duplicate_val v
   INNER JOIN v2 w
      ON v.x = w.x
   WHERE v.freq > 1
),
diff AS (
  SELECT x
       , COUNT(x) OVER() AS n
       , AVG(x) OVER() AS mean
       , STDDEV_POP(x) OVER() AS std_p
       , STDDEV(x) OVER() AS std
    FROM duplicate_val
),
comp_sk_krt AS (
  SELECT n
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
        , mean
        , std
        , num_sk/den_sk AS skw
        , num_krt/den_krt - 3 AS execess_krt
    FROM comp_sk_krt
)
SELECT  ROUND(mean,2) AS mean
      , ROUND(std,2) AS sample_std
      , ROUND((SQRT(n*(n-1.0))/(n-2.0))*skw,2) AS sample_skeweness
      , ROUND((n - 1)*((n + 1)*execess_krt + 6)/((n-2)*(n-3)),2) AS sample_kurt
  FROM pop_sk_krt;
```

```console
mean   | sample_std | sample_skeweness | sample_kurt
-------+------------+------------------+-------------
115.50 |       9.97 |             0.00 |       -0.11
```

Let's calculate the z-score of the normal distribution:

```SQL
WITH RECURSIVE duplicate_val AS (
  SELECT *
    FROM v2
   UNION ALL
  SELECT v.x AS x
        , v.freq - 1 AS freq
    FROM duplicate_val v
   INNER JOIN v2 w
      ON v.x = w.x
   WHERE v.freq > 1
),
mean_std AS (
  SELECT ROUND(AVG(x),2) AS mu
       , ROUND(STDDEV(x),2) AS sigma
    FROM duplicate_val
),
standardz AS (
  SELECT  x
        , (x - mu)/sigma AS zscore
    FROM duplicate_val v, mean_std m
),
freq AS (
  SELECT  ROUND(zscore::NUMERIC,1) AS zscore
        , COUNT(1) AS cont
    FROM standardz
   GROUP BY 1
),
histogram AS (
  SELECT  *
        , ROUND(1000.0*cont/SUM(cont) OVER(),1)::INTEGER AS freq
    FROM freq
)
SELECT  *
      , SUM(freq) OVER(ORDER BY zscore)
      , LPAD('*',freq::INTEGER,'*') AS freq_plot
  FROM histogram
 ORDER BY 1;
```

```console
zscore | cont | freq | sum  |                freq_plot
-------+------+------+------+------------------------------------------
  -3.0 |    1 |    1 |    1 | *
  -2.9 |    1 |    1 |    2 | *
  -2.8 |    1 |    1 |    3 | *
  -2.7 |    1 |    1 |    4 | *
  -2.6 |    2 |    2 |    6 | **
  -2.5 |    2 |    2 |    8 | **
  -2.4 |    3 |    3 |   11 | ***
  -2.3 |    3 |    3 |   14 | ***
  -2.2 |    4 |    4 |   18 | ****
  -2.1 |    5 |    5 |   23 | *****
  -2.0 |    6 |    6 |   29 | ******
  -1.9 |    7 |    7 |   36 | *******
  -1.8 |    9 |    9 |   45 | *********
  -1.7 |   10 |   10 |   55 | **********
  -1.6 |   12 |   12 |   67 | ************
  -1.5 |   14 |   14 |   81 | **************
  -1.4 |   16 |   16 |   97 | ****************
  -1.3 |   18 |   18 |  115 | ******************
  -1.2 |   21 |   21 |  136 | *********************
  -1.1 |   23 |   23 |  159 | ***********************
  -1.0 |   25 |   25 |  184 | *************************
  -0.9 |   28 |   28 |  212 | ****************************
  -0.8 |   30 |   30 |  242 | ******************************
  -0.7 |   32 |   32 |  274 | ********************************
  -0.6 |   34 |   34 |  308 | **********************************
  -0.5 |   36 |   36 |  344 | ************************************
  -0.4 |   38 |   38 |  382 | **************************************
  -0.3 |   39 |   39 |  421 | ***************************************
  -0.2 |   39 |   39 |  460 | ***************************************
  -0.1 |   40 |   40 |  500 | ****************************************
   0.1 |   40 |   40 |  540 | ****************************************
   0.2 |   39 |   39 |  579 | ***************************************
   0.3 |   39 |   39 |  618 | ***************************************
   0.4 |   38 |   38 |  656 | **************************************
   0.5 |   36 |   36 |  692 | ************************************
   0.6 |   34 |   34 |  726 | **********************************
   0.7 |   32 |   32 |  758 | ********************************
   0.8 |   30 |   30 |  788 | ******************************
   0.9 |   28 |   28 |  816 | ****************************
   1.0 |   25 |   25 |  841 | *************************
   1.1 |   23 |   23 |  864 | ***********************
   1.2 |   21 |   21 |  885 | *********************
   1.3 |   18 |   18 |  903 | ******************
   1.4 |   16 |   16 |  919 | ****************
   1.5 |   14 |   14 |  933 | **************
   1.6 |   12 |   12 |  945 | ************
   1.7 |   10 |   10 |  955 | **********
   1.8 |    9 |    9 |  964 | *********
   1.9 |    7 |    7 |  971 | *******
   2.0 |    6 |    6 |  977 | ******
   2.1 |    5 |    5 |  982 | *****
   2.2 |    4 |    4 |  986 | ****
   2.3 |    3 |    3 |  989 | ***
   2.4 |    3 |    3 |  992 | ***
   2.5 |    2 |    2 |  994 | **
   2.6 |    2 |    2 |  996 | **
   2.7 |    1 |    1 |  997 | *
   2.8 |    1 |    1 |  998 | *
   2.9 |    1 |    1 |  999 | *
   3.0 |    1 |    1 | 1000 | *
(60 rows)
```

Let's calculate the mean and standard deviation of the standard normal.

```SQL
WITH RECURSIVE duplicate_val AS (
  SELECT *
    FROM v2
   UNION ALL
  SELECT v.x AS x
        , v.freq - 1 AS freq
    FROM duplicate_val v
   INNER JOIN v2 w
      ON v.x = w.x
   WHERE v.freq > 1
),
mean_std AS (
  SELECT ROUND(AVG(x),2) AS mu
       , ROUND(STDDEV(x),2) AS sigma
    FROM duplicate_val
),
standardz AS (
  SELECT  x
        , (x - mu)/sigma AS zscore
    FROM duplicate_val v, mean_std m
)
SELECT COUNT(zscore) AS n
     , ROUND(AVG(zscore),2) AS mean
     , ROUND(STDDEV_POP(zscore),2) AS std_p
     , ROUND(STDDEV(zscore),2)  AS std
 FROM standardz;
```

```console
n    | mean | std_p | std
-----+------+-------+------
1000 | 0.00 |  1.00 | 1.00
```

# Generating Standard Normal variables using the pnorm function


Suppose we have the following samples taken from the standard normal distribution:

```console
class         |   z   | freq | sum  | pr  | c_pr  |                                              freq_plot
--------------+-------+------+------+-----+-------+-----------------------------------------------------------------------------------------------------
(-inf -3.0]   |  -3.0 |    1 |    1 | 0.1 |   0.1 | *
(-3.0 -2.75]  | -2.75 |    2 |    3 | 0.2 |   0.3 | **
(-2.75 -2.50] | -2.50 |    3 |    6 | 0.3 |   0.6 | ***
(-2.50 -2.25] | -2.25 |    6 |   12 | 0.6 |   1.2 | ******
(-2.25 -2.00] | -2.00 |   11 |   23 | 1.1 |   2.3 | ***********
(-2.00 -1.75] | -1.75 |   17 |   40 | 1.7 |   4.0 | *****************
(-1.75 -1.50] | -1.50 |   27 |   67 | 2.7 |   6.7 | ***************************
(-1.50 -1.25] | -1.25 |   39 |  106 | 3.9 |  10.6 | ***************************************
(-1.25 -1.00] | -1.00 |   53 |  159 | 5.3 |  15.9 | *****************************************************
(-1.00 -0.75] | -0.75 |   68 |  227 | 6.8 |  22.7 | ********************************************************************
(-0.75 -0.50] | -0.50 |   82 |  309 | 8.2 |  30.9 | **********************************************************************************
(-0.50 -0.25] | -0.25 |   92 |  401 | 9.2 |  40.1 | ********************************************************************************************
(-0.25 0.00]  |  0.00 |   99 |  500 | 9.9 |  50.0 | ***************************************************************************************************
(0.00 0.25]   |  0.25 |   99 |  599 | 9.9 |  59.9 | ***************************************************************************************************
(0.25 0.50]   |  0.50 |   92 |  691 | 9.2 |  69.1 | ********************************************************************************************
(0.50 0.75]   |  0.75 |   82 |  773 | 8.2 |  77.3 | **********************************************************************************
(0.75 1.00]   |  1.00 |   68 |  841 | 6.8 |  84.1 | ********************************************************************
(1.00 1.25]   |  1.25 |   53 |  894 | 5.3 |  89.4 | *****************************************************
(1.25 1.50]   |  1.50 |   39 |  933 | 3.9 |  93.3 | ***************************************
(1.50 1.75]   |  1.75 |   27 |  960 | 2.7 |  96.0 | ***************************
(1.75 2.00]   |  2.00 |   17 |  977 | 1.7 |  97.7 | *****************
(2.00 2.25]   |  2.25 |   11 |  988 | 1.1 |  98.8 | ***********
(2.25 2.50]   |  2.50 |    6 |  994 | 0.6 |  99.4 | ******
(2.50 2.75]   |  2.75 |    3 |  997 | 0.3 |  99.7 | ***
(2.75 3.00]   |  3.00 |    2 |  999 | 0.2 |  99.9 | **
(3.0 +inf)    |  3.25 |    1 | 1000 | 0.1 | 100.0 | *
```

The code to generate the above table is available [here](./02_normal_distribution_lookuptable.md)

```SQL
CREATE VIEW vz AS (
WITH RECURSIVE normal AS (
  SELECT -3.0 AS z
        , (pnorm(-3.0)::NUMERIC(4,3)*1000)::INTEGER AS freq
  UNION ALL
  SELECT  z + 0.25 AS z
        , CASE WHEN z = 3.0
               THEN  (((1 - pnorm(z))::NUMERIC(4,3))*1000)::INTEGER
               ELSE
              ((pnorm(z + 0.25)::NUMERIC(4,3) - pnorm(z)::NUMERIC(4,3))*1000)::INTEGER
          END AS freq
    FROM normal
   WHERE z <= 3.0
)
 SELECT *
   FROM normal
);

WITH RECURSIVE duplicate_val AS (
  SELECT  z
        , freq
    FROM vz
   UNION ALL
  SELECT v.z AS z
        , v.freq - 1 AS freq
    FROM duplicate_val v
   INNER JOIN vz w
      ON v.z = w.z
   WHERE v.freq > 1
)
SELECT z
  FROM duplicate_val
 ORDER BY z;
```

```console
z
-------
-3.0
-2.75
-2.75
-2.50
-2.50
-2.50
-2.25
-2.25
-2.25
-2.25
-2.25
-2.25
-2.00
-2.00
-2.00
-2.00
-2.00
-2.00
-2.00
-2.00
-2.00
-2.00
-2.00
-1.75
-1.75
-1.75
-1.75
-1.75
-1.75
-1.75
-1.75
-1.75
-1.75
-1.75
-1.75
-1.75
-1.75
-1.75
-1.75
-1.75
-1.50
-1.50
-1.50
```

Let's transform the z-score values of the standard normal distribution to the corresponding x values of a normal distribution with mean `115.50` and a standard deviation of `9.97`. To visualize the distribution and facilitate the analysis we rounded the value to a whole number.

```SQL
WITH RECURSIVE duplicate_val AS (
  SELECT  z
        , freq
    FROM vz
   UNION ALL
  SELECT v.z AS z
        , v.freq - 1 AS freq
    FROM duplicate_val v
   INNER JOIN vz w
      ON v.z = w.z
   WHERE v.freq > 1
)
SELECT ROUND(115.50 + (9.97)*z,0) AS x
  FROM duplicate_val
 ORDER BY x;
```

```console
x
-----
86
88
88
91
91
91
93
93
93
93
93
93
96
96
96
96
96
96
96
96
96
96
96
98
98
```

Let's plot the distribution:

```SQL
WITH RECURSIVE duplicate_val AS (
  SELECT  z
        , freq
    FROM vz
   UNION ALL
  SELECT v.z AS z
        , v.freq - 1 AS freq
    FROM duplicate_val v
   INNER JOIN vz w
      ON v.z = w.z
   WHERE v.freq > 1
),
raw_data AS (
  SELECT ROUND(115.50 + (9.97)*z,0) AS x
    FROM duplicate_val
),
histogram AS (
  SELECT x
       , COUNT(x) AS freq
    FROM raw_data
   GROUP BY x
)
SELECT  x
      , freq
      , LPAD('*',freq::INTEGER,'*') AS freq_plot
  FROM histogram
 ORDER BY x;
```

```console
x   | freq |                                              freq_plot
----+------+-----------------------------------------------------------------------------------------------------
86 |    1 | *
88 |    2 | **
91 |    3 | ***
93 |    6 | ******
96 |   11 | ***********
98 |   17 | *****************
101 |   27 | ***************************
103 |   39 | ***************************************
106 |   53 | *****************************************************
108 |   68 | ********************************************************************
111 |   82 | **********************************************************************************
113 |   92 | ********************************************************************************************
116 |   99 | ***************************************************************************************************
118 |   99 | ***************************************************************************************************
120 |   92 | ********************************************************************************************
123 |   82 | **********************************************************************************
125 |   68 | ********************************************************************
128 |   53 | *****************************************************
130 |   39 | ***************************************
133 |   27 | ***************************
135 |   17 | *****************
138 |   11 | ***********
140 |    6 | ******
143 |    3 | ***
145 |    2 | **
148 |    1 | *
(26 rows)
```

Let's calculate the summary statistics:

```SQL
WITH RECURSIVE duplicate_val AS (
  SELECT  z
        , freq
    FROM vz
   UNION ALL
  SELECT v.z AS z
        , v.freq - 1 AS freq
    FROM duplicate_val v
   INNER JOIN vz w
      ON v.z = w.z
   WHERE v.freq > 1
),
raw_data AS (
  SELECT ROUND(115.50 + (9.97)*z,0) AS x
    FROM duplicate_val
)
SELECT ROUND(AVG(x),2) AS mu
     , ROUND(STDDEV(x),2) AS sigma
  FROM raw_data;
```

It's just an approximation.

```console
mu     | sigma
-------+-------
116.78 |  9.82
```


# Generating Standard Normal variables using the Gaussian Distribution Example 2

```SQL
CREATE VIEW v3 AS (
WITH RECURSIVE gauss_pdf AS (
  SELECT  '[-3.25  -3.0)' AS class
        , -3.0 AS z
        , gaussian(-3.25 + 0.125,0,1)*0.25 AS prb
   UNION ALL
  SELECT CASE WHEN z = 3.0
              THEN '(3.0  3.25]'
              WHEN z < 0
              THEN  '[' || z::TEXT || '  ' || (z + 0.25)::TEXT || ')'
              ELSE  '(' || z::TEXT || '  ' || (z + 0.25)::TEXT || ']'
         END AS class
        , z + 0.25 AS z
        , gaussian(z + 0.125,0,1)*0.25 AS prb
    FROM gauss_pdf
   WHERE z <= 3.0
),
g_pdf AS (
  SELECT  class
        , z
        , prb
        , ROUND((1000.0*prb)::INTEGER,1)::INTEGER AS freq
    FROM gauss_pdf
)
SELECT  ROW_NUMBER() OVER(ORDER BY z) + 115 - 13 AS x
        , freq
  FROM g_pdf
 WHERE freq > 0
);

SELECT  *
      , LPAD('*',freq::INTEGER,'*') AS freq_plot
  FROM v3;
```

```console
x   | freq |                                              freq_plot
----+------+-----------------------------------------------------------------------------------------------------
103 |    1 | *
104 |    2 | **
105 |    3 | ***
106 |    6 | ******
107 |   10 | **********
108 |   17 | *****************
109 |   27 | ***************************
110 |   39 | ***************************************
111 |   53 | *****************************************************
112 |   68 | ********************************************************************
113 |   82 | **********************************************************************************
114 |   93 | *********************************************************************************************
115 |   99 | ***************************************************************************************************
116 |   99 | ***************************************************************************************************
117 |   93 | *********************************************************************************************
118 |   82 | **********************************************************************************
119 |   68 | ********************************************************************
120 |   53 | *****************************************************
121 |   39 | ***************************************
122 |   27 | ***************************
123 |   17 | *****************
124 |   10 | **********
125 |    6 | ******
126 |    3 | ***
127 |    2 | **
128 |    1 | *
(26 rows)
```

Let's compute the summary statistics:

```SQL
WITH RECURSIVE duplicate_val AS (
  SELECT *
    FROM v3
   UNION ALL
  SELECT v.x AS x
        , v.freq - 1 AS freq
    FROM duplicate_val v
   INNER JOIN v3 w
      ON v.x = w.x
   WHERE v.freq > 1
),
diff AS (
  SELECT x
       , COUNT(x) OVER() AS n
       , AVG(x) OVER() AS mean
       , STDDEV_POP(x) OVER() AS std_p
       , STDDEV(x) OVER() AS std
    FROM duplicate_val
),
comp_sk_krt AS (
  SELECT n
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
        , mean
        , std
        , num_sk/den_sk AS skw
        , num_krt/den_krt - 3 AS execess_krt
    FROM comp_sk_krt
)
SELECT  ROUND(mean,2) AS mean
      , ROUND(std,2) AS sample_std
      , ROUND((SQRT(n*(n-1.0))/(n-2.0))*skw,2) AS sample_skeweness
      , ROUND((n - 1)*((n + 1)*execess_krt + 6)/((n-2)*(n-3)),2) AS sample_kurt
  FROM pop_sk_krt;
```

```console
mean   | sample_std | sample_skeweness | sample_kurt
-------+------------+------------------+-------------
115.50 |       3.99 |             0.00 |       -0.06
```

Let's calculate the z-score of the normal distribution:

```SQL
WITH RECURSIVE duplicate_val AS (
  SELECT *
    FROM v3
   UNION ALL
  SELECT v.x AS x
        , v.freq - 1 AS freq
    FROM duplicate_val v
   INNER JOIN v3 w
      ON v.x = w.x
   WHERE v.freq > 1
),
mean_std AS (
  SELECT ROUND(AVG(x),2) AS mu
       , ROUND(STDDEV(x),2) AS sigma
    FROM duplicate_val
),
standardz AS (
  SELECT  x
        , (x - mu)/sigma AS zscore
    FROM duplicate_val v, mean_std m
),
freq AS (
  SELECT  ROUND(zscore::NUMERIC,2) AS zscore
        , COUNT(1) AS cont
    FROM standardz
   GROUP BY 1
),
histogram AS (
  SELECT  *
        , ROUND(1000.0*cont/SUM(cont) OVER(),1)::INTEGER AS freq
    FROM freq
)
SELECT  *
      , SUM(freq) OVER(ORDER BY zscore)
      , LPAD('*',freq::INTEGER,'*') AS freq_plot
  FROM histogram
 ORDER BY 1;
```

```console
zscore  | cont | freq | sum  |                                              freq_plot
--------+------+------+------+-----------------------------------------------------------------------------------------------------
  -3.1 |    1 |    1 |    1 | *
  -2.9 |    2 |    2 |    3 | **
  -2.6 |    3 |    3 |    6 | ***
  -2.4 |    6 |    6 |   12 | ******
  -2.1 |   10 |   10 |   22 | **********
  -1.9 |   17 |   17 |   39 | *****************
  -1.6 |   27 |   27 |   66 | ***************************
  -1.4 |   39 |   39 |  105 | ***************************************
  -1.1 |   53 |   53 |  158 | *****************************************************
  -0.9 |   68 |   68 |  226 | ********************************************************************
  -0.6 |   82 |   82 |  308 | **********************************************************************************
  -0.4 |   93 |   93 |  401 | *********************************************************************************************
  -0.1 |   99 |   99 |  500 | ***************************************************************************************************
   0.1 |   99 |   99 |  599 | ***************************************************************************************************
   0.4 |   93 |   93 |  692 | *********************************************************************************************
   0.6 |   82 |   82 |  774 | **********************************************************************************
   0.9 |   68 |   68 |  842 | ********************************************************************
   1.1 |   53 |   53 |  895 | *****************************************************
   1.4 |   39 |   39 |  934 | ***************************************
   1.6 |   27 |   27 |  961 | ***************************
   1.9 |   17 |   17 |  978 | *****************
   2.1 |   10 |   10 |  988 | **********
   2.4 |    6 |    6 |  994 | ******
   2.6 |    3 |    3 |  997 | ***
   2.9 |    2 |    2 |  999 | **
   3.1 |    1 |    1 | 1000 | *
(26 rows)
```

Although the example 1 z-score distribution has a more grained resolution (bigger number of bins with smaller width) the pdf is still the Gaussian distribution.
