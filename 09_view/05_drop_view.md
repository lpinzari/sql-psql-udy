# Destroying (Dropping) Views

The **DROP VIEW** statement removes a view from the database. The following illustrates the syntax of the `DROP VIEW` statement:

```SQL
DROP VIEW [IF EXISTS] view_name
[CASCADE | RESTRICT]
```
In this syntax:

- First, specify the name of the view after the `DROP VIEW` keywords.
- Second, use the `IF EXISTS` option to drop a view only if it exists. If you don’t use the `IF EXISTS` option and drop a view that does not exist, PostgreSQL will issue an error. However, if you use the `IF EXISTS` option, PostgreSQL issues a notice instead.
- Third, use the `RESTRICT` option to reject the removal of the view if there are any objects depending on it. The `RESTRICT` option is the default. If you use the `CASCADE` option, the `DROP VIEW` automatically drops objects that depend on view and all objects that depend on those objects.

To remove multiple views using a single statement, you specify a comma-separated list of view names after the `DROP VIEW` keywords like this:

```SQL
DROP VIEW [IF EXISTS] view_name1, view_name2, ...;
```

To execute the `DROP VIEW` statement, you must be the owner of the view.

## PostgreSQL DROP VIEW statement examples

See the following `film`, `film_category`, and `category` tables from the `dvdrental` sample database:

![drop view](./images/03_drop.png)

Let’s create new views for practising.

The following statement creates a view based on the information from those tables:

```SQL
CREATE VIEW film_master AS
       SELECT film_id,
              title,
              release_year,
              length,
              name AS category
         FROM film
        INNER JOIN film_category USING (film_id)
        INNER JOIN category USING(category_id);
```

The following statement creates a view called `horror_film` based on the `film_master` view:

```SQL
CREATE VIEW horror_film AS
       SELECT film_id,
              title,
              release_year,
              length
         FROM film_master
        WHERE category = 'Horror';
```

And the following statement creates also a view called `comedy_film` based on the `film_master` view:

```SQL
CREATE VIEW comedy_film AS
       SELECT film_id,
              title,
              release_year,
              length
         FROM film_master
        WHERE category = 'Comedy';
```

The following statement creates a view that returns the number of films by category:

```SQL
CREATE VIEW film_category_stat AS
       SELECT name,
              COUNT(film_id)
         FROM category
        INNER JOIN film_category USING (category_id)
        INNER JOIN film USING (film_id)
        GROUP BY name;
```

The following creates a view that returns the total length of films for each category:

```SQL
CREATE VIEW film_length_stat AS
       SELECT name,
              SUM(length) film_length
         FROM category
        INNER JOIN film_category USING (category_id)
        INNER JOIN film USING (film_id)
        GROUP BY name;
```


| Schema |            Name            | Type |      Owner|
|:-------:|:-------------------------:|:----:|---------------:|
| public | comedy_film                | view | ludovicopinzari|
| public | film_category_stat         | view | ludovicopinzari|
| public | film_length_stat           | view | ludovicopinzari|
| public | film_master                | view | ludovicopinzari|
| public | horror_film                | view | ludovicopinzari|

## Using PostgreSQL DROP VIEW to drop one view

The following example uses the **DROP VIEW** statement to drop the `comedy_film` view:

```SQL
DROP VIEW comedy_film;
```

```console
dvdrental=# DROP VIEW comedy_film;
DROP VIEW
```

| Schema |            Name            | Type |      Owner|
|:-------:|:-------------------------:|:----:|---------------:|
| public | film_category_stat         | view | ludovicopinzari|
| public | film_length_stat           | view | ludovicopinzari|
| public | film_master                | view | ludovicopinzari|
| public | horror_film                | view | ludovicopinzari|

## Using PostgreSQL DROP VIEW statement to drop a view that has dependent objects

The following statement uses the **DROP VIEW** statement to drop the `film_master` view:

```SQL
DROP VIEW film_master;
```

PostgreSQL issued an error:

```console
ERROR:  cannot drop view film_master because other objects depend on it
DETAIL:  view horror_film depends on view film_master
HINT:  Use DROP ... CASCADE to drop the dependent objects too.
SQL state: 2BP01
```

The `film_master` has a dependent object which is the view `horror_film`.

To drop the view `film_master`, you need to drop its dependent object first or use the **CASCADE** option like this:

```SQL
DROP VIEW film_master
CASCADE;
```

This statement drops the `film_master` view as well as its dependent object which is the `horror_film`. It issued the following notice:

```console
dvdrental=# DROP VIEW film_master
dvdrental-# CASCADE;
NOTICE:  drop cascades to view horror_film
DROP VIEW
```


| Schema |            Name            | Type |      Owner|
|:-------:|:-------------------------:|:----:|---------------:|
| public | film_category_stat         | view | ludovicopinzari|
| public | film_length_stat           | view | ludovicopinzari|
| public | horror_film                | view | ludovicopinzari|

## Using PostgreSQL DROP VIEW to drop multiple views

The following statement uses a single **DROP VIEW** statement to drop multiple views:

```SQL
DROP VIEW film_length_stat, film_category_stat;
```

## Summary

- Use the `DROP VIEW` statement to remove one or more views from the database.
- Use the `IF EXISTS` option to remove a view if it exists.
- Use the `CASCADE` option to remove a view and its dependent objects recursively.
