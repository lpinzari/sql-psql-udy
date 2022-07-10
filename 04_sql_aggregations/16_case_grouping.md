# PostgreSQL CASE

The PostgreSQL CASE expression is the same as `IF/ELSE` statement in other programming languages. **It allows you to add if-else logic to the query** to form a powerful query.

Since CASE is an `expression`, you can use it in any places where an expression can be used e.g.,`SELECT`, `WHERE`, `GROUP BY`, and `HAVING` clause.

The CASE expression has two forms:

- **general** and
- **simple** form.

##  General PostgreSQL CASE expression

The following illustrates the general form of the **CASE** statement:

```SQL
CASE
      WHEN condition_1  THEN result_1
      WHEN condition_2  THEN result_2
      [WHEN ...]
      [ELSE else_result]
END
```

In this syntax, each condition (`condition_1`, `condition_2`…) is a **boolean expression** that returns either `true` or `false`.

- When a condition evaluates to **false**, the CASE expression `evaluates the next condition` from the top to bottom until it finds a condition that evaluates to true.

- If a condition evaluates to **true**, the CASE expression **returns the corresponding result that follows the condition**. For example, if the `condition_2` evaluates to true, the `CASE` expression `returns the result_2`. Also, it immediately stops evaluating the next expression.

In case all conditions evaluate to **false**, the CASE expression returns the result (`else_result`) that follows the `ELSE` keyword.

- If you omit the `ELSE` clause, the CASE expression **returns NULL**.

## A general CASE example

Let’s take a look at the `film` table from the `dvdrental` sample database.

```console
dvdrental=# \d film
                                              Table "public.film"
      Column      |            Type             | Collation | Nullable |                Default
------------------+-----------------------------+-----------+----------+---------------------------------------
 film_id          | integer                     |           | not null | nextval('film_film_id_seq'::regclass)
 title            | character varying(255)      |           | not null |
 description      | text                        |           |          |
 release_year     | year                        |           |          |
 language_id      | smallint                    |           | not null |
 rental_duration  | smallint                    |           | not null | 3
 rental_rate      | numeric(4,2)                |           | not null | 4.99
 length           | smallint                    |           |          |
 replacement_cost | numeric(5,2)                |           | not null | 19.99
 rating           | mpaa_rating                 |           |          | 'G'::mpaa_rating
 last_update      | timestamp without time zone |           | not null | now()
 special_features | text[]                      |           |          |
 fulltext         | tsvector                    |           | not null |
```

Suppose you want to label the films by their **length based on the following logic**:

- If the `length` is **less than 50 minutes**, the film is `short`.
- If the `length` is **greater than 50 minutes and less than or equal to 120 minutes**, the film is `medium`.
- If the `length` is **greater than 120 minutes**, the film is `long`.

To apply this logic, you can use the `CASE` expression in the `SELECT` statement as follows:

```SQL
SELECT title,
       length,
       CASE
           WHEN length > 0 AND length <= 50 THEN 'Short'
           WHEN length > 50 AND length <= 120 THEN 'Medium'
           WHEN length > 120 THEN 'Long'
       END duration
  FROM film
 ORDER BY title
 LIMIT 10;
```

**Results**

|      title       | length | duration|
|:----------------:|:------:|:--------:|
| Academy Dinosaur |     86 | Medium|
| Ace Goldfinger   |     48 | Short|
| Adaptation Holes |     50 | Short|
| Affair Prejudice |    117 | Medium|
| African Egg      |    130 | Long|
| Agent Truman     |    169 | Long|
| Airplane Sierra  |     62 | Medium|
| Airport Pollock  |     54 | Medium|
| Alabama Devil    |    114 | Medium|
| Aladdin Calendar |     63 | Medium|

Note that we placed a column `alias` **duration** after the `CASE` expression.

## Using CASE with an aggregate function example

Suppose that you want to assign **price segments** to `films` with the following logic:

- If the rental rate is `0.99`, the film is **economic**.
- If the rental rate is `1.99`, the film is **mass**.
- If the rental rate is `4.99`, the film is **premium**.

And you want to know the **number of films that belong** to `economy`, `mass`, and `premium`.

In this case, you can use the CASE expression to construct the query as follows:

```SQL
SELECT SUM (CASE
                WHEN rental_rate = 0.99 THEN 1 ELSE 0
            END
       ) AS "Economy",
       SUM (CASE
                WHEN rental_rate = 2.99 THEN 1 ELSE 0
            END
       ) AS "Mass",
       SUM (CASE
                WHEN rental_rate = 4.99 THEN 1 ELSE 0
            END
       ) AS "Premium"
  FROM film;
```

