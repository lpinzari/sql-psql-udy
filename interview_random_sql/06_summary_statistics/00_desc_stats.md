# Introduction to Dataset

In this section, we’ll discuss how to derive **summary statistics** of
- `numerical` and
- `categorical`

columns/fields using SQL. We’ll use the `film` table, (`dvdrental` sample database):

```console
dvdrental=# \d film
                                              Table "public.film"
      Column      |            Type             | Collation | Nullable |                Default
------------------+-----------------------------+-----------+----------+---------------------------------------
 film_id          | integer                     |           | not null | nextval('film_film_id_seq'::regclass)
 title            | character varying(255)      |           | not null |
 description      | text                        |           |          |
 release_year     | year                        |           |          |
 language_id      | smallint                    |           | not null |
 rental_duration  | smallint                    |           | not null | 3
 rental_rate      | numeric(4,2)                |           | not null | 4.99
 length           | smallint                    |           |          |
 replacement_cost | numeric(5,2)                |           | not null | 19.99
 rating           | mpaa_rating                 |           |          | 'G'::mpaa_rating
 last_update      | timestamp without time zone |           | not null | now()
 special_features | text[]                      |           |          |
 fulltext         | tsvector                    |           | not null |
Indexes:
    "film_pkey" PRIMARY KEY, btree (film_id)
    "film_fulltext_idx" gist (fulltext)
    "idx_fk_language_id" btree (language_id)
    "idx_title" btree (title)
Foreign-key constraints:
    "film_language_id_fkey" FOREIGN KEY (language_id) REFERENCES language(language_id) ON UPDATE CASCADE ON DELETE RESTRICT
Referenced by:
    TABLE "film_actor" CONSTRAINT "film_actor_film_id_fkey" FOREIGN KEY (film_id) REFERENCES film(film_id) ON UPDATE CASCADE ON DELETE RESTRICT
    TABLE "film_category" CONSTRAINT "film_category_film_id_fkey" FOREIGN KEY (film_id) REFERENCES film(film_id) ON UPDATE CASCADE ON DELETE RESTRICT
    TABLE "inventory" CONSTRAINT "inventory_film_id_fkey" FOREIGN KEY (film_id) REFERENCES film(film_id) ON UPDATE CASCADE ON DELETE RESTRICT
Triggers:
    film_fulltext_trigger BEFORE INSERT OR UPDATE ON film FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('fulltext', 'pg_catalog.english', 'title', 'description')
    last_updated BEFORE UPDATE ON film FOR EACH ROW EXECUTE PROCEDURE last_updated()
```

where each row is a film with length in minutes.

```SQL
SELECT  film_id
      , title
      , length
  FROM film
 ORDER BY length DESC, film_id;
```

```console
film_id |            title            | length
--------+-----------------------------+--------
    141 | Chicago North               |    185
    182 | Control Anthem              |    185
    212 | Darn Forrester              |    185
    349 | Gangs Pride                 |    185
    426 | Home Pity                   |    185
    609 | Muscle Bright               |    185
    690 | Pond Seattle                |    185
    817 | Soldiers Evolution          |    185
    872 | Sweet Brotherhood           |    185
    991 | Worst Banger                |    185
    180 | Conspiracy Spirit           |    184
    198 | Crystal Breaking            |    184
    499 | King Evolution              |    184
    597 | Moonwalker Fool             |    184
    813 | Smoochy Control             |    184
    820 | Sons Interview              |    184
    821 | Sorority Queen              |    184
    886 | Theory Mermaid              |    184
    128 | Catch Amistad               |    183
    340 | Frontier Cabin              |    183
    767 | Scalawag Duck               |    183
    973 | Wife Turn                   |    183
    996 | Young Language              |    183
     50 | Baked Cleopatra             |    182
    591 | Monsoon Cause               |    182
    719 | Records Zorro               |    182
    721 | Reds Pocus                  |    182
    765 | Saturn Name                 |    182
    774 | Searchers Wait              |    182
     24 | Analyze Hoosiers            |    181
    406 | Haunting Pianist            |    181
    435 | Hotel Happiness             |    181
    467 | Intrigue Worst              |    181
    473 | Jacket Frisco               |    181
    510 | Lawless Vision              |    181
    535 | Love Suicides               |    181
    751 | Runaway Tenenbaums          |    181
    841 | Star Operation              |    181
    974 | Wild Apollo                 |    181
     16 | Alley Evolution             |    180
    174 | Confidential Interview      |    180
    454 | Impact Aladdin              |    180
    584 | Mixed Doors                 |    180
    612 | Mussolini Spoilers          |    180
    615 | Nash Chocolat               |    180
    818 | Something Duck              |    180
     27 | Anonymous Human             |    179
     88 | Born Spinal                 |    179
    126 | Casualties Encino           |    179
    ... | ....                        |    ...
```

Frequently used summary statistics for numerical variables are `mean`, `median`, `minimum`, `maximum`, `range`, `standard deviation`, `variance`, `Q1`, `Q3`, `IQR` and `skewness`.

## Problem 1

We want to return the following table:

