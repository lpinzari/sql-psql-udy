# LEFT FUNCTION

The PostgreSQL `LEFT()` **function returns the first n characters in the string**.

The following illustrates the syntax of the PostgreSQL `LEFT()` function:

## Arguments

The PostgreSQL **LEFT()** function requires two arguments:

```SQL
LEFT(string,n)
```

1. **string**: is a `string` from which a number of the `leftmost characters returned`.

2. **n**: is an `integer` that specifies **the number of left-most characters in the string should be returned**.

If **n is negative**, the `LEFT()` function **returns the leftmost characters in the string** but last |n| (absolute) characters.

## Return value

The PostgreSQL `LEFT()` function returns **the first n characters in a string**.

## Examples

Let’s look at some examples of using the `LEFT()` function.

The following example shows how **to get the first character of a string** `ABC`:

```SQL
SELECT LEFT('ABC',1);
```

**Results**

|left|
|:----:|
|A|

To get the first two characters of the string `ABC`, you use **2** instead of 1 for the `n` argument:

```SQL
SELECT LEFT('ABC',2);
```

**Results**

|left|
|:----:|
|AB|

The following statement demonstrates how to use a `negative integer`:

```SQL
SELECT LEFT('ABC',-2);
```
In this example, `n` is -2, therefore, the **LEFT()** function **return all character except the last 2 characters**, which results in:

**Results**

|left|
|:----:|
|A|

```SQL
SELECT LEFT('ABC',-1);
```

**Results**

|left|
|:----:|
|AB|

See the following `customer` table in the `dvdrental` sample database:

```console
dvdrental=# \d customer
                                             Table "public.customer"
   Column    |            Type             | Collation | Nullable |                    Default
-------------+-----------------------------+-----------+----------+-----------------------------------------------
 customer_id | integer                     |           | not null | nextval('customer_customer_id_seq'::regclass)
 store_id    | smallint                    |           | not null |
 first_name  | character varying(45)       |           | not null |
 last_name   | character varying(45)       |           | not null |
 email       | character varying(50)       |           |          |
 address_id  | smallint                    |           | not null |
 activebool  | boolean                     |           | not null | true
 create_date | date                        |           | not null | ('now'::text)::date
 last_update | timestamp without time zone |           |          | now()
 active      | integer                     |           |          |
```

The following statement uses the `LEFT()` function **to get the initials and the** `COUNT()` **function to return the number of customers for each initial**.

```SQL
SELECT LEFT(first_name, 1) initial,
       COUNT(*)
  FROM customer
 GROUP BY initial
 ORDER BY initial;
```
In this example, first, the `LEFT()` function returns initials of all customers. Then, the `GROUP BY` clause groups customers by their initials. Finally, the `COUNT()` function returns the number of customer for each group.

**Results**

|initial | count|
|:-------:|:------:|
|A       |    44|
|B       |    32|
|C       |    49|
|D       |    40|
|E       |    31|
|F       |    13|
|G       |    22|
|H       |    15|
|I       |     6|
|J       |    65|
|K       |    23|
|L       |    35|
|M       |    51|
|N       |    14|
|O       |     2|
|P       |    17|
|R       |    41|
|S       |    35|
|T       |    32|
|V       |    16|
|W       |    13|
|Y       |     2|
|Z       |     1|
