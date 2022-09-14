# Histograms

Say we have a `film` table, (`dvdrental` sample database):

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

where each row is a film with length in minutes:

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

### Problem 1

Task: Write a query to count the number of films that fall into bands of size 5, i.e. for the above snippet, produce something akin to:

```console
bin_id | bucket  | film_cnt |                 film_cnt_plot
-------+---------+----------+------------------------------------------------
     1 | 46-50   |       37 | *************************************
     2 | 51-55   |       31 | *******************************
     3 | 56-60   |       36 | ************************************
     4 | 61-65   |       41 | *****************************************
     5 | 66-70   |       28 | ****************************
     6 | 71-75   |       45 | *********************************************
     7 | 76-80   |       35 | ***********************************
     8 | 81-85   |       46 | **********************************************
     9 | 86-90   |       26 | **************************
    10 | 91-95   |       31 | *******************************
    11 | 96-100  |       34 | **********************************
    12 | 101-105 |       39 | ***************************************
    13 | 106-110 |       37 | *************************************
    14 | 111-115 |       45 | *********************************************
    15 | 116-120 |       32 | ********************************
    16 | 121-125 |       37 | *************************************
    17 | 126-130 |       34 | **********************************
    18 | 131-135 |       33 | *********************************
    19 | 136-140 |       40 | ****************************************
    20 | 141-145 |       36 | ************************************
    21 | 146-150 |       35 | ***********************************
    22 | 151-155 |       38 | **************************************
    23 | 156-160 |       28 | ****************************
    24 | 161-165 |       30 | ******************************
    25 | 166-170 |       26 | **************************
    26 | 171-175 |       35 | ***********************************
    27 | 176-180 |       46 | **********************************************
    28 | 181-185 |       39 | ***************************************
(28 rows)
```

### Problem 2

We want to increase the size of each bucket to smooth the duration histogram. The interval `46-185` will be partitioned into `20` buckets of `7` minutes width.

```console
bin_id | bucket  | film_cnt |                         film_cnt_plot
--------+---------+----------+---------------------------------------------------------------
     1 | 46-52   |       51 | ***************************************************
     2 | 53-59   |       45 | *********************************************
     3 | 60-66   |       51 | ***************************************************
     4 | 67-73   |       49 | *************************************************
     5 | 74-80   |       57 | *********************************************************
     6 | 81-87   |       57 | *********************************************************
     7 | 88-94   |       44 | ********************************************
     8 | 95-101  |       43 | *******************************************
     9 | 102-108 |       53 | *****************************************************
    10 | 109-115 |       61 | *************************************************************
    11 | 116-122 |       51 | ***************************************************
    12 | 123-129 |       46 | **********************************************
    13 | 130-136 |       48 | ************************************************
    14 | 137-143 |       52 | ****************************************************
    15 | 144-150 |       50 | **************************************************
    16 | 151-157 |       48 | ************************************************
    17 | 158-164 |       43 | *******************************************
    18 | 165-171 |       39 | ***************************************
    19 | 172-178 |       53 | *****************************************************
    20 | 179-185 |       59 | ***********************************************************
(20 rows)
```

### Problem 3

We want to increase the size of each bucket to smooth the duration histogram. The interval `46-185` will be partitioned into `10` buckets of `14` minutes width.

```console
bin_id | bucket  | film_cnt |                                                   film_cnt_plot
-------+---------+----------+--------------------------------------------------------------------------------------------------------------------
     1 | 46-59   |       96 | ************************************************************************************************
     2 | 60-73   |      100 | ****************************************************************************************************
     3 | 74-87   |      114 | ******************************************************************************************************************
     4 | 88-101  |       87 | ***************************************************************************************
     5 | 102-115 |      114 | ******************************************************************************************************************
     6 | 116-129 |       97 | *************************************************************************************************
     7 | 130-143 |      100 | ****************************************************************************************************
     8 | 144-157 |       98 | **************************************************************************************************
     9 | 158-171 |       82 | **********************************************************************************
    10 | 172-185 |      112 | ****************************************************************************************************************
(10 rows)
```

### Problem 4

We want to increase the size of each bucket to smooth the duration histogram. The interval `46-185` will be partitioned into `5` buckets of `28` minutes width.


```console
bin_id | bucket  | film_cnt |                                                                                                    film_cnt_plot
-------+---------+----------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
     1 | 46-73   |      196 | ****************************************************************************************************************************************************************************************************
     2 | 74-101  |      201 | *********************************************************************************************************************************************************************************************************
     3 | 102-129 |      211 | *******************************************************************************************************************************************************************************************************************
     4 | 130-157 |      198 | ******************************************************************************************************************************************************************************************************
     5 | 158-185 |      194 | **************************************************************************************************************************************************************************************************
(5 rows)
```

## Solution 1

```SQL
WITH duration AS (
  SELECT MIN(length) AS lower_bound
       , MAX(length) AS upper_bound
    FROM film
),
histogram AS (
  SELECT DISTINCT (CASE WHEN MOD(n,5) = 0
              THEN (FLOOR(n/5) - 1)
              ELSE FLOOR(n/5)
          END)::INTEGER - (FLOOR((SELECT lower_bound FROM duration)/5))::INTEGER + 1 AS bin_id
       , (1 + CASE WHEN MOD(n,5) = 0
                   THEN (FLOOR(n/5) - 1)*5
                   ELSE FLOOR(n/5)*5
              END)::TEXT || '-' ||
         (5 + CASE WHEN MOD(n,5) = 0
                   THEN (FLOOR(n/5) - 1)*5
                   ELSE FLOOR(n/5)*5
              END)::TEXT AS bin_label
    FROM GENERATE_SERIES((SELECT lower_bound FROM duration)::INTEGER, (SELECT upper_bound FROM duration)::INTEGER) s(n)
),
film_length_label AS (
  SELECT  film_id
        , title
        , length
        , (CASE WHEN MOD(length,5) = 0
                    THEN (FLOOR(length/5) - 1)
                    ELSE FLOOR(length/5)
               END)::INTEGER - (FLOOR((SELECT lower_bound FROM duration)/5))::INTEGER + 1 AS bin_id
        , (1 + CASE WHEN MOD(length,5) = 0
                    THEN (FLOOR(length/5) - 1)*5
                    ELSE FLOOR(length/5)*5
               END)::TEXT || '-' ||
          (5 + CASE WHEN MOD(length,5) = 0
                    THEN (FLOOR(length/5) - 1)*5
                    ELSE FLOOR(length/5)*5
               END)::TEXT AS bin_label
    FROM film
),
film_hist AS (
  SELECT  h.bin_id
        , h.bin_label AS bucket
        , COUNT(DISTINCT f.film_id)::INTEGER AS film_cnt
    FROM histogram h
    LEFT JOIN film_length_label f
      ON h.bin_id = f.bin_id
   GROUP BY h.bin_id, h.bin_label
)
SELECT  bin_id
      , bucket
      , film_cnt
      , LPAD('*',film_cnt,'*') AS film_cnt_plot
  FROM film_hist
 ORDER BY bin_id, bucket;
```

## Solution 2

```SQL
WITH duration AS (
  SELECT MIN(length) AS lower_bound
       , MAX(length) AS upper_bound
    FROM film
),
histogram AS (
  SELECT DISTINCT (CASE WHEN MOD(n,7) <= 3
              THEN (FLOOR(n/7) - 1)
              ELSE FLOOR(n/7)
         END)::INTEGER - (FLOOR((SELECT lower_bound FROM duration)/7))::INTEGER + 1 AS bin_id
         , (4 + CASE WHEN MOD(n,7) <= 3
                     THEN (FLOOR(n/7) - 1)*7
                     ELSE FLOOR(n/7)*7
                END)::TEXT || '-' ||
           (4 + 6 + CASE WHEN MOD(n,7) <= 3
                     THEN (FLOOR(n/7) - 1)*7
                     ELSE FLOOR(n/7)*7
                END)::TEXT AS bin_label
    FROM GENERATE_SERIES((SELECT lower_bound FROM duration)::INTEGER, (SELECT upper_bound FROM duration)::INTEGER) s(n)
),
film_length_label AS (
  SELECT  film_id
        , title
        , length
        , (CASE WHEN MOD(length,7) <= 3
                    THEN (FLOOR(length/7) - 1)
                    ELSE FLOOR(length/7)
               END)::INTEGER - (FLOOR((SELECT lower_bound FROM duration)/7))::INTEGER + 1 AS bin_id
        , (4 + CASE WHEN MOD(length,7) <= 3
                    THEN (FLOOR(length/7) - 1)*7
                    ELSE FLOOR(length/7)*7
               END)::TEXT || '-' ||
          (4 + 6 + CASE WHEN MOD(length,7) <= 3
                        THEN (FLOOR(length/7) - 1)*7
                        ELSE FLOOR(length/7)*7
                    END)::TEXT
          AS bin_label
    FROM film
),
film_hist AS (
  SELECT  h.bin_id
        , h.bin_label AS bucket
        , COUNT(DISTINCT f.film_id)::INTEGER AS film_cnt
    FROM histogram h
    LEFT JOIN film_length_label f
      ON h.bin_id = f.bin_id
   GROUP BY h.bin_id, h.bin_label
)
SELECT bin_id
     , bucket
     , film_cnt
     , LPAD('*',film_cnt,'*') AS film_cnt_plot
  FROM film_hist
 ORDER BY bin_id, bucket;
```

## Solution 3


```SQL
WITH duration AS (
  SELECT MIN(length) AS lower_bound
       , MAX(length) AS upper_bound
    FROM film
),
histogram AS (
  SELECT DISTINCT
         ((CASE WHEN MOD(n,14) <= 3
                THEN (FLOOR(n/14) - 1)
                ELSE  FLOOR(n/14)
            END) - (FLOOR((SELECT lower_bound FROM duration)/14))::INTEGER + 1)
          AS bin_id
        , (4 + CASE WHEN MOD(n,14) <= 3
                   THEN (FLOOR(n/14) - 1)*14
                   ELSE  FLOOR(n/14)*14
              END)::TEXT || '-' ||
          (14 + 3 + CASE WHEN MOD(n,14) <= 3
                     THEN (FLOOR(n/14) - 1)*14
                     ELSE  FLOOR(n/14)*14
                END)::TEXT
          AS bin_label
    FROM GENERATE_SERIES((SELECT lower_bound FROM duration)::INTEGER,(SELECT upper_bound FROM duration)::INTEGER) s(n)
),
film_length_label AS (
  SELECT  film_id
        , title
        , length
        , ((CASE WHEN MOD(length,14) <= 3
               THEN (FLOOR(length/14) - 1)
               ELSE  FLOOR(length/14)
           END) - (FLOOR((SELECT lower_bound FROM duration)/14))::INTEGER + 1)
         AS bin_id
        , (4 + CASE WHEN MOD(length,14) <= 3
                   THEN (FLOOR(length/14) - 1)*14
                   ELSE  FLOOR(length/14)*14
              END)::TEXT || '-' ||
          (14 + 3 + CASE WHEN MOD(length,14) <= 3
                     THEN (FLOOR(length/14) - 1)*14
                     ELSE  FLOOR(length/14)*14
                END)::TEXT
          AS bin_label
     FROM film
),
film_hist AS (
  SELECT  h.bin_id
        , h.bin_label AS bucket
        , COUNT(DISTINCT f.film_id)::INTEGER AS film_cnt
    FROM histogram h
    LEFT JOIN film_length_label f
      ON h.bin_id = f.bin_id
   GROUP BY h.bin_id, h.bin_label
)
SELECT bin_id
     , bucket
     , film_cnt
     , LPAD('*',film_cnt,'*') AS film_cnt_plot
  FROM film_hist
 ORDER BY bin_id, bucket;
```

## Solution 4

