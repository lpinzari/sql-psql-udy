# Finding Outliers Using the Median Absolute Deviation

You want to **identify values in your data that may be suspect**. There are various reasons why values could be suspect:

- there could be a data collection issue, such as an error with the meter that records the value.
- There could be a data entry error such as a typo or similar.
- There could also be unusual circumstances when the data was generated that mean the data point is correct, but they still require you to use caution in any conclusion you make from the data.

## Problem

Therefore, you want to **detect outliers**.

```SQL
SELECT ename,
       job,
       sal
  FROM emp
 ORDER BY sal DESC;
```


| ename  |    job    | sal|
|:------:|:---------:|:----:|
| KING   | PRESIDENT | 5000|
| FORD   | ANALYST   | 3000|
| SCOTT  | ANALYST   | 3000|
| JONES  | MANAGER   | 2975|
| BLAKE  | MANAGER   | 2850|
| CLARK  | MANAGER   | 2450|
| ALLEN  | SALESMAN  | 1600|
| **TURNER** | **SALESMAN**  | **1500**|
| MILLER | CLERK     | 1300|
| MARTIN | SALESMAN  | 1250|
| WARD   | SALESMAN  | 1250|
| ADAMS  | CLERK     | 1100|
| JAMES  | CLERK     |  950|
| SMITH  | CLERK     |  800|

The Median salary is:

|median|
|:----:|
|  1550|



A common way to detect outliers, taught in many statistics courses aimed at `non- statisticians`, is to **calculate the standard deviation of the data and decide that data points more than two or three standard deviations from the mean (or some other similar distance) are outliers**.

However, this method can **misidentify outliers if the data don’t follow a normal distribution**, especially if `the spread of data isn’t symmetrical or doesn’t thin out in the same way as a normal distribution as you move further from the mean`.

## Solution


- **Using MAD**

First **find the median of the values** using the [recipe](./11_calculating_median.md) for finding the median. You will need to put this query into a **CTE** to make it available for further querying.

- MAD(x<sub>i</sub>) = median(|x<sub>i</sub> - median<sub>i</sub>(x<sub>i</sub>)|)

The **deviation** is the **absolute difference between the median and each value**; the **median absolute deviation is the median of this value**, so we need to calculate the median again.



**PostgreSQL and DB2**


```SQL
WITH median AS (
  SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY sal) AS median
    FROM emp
),
devtab  AS (
  SELECT ABS(e.sal - m.median) AS deviation
    FROM emp e, median m
),
medAbsDeviation AS (
  SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY deviation) AS mad
    FROM devtab
)
SELECT ROUND(CAST (ABS(e.sal - md.mad)/(md.mad*1.0) AS NUMERIC),4) AS mmd,
       md.mad,
       e.sal,
       e.ename,
       e.job
  FROM emp e, medAbsDeviation md
 ORDER BY mmd DESC;
```

|mmd   | sal  | ename  |    job|
|:-----:|:----:|:------:|:--------:|
|6.4074 | 5000 | KING   | PRESIDENT|
|3.4444 | 3000 | FORD   | ANALYST|
|3.4444 | 3000 | SCOTT  | ANALYST|
|3.4074 | 2975 | JONES  | MANAGER|
|3.2222 | 2850 | BLAKE  | MANAGER|
|2.6296 | 2450 | CLARK  | MANAGER|
|1.3704 | 1600 | ALLEN  | SALESMAN|
|1.2222 | 1500 | TURNER | SALESMAN|
|0.9259 | 1300 | MILLER | CLERK|
|0.8519 | 1250 | MARTIN | SALESMAN|
|0.8519 | 1250 | WARD   | SALESMAN|
|0.6296 | 1100 | ADAMS  | CLERK|
|0.4074 |  950 | JAMES  | CLERK|
|0.1852 |  800 | SMITH  | CLERK|

## Discussion

In each case the recipe follows a similar strategy.
- First we need to calculate the **median**,
- and then we need to calculate **the median of the difference between each value and the median**, which is the actual **median absolute deviation (MAD)**.
- Finally, **put those deviations in terms of the MAD**: we need to use a query to find the ratio of the deviation of each value to the median deviation.

At that point, we can use the outcome in a similar way to the standard deviation. For example, **if a value is three or more deviations from the MAD**, it can be considered an `outlier`, to use a common interpretation.

As mentioned earlier, the benefit of this approach over the standard deviation is that the interpretation is still valid even if the data doesn’t display a normal distribution. For example, it can be lopsided, and the median absolute deviation will still give a sound answer.

```SQL
WITH median AS (
  SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY sal) AS median
    FROM emp
),
devtab  AS (
  SELECT ABS(e.sal - m.median) AS deviation
    FROM emp e, median m
)
SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY deviation) AS mad
  FROM devtab;
```

|mad|
|:--:|
| 675|

```SQL
WITH median AS (
  SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY sal) AS median
    FROM emp
),
devtab  AS (
  SELECT ABS(e.sal - m.median) AS deviation
    FROM emp e, median m
),
medAbsDeviation AS (
  SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY deviation) AS mad
    FROM devtab
)
SELECT ROUND(CAST (ABS(e.sal - md.mad)/(md.mad*1.0) AS NUMERIC),4) AS mmd,
       md.mad,
       e.sal,
       e.ename,
       e.job
  FROM emp e, medAbsDeviation md
 ORDER BY mmd DESC;
```

```console
|mmd   | sal  | ename  |    job|
|:-----:|:----:|:------:|:--------:|
|6.4074 | 5000 | KING   | PRESIDENT|<-----| |5000 - 675|/(675*1.0) = 6.4074
|3.4444 | 3000 | FORD   | ANALYST|
|3.4444 | 3000 | SCOTT  | ANALYST|
|3.4074 | 2975 | JONES  | MANAGER|
|3.2222 | 2850 | BLAKE  | MANAGER|<--------| |2850 - 675|/(675*1.0) = 3.2222
|2.6296 | 2450 | CLARK  | MANAGER|
|1.3704 | 1600 | ALLEN  | SALESMAN|
|1.2222 | 1500 | TURNER | SALESMAN|
|0.9259 | 1300 | MILLER | CLERK|
|0.8519 | 1250 | MARTIN | SALESMAN|
|0.8519 | 1250 | WARD   | SALESMAN|
|0.6296 | 1100 | ADAMS  | CLERK|
|0.4074 |  950 | JAMES  | CLERK|
|0.1852 |  800 | SMITH  | CLERK|
<-----------------------------------| 675
```


In our salary data, there is one salary that is more than three absolute deviations from the median: the **CEO’s**.


Although there are differing opinions about the fairness of CEO salaries versus those of most other workers, given that the outlier salary belongs to the CEO, it fits with our understanding of the data. In other contexts, if there wasn’t a clear explanation of why the value differed so much, it could lead us to question whether that value was correct or whether the value made sense when taken with the rest of the values (e.g., if it not actually an error, it might make us think we need to analyze our data within more than one subgroup).

## Note

Many of the common statistics, such as the `mean` and the `standard deviation`, **assume that the shape of the data is a bell curve** — a **normal distribution**. This is true for many data sets, and also not true for many data sets.

There are a number of methods for testing whether a data set follows a normal distribution, both by visualizing the data and through calculations. Statistical packages commonly contain functions for these tests, but they are nonexistent and hard to replicate in SQL.

However, there are often `alternative statistical tools` that **don’t assume the data takes a particular form—nonparametric statistics** — and these are **safer to use**.
