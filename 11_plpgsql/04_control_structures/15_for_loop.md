# FOR LOOP

The following illustrates the syntax of the `for loop` statement that loops through a range of integers:

```SQL
[ <<label>> ]
for loop_counter in [ reverse ] from.. to [ by step ] loop
    statements
end loop [ label ];
```

In this syntax:

- First, the for loop creates an integer variable `loop_counter` which is accessible inside the loop only. By default, the `for loop` adds the step to the `loop_counter` after each iteration. However, when you use the `reverse` option, the `for loop` subtracts the step from `loop_counter`.
- Second, the `from` and `to` are expressions that specify the **lower** and **upper bound** of the range. The `for loop` evaluates these expressions before entering the loop.
- Third, the `step` that **follows the by keyword specifies the iteration step**. It defaults to `1`. The for loop evaluates this step expression once only.

The following flowchart illustrates the for loop statement:

![for loop](./images/07_for_loop.png)

The following example uses the `for` loop statement to iterate over five numbers from `1` to `5` and display each of them in each iteration:

```SQL
do $$
begin
   for counter in 1..5 loop
	raise notice 'counter: %', counter;
   end loop;
end; $$
```

Output:

```console
NOTICE:  Counter: 1
NOTICE:  Counter: 2
NOTICE:  Counter: 3
NOTICE:  Counter: 4
NOTICE:  Counter: 5
```

The following example iterates over 5 numbers from `5` to `1` and shows each number in each iteration:

```SQL
do $$
begin
   for counter in reverse 5..1 loop
      raise notice 'counter: %', counter;
   end loop;
end; $$
```

Output:

```console
NOTICE:  Counter: 5
NOTICE:  Counter: 4
NOTICE:  Counter: 3
NOTICE:  Counter: 2
NOTICE:  Counter: 1
```

The following example uses the for loop statement to iterate over six numbers from `1` to `6`. **It adds 2 to the counter after each iteration**:

```SQL
do $$
begin
  for counter in 1..6 by 2 loop
    raise notice 'counter: %', counter;
  end loop;
end; $$
```

Output:

```console
NOTICE:  Counter 1
NOTICE:  Counter 3
NOTICE:  Counter 5
```

## Using PL/pgSQL for loop to iterate over a result set

The following statement shows how to use the `for` loop statement to iterate over a result set of a query:

```SQL
[ <<label>> ]
for target in query loop
    statements
end loop [ label ];
```

The following statement uses the `for` loop to display the titles of the top 10 longest films.

```SQL
do
$$
declare
    f record;
begin
    for f in select title, length
	       from film
	       order by length desc, title
	       limit 10
    loop
	raise notice '%(% mins)', f.title, f.length;
    end loop;
end;
$$
```

```console
NOTICE:  Chicago North(185 mins)
NOTICE:  Control Anthem(185 mins)
NOTICE:  Darn Forrester(185 mins)
NOTICE:  Gangs Pride(185 mins)
NOTICE:  Home Pity(185 mins)
NOTICE:  Muscle Bright(185 mins)
NOTICE:  Pond Seattle(185 mins)
NOTICE:  Soldiers Evolution(185 mins)
NOTICE:  Sweet Brotherhood(185 mins)
NOTICE:  Worst Banger(185 mins)
```

## Using PL/pgSQL for loop to iterate over the result set of a dynamic query

The following form of the for loop statement allows you to execute a dynamic query and iterate over its result set:

```SQL
[ <<label>> ]
for row in execute query_expression [ using query_param [, ... ] ]
loop
    statements
end loop [ label ];
```

In this syntax:

- The `query_expression` is an SQL statement.
- The `using` clause is used to pass parameters to the query.

The following block shows how to use the for loop statement to loop through a dynamic query. It has two configuration variables:

- `sort_type`: 1 to sort the films by title, 2 to sort the films by release year.
- `rec_count`: is the number of rows to query from the film table. We’ll use it in the using clause of the for loop.

This anonymous block composes the query based on the `sort_type` variable and uses the for loop to iterate over the row of the result set.

```SQL
do $$
declare
    -- sort by 1: title, 2: release year
    sort_type smallint := 1;
	-- return the number of films
	rec_count int := 10;
	-- use to iterate over the film
	rec record;
	-- dynamic query
    query text;
begin

	query := 'select title, release_year from film ';

	if sort_type = 1 then
		query := query || 'order by title';
	elsif sort_type = 2 then
	  query := query || 'order by release_year';
	else
	   raise 'invalid sort type %s', sort_type;
	end if;

	query := query || ' limit $1';

	for rec in execute query using rec_count
        loop
	     raise notice '% - %', rec.release_year, rec.title;
	end loop;
end;
$$
```

Output:

```console
NOTICE:  2006 - Academy Dinosaur
NOTICE:  2006 - Ace Goldfinger
NOTICE:  2006 - Adaptation Holes
NOTICE:  2006 - Affair Prejudice
NOTICE:  2006 - African Egg
NOTICE:  2006 - Agent Truman
NOTICE:  2006 - Airplane Sierra
NOTICE:  2006 - Airport Pollock
NOTICE:  2006 - Alabama Devil
NOTICE:  2006 - Aladdin Calendar
```

If you change the `sort_type` to `2`, you’ll get the following output:

```console
NOTICE:  2006 - Grosse Wonderful
NOTICE:  2006 - Airport Pollock
NOTICE:  2006 - Bright Encounters
NOTICE:  2006 - Academy Dinosaur
NOTICE:  2006 - Ace Goldfinger
NOTICE:  2006 - Adaptation Holes
NOTICE:  2006 - Affair Prejudice
NOTICE:  2006 - African Egg
NOTICE:  2006 - Agent Truman
NOTICE:  2006 - Chamber Italian
```
