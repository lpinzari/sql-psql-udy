# EXPLAIN

The **EXPLAIN** statement returns the **execution plan which PostgreSQL planner generates for a given statement**s.

The **EXPLAIN** shows how tables involved in a statement will be scanned by index scan or sequential scan, etc., and if multiple tables are used, what kind of join algorithm will be used.

The most important and useful information that the EXPLAIN statement returns are `start-cost` before the first row can be returned and the `total cost` to return the complete result set.

The following shows the syntax of the `EXPLAIN` statement:

```SQL
EXPLAIN [ ( option [, ...] ) ] sql_statement;
```

where `option` can be one of the following:

```SQL
ANALYZE [ boolean ]
VERBOSE [ boolean ]
COSTS [ boolean ]
BUFFERS [ boolean ]
TIMING [ boolean ]  
SUMMARY [ boolean ]
FORMAT { TEXT | XML | JSON | YAML }
```

The boolean specifies whether the selected option should be turned `on` or `off`. You can use `TRUE`, `ON`, or `1` **to enable the option**, and `FALSE`, `OFF`, or `0` to **disable it**. If you omit the boolean, it defaults to `ON`.

### ANALYZE

The `ANALYZE` option causes the sql_statement to be executed first and then actual run-time statistics in the returned information including total elapsed time expended within each plan node and the number of rows it actually returned.

The `ANALYZE` statement **actually executes the SQL statement and discards the output information**, therefore, if you want to analyze any statement such as `INSERT`, `UPDATE`, or `DELETE` **without affecting the data**, you should wrap the `EXPLAIN ANALYZE` in a **transaction**, as follows:

```SQL
BEGIN;
    EXPLAIN ANALYZE sql_statement;
ROLLBACK;
```

### VERBOSE

The `VERBOSE` parameter allows you to **show additional information regarding the plan**. This parameter sets to FALSE by default.

### COSTS

The `COSTS` option includes **the estimated startup and total costs of each plan node**, as well as **the estimated number of rows** and **the estimated width of each row in the query plan**. The `COSTS` defaults to `TRUE`.

### BUFFERS

This parameter adds information to the buffer usage. `BUFFERS` only can be used when `ANALYZE` is enabled. By default, the `BUFFERS` parameter set to `FALSE`.

### TIMING

This parameter includes **the actual startup time and time spent in each node in the output**. The `TIMING` defaults to `TRUE` and it may only be used when `ANALYZE` is enabled.

### SUMMARY

The `SUMMARY` parameter adds summary information such as **total timing** after the query plan. Note that when `ANALYZE` option is used, the summary information is included by default.

### FORMAT

Specify the output format of the query plan such as `TEXT`, `XML`, `JSON`, and `YAML`. This parameter is set to `TEXT` by default.

## PostgreSQL EXPLAIN examples

The following statement shows the plan for a simple query on the  `film` table:

```SQL
EXPLAIN SELECT * FROM film;
```
Here's the output:

```console
QUERY PLAN
----------------------------------------------------------
Seq Scan on film  (cost=0.00..64.00 rows=1000 width=384)
```

The following example shows the plan for a query that returns a film by a specific `film_id`.

```SQL
EXPLAIN SELECT * FROM film WHERE film_id = 100;
```

```console
QUERY PLAN
------------------------------------------------------------------------
Index Scan using film_pkey on film  (cost=0.28..8.29 rows=1 width=384)
Index Cond: (film_id = 100)
```

Because the `film_id` is indexed, the statement returned a different plan. In the output, the **planner used an** `index scan` instead of a `sequential scan` on the film table.

To suppress the cost, you can use the `COSTS` option:

```SQL
EXPLAIN (COSTS FALSE)
        SELECT *
          FROM film
         WHERE film_id = 100;
```

```console
QUERY PLAN
------------------------------------
Index Scan using film_pkey on film
Index Cond: (film_id = 100)
```

The following example displays the plan for a query that uses an `aggregate function`:

```SQL
EXPLAIN SELECT COUNT(*) FROM film;
```

```console
QUERY PLAN
--------------------------------------------------------------
Aggregate  (cost=66.50..66.51 rows=1 width=8)
->  Seq Scan on film  (cost=0.00..64.00 rows=1000 width=0)
```

The following example returns a plan for a statement that joins multiple tables:

```SQL
EXPLAIN
SELECT f.film_id,
       title,
       name category_name
  FROM film f
 INNER JOIN film_category fc
    ON fc.film_id = f.film_id
 INNER JOIN category c
    ON c.category_id = fc.category_id
 ORDER BY title;
```

```console
QUERY PLAN
--------------------------------------------------------------------------------------
Sort  (cost=149.64..152.14 rows=1000 width=87)
Sort Key: f.title
->  Hash Join  (cost=77.86..99.81 rows=1000 width=87)
Hash Cond: (fc.category_id = c.category_id)
->  Hash Join  (cost=76.50..95.14 rows=1000 width=21)
Hash Cond: (fc.film_id = f.film_id)
->  Seq Scan on film_category fc  (cost=0.00..16.00 rows=1000 width=4)
->  Hash  (cost=64.00..64.00 rows=1000 width=19)
->  Seq Scan on film f  (cost=0.00..64.00 rows=1000 width=19)
->  Hash  (cost=1.16..1.16 rows=16 width=72)
->  Seq Scan on category c  (cost=0.00..1.16 rows=16 width=72)
(11 rows)
```

To add the actual **runtime statistics to the output**, you need to execute the statement using the `ANALYZE` option:

```SQL
EXPLAIN ANALYZE
SELECT f.film_id,
       title,
       name category_name
  FROM film f
 INNER JOIN film_category fc
    ON fc.film_id = f.film_id
 INNER JOIN category c
    ON c.category_id = fc.category_id
 ORDER BY title;
```

```console
QUERY PLAN
-----------------------------------------------------------------------------------------------------------------------------------
Sort  (cost=149.64..152.14 rows=1000 width=87) (actual time=13.785..14.027 rows=1000 loops=1)
Sort Key: f.title
Sort Method: quicksort  Memory: 103kB
->  Hash Join  (cost=77.86..99.81 rows=1000 width=87) (actual time=5.486..9.457 rows=1000 loops=1)
Hash Cond: (fc.category_id = c.category_id)
->  Hash Join  (cost=76.50..95.14 rows=1000 width=21) (actual time=5.080..7.755 rows=1000 loops=1)
Hash Cond: (fc.film_id = f.film_id)
->  Seq Scan on film_category fc  (cost=0.00..16.00 rows=1000 width=4) (actual time=0.024..1.534 rows=1000 loops=1)
->  Hash  (cost=64.00..64.00 rows=1000 width=19) (actual time=4.914..4.915 rows=1000 loops=1)
Buckets: 1024  Batches: 1  Memory Usage: 59kB
->  Seq Scan on film f  (cost=0.00..64.00 rows=1000 width=19) (actual time=0.029..3.385 rows=1000 loops=1)
->  Hash  (cost=1.16..1.16 rows=16 width=72) (actual time=0.259..0.259 rows=16 loops=1)
Buckets: 1024  Batches: 1  Memory Usage: 9kB
->  Seq Scan on category c  (cost=0.00..1.16 rows=16 width=72) (actual time=0.034..0.238 rows=16 loops=1)
Planning Time: 1.959 ms
Execution Time: 14.355 ms
(16 rows)
```
