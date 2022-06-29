# COUNT

The `COUNT()` function is an aggregate function that allows you **to get the number of rows that match a specific condition of a query**.

The following illustrates the syntax of the SQL **COUNT** function:

**SQL**

```SQL
COUNT([ALL | DISTINCT] expression);
```

The result of the **COUNT** function depends on the argument that you pass to it.

The `ALL` keyword will **include the duplicate values** in the result. For example, if you have a group `(1, 2, 3, 3, 4, 4)` and apply the `COUNT` function, the result is `6`.

By **default**, the `COUNT` function uses the `ALL` keyword whether you specify it or not.

The `DISTINCT` keyword **counts only unique values**. For example, the `COUNT` function returns `4` if you apply it to the group (`1`, `2`, `3`, `3`, `4`, `4`).
The expression is a column of a table where you want to count the value.

Another form of the **COUNT** function that accepts an asterisk `(*)` as the argument is as follows:

```SQL
COUNT(*)
```

The `COUNT(*)` function returns the number of rows in a table in a query. It counts **duplicate rows and rows that contain null values**.

## COUNT(*)

The `COUNT(*)` function returns the number of rows returned by a  `SELECT` statement, **including** `NULL` and `duplicates`.

```SQL
SELECT
   COUNT(*)
FROM
   table_name
WHERE
   condition;
```

When you apply the COUNT(*) function to the entire table, PostgreSQL has to scan the whole table sequentially.

If you use the COUNT(* ) function on a big table, the query will be slow. This is related to the PostgreSQL MVCC implementation. Because multiple transactions see different states of data at the same time, there is no direct way for COUNT(*) function to count across the whole table, therefore PostgreSQL must scan all rows.

## COUNT(column)

Similar to the COUNT(* ) function, the **COUNT(column)** function returns the number of rows returned by a SELECT clause. However, **it does not consider NULL values in the column**.

```SQL
SELECT
   COUNT(column)
FROM
   table_name
WHERE
   condition;
```

## COUNT(DISTINCT column)

In this form, the **COUNT(DISTINCT column)** returns the number of **unique non-null values in the column**.

```SQL
SELECT
   COUNT(DISTINCT column)
FROM
   table_name
WHERE
   condition;
```

We often use the `COUNT()` function with the `GROUP BY` clause to return the number of items for each group. For example, we can use the `COUNT()` with the `GROUP BY` clause to **return the number of films in each film category**.

We''l use the `payment` table in the `dvdrental` sample database.

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

**instance**

```console
dvdrental=# SELECT * FROM payment LIMIT 10;
 payment_id | customer_id | staff_id | rental_id | amount |        payment_date
------------+-------------+----------+-----------+--------+----------------------------
      17503 |         341 |        2 |      1520 |   7.99 | 2007-02-15 22:25:46.996577
      17504 |         341 |        1 |      1778 |   1.99 | 2007-02-16 17:23:14.996577
      17505 |         341 |        1 |      1849 |   7.99 | 2007-02-16 22:41:45.996577
      17506 |         341 |        2 |      2829 |   2.99 | 2007-02-19 19:39:56.996577
      17507 |         341 |        2 |      3130 |   7.99 | 2007-02-20 17:31:48.996577
      17508 |         341 |        1 |      3382 |   5.99 | 2007-02-21 12:33:49.996577
      17509 |         342 |        2 |      2190 |   5.99 | 2007-02-17 23:58:17.996577
      17510 |         342 |        1 |      2914 |   5.99 | 2007-02-20 02:11:44.996577
      17511 |         342 |        1 |      3081 |   2.99 | 2007-02-20 13:57:39.996577
      17512 |         343 |        2 |      1547 |   4.99 | 2007-02-16 00:10:50.996577
```


## PostgreSQL COUNT(*) example

The following statement uses the `COUNT(*)` function to return the number of transactions in the payment table:

**SQL**
```SQL
SELECT COUNT(*)
  FROM payment;
```

| count|
|:-----:|
| 14596|

## PostgreSQL COUNT(DISTINCT column) example

To get the distinct amounts which customers paid, you use the `COUNT(DISTINCT amount)` function as shown in the following example:

**SQL**
```SQL
SELECT COUNT (DISTINCT amount)
  FROM payment;
```

| count|
|:-----:|
|    19|

## PostgreSQL COUNT() with GROUP BY clause

To get the **number of payments by the customer**, you use the  `GROUP BY` clause to group the payments into groups based on `customer id`, and use the `COUNT()` function to count the payments for each group.

The following query illustrates the idea:

To get the number of payments by the customer, you use the  GROUP BY clause to group the payments into groups based on `customer id`, and use the `COUNT()` function to count the payments for each group.

The following query illustrates the idea:

