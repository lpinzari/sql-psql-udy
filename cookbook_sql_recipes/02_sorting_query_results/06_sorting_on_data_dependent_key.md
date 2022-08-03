# Sorting on a Data-Dependent Key Problem

You want to sort based on some conditional logic. For example, if `JOB` is `SALESMAN`, you want to sort on `COMM`; otherwise, you want to sort by `SAL`. You want to return the following result set:

|ename  | sal  |    job    | comm   |
|:-----:|:----:|:----------:|:------:|
|TURNER | 1500 | SALESMAN  |     0|
|ALLEN  | 1600 | SALESMAN  |   300|
|WARD   | 1250 | SALESMAN  |   500|
|SMITH  |  800 | CLERK     | NULL;|
|JAMES  |  950 | CLERK     | NULL;|
|ADAMS  | 1100 | CLERK     | NULL;|
|MILLER | 1300 | CLERK     | NULL;|
|MARTIN | 1250 | SALESMAN  |  1400|
|CLARK  | 2450 | MANAGER   | NULL;|
|BLAKE  | 2850 | MANAGER   | NULL;|
|JONES  | 2975 | MANAGER   | NULL;|
|SCOTT  | 3000 | ANALYST   | NULL;|
|FORD   | 3000 | ANALYST   | NULL;|
|KING   | 5000 | PRESIDENT | NULL;|

## Solution

Use a `CASE` expression in the `ORDER BY` clause:


```SQL
SELECT ename,sal,job,comm
  FROM emp
 ORDER BY CASE WHEN job = 'SALESMAN' THEN comm ELSE sal END;
```

## Discussion

You can use the `CASE` expression to dynamically change how results are sorted. The values passed to the `ORDER BY` look as follows:

```SQL
SELECT ename,sal,job,comm,
       CASE WHEN job = 'SALESMAN' THEN comm ELSE sal END AS ordered
  FROM emp
 ORDER BY 5;
```

|ename  | sal  |    job    | comm  | ordered   |
|:-----:|:----:|:---------:|:-----:|:--------:|
|TURNER | 1500 | SALESMAN  |     0 |       0|
|ALLEN  | 1600 | SALESMAN  |   300 |     300|
|WARD   | 1250 | SALESMAN  |   500 |     500|
|SMITH  |  800 | CLERK     | NULL; |     800|
|JAMES  |  950 | CLERK     | NULL; |     950|
|ADAMS  | 1100 | CLERK     | NULL; |    1100|
|MILLER | 1300 | CLERK     | NULL; |    1300|
|MARTIN | 1250 | SALESMAN  |  1400 |    1400|
|CLARK  | 2450 | MANAGER   | NULL; |    2450|
|BLAKE  | 2850 | MANAGER   | NULL; |    2850|
|JONES  | 2975 | MANAGER   | NULL; |    2975|
|SCOTT  | 3000 | ANALYST   | NULL; |    3000|
|FORD   | 3000 | ANALYST   | NULL; |    3000|
|KING   | 5000 | PRESIDENT | NULL; |    5000|