```SQL
WITH duration AS (
  SELECT MIN(length) AS lower_bound
       , MAX(length) AS upper_bound
    FROM film
),
histogram AS (
  SELECT DISTINCT
         ((CASE WHEN MOD(n,28) <= 17
                THEN (FLOOR(n/28) - 1)
                ELSE  FLOOR(n/28)
            END) - (FLOOR((SELECT lower_bound FROM duration)/28))::INTEGER + 1)
          AS bin_id
        , (18 + CASE WHEN MOD(n,28) <= 17
                   THEN (FLOOR(n/28) - 1)*28
                   ELSE  FLOOR(n/28)*28
              END)::TEXT || '-' ||
          (28 + 17 + CASE WHEN MOD(n,28) <= 17
                     THEN (FLOOR(n/28) - 1)*28
                     ELSE  FLOOR(n/28)*28
                END)::TEXT
          AS bin_label
    FROM GENERATE_SERIES((SELECT lower_bound FROM duration)::INTEGER,(SELECT upper_bound FROM duration)::INTEGER) s(n)
),
film_length_label AS (
  SELECT  film_id
        , title
        , length
        , ((CASE WHEN MOD(length,28) <= 17
               THEN (FLOOR(length/28) - 1)
               ELSE  FLOOR(length/28)
           END) - (FLOOR((SELECT lower_bound FROM duration)/28))::INTEGER + 1)
         AS bin_id
        , (18 + CASE WHEN MOD(length,28) <= 17
                   THEN (FLOOR(length/28) - 1)*28
                   ELSE  FLOOR(length/28)*28
              END)::TEXT || '-' ||
          (28 + 17 + CASE WHEN MOD(length,28) <= 17
                     THEN (FLOOR(length/28) - 1)*28
                     ELSE  FLOOR(length/28)*28
                END)::TEXT
          AS bin_label
     FROM film
),
film_hist AS (
  SELECT  h.bin_id
        , h.bin_label AS bucket
        , COUNT(DISTINCT f.film_id)::INTEGER AS film_cnt
    FROM histogram h
    LEFT JOIN film_length_label f
      ON h.bin_id = f.bin_id
   GROUP BY h.bin_id, h.bin_label
)
SELECT bin_id
     , bucket
     , film_cnt
     , LPAD('*',film_cnt,'*') AS film_cnt_plot
  FROM film_hist
 ORDER BY bin_id, bucket;
```

## Discussion


```SQL
SELECT  n::TEXT || '/5' AS operation
      , FLOOR(n/5) AS quotient
      , MOD(n,5) AS remainder
      , FLOOR(n/5)*5 + MOD(n,5) AS numerator
      , (FLOOR(n/5)*5)::TEXT || '-' || (FLOOR(n/5)*5 + 4)::TEXT AS bin_label
  FROM GENERATE_SERIES(0,15) s(n);
```

The trick is to use the `FLOOR` function and the modular arithmetic logic.

```console
operation | quotient | remainder | numerator | bin_label
----------+----------+-----------+-----------+-----------
0/5       |        0 |         0 |         0 | 0-4
1/5       |        0 |         1 |         1 | 0-4
2/5       |        0 |         2 |         2 | 0-4
3/5       |        0 |         3 |         3 | 0-4
4/5       |        0 |         4 |         4 | 0-4
5/5       |        1 |         0 |         5 | 5-9
6/5       |        1 |         1 |         6 | 5-9
7/5       |        1 |         2 |         7 | 5-9
8/5       |        1 |         3 |         8 | 5-9
9/5       |        1 |         4 |         9 | 5-9
10/5      |        2 |         0 |        10 | 10-14
11/5      |        2 |         1 |        11 | 10-14
12/5      |        2 |         2 |        12 | 10-14
13/5      |        2 |         3 |        13 | 10-14
14/5      |        2 |         4 |        14 | 10-14
15/5      |        3 |         0 |        15 | 15-19
(16 rows)
```

In the output table the last column indicates the bucket of the histogram. As you can see, the integer numbers has been partitioned in intervals width of size `5`. The first interval starts at zero. We want to shift the interval of a unit, `1-5`. For example the first buckets should be:

```console

  +---+---+---+---+   +---+---+---+---+
  1   2   3   4   5   6   7   8   9   10
  +---------------+   +---------------+
        1 - 5              6 - 10
```

```SQL
SELECT  n::TEXT || '/5' AS operation
      , FLOOR(n/5) AS quotient
      , MOD(n,5) AS remainder
      , FLOOR(n/5)*5 + MOD(n,5) AS numerator
      , (1 + CASE WHEN MOD(n,5) = 0
                  THEN (FLOOR(n/5) - 1)*5
                  ELSE FLOOR(n/5)*5
             END)::TEXT || '-' ||
        (5 + CASE WHEN MOD(n,5) = 0
                  THEN (FLOOR(n/5) - 1)*5
                  ELSE FLOOR(n/5)*5
             END)::TEXT AS bin_label
  FROM GENERATE_SERIES(1,15) s(n);
```

```console
operation | quotient | remainder | numerator | bin_label
----------+----------+-----------+-----------+-----------
1/5       |        0 |         1 |         1 | 1-5
2/5       |        0 |         2 |         2 | 1-5
3/5       |        0 |         3 |         3 | 1-5
4/5       |        0 |         4 |         4 | 1-5
5/5       |        1 |         0 |         5 | 1-5
----------------------------------------------------
6/5       |        1 |         1 |         6 | 6-10
7/5       |        1 |         2 |         7 | 6-10
8/5       |        1 |         3 |         8 | 6-10
9/5       |        1 |         4 |         9 | 6-10
10/5      |        2 |         0 |        10 | 6-10
-----------------------------------------------------
11/5      |        2 |         1 |        11 | 11-15
12/5      |        2 |         2 |        12 | 11-15
13/5      |        2 |         3 |        13 | 11-15
14/5      |        2 |         4 |        14 | 11-15
15/5      |        3 |         0 |        15 | 11-15
(15 rows)
```

Next, give a number id to each bucket for a graphical representation.

```SQL
SELECT  n::TEXT || '/5' AS operation
      , FLOOR(n/5) AS quotient
      , MOD(n,5) AS remainder
      , FLOOR(n/5)*5 + MOD(n,5) AS numerator
      , (CASE WHEN MOD(n,5) = 0
                  THEN (FLOOR(n/5) - 1)
                  ELSE FLOOR(n/5)
             END) AS bin_id
      , (1 + CASE WHEN MOD(n,5) = 0
                  THEN (FLOOR(n/5) - 1)*5
                  ELSE FLOOR(n/5)*5
             END)::TEXT || '-' ||
        (5 + CASE WHEN MOD(n,5) = 0
                  THEN (FLOOR(n/5) - 1)*5
                  ELSE FLOOR(n/5)*5
             END)::TEXT AS bin_label
  FROM GENERATE_SERIES(1,15) s(n);
```

```console
operation | quotient | remainder | numerator | bin_id | bin_label
----------+----------+-----------+-----------+--------+-----------
1/5       |        0 |         1 |         1 | 0      | 1-5
2/5       |        0 |         2 |         2 | 0      | 1-5
3/5       |        0 |         3 |         3 | 0      | 1-5
4/5       |        0 |         4 |         4 | 0      | 1-5
5/5       |        1 |         0 |         5 | 0      | 1-5
6/5       |        1 |         1 |         6 | 1      | 6-10
7/5       |        1 |         2 |         7 | 1      | 6-10
8/5       |        1 |         3 |         8 | 1      | 6-10
9/5       |        1 |         4 |         9 | 1      | 6-10
10/5      |        2 |         0 |        10 | 1      | 6-10
11/5      |        2 |         1 |        11 | 2      | 11-15
12/5      |        2 |         2 |        12 | 2      | 11-15
13/5      |        2 |         3 |        13 | 2      | 11-15
14/5      |        2 |         4 |        14 | 2      | 11-15
15/5      |        3 |         0 |        15 | 2      | 11-15
(15 rows)
```

Returning to the original table:

```SQL
SELECT  film_id
      , title
      , length
      , (CASE WHEN MOD(length,5) = 0
                  THEN (FLOOR(length/5) - 1)
                  ELSE FLOOR(length/5)
             END) AS bin_id
      , (1 + CASE WHEN MOD(length,5) = 0
                  THEN (FLOOR(length/5) - 1)*5
                  ELSE FLOOR(length/5)*5
             END)::TEXT || '-' ||
        (5 + CASE WHEN MOD(length,5) = 0
                  THEN (FLOOR(length/5) - 1)*5
                  ELSE FLOOR(length/5)*5
             END)::TEXT AS bin_label
  FROM film
 ORDER BY length DESC, film_id;
```

```console
film_id |            title            | length | bin_id | bin_label
--------+-----------------------------+--------+--------+-----------
    141 | Chicago North               |    185 | 36     | 181-185
    182 | Control Anthem              |    185 | 36     | 181-185
    212 | Darn Forrester              |    185 | 36     | 181-185
    349 | Gangs Pride                 |    185 | 36     | 181-185
    426 | Home Pity                   |    185 | 36     | 181-185
    609 | Muscle Bright               |    185 | 36     | 181-185
    690 | Pond Seattle                |    185 | 36     | 181-185
    817 | Soldiers Evolution          |    185 | 36     | 181-185
    872 | Sweet Brotherhood           |    185 | 36     | 181-185
    991 | Worst Banger                |    185 | 36     | 181-185
    180 | Conspiracy Spirit           |    184 | 36     | 181-185
    198 | Crystal Breaking            |    184 | 36     | 181-185
    499 | King Evolution              |    184 | 36     | 181-185
    597 | Moonwalker Fool             |    184 | 36     | 181-185
    813 | Smoochy Control             |    184 | 36     | 181-185
    820 | Sons Interview              |    184 | 36     | 181-185
    821 | Sorority Queen              |    184 | 36     | 181-185
    886 | Theory Mermaid              |    184 | 36     | 181-185
    128 | Catch Amistad               |    183 | 36     | 181-185
    340 | Frontier Cabin              |    183 | 36     | 181-185
    767 | Scalawag Duck               |    183 | 36     | 181-185
    973 | Wife Turn                   |    183 | 36     | 181-185
    996 | Young Language              |    183 | 36     | 181-185
     50 | Baked Cleopatra             |    182 | 36     | 181-185
    591 | Monsoon Cause               |    182 | 36     | 181-185
    719 | Records Zorro               |    182 | 36     | 181-185
    721 | Reds Pocus                  |    182 | 36     | 181-185
    765 | Saturn Name                 |    182 | 36     | 181-185
    774 | Searchers Wait              |    182 | 36     | 181-185
     24 | Analyze Hoosiers            |    181 | 36     | 181-185
    406 | Haunting Pianist            |    181 | 36     | 181-185
    435 | Hotel Happiness             |    181 | 36     | 181-185
    467 | Intrigue Worst              |    181 | 36     | 181-185
    473 | Jacket Frisco               |    181 | 36     | 181-185
    510 | Lawless Vision              |    181 | 36     | 181-185
    535 | Love Suicides               |    181 | 36     | 181-185
    751 | Runaway Tenenbaums          |    181 | 36     | 181-185
    841 | Star Operation              |    181 | 36     | 181-185
    974 | Wild Apollo                 |    181 | 36     | 181-185
    -------------------------------------------------------------
     16 | Alley Evolution             |    180 | 35     | 176-180
    174 | Confidential Interview      |    180 | 35     | 176-180
    454 | Impact Aladdin              |    180 | 35     | 176-180
    584 | Mixed Doors                 |    180 | 35     | 176-180
    612 | Mussolini Spoilers          |    180 | 35     | 176-180
    615 | Nash Chocolat               |    180 | 35     | 176-180
    818 | Something Duck              |    180 | 35     | 176-180
     27 | Anonymous Human             |    179 | 35     | 176-180
     88 | Born Spinal                 |    179 | 35     | 176-180
    126 | Casualties Encino           |    179 | 35     | 176-180
    129 | Cause Date                  |    179 | 35     | 176-180
    323 | Flight Lies                 |    179 | 35     | 176-180
    496 | Kick Savannah               |    179 | 35     | 176-180
    692 | Potluck Mixed               |    179 | 35     | 176-180
    720 | Redemption Comforts         |    179 | 35     | 176-180
    803 | Slacker Liaisons            |    179 | 35     | 176-180
    885 | Texas Watch                 |    179 | 35     | 176-180
    897 | Torque Bound                |    179 | 35     | 176-180
    944 | Virgin Daisy                |    179 | 35     | 176-180
    997 | Youth Kick                  |    179 | 35     | 176-180
    256 | Drop Waterfront             |    178 | 35     | 176-180
    296 | Express Lonely              |    178 | 35     | 176-180
    344 | Fury Murder                 |    178 | 35     | 176-180
    453 | Image Princess              |    178 | 35     | 176-180
    460 | Innocent Usual              |    178 | 35     | 176-180
    545 | Madness Attacks             |    178 | 35     | 176-180
    614 | Name Detective              |    178 | 35     | 176-180
    738 | Rocketeer Mother            |    178 | 35     | 176-180
    958 | Wardrobe Phantom            |    178 | 35     | 176-180
    993 | Wrong Behavior              |    178 | 35     | 176-180
    245 | Double Wrath                |    177 | 35     | 176-180
    248 | Dozen Lion                  |    177 | 35     | 176-180
    280 | Empire Malkovich            |    177 | 35     | 176-180
    557 | Manchurian Curtain          |    177 | 35     | 176-180
    707 | Quest Mussolini             |    177 | 35     | 176-180
    729 | Rider Caddyshack            |    177 | 35     | 176-180
     94 | Braveheart Human            |    176 | 35     | 176-180
    119 | Caper Motions               |    176 | 35     | 176-180
    201 | Cyclone Family              |    176 | 35     | 176-180
    249 | Dracula Crystal             |    176 | 35     | 176-180
    287 | Entrapment Satisfaction     |    176 | 35     | 176-180
    352 | Gathering Calendar          |    176 | 35     | 176-180
    380 | Greek Everyone              |    176 | 35     | 176-180
    431 | Hoosiers Birdcage           |    176 | 35     | 176-180
    871 | Sweden Shining              |    176 | 35     | 176-180
    992 | Wrath Mile                  |    176 | 35     | 176-180
```

