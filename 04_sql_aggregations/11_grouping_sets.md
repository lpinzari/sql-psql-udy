# GROUPING SETS

In this section, you will learn about grouping set concept and how to use the PostgreSQL `GROUPING SETS` clause **to generate multiple grouping sets in a query**.

## Setup a sample table

Let’s get started by creating a new table called `sales` for the demonstration.

```console
hr=# CREATE TABLE sales (
hr(#    brand VARCHAR NOT NULL,
hr(#    segment VARCHAR NOT NULL,
hr(#    quantity INT NOT NULL,
hr(#    PRIMARY KEY (brand, segment)
hr(# );
CREATE TABLE
hr=# INSERT INTO sales (brand, segment, quantity)
hr-# VALUES
hr-#    ('ABC', 'Premium', 100),
hr-#    ('ABC', 'Basic', 200),
hr-#    ('XYZ', 'Premium', 100),
hr-#    ('XYZ', 'Basic', 300);
INSERT 0 4
```

**sales**

| brand | segment | quantity|
|:-----:|:-------:|:-------:|
| ABC   | Premium |      100|
| ABC   | Basic   |      200|
| XYZ   | Premium |      100|
| XYZ   | Basic   |      300|

The sales table stores the number of products sold by brand and segment.

## Introduction to PostgreSQL GROUPING SETS

A grouping set is **a set of columns by which you group by using the** `GROUP BY` clause.

A grouping set is denoted by a `comma-separated list of columns placed inside parentheses`:

```SQL
(column1, column2, ...)
```

For example, the following query uses the `GROUP BY` clause to return the **number of products sold by brand and segment**. In other words, it defines a grouping set of the brand and segment which is denoted by `(brand, segement)`.

```SQL
SELECT brand, segment,
       SUM(quantity)
  FROM sales
 GROUP BY brand, segment;
```

**Results**

| brand | segment | sum|
|:-----:|:-------:|:----:|
| XYZ   | Basic   | 300|
| ABC   | Premium | 100|
| ABC   | Basic   | 200|
| XYZ   | Premium | 100|

The following query finds the number of products sold by a brand. It defines a grouping set `(brand)`:

```SQL
SELECT brand,
       SUM(quantity)
  FROM sales
 GROUP BY brand;
```

**Results**

| brand | sum|
|:-----:|:--:|
| ABC   | 300|
| XYZ   | 400|

The following query finds the number of products sold by segment. It defines a grouping set `(segment)`:

```SQL
SELECT segment,
       SUM(quantity)
  FROM sales
 GROUP BY segment;
```

**Results**

| segment | sum|
|:-------:|:----:|
| Basic   | 500|
| Premium | 200|

The following query finds the number of products sold for all brands and segments. It defines an empty grouping set which is denoted by `()`.

```SQL
SELECT SUM(quantity)
  FROM sales;
```

**Results**

| sum|
|:---:|
| 700|

Suppose that you want to all the grouping sets by using a single query. To achieve this, you may use the `UNION ALL` to combine all the queries above.

Because `UNION ALL` **requires all result sets to have the same number of columns with compatible data types**, you need to adjust the queries by adding `NULL` to the selection list of each as shown below:

```SQL
SELECT brand,
       segment,
       SUM (quantity)
  FROM sales
 GROUP BY brand, segment

UNION ALL

SELECT brand,
       NULL,
       SUM (quantity)
  FROM sales
 GROUP BY brand

UNION ALL

SELECT NULL,
       segment,
       SUM (quantity)
  FROM sales
 GROUP BY segment

UNION ALL

SELECT NULL,
       NULL,
       SUM (quantity)
  FROM sales;
```

**Results**

| brand | segment | sum|
|:-----:|:-------:|:---:|
| XYZ   | Basic   | 300|
| ABC   | Premium | 100|
| ABC   | Basic   | 200|
| XYZ   | Premium | 100|
| ABC   | NULL    | 300|
| XYZ   | NULL    | 400|
| NULL  | Basic   | 500|
| NULL  | Premium | 200|
| NULL  | NULL    | 700|

