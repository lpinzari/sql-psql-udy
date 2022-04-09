# ORDER BY clause

The order of the records within a table has no significance to SQL.  **When records are retrieved from a table**, therefore, **the order in which they appear is arbitrary**. So, When you query data from a table, **the** `SELECT` **statement returns rows in an unspecified order**.

Yet sometimes we wish to see the data resulting from a query ordered in a specific way. To allow this, SQL provides the `ORDER BY` clause for the `SELECT` statement.

**To sort the rows of the result set**, you use the `ORDER BY` clause in the SELECT statement.

The general form of a `SELECT` **statement using** `ORDER BY` is:

```console
SELECT <column names>
  FROM <table>
  ORDER BY <column names>;
```

As before, `<column names>` after `SELECT` and `<table>` indicate the columns that should be selected from the named table. Most importantly for our purposes, the `<column names>` following `ORDER BY` indicate the column(s) whose values should be used to order the selected records. The default order is **ascending order** or `ASC`.

SQL also allows records to be listed in **reverse order** or **descending order**.

```console
SELECT <column names>
  FROM <table>
  ORDER BY <column names> DESC;
```

The **query diagram** for `ORDER BY` is shows the selected table with a **box indicating the column on which the ordering is based**. If two or more columns are used, both are included in the `ORDER BY` box.

## Ordering Data example

Imagine yourself in the finance department at Parch & Posey. You want to look up the **most recent** orders, so that you can confirm that invoices have been sent to those customers.

The `ORDER BY` clause will help you to accomplish this by **allowing you to sort the orders by date**.

Let's first take a look at how data is ordered by default.

```console
parch_posey=# SELECT id,
parch_posey-#        account_id,
parch_posey-#        occurred_at
parch_posey-#   FROM orders
parch_posey-#   LIMIT 20;

id | account_id |     occurred_at
----+------------+---------------------
  1 |       1001 | 2015-10-06 17:31:14
  2 |       1001 | 2015-11-05 03:34:33
  3 |       1001 | 2015-12-04 04:21:55
  4 |       1001 | 2016-01-02 01:18:24
  5 |       1001 | 2016-02-01 19:27:27
  6 |       1001 | 2016-03-02 15:29:32
  7 |       1001 | 2016-04-01 11:20:18
  8 |       1001 | 2016-05-01 15:55:51
  9 |       1001 | 2016-05-31 21:22:48
 10 |       1001 | 2016-06-30 12:32:05
 11 |       1001 | 2016-07-30 03:26:30
 12 |       1001 | 2016-08-28 07:13:39
 13 |       1001 | 2016-09-26 23:28:25
 14 |       1001 | 2016-10-26 20:31:30
 15 |       1001 | 2016-11-25 23:21:32
 16 |       1001 | 2016-12-24 05:53:13
 17 |       1011 | 2016-12-21 10:59:34
 18 |       1021 | 2015-10-12 02:21:56
 19 |       1021 | 2015-11-11 07:37:01
 20 |       1021 | 2015-12-11 16:53:18
(20 rows)
```

You'll notice that this table `appears` to be sorted by `account_id`. It starts at 1001 and goes to 1011, 1021 ... However, the order of the rows in the table has no significance to SQL.

Let's add an `ORDER BY` clause to **reorder** the results **based on the date the order was placed**, which you can see in the `occurred_at` column.

```console
SELECT account_id,
       occurred_at
  FROM orders
  ORDER BY occurred_at
  LIMIT 20;
```

Notice that the `ORSER BY` clause goes between the `FROM` and `LIMIT` clauses. Remember the `ORDER BY` **must appear after** `FROM` **and before** `LIMIT` **clauses**. **You must write the clauses in this order, or the query will not run**.

![12 orderby](./images/12_orderby.png)