**SQL**

```SQL
SELECT customer_id,
       COUNT (customer_id) AS count_payment
  FROM payment
 GROUP BY customer_id
 ORDER BY count_payment DESC
 LIMIT 10;
```

**Results**

| customer_id | count_payment|
|:-----------:|:------------:|
|         148 |            45|
|         526 |            42|
|         144 |            40|
|         236 |            39|
|          75 |            39|
|         178 |            39|
|         410 |            38|
|         137 |            38|
|         459 |            37|
|         366 |            36|


To get the number of payments for by the customer and amount, you use the  GROUP BY clause to group the payments into groups based on `customer_id` and `amount`, and use the `COUNT()` function to count the payments for each group.

**SQL**

```SQL
SELECT customer_id,
       amount,
       COUNT (amount) count_amount,
       SUM (amount) tot_amount
  FROM payment
 GROUP BY customer_id, amount
 ORDER BY customer_id, amount
 LIMIT 20;
```

**Results**

|customer_id | amount | count_amount | tot_amount|
|:----------:|:------:|:------------:|:----------:|
|          1 |   0.99 |            8 |       7.92|
|          1 |   1.99 |            1 |       1.99|
|          1 |   2.99 |            5 |      14.95|
|          1 |   3.99 |            2 |       7.98|
|          1 |   4.99 |            8 |      39.92|
|          1 |   5.99 |            4 |      23.96|
|          1 |   7.99 |            1 |       7.99|
|          1 |   9.99 |            1 |       9.99|
|          2 |   0.99 |            3 |       2.97|
|          2 |   2.99 |            7 |      20.93|
|          2 |   4.99 |            5 |      24.95|
|          2 |   5.99 |            6 |      35.94|
|          2 |   6.99 |            4 |      27.96|
|          2 |  10.99 |            1 |      10.99|
|          3 |   0.99 |            1 |       0.99|
|          3 |   1.99 |            1 |       1.99|
|          3 |   2.99 |            5 |      14.95|
|          3 |   3.99 |            1 |       3.99|
|          3 |   4.99 |            6 |      29.94|
|          3 |   5.99 |            2 |      11.98|

## PostgreSQL COUNT() with HAVING clause

You can use the `COUNT` function in a  `HAVING` clause to apply a specific condition to groups.

**SQL**
```SQL
SELECT customer_id,
       amount,
       COUNT (amount) count_amount,
       SUM (amount) tot_amount
  FROM payment
 GROUP BY customer_id, amount
 HAVING (COUNT(amount) > 10 AND SUM (amount) > 50)
 ORDER BY customer_id, amount;
```

**Results**

| customer_id | amount | count_amount | tot_amount|
|:-----------:|:------:|:------------:|:---------:|
|          43 |   4.99 |           12 |      59.88|
|          46 |   4.99 |           13 |      64.87|
|          71 |   4.99 |           11 |      54.89|
|          73 |   4.99 |           11 |      54.89|
|          91 |   4.99 |           14 |      69.86|
|         148 |   4.99 |           11 |      54.89|
|         157 |   4.99 |           11 |      54.89|
|         167 |   4.99 |           12 |      59.88|
|         181 |   4.99 |           12 |      59.88|
|         236 |   4.99 |           11 |      54.89|
|         242 |   4.99 |           13 |      64.87|
|         363 |   4.99 |           13 |      64.87|
|         410 |   4.99 |           11 |      54.89|
|         421 |   4.99 |           11 |      54.89|
|         438 |   4.99 |           12 |      59.88|
|         469 |   4.99 |           11 |      54.89|
|         470 |   4.99 |           11 |      54.89|
|         473 |   4.99 |           13 |      64.87|
|         478 |   4.99 |           12 |      59.88|
|         486 |   4.99 |           12 |      59.88|
|         576 |   4.99 |           11 |      54.89|


## FILTERING WITH WHERE AND HAVING CLAUSE

```SQL
SELECT customer_id,
       COUNT (customer_id) AS ccount_payments,
       SUM (amount) tot_amount
  FROM payment
 WHERE amount = 4.99
 GROUP BY customer_id
 HAVING SUM(amount) > 55.00
 ORDER BY customer_id;
```

**Results**

| customer_id | ccount_payments | tot_amount|
|:-----------:|:---------------:|:----------:|
|          43 |              12 |      59.88|
|          46 |              13 |      64.87|
|          91 |              14 |      69.86|
|         167 |              12 |      59.88|
|         181 |              12 |      59.88|
|         242 |              13 |      64.87|
|         363 |              13 |      64.87|
|         438 |              12 |      59.88|
|         473 |              13 |      64.87|
|         478 |              12 |      59.88|
|         486 |              12 |      59.88|
