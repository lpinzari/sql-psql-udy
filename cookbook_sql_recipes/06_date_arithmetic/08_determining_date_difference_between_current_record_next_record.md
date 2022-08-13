# Determining the Date Difference Between the Current Record and the Next Record

You want to determine the **difference in days between two dates**(specifically **dates stored in two different rows**).

## Problem

For example, for **every employee** in `DEPTNO 10`, you want to
1. determine the `number of days` **between** the `day they were hired` **and** the `day the next employee` (in department 10) `was hired`.

```SQL
SELECT deptno, ename, hiredate
  FROM emp e
 ORDER BY hiredate;
```

|deptno | ename  |  hiredate|
|:-----:|:------:|:---------:|
|    30 | ALLEN  | 2006-01-20|
|    30 | WARD   | 2006-02-22|
|    20 | JONES  | 2006-04-02|
|    30 | BLAKE  | 2006-05-01|
|    **10** | **CLARK**  | **2006-06-09**|
|    30 | TURNER | 2006-09-08|
|    30 | MARTIN | 2006-09-28|
|    **10** | **KING**   | **2006-11-17**|
|    20 | FORD   | 2006-12-03|
|    30 | JAMES  | 2006-12-03|
|    **10** | **MILLER** | **2007-01-23**|
|    20 | SCOTT  | 2007-12-09|
|    20 | ADAMS  | 2008-01-12|
|    20 | SMITH  | 2015-12-17|

**Output**:

|deptno | ename  |  hiredate  |  next_hd   | diff|
|:-----:|:------:|:----------:|:----------:|:---:|
|    10 | CLARK  | 2006-06-09 | 2006-11-17 |  161|
|    10 | KING   | 2006-11-17 | 2007-01-23 |   67|
|    10 | MILLER | 2007-01-23 | NULL       | NULL|


2. - determine the `number of days` **between** the `day they were hired` **and** the `day the next employee` (can be in another department) `was hired`.

```SQL
SELECT deptno, ename, hiredate
  FROM emp e
 ORDER BY hiredate;
```

|deptno | ename  |  hiredate|
|:-----:|:------:|:----------:|
|    30 | ALLEN  | 2006-01-20|
|    30 | WARD   | 2006-02-22|
|    20 | JONES  | 2006-04-02|
|    30 | BLAKE  | 2006-05-01|
|    **10** | **CLARK**  | **2006-06-09**|
|    30 | TURNER | **2006-09-08**|
|    30 | MARTIN | 2006-09-28|
|    **10** | **KING**   | **2006-11-17**|
|    20 | FORD   | **2006-12-03**|
|    30 | JAMES  | 2006-12-03|
|    **10** | **MILLER** | **2007-01-23**|
|    20 | SCOTT  | **2007-12-09**|
|    20 | ADAMS  | 2008-01-12|
|    20 | SMITH  | 2015-12-17|


**Output**

|deptno | ename  |  hiredate  |  next_hd   | diff|
|:-----:|:------:|:----------:|:----------:|:----:|
|    10 | CLARK  | 2006-06-09 | 2006-09-08 |   91|
|    10 | KING   | 2006-11-17 | 2006-12-03 |   16|
|    10 | MILLER | 2007-01-23 | 2007-12-09 |  320|


## Solution

use the window function `LEAD` and then find the difference in days between the two dates.

- **Problem 1**:

```SQL
WITH dep_hd AS (
  SELECT e.deptno, e.ename, e.hiredate,
         LEAD(hiredate) OVER (ORDER BY hiredate) AS next_hd
    FROM emp e
   WHERE e.deptno = 10
)
SELECT dep_hd.*,
       dep_hd.next_hd - dep_hd.hiredate AS diff
  FROM dep_hd;
```

- **Problem 2**:

```SQL
WITH dep_hd AS (
  SELECT e.deptno, e.ename, e.hiredate,
         LEAD(hiredate) OVER (ORDER BY hiredate) AS next_hd
    FROM emp e
)
SELECT dep_hd.*,
       dep_hd.next_hd - dep_hd.hiredate AS diff
  FROM dep_hd
 WHERE dep_hd.deptno = 10
 ORDER BY dep_hd.hiredate;
```

## Discussion

- **Problem 1**:

```SQL
WITH dep_hd AS (
  SELECT e.deptno, e.ename, e.hiredate,
         LEAD(hiredate) OVER (ORDER BY hiredate) AS next_hd
    FROM emp e
   WHERE e.deptno = 10
)
SELECT dep_hd.*,
       dep_hd.next_hd - dep_hd.hiredate AS diff
  FROM dep_hd;
```

