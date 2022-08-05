# Performing Joins When Using Aggregates

You want to `perform an aggregation`, **but your query involves multiple tables**. You want to ensure that **joins do not disrupt the aggregation**.

## Problem

```console
cookbook=> \d emp
                        Table "public.emp"
  Column  |         Type          | Collation | Nullable | Default
----------+-----------------------+-----------+----------+---------
 empno    | integer               |           | not null |
 ename    | character varying(10) |           |          |
 job      | character varying(9)  |           |          |
 mgr      | integer               |           |          |
 hiredate | date                  |           |          |
 sal      | integer               |           |          |
 comm     | integer               |           |          |
 deptno   | integer               |           |          |
Indexes:
    "emp_pkey" PRIMARY KEY, btree (empno)
```

For example, you want to find the
- `sum of the salaries` for **employees in department** `10` along with the
- `sum of their bonuses`.

Some employees have more than one bonus, and the join between table `EMP` and table `EMP_BONUS` is causing incorrect values to be returned by the aggregate function SUM. For this problem, table `EMP_BONUS` contains the following data:

```console
cookbook=> \d emp_bonus
              Table "public.emp_bonus"
  Column  |  Type   | Collation | Nullable | Default
----------+---------+-----------+----------+---------
 empno    | integer |           | not null |
 received | date    |           |          |
 type     | integer |           |          |
```


```SQL
INSERT INTO emp_bonus
       (empno, received, type)
VALUES (7934,'2005-03-17',1),
       (7934,'2005-03-15',2),
       (7839,'2005-03-15',3),
       (7782,'2005-03-15',1);
```

|empno |  received  | type|
|:----:|:----------:|:---:|
| 7934 | 2005-03-17 |    1|
| 7934 | 2005-03-15 |    2|
| 7839 | 2005-03-15 |    3|
| 7782 | 2005-03-15 |    1|

Table **emp**:

|empno | ename  |    job    |  mgr  |  hiredate  | sal  | comm  | deptno|
|:----:|:------:|:---------:|:-----:|:-----------:|:---:|:-----:|:-----:|
| 7369 | SMITH  | CLERK     |  7902 | 2015-12-17 |  800 | NULL; |     20|
| 7499 | ALLEN  | SALESMAN  |  7698 | 2006-01-20 | 1600 |   300 |     30|
| 7521 | WARD   | SALESMAN  |  7698 | 2006-02-22 | 1250 |   500 |     30|
| 7566 | JONES  | MANAGER   |  7839 | 2006-04-02 | 2975 | NULL; |     20|
| 7654 | MARTIN | SALESMAN  |  7698 | 2006-09-28 | 1250 |  1400 |     30|
| 7698 | BLAKE  | MANAGER   |  7839 | 2006-05-01 | 2850 | NULL; |     30|
| **7782** | **CLARK**  | **MANAGER**   |  **7839** | **2006-06-09** | **2450** | **NULL;** |     **10**|
| 7788 | SCOTT  | ANALYST   |  7566 | 2007-12-09 | 3000 | NULL; |     20|
| **7839** | **KING**   | **PRESIDENT** | **NULL;** | **2006-11-17** | **5000** | **NULL;** |     **10**|
| 7844 | TURNER | SALESMAN  |  7698 | 2006-09-08 | 1500 |     0 |     30|
| 7876 | ADAMS  | CLERK     |  7788 | 2008-01-12 | 1100 | NULL; |     20|
| 7900 | JAMES  | CLERK     |  7698 | 2006-12-03 |  950 | NULL; |     30|
| 7902 | FORD   | ANALYST   |  7566 | 2006-12-03 | 3000 | NULL; |     20|
| **7934** | **MILLER** | **CLERK**     |  **7782** | **2007-01-23** | **1300** | **NULL;** |     **10**|


Now, consider the following query that returns
- the `salary` and `bonus` for all employees in `department` **10**.
- Table `BONUS.TYPE` determines the amount of the bonus.
  - A type `1` bonus is **10%** of an employee’s salary,
  - type `2` is **20%**, and
  - type `3` is **30%**.


