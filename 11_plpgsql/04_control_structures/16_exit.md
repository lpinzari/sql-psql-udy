# EXIT Statement

The **exit** statement allows you **to terminate a** `loop` including an `unconditional loop`, a `while loop`, and a `for loop`.

The following shows the syntax of the **exit statement**:

```SQL
exit [label] [when boolean_expression]
```

The `label` is the loop label of the current loop where the exit is in or the loop label of the outer loop. Depending on the `label`, the `exit statement` will **terminate the corresponding loop**.

If `you don’t use the label`, the `exit statement` **will terminate the current loop**.

The `when boolean_expression` clause is used **to specify a condition that terminates a loop**. The exit statement will terminate the loop if the boolean_expression evaluates to true.

The following statements are equivalent:

```SQL
exit when counter > 10;
```

```SQL
if counter > 10 then
   exit;
end if;
```

The `exit` when is definitely **cleaner** and **shorter**.

In addition to terminating a loop, you can use the `exit statement` to **terminate a block specified by the begin...end keywords**. In this case, the control is passed to the statement after the end keyword of the current block:

```SQL
<<block_label>>
BEGIN
    -- some code
    EXIT [block_label] [WHEN condition];
    -- some more code
END block_label;
```

## PL/pgSQL Exit examples

Let’s take some examples of using the PL/pgSQL `exit statement`.

## Using PL/pgSQL Exit statement to terminate an unconditional loop

The following example illustrates how to use the `exit statement` in unconditional loops:

```SQL
do
$$
declare
   i int = 0;
   j int = 0;
begin
  <<outer_loop>>
  loop
     i = i + 1;
     exit when i > 3;
	 -- inner loop
	 j = 0;
     <<inner_loop>>
     loop
		j = j + 1;
		exit when j > 3;
		raise notice '(i,j): (%,%)', i, j;
	 end loop inner_loop;
  end loop outer_loop;
end;
$$
```

Output:

```SQL
NOTICE:  (i,j): (1,1)
NOTICE:  (i,j): (1,2)
NOTICE:  (i,j): (1,3)
NOTICE:  (i,j): (2,1)
NOTICE:  (i,j): (2,2)
NOTICE:  (i,j): (2,3)
NOTICE:  (i,j): (3,1)
NOTICE:  (i,j): (3,2)
NOTICE:  (i,j): (3,3)
```

How it works.

This example contains two loops: `outer` and `inner` loops.

Since both `exit statements` **don’t use any loop labels**, they **will terminate the current loop**.

The first exit statement terminates the **outer loop** when `i` is `greater than 3`. That’s why you see the value of i in the output is `1`, `2`, and `3`.

The second exit statement terminates the **inner loop** when `j` is `greater than 3`. It is the reason you see that j is `1`, `2`, and `3` for each iteration of the outer loop.

The following example places the label of the outer loop in the second exit statement:

```SQL
do
$$
declare
   i int = 0;
   j int = 0;
begin
  <<outer_loop>>
  loop
     i = i + 1;
     exit when i > 3;
	 -- inner loop
	 j = 0;
     <<inner_loop>>
     loop
		j = j + 1;
		exit outer_loop when j > 3;
		raise notice '(i,j): (%,%)', i, j;
	 end loop inner_loop;
  end loop outer_loop;
end;
$$
```

Output:

```SQL
NOTICE:  (i,j): (1,1)
NOTICE:  (i,j): (1,2)
NOTICE:  (i,j): (1,3)
```

In this example, the second exit statement terminates the outer loop when `j` is `greater than 3`.

## Using the PL/pgSQL Exit statement to exit a block

The following example illustrates how to use the `exit statement` to terminate a block:

```SQL
do
$$
begin

  <<simple_block>>  
   begin
  	 exit simple_block;
         -- for demo purposes
	 raise notice '%', 'unreachable!';
   end;
   raise notice '%', 'End of block';
end;
$$
```

Output:

```SQL
NOTICE:  End of block
```

In this example, the exit statement terminates the `simple_block` immediately:

```SQL
exit simple_block;
```

This statement will never be reached:

```SQL
raise notice '%', 'unreachable!';
```

## Summary

- Use exit statement to terminate a loop including an unconditional loop, while loop, and for loop.
- Also use the exit statement to exit a block.
