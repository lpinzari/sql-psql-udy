# Symmetric Pairs

You are given a table, Functions, containing two columns: X and Y.

|Column|Type|
|:----:|:--:|
|X|Integer|
|Y|Integer|

Two pairs `(X1, Y1)` and `(X2, Y2)` are said to be symmetric pairs if `X1 = Y2` and `Y1 = X2`.

Write a query to **output all such symmetric pairs in ascending order** by the value of `X`. List the rows such that `X1 ≤ Y1`.

## Sample Input

|X|Y|
|:-:|:-:|
|20|20|
|20|20|
|20|21|
|23|22|
|22|23|
|21|20|

## Sample Output

```console
20 20
20 21
22 23
```

## Solution

```SQL
SELECT f1.x, f1.y
  FROM functions f1
 INNER JOIN functions f2
    ON f1.x = f2.y AND f1.y = f2.x
 GROUP BY f1.x, f1.y
HAVING COUNT(f1.x)>1 OR f1.x < f1.y
ORDER BY f1.x;  
```

The key is the HAVING line, with two conditions.

- The first condition in that line makes sure pairs with the same X and Y values don't get to count themselves as their symmetric pair. (e.g. if 10 10 appears one time it's not counted as a symmetric pair, but as 13 13 appears twice, that is a symmetric pair)

- The second condition ensures that only one of a pair is displayed. (e.g. if 3 24 and 24 3 form a symmetric pair, it will only display 3 24, not 24 3 as well.)
