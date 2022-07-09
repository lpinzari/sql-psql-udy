# PostgreSql EXTRACT

In the previous lesson we illustrated how to use the `DATE_TRUNC` function to aggregate information over an interval of time. The `DATE_TRUNC` function **rounds a TIMESTAMP value to a specified interval**, which allows you to count events or calculating aggregate information.

There are some cases where you might want to just pull out a given part of the date. The PostgreSQL **EXTRACT()** function retrieves a field such as a year, month, and day from a date/time value.

The following illustrates the syntax of the **EXTRACT()** function:

```SQL
EXTRACT(field FROM source)
```

## Arguments

The PostgreSQL EXTRACT() function requires two arguments:

1. `field`

The field argument specifies which field to extract from the date/time value.

The following table illustrates some of the valid field values:

|Field Value | TIMESTAMP|
|:-----------:|:--------:|
|CENTURY	|The century	|
|DAY|	The day of the month (1-31)|
|DOW|	The day of week Sunday (0) to Saturday (6)|
|DOY|	The day of year that ranges from 1 to 366|
|MINUTE|	The minute (0-59)|
|MONTH|	Month, 1-12|
|QUARTER|	Quarter of the year|
|WEEK|	The number of the ISO 8601 week-numbering week of the year|
|YEAR|	The year|

