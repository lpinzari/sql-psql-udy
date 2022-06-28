# Totalling Columns

Another useful piece of information to extract from a table is the total of all values in a particular column. To achieve this result, SQL provides the `SUM` aggregate. As the name suggests, `SUM` returns the sum of a particular column.

The PostgreSQL `SUM()` is an aggregate function that **returns the sum of values** or `distinct` **values**.

The syntax of the `SUM()` function is as follows:

```SQL
SUM(DISTINCT expression)
```

- The `DISTINCT` clause forces the `SUM()` function to calculate the sum of unique values.
- The `ALL` clause causes the SUM() function to calculate the sum of all values, including duplicates.

If you omit the clause, the `SUM()` function will use the `ALL` clause by default.

Note that the SUM() function ignores NULL values.


The `SUM()` **function ignores** `NULL`. It means that `SUM()` **doesn’t consider the** `NULL` in calculation.

If you use the `DISTINCT` option, the `SUM()` **function calculates the sum of** `distinct` **values**.

For example, without the `DISTINCT` option, the `SUM()` of `1`, `1`, `8`, and `2` will return **12**. When the `DISTINCT` option is available, the `SUM()` of `1`, `1`, `8`, and `2` will return **11**  `(1 + 8 + 2)`. It **ingores the one duplicate value** (1).

If you use the `SUM` function in a `SELECT` statement, it returns `NULL` not zero in case the `SELECT` **statement returns no rows**.

## PostgreSQL SUM() function examples

We’ll use the `payment` table in the `dvdrental` sample database to demonstrate the functionality of the `SUM` function.

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

And we'll use the `orders` table in the `parch_posey` sample database.

```console
parch_posey=# \d orders
                              Table "public.orders"
      Column      |            Type             | Collation | Nullable | Default
------------------+-----------------------------+-----------+----------+---------
 id               | integer                     |           | not null |
 account_id       | integer                     |           |          |
 occurred_at      | timestamp without time zone |           |          |
 standard_qty     | integer                     |           |          |
 gloss_qty        | integer                     |           |          |
 poster_qty       | integer                     |           |          |
 total            | integer                     |           |          |
 standard_amt_usd | numeric(10,2)               |           |          |
 gloss_amt_usd    | numeric(10,2)               |           |          |
 poster_amt_usd   | numeric(10,2)               |           |          |
 total_amt_usd    | numeric(10,2)               |           |          |
```


## Using PostgreSQL SUM() function in SELECT statement example

The following statement uses the `SUM()` function to calculate the total payment of the customer id `2000`.

**SQL**
```SQL
SELECT SUM (amount) AS total
  FROM payment
 WHERE customer_id = 2000;
```

**Results**

| total|
|:-----:|
|  NULL|


Since no row in the payment table has the `customer_id` 2000, the `SUM()` **function returns a** `NULL`.

If you want the `SUM()` function to return zero instead of `NULL` **in case there is no matching row found**, you use the `COALESCE` function.

The `COALESCE()` **function returns the first non-null argument**. In other words, **it returns the second argument if the first argument is** `NULL`.

The following query illustrates how to use the `SUM()` function with the `COALESCE()` function:

**SQL**

```SQL
SELECT COALESCE(SUM(amount),0) As total
  FROM payment
 WHERE customer_id = 2000;
```

**Results**

| total|
|:-----:|
|     0|


The following statement returns the sum of quantity of products placed by customers in the parch_posey sample database:

**SQL**

```SQL
SELECT SUM(total) AS total_qty
  FROM orders;
```

**Results**

| total_qty|
|:---------:|
|   3675765|


The following statement returns the quantity proportion of paper types sold

**SQL**

```SQL
SELECT ROUND(SUM(standard_qty)*100.0/NULLIF(SUM(total),0), 2) AS standard_qty,
       ROUND(SUM(gloss_qty)*100.0/NULLIF(SUM(total),0), 2) AS gloss_qty,
       ROUND(SUM(poster_qty)*100.0/NULLIF(SUM(total),0), 2) AS poster_qty
  FROM orders;
```

**Results**

| standard_qty | gloss_qty | poster_qty|
|:------------:|:---------:|:---------:|
|        52.73 |     27.58 |      19.69|


## Using PostgreSQL SUM() function with GROUP BY clause

To calculate the summary of every group, you use the `GROUP BY` clause to group the rows in the table into groups and apply the `SUM()` function to each group.

The following example uses the `SUM()` function with the `GROUP BY` clause to calculate the total amount paid by each customer:

**SQL**

```SQL
SELECT customer_id,
       SUM (amount) AS total
  FROM payment
 GROUP BY customer_id
 ORDER BY total;
```

**Results**

| customer_id | total|
|:-----------:|:-------:|
|         318 |  27.93|
|         281 |  32.90|
|         248 |  37.87|
|         320 |  47.85|
|         110 |  49.88|
|         586 |  50.83|
|         288 |  52.81|
|         250 |  54.85|
|         271 |  56.84|
|         395 |  57.81|

