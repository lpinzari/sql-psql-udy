# DENSE_RANK Function

The `DENSE_RANK()` **assigns a rank to every row in each partition of a result set**. Different from the `RANK()` function, the `DENSE_RANK()` **function always returns consecutive rank values**.

For each partition, the `DENSE_RANK()` **function returns the same rank for the rows which have the same values**.

The following shows the syntax of the `DENSE_RANK()` function:

```SQL
DENSE_RANK() OVER (
	PARTITION BY expr1[{,expr2...}]
	ORDER BY expr1 [ASC|DESC], [{,expr2...}]
)
```

In this syntax:

- First, the `PARTITION BY` clause divides the result set produced by the FROM clause into partitions.
- Then, The `ORDER BY` specifies the order of rows in each partition.
- Finally, the `DENSE_RANK()` function is applied to the rows in the specified order of each partition. It resets the rank when the partition boundary is crossed.

## PostgreSQL DENSE_RANK() function demo

First, create a table named `dense_ranks` that has one column:

```SQL
CREATE TABLE dense_ranks (
     c VARCHAR(10)
);
```

Second, insert some rows into the `dense_ranks` table:

```SQL
INSERT INTO dense_ranks(c)
VALUES('A'),('A'),('B'),('C'),('C'),('D'),('E');
```

Third, query data from the dense_ranks table:

```SQL
SELECT c from dense_ranks;
```

**Results**

|c|
|:-:|
|A|
|A|
|B|
|C|
|C|
|D|
|E|

Fourth, use the `DENSE_RANK()` function to assign a rank to each row in the result set:

```SQL
SELECT c,
       DENSE_RANK()
       OVER (ORDER BY c
       ) dense_rank_number
  FROM dense_ranks;
```

**Results**

|c | dense_rank_number|
|:-:|:----------------:|
|A |                 1|
|A |                 1|
|B |                 2|
|C |                 3|
|C |                 3|
|D |                 4|
|E |                 5|

## PostgreSQL DENSE_RANK() function examples

We will use the `products` table to demonstrate the `DENSE_RANK()` function.

![window func](./images/01_window.png)

The data of the products table is as follows:

|product_id |    product_name    |  price  | group_id|
|:---------:|:------------------:|:-------:|:-------:|
|         1 | Microsoft Lumia    |  200.00 |        1|
|         2 | HTC One            |  400.00 |        1|
|         3 | Nexus              |  500.00 |        1|
|         4 | iPhone             |  900.00 |        1|
|         5 | HP Elite           | 1200.00 |        2|
|         6 | Lenovo Thinkpad    |  700.00 |        2|
|         7 | Sony VAIO          |  700.00 |        2|
|         8 | Dell Vostro        |  800.00 |        2|
|         9 | iPad               |  700.00 |        3|
|        10 | Kindle Fire        |  150.00 |        3|
|        11 | Samsung Galaxy Tab |  200.00 |        3|

## Using PostgreSQL DENSE_RANK() function over a result set example

This statement uses the `DENSE_RANK()` function to rank products by list prices:

```SQL
SELECT product_id,
       product_name,
       price,
       DENSE_RANK ()
       OVER (ORDER BY price DESC
       ) price_rank
  FROM products;
```

**Results**

|product_id |    product_name    |  price  | price_rank|
|:---------:|:------------------:|:-------:|:---------:|
|         5 | HP Elite           | 1200.00 |          1|
|         4 | iPhone             |  900.00 |          2|
|         8 | Dell Vostro        |  800.00 |          3|
|         6 | Lenovo Thinkpad    |  700.00 |          4|
|         7 | Sony VAIO          |  700.00 |          4|
|         9 | iPad               |  700.00 |          4|
|         3 | Nexus              |  500.00 |          5|
|         2 | HTC One            |  400.00 |          6|
|        11 | Samsung Galaxy Tab |  200.00 |          7|
|         1 | Microsoft Lumia    |  200.00 |          7|
|        10 | Kindle Fire        |  150.00 |          8|

In this example, we skipped the `PARTITION BY` clause, therefore, the `DENSE_RANK()` function treated the whole result set as a single partition.

The `DENSE_RANK()` function assigned a rank to each product based on the price order from high to low specified by the `ORDER BY` clause.

## Using PostgreSQL DENSE_RANK() function over partitions example

The following example assigns a rank to every product in each product group:

```SQL
SELECT product_id,
       product_name,
       group_id,
       price,
       DENSE_RANK ()
       OVER (PARTITION BY group_id
             ORDER BY price DESC
       ) price_rank
 FROM products;
```

**Results**

|product_id |    product_name    | group_id |  price  | price_rank|
|:---------:|:------------------:|:--------:|:-------:|:---------:|
|         4 | iPhone             |        1 |  900.00 |          1|
|         3 | Nexus              |        1 |  500.00 |          2|
|         2 | HTC One            |        1 |  400.00 |          3|
|         1 | Microsoft Lumia    |        1 |  200.00 |          4|
|         5 | HP Elite           |        2 | 1200.00 |          1|
|         8 | Dell Vostro        |        2 |  800.00 |          2|
|         6 | Lenovo Thinkpad    |        2 |  700.00 |          3|
|         7 | Sony VAIO          |        2 |  700.00 |          3|
|         9 | iPad               |        3 |  700.00 |          1|
|        11 | Samsung Galaxy Tab |        3 |  200.00 |          2|
|        10 | Kindle Fire        |        3 |  150.00 |          3|

In this example, the `PARTITION BY` clause distributed the products into product groups. The `ORDER BY` clause sorted products in each group by their prices from high to low to which the `DENSE_RANK()` function is applied.

## Using PostgreSQL DENSE_RANK() function with a CTE example

The following statement uses the `DENSE_RANK()` function with a **CTE** to **return the most expensive product in each product group**:

```SQL
WITH cte AS(
     SELECT product_id,
            product_name,
            group_id,
            price,
            DENSE_RANK ()
            OVER (PARTITION BY group_id
                  ORDER BY price DESC
            ) price_rank
       FROM products
)

SELECT product_id,
       product_name,
       price
  FROM cte
 WHERE price_rank = 1;
```

**Results**

|product_id | product_name |  price|
|:---------:|:------------:|:------:|
|         4 | iPhone       |  900.00|
|         5 | HP Elite     | 1200.00|
|         9 | iPad         |  700.00|