```SQL
SELECT e.empno,
       e.ename,
       e.sal,
       e.deptno,
       e.sal * (CASE WHEN eb.type = 1 THEN 0.1
                     WHEN eb.type = 2 then 0.2
                     ELSE 0.3
                 END) AS bonus
 FROM emp e
 JOIN emp_bonus eb USING (empno)
WHERE e.deptno = 10;
```


|empno | ename  | sal  | deptno | bonus|
|:----:|:------:|:----:|:------:|:-----:|
| 7934 | MILLER | 1300 |     10 |  130.0|
| 7934 | MILLER | 1300 |     10 |  260.0|
| 7839 | KING   | 5000 |     10 | 1500.0|
| 7782 | CLARK  | 2450 |     10 |  245.0|

We see that empno `7934` appears in two records so we have a duplicate value for the sal column. However, the empno `7934` had two bonuses in different dates.
So far, so good. However, things go awry when you attempt a join to the `EMP_BONUS` table **to sum the bonus amounts**:

```SQL
WITH e_salb AS (
  SELECT e.empno,
         e.ename,
         e.sal,
         e.deptno,
         e.sal * (CASE WHEN eb.type = 1 THEN 0.1
                       WHEN eb.type = 2 then 0.2
                       ELSE 0.3
                   END) AS bonus
   FROM emp e
   JOIN emp_bonus eb USING (empno)
  WHERE e.deptno = 10
)

SELECT deptno,
       SUM(sal) AS total_sal,
       SUM(bonus) AS total_bonus
  FROM e_salb
 GROUP BY deptno;
```

|deptno | total_sal | total_bonus|
|:-----:|:---------:|:----------:|
|    10 |     10050 |      2135.0|

While the `TOTAL_BONUS` is correct, the `TOTAL_SAL` is incorrect. The sum of all salaries in department **10** is `8750`, as the following query shows:

```SQL
SELECT SUM(sal)
  FROM emp
 WHERE deptno = 10;
```

|sum|
|:---:|
|8750|

Why is `TOTAL_SAL` incorrect? The reason is the **duplicate rows in the SAL column created by the join**. Consider the following query, which joins tables `EMP` and `EMP_BONUS`:

```SQL
SELECT e.ename,
       e.sal
  FROM emp e
  JOIN emp_bonus eb USING (empno)
 WHERE e.deptno = 10;
```

|ename  | sal|
|:-----:|:---:|
|MILLER | 1300|
|MILLER | 1300|
|KING   | 5000|
|CLARK  | 2450|

```SQL
SELECT e.ename,
       e.sal
  FROM emp e
 WHERE e.deptno = 10;
```

|ename  | sal|
|:-----:|:---:|
|CLARK  | 2450|
|KING   | 5000|
|MILLER | 1300|

The `resulting tables show that all employees in department` **10** received a **BONUS**.

Now it is easy to see why the value for `TOTAL_SAL` is incorrect: MILLER’s salary is counted twice. The final result set that you are really after is:

|deptno | total_sal | total_bonus|
|:-----:|:---------:|:----------:|
|10|8750|2135|

## Solution

You have to be careful when computing aggregates across joins. Typically when duplicates are returned due to a join, you can avoid miscalculations by aggregate functions in two ways:

 - you can simply use the keyword `DISTINCT` in the call to the aggregate function, so **only unique instances of each value are used in the computation**; or
 - you can perform the **aggregation first (in an inline view) prior to joining**, thus avoiding the incorrect computation by the aggregate function because the aggregate will already be computed before you even join, thus avoiding the problem altogether.

###  MySQL and PostgreSQL

Perform a sum of only the `DISTINCT` salaries:

```SQL
WITH e_salb AS (
  SELECT e.empno,
         e.ename,
         e.sal,
         e.deptno,
         e.sal * (CASE WHEN eb.type = 1 THEN 0.1
                       WHEN eb.type = 2 then 0.2
                       ELSE 0.3
                   END) AS bonus
   FROM emp e
   JOIN emp_bonus eb USING (empno)
  WHERE e.deptno = 10
)

SELECT deptno,
       SUM(DISTINCT sal) AS total_sal,
       SUM(bonus) AS total_bonus
  FROM e_salb
 GROUP BY deptno;
```

