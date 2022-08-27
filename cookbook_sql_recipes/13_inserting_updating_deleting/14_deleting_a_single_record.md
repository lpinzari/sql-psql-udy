# Deleting a Single Record

You want to delete a single record from a table.

## Problem

```SQL
SELECT *
  FROM emp_commission;
```

| empno | ename  | deptno | comm|
|:-----:|:------:|:------:|:----:|
|  7654 | MARTIN |     30 | 1400|
|  7499 | ALLEN  |     30 |  450|
|  7521 | WARD   |     30 |  750|

Suppose you want to delete employee `WARD` from `EMP_COMMISSION` table.

|empno | ename  | deptno | comm|
|:----:|:------:|:------:|:---:|
| 7654 | MARTIN |     30 | 1400|
| 7521 | WARD   |     30 |  750|

## Solution

This is a special case of the previous Recipe `12`. The key is to ensure that your selection criterion is narrow enough to specify only the one record that you want to delete. Often you will want to delete based on the **primary key**. For example, to delete employee `WARD` (`EMPNO 7499`):

```SQL
DELETE FROM emp_commission
      WHERE empno = 7499;
```

## Discussion

Deleting is always about identifying the rows to be deleted, and the impact of a `DELETE` always comes down to its `WHERE` clause. Omit the `WHERE` clause and the scope of a `DELETE` is the entire table. By writing conditions in the `WHERE` clause, you can narrow the scope to a group of records or to a single record. When deleting a single record, you should typically be identifying that record based on its primary key or on one of its unique keys.
