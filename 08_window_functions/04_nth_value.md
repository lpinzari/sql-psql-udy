## NTH_VALUE() function

The `NTH_VALUE()` function **returns a value from the nth row in an ordered partition of a result set**.

Here is the syntax of the `NTH_VALUE()` function:

```SQL
NTH_VALUE(expression, offset)
OVER (
    [PARTITION BY partition_expression]
    [ ORDER BY sort_expression [ASC | DESC]
    frame_clause ]
)
```
Let’s examine the syntax of the `NTH_VALUE()` function in detail.

### expression

The expression is the target column or expression on which the NTH_VALUE() function operates.

### offset

The offset is a **positive integer (greater than zero) that determines the row number relative to the first row in the window against which the expression evaluates**.

### PARTITION BY partition_expression

The `PARTITION BY` clause distributes rows of the result set into partitions to which the `NTH_VALUE()` function applies.

### ORDER BY sort_expression

The `ORDER BY` clause sorts rows in each partition to which the function is applied.

### frame clause

The `frame_clause` defines the subset (or the frame) of the current partition.

### PostgreSQL NTH_VALUE() function examples

We will use the `products` table created in the window functions tutorial for the demonstration.

**Products** table:

|product_id |    product_name    |  price  | group_id|
|:---------:|:------------------:|:--------:|:---------:|
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

## Using PostgreSQL NTH_VALUE() function over the result set example

This example uses the `NTH_VALUE()` function to **return all products together with the  second most expensive product**:

```SQL
SELECT product_id,
       product_name,
       price,
       NTH_VALUE(product_name, 2)
       OVER(ORDER BY price DESC
            RANGE BETWEEN
            UNBOUNDED PRECEDING AND
            UNBOUNDED FOLLOWING
       )
 FROM products;
```

**Results**

|product_id |    product_name    |  price  | nth_value|
|:---------:|:------------------:|:-------:|:--------:|
|         5 | HP Elite           | 1200.00 | iPhone|
|         **4** | **iPhone**             |  **900.00** | **iPhone**|
|         8 | Dell Vostro        |  800.00 | iPhone|
|         6 | Lenovo Thinkpad    |  700.00 | iPhone|
|         7 | Sony VAIO          |  700.00 | iPhone|
|         9 | iPad               |  700.00 | iPhone|
|         3 | Nexus              |  500.00 | iPhone|
|         2 | HTC One            |  400.00 | iPhone|
|        11 | Samsung Galaxy Tab |  200.00 | iPhone|
|         1 | Microsoft Lumia    |  200.00 | iPhone|
|        10 | Kindle Fire        |  150.00 | iPhone|

In this example:

- The `ORDER BY` clause sorted all products by prices from high to low
- The `frame clause` defined the frame start at the beginning row and end at the ending row of the result set.
- The `NTH_VALUE()` function return value in the `product_name` column of **the second row of the result set after sorting and framing**.

## Using PostgreSQL NTH_VALUE() function over a partition example

This example uses the `NTH_VALUE()` function to **return all products with the second most expensive product for each product group**:

```SQL
SELECT product_id,
       product_name,
       price,
       group_id,
       NTH_VALUE(product_name, 2)
       OVER(PARTITION BY group_id
            ORDER BY price DESC
            RANGE BETWEEN
            UNBOUNDED PRECEDING AND
            UNBOUNDED FOLLOWING
       ) second_value
  FROM products;
```

**Results**

|product_id |    product_name    |  price  | group_id |    second_value|
|:---------:|:------------------:|:-------:|:--------:|:-------------------:|
|         4 | iPhone             |  900.00 |        1 | Nexus|
|         3 | **Nexus**              |  **500.00** |        **1** | **Nexus**|
|         2 | HTC One            |  400.00 |        1 | Nexus|
|         1 | Microsoft Lumia    |  200.00 |        1 | Nexus|
|         5 | HP Elite           | 1200.00 |        2 | Dell Vostro|
|         8 | **Dell Vostro**        |  **800.00** |        **2** | **Dell Vostro**|
|         6 | Lenovo Thinkpad    |  700.00 |        2 | Dell Vostro|
|         7 | Sony VAIO          |  700.00 |        2 | Dell Vostro|
|         9 | iPad               |  700.00 |        3 | Samsung Galaxy Tab|
|        11 | **Samsung Galaxy Tab** |  **200.00** |        **3** | **Samsung Galaxy Tab**|
|        10 | Kindle Fire        |  150.00 |        3 | Samsung Galaxy Tab|

In this example,

- The `PARTITION BY` clause to distributed products into product groups (or partitions) specified by the values in the group_id column.
- The `ORDER BY` clause sorted the products in each product group from high to low.
- The `frame clause` defined the whole partition as a frame.
- And the `NTH_VALUE()` **function returns the product name of the 2nd row of each product group**.
