# Generating Simple Forecasts

Based on current data, you want to **return additional rows and columns representing future actions**.

## Problem

For example, consider the following result set:

|id | order_date | process_date|
|:-:|:----------:|:-----------:|
| 1 | 2005-09-25 | 2005-09-27|
| 2 | 2005-09-26 | 2005-09-28|
| 3 | 2005-09-27 | 2005-09-29|

You want to return **three rows per row** returned in your result set (`each row` **plus** two `additional rows for each order`).

Along with the extra rows, you would like to return **two additional columns** providing `dates for expected order processing`.

From the previous result set, you can see that an order takes `two days to process`. For the purposes of this example, let’s say the `next step` after processing is **verification**, and the last step is **shipment**.
- **Verification occurs one day after processing**, and
- **shipment occurs one day after verification**.

You want to return a result set expressing the whole procedure. Ultimately you want to transform the previous result set to the following result set:

|id | order_date | process_date |  verified  |  shipped|
|:--:|:---------:|:------------:|:----------:|:--------:|
| 1 | 2005-09-25 | 2005-09-27   |            ||
| 1 | 2005-09-25 | 2005-09-27   | 2005-09-28 ||
| 1 | 2005-09-25 | 2005-09-27   | 2005-09-28 | 2005-09-29|
| 2 | 2005-09-26 | 2005-09-28   |            ||
| 2 | 2005-09-26 | 2005-09-28   | 2005-09-29 ||
| 2 | 2005-09-26 | 2005-09-28   | 2005-09-29 | 2005-09-30|
| 3 | 2005-09-27 | 2005-09-29   |            ||
| 3 | 2005-09-27 | 2005-09-29   | 2005-09-30 ||
| 3 | 2005-09-27 | 2005-09-29   | 2005-09-30 | 2005-10-01|

## Solution

The key is to use a
- `Cartesian product` to **generate two additional rows for each order**
- and then simply use `CASE` expressions to **create the required column values**.

You can create a Cartesian product many different ways; this solution uses the Post‐ greSQL function `GENERATE_SERIES`:

```SQL
WITH t AS (
  SELECT '2005-09-24'::DATE AS curr_date
),
orders AS (
  SELECT gs.id,
         curr_date + gs.id AS order_date,
         curr_date + gs.id + 2 AS process_date
    FROM GENERATE_SERIES(1,3) gs(id),t
),
orders2 AS (
  SELECT gs.n, orders.*
    FROM GENERATE_SERIES(1,3) gs(n), orders
   ORDER BY id,n
)
SELECT id, order_date, process_date,
       CASE WHEN n >= 2
            THEN process_date + 1
            ELSE NULL
       END AS verified,
       CASE WHEN n = 3
            THEN process_date + 2
            ELSE NULL
       END AS shipped   
  FROM orders2 o;
```


## Discussion


```SQL
WITH t AS (
  SELECT '2005-09-24'::DATE AS curr_date
)
SELECT gs.id,
       curr_date + gs.id AS order_date,
       curr_date + gs.id + 2 AS process_date
  FROM GENERATE_SERIES(1,3) gs(id),t;
```

|id | order_date | process_date|
|:-:|:----------:|:-----------:|
| 1 | 2005-09-25 | 2005-09-27|
| 2 | 2005-09-26 | 2005-09-28|
| 3 | 2005-09-27 | 2005-09-29|

This query simply uses the `GENERATE_SERIES` function to make up three rows representing **the orders you must process**.

`GENERATE_SERIES` returns the values 1, 2, and 3, and those numbers are added to `CURR_DATE` to represent **the dates of the orders**.

Since the “Problem” section states that processing time takes two days, the query also adds two days to the `ORDER_DATE` (adds the value returned by `GENERATE_SERIES` to `CURR_DATE` and then adds two more days).


Now that you have your base result set, the next step is to create a Cartesian product because the requirement is to return three rows for each order.

```SQL
WITH t AS (
  SELECT '2005-09-24'::DATE AS curr_date
),
orders AS (
  SELECT gs.id,
         curr_date + gs.id AS order_date,
         curr_date + gs.id + 2 AS process_date
    FROM GENERATE_SERIES(1,3) gs(id),t
)
SELECT gs.n, orders.*
  FROM GENERATE_SERIES(1,3) gs(n), orders
 ORDER BY id,n;
```


Use the `GENERATE_ SERIES` function to create a Cartesian product to return three rows for each order.

|n | id | order_date | process_date|
|:-:|:---:|:--------:|:-----------:|
|1 |  1 | 2005-09-25 | 2005-09-27|
|2 |  1 | 2005-09-25 | 2005-09-27|
|3 |  1 | 2005-09-25 | 2005-09-27|
|1 |  2 | 2005-09-26 | 2005-09-28|
|2 |  2 | 2005-09-26 | 2005-09-28|
|3 |  2 | 2005-09-26 | 2005-09-28|
|1 |  3 | 2005-09-27 | 2005-09-29|
|2 |  3 | 2005-09-27 | 2005-09-29|
|3 |  3 | 2005-09-27 | 2005-09-29|

Now that you have three rows for each order, simply use a `CASE` expression to create the addition column values to represent the status of verification and shipment.


- The first row  (`n=1`)for each order should have a `NULL` value for `VERIFIED` and `SHIPPED`.
- The second row (`n=2`) for each order should have a `NULL` value for `SHIPPED`.
- The third row (`n=3`) for each order should have `non-NULL` values for **each column**.

```SQL
WITH t AS (
  SELECT '2005-09-24'::DATE AS curr_date
),
orders AS (
  SELECT gs.id,
         curr_date + gs.id AS order_date,
         curr_date + gs.id + 2 AS process_date
    FROM GENERATE_SERIES(1,3) gs(id),t
),
orders2 AS (
  SELECT gs.n, orders.*
    FROM GENERATE_SERIES(1,3) gs(n), orders
   ORDER BY id,n
)
SELECT id, order_date, process_date,
       CASE WHEN n >= 2
            THEN process_date + 1
            ELSE NULL
       END AS verified,
       CASE WHEN n = 3
            THEN process_date + 2
            ELSE NULL
       END AS shipped   
  FROM orders2 o;
```


The final result set is shown here:

|id | order_date | process_date |  verified  |  shipped|
|:--:|:---------:|:------------:|:----------:|:--------:|
| 1 | 2005-09-25 | 2005-09-27   |            ||
| 1 | 2005-09-25 | 2005-09-27   | 2005-09-28 ||
| 1 | 2005-09-25 | 2005-09-27   | 2005-09-28 | 2005-09-29|
| 2 | 2005-09-26 | 2005-09-28   |            ||
| 2 | 2005-09-26 | 2005-09-28   | 2005-09-29 ||
| 2 | 2005-09-26 | 2005-09-28   | 2005-09-29 | 2005-09-30|
| 3 | 2005-09-27 | 2005-09-29   |            ||
| 3 | 2005-09-27 | 2005-09-29   | 2005-09-30 ||
| 3 | 2005-09-27 | 2005-09-29   | 2005-09-30 | 2005-10-01|

The final result set expresses the complete order process from the day the order was received to the day it should be shipped.
