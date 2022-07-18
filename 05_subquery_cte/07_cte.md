# Common Table Expressions

A common table expression is a `temporary result set` which you can reference within another SQL statement including `SELECT`, `INSERT`, `UPDATE` or `DELETE`.

**Common Table Expressions** are temporary in the sense that **they only exist during the execution of the query**.

The following shows the syntax of creating a **CTE**:

```SQL
WITH cte_name (column_list) AS (
    CTE_query_definition
)
statement;
```

In this syntax:

- First, specify the name of the `CTE` following by an optional column list.
- Second, inside the body of the `WITH` clause, specify a query that returns a result set. If you do not explicitly specify the `column list` after the CTE name, the `select` list of the `CTE_query_definition` will become the column list of the CTE.
- Third, use the CTE like a table or view in the statement which can be a `SELECT`, `INSERT`, `UPDATE`, or `DELETE`.

Common Table Expressions or **CTEs** are typically used to simplify **complex joins** and **subqueries** in PostgreSQL.

Though these expressions serve the exact same purpose as subqueries, they are more common in practice, as they tend to be cleaner for a future reader to follow the logic.

## PostgreSQL CTE advantages

The following are some advantages of using common table expressions or CTEs:

- Improve the readability of complex queries. You use CTEs to organize complex queries in a more organized and readable manner.
- Ability to create **recursive queries**. Recursive queries are **queries that reference themselves**. The recursive queries come in handy when you want to query `hierarchical data` such as organization chart or bill of materials.
- Use in conjunction with **window functions**. You can use CTEs in conjunction with window functions to **create an initial result set and use another select statement to further process this result set**.

## PostgreSQL CTE examples

Let’s take some examples of using CTEs to get a better understanding.

To demonstrate the use of a cte in a query we'll be using the `web_events` table in the `parch_posey` sample database.

```console
parch_posey=# \d web_events
                         Table "public.web_events"
   Column    |            Type             | Collation | Nullable | Default
-------------+-----------------------------+-----------+----------+---------
 id          | integer                     |           | not null |
 account_id  | integer                     |           |          |
 occurred_at | timestamp without time zone |           |          |
 channel     | bpchar                      |           |          |
```

**We want to find the average number of events for each day for each channel**.

```SQL
SELECT channel,
       AVG(events) AS average_events
  FROM (SELECT DATE_TRUNC('day',occurred_at) AS day,
               channel,
               COUNT(*) as events
          FROM web_events
         GROUP BY 1,2) sub
GROUP BY channel
ORDER BY 2 DESC;
```

Let's try this again using a **WITH** statement.

Notice, you can pull the inner query:

```SQL
SELECT DATE_TRUNC('day',occurred_at) AS day,
       channel, COUNT(*) as events
  FROM web_events
 GROUP BY 1,2
```

This is the part we put in the **WITH** statement. Notice, we are aliasing the table as `events` below:

```SQL
WITH events AS (
          SELECT DATE_TRUNC('day',occurred_at) AS day,
                  channel,
                  COUNT(*) as events
            FROM web_events
           GROUP BY 1,2)
```

Now, we can use this newly created `events` table as if it is any other table in our database:

```SQL
WITH events AS (
          SELECT DATE_TRUNC('day',occurred_at) AS day,
                        channel, COUNT(*) as events
          FROM web_events
          GROUP BY 1,2)

SELECT channel,
       AVG(events) AS average_events
  FROM events
 GROUP BY channel
 ORDER BY 2 DESC;
```

**Results**

|channel  |   average_events|
|:--------:|:-------------------:|
|direct   | 4.8964879852125693|
|organic  | 1.6672504378283713|
|facebook | 1.5983471074380165|
|adwords  | 1.5701906412478336|
|twitter  | 1.3166666666666667|
|banner   | 1.2899728997289973|

For the above example, we don't need anymore than the one additional table, **but imagine we needed to create a second table to pull from.** We can create an additional table to pull from in the following way:

