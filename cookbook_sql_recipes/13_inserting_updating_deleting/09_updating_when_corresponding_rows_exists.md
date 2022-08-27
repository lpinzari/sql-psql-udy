#  Updating When Corresponding Rows Exist

You want to `update rows` **in one table** when `corresponding rows` **exist in another**.

## Problem

For example, if an employee appears in table `EMP_BONUS`, you want to increase that employee’s salary (in table `EMP`) by `20%`.

The following result set represents the data currently in table `EMP_BONUS`:

```SQL
CREATE TABLE emp_bonus AS
SELECT empno, ename
  FROM emp
 WHERE empno IN (7369,7900,7934);  
```

```console
cookbook=# SELECT * FROM emp_bonus;
 empno | ename
-------+--------
  7369 | SMITH
  7900 | JAMES
  7934 | MILLER
```

```SQL
SELECT empno, ename, sal
  FROM emp
 WHERE empno IN (7369,7900,7934);
```

|empno | ename  | sal|
|:----:|:------:|:---:|
| 7369 | SMITH  |  800|
| 7900 | JAMES  |  950|
| 7934 | MILLER | 1300|

```SQL
SELECT empno, ename, sal
  FROM emp
 WHERE empno IN (7369,7900,7934);
```

The increased salary table is:

|empno | ename  | sal|
|:----:|:------:|:---:|
| 7369 | SMITH  |  960|
| 7900 | JAMES  | 1140|
| 7934 | MILLER | 1560|

## Solution

Use a subquery in your `UPDATE` statement’s `WHERE` clause to find employees in table `EMP` that are also in table `EMP_BONUS`. Your `UPDATE` will then act only on those rows, enabling you to increase their salary by `20%`:

```SQL
UPDATE emp
   SET sal = sal * 1.20
 WHERE empno IN ( SELECT empno
                    FROM emp_bonus);
```

- **Solution 2**:

```SQL
UPDATE emp
   SET sal = sal * 1.20
 WHERE EXISTS ( SELECT NULL
                  FROM emp_bonus
                 WHERE emp.empno = emp_bonus.empno);
```

## Discussion

The results from the subquery represent the rows that will be updated in table `EMP`. The `IN` predicate tests values of `EMPNO` from the `EMP` table to see whether they are in the list of `EMPNO` values returned by the subquery. When they are, the corre‐ sponding `SAL` values are updated.

Alternatively, you can use `EXISTS` instead of `IN`:

```SQL
UPDATE emp
   SET sal = sal * 1.20
 WHERE EXISTS ( SELECT NULL
                  FROM emp_bonus
                 WHERE emp.empno = emp_bonus.empno);
```

You may be surprised to see `NULL` in the `SELECT` list of the `EXISTS` subquery. Fear not, that `NULL` **does not have an adverse effect on the update**.

Arguably it increases readability as it reinforces the fact that, unlike the solution using a subquery with an `IN` operator, what will drive the update (i.e., which rows will be updated) will be controlled by the `WHERE` clause of the subquery, **not the values returned as a result of the subquery’s SELECT list**.
