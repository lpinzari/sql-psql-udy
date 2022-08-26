# Pivoting a Ranked Result Set

You want to
- **rank the values in a table** and then
- **pivot the result set** into `three columns`.

The idea is to show the `top three`, the `next three`, and then `all the rest`.

## Problem

For example, you want to rank the employees in table `EMP` by `SAL` and then **pivot the results into three columns**.

```SQL
SELECT ename, sal
  FROM emp
 ORDER BY sal DESC;  
```

```console
|ename  | sal|
|:-----:|:---:|
|KING   | 5000|
|FORD   | 3000|
|SCOTT  | 3000|  FIRST THREE SALARIES
|JONES  | 2975|
-------------------
|BLAKE  | 2850|
|CLARK  | 2450|  NEXT THREE
|ALLEN  | 1600|
--------------------
|TURNER | 1500|
|MILLER | 1300|
|MARTIN | 1250|  REST OF SALARIES
|WARD   | 1250|
|ADAMS  | 1100|
|JAMES  |  950|
|SMITH  |  800|
```

The desired result set is as follows:

|top_3     |    next_3    |     rest|
|:-----------:|:------------:|:-----------:|
|KING  (5000) | BLAKE (2850) | TURNER(1500)|
|FORD  (3000) | CLARK (2450) | MILLER(1300)|
|SCOTT (3000) | ALLEN (1600) | MARTIN(1250)|
|JONES (2975) |              | WARD  (1250)|
|          |              | ADAMS (1100)|
|          |              | JAMES (950)|
|          |              | SMITH (800)|


## Solution

The key to this solution is to first use the window function `DENSE_RANK OVER` to rank the employees by `SAL` while **allowing for ties**. By using `DENSE_RANK OVER`, you can easily see the top three salaries, the next three salaries, and then all the rest.

Next, use the window function `ROW_NUMBER OVER` to **rank each employee within their group** (the `top three`, `next three`, or `last group`).

Finally, simply perform a `classic transpose`, while using the built-in string functions available on your platform to beautify the results.

```SQL
WITH x AS (
  SELECT ename, sal,
         DENSE_RANK() OVER(ORDER BY sal DESC) AS rnk
    FROM emp  
),
y AS (
  SELECT ename,
         sal,
         CASE WHEN rnk <= 3 THEN 1
              WHEN rnk <= 6 THEN 2
              ELSE 3
         END AS grp
    FROM x
),
z AS (
  SELECT CASE grp WHEN 1 THEN (RPAD(ename,6) || '(' || sal || ')') END AS top_3,
         CASE grp WHEN 2 THEN (RPAD(ename,6) || '(' || sal || ')') END AS next_3,
         CASE grp WHEN 3 THEN (RPAD(ename,6) || '(' || sal || ')') END AS rest,
         grp,
         ROW_NUMBER() OVER(PARTITION BY grp ORDER BY sal DESC, ename) AS grp_rnk
    FROM y
)
SELECT MAX(top_3) AS top_3,
       MAX(next_3) AS next_3,
       MAX(rest) AS rest
  FROM z
 GROUP BY grp_rnk
 ORDER BY grp_rnk;
```

## Discussion


This recipe is a perfect example of how much you can accomplish with so little, with the help of window functions. The solution may look involved, but as you break it down from inside out, you will be surprised how simple it is.


```SQL
SELECT ename, sal,
       DENSE_RANK() OVER(ORDER BY sal DESC) AS rnk
  FROM emp;
```

|ename  | sal  | rnk|
|:-----:|:----:|:---:|
|KING   | 5000 |   1|
|FORD   | 3000 |   2|
|SCOTT  | 3000 |   2|
|JONES  | 2975 |   3|
|BLAKE  | 2850 |   4|
|CLARK  | 2450 |   5|
|ALLEN  | 1600 |   6|
|TURNER | 1500 |   7|
|MILLER | 1300 |   8|
|MARTIN | 1250 |   9|
|WARD   | 1250 |   9|
|ADAMS  | 1100 |  10|
|JAMES  |  950 |  11|
|SMITH  |  800 |  12|

As you can see from the previous result set, the `DENSE_RANK` window function simply ranks the employees by `SAL`, **while allowing for ties** (because the solution uses `DENSE_RANK` instead of `RANK`, **there are ties without gaps**).

```SQL
WITH x AS (
  SELECT ename, sal,
         DENSE_RANK() OVER(ORDER BY sal DESC) AS rnk
    FROM emp  
)
SELECT ename,
       sal,
       CASE WHEN rnk <= 3 THEN 1
            WHEN rnk <= 6 THEN 2
            ELSE 3
       END AS grp
  FROM x
 ORDER BY grp,sal DESC;
```

The next step is to take the rows from CTE `X` and create groups by using a `CASE` expression to evaluate the ranking from `DENSE_RANK`.

|ename  | sal  | grp|
|:-----:|:----:|:---:|
|KING   | 5000 |   1|
|FORD   | 3000 |   1|
|SCOTT  | 3000 |   1|
|JONES  | 2975 |   1|
|BLAKE  | 2850 |   2|
|CLARK  | 2450 |   2|
|ALLEN  | 1600 |   2|
|TURNER | 1500 |   3|
|MILLER | 1300 |   3|
|MARTIN | 1250 |   3|
|WARD   | 1250 |   3|
|ADAMS  | 1100 |   3|
|JAMES  |  950 |   3|
|SMITH  |  800 |   3|