```SQL
WITH table1 AS (
          SELECT *
          FROM web_events),

     table2 AS (
          SELECT *
          FROM accounts)


SELECT *
  FROM table1
  JOIN table2
    ON table1.account_id = table2.id;
```

You can add more and more tables using the `WITH` statement in the same way: When creating multiple tables using `WITH`, **you add a comma after every table except the last table leading to your final query**.

## Example dvdrental

We will use the `film` and `rental` tables from the `dvrental` sample database for the demonstration.

See the following example:

```SQL
WITH cte_film AS (
    SELECT
        film_id,
        title,
        (CASE
            WHEN length < 30 THEN 'Short'
            WHEN length < 90 THEN 'Medium'
            ELSE 'Long'
        END) length    
    FROM
        film
)
SELECT film_id,
       title,
       length
  FROM cte_film
 WHERE length = 'Long'
 ORDER BY title
 LIMIT 10;  
```

**Results**

|film_id |      title       | length|
|:------:|:----------------:|:------:|
|      4 | Affair Prejudice | Long|
|      5 | African Egg      | Long|
|      6 | Agent Truman     | Long|
|      9 | Alabama Devil    | Long|
|     11 | Alamo Videotape  | Long|
|     12 | Alaska Phantom   | Long|
|     13 | Ali Forever      | Long|
|     14 | Alice Fantasia   | Long|
|     16 | Alley Evolution  | Long|
|     19 | Amadeus Holy     | Long|

In this example, we first defined a common table expression named `cte_film` using the `WITH` clause as follows:

```SQL
WITH cte_film AS (
    SELECT
        film_id,
        title,
        (CASE
            WHEN length < 30
                THEN 'Short'
            WHEN length >= 30 AND length < 90
                THEN 'Medium'
            WHEN length >=  90
                THEN 'Long'
        END) length    
    FROM
        film
)
```

The common table expression has two parts:

- The first part defines the name of the CTE which is `cte_film`.
- The second part defines a `SELECT` statement that populates the expression with rows.

We then used the `cte_film` CTE in the `SELECT` statement to return only films whose lengths are ‘**Long**’.

## Joining a CTE with a table example

In the following example, we will use the `rental` and `staff` tables:

The following statement illustrates **how to join a** `CTE` with a table:

```SQL
WITH cte_rental AS (
    SELECT staff_id,
           COUNT(rental_id) rental_count
      FROM rental
     GROUP BY staff_id
)
SELECT s.staff_id,
       first_name,
       last_name,
       rental_count
  FROM staff s
  INNER JOIN cte_rental USING (staff_id);  
```
In this example:

- First, the CTE returns a result set that includes `staff id` and `the number of rentals`.
- Then, join the staff table with the CTE using the `staff_id` column.

Here is the output:

**Results**

|staff_id | first_name | last_name | rental_count|
|:-------:|:----------:|:----------:|:-------------:|
|        1 | Mike       | Hillyer   |         8040|
|        2 | Jon        | Stephens  |         8004|

## Using CTE with a window function example

The following statement illustrates how to use the `CTE` with the `RANK()` window function:

```SQL
WITH cte_film AS (
    SELECT film_id,
           title,
           rating,
           length,
           RANK() OVER (
                  PARTITION BY rating
                  ORDER BY length DESC)
           length_rank
      FROM film
)
SELECT *
  FROM cte_film
 WHERE length_rank = 1;
```

In this example:

- First, we defined a CTE that returns the film ranking by length for each film rating.
- Second, we selected only films whose length rankings are one.

**Results**