The ability to access rows around your current row without additional joins provides for more readable and efficient code. When working with window functions, keep in mind that they are evaluated after the `WHERE` clause.  

One important note to mention about LEAD and LAG functions is their behavior in the presence of duplicates.  

In this example there are no duplicate `HIREDATEs` in table `EMP`, but it is certainly possible (and probably likely) that there are duplicate date values in your tables. Consider the employees in `DEPTNO 10` and their `HIREDATEs`:

```SQL
SELECT e.deptno, e.ename, e.hiredate
  FROM emp e
 WHERE e.deptno = 10
 ORDER BY hiredate;  
```

|deptno | ename  |  hiredate|
|:-----:|:------:|:---------:|
|    10 | CLARK  | 2006-06-09|
|    10 | KING   | 2006-11-17|
|    10 | MILLER | 2007-01-23|

For the sake of this example, let’s insert four duplicates such that there are five employees (including `KING`) hired on November 17, `2006-11-17`:


```SQL
INSERT INTO emp
       (empno,ename,deptno,hiredate)
VALUES (1,'ANT',10,'2006-11-17'),
       (2,'JOE',10,'2006-11-17'),
       (3,'JIM',10,'2006-11-17'),
       (4,'CHOI',10,'2006-11-17');
```

|deptno | ename  |  hiredate|
|:-----:|:------:|:---------:|
|    **10** | **CLARK**  | **2006-06-09**|
|    10 | KING   | 2006-11-17|
|    10 | ANT    | 2006-11-17|
|    10 | CHOI   | 2006-11-17|
|    10 | JOE    | 2006-11-17|
|    10 | JIM    | 2006-11-17|
|    **10** | **MILLER** | **2007-01-23**|

Now there are multiple employees in `DEPTNO 10` hired on the same day. If you try to use the proposed solution on this result set, you get the following output:

|deptno | ename  |  hiredate  |  next_hd   | diff|
|:-----:|:------:|:----------:|:----------:|:---:|
|    10 | CLARK  | 2006-06-09 | 2006-11-17 |  161|
|    10 | KING   | 2006-11-17 | 2006-11-17 |    0|
|    10 | ANT    | 2006-11-17 | 2006-11-17 |    0|
|    10 | CHOI   | 2006-11-17 | 2006-11-17 |    0|
|    10 | JOE    | 2006-11-17 | 2006-11-17 |    0|
|    10 | JIM    | 2006-11-17 | **2007-01-23** |   67|
|    10 | MILLER | **2007-01-23** | NULL       | NULL|

Looking at the values of DIFF for four of the five employees hired on the same day, you can see that the value is zero. This is not correct. All employees hired on the same day should have their dates evaluated against the HIREDATE of the next date on which an employee was hired.

```console
|deptno | ename  |  hiredate  |
|:-----:|:------:|:----------:|:
|    10 | CLARK  | 2006-06-09 |
|    10 | KING   | 2006-11-17 | ---------------+
|    10 | ANT    | 2006-11-17 | ------------+  |
|    10 | CHOI   | 2006-11-17 | ---------+  |  |
|    10 | JOE    | 2006-11-17 | ------+  |  |  |
|    10 | JIM    | 2006-11-17 | ---+  |  |  |  |
                                   |  |  |  |  |
|    10 | MILLER | 2007-01-23 |<---+--+--+--+--+
```
(i.e., all employees hired on `2006-11-17` should be evaluated against MILLER’s HIREDATE `2007-01-23`).

```SQL
SELECT e.deptno, e.ename, e.hiredate,
       LEAD(hiredate) OVER (ORDER BY hiredate) AS next_hd
  FROM emp e
 WHERE deptno = 10
 ORDER BY hiredate;
```

|deptno | ename  |  hiredate  |  next_hd|
|:-----:|:------:|:----------:|:---------:|
|    10 | CLARK  | 2006-06-09 | 2006-11-17|
|    10 | KING   | 2006-11-17 | 2006-11-17|
|    10 | ANT    | 2006-11-17 | 2006-11-17|
|    10 | CHOI   | 2006-11-17 | 2006-11-17|
|    10 | JOE    | 2006-11-17 | 2006-11-17|
|    10 | JIM    | 2006-11-17 | 2007-01-23|
|    10 | MILLER | 2007-01-23 | NULL|

