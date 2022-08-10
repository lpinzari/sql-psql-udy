# Finding Anomalies Using Benford’s Law

Although outliers, as shown in the previous [recipe](./17_finding_outliers_using_median_absolute_deviation.md), are a readily identifiable form of anomalous data, some other data is less easy to identify as problematic.

One way to detect situations where there are anomalous data but no obvious outliers is to look at the **frequency of digits**, which is usually expected to follow `Benford’s law`.

Although using `Benford’s` **law is most often associated with detecting fraud** in situations where `humans have added fake numbers to a data set`, it can be used more generally **to detect data that doesn’t follow expected patterns**.

For example, it can detect errors such as `duplicated data points`, which won’t necessarily stand out as outliers.

**Benford's law**, also called the **first-digit law**, refers to the frequency distribution of digits in many (but not all) real-life sources of data.

In this distribution, the number `1` occurs as the first digit about `30%` of the time, while larger numbers occur in that position less frequently: `9` as the first digit less than `5%` of the time. This distribution of first digits is the same as the widths of gridlines on a logarithmic scale.

Benford's law also concerns the expected distribution for digits beyond the first, which approach a uniform distribution.

This result has been found to apply to a wide variety of data sets, including electricity bills, street addresses, stock prices, population numbers, death rates, lengths of rivers, physical and mathematical constants, and processes described by power laws (which are very common in nature). It tends to be most accurate when values are distributed across multiple orders of magnitude.


A set of numbers is said to satisfy Benford's law if the leading digit `d = {1,2,3,4,5,6,7,8,9}` occurs with probability:

- **P(d) = log<sub>10</sub>(d+1) - log<sub>10</sub>(d) = log<sub>10</sub>(1+1/d)**

For this task, write (a) routine(s) to calculate the distribution of first significant (non-zero) digits in a collection of numbers, then display the actual vs. expected distribution.

To use Benford’s law, you need to **calculate the expected distribution of digits** and then **the actual distribution to compare**.

Although the most sophisticated uses look at first, second, and combinations of digits, in this example we will stick to just the `first digits`.

Use the following data set:

```SQL
SELECT LEFT(CAST(sal AS CHAR),1) as first_digit
  FROM emp;
```

|first_digit|
|:---------:|
|8|
|1|
|1|
|2|
|1|
|2|
|2|
|3|
|5|
|1|
|1|
|9|
|3|
|1|

You compare the frequency predicted by Benford’s law with the actual frequency of your data. Ultimately you want four columns:

- the first digit,
- the count of how many times each first digit appears,
- the frequency of first digits predicted by Benford’s law, and
- the actual frequency.

## Solution

To use Benford’s law, you need to **calculate the expected distribution of digits** and then **the actual distribution to compare**.



```SQL
WITH firstDigits AS (
  SELECT LEFT(CAST(sal AS CHAR),1) AS first_digit
    FROM emp
),
totalCount AS (
  SELECT COUNT(*) AS total
    FROM emp
),
expectedBenford AS (
  SELECT CAST(id AS CHAR) AS digit,
         (LOG(id + 1) - LOG(id)) AS expected
    FROM t10
   WHERE id < 10
)
SELECT eb.digit,
       COUNT(first_digit),
       ROUND(CAST(eb.expected AS NUMERIC),2),
       ROUND(CAST(COALESCE(COUNT(*)/(total*1.0),0) AS NUMERIC),2) AS actual_proportion
  FROM firstDigits
  JOIN totalCount ON 1=1
 RIGHT JOIN expectedBenford eb ON  firstDigits.first_digit = eb.digit
 GROUP BY digit, expected, total
 ORDER BY digit;
```

|digit | count | round | actual_proportion|
|:----:|:-----:|:-----:|:----------------:|
|1     |     6 |  0.30 |              0.43|
|2     |     3 |  0.18 |              0.21|
|3     |     2 |  0.12 |              0.14|
|4     |     **0** |  0.10 |              0.00|
|5     |     1 |  0.08 |              0.07|
|6     |     **0** |  0.07 |              0.00|
|7     |     **0** |  0.06 |              0.00|
|8     |     1 |  0.05 |              0.07|
|9     |     1 |  0.05 |              0.07|

Because we need to make use of two different counts—one of the total rows, and another of the number of rows containing each different first digit—we need to use a CTE.

Strictly speaking, we don’t need to put the expected Benford’s law results into a separate query within the CTE, but we have done so in this case as it allows us to identify the digits with a zero count and display them in the table via the right join.

It’s also possible to produce the FirstDigits count in the main query, but we have chosen not to improve readability through not needing to repeat the LEFT(CAST... expression in the GROUP BY clause.

The math behind Benford’s law is simple:

- **P(d) = log<sub>10</sub>(d+1) - log<sub>10</sub>(d) = log<sub>10</sub>(1+1/d)**

We can use the `T10` pivot table to generate the appropriate values. From there we just need to calculate the actual frequencies for comparison, which first requires us to identify the first digit.

Benford’s law works best when there is a relatively large collection of values to apply it to, and when those values span more than one order of magnitude (10, 100, 1,000, etc.). Those conditions aren’t entirely met here. At the same time, the deviation from expected should still make us suspicious that these values are in some sense made-up values and worth investigating further.
