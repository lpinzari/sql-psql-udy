# A Framing Finale

As a final example of the effect of the framing clause on query output, consider the following query:

```SQL
SELECT ename,
       sal,
       MIN(sal) OVER(ORDER BY sal) min1,
       MAX(sal) OVER(ORDER BY sal) max1,
       MIN(sal) OVER(ORDER BY sal
                        RANGE BETWEEN UNBOUNDED PRECEDING
                          AND UNBOUNDED FOLLOWING) min2,
       MAX(sal) OVER(ORDER BY sal
                        RANGE BETWEEN UNBOUNDED PRECEDING
                          AND UNBOUNDED FOLLOWING) max2,
       MIN(sal) OVER(ORDER BY sal
                        RANGE BETWEEN CURRENT ROW
                          AND CURRENT ROW) min3,
       MAX(sal) OVER(ORDER BY sal
                        RANGE BETWEEN CURRENT ROW
                          AND CURRENT ROW) max3,
       MAX(sal) OVER(ORDER BY sal
                         ROWS BETWEEN 3 PRECEDING
                          AND 3 FOLLOWING) max4
 FROM emp;
```

|ename  | sal  | min1 | max1 | min2 | max2 | min3 | max3 | max4|
|:-----:|:----:|:----:|:----:|:----:|:----:|:----:|:-----:|:----:|
|SMITH  |  800 |  800 |  800 |  800 | 5000 |  800 |  800 | 1250|
|JAMES  |  950 |  800 |  950 |  800 | 5000 |  950 |  950 | 1250|
|ADAMS  | 1100 |  800 | 1100 |  800 | 5000 | 1100 | 1100 | 1300|
|WARD   | 1250 |  800 | 1250 |  800 | 5000 | 1250 | 1250 | 1500|
|MARTIN | 1250 |  800 | 1250 |  800 | 5000 | 1250 | 1250 | 1600|
|MILLER | 1300 |  800 | 1300 |  800 | 5000 | 1300 | 1300 | 2450|
|TURNER | 1500 |  800 | 1500 |  800 | 5000 | 1500 | 1500 | 2850|
|ALLEN  | 1600 |  800 | 1600 |  800 | 5000 | 1600 | 1600 | 2975|
|CLARK  | 2450 |  800 | 2450 |  800 | 5000 | 2450 | 2450 | 3000|
|BLAKE  | 2850 |  800 | 2850 |  800 | 5000 | 2850 | 2850 | 3000|
|JONES  | 2975 |  800 | 2975 |  800 | 5000 | 2975 | 2975 | 5000|
|FORD   | 3000 |  800 | 3000 |  800 | 5000 | 3000 | 3000 | 5000|
|SCOTT  | 3000 |  800 | 3000 |  800 | 5000 | 3000 | 3000 | 5000|
|KING   | 5000 |  800 | 5000 |  800 | 5000 | 5000 | 5000 | 5000|

OK, let’s break this query down:


- **MIN1**

```console
MIN(sal) OVER(ORDER BY sal) min1,
```

The window function generating this column does not specify a framing clause, so the default framing clause of `UNBOUNDED PRECEDING AND CURRENT ROW` kicks in. Why is `MIN1` **800** for all rows? **It’s because the lowest salary comes first** (`ORDER BY SAL`), **and it remains the lowest, or minimum, salary forever after**.

- **MAX1**

```console
MAX(sal) OVER(ORDER BY sal) max1,
```

The values for `MAX1` are much different from those for `MIN1`. Why? The answer (again) is the default framing clause `UNBOUNDED PRECEDING AND CURRENT ROW`. In conjunction with `ORDER BY SAL`, **this framing clause ensures that the maximum salary will also correspond to that of the current row**.

