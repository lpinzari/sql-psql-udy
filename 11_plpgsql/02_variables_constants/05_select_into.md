# SELECT INTO

The `select into` statement **allows you to select data from the database and assign the data to a variable**.

The following illustrates the syntax of the **select into** statement:

```SQL
select select_list
into variable_name
from table_expression;
```

In this syntax, you place the `variable` after the `into` keyword. The `select into` statement w**ill assign the data returned by the** `select clause` **to the variable**.

Besides selecting data from a table, you can use other clauses of the select statement such as `join`, `group by`, and `having`.

## PL/pgSQL Select Into statement example

See the following example:

```SQL
do $$
declare
   actor_count integer;
begin
   -- select the number of actors from the actor table
   select count(*)
   into actor_count
   from actor;

   -- show the number of actors
   raise notice 'The number of actors: %', actor_count;
end; $$
```

Output:

```console
NOTICE:  The number of actors: 200
```

In this example:

- First, declare a variable called `actor_count` that stores the number of actors from the actor table.
- Second, use the `select into` statement to assign the number of actors to the actor_count.
- Finally, `display a message` that shows the value of the `actor_count` variable using the `raise notice` statement.

## Summary

Use the select into statement to select data from the database and assign it to a variable.
