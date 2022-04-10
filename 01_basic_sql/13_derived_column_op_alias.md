# Arithmetic operations - Derived columns - Alias

Before we calculate **how much non-standard paper was sold**, let's check out the order quantities in each column of the orders.

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
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
```

Let's select only the quantity columns.

- `standard_qty`
- `gloss_qty`  (non-standard)
- `poster_qty` (non-standard)

```console
parch_posey=# SELECT account_id,
parch_posey-#        occurred_at,
parch_posey-#        standard_qty,
parch_posey-#        gloss_qty,
parch_posey-#        poster_qty
parch_posey-#   FROM orders
parch_posey-#  LIMIT 5;
account_id |     occurred_at     | standard_qty | gloss_qty | poster_qty
------------+---------------------+--------------+-----------+------------
       1001 | 2015-10-06 17:31:14 |          123 |        22 |         24
       1001 | 2015-11-05 03:34:33 |          190 |        41 |         57
       1001 | 2015-12-04 04:21:55 |           85 |        47 |          0
       1001 | 2016-01-02 01:18:24 |          144 |        32 |          0
       1001 | 2016-02-01 19:27:27 |          108 |        29 |         28
(5 rows)
```
Now, let's **create a new column** that **adds** `gloss_qty` and `poster_qty` to create a field `non_standard` paper. To do this, we'll create a new line in the query and use an arithmetic operator.

```console
SELECT account_id,
       occurred_at,
       standard_qty,
       gloss_qty,
       poster_qty,
       gloss_qty + poster_qty
  FROM orders
 LIMIT 5;
```

Let's execute the query.

```console
parch_posey=# SELECT account_id,
parch_posey-#        occurred_at,
parch_posey-#        standard_qty,
parch_posey-#        gloss_qty,
parch_posey-#        poster_qty,
parch_posey-#        gloss_qty + poster_qty
parch_posey-#   FROM orders
parch_posey-#  LIMIT 5;
account_id |     occurred_at     | standard_qty | gloss_qty | poster_qty | ?column?
------------+---------------------+--------------+-----------+------------+----------
      1001 | 2015-10-06 17:31:14 |          123 |        22 |         24 |       46
      1001 | 2015-11-05 03:34:33 |          190 |        41 |         57 |       98
      1001 | 2015-12-04 04:21:55 |           85 |        47 |          0 |       47
      1001 | 2016-01-02 01:18:24 |          144 |        32 |          0 |       32
      1001 | 2016-02-01 19:27:27 |          108 |        29 |         28 |       57
(5 rows)
```

You'll notice that the values in the column `?column?` are equal to the sum of the `gloss_qty` and `poster_qty` **on a row-by-row basis**.

In the first row:

| gloss_qty | poster_qty | ?column? |
|:---------:|:----------:|:--------:|
| 22| 24| 46|

22 `gloss` and 24 `poster` sum to 46 non standrad paper in the new column we've created. There is a special name for this. It's a **derived column**.

**Derived Column**: A **new column that is a manipulation of the exisitng columns in your database**.

Derive columns can include simple arithmetic or any number of advanced calculations. What makes them special is the fact that they're not just directly selected from the underlying data. **They are manipulated in some way**.

Rather than stick with this ugly column name `?column?`, let's add something more descriptive using an **alias**. We can do this by adding `AS` to the end of the line that produces the derived column and giving it a name.

The best practice is to use names that are clearly descriptive, following existing conventions and don't include capital letters or spaces.

```console
SELECT account_id,
       occurred_at,
       standard_qty,
       gloss_qty,
       poster_qty,
       gloss_qty + poster_qty AS nonstandard_qty
  FROM orders
 LIMIT 5;
```

![20 alias](./images/20_alias.png)

```console
parch_posey=# SELECT account_id,
parch_posey-#        occurred_at,
parch_posey-#        standard_qty,
parch_posey-#        gloss_qty,
parch_posey-#        poster_qty,
parch_posey-#        gloss_qty + poster_qty AS nonstandard_qty
parch_posey-#   FROM orders
parch_posey-#  LIMIT 5;
 account_id |     occurred_at     | standard_qty | gloss_qty | poster_qty | nonstandard_qty
------------+---------------------+--------------+-----------+------------+-----------------
       1001 | 2015-10-06 17:31:14 |          123 |        22 |         24 |              46
       1001 | 2015-11-05 03:34:33 |          190 |        41 |         57 |              98
       1001 | 2015-12-04 04:21:55 |           85 |        47 |          0 |              47
       1001 | 2016-01-02 01:18:24 |          144 |        32 |          0 |              32
       1001 | 2016-02-01 19:27:27 |          108 |        29 |         28 |              57
(5 rows)
```

## Summary

Creating a new column that is a combination of existing columns is known as a **derived column** (or "**calculated**" or "**computed**" column). Usually you want to give a name, or "**alias**," to your new column using the `AS` keyword.

This derived column, and its alias, are generally only temporary, existing just for the duration of your query. The next time you run a query and access this table, the new column will not be there.

If you are deriving the new column from existing columns using a mathematical expression, then these familiar mathematical operators will be useful:

1. `*` (Multiplication)
2. `+` (Addition)
3. `-` (Subtraction)
4. `/` (Division)

Consider this example:

```console
SELECT id,
       (standard_amt_usd/total_amt_usd)*100 AS std_percent,
       total_amt_usd
  FROM orders
 LIMIT 10;
```

Here we divide the standard paper dollar amount by the total order amount to find the standard paper percent for the order, and use the `AS` keyword to name this new column "`std_percent`."

### Order of Operations
math [class](https://www.purplemath.com/modules/orderops.htm) to help remember the order of operations. The same order of operations applies when using arithmetic operators in SQL.

## Questions using Arithmetic Operations

Using the `orders` table:

1. Create a column that divides the `standard_amt_usd` by the `standard_qty` to find **the unit price** for *standard paper* for each order. Limit the results to the first 10 orders, and include the `id` and `account_id` fields.

```console
SELECT id,
       account_id,
       standard_amt_usd/standard_qty AS unit_price
  FROM orders
 LIMIT 10;
```

2. Write a query that finds the **percentage of revenue** that comes from poster paper for each order. You will need to use only the columns that end with `_usd`. (Try to do this without using the total column.) Display the id and account_id fields also. **NOTE** - **you will receive an error with the correct solution to this question. This occurs because at least one of the values in the data creates a division by zero in your formula. You will learn later in the course how to fully handle this issue**. For now, you can just limit your calculations to the first 10 orders, as we did in question 1, and you'll avoid that set of data that causes the problem.

```console
SELECT id,
       account_id,
       poster_amt_usd/(standard_amt_usd + gloss_amt_usd + poster_amt_usd) AS post_per
  FROM orders
 LIMIT 10;
```