This query generated a single result set with the aggregates for all grouping sets.

Even though the above query works as you expected, it has two main problems.

- First, it is quite lengthy.
- Second, it has a performance issue because PostgreSQL has to scan the sales table separately for each query.

To make it more efficient, PostgreSQL provides the `GROUPING SETS` clause which is the subclause of the `GROUP BY` clause.

The `GROUPING SETS` allows you **to define multiple grouping sets in the same query**.

The general syntax of the `GROUPING SETS` is as follows:

```SQL
SELECT
    c1,
    c2,
    aggregate_function(c3)
FROM
    table_name
GROUP BY
    GROUPING SETS (
        (c1, c2),
        (c1),
        (c2),
        ()
);
```

In this syntax, we have four **grouping sets** `(c1,c2)`, `(c1)`, `(c2)`, and `()`.

To apply this syntax to the above example, you can use `GROUPING SETS` clause instead of the `UNION ALL` clause like this:

```SQL
SELECT brand,
       segment,
       SUM (quantity)
  FROM sales
 GROUP BY
     GROUPING SETS (
          (brand, segment),
          (brand),
          (segment),
          ()
 );
```

**Results**

| brand | segment | sum|
|:------:|:------:|:----:|
| NULL  | NULL    | 700|
| XYZ   | Basic   | 300|
| ABC   | Premium | 100|
| ABC   | Basic   | 200|
| XYZ   | Premium | 100|
| ABC   | NULL    | 300|
| XYZ   | NULL    | 400|
| NULL  | Basic   | 500|
| NULL  | Premium | 200|

This query is much shorter and more readable. In addition, PostgreSQL will optimize the number of times it scans the `sales` table and will not scan multiple times.

## Grouping function

The `GROUPING()` function accepts an argument which can be a column name or an expression:

```SQL
GROUPING( column_name | expression)
```

The column_name or expression must match with the one specified in the `GROUP BY` clause.

The `GROUPING()` function returns bit `0` if the argument is a member of the current grouping set and `1` otherwise.

See the following example:

```SQL
SELECT GROUPING(brand) grouping_brand,
       GROUPING(segment) grouping_segment,
       brand,
       segment,
       SUM (quantity)
  FROM sales
 GROUP BY
        GROUPING SETS (
                (brand),
                (segment),
                ()
        )
 ORDER BY brand, segment;
```

**Results**

| grouping_brand | grouping_segment | brand | segment | sum|
|:--------------:|:----------------:|:-----:|:-------:|:----:|
|              0 |                1 | ABC   | NULL    | 300|
|              0 |                1 | XYZ   | NULL    | 400|
|              1 |                0 | NULL  | Basic   | 500|
|              1 |                0 | NULL  | Premium | 200|
|              1 |                1 | NULL  | NULL    | 700|

As shown in the resulting table, when the value in the `grouping_brand` is `0`, the **sum column shows the subtotal of the** `brand`.

When the value in the `grouping_segment` is `zero`, the **sum column shows the subtotal of the** `segment`.

You can use the `GROUPING()` function in the `HAVING` clause **to find the subtotal of each** `brand` like this:

```SQL
SELECT GROUPING(brand) grouping_brand,
       GROUPING(segment) grouping_segment,
       brand,
       segment,
       SUM(quantity)
  FROM sales
 GROUP BY
        GROUPING SETS (
                 (brand),
                 (segment),
                 ()
        )
  HAVING GROUPING(brand) = 0
  ORDER BY brand, segment;
```
**Results**

| grouping_brand | grouping_segment | brand | segment | sum|
|:--------------:|:----------------:|:-----:|:-------:|:----:|
|              0 |                1 | ABC   | NULL    | 300|
|              0 |                1 | XYZ   | NULL    | 400|
