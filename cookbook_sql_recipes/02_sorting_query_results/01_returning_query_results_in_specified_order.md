# Returning Query Results in a Specified Order Problem

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

You want to display the `names`, `jobs`, and `salaries` of employees in department `10` in order **based on their salary (from lowest to highest)**. You want to return the following result set:

|ename  |    job    | sal|
|:-----:|:----------:|:-----:|
|MILLER | CLERK     | 1300|
|CLARK  | MANAGER   | 2450|
|KING   | PRESIDENT | 5000|

## Solution

Use the [ORDER BY](https://github.com/lpinzari/sql-psql-udy/blob/master/01_basic_sql/10_order_by.md) clause:

```SQL
SELECT ename,job,sal
  FROM emp
 WHERE deptno = 10
 ORDER BY sal ASC;
```

```SQL
SELECT ename,job,sal
  FROM emp
 WHERE deptno = 10
 ORDER BY 3 ASC;
```

## Discussion

The `ORDER BY` clause allows you to order the rows of your result set. The solution sorts the rows based on `SAL` in **ascending order**. By default, `ORDER BY` will sort in **ascending order**,`lowest to highest` and the `ASC` clause is therefore optional. Alternatively, specify `DESC` to sort in **descending order**:

```SQL
SELECT ename,job,sal
  FROM emp
 WHERE deptno = 10
 ORDER BY sal DESC;
```

|ename  |    job    | sal|
|:-----:|:---------:|:---:|
|KING   | PRESIDENT | 5000|
|CLARK  | MANAGER   | 2450|
|MILLER | CLERK     | 1300|

**(3 rows)**

You need not specify the name of the column on which to sort. You can instead specify **a number representing the column**. The number starts at `1` and **matches the items in the** `SELECT` list from `left to right`. For example:

```SQL
SELECT ename,job,sal
  FROM emp
 WHERE deptno = 10
 ORDER BY 3 ASC;
```

The number 3 in this example’s ORDER BY clause corresponds to the third column in the SELECT list, which is SAL.
