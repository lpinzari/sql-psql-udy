# SQL Aggregation Introduction

So far in this course, we use SQL to join tables using `left`,`right` and `inner` join and filter the results using `WHERE` and `ON` clauses.

Sometimes, it's useful to view row-level data. For example, we might want to look at all the individual orders for a given sales person to see how they're performing in a given month.

Fortunately, databases are great at aggregating data. SQL provides a number of built-in functions for performing common **aggregate functions**.

Postgres aggregate functions **calculate on a group of rows and return a single value for each group**.

We commonly use the aggregate functions together with the `GROUP BY` clause.

1. The `GROUP BY` clause **divides the rows into groups and an aggregate function calculates and returns a single result for each group**.

2. If you use aggregate functions **without a** `GROUP BY` clause, then the **aggregate functions apply to all rows of the queried tables or views**.

3. We also use the aggregate functions in the `HAVING` clause **to filter groups from the output based on the results of the aggregate functions**.

Postgres aggregate functions can appear in
- `SELECT` lists and
- `ORDER BY`,
- `GROUP BY`, and
- `HAVING` clauses.

The following illustrates how the aggregate function is used with the `GROUP BY` clause:

```SQL
SELECT c1, aggregate_function(c2)
FROM table
GROUP BY c1;
```

PostgreSQL provides all standard SQL’s aggregate functions as follows:

- `AVG()` – return the average value.
- `COUNT()` – return the number of values.
- `MAX()` – return the maximum value.
- `MIN()` – return the minimum value.
- `SUM()` – return the sum of all or distinct values.

Except for the COUNT() function, SQL aggregate functions ignore null.

## DISTINCT vs. ALL

Some aggregate functions accept `DISTINCT` or `ALL` clause.

- The `DISTINCT` clause instructs an **aggregate function to consider only distinct values of the argument**.

- The `ALL` clause causes an **aggregate function to take all values into the calculation, including duplicates**.

For example, the `DISTINCT` average of `2`, `2`, `2` and `4` is **3**, which is the result of `(2 + 4) / 2`.

However, the `ALL` average of `2`, `2`, `2` and `4` is **2.5**, which is the result of `(2 + 2 + 2 + 4) / 4`.

PostgreSQL uses the `ALL` clause by default **if you don’t explicitly specify any clause**.