**Results**

| Economy | Mass | Premium|
|:-------:|:-----:|:--------:|
|     341 |  323 |     336|

In this example, we used the `CASE` expression to return `1` or `0` **if the rental rate falls into each price segment**. And we applied the `SUM` function to **calculate the total of films for each price segment**.

## Simple PostgreSQL CASE expression

PostgreSQL provides another form of the `CASE` expression called simple form as follows:

```SQL
CASE expression
   WHEN value_1 THEN result_1
   WHEN value_2 THEN result_2
   [WHEN ...]
ELSE
   else_result
END
```

The `CASE` first evaluates the expression and compares the result with each value( `value_1`, `value_2`, …) in the `WHEN` clauses **sequentially until it finds the match**.

Once the result of the **expression equals a value** (`value1`, `value2`, etc.) in a `WHEN` clause, the `CASE` **returns the corresponding result** in the `THEN` clause.

If `CASE` **does not find any matches**, it returns the `else_result` in that follows the `ELSE`, or `NULL` value if the `ELSE` is not available.

## Simple PostgreSQL CASE expression example

The following statement uses the `CASE` expression to **add the rating description** to the output:

```SQL
SELECT title,
       rating,
       CASE rating
           WHEN 'G' THEN 'General Audiences'
           WHEN 'PG' THEN 'Parental Guidance Suggested'
           WHEN 'PG-13' THEN 'Parents Stringly Cautioned'
           WHEN 'R' THEN 'Restricted'
           WHEN 'NC-17' THEN 'Adults Only'
       END rating_description
  FROM film
 ORDER BY film
 LIMIT 10;
```

**Results**

|      title       | rating |     rating_description|
|:----------------:|:------:|:----------------------------:|
| Academy Dinosaur | PG     | Parental Guidance Suggested|
| Ace Goldfinger   | G      | General Audiences|
| Adaptation Holes | NC-17  | Adults Only|
| Affair Prejudice | G      | General Audiences|
| African Egg      | G      | General Audiences|
| Agent Truman     | PG     | Parental Guidance Suggested|
| Airplane Sierra  | PG-13  | Parents Stringly Cautioned|
| Airport Pollock  | R      | Restricted|
| Alabama Devil    | PG-13  | Parents Stringly Cautioned|
| Aladdin Calendar | NC-17  | Adults Only|

In this example, we used a simple `CASE` expression to compare the `rating` from the film table with some literal values like `G`, `PG`, `NC17`, `PG-13` and **return the corresponding rating description**.

## Using simple PostgreSQL CASE expression with aggregate function example

The following statement uses `CASE` expression with the `SUM` function to calculate the **number of films in each rating**:

```SQL
SELECT SUM(CASE rating
               WHEN 'G' THEN 1 ELSE 0
           END
       ) AS "General Audiences",
       SUM(CASE rating
               WHEN 'PG' THEN 1 ELSE 0
           END
       ) AS "Parental Guidance Suggested",
       SUM(CASE rating
               WHEN 'PG-13' THEN 1 ELSE 0
           END
       ) AS "Parents Stringly Cautioned",
       SUM(CASE rating
               WHEN 'R' THEN 1 ELSE 0
           END
       ) AS "Restricted",
       SUM(CASE rating
               WHEN 'NC-17' THEN 1 ELSE 0
           END
        ) AS "Adults Only"
  FROM film;
```

|General Audiences|Parental Guidance Suggested|Parents Stringly Cautioned|Restricted| Adults Only|
|:----------------:|:------:|:-------------------------:|:------------:|:------------:|
|178 | 194 |  223 | 195 | 210|

## Parch_Posey Examples

Let's take a look at the `orders` and `accounts` tables from the `parch_posey` sample database.


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
```

**accounts**

```console
parch_posey=# \d accounts
                    Table "public.accounts"
    Column    |     Type      | Collation | Nullable | Default
--------------+---------------+-----------+----------+---------
 id           | integer       |           | not null |
 name         | bpchar        |           |          |
 website      | bpchar        |           |          |
 lat          | numeric(11,8) |           |          |
 long         | numeric(11,8) |           |          |
 primary_poc  | bpchar        |           |          |
 sales_rep_id | integer       |           |          |
