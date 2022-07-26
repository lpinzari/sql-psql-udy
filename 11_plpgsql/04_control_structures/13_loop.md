# LOOP Statements

The `loop` defines an **unconditional loop that executes a block of code repeatedly until terminated by an** `exit` or `return` statement.

The following illustrates the syntax of the `loop` statement:

```SQL
<<label>>
loop
   statements;
end loop;
```

Typically, you use an `if` statement inside the loop to terminate it based on a condition like this:

```SQL
<<label>>
loop
   statements;
   if condition then
      exit;
   end if;
end loop;
```

It’s possible to place a loop statement inside another `loop` statement. When a `loop` statement is placed inside another `loop` statement, it is called a `nested loop`:

```SQL
<<outer>>
loop
   statements;
   <<inner>>
   loop
     /* ... */
     exit <<inner>>
   end loop;
end loop;
```

When you have nested loops, you need to use the loop label so that you can specify it in the `exit` and `continue` statement to indicate which loop these statements refer to.

## PL/pgSQL loop statement example

The following example shows how to use the `loop` statement to calculate the Fibonacci sequence number.

```SQL
do $$
declare
   n integer:= 10;
   fib integer := 0;
   counter integer := 0 ;
   i integer := 0 ;
   j integer := 1 ;
begin
	if (n < 1) then
		fib := 0 ;
	end if;
	loop
		exit when counter = n ;
		counter := counter + 1 ;
		select j, i + j into i,	j ;
	end loop;
	fib := i;
    raise notice '%', fib;
end; $$
```

Output:

```console
NOTICE:  55
```

The block calculates the nth Fibonacci number of an integer (`n`).

By definition, Fibonacci numbers are a sequence of integers starting with `0` and `1`, and each subsequent number is the sum of the two previous numbers, for example, `1`, `1`, `2` (1+1), `3` (2+1), `5` (3 +2), `8` (5+3), …

In the declaration section, the counter variable is initialized to zero (`0`). The loop is terminated when counter equals `n`. The following select statement swaps values of two variables `i` and `j` :

```SQL
SELECT j, i + j INTO i,	j ;
```
