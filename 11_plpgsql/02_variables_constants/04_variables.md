# Variables

A `variable` is a **meaningful name of a memory location**. A variable **holds a value that can be changed through the block**. A `variable` is always associated with a particular **data type**.

Before using a variable, you must **declare it in the declaration section** of the `PL/pgSQL` block.

The following illustrates the syntax of **declaring a variable**.

```SQL
variable_name data_type [:= expression];
```

In this syntax:

- First, specify the `name` of the variable. It is a good practice to assign a meaningful name to a variable. For example, instead of naming a variable i you should use index or counter.
- Second, **associate a specific data type with the variable**. The data type can be any valid data type such as `integer`, `numeric`, `varchar`, and `char`.
- Third, `optionally` **assign a default value to a variable**. If you don’t do so, the initial value of the variable is `NULL`.

> Note that you can use either **:=** or **=** assignment operator to initialize and assign a value to a variable.

The following example illustrates how to **declare** and **initialize** variables:

```SQL
do $$
declare
   counter    integer := 1;
   first_name varchar(50) := 'John';
   last_name  varchar(50) := 'Doe';
   payment    numeric(11,2) := 20.5;
begin
   raise notice '% % % has been paid % USD',
     counter,
	   first_name,
	   last_name,
	   payment;
end $$;
```

The `counter` variable is an **integer** that is initialized to `1`

The `first_name` and `last_name` are **varchar(50)** and initialized to '`John`' and '`Doe`' **string constants**.

The type of `payment` is **numeric** and its value is initialized to `20.5`.

## Variable initialization timing

PostgreSQL evaluates the `default value` of a variable and **assigns it to the variable when the block is entered**. For example:

```SQL
do $$
declare
   created_at time := now();
begin
   raise notice '%', created_at;
   perform pg_sleep(10);
   raise notice '%', created_at;
end $$;
```

```console
dvdrental=# do $$
dvdrental$# declare
dvdrental$#    created_at time := now();
dvdrental$# begin
dvdrental$#    raise notice '%', created_at;
dvdrental$#    perform pg_sleep(10);
dvdrental$#    raise notice '%', created_at;
dvdrental$# end $$;
NOTICE:  01:08:13.460696
```

After ten seconds

```console
NOTICE:  01:08:13.460696
NOTICE:  01:08:13.460696
DO
```

In this example:

- First, declare a variable whose default value is initialized to the current time.
- Second, print out the value of the variable and pass the execution in 10 seconds using the `pg_sleep()` function.
- Third, print out the value of the `created_at` variable again.

As shown clearly from the output, the value of the `created_at` **is only initialized once when the block is entered**.

## Copying data types

The `%type` provides the data type of a table column or another variable. Typically, you use the `%type` to **declare a variable that holds a value from the database or another variable**.

The following illustrates how to **declare a variable** `with the data type` **of a table column**:

```SQL
variable_name table_name.column_name%type;
```

And the following shows how to **declare a variable** `with the data type` **of another variable**:

```SQL
variable_name variable%type;
```

See the following `film` table from the `dvdrental` sample database:

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

This example uses the type **copying technique to declare variables that hold values** which come from the `film` table:

```SQL
do $$
declare
   film_title film.title%type;
   featured_title film_title%type;
begin
   -- get title of the film id 100
   select title
   from film
   into film_title
   where film_id = 100;

   -- show the film title
   raise notice 'Film title id 100: %s', film_title;
end; $$
```

This example declared two variables:

- The `film_title` **variable has the same data type as the** `title` **column** in the `film` **table** from the sample database.
- The `featured_title` **variable has the same data type as the** data type of the `film_title` variable.

By using **type copying feature**, you get the following advantages:

- First, you don’t need to know the type of the column or reference that you are referencing.
- Second, if the data type of the referenced column name (or variable) changes, you don’t need to change the definition of the function.

## Variables in block and subblock

When you declare a variable in a `subblock` which has the same name as another variable in the `outer block`, the variable in the `outer block` **is hidden in the subblock**.

In case you want to access a variable in the `outer block`, you use the `block label` **to qualify its name** as shown in the following example:

```SQL
do $$
<<outer_block>>
declare
  counter integer := 0;
begin
   counter := counter + 1;
   raise notice 'The current value of the counter is %', counter;

   declare
       counter integer := 0;
   begin
       counter := counter + 10;
       raise notice 'Counter in the subblock is %', counter;
       raise notice 'Counter in the outer block is %', outer_block.counter;
   end;

   raise notice 'Counter in the outer block is %', counter;

end outer_block $$;
```

```console
NOTICE:  The current value of the counter is 1
NOTICE:  Counter in the subblock is 10
NOTICE:  Counter in the outer block is 1
NOTICE:  Counter in the outer block is 1
DO
```

In this example:

- First, declare a variable named `counter` in the `outer_block`.
- Next, declare a variable with the same name in the `subblock`.
- Then, before entering into the `subblock`, the value of the `counter` is one. In the `subblock`, we increase the value of the counter to **ten** and print it out. Notice that the change only affects the counter variable in the `subblock`.
- After that, reference the counter variable in the outer block using the block label to qualify its name `outer_block.counter`.
- Finally, print out the value of the `counter` variable in the outer block, its value remains intact.

In this lesson, you have learned the various ways to declare PL/pgSQL variables.