The number of buckets is 37, starting from `1-5`.

The final step is to count the number of films in each bucket.

```SQL
WITH film_length_label AS (
  SELECT  film_id
        , title
        , length
        , (CASE WHEN MOD(length,5) = 0
                    THEN (FLOOR(length/5) - 1)
                    ELSE FLOOR(length/5)
               END) AS bin_id
        , (1 + CASE WHEN MOD(length,5) = 0
                    THEN (FLOOR(length/5) - 1)*5
                    ELSE FLOOR(length/5)*5
               END)::TEXT || '-' ||
          (5 + CASE WHEN MOD(length,5) = 0
                    THEN (FLOOR(length/5) - 1)*5
                    ELSE FLOOR(length/5)*5
               END)::TEXT AS bin_label
    FROM film
)
SELECT  bin_id
      , bin_label AS bucket
      , COUNT(DISTINCT film_id)
  FROM film_length_label
 GROUP BY bin_id, bin_label
 ORDER BY bin_id, bin_label;
```

```console
bin_id | bucket  | count
-------+---------+-------
     9 | 46-50   |    37
    10 | 51-55   |    31
    11 | 56-60   |    36
    12 | 61-65   |    41
    13 | 66-70   |    28
    14 | 71-75   |    45
    15 | 76-80   |    35
    16 | 81-85   |    46
    17 | 86-90   |    26
    18 | 91-95   |    31
    19 | 96-100  |    34
    20 | 101-105 |    39
    21 | 106-110 |    37
    22 | 111-115 |    45
    23 | 116-120 |    32
    24 | 121-125 |    37
    25 | 126-130 |    34
    26 | 131-135 |    33
    27 | 136-140 |    40
    28 | 141-145 |    36
    29 | 146-150 |    35
    30 | 151-155 |    38
    31 | 156-160 |    28
    32 | 161-165 |    30
    33 | 166-170 |    26
    34 | 171-175 |    35
    35 | 176-180 |    46
    36 | 181-185 |    39
(28 rows)
```

The output table shows that the duration of the films is greater than or equal to `46` minutes. Moreover, the interval classes below `46-50` have `count` values equal to zero. These rows are missing. The number of classes is, therefore, equal to `28`. It follows that the first class must start from bin `id` equal to 1 and not 9. Furthermore, it is possible to have bin gaps between values in the data. In this example, there are no gaps between the first and last bin. The best way to generate a histogram is to partition the `x-axis` first and then join with the data of the original table.

First identify the Lower and Upper Bound of your data.

```SQL
WITH duration_bounds AS (
  SELECT MIN(1 + CASE WHEN MOD(length,5) = 0
                      THEN (FLOOR(length/5) - 1)*5
                      ELSE FLOOR(length/5)*5
                  END) AS lower_bound
       , MAX(5 + CASE WHEN MOD(length,5) = 0
                 THEN (FLOOR(length/5) - 1)*5
                 ELSE FLOOR(length/5)*5
                  END) AS upper_bound
    FROM film
)
SELECT  lower_bound
      , upper_bound
  FROM duration_bounds;
```

```console
lower_bound | upper_bound
------------+-------------
         46 |         185
```

Next, generate the bins to accomodate the counts.

```SQL
WITH duration AS (
  SELECT MIN(1 + CASE WHEN MOD(length,5) = 0
                      THEN (FLOOR(length/5) - 1)*5
                      ELSE FLOOR(length/5)*5
                  END) AS lower_bound
       , MAX(5 + CASE WHEN MOD(length,5) = 0
                 THEN (FLOOR(length/5) - 1)*5
                 ELSE FLOOR(length/5)*5
                  END) AS upper_bound
    FROM film
),
histogram AS (
  SELECT DISTINCT (CASE WHEN MOD(n,5) = 0
              THEN (FLOOR(n/5) - 1)
              ELSE FLOOR(n/5)
          END)::INTEGER - (FLOOR((SELECT lower_bound FROM duration)/5))::INTEGER + 1 AS bin_id
       , (1 + CASE WHEN MOD(n,5) = 0
                   THEN (FLOOR(n/5) - 1)*5
                   ELSE FLOOR(n/5)*5
              END)::TEXT || '-' ||
         (5 + CASE WHEN MOD(n,5) = 0
                   THEN (FLOOR(n/5) - 1)*5
                   ELSE FLOOR(n/5)*5
              END)::TEXT AS bin_label
    FROM GENERATE_SERIES((SELECT lower_bound FROM duration)::INTEGER, (SELECT upper_bound FROM duration)::INTEGER) s(n)
)
SELECT  bin_id
      , bin_label
  FROM histogram
 ORDER BY bin_id;
```

```console
bin_id | bin_label
-------+-----------
     1 | 46-50
     2 | 51-55
     3 | 56-60
     4 | 61-65
     5 | 66-70
     6 | 71-75
     7 | 76-80
     8 | 81-85
     9 | 86-90
    10 | 91-95
    11 | 96-100
    12 | 101-105
    13 | 106-110
    14 | 111-115
    15 | 116-120
    16 | 121-125
    17 | 126-130
    18 | 131-135
    19 | 136-140
    20 | 141-145
    21 | 146-150
    22 | 151-155
    23 | 156-160
    24 | 161-165
    25 | 166-170
    26 | 171-175
    27 | 176-180
    28 | 181-185
(28 rows)
```

Next, join the histogram with the table data.

```SQL
WITH duration AS (
  SELECT MIN(1 + CASE WHEN MOD(length,5) = 0
                      THEN (FLOOR(length/5) - 1)*5
                      ELSE FLOOR(length/5)*5
                  END) AS lower_bound
       , MAX(5 + CASE WHEN MOD(length,5) = 0
                 THEN (FLOOR(length/5) - 1)*5
                 ELSE FLOOR(length/5)*5
                  END) AS upper_bound
    FROM film
),
histogram AS (
  SELECT DISTINCT (CASE WHEN MOD(n,5) = 0
              THEN (FLOOR(n/5) - 1)
              ELSE FLOOR(n/5)
          END)::INTEGER - (FLOOR((SELECT lower_bound FROM duration)/5))::INTEGER + 1 AS bin_id
       , (1 + CASE WHEN MOD(n,5) = 0
                   THEN (FLOOR(n/5) - 1)*5
                   ELSE FLOOR(n/5)*5
              END)::TEXT || '-' ||
         (5 + CASE WHEN MOD(n,5) = 0
                   THEN (FLOOR(n/5) - 1)*5
                   ELSE FLOOR(n/5)*5
              END)::TEXT AS bin_label
    FROM GENERATE_SERIES((SELECT lower_bound FROM duration)::INTEGER, (SELECT upper_bound FROM duration)::INTEGER) s(n)
),
film_length_label AS (
  SELECT  film_id
        , title
        , length
        , (CASE WHEN MOD(length,5) = 0
                    THEN (FLOOR(length/5) - 1)
                    ELSE FLOOR(length/5)
               END)::INTEGER - (FLOOR((SELECT lower_bound FROM duration)/5))::INTEGER + 1 AS bin_id
        , (1 + CASE WHEN MOD(length,5) = 0
                    THEN (FLOOR(length/5) - 1)*5
                    ELSE FLOOR(length/5)*5
               END)::TEXT || '-' ||
          (5 + CASE WHEN MOD(length,5) = 0
                    THEN (FLOOR(length/5) - 1)*5
                    ELSE FLOOR(length/5)*5
               END)::TEXT AS bin_label
    FROM film
)
SELECT *
  FROM film_length_label
 ORDER BY bin_id;
```

```console
film_id |            title            | length | bin_id | bin_label
---------+-----------------------------+--------+--------+-----------
    469 | Iron Moon                   |     46 |      1 | 46-50
    575 | Midsummer Groundhog         |     48 |      1 | 46-50
   1000 | Zorro Ark                   |     50 |      1 | 46-50
    237 | Divorce Shining             |     47 |      1 | 46-50
    243 | Doors President             |     49 |      1 | 46-50
    430 | Hook Chariots               |     49 |      1 | 46-50
     83 | Blues Instinct              |     50 |      1 | 46-50
    607 | Muppet Mile                 |     50 |      1 | 46-50
    247 | Downhill Enough             |     47 |      1 | 46-50
    617 | Natural Stock               |     50 |      1 | 46-50
    679 | Pilot Hoosiers              |     50 |      1 | 46-50
    630 | Notting Speakeasy           |     48 |      1 | 46-50
    443 | Hurricane Affair            |     49 |      1 | 46-50
    384 | Grosse Wonderful            |     49 |      1 | 46-50
    931 | Valentine Vanishing         |     48 |      1 | 46-50
     15 | Alien Center                |     46 |      1 | 46-50
    634 | Odds Boogie                 |     48 |      1 | 46-50
    670 | Pelican Comforts            |     48 |      1 | 46-50
    393 | Halloween Nuts              |     47 |      1 | 46-50
    657 | Paradise Sabrina            |     48 |      1 | 46-50
    812 | Smoking Barbarella          |     50 |      1 | 46-50
    192 | Crossing Divorce            |     50 |      1 | 46-50
    784 | Shanghai Tycoon             |     47 |      1 | 46-50
    504 | Kwai Homeward               |     46 |      1 | 46-50
    505 | Labyrinth League            |     46 |      1 | 46-50
      2 | Ace Goldfinger              |     48 |      1 | 46-50
    753 | Rush Goodfellas             |     48 |      1 | 46-50
      3 | Adaptation Holes            |     50 |      1 | 46-50
    524 | Lion Uncut                  |     50 |      1 | 46-50
    410 | Heaven Freedom              |     48 |      1 | 46-50
    845 | Stepmom Dream               |     48 |      1 | 46-50
    407 | Hawk Chill                  |     47 |      1 | 46-50
    866 | Sunset Racer                |     48 |      1 | 46-50
    411 | Heavenly Gun                |     49 |      1 | 46-50
    398 | Hanover Galaxy              |     47 |      1 | 46-50
    730 | Ridgemont Submarine         |     46 |      1 | 46-50
    869 | Suspects Quills             |     47 |      1 | 46-50
    799 | Simon North                 |     51 |      2 | 51-55
```

Finally, left join with the histogram table.

