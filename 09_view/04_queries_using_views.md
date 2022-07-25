# Queries Using Views

In some types of queries, views act identically to base tables. In others, particularly those that add, modify, or delete records, views have some restrictions and can't support certain operations that are perfectly legal on base tables.

## SELECTING Records from a View

As stated earlier, information can be retrieved from  views just as if they were base tables. Queries with `SELECT`, then, operate normally on views. For example, to list all records in the view **faculty**, created in the previous lesson, one could use:

```SQL
SELECT *
  FROM faculty;
```

**Results**

|teacher_id |    teacher_name    |   phone|
|:---------:|:------------------:|:--------:|
|       303 | Dr. Horn           | 257-3049|
|       290 | Dr. Lowe           | 257-2390|
|       430 | Dr. Engle          | 256-4621|
|       180 | Dr. Cooke          | 257-8088|
|       560 | Dr. Olsen          | 257-8086|
|       784 | Dr. Scango         | 257-3046|
|       213 | Dr. Wright         | 257-3393|

The result is a list of exactly what the `CREATE VIEW` statement defined to be in this view - names, teacher numbers and phone numbers of all teachers.

`SELECT's` operating on views can also have `WHERE` clauses and in general are allowed to be as complex as those operating on base tables. For example, to retrieve the names and grades of only those students in Dr. Engle's class from the view **roster** defined previously; you could use

```SQL
SELECT student_name, grade
  FROM roster  
 WHERE teacher_name = 'Dr. Engle';
```

**Result**

|student_name    | grade|
|:-----------------:|:-----:|
|Howard Mansfield   |     3|
|Joe Adams          |     4|
|Allen Thomas       |     2 |

This same information could be retrieved from the base tables themselves with

```SQL
SELECT teacher_name,
       course_name,
       student_name,
       grade
  FROM teachers
 INNER JOIN sections USING(teacher_id)
 INNER JOIN enrolls USING(section_id,course_id)
 INNER JOIN courses USING(course_id)
 INNER JOIN students USING(student_id)
 WHERE teacher_name = 'Dr. Engle';
```

Clearly, the query using the view **roster** is much simpler. If this kind of information will be requested often, defining an appropriate view will make life much simpler.

Nothing is free, however, not even with SQL. A reasonable question to ask is, "**if a view has no physical existence, how can SQL correctly carry out queries against i?**"

The answer stems from how SQL actually stores a view. Typically, a SQL implementation will store the `SELECT` statement you used in the `CREATE VIEW` statement. Then, whenever a query attempts to access that view, SQL must first (conceptually) execute the `SELECT`, which defines the view, then execute that new query. The predictable result is that while **views provide convenience and some measure of security, they do so at the cost of efficiency**. As a result, queries accessing views are **likely to execute more slowly than those accessing only base tables**.

## Listing views in a database

Let's use `\dv`, **display view**, to list all views in the `dvdrental` database:

```console
dvdrental=# \dv
                   List of relations
 Schema |            Name            | Type |  Owner
--------+----------------------------+------+----------
 public | actor_info                 | view | postgres
 public | customer_list              | view | postgres
 public | film_list                  | view | postgres
 public | nicer_but_slower_film_list | view | postgres
 public | sales_by_film_category     | view | postgres
 public | sales_by_store             | view | postgres
 public | staff_list                 | view | postgres
(7 rows)
```

## Show view defintion

To show the actual definition of a view, use the `\sv` command. For example, to show the view definition of `actor_info` in the `dvdrental` database you could type:

`\sv` **actor_info**:

```console
CREATE OR REPLACE VIEW public.actor_info AS
 SELECT a.actor_id,
    a.first_name,
    a.last_name,
    group_concat(DISTINCT (c.name::text || ': '::text) || (( SELECT group_concat(f.title::text) AS group_concat
           FROM film f
             JOIN film_category fc_1 ON f.film_id = fc_1.film_id
             JOIN film_actor fa_1 ON f.film_id = fa_1.film_id
          WHERE fc_1.category_id = c.category_id AND fa_1.actor_id = a.actor_id
          GROUP BY fa_1.actor_id))) AS film_info
   FROM actor a
     LEFT JOIN film_actor fa ON a.actor_id = fa.actor_id
     LEFT JOIN film_category fc ON fa.film_id = fc.film_id
     LEFT JOIN category c ON fc.category_id = c.category_id
  GROUP BY a.actor_id, a.first_name, a.last_name
```

The `actor_info` view provides a list of all actors, including the films in which they have performed, broken down by category.