```console
sno | statisitcs | value  |     class     | width | range | width_range_ratio | cumul
----+------------+--------+---------------+-------+-------+-------------------+--------
  1 | 0% MIN     |     46 |               |       |   139 |                   |
  2 | 1%         |     47 | (46  47]      |  1.00 |   139 |              0.01 |   1.00
  3 | 5%         |     52 | (47  52]      |  5.00 |   139 |              0.04 |   5.00
  4 | 10%        |     60 | (52  60]      |  8.00 |   139 |              0.06 |  11.00
  5 | 25% Q1     |     80 | (60  80]      | 20.00 |   139 |              0.14 |  25.00
  6 | 50% MEDIAN |    114 | (80  114]     | 34.00 |   139 |              0.24 |  49.00
  7 | 75% Q3     | 149.25 | (114  149.25] | 35.25 |   139 |              0.25 |  74.00
  8 | 90%        |    173 | (149.25  173] | 23.75 |   139 |              0.17 |  91.00
  9 | 95%        |    179 | (173  179]    |  6.00 |   139 |              0.04 |  95.00
 10 | 99%        | 184.01 | (179  184.01] |  5.01 |   139 |              0.04 |  99.00
 11 | 100% MAX   |    185 | (184.01  185] |  0.99 |   139 |              0.01 | 100.00
(11 rows)
```

## Problem 2

```console
median |  mean  | sample_std | sample_skeweness | sample_kurt
-------+--------+------------+------------------+-------------
   114 | 115.27 |      40.43 |             0.03 |       -1.17
```

## Problem 3

```console
perc_cont | value |   class    | width | range | cumul  | width_range_ratio | spread_width_plot
----------+-------+------------+-------+-------+--------+-------------------+-------------------
        5 |    52 | (46  52]   |  6.00 |   139 |   4.00 |              4.00 | ****
       10 |    59 | (52  59]   |  7.00 |   139 |   9.00 |              4.00 | ****
       15 |    65 | (59  65]   |  6.00 |   139 |  14.00 |              4.00 | ****
       20 |    73 | (65  73]   |  8.00 |   139 |  19.00 |              4.00 | ****
       25 |    80 | (73  80]   |  7.00 |   139 |  24.00 |              4.00 | ****
       30 |    85 | (80  85]   |  5.00 |   139 |  28.00 |              3.00 | ***
       35 |    93 | (85  93]   |  8.00 |   139 |  34.00 |              4.00 | ****
       40 |   101 | (93  101]  |  8.00 |   139 |  40.00 |              4.00 | ****
       45 |   107 | (101  107] |  6.00 |   139 |  44.00 |              3.00 | ***
       50 |   114 | (107  114] |  7.00 |   139 |  49.00 |              4.00 | ****
       55 |   121 | (114  121] |  7.00 |   139 |  54.00 |              4.00 | ****
       60 |   128 | (121  128] |  7.00 |   139 |  59.00 |              4.00 | ****
       65 |   135 | (128  135] |  7.00 |   139 |  64.00 |              4.00 | ****
       70 |   142 | (135  142] |  7.00 |   139 |  69.00 |              4.00 | ****
       75 |   149 | (142  149] |  7.00 |   139 |  74.00 |              4.00 | ****
       80 |   155 | (149  155] |  6.00 |   139 |  78.00 |              3.00 | ***
       85 |   163 | (155  163] |  8.00 |   139 |  84.00 |              4.00 | ****
       90 |   172 | (163  172] |  9.00 |   139 |  91.00 |              5.00 | *****
       95 |   179 | (172  179] |  7.00 |   139 |  96.00 |              4.00 | ****
      100 |   185 | (179  185] |  6.00 |   139 | 100.00 |              3.00 | ***
(20 rows)
```

# Solution

- **Problem 1**

```SQL
CREATE VIEW v AS
WITH quantiles AS (
  SELECT  11 AS sno
        , '100% MAX' AS statisitcs
        , MAX(length) AS value
    FROM film
  UNION ALL
  SELECT  10 AS sno
        , '99%' AS statistics
        , PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY length) AS value
    FROM film
  UNION ALL
  SELECT  9 AS sno
        , '95%' AS statistics
        , PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY length) AS value
    FROM film
  UNION ALL
  SELECT  8 AS sno
        , '90%' AS statistics
        , PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY length) AS value
    FROM film
  UNION ALL
  SELECT  7 AS sno
        , '75% Q3' AS statistics
        , PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY length) AS value
    FROM film
  UNION ALL
  SELECT  6 AS sno
        , '50% MEDIAN' AS statistics
        , PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY length) AS value
    FROM film
  UNION ALL
  SELECT  5 AS sno
        , '25% Q1' AS statistics
        , PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY length) AS value
    FROM film
  UNION ALL
  SELECT  4 AS sno
        , '10%' AS statistics
        , PERCENTILE_CONT(0.10) WITHIN GROUP (ORDER BY length) AS value
    FROM film
  UNION ALL
  SELECT  3 AS sno
        , '5%' AS statistics
        , PERCENTILE_CONT(0.05) WITHIN GROUP (ORDER BY length) AS value
    FROM film
  UNION ALL
  SELECT  2 AS sno
        , '1%' AS statistics
        , PERCENTILE_CONT(0.01) WITHIN GROUP (ORDER BY length) AS value
    FROM film
  UNION ALL
  SELECT  1 AS sno
        , '0% MIN' AS statistics
        , MIN(length) AS value
    FROM film
)
SELECT *
     , CASE WHEN LAG(value) OVER(ORDER BY value) IS NULL
            THEN NULL
            ELSE '(' || (LAG(value) OVER(ORDER BY value))::TEXT || '  ' || value::TEXT || ']'
       END AS class
    , CASE WHEN LAG(value) OVER(ORDER BY value) IS NULL
           THEN NULL
           ELSE ROUND(value::NUMERIC - LAG(value) OVER(ORDER BY value)::NUMERIC,2)::NUMERIC
      END AS width
    , MAX(value) OVER() - MIN(value) OVER() AS range
FROM quantiles;

SELECT *
      , ROUND((width/range)::NUMERIC,2) AS width_range_ratio
      , ROUND((SUM(width) OVER(ORDER BY value)/range)::NUMERIC,2)*100 AS cumul
  FROM v;
```