```console
parch_posey=# SELECT account_id,
parch_posey-#        occurred_at
parch_posey-#   FROM orders
parch_posey-#   ORDER BY occurred_at
parch_posey-#   LIMIT 20;
 account_id |     occurred_at
------------+---------------------
       2861 | 2013-12-04 04:22:44
       2861 | 2013-12-04 04:45:54
       4311 | 2013-12-04 04:53:25
       1281 | 2013-12-05 20:29:16
       1281 | 2013-12-05 20:33:56
       2481 | 2013-12-06 02:13:20
       3431 | 2013-12-06 12:55:22
       3431 | 2013-12-06 12:57:41
       3251 | 2013-12-06 13:14:47
       3251 | 2013-12-06 13:17:25
       3491 | 2013-12-06 23:45:16
       3491 | 2013-12-06 23:47:45
       2731 | 2013-12-08 00:54:42
       4491 | 2013-12-08 06:34:23
       1301 | 2013-12-08 07:05:07
       1301 | 2013-12-08 07:11:38
       1881 | 2013-12-08 18:24:52
       1881 | 2013-12-08 18:32:52
       3141 | 2013-12-08 20:13:49
       3141 | 2013-12-08 20:37:53
(20 rows)
```

By the **default**, `ORDER BY` goes from:

- `a` to `z`, **Ascending alphabetical order**.
- `lowest` to `highest`, **Ascending numerical order**.
- `earliest` to `latest`, **Ascending date order**.

This is referred to as **ascending** order. You'll notice that that's happening in the result of our last query. The **earliest date** is `2013-12-04 04:22:44` and the client `2861` is the first client that placed an order.

If you want to order the other way, you can add `DESC` option, short for **descending**, to the **end of the** `ORDER BY` clause. This will get us the data set that we're after, which **shows the 10 most recent orders** with the most recent at the top.

```console
SELECT account_id,
parch_posey-#        occurred_at
parch_posey-#   FROM orders
parch_posey-#   ORDER BY occurred_at DESC
parch_posey-#   LIMIT 10;
```

![13 orderby](./images/13_orderby.png)

```console
parch_posey=# SELECT account_id,
parch_posey-#        occurred_at
parch_posey-#   FROM orders
parch_posey-#   ORDER BY occurred_at DESC
parch_posey-#   LIMIT 10;
 account_id |     occurred_at
------------+---------------------
       3841 | 2017-01-02 00:02:40
       3841 | 2017-01-01 23:50:16
       3861 | 2017-01-01 22:29:50
       3861 | 2017-01-01 22:17:26
       4051 | 2017-01-01 21:04:25
       4051 | 2017-01-01 20:52:23
       1761 | 2017-01-01 17:34:10
       1961 | 2017-01-01 16:40:57
       3431 | 2017-01-01 14:05:39
       3431 | 2017-01-01 13:57:21
(10 rows)
```
The last order was placed the `2017-01-02 00:02:40`.

## Summary

The `ORDER BY` statement **allows us to sort our results using the data in any column**. If you are familiar with *Excel* or *Google Sheets*, using `ORDER BY` is similar to sorting a sheet using a column. A key difference, however, is that **using ORDER BY in a SQL query only has temporary effects**, for the results of that query, unlike sorting a sheet by column in Excel or Sheets.

In other words, when you use ORDER BY in a SQL query, your output will be sorted that way, but then the next query you run will encounter the unsorted data again. It's important to keep in mind that this is different than using common spreadsheet software, where sorting the spreadsheet by column actually alters the data in that sheet until you undo or change that sorting. This highlights the meaning and function of a SQL "query."

The **ORDER BY** statement always comes in a query after the **SELECT** and **FROM** statements, but before the **LIMIT** statement.

If you are using the **LIMIT** statement, it **will always appear last**. As you learn additional commands, the order of these statements will matter more.

Remember `DESC` can be added after the column in your `ORDER BY` statement to sort in descending order, as the default is to sort in ascending order.

## Exercises

1. Write a query to return the **10 earliest** `orders` in the orders table. Include the `id`, `occurred_at`, and `total_amt_usd`.

```console
SELECT id,
       occurred_at,
       total_amt_usd
  FROM orders
  ORDER BY occurred_at
  LIMIT 10;
```

2. Write a query to return **the top 5** `orders` in terms of largest `total_amt_usd`. Include the `id`, `account_id`, and `total_amt_usd`.

```console
SELECT id,
       account_id,
       total_amt_usd
  FROM orders
  ORDER BY total_amt_usd DESC
  LIMIT 5;
```

3. Write a query to return **the lowest 20** `orders` in terms of smallest `total_amt_usd`. Include the `id`, `account_id`, and `total_amt_usd`.

```console
SELECT id,
       account_id,
       total_amt_usd
  FROM orders
  ORDER BY total_amt_usd
  LIMIT 20;
```


## Additional Resources

- [ODER BY](https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-order-by/)
