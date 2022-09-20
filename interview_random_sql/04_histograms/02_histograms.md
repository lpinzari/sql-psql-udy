# Histograms

In this section we propose an alternative solution to the problem solved in the previous lesson [solution 1](./01_histograms.md).

```SQL
WITH duration AS (
  SELECT MIN(length) AS lower_bound
       , MAX(length) AS upper_bound
    FROM film
),
histogram AS (
  SELECT  NTILE(20) OVER (ORDER BY n) AS grp
        , n AS value
    FROM GENERATE_SERIES((SELECT lower_bound FROM duration)::INTEGER, (SELECT upper_bound FROM duration)::INTEGER) s(n)
)
SELECT grp
     , value
  FROM histogram
 ORDER BY value;
```

```console
grp | value
----+-------
  1 |    46
  1 |    47
  1 |    48
  1 |    49
  1 |    50
  1 |    51
  1 |    52
  2 |    53
  2 |    54
  2 |    55
  2 |    56
  2 |    57
  2 |    58
  2 |    59
  3 |    60
 ..      ..
```

```SQL
WITH duration AS (
  SELECT MIN(length) AS lower_bound
       , MAX(length) AS upper_bound
    FROM film
),
histogram AS (
  SELECT  NTILE(20) OVER (ORDER BY n) AS grp
        , n AS value
    FROM GENERATE_SERIES((SELECT lower_bound FROM duration)::INTEGER, (SELECT upper_bound FROM duration)::INTEGER) s(n)
),
film_cnt AS (
  SELECT  length
        , COUNT(film_id) AS dvd_cnt
    FROM  film
   GROUP BY length  
)  
SELECT h.grp AS bin_id
     , MIN(h.value)::TEXT || ' - ' || MAX(h.value) AS bucket
     , SUM(f.dvd_cnt) AS film_cnt
  FROM histogram AS h
  LEFT JOIN film_cnt AS f
    ON h.value = f.length
 GROUP BY bin_id
 ORDER BY bin_id;
```

```console
bin_id |  bucket   | film_cnt
-------+-----------+----------
     1 | 46 - 52   |       51
     2 | 53 - 59   |       45
     3 | 60 - 66   |       51
     4 | 67 - 73   |       49
     5 | 74 - 80   |       57
     6 | 81 - 87   |       57
     7 | 88 - 94   |       44
     8 | 95 - 101  |       43
     9 | 102 - 108 |       53
    10 | 109 - 115 |       61
    11 | 116 - 122 |       51
    12 | 123 - 129 |       46
    13 | 130 - 136 |       48
    14 | 137 - 143 |       52
    15 | 144 - 150 |       50
    16 | 151 - 157 |       48
    17 | 158 - 164 |       43
    18 | 165 - 171 |       39
    19 | 172 - 178 |       53
    20 | 179 - 185 |       59
(20 rows)
```

```SQL
WITH duration AS (
  SELECT MIN(length) AS lower_bound
       , MAX(length) AS upper_bound
    FROM film
),
histogram AS (
  SELECT  NTILE(20) OVER (ORDER BY n) AS grp
        , n AS value
    FROM GENERATE_SERIES((SELECT lower_bound FROM duration)::INTEGER, (SELECT upper_bound FROM duration)::INTEGER) s(n)
),
film_cnt AS (
  SELECT  length
        , COUNT(film_id) AS dvd_cnt
    FROM  film
   GROUP BY length  
),
freq_cnt AS (
  SELECT h.grp AS bin_id
       , MIN(h.value)::TEXT || ' - ' || MAX(h.value) AS bucket
       , SUM(f.dvd_cnt) AS film_cnt
    FROM histogram AS h
    LEFT JOIN film_cnt AS f
      ON h.value = f.length
   GROUP BY bin_id
)  
SELECT bin_id
     , bucket
     , film_cnt
     , LPAD('*',film_cnt::INTEGER,'*') AS film_cnt_plot
  FROM freq_cnt
 ORDER BY bin_id;
```

```console
bin_id |  bucket| film_cnt |                         film_cnt_plot
-------+--------+----------+---------------------------------------------------------------
  1 | 46 - 52   |       51 | ***************************************************
  2 | 53 - 59   |       45 | *********************************************
  3 | 60 - 66   |       51 | ***************************************************
  4 | 67 - 73   |       49 | *************************************************
  5 | 74 - 80   |       57 | *********************************************************
  6 | 81 - 87   |       57 | *********************************************************
  7 | 88 - 94   |       44 | ********************************************
  8 | 95 - 101  |       43 | *******************************************
  9 | 102 - 108 |       53 | *****************************************************
 10 | 109 - 115 |       61 | *************************************************************
 11 | 116 - 122 |       51 | ***************************************************
 12 | 123 - 129 |       46 | **********************************************
 13 | 130 - 136 |       48 | ************************************************
 14 | 137 - 143 |       52 | ****************************************************
 15 | 144 - 150 |       50 | **************************************************
 16 | 151 - 157 |       48 | ************************************************
 17 | 158 - 164 |       43 | *******************************************
 18 | 165 - 171 |       39 | ***************************************
 19 | 172 - 178 |       53 | *****************************************************
 20 | 179 - 185 |       59 | ***********************************************************
(20 rows)
```
