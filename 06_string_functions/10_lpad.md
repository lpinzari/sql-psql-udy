# LPAD Function PostgreSQL

The PostgreSQL `LPAD()` function **pads a string on the left to a specified length with a sequence of characters**.

The following illustrates the syntax of the **LPAD()** function:

```SQL
LPAD(string, length[, fill])     
```

## Arguments

The **LPAD()** function accepts 3 arguments:

1. **string**: is a `string` that should be padded on the `left`

2. **length**: is an `positive integer` that specifies the **length of the result string after padding**.

Noted: `that if the string is longer than the length argument, the string will be truncated on the right`.

3. **fill**: is a string used for padding.

The fill argument is optional. If you omit the fill argument, its default value is a space.

## Return value

The PostgreSQL **LPAD()** function returns a `string` **left-padded to length characters**.

## Examples

Let’s see some examples of using the `LPAD()` function.

The following statement uses the `LPAD()` function to pad the **‘*’** on the left of the string ‘`PostgreSQL`’:

```SQL
SELECT LPAD('PostgreSQL',15,'*');
```

The result is:

|lpad|
|:--------------:|
|*****PostgreSQL|

In this example, the length of the PostgreSQL string is `10`, the result string should have the length `15`, therefore, the **LPAD()** function **pads** `5 character` * **on the left of the string**.

See the following `customer` and `payment` tables from the `dvdrental` sample database:

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

**payment**

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

The following statement illustrates how to use the **LPAD()** function to draw a chart based on the sum of payments per customer.

```SQL
SELECT first_name || ' ' || last_name fullname,
       SUM(amount) total,
       LPAD('*', CAST(TRUNC(SUM(amount) / 10) AS INT), '*') chart
  FROM payment
 INNER JOIN customer using (customer_id)
 GROUP BY customer_id
 ORDER BY SUM(amount) DESC;
```

Here's the partial output:

|fullname        | total  |         chart|
|:---------------------:|:--------:|:----------------------|
|Eleanor Hunt          | 211.55 | `*********************`|
|Karl Seal             | 208.58 | `********************`|
|Marion Snyder         | 194.61 | `*******************`|
|Rhonda Kennedy        | 191.62 | `*******************`|
|Clara Shaw            | 189.60 | `******************`|
|Tommy Collazo         | 183.63 | `******************`|
|Ana Bradley           | 167.67 | `****************`|
|Curtis Irby           | 167.62 | `****************`|
|Marcia Dean           | 166.61 | `****************`|
|Mike Way              | 162.67 | `****************`|
|Arnold Havens         | 161.68 | `****************`|
|Wesley Bull           | 158.65 | `***************`|
|Gordon Allard         | 157.69 | `***************`|
|Louis Leone           | 156.66 | `***************`|
|Lena Jensen           | 154.70 | `***************`|
|Tim Cary              | 154.66 | `***************`|
|Warren Sherrod        | 152.69 | `***************`|
|Steve Mackenzie       | 152.68 | `***************`|
|Brittany Riley        | 151.73 | `***************`|
|Guy Brownlee          | 151.69 | `***************`|

In this example,

- First, we added up the payments per each customer using the `SUM()` function and the `GROUP BY` clause,
- Second, we calculated the length of the bar chart based on the sums of payments using various functions: `TRUNC()` to truncate the total payments, `CAST()` to convert the result of `TRUNC()` to an integer. To make the bar chart more readable, we divided the sum of payments by `10`.
- Third, we applied the `LPAD()` function to pad the character (*) based on the result of the second step above.
