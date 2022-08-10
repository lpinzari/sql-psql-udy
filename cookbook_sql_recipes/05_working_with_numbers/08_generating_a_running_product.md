# Generating a Running Product Problem

You want to compute a **running product on a numeric column**. The operation is similar to [generating running total](./07_generating_running_total.md), but using multiplication instead of addition.

## Solution

By way of example, the solutions all compute running products of employee `salaries`. While a running product of salaries may not be all that useful, the technique can easily be applied to other, more useful domains.

Use the **windowing function** `SUM OVER` and take advantage of the fact that **you can simulate multiplication by adding logarithms**:

```SQL
SELECT empno,ename,sal,
       EXP(SUM(LN(sal)) OVER (ORDER BY sal,empno)) AS running_prod
  FROM emp
 WHERE deptno = 10;
```

|empno | ename  | sal  | running_prod|
|:----:|:------:|:----:|:-----------:|
| 7934 | MILLER | 1300 |         1300|
| 7782 | CLARK  | 2450 |      3185000|
| 7839 | KING   | 5000 |  15925000000|

It is **not valid in SQL** (or, formally speaking, in mathematics) to compute **logarithms of values less than or equal to zero**. If you have such values in your tables, you need to avoid passing those invalid values to SQL’s LN function.

Precautions against invalid values and `NULLs` are not provided in this solution for the sake of readability, but you should consider whether to place such precautions in production code that you write. If you absolutely must work with negative and zero values, then this solution may not work for you.

```SQL
WITH emp_no_zero AS (
  SELECT empno, ename, deptno,
         CASE WHEN sal = 0 THEN 1 ELSE sal END AS sal
    FROM emp
)

SELECT empno,ename,sal,
       EXP(SUM(LN(sal)) OVER (ORDER BY sal,empno)) AS running_prod
  FROM emp_no_zero
 WHERE deptno = 10;
```

At the same time, if you have zeros (but no values below zero), a common workaround is to replace all zero values to 1, noting that the logarithm of 1 is always zero regardless of base.

## Discussion

SQL does not have an aggregate function for multiplication; the standard work-around for this is to use logarithms, as follows: since
- **log(ab) = log a + log b**, we can calculate
- **ab = exp(loga + log b)** this generalizes to more than two values.

Thus,

```SQL
SELECT EXP(SUM(LOG(col)))
  FROM table;
```
will give us the product of the values of column or attribute `col`. 

The solution takes advantage of the fact that you can multiply two numbers by:

1. Computing their respective natural logarithms
2. Summing those logarithms
3. Raising the result to the power of the mathematical constant `e` (using the `EXP` function)

```SQL
SELECT EXP(LN(1300)) AS prod_1,
       EXP(LN(1300)+LN(2450)) AS prod_2,
       EXP(LN(1300)+LN(2450)+LN(5000)) AS prod_3;
```

```SQL
SELECT 1300 AS prod_1,
       (1300*2450) AS prod_2,
       (1300*2450*5000) AS prod_3;
```

|prod_1 | prod_2  |   prod_3|
|:-----:|:-------:|:----------:|
|  1300 | 3185000 | 15925000000|

The one caveat when using this approach is that it doesn’t work for summing zero or negative values, because any value less than or equal to zero is out of range for an SQL logarithm.