Indexes:
    "accounts_pkey" PRIMARY KEY, btree (id)
Foreign-key constraints:
    "accounts_fkey_sales_rep" FOREIGN KEY (sales_rep_id) REFERENCES sales_reps(id) ON DELETE CASCADE
Referenced by:
    TABLE "orders" CONSTRAINT "orders_fkey_account" FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE
    TABLE "web_events" CONSTRAINT "web_events_fkey_account" FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE
```

### Problem 1

Write a query to display for each order, the `account ID`, `total amount of the order`, and the level of the order - `Large` or `Small` - **depending on if the order is $3000 or more, or less than $3000**.

```SQL
SELECT account_id,
       total_amt_usd,
       CASE WHEN total_amt_usd > 3000 THEN 'Large' ELSE 'Small'
       END AS order_level
  FROM orders
 ORDER BY total_amt_usd DESC
 LIMIT 10;
```

**Results**

| account_id | total_amt_usd | order_level|
|:----------:|:-------------:|:----------:|
|       4251 |     232207.07 | Large|
|       4161 |     112875.18 | Large|
|       4211 |     107533.55 | Large|
|       2861 |      95005.82 | Large|
|       4101 |      93547.84 | Large|
|       4111 |      93505.69 | Large|
|       1301 |      93106.81 | Large|
|       1521 |      92991.05 | Large|
|       1341 |      84099.62 | Large|
|       4151 |      82163.71 | Large|

### Problem 2

Write a query to display the **number of orders in each of three categories**, based on the total number of items in each order. The three categories are:

- `At Least 2000`,
- `Between 1000 and 2000` and
- `Less than 1000`.

```SQL
SELECT CASE WHEN total >= 2000 THEN 'At least 2000'
            WHEN total >= 1000 AND total < 2000 THEN 'Between 1000 and 2000'
            ELSE 'Less then 1000'
       END AS order_category,
       COUNT(*) AS order_count
  FROM orders;
```

**Results**

|    order_category     | order_count|
|:---------------------:|:----------:|
| Between 1000 and 2000 |         511|
| At least 2000         |          70|
| Less then 1000        |        6331|


### Problem 3

We would like to understand **3 different branches of customers** based on the amount associated with their purchases.

- The top branch includes anyone with a Lifetime Value (total sales of all orders) `greater than 200,000 usd`.
- The second branch is `between 200,000 and 100,000 usd`.
- The lowest branch is `anyone under 100,000 usd`.

Provide a table that includes the level associated with each account. You should provide the `account name`, the `total sales of all orders` for the customer, and `the level`. **Order with the top spending customers listed first**.

```SQL
SELECT a.name,
       SUM(total_amt_usd) total_spent,
       CASE WHEN SUM(total_amt_usd) > 200000 THEN 'top'
            WHEN SUM(total_amt_usd) > 100000 THEN 'middle'
            ELSE 'low'
       END AS customer_level
  FROM orders o
  JOIN accounts a
    ON o.account_id = a.id
 GROUP BY a.name
 ORDER BY 2 DESC
 LIMIT 10;
```

**Results**

|          name          | total_spent | customer_level|
|:----------------------:|:-----------:|:--------------:|
| EOG Resources          |   382873.30 | top|
| Mosaic                 |   345618.59 | top|
| IBM                    |   326819.48 | top|
| General Dynamics       |   300694.79 | top|
| Republic Services      |   293861.14 | top|
| Leucadia National      |   291047.25 | top|
| Arrow Electronics      |   281018.36 | top|
| Sysco                  |   278575.64 | top|
| Supervalu              |   275288.30 | top|
| Archer Daniels Midland |   272672.84 | top|

### Problem 4

We would now like to perform a similar calculation to the first, but we want to obtain the total amount spent by **customers only in 2016 and 2017**. Keep the same levels as in the previous question. Order with the top spending customers listed first.


```SQL
SELECT a.name,
       SUM(total_amt_usd) total_spent,
       CASE WHEN SUM(total_amt_usd) > 200000 THEN 'top'
            WHEN SUM(total_amt_usd) > 100000 THEN 'middle'
            ELSE 'low'
       END AS customer_level
  FROM orders o
  JOIN accounts a
    ON o.account_id = a.id
 WHERE occurred_at > '2015-12-31'
 GROUP BY 1
 ORDER BY 2 DESC
 LIMIT 10;