The problem here is that the `LEAD` function orders the rows by `HIREDATE` but **does not skip duplicates**.

```SQL
SELECT e.deptno, e.empno, e.ename, e.hiredate,
       COUNT(*) OVER (PARTITION BY hiredate) AS cnt,
       ROW_NUMBER() OVER (PARTITION BY hiredate ORDER BY empno) AS rn
  FROM emp e
 WHERE deptno = 10
 ORDER BY hiredate;
```

```console
deptno | empno | ename  |  hiredate  | cnt | rn
--------+-------+--------+------------+-----+----
    10 |  7782 | CLARK  | 2006-06-09 |   1 |  1     (cnt - rn + 1)
    ----------------------------------------------
    10 |     1 | ANT    | 2006-11-17 |   5 |  1  ------------------5    
    10 |     2 | JOE    | 2006-11-17 |   5 |  2  ---------------4  |
    10 |     3 | JIM    | 2006-11-17 |   5 |  3  ------------3  |  |
    10 |     4 | CHOI   | 2006-11-17 |   5 |  4  ---------2  |  |  |
    10 |  7839 | KING   | 2006-11-17 |   5 |  5  ----- 1  |  |  |  |
    ---------------------------------------------      |  |  |  |  |
    10 |  7934 | MILLER | 2007-01-23 |   1 |  1  <-----+--+--+--+--+
```

When invoking the `LEAD` function, you can pass an argument to `LEAD` to specify exactly where the future row is (i.e., is it the `next row`, `10 rows later`, `etc`.).

- So, looking at employee `ANT`, instead of looking ahead one row, you need to look ahead `five rows` (**you want to jump over all the other duplicates**), because that’s where `MILLER` is.

- If you look at employee `JOE`, he is `four rows` from `MILLER`,
- `JIM` is `three rows` from `MILLER`,
- `KING` is `two rows` from `MILLER`, and
- `CHOI` is `one row` from `MILLER`.

To get the correct answer, simply pass the **distance** from each employee to `MILLER` as an argument to `LEAD`.

The window function `COUNT OVER` counts the number of times each `HIREDATE` occurs and returns this value to each row. For the duplicate `HIREDATEs`, a value of **5** is returned for each row with that `HIREDATE`. The window function `ROW_NUMBER OVER` ranks each employee by `EMPNO`. The ranking is partitioned by `HIREDATE`, so unless there are duplicate `HIREDATEs`, each employee will have a rank of **1**. At this point, **all the duplicates have been counted and ranked**, and the ranking can serve as the distance to the next HIREDATE (`MILLER’s HIREDATE`). You can see this by subtracting `RN` from `CNT` and adding **1** for each row when calling `LEAD`:

The solution is shown here:

```SQL
WITH iter AS (
  SELECT e.deptno, e.empno, e.ename, e.hiredate,
         COUNT(*) OVER (PARTITION BY hiredate)::INTEGER AS cnt,
         ROW_NUMBER() OVER (PARTITION BY hiredate ORDER BY empno)::INTEGER AS rn
    FROM emp e
   WHERE deptno = 10
)
SELECT deptno, ename, hiredate,
       LEAD(hiredate, cnt - rn + 1) OVER (ORDER BY hiredate) AS next_hd
  FROM iter
 WHERE deptno = 10;
```

|deptno | ename  |  hiredate  |  next_hd|
|:-----:|:------:|:----------:|:---------:|
|    10 | CLARK  | 2006-06-09 | 2006-11-17|
|    10 | ANT    | 2006-11-17 | 2007-01-23|
|    10 | JOE    | 2006-11-17 | 2007-01-23|
|    10 | JIM    | 2006-11-17 | 2007-01-23|
|    10 | CHOI   | 2006-11-17 | 2007-01-23|
|    10 | KING   | 2006-11-17 | 2007-01-23|
|    10 | MILLER | 2007-01-23 | NULL|

As you can see, by passing the appropriate distance to jump ahead to, the `LEAD` function performs the subtraction on the correct dates.

Now the results are correct. All the employees hired on the same day have their `HIREDATEs` evaluated against the next `HIREDATE`, not a `HIREDATE` that matches their own.

## Clean

```SQL
DELETE FROM emp WHERE ename = 'ANT';
DELETE FROM emp WHERE ename = 'JOE';
DELETE FROM emp WHERE ename = 'JIM';
DELETE FROM emp WHERE ename = 'CHOI';
```