```SQL
WITH duration AS (
  SELECT MIN(1 + CASE WHEN MOD(length,5) = 0
                      THEN (FLOOR(length/5) - 1)*5
                      ELSE FLOOR(length/5)*5
                  END) AS lower_bound
       , MAX(5 + CASE WHEN MOD(length,5) = 0
                 THEN (FLOOR(length/5) - 1)*5
                 ELSE FLOOR(length/5)*5
                  END) AS upper_bound
    FROM film
),
histogram AS (
  SELECT DISTINCT (CASE WHEN MOD(n,5) = 0
              THEN (FLOOR(n/5) - 1)
              ELSE FLOOR(n/5)
          END)::INTEGER - (FLOOR((SELECT lower_bound FROM duration)/5))::INTEGER + 1 AS bin_id
       , (1 + CASE WHEN MOD(n,5) = 0
                   THEN (FLOOR(n/5) - 1)*5
                   ELSE FLOOR(n/5)*5
              END)::TEXT || '-' ||
         (5 + CASE WHEN MOD(n,5) = 0
                   THEN (FLOOR(n/5) - 1)*5
                   ELSE FLOOR(n/5)*5
              END)::TEXT AS bin_label
    FROM GENERATE_SERIES((SELECT lower_bound FROM duration)::INTEGER, (SELECT upper_bound FROM duration)::INTEGER) s(n)
),
film_length_label AS (
  SELECT  film_id
        , title
        , length
        , (CASE WHEN MOD(length,5) = 0
                    THEN (FLOOR(length/5) - 1)
                    ELSE FLOOR(length/5)
               END)::INTEGER - (FLOOR((SELECT lower_bound FROM duration)/5))::INTEGER + 1 AS bin_id
        , (1 + CASE WHEN MOD(length,5) = 0
                    THEN (FLOOR(length/5) - 1)*5
                    ELSE FLOOR(length/5)*5
               END)::TEXT || '-' ||
          (5 + CASE WHEN MOD(length,5) = 0
                    THEN (FLOOR(length/5) - 1)*5
                    ELSE FLOOR(length/5)*5
               END)::TEXT AS bin_label
    FROM film
)
SELECT  h.bin_id
      , h.bin_label AS bucket
      , COUNT(DISTINCT f.film_id)
  FROM histogram h
  LEFT JOIN film_length_label f
    ON h.bin_id = f.bin_id
 GROUP BY h.bin_id, h.bin_label
 ORDER BY h.bin_id, h.bin_label;
```

```console
bin_id | bucket  | count
-------+---------+-------
     1 | 46-50   |    37
     2 | 51-55   |    31
     3 | 56-60   |    36
     4 | 61-65   |    41
     5 | 66-70   |    28
     6 | 71-75   |    45
     7 | 76-80   |    35
     8 | 81-85   |    46
     9 | 86-90   |    26
    10 | 91-95   |    31
    11 | 96-100  |    34
    12 | 101-105 |    39
    13 | 106-110 |    37
    14 | 111-115 |    45
    15 | 116-120 |    32
    16 | 121-125 |    37
    17 | 126-130 |    34
    18 | 131-135 |    33
    19 | 136-140 |    40
    20 | 141-145 |    36
    21 | 146-150 |    35
    22 | 151-155 |    38
    23 | 156-160 |    28
    24 | 161-165 |    30
    25 | 166-170 |    26
    26 | 171-175 |    35
    27 | 176-180 |    46
    28 | 181-185 |    39
(28 rows)
```

Lastly, plot the histogram.

```SQL
WITH duration AS (
  SELECT MIN(1 + CASE WHEN MOD(length,5) = 0
                      THEN (FLOOR(length/5) - 1)*5
                      ELSE FLOOR(length/5)*5
                  END) AS lower_bound
       , MAX(5 + CASE WHEN MOD(length,5) = 0
                 THEN (FLOOR(length/5) - 1)*5
                 ELSE FLOOR(length/5)*5
                  END) AS upper_bound
    FROM film
),
histogram AS (
  SELECT DISTINCT (CASE WHEN MOD(n,5) = 0
              THEN (FLOOR(n/5) - 1)
              ELSE FLOOR(n/5)
          END)::INTEGER - (FLOOR((SELECT lower_bound FROM duration)/5))::INTEGER + 1 AS bin_id
       , (1 + CASE WHEN MOD(n,5) = 0
                   THEN (FLOOR(n/5) - 1)*5
                   ELSE FLOOR(n/5)*5
              END)::TEXT || '-' ||
         (5 + CASE WHEN MOD(n,5) = 0
                   THEN (FLOOR(n/5) - 1)*5
                   ELSE FLOOR(n/5)*5
              END)::TEXT AS bin_label
    FROM GENERATE_SERIES((SELECT lower_bound FROM duration)::INTEGER, (SELECT upper_bound FROM duration)::INTEGER) s(n)
),
film_length_label AS (
  SELECT  film_id
        , title
        , length
        , (CASE WHEN MOD(length,5) = 0
                    THEN (FLOOR(length/5) - 1)
                    ELSE FLOOR(length/5)
               END)::INTEGER - (FLOOR((SELECT lower_bound FROM duration)/5))::INTEGER + 1 AS bin_id
        , (1 + CASE WHEN MOD(length,5) = 0
                    THEN (FLOOR(length/5) - 1)*5
                    ELSE FLOOR(length/5)*5
               END)::TEXT || '-' ||
          (5 + CASE WHEN MOD(length,5) = 0
                    THEN (FLOOR(length/5) - 1)*5
                    ELSE FLOOR(length/5)*5
               END)::TEXT AS bin_label
    FROM film
),
film_hist AS (
  SELECT  h.bin_id
        , h.bin_label AS bucket
        , COUNT(DISTINCT f.film_id)::INTEGER AS film_cnt
    FROM histogram h
    LEFT JOIN film_length_label f
      ON h.bin_id = f.bin_id
   GROUP BY h.bin_id, h.bin_label
)
SELECT  bin_id
      , bucket
      , film_cnt
      , LPAD('*',film_cnt,'*') AS film_cnt_plot
  FROM film_hist
 ORDER BY bin_id, bucket;
```

```console
bin_id | bucket  | film_cnt |                 film_cnt_plot
-------+---------+----------+------------------------------------------------
     1 | 46-50   |       37 | *************************************
     2 | 51-55   |       31 | *******************************
     3 | 56-60   |       36 | ************************************
     4 | 61-65   |       41 | *****************************************
     5 | 66-70   |       28 | ****************************
     6 | 71-75   |       45 | *********************************************
     7 | 76-80   |       35 | ***********************************
     8 | 81-85   |       46 | **********************************************
     9 | 86-90   |       26 | **************************
    10 | 91-95   |       31 | *******************************
    11 | 96-100  |       34 | **********************************
    12 | 101-105 |       39 | ***************************************
    13 | 106-110 |       37 | *************************************
    14 | 111-115 |       45 | *********************************************
    15 | 116-120 |       32 | ********************************
    16 | 121-125 |       37 | *************************************
    17 | 126-130 |       34 | **********************************
    18 | 131-135 |       33 | *********************************
    19 | 136-140 |       40 | ****************************************
    20 | 141-145 |       36 | ************************************
    21 | 146-150 |       35 | ***********************************
    22 | 151-155 |       38 | **************************************
    23 | 156-160 |       28 | ****************************
    24 | 161-165 |       30 | ******************************
    25 | 166-170 |       26 | **************************
    26 | 171-175 |       35 | ***********************************
    27 | 176-180 |       46 | **********************************************
    28 | 181-185 |       39 | ***************************************
(28 rows)
```

### Problem 2

```SQL
SELECT  n::TEXT || '/7' AS operation
      , FLOOR(n/7) AS quotient
      , MOD(n,7) AS remainder
      , FLOOR(n/7)*7 + MOD(n,7) AS numerator
      , (CASE WHEN MOD(n,7) = 0
                  THEN (FLOOR(n/7) - 1)
                  ELSE FLOOR(n/7)
             END) AS bin_id
      , (1 + CASE WHEN MOD(n,7) = 0
                  THEN (FLOOR(n/7) - 1)*7
                  ELSE FLOOR(n/7)*7
             END)::TEXT || '-' ||
        (7 + CASE WHEN MOD(n,7) = 0
                  THEN (FLOOR(n/7) - 1)*7
                  ELSE FLOOR(n/7)*7
             END)::TEXT AS bin_label
  FROM GENERATE_SERIES(46,52) s(n);
```

```console
operation | quotient | remainder | numerator | bin_id | bin_label
----------+----------+-----------+-----------+--------+-----------
46/7      |        6 |         4 |        46 |      6 | 43-49
47/7      |        6 |         5 |        47 |      6 | 43-49
48/7      |        6 |         6 |        48 |      6 | 43-49
49/7      |        7 |         0 |        49 |      6 | 43-49
50/7      |        7 |         1 |        50 |      7 | 50-56
51/7      |        7 |         2 |        51 |      7 | 50-56
52/7      |        7 |         3 |        52 |      7 | 50-56
```

The output table shows that the range `46-52` is partitioned into two buckets. We want a single bucket. The trick is always the modular arithmetic and the remainder value.

```console
operation | quotient | remainder | numerator | bin_id | bin_label
----------+----------+-----------+-----------+--------+-----------
4/7       |        0 |         4 |         4 |      0 | 1-7
5/7       |        0 |         5 |         5 |      0 | 1-7
6/7       |        0 |         6 |         6 |      0 | 1-7
7/7       |        1 |         0 |         7 |      0 | 1-7
8/7       |        1 |         1 |         8 |      1 | 8-14
9/7       |        1 |         2 |         9 |      1 | 8-14
```

We want the first offset equal to `4`.


```SQL
SELECT  n::TEXT || '/7' AS operation
      , FLOOR(n/7) AS quotient
      , MOD(n,7) AS remainder
      , FLOOR(n/7)*7 + MOD(n,7) AS numerator
      , (CASE WHEN MOD(n,7) <= 3
                  THEN (FLOOR(n/7) - 1)
                  ELSE FLOOR(n/7)
             END) AS bin_id
      , (4 + CASE WHEN MOD(n,7) <= 3
                  THEN (FLOOR(n/7) - 1)*7
                  ELSE FLOOR(n/7)*7
             END)::TEXT || '-' ||
        (4 + 6 + CASE WHEN MOD(n,7) <= 3
                  THEN (FLOOR(n/7) - 1)*7
                  ELSE FLOOR(n/7)*7
             END)::TEXT AS bin_label
  FROM GENERATE_SERIES(4,53) s(n);
```

```console
operation | quotient | remainder | numerator | bin_id | bin_label
-----------+----------+-----------+-----------+--------+-----------
4/7       |        0 |         4 |         4 |      0 | 4-10
5/7       |        0 |         5 |         5 |      0 | 4-10
6/7       |        0 |         6 |         6 |      0 | 4-10
7/7       |        1 |         0 |         7 |      0 | 4-10
8/7       |        1 |         1 |         8 |      0 | 4-10
9/7       |        1 |         2 |         9 |      0 | 4-10
10/7      |        1 |         3 |        10 |      0 | 4-10
--------------------------------------------------------------
11/7      |        1 |         4 |        11 |      1 | 11-17
12/7      |        1 |         5 |        12 |      1 | 11-17
13/7      |        1 |         6 |        13 |      1 | 11-17
14/7      |        2 |         0 |        14 |      1 | 11-17
15/7      |        2 |         1 |        15 |      1 | 11-17
16/7      |        2 |         2 |        16 |      1 | 11-17
17/7      |        2 |         3 |        17 |      1 | 11-17
...       |      ... |       ... |       ... |    ... | ...
46/7      |        6 |         4 |        46 |      6 | 46-52
47/7      |        6 |         5 |        47 |      6 | 46-52
48/7      |        6 |         6 |        48 |      6 | 46-52
49/7      |        7 |         0 |        49 |      6 | 46-52
50/7      |        7 |         1 |        50 |      6 | 46-52
51/7      |        7 |         2 |        51 |      6 | 46-52
52/7      |        7 |         3 |        52 |      6 | 46-52
-------------------------------------------------------------
53/7      |        7 |         4 |        53 |      7 | 53-59
```

