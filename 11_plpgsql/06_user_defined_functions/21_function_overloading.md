# Function Overloading

PostgreSQL allows **multiple functions to share the same name** `as long as they have different arguments`.

If **two or more functions share the same name**, the `function names are overloaded`.

When you can call an overloading function, PostgreSQL select the best candidate function to execute based on the the `function argument list`.

The following `get_rental_duration()` function returns the total rental days of a specified customer:

```SQL
create or replace function get_rental_duration(
	p_customer_id integer
)
returns integer
language plpgsql
as $$
declare
	rental_duration integer;
begin
	select
		sum( extract(day from return_date - rental_date))
	into rental_duration
    from rental
	where customer_id = p_customer_id;

	return rental_duration;
end; $$
```

The `get_rental_function` function has the `p_customer_id` as an `in` parameter.

The following return the number of rental days of the customer id `232`:

```SQL
SELECT get_rental_duration(232);
```
```console
get_rental_duration
---------------------
                 90
(1 row)
```

Suppose that you want to know the rental duration of a customer from a specific date up to now.

To do it, you can add one more parameter `p_from_date` to the `get_retal_duration()` function. Or you can **develop a new function** with the same name but `have two parameters` like this:

```SQL
create or replace function get_rental_duration(
	p_customer_id integer,
	p_from_date date
)
returns integer
language plpgsql
as $$
declare
	rental_duration integer;
begin
	-- get the rental duration based on customer_id
	-- and rental date
	select sum( extract( day from return_date + '12:00:00' - rental_date))
	into rental_duration
	from rental
	where customer_id = p_customer_id and
		  rental_date >= p_from_date;

	-- return the rental duration in days
	return rental_duration;
end; $$
```

This function has the same name as the first one except that it has two parameters.

In other words, the `get_rental_duration(integer)` function is overloaded by the `get_rental_duration(integer,date)` function.

The following statement returns the rental duration of the customer id `232` since `July 1st 2005`:

```SQL
SELECT get_rental_duration(232,'2005-07-01');
```

```console
get_rental_duration
---------------------
                 85
(1 row)
```

Note that if you omit the second argument, PostgreSQL will call the `get_rental_duration(integer)` function that has one parameter.

## PL/pgSQL function overloading and default values

In the `get_rental_duration(integer,date)` function, **if you want to set a default value to the second argument** like this:

```SQL
create or replace function get_rental_duration(
	p_customer_id integer,
	p_from_date date default '2005-01-01'
)
returns integer
language plpgsql
as $$
declare
	rental_duration integer;
begin
	select sum(
		extract( day from return_date + '12:00:00' - rental_date)
	)
	into rental_duration
	from rental
	where customer_id= p_customer_id and
		  rental_date >= p_from_date;

	return rental_duration;

end; $$
```

The following calls the `get_rental_duration()` function and passes the customer id `232`:

```SQL
SELECT get_rental_duration(232);
```

PostgreSQL issued an error:

```SQL
ERROR:  function get_rental_duration(integer) is not unique
LINE 1: SELECT get_rental_duration(232);
               ^
HINT:  Could not choose the best candidate function. You might need to add explicit type casts.
SQL state: 42725
Character: 8
```

In this case, PostgreSQL could not choose the best candidate function to execute.

In this scenario, you have three functions:

```SQL
get_rental_duration(p_customer_id integer);
get_rental_duration(p_customer_id integer, p_from_date date)
get_rental_duration(p_customer_id integer, p_from_date date default '2005-01-01'
)
```

PostgreSQL did not know whether it should execute the first or the third function.

As a rule of thumb, when you overload a function, you should always make their parameter list unique.

## Summary

- Multiple functions can share the same names as long as they have different arguments. These function names are overloaded.
- Use a unique function argument list to define overloading functions.
