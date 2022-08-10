# Counting Values in a Column

You want to `count the number of` **non-NULL values** `in a column`.

## Problem

```SQL
SELECT comm
  FROM emp
 ORDER BY comm;
```

|comm|
|:----:|
|   0|
| 300|
| 500|
|1400|
|NULL|
|NULL|
|NULL|
|NULL|
|NULL|
|NULL|
|NULL|
|NULL|
|NULL|
|NULL|

For example, you’d like to find out **how many** `employees` are on `commission`.

## Solution

Count the number of **non-NULL** values in the `EMP` table’s `COMM` column:

```SQL
SELECT COUNT(comm) count_comm
  FROM emp;
```

|count_comm|
|:--------:|
|         4|

## Discussion

When you “count star,” as in `COUNT(*)`, **what you are really counting is rows** (regardless of actual value, which is why rows containing NULL and non-NULL val‐ ues are counted).

But when you `COUNT a column`, **you are counting the number of** `non-NULL` values in that column. The previous recipe’s discussion touches on this distinction. In this solution, `COUNT(COMM)` returns the number of `non-NULL` values in the `COMM` column. Since only commissioned employees have commis‐ sions, the result of COUNT(COMM) is the number of such employees.
