# Ranking Results

You want to **rank the salaries** in table `EMP` while allowing for **ties**. You want to return the following result set:

|rnk | sal|
|:--:|:---:|
|  1 |  800|
|  2 |  950|
|  3 | 1100|
|  4 | 1250|
|  4 | 1250|
|  5 | 1300|
|  6 | 1500|
|  7 | 1600|
|  8 | 2450|
|  9 | 2850|
| 10 | 2975|
| 11 | 3000|
| 11 | 3000|
| 12 | 5000|


## Solution

Window functions make ranking queries extremely simple. Three window functions are particularly useful for **ranking**:

- `DENSE_RANK OVER`,
- `ROW_NUMBER OVER`, and
- `RANK OVER`.

Because you want to **allow for ties**, rows with the same values must have the same rank number, use the window function `DENSE_RANK OVER`:

```SQL
SELECT DENSE_RANK() OVER (ORDER BY sal) rnk, sal
  FROM emp;
```

## Discussion

The window function `DENSE_RANK OVER` does all the legwork here. In parentheses following the `OVER` keyword you place an `ORDER BY` clause **to specify the order in which rows are ranked**. The solution uses `ORDER BY SAL`, so rows from `EMP` **are ranked in ascending order of salary**.