Consider the first row, for `SMITH`. When evaluating `SMITH’s` salary and all prior salaries, `MAX1` for `SMITH` is `SMITH’s` salary, because there are no prior salaries. Moving on to the next row, `JAMES`, when comparing `JAMES’s` salary to all prior salaries, in this case comparing to the salary of SMITH, JAMES’s salary is the
higher of the two, and thus it is the maximum. If you apply this logic to all rows, you will see that the value of `MAX1` for each row **is the current employee’s salary**.

- **MIN2** and **MAX2**:

```console
MIN(sal) OVER(ORDER BY sal
                 RANGE BETWEEN UNBOUNDED PRECEDING
                   AND UNBOUNDED FOLLOWING) min2,
MAX(sal) OVER(ORDER BY sal
                 RANGE BETWEEN UNBOUNDED PRECEDING
                   AND UNBOUNDED FOLLOWING) max2,
```

The framing clause given for these is `UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING`, which **is the same as specifying empty parentheses**.`OVER ()` Thus, all rows in the result set are considered when computing `MIN` and `MAX`. As you might expect, the `MIN` and `MAX` values for the entire result set are **constant**, and thus the value of these columns is constant as well.

- **MIN3** and **MAX3**:

```console
MIN(sal) OVER(ORDER BY sal
                 RANGE BETWEEN CURRENT ROW
                   AND CURRENT ROW) min3,
MAX(sal) OVER(ORDER BY sal
                 RANGE BETWEEN CURRENT ROW
                   AND CURRENT ROW) max3,
```

The framing clause for these is `CURRENT ROW AND CURRENT ROW`, **which simply means use only the current employee’s salary when looking for the** `MIN` and `MAX` salary. Thus, both `MIN3` and `MAX3` **are the same as** `SAL` for each row. That was easy, wasn’t it?

- **MAX4**:

```console
MAX(sal) OVER(ORDER BY sal
                  ROWS BETWEEN 3 PRECEDING
                   AND 3 FOLLOWING) max4
```

The framing clause defined for `MAX4` is `3 PRECEDING AND 3 FOLLOWING`, which means, for every row, **consider the three rows prior** `and` **the three rows after the current row**, `as well as` **the current row itself**. This particular invocation of `MAX(SAL)` will return from those rows the highest salary value.


|ename  | sal  | min1 | max1 | min2 | max2 | min3 | max3 | max4|
|:-----:|:----:|:----:|:----:|:----:|:----:|:----:|:-----:|:----:|
|SMITH  |  800 |  800 |  800 |  800 | 5000 |  800 |  800 | 1250|
|JAMES  |  **950** |  800 |  950 |  800 | 5000 |  950 |  950 | 1250|
|ADAMS  | **1100** |  800 | 1100 |  800 | 5000 | 1100 | 1100 | 1300|
|WARD   | **1250** |  800 | 1250 |  800 | 5000 | 1250 | 1250 | 1500|
|**MARTIN** | **1250** |  800 | 1250 |  800 | 5000 | 1250 | 1250 | 1600|
|MILLER | **1300** |  800 | 1300 |  800 | 5000 | 1300 | 1300 | 2450|
|TURNER | **1500** |  800 | 1500 |  800 | 5000 | 1500 | 1500 | 2850|
|ALLEN  | **1600** |  800 | 1600 |  800 | 5000 | 1600 | 1600 | 2975|

- MAX(950,1100,1250,1250,1300,1500,1600) = 1600.

If you look at the value of `MAX4` for employee `MARTIN`, you can see how the framing clause is applied. `MARTIN’s` salary is **1250**, and the three employee salaries prior to `MARTIN’s` are `WARD’s` (**1250**), `ADAMS’s` (**1100**) and `JAMES’s` (**950**). The three employee salaries after `MARTIN’s` are `MILLER’s` (**1300**), `TURNER’s` (**1500**), and `ALLEN’s` (**1600**). Out of all those salaries, including MARTIN’s, the highest is `ALLEN’s`, and thus the value of `MAX4` for `MARTIN` is `1600`.
