# Function Parameter Modes: IN, OUT, INOUT

he parameter modes determine the `behaviors of parameters`. PL/pgSQL supports three **parameter modes**: `in`, `out`, and `inout`. A parameter takes the in mode by default if you do not explicitly specify it.

The following table illustrates the three parameter modes:

|IN|	OUT|	INOUT|
|:--:|:---:|:---:|
|The default|	Explicitly specified|	Explicitly specified|
|Pass a value to function|	Return a value from a function|	Pass a value to a function and return an updated value.|
|in parameters act like constants|	out parameters act like uninitialized variables|	inout parameters act like an initialized variables|
|Cannot be assigned a value|	Must assign a value|	Should be assigned a value|

## The IN mode

The following function finds a film by its id and returns the title of the film:

```SQL
create or replace function find_film_by_id(p_film_id int)
returns varchar
language plpgsql
as $$
declare
   film_title film.title%type;
begin
  -- find film title by id
  select title
  into film_title
  from film
  where film_id = p_film_id;

  if not found then
     raise 'Film with id % not found', p_film_id;
  end if;

  return title;

end;$$
```

Because we didn’t specify the mode for `p_film_id` parameter, it takes the `in` mode by default.

## The OUT mode

The out parameters are defined as a part of the argument list and are returned back as a part of the result.

The out parameters are **very useful in functions that need to return multiple values**.

> Note that PostgreSQL has supported the out parameters since version 8.1.

To define `out` parameters, you explicitly precede the parameter name with the `out` keyword as follows:

```SQL
out parameter_name type
```

The following example defines the `get_film_stat` function that has `three out parameters`:

```SQL
create or replace function get_film_stat(
    out min_len int,
    out max_len int,
    out avg_len numeric)
language plpgsql
as $$
begin

  select min(length),
         max(length),
		 avg(length)::numeric(5,1)
  into min_len, max_len, avg_len
  from film;

end;$$
```

In the `get_film_stat` function, we select the `min`, `max`, and `average` of film length **from the film table using** the `min`, `max`, and `avg` aggregate functions and **assign the results to the corresponding out parameters**.

The following statement calls the `get_film_stat` function:

```SQL
select get_film_stat();
```

Output:

|get_film_stat|
|:-----------:|
|(46,185,115.3)|

The output of the function is a record. To make the output separated as columns, you use the following statement:

```SQL
select * from get_film_stat();
```

Output:

|min_len|max_len|avg_len|
|:--:|:--:|:--:|
|46|185|115.3|

## The INOUT mode

The `inout mode` is the combination `in` and `out` modes.

It means that the caller can pass an argument to a function. The function changes the argument and returns the updated value.

The following `swap` function accepts two integers and their values:

```SQL
create or replace function swap(
	inout x int,
	inout y int
)
language plpgsql
as $$
begin
   select x,y into y,x;
end; $$;
```

The following statement calls the `swap()` function:

```SQL
select * from swap(10,20);
```

Output:

|x|y|
|:-:|:-:|
|20|10|

## Summary

PL/pgSQL support three parameter modes: in, out, and intout. By default, a parameter takes the in mode.

- Use the `in` mode if you want to pass a value to the function.
- Use the `out` mode if you want to return a value from a function.
- Use the `inout` mode when you want to pass in an initial value, update the value in the function, and return it updated value back.
