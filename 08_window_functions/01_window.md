# WINDOW Function Examples

In the previous lesson we introduce the PostgreSQL `WINDOW` functions. The `WINDOW` functions allow to compare one row to another without doing any join: That means you want to do simple things like creating a **running total**, as well as tricky things like determine whether one row is greater than the previous row and classify it based on your finding.

The most practical example of `WINDOW` function is a **running total**. For example, let's say you want to calculate a **running total** of how much `standard paper`, Parch and Posey has sold to date.

```SQL
SELECT occurred_at, standard_qty,
       SUM (standard_qty) OVER (ORDER BY occurred_at) AS running_tot
  FROM orders
 LIMIT 10;
```

|     occurred_at     | standard_qty | running_tot|
|:-------------------:|:------------:|:-----------:|
| 2013-12-04 04:22:44 |            0 |           0|
| 2013-12-04 04:45:54 |          490 |         490|
| 2013-12-04 04:53:25 |          528 |        1018|
| 2013-12-05 20:29:16 |            0 |        1018|
| 2013-12-05 20:33:56 |          492 |        1510|
| 2013-12-06 02:13:20 |          502 |        2012|
| 2013-12-06 12:55:22 |           53 |        2065|
| 2013-12-06 12:57:41 |          308 |        2373|
| 2013-12-06 13:14:47 |           75 |        2448|
| 2013-12-06 13:17:25 |          281 |        2729|

You can see that this query creates an aggregation, `running_tot` , without using `GROUP BY`. Let's break down this syntax and see how it works.

The first part of this aggregation looks a lot like any other aggregation. Adding `OVER`, designates it as **WINDOW FUNCTION**.

You could read the above aggregation as `take the sum of standard quantity across all rows leading up to a given row in ORDER BY occurred_at`.

Let's say instead we want to start the `running total` over at the beginning of `each month` to narrow the `WINDOW` from the entire dataset to individual groups within a dataset, you use the `PARTITION BY` function.

```SQL
SELECT standard_qty,
       DATE_TRUNC('month',occurred_at) AS month,
       SUM (standard_qty) OVER (PARTITION BY DATE_TRUNC('month',occurred_at)
                                ORDER BY occurred_at) AS running_tot
  FROM orders;
```

**Result**

|standard_qty |        month        | running_tot|
|:------------:|:------------------:|:-----------:|
|           0 | 2013-12-01 00:00:00 |           0|
|         490 | 2013-12-01 00:00:00 |         490|
|         528 | 2013-12-01 00:00:00 |        1018|
|           0 | 2013-12-01 00:00:00 |        1018|
|         492 | 2013-12-01 00:00:00 |        1510|
|         502 | 2013-12-01 00:00:00 |        2012|
|          53 | 2013-12-01 00:00:00 |        2065|
|         308 | 2013-12-01 00:00:00 |        2373|
|          75 | 2013-12-01 00:00:00 |        2448|
|         281 | 2013-12-01 00:00:00 |        2729|
|          12 | 2013-12-01 00:00:00 |        2741|
|         461 | 2013-12-01 00:00:00 |        3202|
|         490 | 2013-12-01 00:00:00 |        3692|
|         ... | 2013-12-01 00:00:00 |        ...|
|119          | 2013-12-01 00:00:00 |       26069|
|          485 | `2013-12-01 00:00:00` |       **26554**|
|          515 | **2014-01-01 00:00:00** |         **515**|
|            0 | 2014-01-01 00:00:00 |         515|
|           37 | 2014-01-01 00:00:00 |         552|

Now this query groups and orders the query by the month in which the transaction occurred within each month. It's ordered by `occurred_at` and the `running total` sums across that current row and all previous rows of `standard_qty`. That's what happens when you group using `PARTITION BY`.

In case you are still stumped by the `ORDER BY`, it simply orders the designated columns the same way the `ORDER BY` clause would, except that it treats every partition as separate. It also creates the running total.

Without `ORDER BY`, each value will simply be a sum of all the `standard_qty` values in it's respective month. To gert a clearer picture, here's what happens when we run this query without `ORDER BY`.

```SQL
SELECT standard_qty,
       DATE_TRUNC('month',occurred_at) AS month,
       SUM (standard_qty) OVER (PARTITION BY DATE_TRUNC('month',occurred_at)
                                ) AS running_tot
  FROM orders;
```

**Result**

|standard_qty |        month        | running_tot|
|:-----------:|:--------------------:|:---------:|
|         497 | 2013-12-01 00:00:00 |       26554|
|         508 | 2013-12-01 00:00:00 |       26554|
|          84 | 2013-12-01 00:00:00 |       26554|
|           0 | 2013-12-01 00:00:00 |       26554|
|         304 | 2013-12-01 00:00:00 |       26554|
|         151 | 2013-12-01 00:00:00 |       26554|
|         353 | 2013-12-01 00:00:00 |       26554|
|         491 | 2013-12-01 00:00:00 |       26554|
|           0 | 2013-12-01 00:00:00 |       26554|
|         142 | 2013-12-01 00:00:00 |       26554|
|         485 | 2013-12-01 00:00:00 |       26554|
|         ... | 2013-12-01 00:00:00 |        ...|
|          485 | 2013-12-01 00:00:00 |       26554|

The `ORDER BY` and `PARTITION` defined what's referred to as the `WINDOW`. The ordered subset of data over which all these calculations are made.
