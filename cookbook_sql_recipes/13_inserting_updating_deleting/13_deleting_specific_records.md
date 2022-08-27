# Deleting Specific Records

You want to `delete records` **meeting a specific criterion from a table**.

## Problem

Suppose you have the following table `emp_commmission`:

```SQL
SELECT *
  FROM emp_commission;
```

|empno | ename  | deptno | comm|
|:----:|:------:|:------:|:---:|
| 7654 | MARTIN |     30 | 1400|
| 7499 | ALLEN  |     30 |  450|
| 7521 | WARD   |     30 |  750|
| 7844 | TURNER |     30 |  100|
| 7369 | SMITH  |     20 |  500|
| 7566 | JONES  |     20 |  100|
| 7698 | BLAKE  |     30 |  100|
| 7782 | CLARK  |     10 |  100|
| 7788 | SCOTT  |     20 |  100|
| 7839 | KING   |     10 |  100|
| 7876 | ADAMS  |     20 |  100|
| 7900 | JAMES  |     30 |  500|
| 7902 | FORD   |     20 |  100|
| 7934 | MILLER |     10 |  100|

Let's say, we want to delete all records where commission is `100` or `500`.

We want to return the following table:

```SQL
SELECT *
  FROM emp_commission;
```

| empno | ename  | deptno | comm|
|:-----:|:------:|:------:|:----:|
|  7654 | MARTIN |     30 | 1400|
|  7499 | ALLEN  |     30 |  450|
|  7521 | WARD   |     30 |  750|


## Solution

Use the `DELETE` command with a `WHERE` clause specifying which rows to delete.

```SQL
DELETE FROM emp_commission
      WHERE comm IN (100,500);
```

## Discussion

By using a `WHERE` clause with the `DELETE` command, you can delete a subset of rows in a table rather than all the rows. Don’t forget to check that you’re deleting the right data by previewing the effect of your `WHERE` clause using `SELECT` you can delete the wrong data even in a simple situation.
