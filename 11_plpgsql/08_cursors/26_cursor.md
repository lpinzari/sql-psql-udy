# CURSOR

A PL/pgSQL cursor allows you to encapsulate a query and process each individual row at a time.

Typically, you use cursors when **you want to divide a large result set into parts and process each part individually**. If you process it at once, you may have a memory overflow error.

On top of that, you can `develop a function` that **returns a reference to a cursor**. This is an effective way to return a large result set from a function. The caller of the function can process the result set based on the cursor reference.

The following diagram illustrates how to use a cursor in PostgreSQL:

![cursor](./images/01_cursor.png)

- First, declare a cursor.
- Next, open the cursor.
- Then, fetch rows from the result set into a target.
- After that, check if there is more row left to fetch. If yes, go to step 3, otherwise, go to step 5.
- Finally, close the cursor.

We will examine each step in more detail in the following sections.

## Declaring cursors

To access to a cursor, you need to declare a `cursor` **variable in the declaration section of a block**. PostgreSQL provides you with a special type called `REFCURSOR` to declare a cursor variable.

```SQL
declare my_cursor refcursor;
```

You can also declare a cursor that bounds to a query by using the following syntax:

```SQL
cursor_name [ [no] scroll ] cursor [( name datatype, name data type, ...)] for query;
```

- First, you specify a variable `name` for the cursor.

- Next, you specify **whether the cursor can be scrolled backward** using the `SCROLL`. If you use `NO SCROLL`, the cursor cannot be scrolled backward.

- Then, you put the `CURSOR` keyword followed by a list of `comma-separated arguments ( name datatype)` that defines parameters for the query. These arguments will be substituted by values when the cursor is opened.

- After that, you specify a query following the `FOR` keyword. You can use any valid SELECT statement here.

The following example illustrates how to declare cursors:

```SQL
declare
    cur_films  cursor for
		select *
		  from film;
    cur_films2 cursor (year integer) for
		select *
		  from film
		 where release_year = year;
```

The `cur_films` is a **cursor** that encapsulates all rows in the `film` table.

The `cur_films2` is a **cursor** that encapsulates film with a particular release year in the `film` table.

## Opening cursors

Cursors must be opened before they can be used to query rows. PostgreSQL provides the syntax for opening an unbound and bound cursor.

## Opening unbound cursors

You **open an** `unbound cursor` using the following syntax:

```SQL
OPEN unbound_cursor_variable [ [ NO ] SCROLL ] FOR query;
```

Because the unbound cursor variable is not bounded to any query when we declared it, we have to specify the query when we open it. See the following example:

```SQL
open my_cursor for
	select *
    from city
	 where country = p_country;
```

PostgreSQL allows you to open a cursor and bound it to a `dynamic query`. Here is the syntax:

```SQL
open unbound_cursor_variable[ [ no ] scroll ]
for execute query_string [using expression [, ... ] ];
```

In the following example, we build a dynamic query that sorts rows based on a `sort_field` parameter and open the cursor that executes the dynamic query.

```SQL
query := 'select * from city order by $1';

open cur_city for execute query using sort_field;
```

## Opening bound cursors

Because a bound cursor already bounds to a query when we declared it, so when we open it, we just need to pass the arguments to the query if necessary.

```SQL
open cursor_variable[ (name:=value,name:=value,...)];
```

In the following example, we open bound cursors `cur_films` and `cur_films2` that we declared above:

```SQL
open cur_films;
open cur_films2(year:=2005);
```

## Using cursors

After opening a cursor, we can manipulate it using `FETCH`, `MOVE`, `UPDATE`, or `DELETE` statement.

## Fetching the next row

```SQL
fetch [ direction { from | in } ] cursor_variable
into target_variable;
```

The `FETCH` statement gets the next row from the cursor and assigns it a `target_variable`, which could be a record, a row variable, or a comma-separated list of variables. If no more row found, the `target_variable` is set to `NULL(s)`.

By default, a cursor gets the next row if you don’t specify the direction explicitly. The following is valid for the  cursor:

- NEXT
- LAST
- PRIOR
- FIRST
- ABSOLUTE count
- RELATIVE count
- FORWARD
- BACKWARD

Note that `FORWARD` and `BACKWARD` directions are only for cursors declared with `SCROLL` option.

See the following examples of fetching cursors.

```SQL
fetch cur_films into row_film;
fetch last from row_film into title, release_year;
```

## Moving the cursor

```SQL
move [ direction { from | in } ] cursor_variable;
```

If you want to move the cursor only without retrieving any row, you use the `MOVE` statement. The direction accepts the same value as the `FETCH` statement.

```SQL
move cur_films2;
move last from cur_films;
move relative -1 from cur_films;
move forward 3 from cur_films;
```


## Deleting or updating the row

Once a cursor is positioned, we can delete or update row identifying by the cursor using `DELETE WHERE CURRENT OF` or `UPDATE WHERE CURRENT OF` statement as follows:

```SQL
update table_name
set column = value, ...
where current of cursor_variable;

delete from table_name
where current of cursor_variable;
```

See the following example.

```SQL
update film
set release_year = p_year
where current of cur_films;
```

## Closing cursors

To close an opening cursor, we use `CLOSE` statement as follows:

```SQL
close cursor_variable;
```

The `CLOSE` statement releases resources or frees up cursor variable to allow it to be opened again using `OPEN` statement.

## PL/pgSQL cursors – putting it all together

The following `get_film_titles(integer)` function accepts an argument that represents the release year of a `film`. Inside the function, we query all films whose release year equals to the released year passed to the function. We use the cursor to loop through the rows and concatenate the title and release year of film that has the title contains the `ful` word.

```SQL
create or replace function get_film_titles(p_year integer)
   returns text as $$
declare
	 titles text default '';
	 rec_film   record;
	 cur_films cursor(p_year integer)
		 for select title, release_year
		 from film
		 where release_year = p_year;
begin
   -- open the cursor
   open cur_films(p_year);

   loop
    -- fetch row into the film
      fetch cur_films into rec_film;
    -- exit when no more row to fetch
      exit when not found;

    -- build the output
      if rec_film.title like '%ful%' then
         titles := titles || ',' || rec_film.title || ':' || rec_film.release_year;
      end if;
   end loop;

   -- close the cursor
   close cur_films;

   return titles;
end; $$

language plpgsql;
```

```SQL
select get_film_titles(2006);
```

```console
,Grosse Wonderful:2006,Day Unfaithful:2006,Reap Unfaithful:2006,Unfaithful Kill:2006,Wonderful Drop:2006
```

In this lesson, you have learned how to work with PL/pgSQL cursor to loop through a set of rows and process each row individually.