The following query returns top five customers who paid the most:

**SQL**

```SQL
SELECT customer_id,
       SUM (amount) AS total
  FROM payment
 GROUP BY customer_id
 ORDER BY total DESC
 LIMIT 5;
```
**Results**

| customer_id | total|
|:-----------:|:-------:|
|         148 | 211.55|
|         526 | 208.58|
|         178 | 194.61|
|         137 | 191.62|
|         144 | 189.60|


To get the sum of quantity of products on sales order by account_id, you use the following statement:

**SQL**

```SQL
SELECT account_id,
       SUM(total) AS total_qty
  FROM orders
 GROUP BY account_id
 ORDER BY total_qty DESC
 LIMIT 10;
```

**Results**

| account_id | total_qty|
|:----------:|:--------:|
|       4211 |     56410|
|       4151 |     49246|
|       1301 |     47506|
|       4161 |     44750|
|       1871 |     43730|
|       3411 |     42358|
|       2181 |     40904|
|       4111 |     40833|
|       1561 |     40535|
|       2591 |     40412|

In this example,

- First, the `GROUP BY` clause groups the rows in the orders into groups by account_id.
- Second, the `SUM()` function returns the sum of quantity for each group.

To get the quantity percentage of paper types on sales order by account_id and sorted by total expenditure in descending order, you use the following statement:

**SQL**
```SQL
SELECT account_id,
       ROUND(SUM(standard_qty)*100.0/NULLIF(SUM(total),0), 2) AS standard_qty,
       ROUND(SUM(gloss_qty)*100.0/NULLIF(SUM(total),0), 2) AS gloss_qty,
       ROUND(SUM(poster_qty)*100.0/NULLIF(SUM(total),0), 2) AS poster_qty,
       SUM(total_amt_usd) AS total_amt_usd
  FROM orders
 GROUP BY account_id
 ORDER BY total_amt_usd DESC
 LIMIT 10;
```

In this example,

- First, the formula `ROUND(SUM(standard_qty)*100.0/NULLIF(SUM(total),0), 2)` returns the value percentage of each paper order item. **NULLIF** prevents division by zero.
- Second the formula `SUM(total_amt_usd)` returns the total expenditure of each customer.
- Third, the `GROUP BY` clause divides the orders into groups by account_id.


**Results**

| account_id | standard_qty | gloss_qty | poster_qty | total_amt_usd|
|:----------:|:------------:|:---------:|:----------:|:------------:|
|       4211 |        31.00 |     57.51 |      11.49 |     382873.30|
|       4151 |        28.64 |     32.61 |      38.75 |     345618.59|
|       1301 |        33.25 |     31.68 |      35.07 |     326819.48|
|       1871 |        31.06 |     43.11 |      25.82 |     300694.79|
|       4111 |        24.09 |     26.89 |      49.03 |     293861.14|
|       3411 |        31.62 |     41.13 |      27.25 |     291047.25|
|       2181 |        31.25 |     43.13 |      25.62 |     281018.36|
|       1561 |        32.05 |     38.78 |      29.17 |     278575.64|
|       2591 |        33.34 |     41.95 |      24.71 |     275288.30|
|       1401 |        32.73 |     40.50 |      26.76 |     272672.84|


The following statement returns the table sorted by total_amt_usd in ascending order.


**SQL**

```SQL
SELECT account_id,
      ROUND(SUM(standard_qty)*100.0/NULLIF(SUM(total),0), 2) AS standard_qty,
      ROUND(SUM(gloss_qty)*100.0/NULLIF(SUM(total),0), 2) AS gloss_qty,
      ROUND(SUM(poster_qty)*100.0/NULLIF(SUM(total),0), 2) AS poster_qty,
      SUM(total_amt_usd) AS total_amt_usd
 FROM orders
GROUP BY account_id
ORDER BY total_amt_usd
LIMIT 10;
```

**Results**

| account_id | standard_qty | gloss_qty | poster_qty | total_amt_usd|
|:----------:|:------------:|:---------:|:----------:|:------------:|
|       1901 |         0.00 |     50.00 |      50.00 |        390.25|
|       1671 |        90.85 |      5.49 |       3.66 |        859.64|
|       4321 |        78.85 |      0.00 |      21.15 |        881.73|
|       1961 |        60.00 |     22.94 |      17.06 |       1036.57|
|       3371 |        47.02 |     44.64 |       8.33 |       1069.64|
|       3401 |        62.70 |     22.16 |      15.14 |       1113.29|
|       3741 |        58.79 |     11.06 |      30.15 |       1235.81|
|       4401 |        83.52 |      9.34 |       7.14 |       1982.74|
|       4071 |        87.47 |      7.27 |       5.26 |       2129.24|
|       2781 |        90.24 |      5.85 |       3.90 |       2155.98|


## Using PostgreSQL SUM function with HAVING clause

To filter the sums of groups based on a specific condition, you use the SUM function in the `HAVING` clause.