- **Problem 2**:

```SQL
WITH diff AS (
  SELECT length AS x
       , COUNT(length) OVER() AS n
       , AVG(length) OVER() AS mean
       , STDDEV_POP(length) OVER() AS std_p
       , STDDEV(length) OVER() AS std
    FROM film
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
SELECT  median
      , ROUND(mean,2) AS mean
      , ROUND(std,2) AS sample_std
      , ROUND((SQRT(n*(n-1.0))/(n-2.0))*skw,2) AS sample_skeweness
      , ROUND((n - 1)*((n + 1)*execess_krt + 6)/((n-2)*(n-3)),2) AS sample_kurt
  FROM pop_sk_krt;
```


- **Problem 3**:

```SQL
WITH rnk_duration AS (
  SELECT  length
        , DENSE_RANK() OVER (ORDER BY length)::INTEGER AS rnk
        , (ROUND((CUME_DIST() OVER (ORDER BY length))::NUMERIC,2)*100)::INTEGER AS c_rnk
    FROM film
),
rnk_5 AS (
  SELECT DISTINCT length AS x
        , rnk
        , c_rnk
        , MIN(length) OVER(PARTITION BY c_rnk) AS min_length
    FROM rnk_duration
   WHERE MOD(c_rnk,5) = 0 OR rnk = 1
),
percentile AS (
  SELECT  c_rnk AS perc_cont
        , x AS value
    FROM rnk_5
   WHERE x = min_length
),
percentile_w AS (
  SELECT perc_cont
       , value
       , CASE WHEN LAG(value) OVER(ORDER BY value) IS NULL
              THEN NULL
              ELSE '(' || (LAG(value) OVER(ORDER BY value))::TEXT || '  ' || value::TEXT || ']'
         END AS class
      , CASE WHEN LAG(value) OVER(ORDER BY value) IS NULL
             THEN NULL
             ELSE ROUND(value::NUMERIC - LAG(value) OVER(ORDER BY value)::NUMERIC,2)::NUMERIC
        END AS width
      , MAX(value) OVER() - MIN(value) OVER() AS range
  FROM percentile
),
dist_percentile AS (
  SELECT *
        , ROUND((SUM(width) OVER(ORDER BY value)/range)::NUMERIC,2)*100 AS cumul
    FROM percentile_w
   WHERE perc_cont >= 5
),
cumul_dist_percentile AS (
  SELECT *
        , CASE WHEN LAG(cumul) OVER(ORDER BY cumul) IS NULL
               THEN ROUND((width/range)::NUMERIC,2)*100
               ELSE ROUND((cumul - LAG(cumul) OVER(ORDER BY cumul))/range,2)*100
          END AS width_range_ratio
    FROM dist_percentile
)
SELECT *
      , LPAD('*',width_range_ratio::INTEGER,'*') AS spread_width_plot
  FROM cumul_dist_percentile;
```



## MEAN

In PostgreSQL, the mean of a numerical field/column is computed using the `AVG()` function. We’ll compute the mean of `length` minutes duration field as shown below.

```SQL
SELECT ROUND(AVG(length),2) AS mean
  FROM film;  
```

```console
mean
--------
115.27
(1 row)
```

## MEDIAN (Q2)

In PostgreSQL, there is no function to directly compute the median of a numerical field/column.

However, since median is the 50th percentile,a value that exceeds half of the sample data values and is exceeded by half of the sample data values, we can use it as a proxy to median. Percentile of a numerical variable is computed using the `PERCENTILE_CONT()` function. We’ll compute the median of duration_minutes field as shown below.

```SQL
SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY length) AS median
  FROM  film;
```

```console
median
--------
   114
(1 row)
```

`WITHIN GROUP` clause creates an ordered subset of data that can be used to perform aggregations. `PERCENTILE_CONT` takes the percentile required as an argument, in this case it is 0.5 i.e. the `50th` percentile.

## MINIMUM

In PostgreSQL, the minimum value of a numerical field/column is found using the `MIN()` function. We’ll find the minimum value (smallest value) of  length minutes field as shown below.

```SQL
SELECT MIN(length) AS min
  FROM film;  
```

```console
min
-----
 46
(1 row)
```

## MAXIMUM

In PostgreSQL, the maximum value of a numerical field/column is found using the `MAX()` function. We’ll find the maximum value (largest value) of length field as shown below.

```SQL
SELECT MAX(length) As max
  FROM film;
```

```console
max
-----
185
(1 row)
```

## RANGE

In PostgreSQL, there is no function to directly compute the range of a numerical field/column. However, since range is the difference between maximum and minimum values, we can use it as a proxy to range.

```SQL
SELECT MAX(length) - MIN(length) AS range
  FROM film;
```

```console
range
-------
  139
(1 row)
```

## STANDARD DEVIATION

In PostgreSQL, the standard deviation of a numerical field/column is computed using the `STDDEV()` function. The `STDDEV()` function returns the `sample` standard deviation. We’ll compute the standard deviation of `length` field as shown below.

- **Sample standard deviation**

```SQL
SELECT ROUND(STDDEV(length),2) AS stdev
  FROM film;
```

