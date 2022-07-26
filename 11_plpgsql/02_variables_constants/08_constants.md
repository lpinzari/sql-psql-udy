# Constants

Unlike a `variable`, the value of a `constant` **cannot be changed once it initialized**.

The following are the reasons to use constants.

- First, constants make code more readable and maintainable e.g., imagine that you have the following formula:

```SQL
selling_price := net_price + net_price * 0.1;
```

What does `0.1` means? It can be interpreted as anything.

But when you use the following formula, everyone knows the meaning of the calculation of the selling price that equals the net price plus value-added tax (`VAT`).

```SQL
selling_price := net_price + net_price * vat;
```

Second, constants reduce maintenance effort.

Suppose that you have a formula that calculates the selling price in all over places in a function. When the `VAT` changes e.g., from `0.1` to `0.5`, you need to change all of these hard-coded values.

By using a constant, you just need to change its value in one place where you define the constant.

So how do you define a constant in PL/pgSQL?

## Defining constants

To define a constant in PL/pgSQL, you use the following syntax:

```SQL
constant_name constant data_type := expression;
```

In this syntax:

- First, specify the name of the `constant`. The `name` should be as descriptive as possible.
- Second, add the `constant` keyword after the name and specify the data type of the constant.
- Third, **initialize a value** for the constant after the assignment operator (`:=`).

## PL/pgSQL constants example

The following example declares a constant named `vat` that stores the value-added tax and calculates the selling price from the net price:

```SQL
do $$
declare
   vat constant numeric := 0.1;
   net_price    numeric := 20.5;
begin
   raise notice 'The selling price is %', net_price * ( 1 + vat );
end $$;
```

```console
NOTICE:  The selling price is 22.55
```

Now, if you try to change the value of the constant as follows:

```SQL
do $$
declare
   vat constant numeric := 0.1;
   net_price    numeric := 20.5;
begin
   raise notice 'The selling price is %', net_price * ( 1 + vat);
   vat := 0.05;
end $$;
```

You will get the following error message:

```console
ERROR: "vat" is declared CONSTANT
SQL state: 22005
Character: 155
```

Similar to the default value of a variable, PostgreSQL **evaluates the value for the constant when the block is entered at run-time**, not compile-time. For example:

```console
do $$
declare
   start_at constant time := now();
begin
   raise notice Start executing block at %', start_at;
end $$;
```

```console
NOTICE:  Start executing block at 17:49:59.791
```

PostgreSQL evaluates the `now()` function every time the block is called. To see its effect, you can execute the block repeatedly:

```console
NOTICE:  Start executing block at 17:50:44.956
```