```

**Results**

|            name             | total_spent | customer_level|
|:---------------------------:|:-----------:|:-------------:|
| Pacific Life                |   255319.18 | top|
| Mosaic                      |   172180.04 | middle|
| CHS                         |   163471.78 | middle|
| Core-Mark Holding           |   148105.93 | middle|
| Disney                      |   129157.38 | middle|
| National Oilwell Varco      |   121873.16 | middle|
| Sears Holdings              |   114003.21 | middle|
| State Farm Insurance Cos.   |   111810.55 | middle|
| Fidelity National Financial |   110027.29 | middle|
| BB&T Corp.                  |   107300.05 | middle|

### Problem 5

We would like to identify top performing **sales reps**, which are sales reps associated with more than `200 orders`.

Create a table with the `sales rep name`, the `total number of orders`, and a column with top or not depending on if they have more than 200 orders. Place the top sales people first in your final table.

```SQL
SELECT s.name,
       COUNT(*) num_ords,
       CASE WHEN COUNT(*) > 200 THEN 'top' ELSE 'not'
       END AS sales_rep_level
  FROM orders o
  JOIN accounts a
    ON o.account_id = a.id
  JOIN sales_reps s
    ON s.id = a.sales_rep_id
 GROUP BY s.name
 ORDER BY 2 DESC
 LIMIT 15;
```

**Results**

|        name         | num_ords | sales_rep_level|
|:-------------------:|:---------:|:-----------------:|
| Earlie Schleusner   |      335 | top|
| Vernita Plump       |      299 | top|
| Tia Amato           |      267 | top|
| Georgianna Chisholm |      256 | top|
| Moon Torian         |      250 | top|
| Nelle Meaux         |      241 | top|
| Maren Musto         |      224 | top|
| Dorotha Seawell     |      208 | top|
| Charles Bidwell     |      205 | top|
| Maryanna Fiorentino |      204 | top|
| Calvin Ollison      |      199 | not|
| Sibyl Lauria        |      193 | not|
| Elwood Shutt        |      191 | not|
| Hilma Busick        |      191 | not|
| Arica Stoltzfus     |      186 | not|

It is worth mentioning that this assumes each name is unique - which has been done a few times. We otherwise would want to break by the name and the id of the table.

### Problem 6

The previous didn't account for the `middle`, nor the dollar amount associated with the sales. Management decides they want to see these characteristics represented as well. We would like to identify top performing sales reps, which are **sales reps** associated with more than `200` orders or more than `750000` in total sales. The `middle` group has any rep with more than `150` orders or `500000` in sales.

Create a table with the sales rep name, the `total number of orders`, `total sales across all orders`, and a column with `top`, `middle`, or `low` depending on this criteria. Place the top sales people based on dollar amount of sales first in your final table.

```SQL
SELECT s.name,
       COUNT(*),
       SUM(o.total_amt_usd) total_spent,
       CASE WHEN COUNT(*) > 200 OR SUM(o.total_amt_usd) > 750000 THEN 'top'
            WHEN COUNT(*) > 150 OR SUM(o.total_amt_usd) > 500000 THEN 'middle'
            ELSE 'low'
       END AS sales_rep_level
  FROM orders o
  JOIN accounts a
    ON o.account_id = a.id
  JOIN sales_reps s
    ON s.id = a.sales_rep_id
 GROUP BY s.name
 ORDER BY 3 DESC
 LIMIT 15;
```

**Results**

|        name         | count | total_spent | sales_rep_level|
|:--------------------:|:-----:|:----------:|:--------------:|
| Earlie Schleusner   |   335 |  1098137.72 | top|
| Tia Amato           |   267 |  1010690.60 | top|
| Vernita Plump       |   299 |   934212.93 | top|
| Georgianna Chisholm |   256 |   886244.12 | top|
| Arica Stoltzfus     |   186 |   810353.34 | top|
| Dorotha Seawell     |   208 |   766935.04 | top|
| Nelle Meaux         |   241 |   749076.16 | top|
| Sibyl Lauria        |   193 |   722084.27 | middle|
| Maren Musto         |   224 |   702697.29 | top|
| Brandie Riva        |   167 |   675917.64 | middle|
| Charles Bidwell     |   205 |   675637.19 | top|
| Elwood Shutt        |   191 |   662500.24 | middle|
| Maryanna Fiorentino |   204 |   655954.74 | top|
| Moon Torian         |   250 |   650393.52 | top|
| Hilma Busick        |   191 |   622808.04 | middle|
