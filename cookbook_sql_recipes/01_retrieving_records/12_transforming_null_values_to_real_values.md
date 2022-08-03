# Transforming Nulls into Real Values Problem

You have rows that contain nulls and **would like to return non-null values in place of those nulls**.

## Solution

Use the function [COALESCE](https://github.com/lpinzari/sql-psql-udy/blob/master/07_data_cleaning/10_coalesce.md) to substitute real values for nulls:

```SQL
SELECT comm, COALESCE(comm,0) AS not_null
  FROM emp;
```

|comm  | not_null|
|:-----:|:-------:|
|NULL; |        0|
|  300 |      300|
|  500 |      500|
|NULL; |        0|
| 1400 |     1400|
|NULL; |        0|
|NULL; |        0|
|NULL; |        0|
|NULL; |        0|
|    0 |        0|
|NULL; |        0|
|NULL; |        0|
|NULL; |        0|
|NULL; |        0|

## Discussion

The **COALESCE** function takes one or more values as arguments. The function **returns the first non-null value in the list**. In the solution, the value of COMM is returned whenever `COMM` is not null. Otherwise, a `zero` is returned.

When working with nulls, it’s best to take advantage of the built-in functionality provided by your DBMS; in many cases you’ll find several functions work equally as well for this task. **COALESCE** happens to work for all DBMSs. Additionally, `CASE` can be used for all DBMSs as well:

```SQL
SELECT CASE
           WHEN comm IS NOT NULL THEN comm
           ELSE 0
           END
  FROM emp;
```

While you can use `CASE` to translate nulls into values, you can see that it’s much easier and more succinct to use `COALESCE`.
