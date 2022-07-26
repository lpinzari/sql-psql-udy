# Function That Returns a Table

To define a **function that returns a table**, you use the following form of the create function statement:

```SQL
create or replace function function_name (
   parameter_list
)
returns table ( column_list )
language plpgsql
as $$
declare
-- variable declaration
begin
-- body
end; $$;
```


Instead of returning a single value, this syntax allows you to return a table with a specified column list:

```SQL
returns table ( column_list )
```

We will use the `film` table from the `dvdrental` sample database for the demonstration:

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

The following function returns all films whose titles match a particular pattern using `ILIKE` operator.

```SQL
create or replace function get_film (
    p_pattern varchar
)
returns table (film_title varchar,film_release_year int)
language plpgsql
as $$
begin
  return query
    select
      title,
      release_year::integer
    from film
   where title ilike p_pattern;
end;$$;
```

This `get_film(varchar)` accepts one parameter `p_pattern` which is a pattern that you want to match with the `film title`.

The function returns `a query` that is the result of a select statement. Note that the columns in the result set must be the same as the columns in the table defined after the returns table clause.

Because the data type of `release_year` column from the film table is not integer, you need **to cast it to an integer using the cast operator** `::`.

The folowing shows how to call the `get_film()` function:

```SQL
SELECT * FROM get_film ('Al%');
```

```console
dvdrental=# SELECT * FROM get_film ('Al%');
    film_title    | film_release_year
------------------+-------------------
 Alabama Devil    |              2006
 Aladdin Calendar |              2006
 Alamo Videotape  |              2006
 Alaska Phantom   |              2006
 Ali Forever      |              2006
 Alice Fantasia   |              2006
 Alien Center     |              2006
 Alley Evolution  |              2006
 Alone Trip       |              2006
 Alter Victory    |              2006
(10 rows)
```

If you call the function using the following statement, PostgreSQL returns a table that consists of one column that holds an array of rows:

```SQL
SELECT get_film ('Al%');
```

```console
dvdrental=# SELECT get_film ('Al%');
         get_film
---------------------------
 ("Alabama Devil",2006)
 ("Aladdin Calendar",2006)
 ("Alamo Videotape",2006)
 ("Alaska Phantom",2006)
 ("Ali Forever",2006)
 ("Alice Fantasia",2006)
 ("Alien Center",2006)
 ("Alley Evolution",2006)
 ("Alone Trip",2006)
 ("Alter Victory",2006)
(10 rows)
```

In practice, you often process each individual row before appending it in the function’s result set:

```SQL
create or replace function get_film (
  p_pattern varchar,
  p_year int
)
returns table (
  film_title varchar,
  film_release_year int
)
language plpgsql
as $$
declare
   var_r record;
begin
  for var_r in(
            select title, release_year
              from film
             where title ilike p_pattern and
                   release_year = p_year
                 )
             loop  film_title := upper(var_r.title) ;
             film_release_year := var_r.release_year;
             return next;
             end loop;
end; $$;
```

In this example, we created the `get_film(varchar,int)` that accepts two parameters:

- The `p_pattern` is used to search for films.
- The `p_year` is the release year of the films.

In the function `body`, we used a `for loop staetment` to process the query row by row.

The `return next` statement adds a row to the returned table of the function.

The following illustrates how to call the `get_film()` function:

```SQL
SELECT * FROM get_film ('%er', 2006);
```

```console
dvdrental=# SELECT * FROM get_film ('%er', 2006);
         film_title          | film_release_year
-----------------------------+-------------------
 ACE GOLDFINGER              |              2006
 ALI FOREVER                 |              2006
 ALIEN CENTER                |              2006
 AMISTAD MIDSUMMER           |              2006
 ARACHNOPHOBIA ROLLERCOASTER |              2006
 DYING MAKER                 |              2006
 BIRDCAGE CASPER             |              2006
 BOUND CHEAPER               |              2006
 BREAKFAST GOLDFINGER        |              2006
 BUTCH PANTHER               |              2006
 CAMPUS REMEMBER             |              2006
 CASABLANCA SUPER            |              2006
 ```

 > Note that this example is for the demonstration purposes.
