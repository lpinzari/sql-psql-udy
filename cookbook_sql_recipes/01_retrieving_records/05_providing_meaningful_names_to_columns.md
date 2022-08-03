# Providing Meaningful Names for Columns Problem

You would like to **change the names of the columns that are returned by your query** so they are more readable and understandable. Consider this query that returns the salaries and commissions for each employee:

```SQL
SELECT sal,
       comm
  FROM emp;
```

What’s `SAL`? Is it short for **sale**? Is it someone’s name? What’s `COMM`? Is it communication? You want the results to have more meaningful labels.

## Solution

To change the names of your query results, use the **AS** keyword in the form `original_name` **AS** `new_name`. Some databases do not require AS, but all accept it:

```SQL
SELECT sal AS salary,
       comm AS commission
  FROM emp;
```

**Output**

|salary | commission|
|:-----:|:----------:|
|   800 |      NULL;|
|  1600 |        300|
|  1250 |        500|
|  2975 |      NULL;|
|  1250 |       1400|
|  2850 |      NULL;|
|  2450 |      NULL;|
|  3000 |      NULL;|
|  5000 |      NULL;|
|  1500 |          0|
|  1100 |      NULL;|
|   950 |      NULL;|
|  3000 |      NULL;|
|  1300 |      NULL;|

**(14 rows)**

## Discussion

Using the **AS** keyword to give new names to columns returned by your query is known as `aliasing` those columns. The new names that you give are known as `aliases`.

Creating good aliases can go a long way toward making a query and its results understandable to others.
