# Continue

The **continue** statement prematurely **skips the current iteration of the loop and jumps to the next one**. The continue statement can be used in all kinds of loops including `unconditional loops`, `while loops`, and `for loops`.

The following illustrates the syntax of the continue statement:

```SQL
continue [loop_label] [when condition]
```

In this syntax, the `loop_label` and when condition are optional.

The `loop_label` is the label of the loop that you want to skip the current iteration.

If you omit the `loop_label`, the **continue** statement `skips the current iteration of the loop`.

If you specify a `loop label`, the continue statement `skips the current iteration of that loop`.

The `condition` is a **boolean expression that specifies the condition to skip the current iteration of the loop**. If the condition is true, then the continue will skip the current loop iteration.

## PL/pgSQL Continue statement example

The following example uses the continue statement in an `unconditional loop` to print out the `odd numbers` from `1` to `10`:

```SQL
do
$$
declare
   counter int = 0;
begin

  loop
     counter = counter + 1;
	 -- exit the loop if counter > 10
	 exit when counter > 10;
	 -- skip the current iteration if counter is an even number
	 continue when mod(counter,2) = 0;
	 -- print out the counter
	 raise notice '%', counter;
  end loop;
end;
$$
```

Output:

```SQL
NOTICE:  1
NOTICE:  3
NOTICE:  5
NOTICE:  7
NOTICE:  9
```

How it works.

- First, initialize the counter to zero.
- Second, increase the counter by one in each iteration. If the counter is greater than 10, then exit the loop. If the counter is an even number, then skip the current iteration.
- `The mod(counter,2)` returns the remainder of the division of the counter by two. If it is zero, then the counter is an even number. **All the statements between the continue statement and end loop will be skipped**.

## Summary

Use the continue statement to skip the current loop iteration prematurely and start a new one.