```console
stdev
-------
40.43
(1 row)
```

OR

We can also compute standard deviation as the square root of variance as shown below.

```SQL
SELECT ROUND(SQRT(VARIANCE(length)),2) AS stdev
  FROM film;
```

```console
stdev
-------
40.43
(1 row)
```

- **Population standard deviation**

```SQL
SELECT ROUND(STDDEV_POP(length),2) AS stdev_p
  FROM film;
```

```console
stdev_p
---------
  40.41
(1 row)
```

OR

We can also compute standard deviation as the square root of variance as shown below.

```SQL
SELECT ROUND(SQRT(VAR_POP(length)),2) AS stdev_p
  FROM film;
```

## VARIANCE

In PostgreSQL, the variance of a numerical field/column is computed using the `VARIANCE()` function.The `VARIANCE` function computes the `sample` variance of the population. We’ll compute the variance of length field as shown below.

- **Sample Vartiance**

```SQL
SELECT ROUND(VARIANCE(length),2) AS var
  FROM film;
```

```console
var
---------
1634.29
(1 row)
```

OR

We can also compute variance as the square of standard deviation as shown below.

```SQL
SELECT ROUND(POWER(STDDEV(length),2),2) AS var
  FROM film;
```

OR

```SQL
WITH diff AS (
  SELECT length AS x
       , AVG(length) OVER() AS mean
    FROM film
)
SELECT ROUND(SUM(POWER(x - mean,2))/(COUNT(x)-1),2) AS var
  FROM diff;
```

- **Population Variance**

```SQL
SELECT ROUND(VAR_POP(length),2) AS var_p
  FROM film;
```

```console
var_p
---------
1632.65
(1 row)
```

OR

We can also compute variance as the square of standard deviation as shown below.

```SQL
SELECT ROUND(POWER(STDDEV_POP(length),2),2) AS var_p
  FROM film;
```
OR

```SQL
WITH diff AS (
  SELECT length AS x
       , AVG(length) OVER() AS mean
    FROM film
)
SELECT ROUND(SUM(POWER(x - mean,2))/COUNT(x),2) AS var
  FROM diff;
```

## Q1

In PostgreSQL, there is no function to directly compute the `first quartile` (`Q1`) of a numerical field/column. However, since `Q1` is the `25th percentile`, we can use it as a proxy to Q1. We’ll compute the Q1 of length field as shown below.

```SQL
SELECT PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY length) q1
  FROM film;
```

```console
q1
----
80
(1 row)
```

## Q3

In PostgreSQL, there is no function to directly compute the `third quartile` (`Q3`) of a numerical field/column. However, since `Q3` is the `75th percentile`, we can use it as a proxy to Q3. We’ll compute the Q3 of length field as shown below.

```SQL
SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY length) q3
  FROM film;
```

## IQR

In PostgreSQL, there is no function to directly compute the interquartile range (IQR) of a numerical field/column. However, since IQR is the difference between Q3 and Q1, we can use it as a proxy to IQR. We’ll compute the IQR of length field as shown below.

```SQL
SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY length) -
       PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY length) AS iqr
  FROM film;
```

```console
iqr
-------
69.25
(1 row)
```

## PERCENTILE 1st, 5th, 10th and 90th, 95th, 99th

```SQL
SELECT  PERCENTILE_CONT(0.01) WITHIN GROUP (ORDER BY length) AS perc_1st
      , PERCENTILE_CONT(0.05) WITHIN GROUP (ORDER BY length) AS perc_5th
      , PERCENTILE_CONT(0.10) WITHIN GROUP (ORDER BY length) AS perc_10th
      , PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY length) AS perc_90th
      , PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY length) AS perc_95th
      , PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY length) AS perc_99th
  FROM film;
```

```console
perc_1st | perc_5th | perc_10th | perc_90th | perc_95th | perc_99th
---------+----------+-----------+-----------+-----------+-----------
      47 |       52 |        60 |       173 |       179 |    184.01
(1 row)
```

## SKEWENESS

In PostgreSQL, there is no function to directly compute the skewness of a numerical field/column.

- **Population Skeweness**:

A distribution of values (a frequency distribution) is said to be “skewed” if it is not symmetrical.

```console
          *                                               *
        * * *                                           * * *
      * * * * *                                       * * * * *
    * * * * * * * *                               * * * * * * * *
  * * * * * * * * * * *                       * * * * * * * * * * *
* * * * * * * * * * * * * * * *       * * * * * * * * * * * * * * * *
CURVE A                                              CURVE B
```

Curve A illustrates positive skewness (skewed “to the right”), where most of the values are near the minimum value, although some are much higher.

Curve B illustrates negative skewness (skewed “to the left”), where most of the values are near the maximum, although some are much lower.

If you describe the curves statistically, curve A is positively skewed and might have a skewness coefficient of 0.5, and curve B is negatively skewed and might have a -0.5 skewness coefficient.

The Skewness is computed by finding the third moment about the mean and dividing by the cube of the standard deviation.


```console     
               n                                    
              Sum  (x - mean)^(3)                 
             i = 1  -------------                 
                        n                                      
skeweness = ------------------------------  

                 (Sigma)^(3)
```

- `(-inf -1) U (1 +inf)`: A skewness value greater than `1` or less than `-1` indicates a highly skewed distribution.
- `[-1 -0.5) U (0.5 1]`: A value between 0.5 and 1 or -0.5 and -1 is moderately skewed.
- `[-0.5 0.5]`: A value between -0.5 and 0.5 indicates that the distribution is fairly symmetrical.

