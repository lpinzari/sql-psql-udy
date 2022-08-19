# Paginating Through a Result Set

You want to **paginate** or “**scroll through**” a result set.

For example, you want to return the
- first five salaries from table EMP,
- then the next five,
- and so forth.

Your goal is to `allow a user to view five records at a time`, **scrolling forward** with `each click` of a `Next button`.

## Solution

Because there is no concept of first, last, or next in SQL, you must impose order on the rows you are working with. Only by **imposing order can you accurately return ranges of records**.

- Use the window function `ROW_NUMBER OVER` **to impose order**, and
- specify the window of records that you want returned in your `WHERE` clause.

```SQL
SELECT ename, sal
  FROM emp
 ORDER BY sal;
```

| ename  | sal|
|:------:|:-----:|
| SMITH  |  800|
| JAMES  |  950|
| ADAMS  | 1100|
| WARD   | 1250|
| MARTIN | 1250|
| MILLER | 1300|
| TURNER | 1500|
| ALLEN  | 1600|
| CLARK  | 2450|
| BLAKE  | 2850|
| JONES  | 2975|
| FORD   | 3000|
| SCOTT  | 3000|
| KING   | 5000|

```SQL
SELECT ROW_NUMBER() OVER (ORDER BY sal) AS rn,
       ename, sal
  FROM emp
 ORDER BY sal;
```

The window function `ROW_NUMBER OVER` will assign a unique number to each salary (in increasing order starting from 1).

|rn | ename  | sal|
|:--:|:-----:|:---:|
| 1 | SMITH  |  800|
| 2 | JAMES  |  950|
| 3 | ADAMS  | 1100|
| 4 | WARD   | 1250|
| 5 | MARTIN | 1250|
| 6 | MILLER | 1300|
| 7 | TURNER | 1500|
| 8 | ALLEN  | 1600|
| 9 | CLARK  | 2450|
|10 | BLAKE  | 2850|
|11 | JONES  | 2975|
|12 | FORD   | 3000|
|13 | SCOTT  | 3000|
|14 | KING   | 5000|

Once a number has been assigned to a salary, simply pick the range you want to return by specifying values for RN.

For example, use this to return rows 1 through 5:

```SQL
WITH sal_page AS (
  SELECT ROW_NUMBER() OVER (ORDER BY sal) AS rn,
         ename, sal
    FROM emp
)
SELECT *
  FROM sal_page
 WHERE rn BETWEEN 1 AND 5
 ORDER BY sal;
```

|rn | ename  | sal|
|:-:|:------:|:----:|
| 1 | SMITH  |  800|
| 2 | JAMES  |  950|
| 3 | ADAMS  | 1100|
| 4 | WARD   | 1250|
| 5 | MARTIN | 1250|

Alternatively use the `LIMIT` option to return the first n records.

```SQL
SELECT ename, sal
  FROM emp
 ORDER BY sal
 LIMIT 5;
```

|ename  | sal|
|:-----:|:----:|
|SMITH  |  800|
|JAMES  |  950|
|ADAMS  | 1100|
|WARD   | 1250|
|MARTIN | 1250|

Then use this to return rows 6 through 10:

```SQL
WITH sal_page AS (
  SELECT ROW_NUMBER() OVER (ORDER BY sal) AS rn,
         ename, sal
    FROM emp
)
SELECT *
  FROM sal_page
 WHERE rn BETWEEN 6 AND 10
 ORDER BY sal;
```

|rn | ename  | sal|
|:-:|:------:|:---:|
| 6 | MILLER | 1300|
| 7 | TURNER | 1500|
| 8 | ALLEN  | 1600|
| 9 | CLARK  | 2450|
|10 | BLAKE  | 2850|

```SQL
SELECT ename, sal
  FROM emp
 ORDER BY sal
 OFFSET 5 ROWS
 FETCH FIRST 5 ROW ONLY;
```

|ename  | sal|
|:------:|:-----:|
|MILLER | 1300|
|TURNER | 1500|
|ALLEN  | 1600|
|CLARK  | 2450|
|BLAKE  | 2850|
