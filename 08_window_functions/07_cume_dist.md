# CUME_DIST Function

Sometimes, you may want to create a report that shows `the top or bottom x% values from a data set`, for example, **top 1% of products by revenue**. Fortunately, PostgreSQL provides us with the **CUME_DIST()** function to calculate it.

The `CUME_DIST()` function returns the cumulative distribution of a value within a set of values. In other words, it returns the relative position of a value in a set of values.

The `CUME_DIST()` function **returns a value** that represents the `number of rows with values less than or equal to` (<= )`the current row’s value` **divided** `by the total number of rows`:

```SQL
N / total_rows
```

In this formula:

- `N` is **the number of rows with the value less than or equal to the current row value**.
- `total_rows` is **the number of rows in the partition or result set being evaluated**.

The return value of the `CUME_DIST()` function has a **range** of the low value **greater than** `0` and the high value **less than or equal** to `1`.

```console
0 < CUME_DIST() <= 1
```

The repeated column values receive the same `CUME_DIST()` value.

The syntax of the `CUME_DIST()` function is as follows:

```SQL
CUME_DIST() OVER (
	PARTITION BY expr1, expr2 ...
	ORDER BY expr1 [ASC | DESC], expr2...
)
```

In this syntax:

- First, the `PARTITION BY` clause divides the result set into partitions. If you omit the PARTITION BY clause, the function treats the whole result set as a single partition.
- Then, the `ORDER BY` clause sorts the rows within each partition.
- Finally, the `CUME_DIST()` function is applied to each sorted partition independently.

## PostgreSQL CUME_DIST() examples

First, create a new table named `sales_stats` that stores the  sales revenue by employees:

```SQL
CREATE TABLE sales_stats(
    name VARCHAR(100) NOT NULL,
    year SMALLINT NOT NULL CHECK (year > 0),
    amount DECIMAL(10,2) CHECK (amount >= 0),
    PRIMARY KEY (name,year)
);
```

Second, insert some rows into the `sales_stats` table:

```SQL
INSERT INTO
    sales_stats(name, year, amount)
VALUES
    ('John Doe',2018,120000),
    ('Jane Doe',2018,110000),
    ('Jack Daniel',2018,150000),
    ('Yin Yang',2018,30000),
    ('Stephane Heady',2018,200000),
    ('John Doe',2019,150000),
    ('Jane Doe',2019,130000),
    ('Jack Daniel',2019,180000),
    ('Yin Yang',2019,25000),
    ('Stephane Heady',2019,270000);
```

|name      | year |  amount|
|:-------------:|:----:|:--------:|
|John Doe       | 2018 | 120000.00|
|Jane Doe       | 2018 | 110000.00|
|Jack Daniel    | 2018 | 150000.00|
|Yin Yang       | 2018 |  30000.00|
|Stephane Heady | 2018 | 200000.00|
|John Doe       | 2019 | 150000.00|
|Jane Doe       | 2019 | 130000.00|
|Jack Daniel    | 2019 | 180000.00|
|Yin Yang       | 2019 |  25000.00|
|Stephane Heady | 2019 | 270000.00|

## Using PostgreSQL CUME_DIST() function over a result set example

The following example returns the sales **amount percentile for each sales employee in 2018**:

```SQL
SELECT name,
       year,
       amount,
       CUME_DIST()
       OVER (ORDER BY amount
       ) cumul_dist
  FROM sales_stats
 WHERE year = 2018;
```

**Results**

|name      | year |  amount   | cumul_dist|
|:-------------:|:----:|:---------:|:----------:|
|Yin Yang       | 2018 |  30000.00 |        0.2|
|Jane Doe       | 2018 | 110000.00 |        0.4|
|John Doe       | 2018 | 120000.00 |        0.6|
|Jack Daniel    | 2018 | 150000.00 |        0.8|
|Stephane Heady | 2018 | 200000.00 |          1|

In this example, sales were sorted by their amount in ascending order. The total of rows in the result set is 5.

So the first row `cumul_dist` value is `1/5 = 0.2`, the second value is `0.2 + 1/5 = 0.4` and so on.

As clearly shown in the output, we can find that 80% of sales employees have sales less than or equal to 150K in 2018.

## Using PostgreSQL CUME_DIST() function over a partition example

The following example uses the `CUME_DIST()` function to calculate the **sales percentile for each sales employee in 2018 and 2019**.

```SQL
SELECT name,
       year,
       amount,
       CUME_DIST()
       OVER (PARTITION BY year
             ORDER BY amount
       ) cuml_dist_yr
  FROM sales_stats;
```

**Results**

|name      | year |  amount   | cuml_dist_yr|
|:-------------:|:----:|:---------:|:-----------:|
|Yin Yang       | 2018 |  30000.00 |          0.2|
|Jane Doe       | 2018 | 110000.00 |          0.4|
|John Doe       | 2018 | 120000.00 |          0.6|
|Jack Daniel    | 2018 | 150000.00 |          0.8|
|Stephane Heady | 2018 | 200000.00 |            1|
|Yin Yang       | 2019 |  25000.00 |          0.2|
|Jane Doe       | 2019 | 130000.00 |          0.4|
|John Doe       | 2019 | 150000.00 |          0.6|
|Jack Daniel    | 2019 | 180000.00 |          0.8|
|Stephane Heady | 2019 | 270000.00 |            1|

In this example:

- The `PARTITION BY` clause divided the rows into two partitions by the year 2018 and 2019.
- The `ORDER BY` clause sorted sales amount of every employee in each partition from high to low to which the `CUME_DIST()` function is applied.
