# CUBE FUNCTION

PostgreSQL **CUBE** is a `subclause` of the `GROUP BY` clause. The CUBE **allows you to generate multiple grouping sets**.

A grouping set is a set of columns to which you want to group. For more information on the grouping sets, check it out the `GROUPING SETS` lesson.

The following illustrates the syntax of the **CUBE** subclause:

```SQL
SELECT
    c1,
    c2,
    c3,
    aggregate (c4)
FROM
    table_name
GROUP BY
    CUBE (c1, c2, c3);
```

In this syntax:

- First, specify the **CUBE** subclause in the the `GROUP BY` clause of the SELECT statement.
- Second, in the select list, specify the columns (dimensions or dimension columns, e.g `c1, c2, c3`) which you want to analyze and aggregation function expressions.
- Third, in the GROUP BY clause, specify the dimension columns within the parentheses of the CUBE subclause, `(c1,c2,c3)`.

The query generates **all possible grouping sets based on the dimension columns specified in** `CUBE`.

The CUBE subclause is a short way to define multiple grouping sets so the following are equivalent:

```SQL
CUBE(c1,c2,c3)

GROUPING SETS (
    (c1,c2,c3),
    (c1,c2),
    (c1,c3),
    (c2,c3),
    (c1),
    (c2),
    (c3),
    ()
 )  
```

The **CUBE** generates `grouping sets` of **all combinations** of `c1`, `c2` and `c3` dimensions, which returns **8** `grouping sets`, **2<sup>3</sup>**.

In general, if the number of columns specified in the **CUBE** is `n`, then you will have **2<sup>n</sup>** combinations.

When the aggregate function is the `SUM()` function, you will have **2<sup>n</sup>** `subtotals for all the possible combinations of dimensions`.

PostgreSQL allows you to perform a `partial cube` to reduce the number of aggregates calculated. The following shows the syntax:

```SQL
SELECT
    c1,
    c2,
    c3,
    aggregate (c4)
FROM
    table_name
GROUP BY
    c1,
    CUBE (c1, c2);
```

## PostgreSQL CUBE examples

We will use the sales table created in the `GROUPING SETS` lesson for the demonstration.

**sales**

| brand | segment | quantity|
|:-----:|:-------:|:-------:|
| ABC   | Premium |      100|
| ABC   | Basic   |      200|
| XYZ   | Premium |      100|
| XYZ   | Basic   |      300|

The sales table stores the number of products sold by brand and segment.

The following query uses the **CUBE** subclause to generate multiple grouping sets:

**SQL**

```SQL
SELECT brand,
       segment,
       SUM (quantity)
  FROM sales
 GROUP BY
       CUBE (brand, segment)
 ORDER BY brand, segment;
```

**Results**

| brand | segment | sum|
|:-----:|:--------:|:----:|
| **ABC**   | Basic   | 200|
| **ABC**   | Premium | 100|
| **ABC**   | NULL    | 300|
| XYZ   | Basic   | 300|
| XYZ   | Premium | 100|
| XYZ   | NULL    | 400|
| **NULL**  | Basic   | 500|
| **NULL**  | Premium | 200|
| **NULL**  | NULL    | 700|

The `brand` and `segment` columns have two distinct values. The `CUBE` function combines the first value `ABC` with the other two distinct values of segment's column, and the value `NULL` to include the single value `ABC`. Similarly, the string `XYZ` has three rows and lastly three NULLs rows.

The following query performs a partial cube:

**SQL**

```SQL
SELECT brand,
       segment,
       SUM (quantity)
  FROM sales
 GROUP BY brand,
          CUBE (segment)
 ORDER BY brand, segment;
```

**Results**

| brand | segment | sum|
|:-----:|:--------:|:----:|
| **ABC**   | Basic   | 200|
| **ABC**   | Premium | 100|
| **ABC**   | NULL    | 300|
| XYZ   | Basic   | 300|
| XYZ   | Premium | 100|
| XYZ   | NULL    | 400|
