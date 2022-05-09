# Between and AND in a WHERE exercises

We’ll use the `accounts`, `orders` and `web_events` tables in the `parch_posey` sample database for the demonstration.

1. **Problem**: Write a query that returns all the orders where the standard_qty is over 1000, the poster_qty is 0, and the gloss_qty is 0.

```SQL
SELECT *
  FROM orders
 WHERE standard_qty > 1000 AND
       poster_qty = 0 AND
       gloss_qty = 0;
```

2. **Problem**: Using the accounts table, find all the companies whose names do not start with 'C' and end with 's'.

```SQL
SELECT name
  FROM accounts
 WHERE name NOT LIKE 'C%' AND
       name LIKE '%s';
```

3. **Problem**: Find all the information about the web events advertised on the organic and adwords channel in 2016.

```SQL
SELECT *
  FROM web_events
 WHERE channel IN ('organic', 'adwords') AND
       occurred_at BETWEEN '2016-01-01' AND '2017-01-01'
 ORDER BY occurred_at DESC;
```

You will notice that using BETWEEN is tricky for dates! While BETWEEN is generally inclusive of endpoints, it assumes the time is at 00:00:00 (i.e. midnight) for dates. This is the reason why we set the right-side endpoint of the period at '2017-01-01'.