|actor_id|first_name|last_name|film_info|
|:------:|:--------:|:-------:|:-------:|
|1 | Penelope   | Guiness      | Animation: Anaconda Confessions, Children: Language Cowboy, Classics: Color Philadelphia, Westward Seabiscuit, Comedy: Vertigo Northwest, Documentary: Academy Dinosaur, Family: King Evolution, Splash Gump, Foreign: Mulholland Beast, Games: Bulworth Commandments, Human Graffiti, Horror: Elephant Trojan, Lady Stage, Rules Human, Music: Wizard Coldblooded, New: Angels Life, Oklahoma Jumanji, Sci-Fi: Cheaper Clyde, Sports: Gleaming Jawbreaker|


2. **customer_list**:

```console
dvdrental=# \sv customer_list
CREATE OR REPLACE VIEW public.customer_list AS
 SELECT cu.customer_id AS id,
    (cu.first_name::text || ' '::text) || cu.last_name::text AS name,
    a.address,
    a.postal_code AS "zip code",
    a.phone,
    city.city,
    country.country,
        CASE
            WHEN cu.activebool THEN 'active'::text
            ELSE ''::text
        END AS notes,
    cu.store_id AS sid
   FROM customer cu
     JOIN address a ON cu.address_id = a.address_id
     JOIN city ON a.city_id = city.city_id
     JOIN country ON city.country_id = country.country_id
```

The **customer_list** view provides a list of customers, with first name and last name concatenated together and address information combined into a single view.
The **customer_list** view incorporates data from the `customer`, `address`, `city`, and `country tables`.

```SQL
SELECT * FROM customer_list LIMIT 2;
```

| id | name|address|zip code|phone|city|country|notes| sid|
|:---:|:--:|:-----:|:------:|:---:|:--:|:-----:|:---:|:---:|
|52 | Julie Sanchez | 939 Probolinggo Loop  | 4166     | 680428310138 | A Corua (La Corua) | Spain        | active |   1|
|101 | Peggy Myers   | 733 Mandaluyong Place | 77459    | 196568435814 | Abha               | Saudi Arabia | active |   1|

3. **film_list**:

```console
dvdrental=# \sv film_list
CREATE OR REPLACE VIEW public.film_list AS
 SELECT film.film_id AS fid,
    film.title,
    film.description,
    category.name AS category,
    film.rental_rate AS price,
    film.length,
    film.rating,
    group_concat((actor.first_name::text || ' '::text) || actor.last_name::text) AS actors
   FROM category
     LEFT JOIN film_category ON category.category_id = film_category.category_id
     LEFT JOIN film ON film_category.film_id = film.film_id
     JOIN film_actor ON film.film_id = film_actor.film_id
     JOIN actor ON film_actor.actor_id = actor.actor_id
  GROUP BY film.film_id, film.title, film.description, category.name, film.rental_rate, film.length, film.rating
```

The **film_list** view contains a formatted view of the `film` table, with a comma-separated list of actors for each film.
The **film_list** view incorporates data from the `film`, `category`, `film_category`, `actor`, and `film_actor` tables.

|fid | title |description|category| price | length | rating|actors|
|:--:|:-----:|:---------:|:------:|:-----:|:-------:|:----:|:----:|
|1 | Academy Dinosaur | A Epic Drama of a Feminist And a Mad Scientist who must Battle a Teacher in The Canadian Rockies     | Documentary |  0.99 |     86 | PG     | Rock Dukakis, Mary Keitel, Johnny Cage, Penelope Guiness, Sandra Peck, Christian Gable, Oprah Kilmer, Warren Nolte, Lucille Tracy, Mena Temple|
|2 | Ace Goldfinger   | A Astounding Epistle of a Database Administrator And a Explorer who must Find a Car in Ancient China | Horror      |  4.99 |     48 | G      | Minnie Zellweger, Chris Depp, Bob Fawcett, Sean Guiness|

4. **nicer_but_slower_film_list**:

```console
dvdrental=# \sv nicer_but_slower_film_list
CREATE OR REPLACE VIEW public.nicer_but_slower_film_list AS
 SELECT film.film_id AS fid,
    film.title,
    film.description,
    category.name AS category,
    film.rental_rate AS price,
    film.length,
    film.rating,
    group_concat(((upper("substring"(actor.first_name::text, 1, 1)) || lower("substring"(actor.first_name::text, 2))) || upper("substring"(actor.last_name::text, 1, 1))) || lower("substring"(actor.last_name::text, 2))) AS actors
   FROM category
     LEFT JOIN film_category ON category.category_id = film_category.category_id
     LEFT JOIN film ON film_category.film_id = film.film_id
     JOIN film_actor ON film.film_id = film_actor.film_id
     JOIN actor ON film_actor.actor_id = actor.actor_id
  GROUP BY film.film_id, film.title, film.description, category.name, film.rental_rate, film.length, film.rating
```

The **nicer_but_slower_film_list** view contains a formatted view of the `film` table, with a comma-separated list of the film's actors.

