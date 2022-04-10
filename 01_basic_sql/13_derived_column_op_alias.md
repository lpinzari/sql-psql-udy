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