```SQL
WITH diff AS (
  SELECT length AS x
       , AVG(length) OVER() AS mean
    FROM film
),
comp_sk AS (
  SELECT SUM(POWER(x - mean,3))/(COUNT(x))  AS num
       , POWER(STDDEV_POP(x),3) AS den
    FROM diff
)
SELECT ROUND(num/den,2) skw
  FROM comp_sk;
```

```console
skw
------
0.03
(1 row)
```

- **Sample Skeweness**

You’ll remember that you have to compute the variance and standard deviation slightly differently, depending on whether you have data for the whole population or just a sample. The same is true of skewness. If you have the whole population, then g1 above is the measure of skewness. But if you have just a sample, you need the sample skewness:



```console
              +-     -+ 1/2
              |n*(n-1)|
              +-     -+   
Sample skw =  -------------- * population_skeweness
                  n - 2
```

Reference: Joanes, D. N., and C. A. Gill. 1998.
“Comparing Measures of Sample Skewness and Kurtosis”. The Statistician 47(1): 183–189.

```SQL
WITH diff AS (
  SELECT length AS x
       , AVG(length) OVER() AS mean
    FROM film
),
comp_sk AS (
  SELECT SUM(POWER(x - mean,3))/(COUNT(x))  AS num
       , POWER(STDDEV_POP(x),3) AS den
       , COUNT(x) AS n
    FROM diff
),
pop_sk AS (
  SELECT  n
        , num/den skw
    FROM comp_sk
)
SELECT ROUND((SQRT(n*(n-1.0))/(n-2.0))*skw,2) AS skeweness
  FROM pop_sk;
```

```console
skeweness
------
0.03
(1 row)
```

## Kurtosis

Kurtosis refers to the peakedness of a distribution. For example, a distribution of values might be perfectly symmetrical but look either very “peaked” or very “flat,” as illustrated below:

```console
      *                                            *                   *
      *                                            *                   *
      *                        *                   *                   *
    * * *                    * * *                 *                   *
    * * *                * * * * * * *             *                   *
* * * * * * *        * * * * * * * * * * *         *                   *
  CURVE A                  CURVE B                       CURVE C: Kurtosis = 1.0
```

Curve A is fairly peaked, because most of the values are about the same, with few receiving very high or low values. Curve B is flat-topped, indicating that the values cover a wider spread.

Describing the curves statistically, curve A is fairly peaked, with a kurtosis of about `4`. Curve B, which is fairly flat, might have a kurtosis of `2`.

A `normal distribution` usually is used as the standard of reference and has a kurtosis of `3`.

- Distributions with kurtosis values of `less than 3` are described as `platykurtic` (`meaning flat`).Compared to a normal distribution, its tails are shorter and thinner, and often its central peak is lower and broader.

- and distributions with kurtosis values of `greater than 3` are `leptokurtic` (`meaning peaked`).Compared to a normal distribution, its tails are longer and fatter, and often its central peak is higher and sharper.

A discrete distribution with two equally likely outcomes, such as winning or losing on the flip of a coin, has the lowest possible kurtosis. It has no central peak and no real tails, and you could say that it’s “all shoulder” — it’s as platykurtic as a distribution can be. At the other extreme, Student’s t distribution with four degrees of freedom has infinite kurtosis. A distribution can’t be any more leptokurtic than this.


- **Population Kurtosis**:

Kurtosis, or peakedness, is calculated by finding the fourth moment about the mean and dividing by the quadruple of the standard deviation.


```console     
               n                                    
              Sum  (x - mean)^(4)                 
             i = 1  -------------                 
                        n                                      
Kurtosis  = ------------------------------  

                 (Sigma)^(4)
```

```SQL
WITH diff AS (
  SELECT length AS x
       , AVG(length) OVER() AS mean
    FROM film
),
comp_k AS (
  SELECT SUM(POWER(x - mean,4))/(COUNT(x))  AS num
       , POWER(STDDEV_POP(x),4) AS den
    FROM diff
)
SELECT ROUND(num/den,2) AS kurt
      , ROUND(num/den,2) - 3 AS excess_kurt
  FROM comp_k;
```

```console
kurt | excess_kurt
------+-------------
1.83 |       -1.17
(1 row)
```

- **Sample Kurtosis**:

Just as with variance, standard deviation, and skewness, the above is the final computation of kurtosis if you have data for the whole population. But if you have data for only a sample, you have to compute the sample excess kurtosis using this formula, which comes from Joanes and Gill:

```console
                    n - 1
sample Kurtosis = --------------- * [(n + 1)* execess_kurt + 6]
                   (n - 2)*(n - 3)
```

```SQL
WITH diff AS (
  SELECT length AS x
       , AVG(length) OVER() AS mean
    FROM film
),
comp_k AS (
  SELECT SUM(POWER(x - mean,4))/(COUNT(x))  AS num
       , POWER(STDDEV_POP(x),4) AS den
       , COUNT(x) AS n
    FROM diff
),
pop_kurt AS (
  SELECT  ROUND(num/den,2) - 3 AS excess_kurt
        , n
    FROM comp_k
)
SELECT ROUND((n - 1)*((n + 1)*excess_kurt + 6)/((n-2)*(n-3)),2) AS sample_kurt
  FROM pop_kurt;
```

```console
sample_kurt
-------------
      -1.17
(1 row)
```

## Putting everything together

