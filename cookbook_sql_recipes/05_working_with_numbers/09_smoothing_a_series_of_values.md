# Smoothing a Series of Values 

You have a series of values that appear over time, such as `monthly` **sales figures**. As is common, the `data` **shows a lot of variation from point to point**, but you are interested in the `overall trend`.

Therefore, you want to implement a **simple smoother**, such as **weighted running average** to better identify the trend.

## Problem

Imagine you have **daily sales totals**, in dollars, such as from a newsstand:

```SQL
CREATE TABLE sales (
  id INTEGER PRIMARY KEY,
  date1 DATE,
  sales NUMERIC(7,2)
);

INSERT INTO sales
       (id, date1, sales)
VALUES (1,'2020-01-01',647.00),
       (2,'2020-01-02',561.00),
       (3,'2020-01-03',741.00),
       (4,'2020-01-04',978.00),
       (5,'2020-01-05',1062.00),
       (6,'2020-01-06',1072.00),
       (7,'2020-01-07',805.00),
       (8,'2020-01-08',662.00),
       (9,'2020-01-09',1083.00),
       (10,'2020-01-10',970.00);
```

|id |   date1    | sales|
|:-:|:----------:|:----:|
| 1 | 2020-01-01 |   647.00|
| 2 | 2020-01-02 |   561.00|
| 3 | 2020-01-03 |   741.00|
| 4 | 2020-01-04 |   978.00|
| 5 | 2020-01-05 |  1062.00|
| 6 | 2020-01-06 |  1072.00|
| 7 | 2020-01-07 |   805.00|
| 8 | 2020-01-08 |   662.00|
| 9 | 2020-01-09 |  1083.00|
|10 | 2020-01-10 |   970.00|

However, you know that there is **volatility to the sales data that makes it difficult to discern an underlying trend**.

`Possibly different days of the week` or `month` are known to have especially **high** or **low** sales. Alternatively, maybe you are aware that due to the way the data is collected, sometimes sales for one day are moved into the next day, creating a trough followed by a peak, but there is no practical way to allocate the sales to their correct day.

Therefore, you need to **smooth the data over a number of days** to achieve a proper view of what’s happening.

A **moving average** can be calculated by **summing the current value** and **the preceding** `n-1` **values** and **dividing by** `n`. If you also display the previous values for reference, you expect something like this:


|date1    |  sales  | saleslagone | saleslagtwo | movingaverage|
|:---------:|:-------:|:-----------:|:-----------:|:-------------:|
|2020-01-01 |  647.00 |        NULL |        NULL |          NULL|
|2020-01-02 |  561.00 |      647.00 |        NULL |          NULL|
|2020-01-03 |  741.00 |      561.00 |      647.00 |        649.67|
|2020-01-04 |  978.00 |      741.00 |      561.00 |        760.00|
|2020-01-05 | 1062.00 |      978.00 |      741.00 |        927.00|
|2020-01-06 | 1072.00 |     1062.00 |      978.00 |       1037.33|
|2020-01-07 |  805.00 |     1072.00 |     1062.00 |        979.67|
|2020-01-08 |  662.00 |      805.00 |     1072.00 |        846.33|
|2020-01-09 | 1083.00 |      662.00 |      805.00 |        850.00|
|2020-01-10 |  970.00 |     1083.00 |      662.00 |        905.00|


**first**

|date1    |  sales  | saleslagone | saleslagtwo | movingaverage|
|:---------:|:-------:|:-----------:|:-----------:|:-------------:|
|2020-01-01 |  647.00 |        NULL |        NULL |          NULL|

**second**

|date1    |  sales  | saleslagone | saleslagtwo | movingaverage|
|:---------:|:-------:|:-----------:|:-----------:|:-------------:|
|2020-01-01 |  647.00 |        NULL |        NULL |          NULL|
|2020-01-02 |  561.00 |      647.00 |        NULL |          NULL|

**third: First window**

|date1    |  sales  | saleslagone | saleslagtwo | movingaverage|
|:---------:|:-------:|:-----------:|:-----------:|:-------------:|
|2020-01-01 |  `647.00` |        NULL |        NULL |          NULL|
|2020-01-02 |  `561.00` |      647.00 |        NULL |          NULL|
|2020-01-03 |  **741.00** |      `561.00` |      `647.00` |        649.67|

**Second Wind**

|date1    |  sales  | saleslagone | saleslagtwo | movingaverage|
|:---------:|:-------:|:-----------:|:-----------:|:-------------:|
|2020-01-02 |  `561.00` |      647.00 |        NULL |          NULL|
|2020-01-03 |  `741.00` |      561.00 |      647.00 |        649.67|
|2020-01-04 |  **978.00** |      `741.00` |      `561.00` |        760.00|

**Third window**

|date1    |  sales  | saleslagone | saleslagtwo | movingaverage|
|:---------:|:-------:|:-----------:|:-----------:|:-------------:|
|2020-01-03 |  `741.00` |      561.00 |      647.00 |        649.67|
|2020-01-04 |  `978.00` |      741.00 |      561.00 |        760.00|
|2020-01-05 | **1062.00** |      `978.00` |      `741.00` |        927.00|

And so on ..

## Solution

The formula for the mean is well known. By applying a simple weighting to the formula, we can make it more relevant for this task by giving more weight to more recent values. Use the window function [LAG](https://github.com/lpinzari/sql-psql-udy/blob/master/08_window_functions/06_lag.md) to create a moving average:

```SQL
SELECT date1,
       sales,
       LAG(sales,1) OVER (ORDER BY date1) AS salesLagOne,
       LAG(sales,2) OVER (ORDER BY date1) AS salesLagTwo,
       ROUND((sales +
         (LAG(sales,1) OVER (ORDER BY date1)) +
         (LAG(sales,2) OVER (ORDER BY date1))
       )/3,2) AS MovingAverage
  FROM sales;
```

## Discussion

A **weighted moving average** is one of the simplest ways to analyze **time-series** data (data that appears at particular time intervals). This is just one way to calculate a simple moving average—you can also use a partition with average. Although we have selected a simple `three-point moving average`, there are different formulas with differing numbers of points according to the characteristics of the data.

For example, a simple `three-point weighted moving average` that **emphasizes the most recent data point** could be implemented with the following variant on the solution, where `coefficients` and the `denominator` have been updated:

```SQL
SELECT date1,
       sales,
       LAG(sales,1) OVER (ORDER BY date1) AS salesLagOne,
       LAG(sales,2) OVER (ORDER BY date1) AS salesLagTwo,
       ROUND((3 * sales +
         (2 * LAG(sales,1) OVER (ORDER BY date1)) +
         (LAG(sales,2) OVER (ORDER BY date1))
       )/6,2) AS MovingAverage
  FROM sales;
```