For a full list please refer to the following link [extract function](https://www.postgresqltutorial.com/postgresql-date-functions/postgresql-extract/).

2. `source`

The source is a value of type `TIMESTAMP` or INTERVAL. If you pass a DATE value, the function will cast it to a TIMESTAMP value.

## Return value

The **EXTRACT()** function returns a double precision value.

## PostgreSQL EXTRACT examples

The following example extracts year, month and day from a `TIMESTAMP`

```SQL
SELECT EXTRACT(YEAR FROM TIMESTAMP '2021-12-31 23:59:59');
SELECT EXTRACT(MONTH FROM TIMESTAMP '2021-12-31 23:59:59');
SELECT EXTRACT(DAY FROM TIMESTAMP '2021-12-31 23:59:59');
```

**Results**

- `2021-12-31 23:59:59`

|field|Output|
|:----:|:-----------------:|
|YEAR|2021|
|MONTH|12|
|DAY|31|

**EXTRACT** can be useful for pulling a specific portion of a date, but notice pulling month or day of the week (dow) means that **you are no longer keeping the years in order**. Rather you are grouping for certain components regardless of which year they belonged in.

For example, the following query calculates the total revenue of each paper type by year and month in 2014 and 2015.

```SQL
parch_posey=# SELECT DATE_TRUNC('month', occurred_at) AS date_month,
parch_posey-#        EXTRACT(MONTH FROM occurred_at) AS month,
parch_posey-#        SUM(standard_amt_usd) As standard_sales,
parch_posey-#        SUM(gloss_amt_usd) AS gloss_sales,
parch_posey-#        SUM(poster_amt_usd) AS poster_sales
parch_posey-#   FROM orders
parch_posey-#  WHERE occurred_at BETWEEN '2014-01-01' AND '2016-01-01'
parch_posey-#  GROUP BY 1,2
parch_posey-#  ORDER BY 1;
```

**Results**

|     date_month      | month | standard_sales | gloss_sales | poster_sales|
|:--------------------:|:----:|:--------------:|:-----------:|:-----------:|
| 2014-01-01 00:00:00 |     1 |      133452.56 |    97512.31 |     55175.40|
| 2014-02-01 00:00:00 |     2 |      142010.41 |   118918.73 |     88792.20|
| 2014-03-01 00:00:00 |     3 |      135553.35 |   115323.53 |     90635.44|
| 2014-04-01 00:00:00 |     4 |      131686.10 |   121914.73 |     91293.16|
| 2014-05-01 00:00:00 |     5 |      143572.28 |    96411.28 |     79226.84|
| 2014-06-01 00:00:00 |     6 |      140917.60 |    94441.41 |     62296.64|
| 2014-07-01 00:00:00 |     7 |      149076.25 |    87677.94 |     52374.00|
| 2014-08-01 00:00:00 |     8 |      150408.58 |   132925.03 |     83351.80|
| 2014-09-01 00:00:00 |     9 |      142524.38 |    81221.56 |     76222.44|
| 2014-10-01 00:00:00 |    10 |      186790.67 |   128887.92 |    179655.00|
| 2014-11-01 00:00:00 |    11 |      148677.05 |    97542.27 |     65674.56|
| 2014-12-01 00:00:00 |    12 |      161626.10 |   114222.50 |     91114.52|
| 2015-01-01 00:00:00 |     1 |      169635.05 |   112657.09 |     65512.16|
| 2015-02-01 00:00:00 |     2 |      156112.15 |    88337.06 |     89238.80|
| 2015-03-01 00:00:00 |     3 |      161666.02 |   268246.86 |     89490.52|
| 2015-04-01 00:00:00 |     4 |      166815.70 |   109196.71 |    175741.16|
| 2015-05-01 00:00:00 |     5 |      180408.46 |   127614.62 |     82807.76|
| 2015-06-01 00:00:00 |     6 |      179185.91 |   142924.18 |     98796.04|
| 2015-07-01 00:00:00 |     7 |      203083.02 |   151230.59 |    107581.88|
| 2015-08-01 00:00:00 |     8 |      186855.54 |   177355.71 |     99543.08|
| 2015-09-01 00:00:00 |     9 |      213137.87 |   211622.46 |     86088.24|
| 2015-10-01 00:00:00 |    10 |      245253.51 |   195444.06 |    113493.24|
| 2015-11-01 00:00:00 |    11 |      255313.35 |   190350.86 |    236430.04|
| 2015-12-01 00:00:00 |    12 |      266700.53 |   196769.79 |    151364.92|


Let's group the dates only by month.

```SQL
SELECT EXTRACT(month FROM occurred_at) AS month,
       SUM(standard_amt_usd) AS standard_sales,
       SUM(gloss_amt_usd) AS gloss_sales,
       SUM(poster_amt_usd) AS poster_sales
  FROM orders
 WHERE occurred_at BETWEEN '2014-01-01' AND '2016-01-01'
 GROUP BY 1
 ORDER BY 1;
```

**Results**

| month | standard_sales | gloss_sales | poster_sales|
|:-----:|:--------------:|:-----------:|:-----------:|
|     1 |      303087.61 |   210169.40 |    120687.56|
|     2 |      298122.56 |   207255.79 |    178031.00|
|     3 |      297219.37 |   383570.39 |    180125.96|
|     4 |      298501.80 |   231111.44 |    267034.32|
|     5 |      323980.74 |   224025.90 |    162034.60|
|     6 |      320103.51 |   237365.59 |    161092.68|
|     7 |      352159.27 |   238908.53 |    159955.88|
|     8 |      337264.12 |   310280.74 |    182894.88|
|     9 |      355662.25 |   292844.02 |    162310.68|
|    10 |      432044.18 |   324331.98 |    293148.24|
|    11 |      403990.40 |   287893.13 |    302104.60|
|    12 |      428326.63 |   310992.29 |    242479.44|

## EXERCISES

In the following exercises the `DATE_PART` function will be used in place of `EXTRACT`.

1. Find the sales in terms of total dollars for all orders in each year, ordered from greatest to least. Do you notice any trends in the yearly sales totals?

```SQL
SELECT DATE_PART('year', occurred_at) ord_year,  
       SUM(total_amt_usd) total_spent
  FROM orders
 GROUP BY 1
 ORDER BY 2 DESC;
```

**Results**

| ord_year | total_spent|
|:--------:|:----------:|
|     2016 | 12864917.92|
|     2015 |  5752004.94|
|     2014 |  4069106.54|
|     2013 |   377331.00|
|     2017 |    78151.43|

When we look at the yearly totals, you might notice that 2013 and 2017 have much smaller totals than all other years. If we look further at the monthly data, we see that for 2013 and 2017 there is only one month of sales for each of these years (12 for 2013 and 1 for 2017). Therefore, neither of these are evenly represented. Sales have been increasing year over year, with 2016 being the largest sales to date. At this rate, we might expect 2017 to have the largest sales.

2. Which month did Parch & Posey have the greatest sales in terms of total dollars? Are all months evenly represented by the dataset?

In order for this to be 'fair', we should remove the sales from 2013 and 2017. For the same reasons as discussed above.

```SQL
SELECT DATE_PART('month', occurred_at) ord_month,
       SUM(total_amt_usd) total_spent
  FROM orders
 WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01'
 GROUP BY 1
 ORDER BY 2 DESC;  
```

**Results**

|ord_month | total_spent|
|:---------:|:------------:|
|        12 |  2752080.98|
|        10 |  2427505.97|
|        11 |  2390033.75|
|         9 |  2017216.88|
|         7 |  1978731.15|
|         8 |  1918107.22|
|         6 |  1871118.52|
|         3 |  1659987.88|
|         4 |  1562037.74|
|         5 |  1537082.23|
|         2 |  1312616.64|
|         1 |  1259510.44|

The greatest sales amounts occur in December (12).