|deptno | total_sal | total_bonus|
|:-----:|:---------:|:-----------:|
|    10 |      8750 |      2135.0|


The second query in the “Problem” section of this recipe joins table `EMP` and table `EMP_BONUS` and returns **two rows** for employee `MILLER`, which is what causes the error on the sum of `EMP.SAL` (**the salary is added twice**). The solution is to simply sum the distinct `EMP.SAL` values that are returned by the query.

## CTE

The following query is an alternative solution—necessary **if there could be duplicate values in the column you are summing**.

- The sum of all salaries in department `10` is computed first,
- and that row is then joined to table `EMP`,
- which is then joined to table `EMP_BONUS`.

The following query works for all DBMSs:


```SQL
WITH e_sal AS (
  SELECT deptno,
         SUM(sal) AS total_sal
    FROM emp
   WHERE deptno = 10
   GROUP BY deptno
),
e_salb AS (
  SELECT e.empno,
         e.ename,
         e.deptno,
         e.sal * (CASE WHEN eb.type = 1 THEN 0.1
                       WHEN eb.type = 2 then 0.2
                       ELSE 0.3
                   END) AS bonus
   FROM emp e
   JOIN emp_bonus eb USING (empno)
  WHERE e.deptno = 10
)

SELECT e_sal.deptno,
       e_sal.total_sal,
       e_salb.bonus
  FROM e_sal
  JOIN e_salb USING(deptno);
```

|deptno | total_sal | bonus|
|:-----:|:---------:|:-----:|
|    10 |      8750 |  130.0|
|    10 |      8750 |  260.0|
|    10 |      8750 | 1500.0|
|    10 |      8750 |  245.0|


Lastly, we perform the aggregation for the bonus salaries.

```SQL
WITH e_sal AS (
  SELECT deptno,
         SUM(sal) AS total_sal
    FROM emp
   WHERE deptno = 10
   GROUP BY deptno
),
e_salb AS (
  SELECT e.empno,
         e.ename,
         e.deptno,
         e.sal * (CASE WHEN eb.type = 1 THEN 0.1
                       WHEN eb.type = 2 then 0.2
                       ELSE 0.3
                   END) AS bonus
   FROM emp e
   JOIN emp_bonus eb USING (empno)
  WHERE e.deptno = 10
)

SELECT e_sal.deptno,
       e_sal.total_sal,
       SUM(e_salb.bonus) AS total_bonus
  FROM e_sal
  JOIN e_salb USING(deptno)
 GROUP BY e_sal.deptno, e_sal.total_sal;
```

|deptno | total_sal | total_bonus|
|:-----:|:---------:|:----------:|
|    10 |      8750 |      2135.0|


## NESTED QUERIES

```SQL
SELECT e_sal.deptno,
       e_sal.total_sal,
       SUM(e.sal * CASE WHEN eb.type = 1 THEN .1
                        WHEN eb.type = 2 THEN .2
                        ELSE .3 END) AS total_bonus
  FROM emp e,
       emp_bonus eb,
       (
          SELECT deptno,
                 SUM(sal) AS total_sal
            FROM emp
           WHERE deptno = 10
           GROUP BY deptno
       )e_sal
 WHERE e.deptno = e_sal.deptno AND
       e.empno = eb.empno
 GROUP BY e_sal.deptno,e_sal.total_sal;
```

# WINDOW FUNCTION

An alternative solution takes advantage of the window function SUM OVER.

```SQL
WITH e_sal AS (
  SELECT deptno,
         SUM(sal) AS total_sal
    FROM emp
   WHERE deptno = 10
   GROUP BY deptno
),
e_salb AS (
  SELECT e.empno,
         e.ename,
         e.deptno,
         e.sal * (CASE WHEN eb.type = 1 THEN 0.1
                       WHEN eb.type = 2 then 0.2
                       ELSE 0.3
                   END) AS bonus
   FROM emp e
   JOIN emp_bonus eb USING (empno)
  WHERE e.deptno = 10
)

SELECT DISTINCT e_sal.deptno,
       total_sal,
       SUM(e_salb.bonus) OVER (PARTITION BY e_sal.deptno, total_sal) AS total_bonus
  FROM e_sal
  JOIN e_salb USING(deptno);
```
