# Modifying Records in a Table

You want to modify values for some or all rows in a table. For example, you might want to **increase the salaries of everyone** in `department` **20** by `10%`.


```SQL
CREATE TABLE emp_2 AS
  SELECT *
    FROM emp;
```

The following result set shows the `DEPTNO`, `ENAME`, and `SAL` for employees in that department:

```SQL
SELECT deptno, ename, sal
  FROM emp_2
 WHERE deptno = 20
 ORDER BY 1,3;
```

|deptno | ename | sal|
|:-----:|:-----:|:----:|
|    20 | SMITH |  800|
|    20 | ADAMS | 1100|
|    20 | JONES | 2975|
|    20 | SCOTT | 3000|
|    20 | FORD  | 3000|

You want to bump all the SAL values by `10%`.

```SQL
SELECT deptno, ename, sal
  FROM emp_2
 WHERE deptno = 20
 ORDER BY 1,3;
```

|deptno | ename | sal|
|:------:|:-----:|:---:|
|    20 | SMITH |  880|
|    20 | ADAMS | 1210|
|    20 | JONES | 3273|
|    20 | SCOTT | 3300|
|    20 | FORD  | 3300|


## Solution

Use the `UPDATE` statement to modify existing rows in a database table. For example:

```SQL
UPDATE emp_2
   SET sal = sal*1.10
 WHERE deptno = 20;   
```

## Discussion

Use the `UPDATE` statement along with a `WHERE` clause to specify which rows to update; if you exclude a `WHERE` clause, then all rows are updated. The expression `SAL*1.10` in this solution returns the salary increased by `10%`.

When preparing for a mass update, you may want to preview the results. You can do that by issuing a `SELECT` statement that includes the expressions you plan to put into your `SET` clauses. The following `SELECT` shows the result of a `10%` salary increase:

```SQL
SELECT deptno, ename,
       sal AS orig_sal,
       sal * .10 AS amt_to_add,
       sal * 1.10 AS new_sal
  FROM emp_2
 WHERE deptno = 20
 ORDER BY 1,3;
```

|deptno | ename | orig_sal | amt_to_add | new_sal|
|:-----:|:-----:|:--------:|:----------:|:------:|
|    20 | SMITH |      800 |      80.00 |  880.00|
|    20 | ADAMS |     1100 |     110.00 | 1210.00|
|    20 | JONES |     2975 |     297.50 | 3272.50|
|    20 | SCOTT |     3000 |     300.00 | 3300.00|
|    20 | FORD  |     3000 |     300.00 | 3300.00|

The salary increase is broken down into two columns: one to show the increase over the old salary, and the other to show the new salary.
