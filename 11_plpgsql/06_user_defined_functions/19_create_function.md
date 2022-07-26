# CREATE Function statement

The `create function` statement **allows you to define a new user-defined function**.

The following illustrates the syntax of the **create function** statement:

```SQL
create [or replace] function function_name(param_list)
   returns return_type
   language plpgsql
  as
$$
declare
-- variable declaration
begin
 -- logic
end;
$$
```

In this syntax:

- First, specify the `name` of the function after the `create function` keywords. If you want to replace the existing function, you can use the or `replace` keywords.
- Then, specify the `function parameter list` surrounded by parentheses after the function name. A function can have `zero` or `many parameters`.
- Next, specify the `datatype` of the returned value after the `returns` keyword.
- After that, use the language `plpgsql` to specify the procedural language of the function. Note that PostgreSQL supports many procedural languages, not just plpgsql.
- Finally, place a block in the `dollar-quoted string constant`.

## PostgreSQL Create Function statement examples

We’ll use the `film` table from the `dvdrental` sample database.

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

The following statement creates a **function** that `counts the films whose length between the` **len_from** and **len_to** parameters:

```SQL
create function get_film_count(len_from int, len_to int)
returns int
language plpgsql
as
$$
declare
   film_count integer;
begin
   select count(*)
   into film_count
   from film
   where length between len_from and len_to;

   return film_count;
end;
$$;
```

The function `get_film_count` has two main sections: `header` and `body`.

In the `header` section:

- First, the name of the function is `get_film_count` that follows the `create function` keywords.
- Second, the `get_film_count()` function accepts two parameters `len_from` and `len_to` with the `integer datatype`.
- Third, the `get_film_count` function returns an `integer` specified by the `returns int` clause.
- Finally, the language of the function is `plpgsql` indicated by the language plpgsql.

In the function `body`:

- Use the `dollar-quoted string constant syntax` that starts with `$$` and ends with `$$`. Between these $$, you can place a `block` that contains the `declaration` and `logic` of the function.
- In the `declaration` section, declare a variable called `film_count` that stores the number of films selected from the `film` table.
- In the `body` of the `block`, use the `select into` statement to select the number of films whose length are between `len_from` and `len_to` and assign the result to the `film_count` variable. At the end of the block, use the `return statement` to return the `film_count`.

To execute the create function statement, you can use any PostgreSQL client tool including psql and pgAdmin

## Creating a function using psql

- First, launch the `psql` interactive tool and connect to the `dvdrental` database.

- Second, enter the above code in the `psql` to create the function like this:

```console
dvdrental=# create function get_film_count(len_from int, len_to int)
dvdrental-# returns int
dvdrental-# language plpgsql
dvdrental-# as
dvdrental-# $$
dvdrental$# declare
dvdrental$#    film_count integer;
dvdrental$# begin
dvdrental$#    select count(*)
dvdrental$#    into film_count
dvdrental$#    from film
dvdrental$#    where length between len_from and len_to;
dvdrental$#
dvdrental$#    return film_count;
dvdrental$# end;
dvdrental$# $$;
CREATE FUNCTION
```

You will see the following message if the function is created successfully:

```console
CREATE FUNCTION
```

Third, use the `\df` command to list all user-defined in the current database:

```console
dvdrental=# \df
                                                          List of functions
 Schema |            Name            | Result data type |                         Argument data types                         | Type
--------+----------------------------+------------------+---------------------------------------------------------------------+------
 public | _group_concat              | text             | text, text                                                          | func
 public | film_in_stock              | SETOF integer    | p_film_id integer, p_store_id integer, OUT p_film_count integer     | func
 public | film_not_in_stock          | SETOF integer    | p_film_id integer, p_store_id integer, OUT p_film_count integer     | func
 public | get_customer_balance       | numeric          | p_customer_id integer, p_effective_date timestamp without time zone | func
 public | get_film_count             | integer          | len_from integer, len_to integer                                    | func
 public | group_concat               | text             | text                                                                | agg
 public | inventory_held_by_customer | integer          | p_inventory_id integer                                              | func
 public | inventory_in_stock         | boolean          | p_inventory_id integer                                              | func
 public | last_day                   | date             | timestamp without time zone                                         | func
 public | last_updated               | trigger          |                                                                     | func
 public | rewards_report             | SETOF customer   | min_monthly_purchases integer, min_dollar_amount_purchased numeric  | func
 ```

## Calling a user-defined function

PostgreSQL provides you with three ways **to call a user-defined function**:

- Using `positional` notation
- Using `named` notation
- Using the `mixed` notation.

## Using positional notation

To call a function using the `positional` notation, you need to specify the arguments in the `same order as parameters`. For example:

```SQL
select get_film_count(40,90);
```

Output:

```console
get_film_count
----------------
           325
(1 row)
````

In this example, the arguments of the `get_film_count()` are `40` and `90` that corresponding to the `from_len` and `to_len` parameters.

You call a function using the positional notation when the function has few parameters.

If the function **has many parameters**, you should call it using the `named notation` since it will make the function call more obvious.

## Using named notation

The following shows how to call the `get_film_count` function using the named notation:

```SQL
select get_film_count(
    len_from => 40,
     len_to => 90
);
```

Output:

```SQL
get_film_count
----------------
           325
(1 row)
```

In the named notation, you use the `=>` to **separate the argument’s name and its value**.

For backward compatibility, PostgreSQL supports the older syntax based on `:=` as follows:

```SQL
select get_film_count(
    len_from := 40,
    len_to := 90
);
```

## Using mixed notation

The mixed notation is the combination of `positional` and `named` notations. For example:

```SQL
select get_film_count(40, len_to => 90);
```

Note that **you cannot use the named arguments before positional arguments** like this:

```SQL
select get_film_count(len_from => 40, 90);
```

Error:

```console
ERROR:  positional argument cannot follow named argument
LINE 1: select get_film_count(len_from => 40, 90);
```
