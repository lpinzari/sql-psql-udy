# LAG() Function

SQL `LAG()` is a window function that **provides access to a row at a specified physical offset which comes before the current row**.

In other words, by using the `LAG()` function, from **the current row**, you can **access data of the previous row**, or **from the second row before the current row**, or **from the third row before current row**, and so on.

The `LAG()` function can be very useful for **calculating the difference between the current row and the previous row**.

The following illustrates the syntax of the `LAG()` function:

```SQL
LAG(return_value [,offset[, default_value ]]) OVER (
    PARTITION BY expr1, expr2,...
	ORDER BY expr1 [ASC | DESC], expr2,...
)
```

Let’s examine each element of the `LAG()` function in more detail.

### return_value

The return value based on the specified offset. It can be a column of the row at a given offset from the current row.

### offset

The **number of rows back from the current row from which to access data**. The offset must be a **non-negative integer**. It `defaults to one` if skipped.

### default_value

If the preceding row is not specified, `default_value` is returned. For example, when the offset is 2, the return value from the first row is default_value. If default_value is not given and no preceding row found, NULL is returned by default.

### PARTITION BY clause

The `PARTITION BY` clause organizes rows into one or more partitions to which the `LAG()` function is applied. The whole result is treated as a single partition if you omit the `PARTITION BY` clause.

### ORDER BY clause

The `ORDER BY` clause specifies the order of rows in each partition to which the `LAG()` function is applied.

## PostgreSQL LAG() function examples

We’ll use the `sales` table from the `LEAD()` function tutorial for the demonstration.

Here is the data from the `sales` function:

```SQL
SELECT * FROM sales;
```

**Results**

|year | group_id | amount|
|:---:|:--------:|:------:|
|2018 |        1 | 1474.00|
|2018 |        2 | 1787.00|
|2018 |        3 | 1760.00|
|2019 |        1 | 1915.00|
|2019 |        2 | 1911.00|
|2019 |        3 | 1118.00|
|2020 |        1 | 1646.00|
|2020 |        2 | 1975.00|
|2020 |        3 | 1516.00|

## Using PostgreSQL LAG() function over a result set example

This example uses the `LAG()` function **to return the sales amount of the current year and the previous year**:

```SQL
WITH cte AS (
     SELECT year,
            SUM(amount) amount
       FROM sales
      GROUP BY year
      ORDER BY year
)

SELECT year,
       amount,
       LAG(amount,1)
       OVER (ORDER BY year
       ) previous_year_sales
  FROM cte;
```

**Results**

|year | amount  | previous_year_sales|
|:---:|:--------:|:------------------:|
|2018 | 5021.00 |                NULL|
|2019 | 4944.00 |             5021.00|
|2020 | 5137.00 |             4944.00|

In this example:

- First, the `CTE` returns net sales summarized by year.
- Then, the outer query uses the `LAG()` function to return the sales of the previous year for each row. The first row has `NULL` in the `previous_year_sales` column because there is no previous year of the first row.


This example uses two common table expressions to return the sales variance between the current and previous years:

```SQL
WITH cte AS (
     SELECT year,
            SUM(amount) amount
       FROM sales
      GROUP BY year
      ORDER BY year
), cte2 AS (
     SELECT year,
            amount,
            LAG(amount,1)
            OVER (ORDER BY year
            ) previous_year_sales
       FROM cte
)

SELECT year,
       amount,
       previous_year_sales,
       (previous_year_sales - amount) variance
  FROM cte2;
```

**Results**

|year | amount  | previous_year_sales | variance|
|:---:|:-------:|:-------------------:|:-------:|
|2018 | 5021.00 |                NULL |     NULL|
|2019 | 4944.00 |             5021.00 |    77.00|
|2020 | 5137.00 |             4944.00 |  -193.00|

## Using PostgreSQL LAG() function over a partition example

This example uses the `LAG()` function to **compare the sales of the current year with the sales of the previous year of each product group**:

```SQL
SELECT year,
       amount,
       group_id,
       LAG(amount,1)
       OVER (PARTITION BY group_id
             ORDER BY year
       ) previous_year_sales
  FROM sales;
```

**Results**

|year | amount  | group_id | previous_year_sales|
|:---:|:-------:|:--------:|:------------------:|
|2018 | 1474.00 |        1 |                NULL|
|2019 | 1915.00 |        1 |             1474.00|
|2020 | 1646.00 |        1 |             1915.00|
|2018 | 1787.00 |        2 |                NULL|
|2019 | 1911.00 |        2 |             1787.00|
|2020 | 1975.00 |        2 |             1911.00|
|2018 | 1760.00 |        3 |                NULL|
|2019 | 1118.00 |        3 |             1760.00|
|2020 | 1516.00 |        3 |             1118.00|

In this example:

- The `PARTITION BY` clause distributes rows into product groups (or partitions) specified by group id.
- The `ORDER BY` clause sorts rows in each product group by years in ascending order.
- The `LAG()` function is applied to each partition to return the sales of the previous year.