The following example returns the customers who paid more than `$200`:

**SQL**

```SQL
SELECT customer_id,
       SUM (amount) As total
  FROM payment
 GROUP BY customer_id
 HAVING SUM(amount) > 200
 ORDER BY total DESC;
```

**Results**

| customer_id | total|
|:-----------:|:-------:|
|         148 | 211.55|
|         526 | 208.58|

To get the quantity percentage of paper types on sales order by account_id and sorted by total expenditure in descending order having the top 10 and last 10 customers, you use the following statement:


**SQL**

```SQL
SELECT account_id,
       ROUND(SUM(standard_qty)*100.0/NULLIF(SUM(total),0), 2) AS standard_qty,
       ROUND(SUM(gloss_qty)*100.0/NULLIF(SUM(total),0), 2) AS gloss_qty,
       ROUND(SUM(poster_qty)*100.0/NULLIF(SUM(total),0), 2) AS poster_qty,
       SUM(total_amt_usd) AS total_usd
  FROM orders
 GROUP BY account_id
HAVING SUM(total_amt_usd) NOT BETWEEN 2156.00 AND 272672.00
 ORDER BY total_usd DESC;
```

**Results**

| account_id | standard_qty | gloss_qty | poster_qty | total_usd|
|:----------:|:------------:|:---------:|:----------:|:--------:|
|       4211 |        31.00 |     57.51 |      11.49 | 382873.30|
|       4151 |        28.64 |     32.61 |      38.75 | 345618.59|
|       1301 |        33.25 |     31.68 |      35.07 | 326819.48|
|       1871 |        31.06 |     43.11 |      25.82 | 300694.79|
|       4111 |        24.09 |     26.89 |      49.03 | 293861.14|
|       3411 |        31.62 |     41.13 |      27.25 | 291047.25|
|       2181 |        31.25 |     43.13 |      25.62 | 281018.36|
|       1561 |        32.05 |     38.78 |      29.17 | 278575.64|
|       2591 |        33.34 |     41.95 |      24.71 | 275288.30|
|       1401 |        32.73 |     40.50 |      26.76 | 272672.84|
|       2781 |        90.24 |      5.85 |       3.90 |   2155.98|
|       4071 |        87.47 |      7.27 |       5.26 |   2129.24|
|       4401 |        83.52 |      9.34 |       7.14 |   1982.74|
|       3741 |        58.79 |     11.06 |      30.15 |   1235.81|
|       3401 |        62.70 |     22.16 |      15.14 |   1113.29|
|       3371 |        47.02 |     44.64 |       8.33 |   1069.64|
|       1961 |        60.00 |     22.94 |      17.06 |   1036.57|
|       4321 |        78.85 |      0.00 |      21.15 |    881.73|
|       1671 |        90.85 |      5.49 |       3.66 |    859.64|
|       1901 |         0.00 |     50.00 |      50.00 |    390.25|


## Using PostgreSQL SUM with expression

See the following `rental` table from the sample database:

```console
dvdrental=# \d rental
                                             Table "public.rental"
    Column    |            Type             | Collation | Nullable |                  Default
--------------+-----------------------------+-----------+----------+-------------------------------------------
 rental_id    | integer                     |           | not null | nextval('rental_rental_id_seq'::regclass)
 rental_date  | timestamp without time zone |           | not null |
 inventory_id | integer                     |           | not null |
 customer_id  | smallint                    |           | not null |
 return_date  | timestamp without time zone |           |          |
 staff_id     | smallint                    |           | not null |
 last_update  | timestamp without time zone |           | not null | now()
```

The following statement uses the SUM() function to calculate total rental days:

**SQL**

```SQL
SELECT SUM(return_date - rental_date)
  FROM rental;
```

**Results**

|           sum|
|:-----------------------:|
| 71786 days 190098:21:00|

How it works.

- First, calculate the rental duration by subtracting the rental date from the return date.
- Second, apply the `SUM()` function to the expression.

The following example uses the `SUM()` function to calculate the total duration by customers:

**SQL**
```SQL
SELECT first_name || ' ' || last_name AS full_name,
       SUM(return_date - rental_date) AS rental_duration
  FROM rental
 INNER JOIN customer USING(customer_id)
 GROUP BY customer_id
 ORDER BY rental_duration
 LIMIT 10;
```

**Results**

|full_name     |  rental_duration|
|:------------:|:-------------------:|
|Tiffany Jordan   | 52 days 172:45:00|
|Brian Wyman      | 53 days 149:34:00|
|Annie Russell    | 58 days 154:13:00|
|Johnny Turpin    | 56 days 317:13:00|
|Caroline Bowman  | 65 days 171:25:00|
|Anita Morales    | 68 days 192:29:00|
|Edith Mcdonald   | 69 days 172:04:00|
|Lauren Hudson    | 67 days 228:10:00|
|Eugene Culpepper | 66 days 252:24:00|
|Leona Obrien     | 70 days 174:57:00|
