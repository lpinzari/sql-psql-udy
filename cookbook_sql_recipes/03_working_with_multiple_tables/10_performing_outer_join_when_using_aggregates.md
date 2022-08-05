# Performing Outer Joins When Using Aggregates Problem

Begin with the same problem as in Recipe [09](./09_performing_join_when_using_aggregates), but modify table `EMP_BONUS` such that the difference in this case is `NOT ALL EMPLOYEES IN DEPARTMENT` **10** `HAVE BEEN GIVEN BONUSES`.

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
       (7934,'2005-03-15',2);
```

|empno |  received  | type|
|:----:|:----------:|:---:|
| 7934 | 2005-03-17 |    1|
| 7934 | 2005-03-15 |    2|


Consider the `EMP_BONUS` table and a query to (ostensibly) find both the
- `sum of the salaries` for **employees in department** `10` **WHO HAD BEEN GIVEN BONUSES** along with the
- `sum of their bonuses`:

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
|:-----:|:---------:|:-----------:|
|    10 |      2600 |       390.0|

This result confirms the total sum of the employees who had been given a bonus.

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
| 7934 | MILLER | 1300 |     10 | 130.0|
| 7934 | MILLER | 1300 |     10 | 260.0|

Now suppose we wanted find both the
- `sum of the salaries` for **employees in department** `10` along with the
- `sum of their bonuses`.

|deptno | total_sal | total_bonus|
|:-----:|:---------:|:-----------:|
|    10 |      8750 |       390.0|

## Solution

Perform a sum of only the `DISTINCT` salaries with a `LEFT OUTER JOIN`:

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
   LEFT JOIN emp_bonus eb USING (empno)
  WHERE e.deptno = 10
)

SELECT deptno,
       SUM(DISTINCT sal) AS total_sal,
       SUM(bonus) AS total_bonus
  FROM e_salb
 GROUP BY deptno;
```

The solution is the same as the one used in the previous problem [09](./09_performing_join_when_using_aggregates) **if there could be duplicate values in the column you are summing**.

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
