# Finding Rows That Satisfy Multiple Conditions Problem

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


You want to return rows that satisfy multiple conditions.

## Solution

Use the `WHERE` clause along with the `OR` and `AND` clauses. For example, if you would like to find **all the employees** in **department** `10`, along with any employees who **earn a commission**, along with any employees in department `20` who earn at `most $2,000`:

```SQL
SELECT *
  FROM emp
 WHERE deptno = 10
       OR comm is not null
       OR sal <= 2000 AND deptno = 20;
```

```SQL
SELECT *
  FROM emp
 WHERE (deptno = 10)
       OR (comm is not null)
       OR (sal <= 2000 AND deptno = 20);
```

**Output**

|empno | ename  |    job    |  mgr  |  hiredate  | sal  | comm  | deptno|
|:----:|:------:|:---------:|:------:|:---------:|:----:|:-----:|:-----:|
| 7369 | SMITH  | CLERK     |  7902 | 2015-12-17 |  800 | NULL; |     20|
| 7499 | ALLEN  | SALESMAN  |  7698 | 2006-01-20 | 1600 |   300 |     30|
| 7521 | WARD   | SALESMAN  |  7698 | 2006-02-22 | 1250 |   500 |     30|
| 7654 | MARTIN | SALESMAN  |  7698 | 2006-09-28 | 1250 |  1400 |     30|
| 7782 | CLARK  | MANAGER   |  7839 | 2006-06-09 | 2450 | NULL; |     10|
| 7839 | KING   | PRESIDENT | NULL; | 2006-11-17 | 5000 | NULL; |     10|
| 7844 | TURNER | SALESMAN  |  7698 | 2006-09-08 | 1500 |     0 |     30|
| 7876 | ADAMS  | CLERK     |  7788 | 2008-01-12 | 1100 | NULL; |     20|
| 7934 | MILLER | CLERK     |  7782 | 2007-01-23 | 1300 | NULL; |     10|

**(9 rows)**

## Discussion

You can use a combination of `AND`, `OR`, and `parentheses` to return rows that satisfy multiple conditions. In the solution example, the `WHERE` clause finds rows such that:

-  The `DEPTNO` is 10

|empno | ename  |    job    |  mgr  |  hiredate  | sal  | comm  | deptno|
|:----:|:------:|:---------:|:------:|:---------:|:----:|:-----:|:-----:|
| 7782 | CLARK  | MANAGER   |  7839 | 2006-06-09 | 2450 | NULL; |     10|
| 7839 | KING   | PRESIDENT | NULL; | 2006-11-17 | 5000 | NULL; |     10|
| 7934 | MILLER | CLERK     |  7782 | 2007-01-23 | 1300 | NULL; |     10|


-  OR The `COMM` is not NULL

|empno | ename  |    job    |  mgr  |  hiredate  | sal  | comm  | deptno|
|:----:|:------:|:---------:|:------:|:---------:|:----:|:-----:|:-----:|
| 7499 | ALLEN  | SALESMAN  |  7698 | 2006-01-20 | 1600 |   300 |     30|
| 7521 | WARD   | SALESMAN  |  7698 | 2006-02-22 | 1250 |   500 |     30|
| 7654 | MARTIN | SALESMAN  |  7698 | 2006-09-28 | 1250 |  1400 |     30|
| 7844 | TURNER | SALESMAN  |  7698 | 2006-09-08 | 1500 |     0 |     30|

-  OR The `salary` is `$2,000 or less` for any employee in `DEPTNO 20`.

|empno | ename  |    job    |  mgr  |  hiredate  | sal  | comm  | deptno|
|:----:|:------:|:---------:|:------:|:---------:|:----:|:-----:|:-----:|
| 7369 | SMITH  | CLERK     |  7902 | 2015-12-17 |  800 | NULL; |     20|
| 7876 | ADAMS  | CLERK     |  7788 | 2008-01-12 | 1100 | NULL; |     20|


The presence of parentheses causes conditions within them to be evaluated together.

For example, consider how the result set changes if the query was written with the parentheses as shown here:

```SQL
SELECT *
  FROM emp
 WHERE (deptno = 10
       OR comm is not null
       OR sal <= 2000) AND deptno = 20;
```

**Output**

|empno | ename  |    job    |  mgr  |  hiredate  | sal  | comm  | deptno|
|:----:|:------:|:---------:|:------:|:---------:|:----:|:-----:|:-----:|
| 7369 | SMITH | CLERK | 7902 | 2015-12-17 |  800 | NULL; |     20|
| 7876 | ADAMS | CLERK | 7788 | 2008-01-12 | 1100 | NULL; |     20|

(2 rows)