```SQL
WITH x AS (
  SELECT ename, sal,
         DENSE_RANK() OVER(ORDER BY sal DESC) AS rnk
    FROM emp  
),
y AS (
  SELECT ename,
         sal,
         CASE WHEN rnk <= 3 THEN 1
              WHEN rnk <= 6 THEN 2
              ELSE 3
         END AS grp
    FROM x
)
SELECT y.*,
       ROW_NUMBER() OVER(PARTITION BY grp ORDER BY sal DESC, ename) AS grp_rnk
  FROM y
 ORDER BY grp,sal DESC;
```

Use the window function `ROW_NUMBER OVER` to rank the employees by `SAL` within their group (within the group you are creating with the `CASE` expression).

|ename  | sal  | grp | grp_rnk|
|:-----:|:----:|:---:|:--:|
|KING   | 5000 |   1 |   1|
|FORD   | 3000 |   1 |   2|
|SCOTT  | 3000 |   1 |   3|
|JONES  | 2975 |   1 |   4|
|BLAKE  | 2850 |   2 |   1|
|CLARK  | 2450 |   2 |   2|
|ALLEN  | 1600 |   2 |   3|
|TURNER | 1500 |   3 |   1|
|MILLER | 1300 |   3 |   2|
|MARTIN | 1250 |   3 |   3|
|WARD   | 1250 |   3 |   4|
|ADAMS  | 1100 |   3 |   5|
|JAMES  |  950 |   3 |   6|
|SMITH  |  800 |   3 |   7|

Now the query is starting to take shape, and if you followed it from the beginning you can see that it’s not that complicated. The query so far returns each employee; their `SAL`; their `RNK`, which represents where their `SAL` ranks among all employees; their `GRP`, which indicates the group each employee is in (based on SAL); and finally `GRP_RANK`, which is a ranking (based on `SAL`) within their `GRP`.

```SQL
WITH x AS (
  SELECT ename, sal,
         DENSE_RANK() OVER(ORDER BY sal DESC) AS rnk
    FROM emp  
),
y AS (
  SELECT ename,
         sal,
         CASE WHEN rnk <= 3 THEN 1
              WHEN rnk <= 6 THEN 2
              ELSE 3
         END AS grp
    FROM x
),
z AS (
  SELECT y.*,
         ROW_NUMBER() OVER(PARTITION BY grp ORDER BY sal DESC, ename) AS grp_rnk
    FROM y
)
SELECT CASE grp WHEN 1 THEN (RPAD(ename,6) || '(' || sal || ')') END AS top_3,
       CASE grp WHEN 2 THEN (RPAD(ename,6) || '(' || sal || ')') END AS next_3,
       CASE grp WHEN 3 THEN (RPAD(ename,6) || '(' || sal || ')') END AS rest
  FROM z
  ORDER BY grp, grp_rnk;
```

|top_3     |    next_3    |     rest|
|:------------:|:--------------:|:-------------:|
|KING  (5000) |              ||
|FORD  (3000) |              ||
|SCOTT (3000) |              ||
|JONES (2975) |              ||
|          | BLAKE (2850) ||
|          | CLARK (2450) ||
|          | ALLEN (1600) ||
|          |              | TURNER(1500)|
|          |              | MILLER(1300)|
|          |              | MARTIN(1250)|
|          |              | WARD  (1250)|
|          |              | ADAMS (1100)|
|          |              | JAMES (950)|
|          |              | SMITH (800)|

At this point, perform a `traditional pivot` on `ENAME` while using the concatenation operator `||` to append the `SAL`. The function `RPAD` ensures that the numeric values in parentheses line up nicely. Finally, use `GROUP BY` on `GRP_RNK` to ensure you show each employee in the result set. The final result set is shown here:

```SQL
WITH x AS (
  SELECT ename, sal,
         DENSE_RANK() OVER(ORDER BY sal DESC) AS rnk
    FROM emp  
),
y AS (
  SELECT ename,
         sal,
         CASE WHEN rnk <= 3 THEN 1
              WHEN rnk <= 6 THEN 2
              ELSE 3
         END AS grp
    FROM x
),
z AS (
  SELECT CASE grp WHEN 1 THEN (RPAD(ename,6) || '(' || sal || ')') END AS top_3,
         CASE grp WHEN 2 THEN (RPAD(ename,6) || '(' || sal || ')') END AS next_3,
         CASE grp WHEN 3 THEN (RPAD(ename,6) || '(' || sal || ')') END AS rest,
         grp,
         ROW_NUMBER() OVER(PARTITION BY grp ORDER BY sal DESC, ename) AS grp_rnk
    FROM y
)
SELECT grp_rnk,
       MAX(top_3) AS top_3,
       MAX(next_3) AS next_3,
       MAX(rest) AS rest
  FROM z
 GROUP BY grp_rnk
 ORDER BY grp_rnk;
```

|grp_rnk |    top_3     |    next_3    |     rest|
|:------:|:------------:|:------------:|:-----------:|
|      1 | KING  (5000) | BLAKE (2850) | TURNER(1500)|
|      2 | FORD  (3000) | CLARK (2450) | MILLER(1300)|
|      3 | SCOTT (3000) | ALLEN (1600) | MARTIN(1250)|
|      4 | JONES (2975) |              | WARD  (1250)|
|      5 |              |              | ADAMS (1100)|
|      6 |              |              | JAMES (950)|
|      7 |              |              | SMITH (800)|
