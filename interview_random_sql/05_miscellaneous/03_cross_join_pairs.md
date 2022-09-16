# CROSS-JOIN PAIRS

Suppose we have the following table:

- `film`:

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
```

For a complete

- **film_id**: A SERIAL containing a unique integer number for each film.
- **title**: A VARCHAR (255) containing the title of the film.
- description: A TEXT containing a short description of plot summary of the film.
- release_year: A year containing the year in which the movie was released.
- language_id: A SMALLINT identifying the language of this film. Values in this column are drawn from the column of the same name in the language table.
- **rental_duration**: A SMALLINT indicating the length of the rental period, in days.
- **rental_rate**: A NUMERIC (4,2) indicating the cost to rent the film for the period specified in the rental duration column.
- **length**: A SMALLINT indicating the duration of the film, in minutes.
- replacement_cost: A NUMERIC (5,2) indicating the amount charged to the customer if the film is not returned or is returned in a damage state.


## Problem

Write a query to get the pairs of films with
- total length amounts between `360` and `365` minutes, and
- total length amounts within `40` of each other and  
- The total cost must be less than equal to `2` dollars for 7 days.

```console
title_1          |     title_2      | tot_length | tot_7days_cost
-----------------+------------------+------------+----------------
Anonymous Human  | Catch Amistad    |        362 |           1.96
Anonymous Human  | Smoochy Control  |        363 |           1.96
Catch Amistad    | Empire Malkovich |        360 |           1.96
Catch Amistad    | Anonymous Human  |        362 |           1.96
Catch Amistad    | Texas Watch      |        362 |           1.96
Dracula Crystal  | Smoochy Control  |        360 |           1.96
Empire Malkovich | Catch Amistad    |        360 |           1.96
Empire Malkovich | Smoochy Control  |        361 |           1.96
Smoochy Control  | Dracula Crystal  |        360 |           1.96
Smoochy Control  | Empire Malkovich |        361 |           1.96
Smoochy Control  | Anonymous Human  |        363 |           1.96
Smoochy Control  | Texas Watch      |        363 |           1.96
Texas Watch      | Catch Amistad    |        362 |           1.96
Texas Watch      | Smoochy Control  |        363 |           1.96
(14 rows)
```

For example, the first row indicates that the total length is `362` minutes and the total rental cost for `Anonymous Human` and `Catch Amistad` is `1.96`.

```console
title_1         |    title_2    | length_1 | length_2 | tot_length | daily_cost_1 | daily_cost_2 | tot_daily_cost | tot_7days_cost
----------------+---------------+----------+----------+------------+--------------+--------------+----------------+----------------
Anonymous Human | Catch Amistad |      179 |      183 |        362 |         0.14 |         0.14 |           0.28 |           1.96
```

The output table shows the calculations broken down in different amounts.


### Problem 2

The previous solution includes duplicates in the result. We want to remove the duplicates in the final solution.

```console
title_1          |     title_2      | tot_length | tot_7days_cost
-----------------+------------------+------------+----------------
Anonymous Human  | Catch Amistad    |        362 |           1.96
Catch Amistad    | Anonymous Human  |        362 |           1.96
```

For example, the first record in the output table should be kept and the symmetric pair should be removed. In other words, we want to keep all the pairs where the first title_1 comes first in alphabetical order.

```console
title_1          |     title_2      | tot_length | tot_7days_cost
-----------------+------------------+------------+----------------
Anonymous Human  | Catch Amistad    |        362 |           1.96
Anonymous Human  | Smoochy Control  |        363 |           1.96
Catch Amistad    | Empire Malkovich |        360 |           1.96
Catch Amistad    | Texas Watch      |        362 |           1.96
Dracula Crystal  | Smoochy Control  |        360 |           1.96
Empire Malkovich | Smoochy Control  |        361 |           1.96
Smoochy Control  | Texas Watch      |        363 |           1.96
(7 rows)
```


## Solution

```SQL
WITH movies_pairs AS (
  SELECT  f1.film_id AS id1
        , f2.film_id AS id2
        , f1.title AS title_1
        , f2.title AS title_2
        , f1.length AS length_1
        , f2.length AS length_2
        , f1.length + f2.length AS tot_length
        , ROUND(f1.rental_rate * 1.0/f1.rental_duration,2) AS daily_cost_1
        , ROUND(f2.rental_rate * 1.0/f2.rental_duration,2) AS daily_cost_2
        , ROUND(f1.rental_rate * 1.0/f1.rental_duration,2) +
          ROUND(f2.rental_rate * 1.0/f2.rental_duration,2) AS tot_daily_cost
        , 7*(ROUND(f1.rental_rate * 1.0/f1.rental_duration,2) +
          ROUND(f2.rental_rate * 1.0/f2.rental_duration,2)) AS tot_7days_cost
    FROM film f1
   CROSS JOIN film f2
   WHERE f1.film_id != f2.film_id
)
SELECT  title_1
      , title_2
      , tot_length
      , tot_7days_cost
  FROM movies_pairs
 WHERE tot_length BETWEEN 360 AND 365
       AND ABS(length_1 - length_2) <= 40
       AND tot_7days_cost <= 2.0
 ORDER BY title_1, tot_length, tot_7days_cost;
```

## Solution 2

```SQL
WITH movies_pairs AS (
  SELECT  f1.film_id AS id1
        , f2.film_id AS id2
        , f1.title AS title_1
        , f2.title AS title_2
        , f1.length AS length_1
        , f2.length AS length_2
        , f1.length + f2.length AS tot_length
        , ROUND(f1.rental_rate * 1.0/f1.rental_duration,2) AS daily_cost_1
        , ROUND(f2.rental_rate * 1.0/f2.rental_duration,2) AS daily_cost_2
        , ROUND(f1.rental_rate * 1.0/f1.rental_duration,2) +
          ROUND(f2.rental_rate * 1.0/f2.rental_duration,2) AS tot_daily_cost
        , 7*(ROUND(f1.rental_rate * 1.0/f1.rental_duration,2) +
          ROUND(f2.rental_rate * 1.0/f2.rental_duration,2)) AS tot_7days_cost
    FROM film f1
   CROSS JOIN film f2
   WHERE f1.film_id != f2.film_id
     AND f1.title <= f2.title

)
SELECT  title_1
      , title_2
      , tot_length
      , tot_7days_cost
  FROM movies_pairs
 WHERE tot_length BETWEEN 360 AND 365
       AND ABS(length_1 - length_2) <= 40
       AND tot_7days_cost <= 2.0
 ORDER BY title_1, tot_length, tot_7days_cost;
```

Another option is to use a different the relation order on the `film_id` fields.