```SQL
WITH duration AS (
  SELECT MIN(4 + CASE WHEN MOD(length,7) <= 3
                      THEN (FLOOR(length/7) - 1)*7
                      ELSE FLOOR(length/7)*7
                  END)
         AS lower_bound
       , MAX(4 + 6 + CASE WHEN MOD(length,7) <= 3
                          THEN (FLOOR(length/7) - 1)*7
                          ELSE FLOOR(length/7)*7
                      END)
         AS upper_bound
    FROM film
)
SELECT *
  FROM duration;
```

```console
lower_bound | upper_bound
------------+-------------
         46 |         185
(1 row)
```

```SQL
WITH duration AS (
  SELECT MIN(4 + CASE WHEN MOD(length,7) <= 3
                      THEN (FLOOR(length/7) - 1)*7
                      ELSE FLOOR(length/7)*7
                  END)
         AS lower_bound
       , MAX(4 + 6 + CASE WHEN MOD(length,7) <= 3
                          THEN (FLOOR(length/7) - 1)*7
                          ELSE FLOOR(length/7)*7
                      END)
         AS upper_bound
    FROM film
),
histogram AS (
  SELECT DISTINCT (CASE WHEN MOD(n,7) <= 3
              THEN (FLOOR(n/7) - 1)
              ELSE FLOOR(n/7)
         END)::INTEGER - (FLOOR((SELECT lower_bound FROM duration)/7))::INTEGER + 1 AS bin_id
         , (4 + CASE WHEN MOD(n,7) <= 3
                     THEN (FLOOR(n/7) - 1)*7
                     ELSE FLOOR(n/7)*7
                END)::TEXT || '-' ||
           (4 + 6 + CASE WHEN MOD(n,7) <= 3
                     THEN (FLOOR(n/7) - 1)*7
                     ELSE FLOOR(n/7)*7
                END)::TEXT AS bin_label
    FROM GENERATE_SERIES((SELECT lower_bound FROM duration)::INTEGER, (SELECT upper_bound FROM duration)::INTEGER) s(n)
)
SELECT *
  FROM histogram
  ORDER BY bin_id;
```

```console
bin_id | bin_label
-------+-----------
     1 | 46-52
     2 | 53-59
     3 | 60-66
     4 | 67-73
     5 | 74-80
     6 | 81-87
     7 | 88-94
     8 | 95-101
     9 | 102-108
    10 | 109-115
    11 | 116-122
    12 | 123-129
    13 | 130-136
    14 | 137-143
    15 | 144-150
    16 | 151-157
    17 | 158-164
    18 | 165-171
    19 | 172-178
    20 | 179-185
(20 rows)
```

```SQL
WITH duration AS (
  SELECT MIN(4 + CASE WHEN MOD(length,7) <= 3
                      THEN (FLOOR(length/7) - 1)*7
                      ELSE FLOOR(length/7)*7
                  END)
         AS lower_bound
       , MAX(4 + 6 + CASE WHEN MOD(length,7) <= 3
                          THEN (FLOOR(length/7) - 1)*7
                          ELSE FLOOR(length/7)*7
                      END)
         AS upper_bound
    FROM film
),
histogram AS (
  SELECT DISTINCT (CASE WHEN MOD(n,7) <= 3
              THEN (FLOOR(n/7) - 1)
              ELSE FLOOR(n/7)
         END)::INTEGER - (FLOOR((SELECT lower_bound FROM duration)/7))::INTEGER + 1 AS bin_id
         , (4 + CASE WHEN MOD(n,7) <= 3
                     THEN (FLOOR(n/7) - 1)*7
                     ELSE FLOOR(n/7)*7
                END)::TEXT || '-' ||
           (4 + 6 + CASE WHEN MOD(n,7) <= 3
                     THEN (FLOOR(n/7) - 1)*7
                     ELSE FLOOR(n/7)*7
                END)::TEXT AS bin_label
    FROM GENERATE_SERIES((SELECT lower_bound FROM duration)::INTEGER, (SELECT upper_bound FROM duration)::INTEGER) s(n)
),
film_length_label AS (
  SELECT  film_id
        , title
        , length
        , (CASE WHEN MOD(length,7) <= 3
                    THEN (FLOOR(length/7) - 1)
                    ELSE FLOOR(length/7)
               END)::INTEGER - (FLOOR((SELECT lower_bound FROM duration)/7))::INTEGER + 1 AS bin_id
        , (4 + CASE WHEN MOD(length,7) <= 3
                    THEN (FLOOR(length/7) - 1)*7
                    ELSE FLOOR(length/7)*7
               END)::TEXT || '-' ||
          (4 + 6 + CASE WHEN MOD(length,7) <= 3
                        THEN (FLOOR(length/7) - 1)*7
                        ELSE FLOOR(length/7)*7
                    END)::TEXT
          AS bin_label
    FROM film
)
SELECT *
  FROM film_length_label
 ORDER BY bin_id, length, film_id;
```

```console
film_id |            title            | length | bin_id | bin_label
--------+-----------------------------+--------+--------+-----------
     15 | Alien Center                |     46 |      1 | 46-52
    469 | Iron Moon                   |     46 |      1 | 46-52
    504 | Kwai Homeward               |     46 |      1 | 46-52
    505 | Labyrinth League            |     46 |      1 | 46-52
    730 | Ridgemont Submarine         |     46 |      1 | 46-52
    237 | Divorce Shining             |     47 |      1 | 46-52
    247 | Downhill Enough             |     47 |      1 | 46-52
    393 | Halloween Nuts              |     47 |      1 | 46-52
    398 | Hanover Galaxy              |     47 |      1 | 46-52
    407 | Hawk Chill                  |     47 |      1 | 46-52
    784 | Shanghai Tycoon             |     47 |      1 | 46-52
    869 | Suspects Quills             |     47 |      1 | 46-52
      2 | Ace Goldfinger              |     48 |      1 | 46-52
    410 | Heaven Freedom              |     48 |      1 | 46-52
    575 | Midsummer Groundhog         |     48 |      1 | 46-52
    630 | Notting Speakeasy           |     48 |      1 | 46-52
    634 | Odds Boogie                 |     48 |      1 | 46-52
    657 | Paradise Sabrina            |     48 |      1 | 46-52
    670 | Pelican Comforts            |     48 |      1 | 46-52
    753 | Rush Goodfellas             |     48 |      1 | 46-52
    845 | Stepmom Dream               |     48 |      1 | 46-52
    866 | Sunset Racer                |     48 |      1 | 46-52
    931 | Valentine Vanishing         |     48 |      1 | 46-52
    243 | Doors President             |     49 |      1 | 46-52
    384 | Grosse Wonderful            |     49 |      1 | 46-52
    411 | Heavenly Gun                |     49 |      1 | 46-52
    430 | Hook Chariots               |     49 |      1 | 46-52
    443 | Hurricane Affair            |     49 |      1 | 46-52
      3 | Adaptation Holes            |     50 |      1 | 46-52
     83 | Blues Instinct              |     50 |      1 | 46-52
    192 | Crossing Divorce            |     50 |      1 | 46-52
    524 | Lion Uncut                  |     50 |      1 | 46-52
    607 | Muppet Mile                 |     50 |      1 | 46-52
    617 | Natural Stock               |     50 |      1 | 46-52
    679 | Pilot Hoosiers              |     50 |      1 | 46-52
    812 | Smoking Barbarella          |     50 |      1 | 46-52
   1000 | Zorro Ark                   |     50 |      1 | 46-52
    134 | Champion Flatliners         |     51 |      1 | 46-52
    219 | Deep Crusade                |     51 |      1 | 46-52
    285 | English Bulworth            |     51 |      1 | 46-52
    292 | Excitement Eve              |     51 |      1 | 46-52
    338 | Frisco Forrest              |     51 |      1 | 46-52
    392 | Hall Cassidy                |     51 |      1 | 46-52
    799 | Simon North                 |     51 |      1 | 46-52
    111 | Caddyshack Jedi             |     52 |      1 | 46-52
    402 | Harper Dying                |     52 |      1 | 46-52
    542 | Lust Lock                   |     52 |      1 | 46-52
    794 | Side Ark                    |     52 |      1 | 46-52
    824 | Spartacus Cheaper           |     52 |      1 | 46-52
    912 | Trojan Tomorrow             |     52 |      1 | 46-52
    970 | Westward Seabiscuit         |     52 |      1 | 46-52
     66 | Beneath Rush                |     53 |      2 | 53-59
    110 | Cabin Flash                 |     53 |      2 | 53-59
    386 | Gump Date                   |     53 |      2 | 53-59
```

Next, join the tables.

```SQL
WITH duration AS (
  SELECT MIN(4 + CASE WHEN MOD(length,7) <= 3
                      THEN (FLOOR(length/7) - 1)*7
                      ELSE FLOOR(length/7)*7
                  END)
         AS lower_bound
       , MAX(4 + 6 + CASE WHEN MOD(length,7) <= 3
                          THEN (FLOOR(length/7) - 1)*7
                          ELSE FLOOR(length/7)*7
                      END)
         AS upper_bound
    FROM film
),
histogram AS (
  SELECT DISTINCT (CASE WHEN MOD(n,7) <= 3
              THEN (FLOOR(n/7) - 1)
              ELSE FLOOR(n/7)
         END)::INTEGER - (FLOOR((SELECT lower_bound FROM duration)/7))::INTEGER + 1 AS bin_id
         , (4 + CASE WHEN MOD(n,7) <= 3
                     THEN (FLOOR(n/7) - 1)*7
                     ELSE FLOOR(n/7)*7
                END)::TEXT || '-' ||
           (4 + 6 + CASE WHEN MOD(n,7) <= 3
                     THEN (FLOOR(n/7) - 1)*7
                     ELSE FLOOR(n/7)*7
                END)::TEXT AS bin_label
    FROM GENERATE_SERIES((SELECT lower_bound FROM duration)::INTEGER, (SELECT upper_bound FROM duration)::INTEGER) s(n)
),
film_length_label AS (
  SELECT  film_id
        , title
        , length
        , (CASE WHEN MOD(length,7) <= 3
                    THEN (FLOOR(length/7) - 1)
                    ELSE FLOOR(length/7)
               END)::INTEGER - (FLOOR((SELECT lower_bound FROM duration)/7))::INTEGER + 1 AS bin_id
        , (4 + CASE WHEN MOD(length,7) <= 3
                    THEN (FLOOR(length/7) - 1)*7
                    ELSE FLOOR(length/7)*7
               END)::TEXT || '-' ||
          (4 + 6 + CASE WHEN MOD(length,7) <= 3
                        THEN (FLOOR(length/7) - 1)*7
                        ELSE FLOOR(length/7)*7
                    END)::TEXT
          AS bin_label
    FROM film
),
film_hist AS (
  SELECT  h.bin_id
        , h.bin_label AS bucket
        , COUNT(DISTINCT f.film_id)::INTEGER AS film_cnt
    FROM histogram h
    LEFT JOIN film_length_label f
      ON h.bin_id = f.bin_id
   GROUP BY h.bin_id, h.bin_label
)
SELECT bin_id
     , bucket
     , film_cnt
     , LPAD('*',film_cnt,'*') AS film_cnt_plot
  FROM film_hist
 ORDER BY bin_id, bucket;
```

## Problem 3

```SQL
SELECT  n::TEXT || '/14' AS operation
      , FLOOR(n/14) AS quotient
      , MOD(n,14) AS remainder
      , FLOOR(n/14)*14 + MOD(n,14) AS numerator
      , (CASE WHEN MOD(n,14) = 0
                  THEN (FLOOR(n/14) - 1)
                  ELSE FLOOR(n/14)
             END) AS bin_id
      , (1 + CASE WHEN MOD(n,14) = 0
                  THEN (FLOOR(n/14) - 1)*14
                  ELSE FLOOR(n/14)*14
             END)::TEXT || '-' ||
        (14 + CASE WHEN MOD(n,14) = 0
                  THEN (FLOOR(n/14) - 1)*14
                  ELSE FLOOR(n/14)*14
             END)::TEXT AS bin_label
  FROM GENERATE_SERIES(1,59) s(n);
```