```SQL
WITH quantiles AS (
  SELECT  11 AS sno
        , '100% MAX' AS statisitcs
        , MAX(length) AS value
    FROM film
  UNION ALL
  SELECT  10 AS sno
        , '99%' AS statistics
        , PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY length) AS value
    FROM film
  UNION ALL
  SELECT  9 AS sno
        , '95%' AS statistics
        , PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY length) AS value
    FROM film
  UNION ALL
  SELECT  8 AS sno
        , '90%' AS statistics
        , PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY length) AS value
    FROM film
  UNION ALL
  SELECT  7 AS sno
        , '75% Q3' AS statistics
        , PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY length) AS value
    FROM film
  UNION ALL
  SELECT  6 AS sno
        , '50% MEDIAN' AS statistics
        , PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY length) AS value
    FROM film
  UNION ALL
  SELECT  5 AS sno
        , '25% Q1' AS statistics
        , PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY length) AS value
    FROM film
  UNION ALL
  SELECT  4 AS sno
        , '10%' AS statistics
        , PERCENTILE_CONT(0.10) WITHIN GROUP (ORDER BY length) AS value
    FROM film
  UNION ALL
  SELECT  3 AS sno
        , '5%' AS statistics
        , PERCENTILE_CONT(0.05) WITHIN GROUP (ORDER BY length) AS value
    FROM film
  UNION ALL
  SELECT  2 AS sno
        , '1%' AS statistics
        , PERCENTILE_CONT(0.01) WITHIN GROUP (ORDER BY length) AS value
    FROM film
  UNION ALL
  SELECT  1 AS sno
        , '0% MIN' AS statistics
        , MIN(length) AS value
    FROM film
)
SELECT *
       , CASE WHEN LAG(value) OVER(ORDER BY value) IS NULL
              THEN NULL
              ELSE '(' || (LAG(value) OVER(ORDER BY value))::TEXT || '  ' || value::TEXT || ']'
         END AS class
       , CASE WHEN LAG(value) OVER(ORDER BY value) IS NULL
              THEN NULL
              ELSE ROUND(value::NUMERIC - LAG(value) OVER(ORDER BY value)::NUMERIC,2)
         END AS width
       , MAX(value) OVER() - MIN(value) OVER() AS range
  FROM quantiles
 ORDER BY sno;
```

```console
sno | statisitcs | value  |     class     | width | range
----+------------+--------+---------------+-------+-------
  1 | 0% MIN     |     46 |               |       |   139
  2 | 1%         |     47 | (46  47]      |  1.00 |   139
  3 | 5%         |     52 | (47  52]      |  5.00 |   139
  4 | 10%        |     60 | (52  60]      |  8.00 |   139
  5 | 25% Q1     |     80 | (60  80]      | 20.00 |   139
  6 | 50% MEDIAN |    114 | (80  114]     | 34.00 |   139
  7 | 75% Q3     | 149.25 | (114  149.25] | 35.25 |   139
  8 | 90%        |    173 | (149.25  173] | 23.75 |   139
  9 | 95%        |    179 | (173  179]    |  6.00 |   139
 10 | 99%        | 184.01 | (179  184.01] |  5.01 |   139
 11 | 100% MAX   |    185 | (184.01  185] |  0.99 |   139
(11 rows)
```

```SQL
CREATE VIEW v AS
WITH quantiles AS (
  SELECT  11 AS sno
        , '100% MAX' AS statisitcs
        , MAX(length) AS value
    FROM film
  UNION ALL
  SELECT  10 AS sno
        , '99%' AS statistics
        , PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY length) AS value
    FROM film
  UNION ALL
  SELECT  9 AS sno
        , '95%' AS statistics
        , PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY length) AS value
    FROM film
  UNION ALL
  SELECT  8 AS sno
        , '90%' AS statistics
        , PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY length) AS value
    FROM film
  UNION ALL
  SELECT  7 AS sno
        , '75% Q3' AS statistics
        , PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY length) AS value
    FROM film
  UNION ALL
  SELECT  6 AS sno
        , '50% MEDIAN' AS statistics
        , PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY length) AS value
    FROM film
  UNION ALL
  SELECT  5 AS sno
        , '25% Q1' AS statistics
        , PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY length) AS value
    FROM film
  UNION ALL
  SELECT  4 AS sno
        , '10%' AS statistics
        , PERCENTILE_CONT(0.10) WITHIN GROUP (ORDER BY length) AS value
    FROM film
  UNION ALL
  SELECT  3 AS sno
        , '5%' AS statistics
        , PERCENTILE_CONT(0.05) WITHIN GROUP (ORDER BY length) AS value
    FROM film
  UNION ALL
  SELECT  2 AS sno
        , '1%' AS statistics
        , PERCENTILE_CONT(0.01) WITHIN GROUP (ORDER BY length) AS value
    FROM film
  UNION ALL
  SELECT  1 AS sno
        , '0% MIN' AS statistics
        , MIN(length) AS value
    FROM film
)
SELECT *
     , CASE WHEN LAG(value) OVER(ORDER BY value) IS NULL
            THEN NULL
            ELSE '(' || (LAG(value) OVER(ORDER BY value))::TEXT || '  ' || value::TEXT || ']'
       END AS class
    , CASE WHEN LAG(value) OVER(ORDER BY value) IS NULL
           THEN NULL
           ELSE ROUND(value::NUMERIC - LAG(value) OVER(ORDER BY value)::NUMERIC,2)::NUMERIC
      END AS width
    , MAX(value) OVER() - MIN(value) OVER() AS range
FROM quantiles;

SELECT *
      , ROUND((width/range)::NUMERIC,2) AS width_range_ratio
      , ROUND((SUM(width) OVER(ORDER BY value)/range)::NUMERIC,2)*100 AS cumul
  FROM v;
```

