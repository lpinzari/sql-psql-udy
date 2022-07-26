# Exceptions

When an **error occurs in a block**, PostgreSQL will abort the execution of the block and also the surrounding transaction.

To **recover from the error**, you can use the **exception clause** in the `begin...end block`.

The following illustrates the syntax of the `exception clause`:

```SQL
<<label>>
declare
begin
    statements;
exception
    when condition [or condition...] then
       handle_exception;
   [when condition [or condition...] then
       handle_exception;]
   [when others then
       handle_other_exceptions;
   ]
end;
```

How it works.

- First, when an `error occurs` between the begin and exception, PL/pgSQL **stops the execution** and **passes the control to the exception list**.
- Second, PL/pgSQL searches for the `first condition that matches the occurring error`.
- Third, if there is a match, the corresponding `handle_exception` statements will execute. PL/pgSQL passes the control to the statement after the `end` keyword.
- Finally, if no match found, the error propagates out and can be caught by the `exception` clause of the enclosing block. In case there is no enclosing block with the `exception` clause, PL/pgSQL will abort the processing.

The condition names can be `no_data_found` in case of a select statement return no rows or `too_many_rows` if the select statement returns more than one row. For a complete list of condition names on the [PostgreSQL website](https://www.postgresql.org/docs/current/errcodes-appendix.html).

It’s also possible to specify the error condition by `SQLSTATE` code. For example, `P0002` for `no_data_found` and `P0003` for `too_many_rows`.

Typically, you will catch a specific exception and handle it accordingly. To handle other exceptions rather than the one you specify on the list, you can use the `when others then clause`.

## Handling exception examples

We’ll use the `film` table from the `dvdrental` sample database for the demonstration.

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

## Handling no_data_found exception example

The following example issues **an error** because the film with id `2000` **does not exist**.

```SQL
do
$$
declare
	rec record;
	v_film_id int = 2000;
begin
	-- select a film
	select film_id, title
	into strict rec
	from film
	where film_id = v_film_id;
end;
$$
language plpgsql;
```

Output:

```SQL
ERROR:  query returned no rows
CONTEXT:  PL/pgSQL function inline_code_block line 6 at SQL statement
SQL state: P0002
```

The following example uses the exception clause to catch the `no_data_found` exception and **report a more meaningful message**:

```SQL
do
$$
declare
	rec record;
	v_film_id int = 2000;
begin
	-- select a film
	select film_id, title
	into strict rec
	from film
	where film_id = v_film_id;
        -- catch exception
	exception
	   when no_data_found then
	      raise exception 'film % not found', v_film_id;
end;
$$
language plpgsql;
```

Output:

```SQL
ERROR:  film 2000 not found
CONTEXT:  PL/pgSQL function inline_code_block line 14 at RAISE
SQL state: P0001
```

## Handling too_many_rows exception example

The following example illustrates how to handle the `too_many_rows` exception:

```SQL
do
$$
declare
	rec record;
begin
	-- select film
	select film_id, title
	into strict rec
	from film
	where title LIKE 'A%';

	exception
	   when too_many_rows then
	      raise exception 'Search query returns too many rows';
end;
$$
language plpgsql;
```

Output:

```SQL
ERROR:  Search query returns too many rows
CONTEXT:  PL/pgSQL function inline_code_block line 15 at RAISE
SQL state: P0001
```

In this example, the `too_many_rows` exception occurs because the select into statement returns **more than one row while it is supposed to return one row**.

## Handling multiple exceptions

The following example illustrates **how to catch multiple exceptions**:

```SQL
do
$$
declare
	rec record;
	v_length int = 90;
begin
	-- select a film
	select film_id, title
	into strict rec
	from film
	where length = v_length;

        -- catch exception
	exception
	   when sqlstate 'P0002' then
	      raise exception 'film with length % not found', v_length;
	   when sqlstate 'P0003' then
	      raise exception 'The with length % is not unique', v_length;
end;
$$
language plpgsql;
```

Output:

```SQL
ERROR:  The with length 90 is not unique
CONTEXT:  PL/pgSQL function inline_code_block line 17 at RAISE
SQL state: P0001
```

## Handling exceptions as SQLSTATE codes

The following example is the same as the one above except that it uses the `SQLSTATE` **codes** instead of the `condition names`:

```SQL
do
$$
declare
	rec record;
	v_length int = 30;
begin
	-- select a film
	select film_id, title
	into strict rec
	from film
	where length = v_length;

        -- catch exception
	exception
	   when sqlstate 'P0002' then
	      raise exception 'film with length % not found', v_length;
	   when sqlstate 'P0003' then
	      raise exception 'The with length % is not unique', v_length;
end;
$$
language plpgsql;
```

Output:

```SQL
ERROR:  film with length 30 not found
CONTEXT:  PL/pgSQL function inline_code_block line 15 at RAISE
SQL state: P0001
```