```console
operation | quotient | remainder | numerator | bin_id | bin_label
----------+----------+-----------+-----------+--------+-----------
1/14      |        0 |         1 |         1 |      0 | 1-14
2/14      |        0 |         2 |         2 |      0 | 1-14
3/14      |        0 |         3 |         3 |      0 | 1-14
4/14      |        0 |         4 |         4 |      0 | 1-14
5/14      |        0 |         5 |         5 |      0 | 1-14
6/14      |        0 |         6 |         6 |      0 | 1-14
7/14      |        0 |         7 |         7 |      0 | 1-14
8/14      |        0 |         8 |         8 |      0 | 1-14
9/14      |        0 |         9 |         9 |      0 | 1-14
10/14     |        0 |        10 |        10 |      0 | 1-14
11/14     |        0 |        11 |        11 |      0 | 1-14
12/14     |        0 |        12 |        12 |      0 | 1-14
13/14     |        0 |        13 |        13 |      0 | 1-14
14/14     |        1 |         0 |        14 |      0 | 1-14
15/14     |        1 |         1 |        15 |      1 | 15-28
16/14     |        1 |         2 |        16 |      1 | 15-28
17/14     |        1 |         3 |        17 |      1 | 15-28
18/14     |        1 |         4 |        18 |      1 | 15-28
19/14     |        1 |         5 |        19 |      1 | 15-28
20/14     |        1 |         6 |        20 |      1 | 15-28
21/14     |        1 |         7 |        21 |      1 | 15-28
22/14     |        1 |         8 |        22 |      1 | 15-28
23/14     |        1 |         9 |        23 |      1 | 15-28
24/14     |        1 |        10 |        24 |      1 | 15-28
25/14     |        1 |        11 |        25 |      1 | 15-28
26/14     |        1 |        12 |        26 |      1 | 15-28
27/14     |        1 |        13 |        27 |      1 | 15-28
28/14     |        2 |         0 |        28 |      1 | 15-28
29/14     |        2 |         1 |        29 |      2 | 29-42
30/14     |        2 |         2 |        30 |      2 | 29-42
31/14     |        2 |         3 |        31 |      2 | 29-42
32/14     |        2 |         4 |        32 |      2 | 29-42
33/14     |        2 |         5 |        33 |      2 | 29-42
34/14     |        2 |         6 |        34 |      2 | 29-42
35/14     |        2 |         7 |        35 |      2 | 29-42
36/14     |        2 |         8 |        36 |      2 | 29-42
37/14     |        2 |         9 |        37 |      2 | 29-42
38/14     |        2 |        10 |        38 |      2 | 29-42
39/14     |        2 |        11 |        39 |      2 | 29-42
40/14     |        2 |        12 |        40 |      2 | 29-42
41/14     |        2 |        13 |        41 |      2 | 29-42
42/14     |        3 |         0 |        42 |      2 | 29-42
43/14     |        3 |         1 |        43 |      3 | 43-56 <---+
44/14     |        3 |         2 |        44 |      3 | 43-56     |
45/14     |        3 |         3 |        45 |      3 | 43-56     |
46/14     |        3 |         4 |        46 |      3 | 43-56 <---+
```

```SQL
SELECT  n::TEXT || '/14' AS operation
      , FLOOR(n/14) AS quotient
      , MOD(n,14) AS remainder
      , FLOOR(n/14)*14 + MOD(n,14) AS numerator
      , FLOOR(n/14) AS bin_id
      , (FLOOR(n/14)*14)::TEXT || '-' ||
        (14 + FLOOR(n/14)*14)::TEXT AS bin_label
  FROM GENERATE_SERIES(0,59) s(n);
```

```console
operation | quotient | remainder | numerator | bin_id | bin_label
----------+----------+-----------+-----------+--------+-----------
0/14      |        0 |         0 |         0 |      0 | 0-14 ----+
1/14      |        0 |         1 |         1 |      0 | 0-14     |
2/14      |        0 |         2 |         2 |      0 | 0-14     |
3/14      |        0 |         3 |         3 |      0 | 0-14     |
4/14      |        0 |         4 |         4 |      0 | 0-14 <---+ 4 - 17 +
5/14      |        0 |         5 |         5 |      0 | 0-14              |
6/14      |        0 |         6 |         6 |      0 | 0-14              |
7/14      |        0 |         7 |         7 |      0 | 0-14              |
8/14      |        0 |         8 |         8 |      0 | 0-14              |
9/14      |        0 |         9 |         9 |      0 | 0-14              |
10/14     |        0 |        10 |        10 |      0 | 0-14              |
11/14     |        0 |        11 |        11 |      0 | 0-14              |
12/14     |        0 |        12 |        12 |      0 | 0-14              |
13/14     |        0 |        13 |        13 |      0 | 0-14              |
14/14     |        1 |         0 |        14 |      1 | 14-28             |
15/14     |        1 |         1 |        15 |      1 | 14-28             |
16/14     |        1 |         2 |        16 |      1 | 14-28             |
17/14     |        1 |         3 |        17 |      1 | 14-28 <-----------+
18/14     |        1 |         4 |        18 |      1 | 14-28
19/14     |        1 |         5 |        19 |      1 | 14-28
20/14     |        1 |         6 |        20 |      1 | 14-28
21/14     |        1 |         7 |        21 |      1 | 14-28
22/14     |        1 |         8 |        22 |      1 | 14-28
23/14     |        1 |         9 |        23 |      1 | 14-28
24/14     |        1 |        10 |        24 |      1 | 14-28
25/14     |        1 |        11 |        25 |      1 | 14-28
26/14     |        1 |        12 |        26 |      1 | 14-28
27/14     |        1 |        13 |        27 |      1 | 14-28
28/14     |        2 |         0 |        28 |      2 | 28-42
29/14     |        2 |         1 |        29 |      2 | 28-42
30/14     |        2 |         2 |        30 |      2 | 28-42
31/14     |        2 |         3 |        31 |      2 | 28-42
32/14     |        2 |         4 |        32 |      2 | 28-42
33/14     |        2 |         5 |        33 |      2 | 28-42
34/14     |        2 |         6 |        34 |      2 | 28-42
35/14     |        2 |         7 |        35 |      2 | 28-42
36/14     |        2 |         8 |        36 |      2 | 28-42
37/14     |        2 |         9 |        37 |      2 | 28-42
38/14     |        2 |        10 |        38 |      2 | 28-42
39/14     |        2 |        11 |        39 |      2 | 28-42
40/14     |        2 |        12 |        40 |      2 | 28-42
41/14     |        2 |        13 |        41 |      2 | 28-42 ----+
42/14     |        3 |         0 |        42 |      3 | 42-56     |
43/14     |        3 |         1 |        43 |      3 | 42-56     |
44/14     |        3 |         2 |        44 |      3 | 42-56     |
45/14     |        3 |         3 |        45 |      3 | 42-56 <---+
46/14     |        3 |         4 |        46 |      3 | 42-56 START
47/14     |        3 |         5 |        47 |      3 | 42-56
48/14     |        3 |         6 |        48 |      3 | 42-56
49/14     |        3 |         7 |        49 |      3 | 42-56
50/14     |        3 |         8 |        50 |      3 | 42-56
51/14     |        3 |         9 |        51 |      3 | 42-56
52/14     |        3 |        10 |        52 |      3 | 42-56
53/14     |        3 |        11 |        53 |      3 | 42-56
54/14     |        3 |        12 |        54 |      3 | 42-56
55/14     |        3 |        13 |        55 |      3 | 42-56
56/14     |        4 |         0 |        56 |      4 | 56-70
57/14     |        4 |         1 |        57 |      4 | 56-70
58/14     |        4 |         2 |        58 |      4 | 56-70
59/14     |        4 |         3 |        59 |      4 | 56-70
(60 rows)
```

```SQL
SELECT  n::TEXT || '/14' AS operation
      , FLOOR(n/14) AS quotient
      , MOD(n,14) AS remainder
      , FLOOR(n/14)*14 + MOD(n,14) AS numerator
      , (CASE WHEN MOD(n,14) <= 3
                 THEN (FLOOR(n/14) - 1)
                 ELSE  FLOOR(n/14)
            END)::TEXT
        AS bin_id
      , (4 + CASE WHEN MOD(n,14) <= 3
                 THEN (FLOOR(n/14) - 1)*14
                 ELSE  FLOOR(n/14)*14
            END)::TEXT || '-' ||
        (14 + 3 + CASE WHEN MOD(n,14) <= 3
                   THEN (FLOOR(n/14) - 1)*14
                   ELSE  FLOOR(n/14)*14
              END)::TEXT
        AS bin_label
  FROM GENERATE_SERIES(4,59) s(n);
```

```console
operation | quotient | remainder | numerator | bin_id | bin_label
----------+----------+-----------+-----------+--------+-----------
4/14      |        0 |         4 |         4 | 0      | 4-17
5/14      |        0 |         5 |         5 | 0      | 4-17
6/14      |        0 |         6 |         6 | 0      | 4-17
7/14      |        0 |         7 |         7 | 0      | 4-17
8/14      |        0 |         8 |         8 | 0      | 4-17
9/14      |        0 |         9 |         9 | 0      | 4-17
10/14     |        0 |        10 |        10 | 0      | 4-17
11/14     |        0 |        11 |        11 | 0      | 4-17
12/14     |        0 |        12 |        12 | 0      | 4-17
13/14     |        0 |        13 |        13 | 0      | 4-17
14/14     |        1 |         0 |        14 | 0      | 4-17
15/14     |        1 |         1 |        15 | 0      | 4-17
16/14     |        1 |         2 |        16 | 0      | 4-17
17/14     |        1 |         3 |        17 | 0      | 4-17
18/14     |        1 |         4 |        18 | 1      | 18-31
19/14     |        1 |         5 |        19 | 1      | 18-31
20/14     |        1 |         6 |        20 | 1      | 18-31
21/14     |        1 |         7 |        21 | 1      | 18-31
22/14     |        1 |         8 |        22 | 1      | 18-31
23/14     |        1 |         9 |        23 | 1      | 18-31
24/14     |        1 |        10 |        24 | 1      | 18-31
25/14     |        1 |        11 |        25 | 1      | 18-31
26/14     |        1 |        12 |        26 | 1      | 18-31
27/14     |        1 |        13 |        27 | 1      | 18-31
28/14     |        2 |         0 |        28 | 1      | 18-31
29/14     |        2 |         1 |        29 | 1      | 18-31
30/14     |        2 |         2 |        30 | 1      | 18-31
31/14     |        2 |         3 |        31 | 1      | 18-31
32/14     |        2 |         4 |        32 | 2      | 32-45
33/14     |        2 |         5 |        33 | 2      | 32-45
34/14     |        2 |         6 |        34 | 2      | 32-45
35/14     |        2 |         7 |        35 | 2      | 32-45
36/14     |        2 |         8 |        36 | 2      | 32-45
37/14     |        2 |         9 |        37 | 2      | 32-45
38/14     |        2 |        10 |        38 | 2      | 32-45
39/14     |        2 |        11 |        39 | 2      | 32-45
40/14     |        2 |        12 |        40 | 2      | 32-45
41/14     |        2 |        13 |        41 | 2      | 32-45
42/14     |        3 |         0 |        42 | 2      | 32-45
43/14     |        3 |         1 |        43 | 2      | 32-45
44/14     |        3 |         2 |        44 | 2      | 32-45
45/14     |        3 |         3 |        45 | 2      | 32-45
46/14     |        3 |         4 |        46 | 3      | 46-59
47/14     |        3 |         5 |        47 | 3      | 46-59
48/14     |        3 |         6 |        48 | 3      | 46-59
49/14     |        3 |         7 |        49 | 3      | 46-59
50/14     |        3 |         8 |        50 | 3      | 46-59
51/14     |        3 |         9 |        51 | 3      | 46-59
52/14     |        3 |        10 |        52 | 3      | 46-59
53/14     |        3 |        11 |        53 | 3      | 46-59
54/14     |        3 |        12 |        54 | 3      | 46-59
55/14     |        3 |        13 |        55 | 3      | 46-59
56/14     |        4 |         0 |        56 | 3      | 46-59
57/14     |        4 |         1 |        57 | 3      | 46-59
58/14     |        4 |         2 |        58 | 3      | 46-59
59/14     |        4 |         3 |        59 | 3      | 46-59
(56 rows)
```

