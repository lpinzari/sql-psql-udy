# ASSERTS

> Notice that PostgreSQL introduced the assert statement since version 9.5. Check your PostgreSQL version before using it.

The **assert statement** is a useful shorthand for **inserting debugging checks into PL/pgSQL code**.

The following illustrates the syntax of the **assert statement**:

```SQL
assert condition [, message];
```

In this syntax:

##  condition

The condition is a **Boolean expression that is expected to always return true**.

If the condition evaluates to true, the assert statement does nothing.

In case the condition evaluates to `false` or `null`, **PostgreSQL raises an** `assert_failure` exception.

## message

The message is optional.

If you don’t pass the message, PostgreSQL uses the “`assertion failed`” message by default. In case you pass the message to the assert statement, it will use it to replace the default message.

> Note that you should use the assert statement solely for detecting bugs, not for reporting. To report a message or an error, you use the raise statement instead.

## Enable / Disable Assertions

PostgreSQL provides the `plpgsql.check_asserts` configuration parameter to enable or disable assertion testing. If you set this parameter to `off`, **the assert statement will do nothing**.

## PostgreSQL assert statement example

The following example uses the `assert statement` to **check if the** `film` table from the sample database has data:

```SQL
do $$
declare
   film_count integer;
begin
   select count(*)
   into film_count
   from film;

   assert film_count > 0, 'Film not found, check the film table';
end$$;
```

Because the `film` table has data, **the block did not issue any message**.

The following example issue an error because the number of films from the film table is not greater than `1,000`.

```SQL
do $$
declare
   film_count integer;
begin
   select count(*)
   into film_count
   from film;

   assert film_count > 1000, '1000 Film found, check the film table';
end$$;
```

Output:

```console
ERROR:  1000 Film found, check the film table
CONTEXT:  PL/pgSQL function inline_code_block line 9 at ASSERT
SQL state: P0004
```

## Summary

- Use the assert statement to add debugging checks to the PL/pgSQL code.
- The assert statement evaluates a condition that is expected to be true and issues an error in case the condition is false or null.
- Use the assert statement for detecting bugs only. For reporting ordinary messages and errors, use the raise statement instead.