The **nicer_but_slower_film_list** view differs from the **film_list** view in the list of actors. The lettercase of the actor names is adjusted so that the first letter of each name is capitalized, rather than having the name in all-caps.

As indicated in its name, the **nicer_but_slower_film_list** view performs additional processing and therefore takes longer to return data than the `film_list` view.
The **nicer_but_slower_film_list** view incorporates data from the `film`, `category`, `film_category`, `actor`, and `film_actor` tables.

|fid | title|description |category| price | length|rating|actors|
|:---:|:---:|:----------:|:------:|:------:|:----:|:----:|:-----:|
|1 | Academy Dinosaur | A Epic Drama of a Feminist And a Mad Scientist who must Battle a Teacher in The Canadian Rockies     | Documentary |  0.99 |     86 | PG     | RockDukakis, MaryKeitel, JohnnyCage, PenelopeGuiness, SandraPeck, ChristianGable, OprahKilmer, WarrenNolte, LucilleTracy, MenaTemple|
|2 | Ace Goldfinger   | A Astounding Epistle of a Database Administrator And a Explorer who must Find a Car in Ancient China | Horror      |  4.99 |     48 | G      | MinnieZellweger, ChrisDepp, BobFawcett, SeanGuiness|

5. **sales_by_film_category**

```console
dvdrental=# \sv sales_by_film_category
CREATE OR REPLACE VIEW public.sales_by_film_category AS
 SELECT c.name AS category,
    sum(p.amount) AS total_sales
   FROM payment p
     JOIN rental r ON p.rental_id = r.rental_id
     JOIN inventory i ON r.inventory_id = i.inventory_id
     JOIN film f ON i.film_id = f.film_id
     JOIN film_category fc ON f.film_id = fc.film_id
     JOIN category c ON fc.category_id = c.category_id
  GROUP BY c.name
  ORDER BY (sum(p.amount)) DESC
```

The **sales_by_film_category** view provides a list of total sales, broken down by individual film category.
Because a film can be listed in multiple categories, it is not advisable to calculate aggregate sales by totalling the rows of this view.
The **sales_by_film_category** view incorporates data from the `category`, `payment`, `rental`, `inventory`, `film`, `film_category`, and `category tables`.

|category  | total_sales|
|-----------+-------------|
|Sports    |     4892.19|
|Sci-Fi    |     4336.01|
|Animation |     4245.31|
|Drama     |     4118.46|
|Comedy    |     4002.48|

6. **sales_by_store**

```console
dvdrental=# \sv sales_by_store
CREATE OR REPLACE VIEW public.sales_by_store AS
 SELECT (c.city::text || ','::text) || cy.country::text AS store,
    (m.first_name::text || ' '::text) || m.last_name::text AS manager,
    sum(p.amount) AS total_sales
   FROM payment p
     JOIN rental r ON p.rental_id = r.rental_id
     JOIN inventory i ON r.inventory_id = i.inventory_id
     JOIN store s ON i.store_id = s.store_id
     JOIN address a ON s.address_id = a.address_id
     JOIN city c ON a.city_id = c.city_id
     JOIN country cy ON c.country_id = cy.country_id
     JOIN staff m ON s.manager_staff_id = m.staff_id
  GROUP BY cy.country, c.city, s.store_id, m.first_name, m.last_name
  ORDER BY cy.country, c.city
```

The **sales_by_store** view provides a list of total sales, broken down by store. The view returns the store location, manager name, and total sales.
The **sales_by_store** view incorporates data from the `city`, `country`, `payment`, `rental`, `inventory`, `store`, `address`, and `staff` tables.

|store        |   manager    | total_sales|
|:------------------:|:------------:|:----------:|
|Woodridge,Australia | Jon Stephens |    30683.13|
|Lethbridge,Canada   | Mike Hillyer |    30628.91|

7. **staff_list**:

```console
dvdrental=# \sv staff_list
CREATE OR REPLACE VIEW public.staff_list AS
 SELECT s.staff_id AS id,
    (s.first_name::text || ' '::text) || s.last_name::text AS name,
    a.address,
    a.postal_code AS "zip code",
    a.phone,
    city.city,
    country.country,
    s.store_id AS sid
   FROM staff s
     JOIN address a ON s.address_id = a.address_id
     JOIN city ON a.city_id = city.city_id
     JOIN country ON city.country_id = country.country_id
```

The **staff_list** view provides a list of all staff members, including address and store information. The **staff_list** view incorporates data from the staff and address tables.

|id |name| address | zip code |phone |city|country | sid|
|:--:|:--:|:---:|:---:|:---:|:---:|:---:|:---:|
|1 | Mike Hillyer | 23 Workhaven Lane    |          | 14033335568 | Lethbridge | Canada    |   1|
|2 | Jon Stephens | 1411 Lillydale Drive |          | 6172235589  | Woodridge  | Australia |   2|
