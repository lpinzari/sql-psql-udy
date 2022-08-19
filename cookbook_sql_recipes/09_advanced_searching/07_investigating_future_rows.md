# Investigating Future Rows

You want to find `any employees` who **earn less than the employee hired immediately after them**.

Based on the following result set:

```SQL
SELECT ename, sal, hiredate
  FROM emp
 ORDER BY hiredate;
```

| ename  | sal  |  hiredate|
|:------:|:----:|:---------:|
| ALLEN  | 1600 | 2006-01-20|
| **WARD**   | **1250** | **2006-02-22**|
| JONES  | 2975 | 2006-04-02|
| BLAKE  | 2850 | 2006-05-01|
| CLARK  | 2450 | 2006-06-09|
| TURNER | 1500 | 2006-09-08|
| **MARTIN** | **1250** | **2006-09-28**|
| KING   | 5000 | 2006-11-17|
| FORD   | 3000 | 2006-12-03|
| **JAMES**  |  **950** | **2006-12-03**|
| **MILLER** | **1300** | **2007-01-23**|
| SCOTT  | 3000 | 2007-12-09|
| ADAMS  | 1100 | 2008-01-12|
| SMITH  |  800 | 2015-12-17|

The output:

|ename  | sal  |  hiredate|
|:------:|:----:|:---------:|
|WARD   | 1250 | 2006-02-22|
|MARTIN | 1250 | 2006-09-28|
|JAMES  |  950 | 2006-12-03|
|MILLER | 1300 | 2007-01-23|

## Solution

The first step is to define what “**future**” means. You must impose order on your result set to be able to define a `row as having a value that is` “**later**” than another.
You can use the `LEAD OVER` window function **to access the salary of the next employee that was hired**.

It’s then a simple matter to check whether that salary is larger:

```SQL
WITH t AS (
  SELECT ename, sal,
         LEAD(sal) OVER(ORDER BY hiredate) AS next_sal
    FROM emp
)
SELECT ename, sal
  FROM t
 WHERE sal < next_sal;
```

If you mind about duplicates `hiredate`:

```SQL
WITH t1 AS (
  SELECT ename, sal, hiredate,
         COUNT(*) OVER(PARTITION BY hiredate) AS cnt,
         ROW_NUMBER() OVER (PARTITION BY hiredate
                                ORDER BY empno) AS rn
    FROM emp
),
t2 AS (
  SELECT ename, sal, hiredate,
         LEAD(sal, (cnt - rn + 1)::INTEGER) OVER (ORDER BY hiredate) AS next_sal
    FROM t1
)
SELECT ename, sal, hiredate
  FROM t2
 WHERE sal < next_sal;
```

## Discussion

The window function `LEAD OVER` is perfect for a problem such as this one. It not only makes for a more readable query than the solution for the other products, `LEAD OVER` also leads to a more flexible solution because an argument can be passed to it that will determine how many rows ahead it should look (by default one). Being able to leap ahead more than one row is important in the case of duplicates in the column you are ordering by.

The following example shows how easy it is to use `LEAD OVER` to look at the salary of the “next” employee hired:

```SQL
SELECT ename, sal,
       LEAD(sal) OVER(ORDER BY hiredate) AS next_sal
  FROM emp;  
```

|ename  | sal  | next_sal|
|:-----:|:----:|:-------:|
|ALLEN  | 1600 |     1250|
|WARD   | 1250 |     2975|
|JONES  | 2975 |     2850|
|BLAKE  | 2850 |     2450|
|CLARK  | 2450 |     1500|
|TURNER | 1500 |     1250|
|MARTIN | 1250 |     5000|
|KING   | 5000 |     3000|
|FORD   | 3000 |      950|
|JAMES  |  950 |     1300|
|MILLER | 1300 |     3000|
|SCOTT  | 3000 |     1100|
|ADAMS  | 1100 |      800|
|SMITH  |  800 ||

The final step is to return only rows where `SAL` is less than `NEXT_SAL`. Because of `LEAD OVER’s` default range of one row, if there had been duplicates in table `EMP` in particular, multiple employees hired on the same date—their `SAL` would be compared. This may or may not have been what you intended. If your goal is to compare the `SAL` of each employee with `SAL` of the next employee hired, **excluding other employees hired on the same day**, you can use the following solution as an alternative:

```SQL
WITH t1 AS (
  SELECT ename, sal, hiredate,
         COUNT(*) OVER(PARTITION BY hiredate) AS cnt,
         ROW_NUMBER() OVER (PARTITION BY hiredate
                                ORDER BY empno) AS rn
    FROM emp
),
t2 AS (
  SELECT ename, sal, hiredate,
         LEAD(sal, (cnt - rn + 1)::INTEGER) OVER (ORDER BY hiredate) AS next_sal
    FROM t1
)
SELECT ename, sal, hiredate
  FROM t2
 WHERE sal < next_sal;
```

The idea behind this solution is to find the distance from the current row to the row it should be compared with.

For example, if there are five duplicates, the first of the five needs to leap five rows to get to its correct `LEAD OVER` row. The value for `CNT` represents, for each employee with a duplicate `HIREDATE`, how many duplicates there are in total for their `HIREDATE`. The value for `RN` represents a ranking for the employees in `DEPTNO 10`. The rank is partitioned by `HIREDATE` so only employees with a `HIREDATE` that another employee has will have a value greater than one. The ranking is sorted by `EMPNO` (this is arbitrary). Now that you know how many total duplicates there are and you have a ranking of each duplicate, the distance to the next `HIREDATE` is simply the total number of duplicates minus the current rank plus one (`CNT-RN+1`).