```console
sno | statisitcs | value  |     class     | width | range | width_range_ratio | cumul
----+------------+--------+---------------+-------+-------+-------------------+--------
  1 | 0% MIN     |     46 |               |       |   139 |                   |
  2 | 1%         |     47 | (46  47]      |  1.00 |   139 |              0.01 |   1.00
  3 | 5%         |     52 | (47  52]      |  5.00 |   139 |              0.04 |   5.00
  4 | 10%        |     60 | (52  60]      |  8.00 |   139 |              0.06 |  11.00
  5 | 25% Q1     |     80 | (60  80]      | 20.00 |   139 |              0.14 |  25.00
  6 | 50% MEDIAN |    114 | (80  114]     | 34.00 |   139 |              0.24 |  49.00
  7 | 75% Q3     | 149.25 | (114  149.25] | 35.25 |   139 |              0.25 |  74.00
  8 | 90%        |    173 | (149.25  173] | 23.75 |   139 |              0.17 |  91.00
  9 | 95%        |    179 | (173  179]    |  6.00 |   139 |              0.04 |  95.00
 10 | 99%        | 184.01 | (179  184.01] |  5.01 |   139 |              0.04 |  99.00
 11 | 100% MAX   |    185 | (184.01  185] |  0.99 |   139 |              0.01 | 100.00
(11 rows)
```

In the output table we clearly see that 50% of dvds have a duration between 60 and 149 minutes.




```SQL
WITH diff AS (
  SELECT length AS x
       , COUNT(length) OVER() AS n
       , AVG(length) OVER() AS mean
       , STDDEV_POP(length) OVER() AS std_p
       , STDDEV(length) OVER() AS std
    FROM film
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
115.27 |      40.43 |             0.03 |       -1.17
```

The distribution is approximately symmetric roughly flat with positive skeweness. We'd expect a mean greater than the median.

## Problem 2

```SQL
SELECT  length
      , DENSE_RANK() OVER (ORDER BY length) AS rnk
      , (ROUND((CUME_DIST() OVER (ORDER BY length))::NUMERIC,2)*100)::INTEGER AS c_rnk
  FROM film
 ORDER BY length;
```

```console
length | rnk | c_rnk
--------+-----+-------
    46 |   1 |     1
    46 |   1 |     1
    46 |   1 |     1
    46 |   1 |     1
    46 |   1 |     1
    47 |   2 |     1
    47 |   2 |     1
    47 |   2 |     1
    47 |   2 |     1
    47 |   2 |     1
    47 |   2 |     1
    47 |   2 |     1
    48 |   3 |     2
    48 |   3 |     2
    48 |   3 |     2
    48 |   3 |     2
    ..    ..      ..
```

We want to filter only the multiples of 5.

```SQL
WITH rnk_duration AS (
  SELECT  length
        , DENSE_RANK() OVER (ORDER BY length)::INTEGER AS rnk
        , (ROUND((CUME_DIST() OVER (ORDER BY length))::NUMERIC,2)*100)::INTEGER AS c_rnk
    FROM film
)
SELECT  length AS x
      , rnk
      , c_rnk
  FROM rnk_duration
 WHERE MOD(c_rnk,5) = 0
 ORDER BY x;
```

```console
x  | rnk | c_rnk
---+-----+-------
52 |   7 |     5
52 |   7 |     5
52 |   7 |     5
52 |   7 |     5
52 |   7 |     5
52 |   7 |     5
52 |   7 |     5
59 |  14 |    10 <---
59 |  14 |    10
59 |  14 |    10
59 |  14 |    10
59 |  14 |    10
59 |  14 |    10
59 |  14 |    10
59 |  14 |    10
59 |  14 |    10
60 |  15 |    10
60 |  15 |    10
```

```SQL
WITH rnk_duration AS (
  SELECT  length
        , DENSE_RANK() OVER (ORDER BY length)::INTEGER AS rnk
        , (ROUND((CUME_DIST() OVER (ORDER BY length))::NUMERIC,2)*100)::INTEGER AS c_rnk
    FROM film
)
SELECT DISTINCT length AS x
      , rnk
      , c_rnk
  FROM rnk_duration
 WHERE MOD(c_rnk,5) = 0
 ORDER BY x;
```

```console
x  | rnk | c_rnk
-----+-----+-------
52 |   7 |     5
59 |  14 |    10 <---
60 |  15 |    10
65 |  20 |    15 <---
66 |  21 |    15
73 |  28 |    20 <---
80 |  35 |    25 <---
85 |  40 |    30 <---
86 |  41 |    30
93 |  48 |    35 <---
94 |  49 |    35
101 |  56 |    40 <---
107 |  62 |    45 <---
108 |  63 |    45
114 |  69 |    50 <---
121 |  76 |    55 <---
128 |  83 |    60 <---
135 |  90 |    65 <---
142 |  97 |    70 <---
149 | 104 |    75 <---
155 | 110 |    80 <---
156 | 111 |    80
163 | 118 |    85 <---
164 | 119 |    85
165 | 120 |    85
172 | 127 |    90 <---
173 | 128 |    90
179 | 134 |    95 <---
185 | 140 |   100 <---
(29 rows)
```

