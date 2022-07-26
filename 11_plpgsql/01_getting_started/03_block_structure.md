# BLOCK Structure

`PL/pgSQL` is a **block-structured language**, therefore, a PL/pgSQL **function** or **stored procedure** is organized into blocks.

The following illustrates the syntax of a **complete block** in `PL/pgSQL`:

```SQL
[ <<label>> ]
[ declare
    declarations ]
begin
    statements;
	...
end [ label ];
```

Let’s examine the **block structure** in more detail:

- Each block has two sections: `declaration` and `body`.
  - The declaration section is optional while the body section is required.
- A **block** is ended with a semicolon (`;`) after the `END` keyword.
- A block may have an **optional label** located at the beginning and at the end. You use the block label when you want to specify it in the `EXIT` statement of the block body or when you want to qualify the names of variables declared in the block.
- The declaration section is where you declare all variables used within the body section. Each statement in the declaration section is terminated with a semicolon (;).
- The body section is where you place the code. Each statement in the body section is also terminated with a semicolon (;).

## PL/pgSQL block structure example

The following example illustrates a very simple block. It is called an **anonymous block**.

```SQL
do $$
<<first_block>>
declare
  film_count integer := 0;
begin
   -- get the number of films
   select count(*)
   into film_count
   from film;
   -- display a message
   raise notice 'The number of films is %', film_count;
end first_block $$;
```

```console
NOTICE:  The number of films is 1000
DO
```

Notice that the DO statement does not belong to the block. It is used to execute an anonymous block. PostgreSQL introduced the `DO` statement since version 9.0.

The anonymous block has to be surrounded in single quotes like this:

```SQL
'<<first_block>>
declare
  film_count integer := 0;
begin
   -- get the number of films
   select count(*)
   into film_count
   from film;
   -- display a message
   raise notice ''The number of films is %'', film_count;
end first_block';
```

However, we used the **dollar-quoted string constant** syntax to make it more readable.

In the `declaration` section, we declared a variable `film_count` and **set its value to** `zero`.

```SQL
film_count integer := 0;
```

Inside the body section, we used a `select` `into` statement with the `count()` function to get the number of films from the film table and assign the result to the `film_count` **variable**.

```SQL
select count(*)
into film_count
from film;
```

After that, we showed a message using `raise notice` **statement**:

```SQL
raise notice 'The number of films is %', film_count;
```

The `%` is a placeholder that is replaced by the content of the `film_count` variable.

Note that the `first_block` label is just for demonstration purposes. **It does nothing in this example**.

## PL/pgSQL Subblocks

**PL/pgSQL** allows you to place a block inside the body of another block.

The block nested inside another block is called a **subblock**. The block that contains the **subblock** is referred to as an **outer block**.

The following picture illustrates the **outerblock** and **subblock**:

![block 1](./images/01_block.png)

Typically, you divide a large block into smaller and more logical `subblocks`. The variables in the `subblock` **can have the names as the ones in the outer block, even though it is not a good practice**.

## Summary

- PL/pgSQL is a blocked-structure language. It organize a program into blocks.
- A block contains two parts: declaration and body. The declaration part is optional while the body part is mandatory.
- Blocks can be nested. A nested block is a block placed inside the body of another block.
