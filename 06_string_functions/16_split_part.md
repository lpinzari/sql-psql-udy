# SPLIT_PART Function PostgreSQL

The PostgreSQL **SPLIT_PART()** function splits a string on a specified delimiter and returns the n<sup>th</sup> substring.

The following illustrates the syntax of the PostgreSQL `SPLIT_PART()` function:

```SQL
SPLIT_PART(string, delimiter, position)
```

## Arguments

The `SPLIT_PART()` function requires three arguments:

1. **string**: is the string to be split.

2. **delimiter**: The delimiter is a string used as the **delimiter for splitting**.

3. **position**: is **the position of the part to return**, `starting from 1`. The position must be a `positive integer`.

If the position is greater than the number of parts after splitting, the `SPLIT_PART()` function returns an empty string.

## Return Value

The `SPLIT_PART()` function **returns a part as a string at a specified position**.

## Examples

See the following statement:

```SQL
SELECT SPLIT_PART('A,B,C', ',', 2) second;
```

The string `'A,B,C'` is split on the comma delimiter (`,`) that results in `3 substrings`: ‘A’, ‘B’, and ‘C’.

Because the position is `2`, the function returns the `2nd substring` which is ‘**B**’.

Here is the output:

|second|
|:----:|
|B|

See the following `payment` table in the `dvdrental` sample database.

```console
dvdrental=# \d payment
                                             Table "public.payment"
    Column    |            Type             | Collation | Nullable |                   Default
--------------+-----------------------------+-----------+----------+---------------------------------------------
 payment_id   | integer                     |           | not null | nextval('payment_payment_id_seq'::regclass)
 customer_id  | smallint                    |           | not null |
 staff_id     | smallint                    |           | not null |
 rental_id    | integer                     |           | not null |
 amount       | numeric(5,2)                |           | not null |
 payment_date | timestamp without time zone |           | not null |
```

The following statement uses the `SPLIT_PART()` function to return the year and month of the payment date:

```SQL
SELECT split_part(payment_date::TEXT,'-', 1) y,
       split_part(payment_date::TEXT,'-', 2) m,
       amount
  FROM payment
 LIMIT 3;
```

**Output**

|y   | m  | amount|
|:---:|:----:|:-------:|
|2007 | 02 |   7.99|
|2007 | 02 |   1.99|
|2007 | 02 |   7.99|
