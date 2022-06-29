## STRING_AGG FUNCTION

The PostgreSQL `STRING_AGG()` function is an aggregate function that concatenates a list of strings and places a separator between them. The function does not add the separator at the end of the string.

The following shows the syntax of the `STRING_AGG()` function:

```SQL
STRING_AGG ( expression, separator [order_by_clause] )
```

The `STRING_AGG()` function accepts two arguments and an optional `ORDER BY` clause.

- `expression` is any valid expression that can resolve to a character string. If you use other types than character string type, you need to explicitly cast these values of that type to the character string type.
- `separator` is the separator for concatenated strings.

The `order_by_clause` is an optional clause that specifies the order of concatenated results. It has the following form:

```SQL
ORDER BY expression1 {ASC | DESC}, [...]
```

The `STRING_AGG()` is similar to the `ARRAY_AGG()` function except for the return type. The return type of the `STRING_AGG()` function is the **string** while the return type of the `ARRAY_AGG()` function is the **array**.

Like other aggregate functions such as `AVG()`, `COUNT()`, `MAX()`, `MIN()`, and `SUM()`, the `STRING_AGG()` function is often used with the `GROUP BY` clause.

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

## Using STRING_AGG() function to generate a list of comma-separated values

This example uses the `STRING_AGG()` function to return a list of actor’s names for each film from the film table:

**SQL**
```SQL
SELECT f.title,
       STRING_AGG ( a.first_name || ' ' || a.last_name, ','
                    ORDER BY a.first_name, a.last_name
       ) actors
  FROM film f
 INNER JOIN film_actor fa USING (film_id)
 INNER JOIN actor a USING (actor_id)
 GROUP BY f.title
 LIMIT 10;
```

**Results**

|title       | actors|
|:---------:|:----:|
Academy Dinosaur | Christian Gable,Johnny Cage,Lucille Tracy,Mary Keitel,Mena Temple,Oprah Kilmer,Penelope Guiness,Rock Dukakis,Sandra Peck,Warren Nolte|
Ace Goldfinger   | Bob Fawcett,Chris Depp,Minnie Zellweger,Sean Guiness|
Adaptation Holes | Bob Fawcett,Cameron Streep,Julianne Dench,Nick Wahlberg,Ray Johansson|
Affair Prejudice | Fay Winslet,Jodie Degeneres,Kenneth Pesci,Oprah Kilmer,Scarlett Damon|
African Egg      | Dustin Tautou,Gary Phoenix,Matthew Carrey,Matthew Leigh,Thora Temple|
Agent Truman     | Jayne Neeson,Kenneth Hoffman,Kirsten Paltrow,Morgan Williams,Reese West,Sandra Kilmer,Warren Nolte|
Airplane Sierra  | Jim Mostel,Mena Hopper,Michael Bolger,Oprah Kilmer,Richard Penn|
Airport Pollock  | Fay Kilmer,Gene Willis,Lucille Dee,Susan Davis|
Alabama Devil    | Christian Gable,Elvis Marx,Greta Keitel,Mena Temple,Meryl Allen,Rip Crawford,Rip Winslet,Warren Nolte,William Hackman|
Aladdin Calendar | Alec Wayne,Greta Malden,Jada Ryder,Judy Dean,Ray Johansson,Renee Tracy,Rock Dukakis,Val Bolger|

## Using STRING_AGG() function to generate a list of emails

The following example uses the `STRING_AGG()` function to build an email list for each country. The email in each list separated by a semi-colon.

![dvdrental erd](../00_basic_intro/images/16_dvdrental.png)

**SQL**
```SQL
SELECT country,
       STRING_AGG (email, ';') email_list
  FROM customer
 INNER JOIN address USING (address_id)
 INNER JOIN city USING (city_id)
 INNER JOIN country USING (country_id)
 GROUP BY country
 LIMIT 10;
```

**Results**

|country        |  email_list|
|:-------------:|----------:|
|Thailand|carolyn.perez@sakilacustomer.org;jacqueline.long@sakilacustomer.org;shawn.heaton@sakilacustomer.org|
|Virgin Islands, U.S. | nathan.runyon@sakilacustomer.org|
|Faroe Islands        | edward.baugh@sakilacustomer.org|
|Bangladesh           | michelle.clark@sakilacustomer.org;frank.waggoner@sakilacustomer.org;stephen.qualls@sakilacustomer.org|
|Indonesia            | jared.ely@sakilacustomer.org;victoria.gibson@sakilacustomer.org;suzanne.nichols@sakilacustomer.org;tara.ryan@sakilacustomer.org;minnie.romero@sakilacustomer.org;jeffrey.spear@sakilacustomer.org;steve.mackenzie@sakilacustomer.org;norman.currier@sakilacustomer.org;jay.robb@sakilacustomer.org;lloyd.dowd@sakilacustomer.org;jorge.olivares@sakilacustomer.org;reginald.kinder@sakilacustomer.org;leslie.seward@sakilacustomer.org;lonnie.tirado@sakilacustomer.org|
Italy                | anna.hill@sakilacustomer.org;bessie.morrison@sakilacustomer.org;christopher.greco@sakilacustomer.org;alexander.fennell@sakilacustomer.org;marc.outlaw@sakilacustomer.org;adrian.clary@sakilacustomer.org;darren.windham@sakilacustomer.org|
Venezuela            | carmen.owens@sakilacustomer.org;cindy.fisher@sakilacustomer.org;yvonne.watkins@sakilacustomer.org;kristina.chambers@sakilacustomer.org;calvin.martel@sakilacustomer.org;mathew.bolin@sakilacustomer.org;alberto.henning@sakilacustomer.org|
|Oman                 | margaret.moore@sakilacustomer.org;gene.sanborn@sakilacustomer.org|
Cameroon             | albert.crouse@sakilacustomer.org;lawrence.lawton@sakilacustomer.org|
|Czech Republic       | jennie.terry@sakilacustomer.org|