|film_id |       title        | rating | length | length_rank|
|:-------:|:-----------------:|:-------:|:------:|:------------:|
|     182 | Control Anthem     | G      |    185 |           1|
|     212 | Darn Forrester     | G      |    185 |           1|
|     609 | Muscle Bright      | G      |    185 |           1|
|     991 | Worst Banger       | PG     |    185 |           1|
|     141 | Chicago North      | PG-13  |    185 |           1|
|     349 | Gangs Pride        | PG-13  |    185 |           1|
|     690 | Pond Seattle       | PG-13  |    185 |           1|
|     817 | Soldiers Evolution | R      |    185 |           1|
|     426 | Home Pity          | R      |    185 |           1|
|     872 | Sweet Brotherhood  | R      |    185 |           1|
|     821 | Sorority Queen     | NC-17  |    184 |           1|
|     499 | King Evolution     | NC-17  |    184 |           1|
|     820 | Sons Interview     | NC-17  |    184 |           1|
|     198 | Crystal Breaking   | NC-17  |    184 |           1|

## Converting Subquery to CTE

Essentially a WITH statement performs the same task as a Subquery. Therefore, you can write any of the queries we worked with in the [examples_subquery](./02_examples_subquery.md) using a `WITH`.

1. Provide the `name` of the **sales_rep** in each **region** with the largest amount of **total_amt_usd** sales.

```SQL
SELECT t3.rep_name, t3.region_name, t3.total_amt
  FROM (SELECT region_name, MAX(total_amt) total_amt
          FROM (SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
                  FROM sales_reps s
                  JOIN accounts a
                    ON a.sales_rep_id = s.id
                  JOIN orders o
                    ON o.account_id = a.id
                  JOIN region r
                    ON r.id = s.region_id
                 GROUP BY 1, 2) t1
        GROUP BY 1) t2
  JOIN (SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
          FROM sales_reps s
          JOIN accounts a
            ON a.sales_rep_id = s.id
          JOIN orders o
            ON o.account_id = a.id
          JOIN region r
            ON r.id = s.region_id
         GROUP BY 1,2
         ORDER BY 3 DESC) t3
    ON t3.region_name = t2.region_name AND t3.total_amt = t2.total_amt;
```


**CTE**

```SQL
WITH t1 AS (
   SELECT s.name rep_name,
          r.name region_name,
          SUM(o.total_amt_usd) total_amt
     FROM sales_reps s
     JOIN accounts a
       ON a.sales_rep_id = s.id
     JOIN orders o
       ON o.account_id = a.id
     JOIN region r
       ON r.id = s.region_id
    GROUP BY 1,2
    ORDER BY 3 DESC),

t2 AS (
   SELECT region_name,
          MAX(total_amt) total_amt
     FROM t1
    GROUP BY 1)

SELECT t1.rep_name,
       t1.region_name,
       t1.total_amt
  FROM t1
  JOIN t2
    ON t1.region_name = t2.region_name AND
       t1.total_amt = t2.total_amt;
```

2. For the **region with the largest sales** `total_amt_usd`, how `many total orders` were placed?

```SQL
SELECT r.name, COUNT(o.total) total_orders
  FROM sales_reps s
  JOIN accounts a
    ON a.sales_rep_id = s.id
  JOIN orders o
    ON o.account_id = a.id
  JOIN region r
    ON r.id = s.region_id
 GROUP BY r.name
HAVING SUM(o.total_amt_usd) = (
      SELECT MAX(total_amt)
        FROM (SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
                FROM sales_reps s
                JOIN accounts a
                  ON a.sales_rep_id = s.id
                JOIN orders o
                  ON o.account_id = a.id
                JOIN region r
                  ON r.id = s.region_id
               GROUP BY r.name) sub);
```

**CTE**

```SQL
WITH t1 AS (
   SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
   FROM sales_reps s
   JOIN accounts a
   ON a.sales_rep_id = s.id
   JOIN orders o
   ON o.account_id = a.id
   JOIN region r
   ON r.id = s.region_id
   GROUP BY r.name),
t2 AS (
   SELECT MAX(total_amt)
   FROM t1)

SELECT r.name, COUNT(o.total) total_orders
  FROM sales_reps s
  JOIN accounts a
    ON a.sales_rep_id = s.id
  JOIN orders o
    ON o.account_id = a.id
  JOIN region r
    ON r.id = s.region_id
 GROUP BY r.name
HAVING SUM(o.total_amt_usd) = (SELECT * FROM t2);
```