```SQL
WITH duration AS (
  SELECT MIN(length) AS lower_bound
       , MAX(length) AS upper_bound
    FROM film
),
histogram AS (
  SELECT DISTINCT
         ((CASE WHEN MOD(n,14) <= 3
                THEN (FLOOR(n/14) - 1)
                ELSE  FLOOR(n/14)
            END) - (FLOOR((SELECT lower_bound FROM duration)/14))::INTEGER + 1)
          AS bin_id
        , (4 + CASE WHEN MOD(n,14) <= 3
                   THEN (FLOOR(n/14) - 1)*14
                   ELSE  FLOOR(n/14)*14
              END)::TEXT || '-' ||
          (14 + 3 + CASE WHEN MOD(n,14) <= 3
                     THEN (FLOOR(n/14) - 1)*14
                     ELSE  FLOOR(n/14)*14
                END)::TEXT
          AS bin_label
    FROM GENERATE_SERIES((SELECT lower_bound FROM duration)::INTEGER,(SELECT upper_bound FROM duration)::INTEGER) s(n)
)
SELECT *
  FROM histogram
 ORDER BY bin_id;
```

```console
bin_id | bin_label
-------+-----------
     1 | 46-59
     2 | 60-73
     3 | 74-87
     4 | 88-101
     5 | 102-115
     6 | 116-129
     7 | 130-143
     8 | 144-157
     9 | 158-171
    10 | 172-185
(10 rows)
```

```SQL
WITH duration AS (
  SELECT MIN(length) AS lower_bound
       , MAX(length) AS upper_bound
    FROM film
),
histogram AS (
  SELECT DISTINCT
         ((CASE WHEN MOD(n,14) <= 3
                THEN (FLOOR(n/14) - 1)
                ELSE  FLOOR(n/14)
            END) - (FLOOR((SELECT lower_bound FROM duration)/14))::INTEGER + 1)
          AS bin_id
        , (4 + CASE WHEN MOD(n,14) <= 3
                   THEN (FLOOR(n/14) - 1)*14
                   ELSE  FLOOR(n/14)*14
              END)::TEXT || '-' ||
          (14 + 3 + CASE WHEN MOD(n,14) <= 3
                     THEN (FLOOR(n/14) - 1)*14
                     ELSE  FLOOR(n/14)*14
                END)::TEXT
          AS bin_label
    FROM GENERATE_SERIES((SELECT lower_bound FROM duration)::INTEGER,(SELECT upper_bound FROM duration)::INTEGER) s(n)
),
film_length_label AS (
  SELECT  film_id
        , title
        , length
        , ((CASE WHEN MOD(length,14) <= 3
               THEN (FLOOR(length/14) - 1)
               ELSE  FLOOR(length/14)
           END) - (FLOOR((SELECT lower_bound FROM duration)/14))::INTEGER + 1)
         AS bin_id
        , (4 + CASE WHEN MOD(length,14) <= 3
                   THEN (FLOOR(length/14) - 1)*14
                   ELSE  FLOOR(length/14)*14
              END)::TEXT || '-' ||
          (14 + 3 + CASE WHEN MOD(length,14) <= 3
                     THEN (FLOOR(length/14) - 1)*14
                     ELSE  FLOOR(length/14)*14
                END)::TEXT
          AS bin_label
     FROM film
)
SELECT *
  FROM film_length_label
 ORDER BY bin_id, length;
```

```console
film_id |            title            | length | bin_id | bin_label
--------+-----------------------------+--------+--------+-----------
    730 | Ridgemont Submarine         |     46 |      1 | 46-59
    469 | Iron Moon                   |     46 |      1 | 46-59
     15 | Alien Center                |     46 |      1 | 46-59
    504 | Kwai Homeward               |     46 |      1 | 46-59
    505 | Labyrinth League            |     46 |      1 | 46-59
    237 | Divorce Shining             |     47 |      1 | 46-59
    398 | Hanover Galaxy              |     47 |      1 | 46-59
    869 | Suspects Quills             |     47 |      1 | 46-59
    393 | Halloween Nuts              |     47 |      1 | 46-59
    407 | Hawk Chill                  |     47 |      1 | 46-59
    247 | Downhill Enough             |     47 |      1 | 46-59
    784 | Shanghai Tycoon             |     47 |      1 | 46-59
    410 | Heaven Freedom              |     48 |      1 | 46-59
    753 | Rush Goodfellas             |     48 |      1 | 46-59
    630 | Notting Speakeasy           |     48 |      1 | 46-59
      2 | Ace Goldfinger              |     48 |      1 | 46-59
    931 | Valentine Vanishing         |     48 |      1 | 46-59
    575 | Midsummer Groundhog         |     48 |      1 | 46-59
    866 | Sunset Racer                |     48 |      1 | 46-59
    634 | Odds Boogie                 |     48 |      1 | 46-59
    845 | Stepmom Dream               |     48 |      1 | 46-59
    670 | Pelican Comforts            |     48 |      1 | 46-59
    657 | Paradise Sabrina            |     48 |      1 | 46-59
    384 | Grosse Wonderful            |     49 |      1 | 46-59
    443 | Hurricane Affair            |     49 |      1 | 46-59
    430 | Hook Chariots               |     49 |      1 | 46-59
    411 | Heavenly Gun                |     49 |      1 | 46-59
    243 | Doors President             |     49 |      1 | 46-59
    679 | Pilot Hoosiers              |     50 |      1 | 46-59
   1000 | Zorro Ark                   |     50 |      1 | 46-59
      3 | Adaptation Holes            |     50 |      1 | 46-59
    192 | Crossing Divorce            |     50 |      1 | 46-59
     83 | Blues Instinct              |     50 |      1 | 46-59
    812 | Smoking Barbarella          |     50 |      1 | 46-59
    617 | Natural Stock               |     50 |      1 | 46-59
    524 | Lion Uncut                  |     50 |      1 | 46-59
    607 | Muppet Mile                 |     50 |      1 | 46-59
    392 | Hall Cassidy                |     51 |      1 | 46-59
    219 | Deep Crusade                |     51 |      1 | 46-59
    292 | Excitement Eve              |     51 |      1 | 46-59
    134 | Champion Flatliners         |     51 |      1 | 46-59
    799 | Simon North                 |     51 |      1 | 46-59
    285 | English Bulworth            |     51 |      1 | 46-59
    338 | Frisco Forrest              |     51 |      1 | 46-59
    912 | Trojan Tomorrow             |     52 |      1 | 46-59
    542 | Lust Lock                   |     52 |      1 | 46-59
    794 | Side Ark                    |     52 |      1 | 46-59
    970 | Westward Seabiscuit         |     52 |      1 | 46-59
    824 | Spartacus Cheaper           |     52 |      1 | 46-59
    402 | Harper Dying                |     52 |      1 | 46-59
    111 | Caddyshack Jedi             |     52 |      1 | 46-59
    888 | Thin Sagebrush              |     53 |      1 | 46-59
    862 | Summer Scarface             |     53 |      1 | 46-59
    697 | Primary Glass               |     53 |      1 | 46-59
     66 | Beneath Rush                |     53 |      1 | 46-59
    548 | Magnificent Chitty          |     53 |      1 | 46-59
    110 | Cabin Flash                 |     53 |      1 | 46-59
    603 | Movie Shakespeare           |     53 |      1 | 46-59
    883 | Tequila Past                |     53 |      1 | 46-59
    386 | Gump Date                   |     53 |      1 | 46-59
    779 | Sense Greek                 |     54 |      1 | 46-59
    489 | Juggler Hardly              |     54 |      1 | 46-59
    363 | Go Purple                   |     54 |      1 | 46-59
    497 | Kill Brotherhood            |     54 |      1 | 46-59
    633 | October Submarine           |     54 |      1 | 46-59
      8 | Airport Pollock             |     54 |      1 | 46-59
    164 | Coast Rainbow               |     55 |      1 | 46-59
    981 | Wolves Desire               |     55 |      1 | 46-59
    369 | Goodfellas Salute           |     56 |      1 | 46-59
    565 | Matrix Snowman              |     56 |      1 | 46-59
    226 | Destiny Saturday            |     56 |      1 | 46-59
     97 | Bride Intrigue              |     56 |      1 | 46-59
    199 | Cupboard Sinners            |     56 |      1 | 46-59
    215 | Dawn Pond                   |     57 |      1 | 46-59
    187 | Cranes Reservoir            |     57 |      1 | 46-59
    238 | Doctor Grail                |     57 |      1 | 46-59
    598 | Mosquito Armageddon         |     57 |      1 | 46-59
    626 | Noon Papi                   |     57 |      1 | 46-59
     18 | Alter Victory               |     57 |      1 | 46-59
    849 | Storm Happiness             |     57 |      1 | 46-59
    303 | Fantasy Troopers            |     58 |      1 | 46-59
    867 | Super Wyoming               |     58 |      1 | 46-59
    159 | Closer Bang                 |     58 |      1 | 46-59
    635 | Oklahoma Jumanji            |     58 |      1 | 46-59
    481 | Jekyll Frogmen              |     58 |      1 | 46-59
    732 | Rings Heartbreakers         |     58 |      1 | 46-59
    205 | Dances None                 |     58 |      1 | 46-59
    409 | Heartbreakers Bright        |     59 |      1 | 46-59
    947 | Vision Torque               |     59 |      1 | 46-59
    972 | Whisperer Giant             |     59 |      1 | 46-59
    486 | Jet Neighbors               |     59 |      1 | 46-59
    214 | Daughter Madigan            |     59 |      1 | 46-59
    516 | Legend Jedi                 |     59 |      1 | 46-59
    465 | Interview Liaisons          |     59 |      1 | 46-59
    581 | Minority Kiss               |     59 |      1 | 46-59
    171 | Commandments Express        |     59 |      1 | 46-59
    811 | Smile Earring               |     60 |      2 | 60-73
    586 | Mockingbird Hollywood       |     60 |      2 | 60-73
    675 | Phantom Glory               |     60 |      2 | 60-73
    782 | Shakespeare Saddle          |     60 |      2 | 60-73
    102 | Bubble Grosse               |     60 |      2 | 60-73
    743 | Room Roman                  |     60 |      2 | 60-73
    683 | Pity Bound                  |     60 |      2 | 60-73
```

```SQL
WITH duration AS (
  SELECT MIN(length) AS lower_bound
       , MAX(length) AS upper_bound
    FROM film
),
histogram AS (
  SELECT DISTINCT
         ((CASE WHEN MOD(n,14) <= 3
                THEN (FLOOR(n/14) - 1)
                ELSE  FLOOR(n/14)
            END) - (FLOOR((SELECT lower_bound FROM duration)/14))::INTEGER + 1)
          AS bin_id
        , (4 + CASE WHEN MOD(n,14) <= 3
                   THEN (FLOOR(n/14) - 1)*14
                   ELSE  FLOOR(n/14)*14
              END)::TEXT || '-' ||
          (14 + 3 + CASE WHEN MOD(n,14) <= 3
                     THEN (FLOOR(n/14) - 1)*14
                     ELSE  FLOOR(n/14)*14
                END)::TEXT
          AS bin_label
    FROM GENERATE_SERIES((SELECT lower_bound FROM duration)::INTEGER,(SELECT upper_bound FROM duration)::INTEGER) s(n)
),
film_length_label AS (
  SELECT  film_id
        , title
        , length
        , ((CASE WHEN MOD(length,14) <= 3
               THEN (FLOOR(length/14) - 1)
               ELSE  FLOOR(length/14)
           END) - (FLOOR((SELECT lower_bound FROM duration)/14))::INTEGER + 1)
         AS bin_id
        , (4 + CASE WHEN MOD(length,14) <= 3
                   THEN (FLOOR(length/14) - 1)*14
                   ELSE  FLOOR(length/14)*14
              END)::TEXT || '-' ||
          (14 + 3 + CASE WHEN MOD(length,14) <= 3
                     THEN (FLOOR(length/14) - 1)*14
                     ELSE  FLOOR(length/14)*14
                END)::TEXT
          AS bin_label
     FROM film
),
film_hist AS (
  SELECT  h.bin_id
        , h.bin_label AS bucket
        , COUNT(DISTINCT f.film_id)::INTEGER AS film_cnt
    FROM histogram h
    LEFT JOIN film_length_label f
      ON h.bin_id = f.bin_id
   GROUP BY h.bin_id, h.bin_label
)
SELECT bin_id
     , bucket
     , film_cnt
     , LPAD('*',film_cnt,'*') AS film_cnt_plot
  FROM film_hist
 ORDER BY bin_id, bucket;
```

