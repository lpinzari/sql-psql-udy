## Introduction the dollar-quoted string constant syntax

In PostgreSQL, you use `single quotes` for a string constant like this:

```SQL
select 'String constant';
```

When a string constant contains a single quote ('), you need to escape it by doubling up the single quote. For example:

```SQL
select 'I''m also a string constant';
```

If you use an old version of PostgreSQL, you can prepend the string constant with `E` to declare the postfix escape string syntax and **use the backslash** `\` **to escape the single quote like this**:

```SQL
select E'I\'m also a string constant';
```

If a string constant contains a backslash, you need to escape it by using another backslash.

The problem arises when the string constant contains many single quotes and backslashes. Doubling every single quote and backslash makes the string constant more difficult to read and maintain.

PostgreSQL version 8.0 introduced the **dollar quoting feature to make string constants more readable**.

The following shows the syntax of the **dollar-quoted string constants**:

```SQL
$tag$<string_constant>$tag$
```

In this syntax, the `tag` is optional. It may contain zero or many characters.

Between the `$tag$`, **you can place any string with single quotes** (') **and backslashes** (`\`). For example:

```console
select $$I'm a string constant that contains a backslash \$$;
```

In this example, we did not specify the tag between the two dollar signs($).

The following example uses the **dollar-quoted string constant syntax with a tag**:

```console
SELECT $message$I'm a string constant that contains a backslash \$message$;
```

|?column?|
|:-------------------------------------------------:|
|I'm a string constant that contains a backslash \|

In this example, we used the **string** `message` as a tag between the two dollar signs (`$`)

## Using dollar-quoted string constant in anonymous blocks

The following shows the anonymous block in `PL/pgSQL`:

```console
do
'declare
   film_count integer;
begin
   select count(*) into film_count
   from film;
   raise notice ''The number of films: %'', film_count;
end;';
```

> Note that you will learn about the anonymous block in the PL/pgSQL block structure tutorial. In this tutorial, you can copy and paste the code in any PostgreSQL client tool like pgAdmin or psql to execute it.

The code in the block must be surrounded by single quotes. If it has any single quote, you need to escape it by doubling it like this:

```console
 raise notice ''The number of films: %'', film_count;
```

To avoid escaping every single quotes and backslashes, you can use the **dollar-quoted string** as follows:

```SQL
do
$$
declare
   film_count integer;
begin
   select count(*) into film_count
   from film;
   raise notice 'The number of films: %', film_count;
end;
$$
```

In this example, you don’t need to escape the single quotes and backslashes.

## Using dollar-quoted string constants in functions

The following shows the syntax of the `CREATE FUNCTION` statement that allows you to create a **user-defined function**:

```SQL
create function function_name(param_list)
    returns datatype
language lang_name
as
 'function_body'
```

> Note that you will learn more about the syntax of CREATE FUNCTION statement in the creating function tutorial.

In this syntax, the `function_body` is a **string constant**. For example, the following function **finds a film by its id**:

```SQL
create function find_film_by_id(
   id int
) returns film
language sql
as
  'select * from film
   where film_id = id';
```

As you can see, the `body` of the `find_film_by_id()` **function** is **surrounded by single quotes**.

If the function has **many statements**, it becomes more difficult to read. In this case, you can use **dollar-quoted string constant syntax**:

```SQL
create function find_film_by_id(
   id int
) returns film
language sql
as
$$
  select * from film
  where film_id = id;  
$$;
```

Now, you **can place any piece of code** between the `$$` and `$$` without using single quotes or backslashes to escape single quotes and backslashes.

## Using dollar-quoted string constants in stored procedures

Similarly, you can use the `dollar-quoted string constant` syntax in **stored procedures like this**:

```SQL
create procedure proc_name(param_list)
language lang_name
as $$
  -- stored procedure body
$$
```
