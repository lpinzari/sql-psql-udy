# ARRAY_AGG FUNCTION

The PostgreSQL **ARRAY_AGG()** function is an aggregate function that accepts **a set of values** and **returns an array in which each value in the set is assigned to an element of the array**.

The following shows the syntax of the **ARRAY_AGG()** function:

```SQL
ARRAY_AGG(expression [ORDER BY [sort_expression {ASC | DESC}], [...])
```

The `ARRAY_AGG()` accepts an expression that returns a value of any type which is valid for an array element.

The `ORDER BY` clause is an optional clause. It specifies the order of rows processed in the aggregation, which determines the order of the elements in the result array.

Similar to other aggregate functions such as `AVG()`, `COUNT()`, `MAX()`, `MIN()`, and `SUM()`, the `ARRAY_AGG()` is often used with the `GROUP BY` clause.

## PostgreSQL ARRAY_AGG() function examples

We will use the `film`, `film_actor`, and `actor` tables from the sample database for the demonstration.

**film**

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

**film_actor**

```console
dvdrental=# \d film_actor
                         Table "public.film_actor"
   Column    |            Type             | Collation | Nullable | Default
-------------+-----------------------------+-----------+----------+---------
 actor_id    | smallint                    |           | not null |
 film_id     | smallint                    |           | not null |
 last_update | timestamp without time zone |           | not null | now()
```

**actor**

```console
dvdrental=# \d actor
                                            Table "public.actor"
   Column    |            Type             | Collation | Nullable |                 Default
-------------+-----------------------------+-----------+----------+-----------------------------------------
 actor_id    | integer                     |           | not null | nextval('actor_actor_id_seq'::regclass)
 first_name  | character varying(45)       |           | not null |
 last_name   | character varying(45)       |           | not null |
 last_update | timestamp without time zone |           | not null | now()
```


![dvdrental erd](../00_basic_intro/images/16_dvdrental.png)

**SQL**
```SQL
SELECT title, first_name, last_name
  FROM film
 INNER JOIN film_actor USING(film_id)
 INNER JOIN actor USING(actor_id)
 GROUP BY title, first_name, last_name
 ORDER BY title
 LIMIT 20;
```

**Results**

|title       | first_name | last_name|
|:--------------:|:-----------:|:---------:|
|Academy Dinosaur | Mary       | Keitel|
|Academy Dinosaur | Warren     | Nolte|
|Academy Dinosaur | Rock       | Dukakis|
|Academy Dinosaur | Lucille    | Tracy|
|Academy Dinosaur | Johnny     | Cage|
|Academy Dinosaur | Penelope   | Guiness|
|Academy Dinosaur | Sandra     | Peck|
|Academy Dinosaur | Christian  | Gable|
|Academy Dinosaur | Mena       | Temple|
|Academy Dinosaur | Oprah      | Kilmer|
|Ace Goldfinger   | Minnie     | Zellweger|
|Ace Goldfinger   | Bob        | Fawcett|
|Ace Goldfinger   | Chris      | Depp|
|Ace Goldfinger   | Sean       | Guiness|
|Adaptation Holes | Ray        | Johansson|
|Adaptation Holes | Julianne   | Dench|
|Adaptation Holes | Bob        | Fawcett|
|Adaptation Holes | Nick       | Wahlberg|
|Adaptation Holes | Cameron    | Streep|
|Affair Prejudice | Kenneth    | Pesci|

## Using PostgreSQL ARRAY_AGG() function without the ORDER BY clause example

The following example uses the `ARRAY_AGG()` function to **return the list of film title and a list of actors for each film**:


**SQL**
```SQL
SELECT title,
       ARRAY_AGG (first_name || ' ' || last_name) actors
  FROM film
 INNER JOIN film_actor USING (film_id)
 INNER JOIN actor USING (actor_id)
 GROUP BY title
 ORDER BY title
 LIMIT 10;
```

**Results**

