# Introduction to SQL MIN function

The SQL `MIN` function returns the minimum value in a set of values. The following demonstrates the syntax of the `MIN` function.

```SQL
MIN(expression)
```
Like the MAX function, the `MIN` **function also ignores** `NULL` values and the `DISTINCT` option is not applicable to the MIN function.

## PostgreSQL MIN() function examples

We will use the `film` , `film_category`, and `category` tables from the `dvdrental` sample database for demonstration.

**film** table:

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
```

**film_category**

```console
dvdrental=# \d film_category
                        Table "public.film_category"
   Column    |            Type             | Collation | Nullable | Default
-------------+-----------------------------+-----------+----------+---------
 film_id     | smallint                    |           | not null |
 category_id | smallint                    |           | not null |
 last_update | timestamp without time zone |           | not null | now()
 ```

 **category**

 ```console
 dvdrental=# \d category
                                             Table "public.category"
   Column    |            Type             | Collation | Nullable |                    Default
-------------+-----------------------------+-----------+----------+-----------------------------------------------
 category_id | integer                     |           | not null | nextval('category_category_id_seq'::regclass)
 name        | character varying(25)       |           | not null |
 last_update | timestamp without time zone |           | not null | now()
 ```

## Using PostgreSQL MIN function in SELECT clause

The following example uses the `MIN()` function to **get the lowest rental rate from** the `rental_rate` column the `film` table:

**SQL**

```SQL
SELECT MIN (rental_rate)
  FROM film;
```
**Results**

| min|
|:----:|
| 0.99|

## Using PostgreSQL MIN function in a subquery

To **get films which have the lowest rental rate**, you use the following query:

**SQL**
```SQL
SELECT film_id, title, rental_rate
  FROM film
 WHERE rental_rate = (
          SELECT MIN (rental_rate)
            FROM film
 ) LIMIT 10;
```

**Results**

|film_id |        title         | rental_rate|
|:------:|:--------------------:|:------------:|
|      1 | Academy Dinosaur     |        0.99|
|     11 | Alamo Videotape      |        0.99|
|     12 | Alaska Phantom       |        0.99|
|    213 | Date Speed           |        0.99|
|     14 | Alice Fantasia       |        0.99|
|     17 | Alone Trip           |        0.99|
|     18 | Alter Victory        |        0.99|
|     19 | Amadeus Holy         |        0.99|
|     23 | Anaconda Confessions |        0.99|
|     26 | Annie Identity       |        0.99|

How it works.

- First, the subquery to select the lowest rental rate.
- Then, the outer query selects films that have rental rates equal to the lowest rental rate returned by the subquery.

## Using PostgreSQL MIN function with GROUP BY clause

In practice, you often use the `MIN` function with the `GROUP BY` clause to find the lowest value in each group.

The following statement uses the `MIN()` function with the `GROUP BY` clause to find the lowest replacement cost of films by category:

**SQL**

```SQL
SELECT name,
       MIN(replacement_cost) replacement_cost
  FROM category
 INNER JOIN film_category USING (category_id)
 INNER JOIN film USING (film_id)
 GROUP BY name
 ORDER BY name;
 ```

**Results**

|    name     | replacement_cost|
|:-----------:|:---------------:|
| Action      |             9.99|
| Animation   |             9.99|
| Children    |             9.99|
| Classics    |            10.99|
| Comedy      |             9.99|
| Documentary |             9.99|
| Drama       |             9.99|
| Family      |             9.99|
| Foreign     |             9.99|
| Games       |             9.99|
| Horror      |            10.99|
| Music       |            10.99|
| New         |             9.99|
| Sci-Fi      |             9.99|
| Sports      |             9.99|
| Travel      |             9.99|

## Using PostgreSQL MIN function with HAVING clause


It’s possible to use the `MIN` function in the `HAVING` clause the filter the groups whose minimum values match a certain condition.

The following query finds uses the `MIN()` **function to find the lowest replacement costs of films grouped by category and selects only groups that have replacement cost greater than** `9.99`.

**SQL**
```SQL
SELECT name,
       MIN(replacement_cost) replacement_cost
  FROM category
 INNER JOIN film_category USING (category_id)
 INNER JOIN film USING (film_id)
 GROUP BY name
 HAVING MIN (replacement_cost) > 9.99
 ORDER BY name;
```

**Results**

|name   | replacement_cost|
|:------:|:-----------------:|
|Classics |            10.99|
|Horror   |            10.99|
|Music    |            10.99|

## Using PostgreSQL MIN function with other aggregate functions

It’s possible to use the  `MIN()` function with other aggregate functions such as `MAX()` function in the same query.

The following example uses the `MIN()` and `MAX()` function to find the shortest and longest films by category:

**SQL**
```SQL
SELECT name,
       MIN(length) min_length,
       MAX(length) max_length
  FROM category
 INNER JOIN film_category USING (category_id)
 INNER JOIN film USING (film_id)
 GROUP BY name
 ORDER BY name;
```

**Results**

|name     | min_length | max_length|
|:--------:|:---------:|:-----------:|
|Action      |         47 |        185|
|Animation   |         49 |        185|
|Children    |         46 |        178|
|Classics    |         46 |        184|
|Comedy      |         47 |        185|
|Documentary |         47 |        183|
|Drama       |         46 |        181|
|Family      |         48 |        184|
|Foreign     |         46 |        184|
|Games       |         57 |        185|
|Horror      |         48 |        181|
|Music       |         47 |        185|
|New         |         46 |        183|
|Sci-Fi      |         51 |        185|
|Sports      |         47 |        184|
|Travel      |         47 |        185|
