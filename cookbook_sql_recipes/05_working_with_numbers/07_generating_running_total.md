# Generating a Running Total

You want to **calculate a running total of values in a column**.

## Solution

As an example, the following solutions show how to compute a `running total` of `salaries` for all employees. For readability, results are ordered by `SAL` whenever possible so that you can easily `eyeball` the progression of the running total.

```SQL
SELECT ename,
       sal,
       SUM(sal) OVER (ORDER BY sal, empno) AS running_total,
       SUM(sal) OVER () AS total
  FROM emp
 ORDER BY 2;
```

|ename  | sal  | running_total | total|
|:-----:|:----:|:-------------:|:----:|
|SMITH  |  800 |           800 | 29025|
|JAMES  |  950 |          1750 | 29025|
|ADAMS  | 1100 |          2850 | 29025|
|WARD   | 1250 |          4100 | 29025|
|MARTIN | 1250 |          5350 | 29025|
|MILLER | 1300 |          6650 | 29025|
|TURNER | 1500 |          8150 | 29025|
|ALLEN  | 1600 |          9750 | 29025|
|CLARK  | 2450 |         12200 | 29025|
|BLAKE  | 2850 |         15050 | 29025|
|JONES  | 2975 |         18025 | 29025|
|SCOTT  | 3000 |         21025 | 29025|
|FORD   | 3000 |         24025 | 29025|
|KING   | 5000 |         29025 | 29025|

**(14 rows)**

## Discussion

The `windowing` function `SUM OVER` makes **generating a running total** a simple task.

The `ORDER BY` clause in the solution includes not only the `SAL` column, but also the `EMPNO` column (**which is the primary key**) to `avoid duplicate values in the running total`.

The column `RT2` (RUNNING_TOTAL2) in the following example illustrates the **problem that you might otherwise have with duplicates**:

```SQL
SELECT empno,ename, sal,
       SUM(sal) OVER (ORDER BY sal,empno) AS rt1,
       SUM(sal) OVER (ORDER BY sal) AS rt2
  FROM emp
 ORDER BY 3;
```

|empno | ename  | sal  |  rt1  |  rt2|
|:----:|:------:|:----:|:-----:|:----:|
| 7369 | SMITH  |  800 |   800 |   800|
| 7900 | JAMES  |  950 |  1750 |  1750|
| 7876 | ADAMS  | 1100 |  2850 |  2850|
| 7521 | **WARD**   | `1250` |  **4100** |  **5350**|
| 7654 | **MARTIN** | `1250` |  **5350** |  **5350**|
| 7934 | MILLER | 1300 |  6650 |  6650|
| 7844 | TURNER | 1500 |  8150 |  8150|
| 7499 | ALLEN  | 1600 |  9750 |  9750|
| 7782 | CLARK  | 2450 | 12200 | 12200|
| 7698 | BLAKE  | 2850 | 15050 | 15050|
| 7566 | JONES  | 2975 | 18025 | 18025|
| 7788 | **SCOTT**  | `3000` | **21025** | **24025**|
| 7902 | **FORD**   | `3000` | **24025** | **24025**|
| 7839 | KING   | 5000 | 29025 | 29025|

The values in `RUNNING_TOTAL2` (**rt2**) for `WARD`, `MARTIN`, `SCOTT`, and `FORD` are incorrect. **Their salaries occur more than once, and those duplicates are summed and added to the running total**. This is why `EMPNO` (which is unique) is needed to produce the (correct) results that you see in `RUNNING_TOTAL1` (**rt1**).

Consider this: for `ADAMS` you see **2850** for `RUNNING_TOTAL1` and `RUNNING_TOTAL2`. Add `WARD’s` salary of `1250` to `2850` and you get `4100`, yet `RUNNING_TOTAL2` returns `5350`.

Why? Since `WARD` and `MARTIN` have the same `SAL`, their two `1250` salaries are added together to yield `2500`, which is then added to `2850` to arrive at `5350` for both `WARD` and `MARTIN`. By specifying a combination of columns to order by that cannot result in duplicate values (e.g., any combination of `SAL` and `EMPNO` is unique), you ensure the correct progression of the running total.

This is better illustrated in the diagram below:

```SQL
SELECT ename, sal  SELECT sal,        SELECT ename, sal,
  FROM emp                COUNT(sal),        SUM(sal) OVER (ORDER BY sal) AS rt2                     
                          SUM(sal)
 ORDER BY sal;       FROM emp          FROM emp
                    ORDER BY sal;     ORDER BY sal;
                    GROUP BY sal;
```

```console
+---------------+      +------------+       +----------+   +------+  
| ename  | sal  |      | COUNT(sal) |       | SUM(sal) |   | rt2  |
+--------+------+      +------------+       +----------+   +------+
| SMITH  |  800 |      +-----+              +-----+           
|--------|------+----> |  1  |  (1 * 800)   | 800 |        +-------+       
| JAMES  |  950 |      +-----+              +-----+------->| 800   |  
|--------|------+----> |  1  |  (1 * 950)   | 950 |        +-------+          
| ADAMS  | 1100 |      +-----+              +-----+------->| 1750  |  (800 + 950)
|--------|------+----> |  1  |  (1 * 1100)  | 1100|        +-------+
| WARD   | 1250 |      +-----+              +-----+------->| 2850  |  (1750 + 1100)
| MARTIN | 1250 |      +-----+              +-----+        +-------+
|--------|------+----> |  2  |  (2 * 1250)  | 2500|        +-------+  
| MILLER | 1300 |      +-----+              +-----+------->| 5350  |  (2850 + 2500)
|--------|------+----> |  1  |  (1 * 1300)  | 1300|        +-------+
| TURNER | 1500 |      +-----+              +-----+------->| 6650  |  (5350 + 1300)
|--------|------+----> |  1  |  (1 * 1500)  | 1500|        +-------+
| ALLEN  | 1600 |      +-----+              +-----+------->| 8150  |  (6650 + 1500)
|--------|------+----> |  1  |  (1 * 1600)  | 1600|        +-------+
| CLARK  | 2450 |      +-----+              +-----+------->| 9750  |  (8150 + 1600)
|--------|------+----> |  1  |  (1 * 2450)  | 2450|        +-------+
| BLAKE  | 2850 |      +-----+              +-----+------->| 12200 |  (9750 + 2450)
|--------|------+----> |  1  |  (1 * 2850)  | 2850|        +-------+
| JONES  | 2975 |      +-----+              +-----+------->| 15050 |  (12200 + 2850)
|--------|------+----> |  1  |  (1 * 2975)  | 2975|        +-------+
| FORD   | 3000 |      +-----+              +-----+------->| 18025 |  (15050 + 2975)
| SCOTT  | 3000 |      +-----+              +-----+        +-------+
|--------|------+----> |  2  |  (2 * 3000)  | 6000|        +-------+
| KING   | 5000 |      +-----+              +-----+------->| 24025 |  (18025 + 6000)
|--------|------+----> |  1  |  (1 * 5000)  | 5000|        +-------+
(14 rows)              +-----+              +-----+------->| 29025 |  (24025 + 5000)
                                                           +-------+
```
