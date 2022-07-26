# ROW TYPES

To **store the whole row of a result set** returned by the `select into` statement, you use the `row-type` **variable** or **row variable**.

You can declare a variable that has the same `datatype` as the `datatype` of the row in a table by using the following syntax:

```SQL
row_variable table_name%ROWTYPE;
row_variable view_name%ROWTYPE;
```

To access the individual field of the row variable, you use the dot notation (`.`) like this:

```SQL
row_variable.field_name
```

## PL/pgSQL row types example

We’ll use the `actor` table from the `dvdrental` sample database to show how row types work:

```console
dvdrental=# \d actor
                                            Table "public.actor"
   Column    |            Type             | Collation | Nullable |                 Default
-------------+-----------------------------+-----------+----------+-----------------------------------------
 actor_id    | integer                     |           | not null | nextval('actor_actor_id_seq'::regclass)
 first_name  | character varying(45)       |           | not null |
 last_name   | character varying(45)       |           | not null |
 last_update | timestamp without time zone |           | not null | now()
Indexes:
    "actor_pkey" PRIMARY KEY, btree (actor_id)
    "idx_actor_last_name" btree (last_name)
Referenced by:
    TABLE "film_actor" CONSTRAINT "film_actor_actor_id_fkey" FOREIGN KEY (actor_id) REFERENCES actor(actor_id) ON UPDATE CASCADE ON DELETE RESTRICT
Triggers:
    last_updated BEFORE UPDATE ON actor FOR EACH ROW EXECUTE PROCEDURE last_updated()
```

The following example shows the `first name` and `last name` of the actor id `10`:

```SQL
do $$
declare
   selected_actor actor%rowtype;
begin
   -- select actor with id 10   
   select *
   from actor
   into selected_actor
   where actor_id = 10;

   -- show the number of actor
   raise notice 'The actor name is % %',
      selected_actor.first_name,
      selected_actor.last_name;
end; $$
```

How it works.

- First, declare a row variable called `selected_actor` whose datatype is the same as the row in the actor table.
- Second, assign the row whose value in the `actor_id` column is `10` to the `selected_actor` variable by using the `select into` statement.
- Third, show the `first name` and `last name` of the `selected actor` by using the `raise notice` statement. It accessed the `first_name` and `last_name` fields using the **dot notation**.

## Summary

Use row type variables (`%ROWTYPE`) to hold a row of a result set returned by the `select into` statement.