```SQL
WITH rnk_duration AS (
  SELECT  length
        , DENSE_RANK() OVER (ORDER BY length)::INTEGER AS rnk
        , (ROUND((CUME_DIST() OVER (ORDER BY length))::NUMERIC,2)*100)::INTEGER AS c_rnk
    FROM film
),
rnk_5 AS (
  SELECT DISTINCT length AS x
        , rnk
        , c_rnk
        , MIN(length) OVER(PARTITION BY c_rnk) AS min_length
    FROM rnk_duration
   WHERE MOD(c_rnk,5) = 0
)
SELECT  x
      , rnk
      , c_rnk
  FROM rnk_5
 WHERE x = min_length;
```

```console
x   | rnk | c_rnk
----+-----+-------
52  |   7 |     5
59  |  14 |    10
65  |  20 |    15
73  |  28 |    20
80  |  35 |    25
85  |  40 |    30
93  |  48 |    35
101 |  56 |    40
107 |  62 |    45
114 |  69 |    50
121 |  76 |    55
128 |  83 |    60
135 |  90 |    65
142 |  97 |    70
149 | 104 |    75
155 | 110 |    80
163 | 118 |    85
172 | 127 |    90
179 | 134 |    95
185 | 140 |   100
(20 rows)
```

```SQL
WITH rnk_duration AS (
  SELECT  length
        , DENSE_RANK() OVER (ORDER BY length)::INTEGER AS rnk
        , (ROUND((CUME_DIST() OVER (ORDER BY length))::NUMERIC,2)*100)::INTEGER AS c_rnk
    FROM film
),
rnk_5 AS (
  SELECT DISTINCT length AS x
        , rnk
        , c_rnk
        , MIN(length) OVER(PARTITION BY c_rnk) AS min_length
    FROM rnk_duration
   WHERE MOD(c_rnk,5) = 0 OR rnk = 1
),
percentile AS (
  SELECT  c_rnk AS perc_cont
        , x AS value
    FROM rnk_5
   WHERE x = min_length
),
percentile_w AS (
  SELECT perc_cont
       , value
       , CASE WHEN LAG(value) OVER(ORDER BY value) IS NULL
              THEN NULL
              ELSE '(' || (LAG(value) OVER(ORDER BY value))::TEXT || '  ' || value::TEXT || ']'
         END AS class
      , CASE WHEN LAG(value) OVER(ORDER BY value) IS NULL
             THEN NULL
             ELSE ROUND(value::NUMERIC - LAG(value) OVER(ORDER BY value)::NUMERIC,2)::NUMERIC
        END AS width
      , MAX(value) OVER() - MIN(value) OVER() AS range
  FROM percentile
),
dist_percentile AS (
  SELECT *
        , ROUND((SUM(width) OVER(ORDER BY value)/range)::NUMERIC,2)*100 AS cumul
    FROM percentile_w
   WHERE perc_cont >= 5
),
cumul_dist_percentile AS (
  SELECT *
        , CASE WHEN LAG(cumul) OVER(ORDER BY cumul) IS NULL
               THEN ROUND((width/range)::NUMERIC,2)*100
               ELSE ROUND((cumul - LAG(cumul) OVER(ORDER BY cumul))/range,2)*100
          END AS width_range_ratio
    FROM dist_percentile
)
SELECT *
      , LPAD('*',width_range_ratio::INTEGER,'*') AS spread_width_plot
  FROM cumul_dist_percentile;
```

```console
perc_cont | value |   class    | width | range | cumul  | width_range_ratio | spread_width_plot
----------+-------+------------+-------+-------+--------+-------------------+-------------------
        5 |    52 | (46  52]   |  6.00 |   139 |   4.00 |              4.00 | ****
       10 |    59 | (52  59]   |  7.00 |   139 |   9.00 |              4.00 | ****
       15 |    65 | (59  65]   |  6.00 |   139 |  14.00 |              4.00 | ****
       20 |    73 | (65  73]   |  8.00 |   139 |  19.00 |              4.00 | ****
       25 |    80 | (73  80]   |  7.00 |   139 |  24.00 |              4.00 | ****
       30 |    85 | (80  85]   |  5.00 |   139 |  28.00 |              3.00 | ***
       35 |    93 | (85  93]   |  8.00 |   139 |  34.00 |              4.00 | ****
       40 |   101 | (93  101]  |  8.00 |   139 |  40.00 |              4.00 | ****
       45 |   107 | (101  107] |  6.00 |   139 |  44.00 |              3.00 | ***
       50 |   114 | (107  114] |  7.00 |   139 |  49.00 |              4.00 | ****
       55 |   121 | (114  121] |  7.00 |   139 |  54.00 |              4.00 | ****
       60 |   128 | (121  128] |  7.00 |   139 |  59.00 |              4.00 | ****
       65 |   135 | (128  135] |  7.00 |   139 |  64.00 |              4.00 | ****
       70 |   142 | (135  142] |  7.00 |   139 |  69.00 |              4.00 | ****
       75 |   149 | (142  149] |  7.00 |   139 |  74.00 |              4.00 | ****
       80 |   155 | (149  155] |  6.00 |   139 |  78.00 |              3.00 | ***
       85 |   163 | (155  163] |  8.00 |   139 |  84.00 |              4.00 | ****
       90 |   172 | (163  172] |  9.00 |   139 |  91.00 |              5.00 | *****
       95 |   179 | (172  179] |  7.00 |   139 |  96.00 |              4.00 | ****
      100 |   185 | (179  185] |  6.00 |   139 | 100.00 |              3.00 | ***
(20 rows)
```

The values are a little bit more spread out on the right.