|title|actors|
|:---:|:---------:|
|Academy Dinosaur | {"Penelope Guiness","Christian Gable","Lucille Tracy","Sandra Peck","Johnny Cage","Mena Temple","Warren Nolte","Oprah Kilmer","Rock Dukakis","Mary Keitel"}|
|Ace Goldfinger   | {"Bob Fawcett","Minnie Zellweger","Sean Guiness","Chris Depp"}|
|Adaptation Holes | {"Nick Wahlberg","Bob Fawcett","Cameron Streep","Ray Johansson","Julianne Dench"}|
|Affair Prejudice | {"Jodie Degeneres","Scarlett Damon","Kenneth Pesci","Fay Winslet","Oprah Kilmer"}|
|African Egg      | {"Gary Phoenix","Dustin Tautou","Matthew Leigh","Matthew Carrey","Thora Temple"}|
|Agent Truman     | {"Kirsten Paltrow","Sandra Kilmer","Jayne Neeson","Warren Nolte","Morgan Williams","Kenneth Hoffman","Reese West"}|
|Airplane Sierra  | {"Jim Mostel","Richard Penn","Oprah Kilmer","Mena Hopper","Michael Bolger"}|
|Airport Pollock  | {"Fay Kilmer","Gene Willis","Susan Davis","Lucille Dee"}|
|Alabama Devil    | {"Christian Gable","Elvis Marx","Rip Crawford","Mena Temple","Rip Winslet","Warren Nolte","Greta Keitel","William Hackman","Meryl Allen"}|
|Aladdin Calendar | {"Alec Wayne","Judy Dean","Val Bolger","Ray Johansson","Renee Tracy","Jada Ryder","Greta Malden","Rock Dukakis"}|

As you can see, the `actors` in each film are **arbitrarily ordered**. To sort the actors by last name or first name, you can use the `ORDER BY` clause in the `ARRAY_AGG()` function.

## Using PostgreSQL ARRAY_AGG() function with the ORDER BY clause example

This example uses the `ARRAY_AGG()` function to return a list of films and a list of actors for each film sorted by the actor’s first name and last name:

**SQL**
```SQL
SELECT title,
       ARRAY_AGG (first_name || ' ' || last_name
                  ORDER BY first_name ASC,
                           last_name DESC
       ) actors
  FROM film
 INNER JOIN film_actor USING (film_id)
 INNER JOIN actor USING (actor_id)
 GROUP BY title
 ORDER BY title
 LIMIT 10;
```

**Results**

|title|actors|
|----:|:----:|
|Academy Dinosaur | {"Christian Gable","Johnny Cage","Lucille Tracy","Mary Keitel","Mena Temple","Oprah Kilmer","Penelope Guiness","Rock Dukakis","Sandra Peck","Warren Nolte"}
|Ace Goldfinger   | {"Bob Fawcett","Chris Depp","Minnie Zellweger","Sean Guiness"}|
|Adaptation Holes | {"Bob Fawcett","Cameron Streep","Julianne Dench","Nick Wahlberg","Ray Johansson"}|
|Affair Prejudice | {"Fay Winslet","Jodie Degeneres","Kenneth Pesci","Oprah Kilmer","Scarlett Damon"}|
|African Egg      | {"Dustin Tautou","Gary Phoenix","Matthew Leigh","Matthew Carrey","Thora Temple"}|
|Agent Truman     | {"Jayne Neeson","Kenneth Hoffman","Kirsten Paltrow","Morgan Williams","Reese West","Sandra Kilmer","Warren Nolte"}|
|Airplane Sierra  | {"Jim Mostel","Mena Hopper","Michael Bolger","Oprah| Kilmer","Richard Penn"}|
|Airport Pollock  | {"Fay Kilmer","Gene Willis","Lucille Dee","Susan Davis"}|
|Alabama Devil    | {"Christian Gable","Elvis Marx","Greta Keitel","Mena Temple","Meryl Allen","Rip Winslet","Rip Crawford","Warren Nolte","William Hackman"}|
|Aladdin Calendar | {"Alec Wayne","Greta Malden","Jada Ryder","Judy Dean","Ray Johansson","Renee Tracy","Rock Dukakis","Val Bolger"}|