3. **How many accounts** had more **total** purchases than the account **name** which has bought the most **standard_qty** paper throughout their lifetime as a customer?

```SQL
SELECT COUNT(*)
  FROM (SELECT a.name
          FROM orders o
          JOIN accounts a
            ON a.id = o.account_id
         GROUP BY 1
        HAVING SUM(o.total) >
               (SELECT total
                  FROM (SELECT a.name act_name, SUM(o.standard_qty) tot_std, SUM(o.total) total
                          FROM accounts a
                          JOIN orders o
                            ON o.account_id = a.id
                         GROUP BY 1
                         ORDER BY 2 DESC
                         LIMIT 1) inner_tab)
        ) counter_tab;
```

**CTE**

```SQL
WITH t1 AS (
  SELECT a.name account_name, SUM(o.standard_qty) total_std, SUM(o.total) total
    FROM accounts a
    JOIN orders o
      ON o.account_id = a.id
   GROUP BY 1
   ORDER BY 2 DESC
   LIMIT 1),
t2 AS (
  SELECT a.name
    FROM orders o
    JOIN accounts a
      ON a.id = o.account_id
   GROUP BY 1
  HAVING SUM(o.total) > (SELECT total FROM t1))

SELECT COUNT(*)
  FROM t2;
```

4. For the customer that spent the most (in total over their lifetime as a customer) **total_amt_usd**, how many **web_events** did they have for each channel?

```SQL
SELECT a.name, w.channel, COUNT(*)
  FROM accounts a
  JOIN web_events w
    ON a.id = w.account_id AND
       a.id =  (SELECT id
                  FROM (SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
                          FROM orders o
                          JOIN accounts a
                            ON a.id = o.account_id
                         GROUP BY a.id, a.name
                         ORDER BY 3 DESC
                         LIMIT 1) inner_table)
GROUP BY 1, 2
ORDER BY 3 DESC;
```

**CTE**

```SQL
WITH t1 AS (
   SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
   FROM orders o
   JOIN accounts a
   ON a.id = o.account_id
   GROUP BY a.id, a.name
   ORDER BY 3 DESC
   LIMIT 1)
SELECT a.name, w.channel, COUNT(*)
FROM accounts a
JOIN web_events w
ON a.id = w.account_id AND a.id =  (SELECT id FROM t1)
GROUP BY 1, 2
ORDER BY 3 DESC;
```

5. What is the lifetime average amount spent in terms of **total_amt_usd** for the top 10 total spending **accounts**?

```SQL
SELECT AVG(tot_spent)
  FROM (SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
          FROM orders o
          JOIN accounts a
            ON a.id = o.account_id
         GROUP BY a.id, a.name
         ORDER BY 3 DESC
         LIMIT 10) temp;
```

**CTE**

```SQL
WITH t1 AS (
   SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
     FROM orders o
     JOIN accounts a
       ON a.id = o.account_id
    GROUP BY a.id, a.name
    ORDER BY 3 DESC
    LIMIT 10)
SELECT AVG(tot_spent)
  FROM t1;
```

6. What is the lifetime average amount spent in terms of **total_amt_usd**, including only the companies that spent more per order, on average, than the average of all orders.

```SQL
SELECT AVG(avg_amt)
  FROM (SELECT o.account_id, AVG(o.total_amt_usd) avg_amt
          FROM orders o
         GROUP BY 1
        HAVING AVG(o.total_amt_usd) >
               (SELECT AVG(o.total_amt_usd) avg_all
                  FROM orders o)
        ) temp_table;
```

**CTE**

```SQL
WITH t1 AS (
   SELECT AVG(o.total_amt_usd) avg_all
   FROM orders o
   JOIN accounts a
   ON a.id = o.account_id),
t2 AS (
   SELECT o.account_id, AVG(o.total_amt_usd) avg_amt
     FROM orders o
    GROUP BY 1
   HAVING AVG(o.total_amt_usd) > (SELECT * FROM t1))

SELECT AVG(avg_amt)
  FROM t2; 
```
