# Shifting Row Values

You want to return each employee’s `name` and `salary` along with the **next highest and lowest salaries**.

If there are no higher or lower salaries, you want the results to wrap (first `SAL` shows last `SAL` and vice versa).

You want to return the following result set:

## Solution

The window functions `LEAD OVER` and `LAG OVER` make this problem easy to solve and the resulting queries very readable. Use the window functions `LAG OVER` and `LEAD OVER` to access prior and next rows relative to the current row:


```SQL
SELECT ename, sal,
       COALESCE(LEAD(sal) OVER (ORDER BY sal),MIN(sal) OVER()) AS forward,
       COALESCE(LAG(sal) OVER (ORDER BY sal),MAX(sal) OVER()) AS rewind
  FROM emp
 ORDER BY sal;
```

## Discussion

The window functions `LAG OVER` and `LEAD OVER` will (by default and unless otherwise specified) **return values** from the `row before` and `after` the **current row**, respectively.

You define what “**before**” or “**after**” means in the `ORDER BY` portion of the `OVER` clause. If you examine the solution, the first step is to return the next and prior rows relative to the current row, ordered by `SAL`:

```SQL
SELECT ename, sal,
       LEAD(sal) OVER (ORDER BY sal) AS forward,
       LAG(sal) OVER (ORDER BY sal) AS rewind
  FROM emp
 ORDER BY sal;
```

|ename  | sal  | forward | rewind|
|:-----:|:----:|:------:|:-------:|
|SMITH  |  800 |     950 ||
|JAMES  |  950 |    1100 |    800|
|ADAMS  | 1100 |    1250 |    950|
|WARD   | 1250 |    1250 |   1100|
|MARTIN | 1250 |    1300 |   1250|
|MILLER | 1300 |    1500 |   1250|
|TURNER | 1500 |    1600 |   1300|
|ALLEN  | 1600 |    2450 |   1500|
|CLARK  | 2450 |    2850 |   1600|
|BLAKE  | 2850 |    2975 |   2450|
|JONES  | 2975 |    3000 |   2850|
|FORD   | 3000 |    3000 |   2975|
|SCOTT  | 3000 |    5000 |   3000|
|KING   | 5000 |         |   3000|

Notice that `REWIND` is `NULL` for employee **SMITH**, and `FORWARD` is `NULL` for employee **KING**; that is because those two employees have the lowest and highest salaries, respectively.

The requirement in the “Problem” section should `NULL` values exist in FORWARD or REWIND is to “**wrap**” the results, **meaning that for the highest** `SAL`, `FORWARD` should be the value of the **lowest SAL** in the table, and for the **lowest SAL**, `REWIND` should be the value of the **highest SAL in the table**.


```SQL
SELECT ename, sal,
       COALESCE(LEAD(sal) OVER (ORDER BY sal),MIN(sal) OVER()) AS forward,
       COALESCE(LAG(sal) OVER (ORDER BY sal),MAX(sal) OVER()) AS rewind
  FROM emp
 ORDER BY sal;
```

The window functions `MIN OVER` and `MAX OVER` with no partition or window specified (i.e., an empty parentheses after the `OVER` clause) **will return the lowest and highest salaries in the table**, respectively. The results are shown here:

|ename  | sal  | forward | rewind|
|:----:|:-----:|:-------:|:-----:|
|SMITH  |  800 |     950 |   5000|
|JAMES  |  950 |    1100 |    800|
|ADAMS  | 1100 |    1250 |    950|
|WARD   | 1250 |    1250 |   1100|
|MARTIN | 1250 |    1300 |   1250|
|MILLER | 1300 |    1500 |   1250|
|TURNER | 1500 |    1600 |   1300|
|ALLEN  | 1600 |    2450 |   1500|
|CLARK  | 2450 |    2850 |   1600|
|BLAKE  | 2850 |    2975 |   2450|
|JONES  | 2975 |    3000 |   2850|
|FORD   | 3000 |    3000 |   2975|
|SCOTT  | 3000 |    5000 |   3000|
|KING   | 5000 |     800 |   3000|

Another useful feature of LAG OVER and LEAD OVER is the ability to define how far forward or back you would like to go. In the example for this recipe, you go only one row forward or back. If want to move three rows forward and five rows back, doing so is simple. Just specify the values 3 and 5,