## Problem 4

```SQL
SELECT  n::TEXT || '/28' AS operation
      , FLOOR(n/28) AS quotient
      , MOD(n,28) AS remainder
      , FLOOR(n/28)*28 + MOD(n,28) AS numerator
      , FLOOR(n/28) AS bin_id
      , (FLOOR(n/28)*28)::TEXT || '-' ||
        (28 + FLOOR(n/28)*28)::TEXT AS bin_label
  FROM GENERATE_SERIES(0,59) s(n);
```

```console
operation | quotient | remainder | numerator | bin_id | bin_label
----------+----------+-----------+-----------+--------+-----------
0/28      |        0 |         0 |         0 |      0 | 0-28
1/28      |        0 |         1 |         1 |      0 | 0-28
2/28      |        0 |         2 |         2 |      0 | 0-28
3/28      |        0 |         3 |         3 |      0 | 0-28
4/28      |        0 |         4 |         4 |      0 | 0-28
5/28      |        0 |         5 |         5 |      0 | 0-28
6/28      |        0 |         6 |         6 |      0 | 0-28
7/28      |        0 |         7 |         7 |      0 | 0-28
8/28      |        0 |         8 |         8 |      0 | 0-28
9/28      |        0 |         9 |         9 |      0 | 0-28
10/28     |        0 |        10 |        10 |      0 | 0-28
11/28     |        0 |        11 |        11 |      0 | 0-28
12/28     |        0 |        12 |        12 |      0 | 0-28
13/28     |        0 |        13 |        13 |      0 | 0-28
14/28     |        0 |        14 |        14 |      0 | 0-28
15/28     |        0 |        15 |        15 |      0 | 0-28
16/28     |        0 |        16 |        16 |      0 | 0-28
17/28     |        0 |        17 |        17 |      0 | 0-28
18/28     |        0 |        18 |        18 |      0 | 0-28
19/28     |        0 |        19 |        19 |      0 | 0-28
20/28     |        0 |        20 |        20 |      0 | 0-28
21/28     |        0 |        21 |        21 |      0 | 0-28
22/28     |        0 |        22 |        22 |      0 | 0-28
23/28     |        0 |        23 |        23 |      0 | 0-28
24/28     |        0 |        24 |        24 |      0 | 0-28
25/28     |        0 |        25 |        25 |      0 | 0-28
26/28     |        0 |        26 |        26 |      0 | 0-28
27/28     |        0 |        27 |        27 |      0 | 0-28 -----+
28/28     |        1 |         0 |        28 |      1 | 28-56     |
29/28     |        1 |         1 |        29 |      1 | 28-56     |
30/28     |        1 |         2 |        30 |      1 | 28-56     |
31/28     |        1 |         3 |        31 |      1 | 28-56     |
32/28     |        1 |         4 |        32 |      1 | 28-56     |
33/28     |        1 |         5 |        33 |      1 | 28-56     |
34/28     |        1 |         6 |        34 |      1 | 28-56     |
35/28     |        1 |         7 |        35 |      1 | 28-56     |
36/28     |        1 |         8 |        36 |      1 | 28-56     |
37/28     |        1 |         9 |        37 |      1 | 28-56     |
38/28     |        1 |        10 |        38 |      1 | 28-56     |
39/28     |        1 |        11 |        39 |      1 | 28-56     |
40/28     |        1 |        12 |        40 |      1 | 28-56     |
41/28     |        1 |        13 |        41 |      1 | 28-56     |
42/28     |        1 |        14 |        42 |      1 | 28-56     |
43/28     |        1 |        15 |        43 |      1 | 28-56     |
44/28     |        1 |        16 |        44 |      1 | 28-56     |
45/28     |        1 |        17 |        45 |      1 | 28-56<----+
46/28     |        1 |        18 |        46 |      1 | 28-56 <-- START
47/28     |        1 |        19 |        47 |      1 | 28-56
48/28     |        1 |        20 |        48 |      1 | 28-56
49/28     |        1 |        21 |        49 |      1 | 28-56
50/28     |        1 |        22 |        50 |      1 | 28-56
51/28     |        1 |        23 |        51 |      1 | 28-56
52/28     |        1 |        24 |        52 |      1 | 28-56
53/28     |        1 |        25 |        53 |      1 | 28-56
54/28     |        1 |        26 |        54 |      1 | 28-56
55/28     |        1 |        27 |        55 |      1 | 28-56
56/28     |        2 |         0 |        56 |      2 | 56-84
57/28     |        2 |         1 |        57 |      2 | 56-84
58/28     |        2 |         2 |        58 |      2 | 56-84
59/28     |        2 |         3 |        59 |      2 | 56-84
(60 rows)
```

```SQL
SELECT  n::TEXT || '/28' AS operation
      , FLOOR(n/28) AS quotient
      , MOD(n,28) AS remainder
      , FLOOR(n/28)*28 + MOD(n,28) AS numerator
      , (CASE WHEN MOD(n,28) <= 17
                 THEN (FLOOR(n/28) - 1)
                 ELSE  FLOOR(n/28)
            END)::TEXT
        AS bin_id
      , (18 + CASE WHEN MOD(n,28) <= 17
                 THEN (FLOOR(n/28) - 1)*28
                 ELSE  FLOOR(n/28)*28
            END)::TEXT || '-' ||
        (28 + 17 + CASE WHEN MOD(n,28) <= 17
                   THEN (FLOOR(n/28) - 1)*28
                   ELSE  FLOOR(n/28)*28
              END)::TEXT
        AS bin_label
  FROM GENERATE_SERIES(46,185) s(n);
```

```console
operation | quotient | remainder | numerator | bin_id | bin_label
-----------+----------+-----------+-----------+--------+-----------
46/28     |        1 |        18 |        46 | 1      | 46-73
47/28     |        1 |        19 |        47 | 1      | 46-73
48/28     |        1 |        20 |        48 | 1      | 46-73
49/28     |        1 |        21 |        49 | 1      | 46-73
50/28     |        1 |        22 |        50 | 1      | 46-73
51/28     |        1 |        23 |        51 | 1      | 46-73
52/28     |        1 |        24 |        52 | 1      | 46-73
53/28     |        1 |        25 |        53 | 1      | 46-73
54/28     |        1 |        26 |        54 | 1      | 46-73
55/28     |        1 |        27 |        55 | 1      | 46-73
56/28     |        2 |         0 |        56 | 1      | 46-73
57/28     |        2 |         1 |        57 | 1      | 46-73
58/28     |        2 |         2 |        58 | 1      | 46-73
59/28     |        2 |         3 |        59 | 1      | 46-73
60/28     |        2 |         4 |        60 | 1      | 46-73
61/28     |        2 |         5 |        61 | 1      | 46-73
62/28     |        2 |         6 |        62 | 1      | 46-73
63/28     |        2 |         7 |        63 | 1      | 46-73
64/28     |        2 |         8 |        64 | 1      | 46-73
65/28     |        2 |         9 |        65 | 1      | 46-73
66/28     |        2 |        10 |        66 | 1      | 46-73
67/28     |        2 |        11 |        67 | 1      | 46-73
68/28     |        2 |        12 |        68 | 1      | 46-73
69/28     |        2 |        13 |        69 | 1      | 46-73
70/28     |        2 |        14 |        70 | 1      | 46-73
71/28     |        2 |        15 |        71 | 1      | 46-73
72/28     |        2 |        16 |        72 | 1      | 46-73
73/28     |        2 |        17 |        73 | 1      | 46-73
74/28     |        2 |        18 |        74 | 2      | 74-101
```

```SQL
WITH duration AS (
  SELECT MIN(length) AS lower_bound
       , MAX(length) AS upper_bound
    FROM film
),
histogram AS (
  SELECT DISTINCT
         ((CASE WHEN MOD(n,28) <= 17
                THEN (FLOOR(n/28) - 1)
                ELSE  FLOOR(n/28)
            END) - (FLOOR((SELECT lower_bound FROM duration)/28))::INTEGER + 1)
          AS bin_id
        , (18 + CASE WHEN MOD(n,28) <= 17
                   THEN (FLOOR(n/28) - 1)*28
                   ELSE  FLOOR(n/28)*28
              END)::TEXT || '-' ||
          (28 + 17 + CASE WHEN MOD(n,28) <= 17
                     THEN (FLOOR(n/28) - 1)*28
                     ELSE  FLOOR(n/28)*28
                END)::TEXT
          AS bin_label
    FROM GENERATE_SERIES((SELECT lower_bound FROM duration)::INTEGER,(SELECT upper_bound FROM duration)::INTEGER) s(n)
)
SELECT *
  FROM histogram
 ORDER BY bin_id;
```

```console
bin_id | bin_label
-------+-----------
     1 | 46-73
     2 | 74-101
     3 | 102-129
     4 | 130-157
     5 | 158-185
(5 rows)
```

```SQL
WITH duration AS (
  SELECT MIN(length) AS lower_bound
       , MAX(length) AS upper_bound
    FROM film
),
histogram AS (
  SELECT DISTINCT
         ((CASE WHEN MOD(n,28) <= 17
                THEN (FLOOR(n/28) - 1)
                ELSE  FLOOR(n/28)
            END) - (FLOOR((SELECT lower_bound FROM duration)/28))::INTEGER + 1)
          AS bin_id
        , (18 + CASE WHEN MOD(n,28) <= 17
                   THEN (FLOOR(n/28) - 1)*28
                   ELSE  FLOOR(n/28)*28
              END)::TEXT || '-' ||
          (28 + 17 + CASE WHEN MOD(n,28) <= 17
                     THEN (FLOOR(n/28) - 1)*28
                     ELSE  FLOOR(n/28)*28
                END)::TEXT
          AS bin_label
    FROM GENERATE_SERIES((SELECT lower_bound FROM duration)::INTEGER,(SELECT upper_bound FROM duration)::INTEGER) s(n)
),
film_length_label AS (
  SELECT  film_id
        , title
        , length
        , ((CASE WHEN MOD(length,28) <= 17
               THEN (FLOOR(length/28) - 1)
               ELSE  FLOOR(length/28)
           END) - (FLOOR((SELECT lower_bound FROM duration)/28))::INTEGER + 1)
         AS bin_id
        , (18 + CASE WHEN MOD(length,28) <= 17
                   THEN (FLOOR(length/28) - 1)*28
                   ELSE  FLOOR(length/28)*28
              END)::TEXT || '-' ||
          (28 + 17 + CASE WHEN MOD(length,28) <= 17
                     THEN (FLOOR(length/28) - 1)*28
                     ELSE  FLOOR(length/28)*28
                END)::TEXT
          AS bin_label
     FROM film
),
film_hist AS (
  SELECT  h.bin_id
        , h.bin_label AS bucket
        , COUNT(DISTINCT f.film_id)::INTEGER AS film_cnt
    FROM histogram h
    LEFT JOIN film_length_label f
      ON h.bin_id = f.bin_id
   GROUP BY h.bin_id, h.bin_label
)
SELECT bin_id
     , bucket
     , film_cnt
     , LPAD('*',film_cnt,'*') AS film_cnt_plot
  FROM film_hist
 ORDER BY bin_id, bucket;
```
