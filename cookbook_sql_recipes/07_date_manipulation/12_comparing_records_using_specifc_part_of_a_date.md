# Comparing Records Using Specific Parts of a Date

You want to find `which employees have been hired` on the same `month` and `weekday`.

## Problem

For example, if an employee was hired on `Monday, March 10, 2008`, and another employee was hired on `Monday, March 2, 2001`, you **want those two to come up** as a match since the day of week,`Monday` and month `March` match.

In table `EMP`, only three employees meet this requirement. You want to return the following result set:


|msg|
|:------------------------------------------------------:|
|JAMES was hired on the same month and weekday as FORD|
|SCOTT was hired on the same month and weekday as FORD|
|SCOTT was hired on the same month and weekday as JAMES|

## Solution

```SQL
SELECT e1.ename || ' was hired on the same month and weekday as ' || e2.ename AS msg
  FROM emp e1, emp e2
 WHERE e1.empno < e2.empno AND
       TO_CHAR(e1.hiredate,'MONTH') = TO_CHAR(e2.hiredate,'MONTH') AND
       TO_CHAR(e1.hiredate,'D') = TO_CHAR(e2.hiredate,'D')
 ORDER BY 1;
```
Because you want to compare one employee’s `HIREDATE` with the `HIREDATE` of the other employees, you will need to self-join table `EMP`. That makes each possible combination of `HIREDATEs` available for you to compare. Then, simply extract the weekday and month from each `HIREDATE` and compare.


## Discussion

The first step is to **self-join** `EMP` so that `each employee has access to the other employees’ HIREDATEs`.

Consider the results of the query shown here (**filtered** for `SCOTT`):

```SQL
SELECT e1.ename AS scott,
       TO_CHAR(e1.hiredate,'MONTH') AS scott_mth_hr,
       TO_CHAR(e1.hiredate,'D') AS scott_dow_hr,
       e2.ename AS other_emps,
       TO_CHAR(e2.hiredate,'MONTH') AS other_emp_mth_hr,
       TO_CHAR(e2.hiredate,'D') AS other_emp_dow_hr
  FROM emp e1, emp e2
 WHERE e1.ename = 'SCOTT' AND e1.empno != e2.empno
 ORDER BY e2.hiredate;
```

```console
scott | scott_mth_hr | scott_dow_hr | other_emps | other_emp_mth_hr | other_emp_dow_hr
------|--------------|--------------|------------|------------------|----
SCOTT | DECEMBER     | 1            | ALLEN      | JANUARY          | 6
SCOTT | DECEMBER     | 1            | WARD       | FEBRUARY         | 4
SCOTT | DECEMBER     | 1            | JONES      | APRIL            | 1
SCOTT | DECEMBER     | 1            | BLAKE      | MAY              | 2
SCOTT | DECEMBER     | 1            | CLARK      | JUNE             | 6
SCOTT | DECEMBER     | 1            | TURNER     | SEPTEMBER        | 6
SCOTT | DECEMBER     | 1            | MARTIN     | SEPTEMBER        | 5
SCOTT | DECEMBER     | 1            | KING       | NOVEMBER         | 6
--------------------------------------------------------------------------
SCOTT | DECEMBER     | 1            | FORD       | DECEMBER         | 1 <----
SCOTT | DECEMBER     | 1            | JAMES      | DECEMBER         | 1 <----
--------------------------------------------------------------------------
SCOTT | DECEMBER     | 1            | MILLER     | JANUARY          | 3
SCOTT | DECEMBER     | 1            | ADAMS      | JANUARY          | 7
SCOTT | DECEMBER     | 1            | SMITH      | DECEMBER         | 5
```

By self-joining table `EMP`, you can compare `SCOTT’s HIREDATE` to the `HIREDATE` of all the other employees. The filter on `EMPNO` is so that `SCOTT’s HIREDATE` is not returned as one of the `OTHER_HDS`.

The next step is to use your RDBMS’s supplied date formatting function(s) to compare the weekday and month of the `HIREDATEs` and keep only those that match:

```SQL
SELECT e1.ename AS e1,
       TO_CHAR(e1.hiredate,'MONTH') AS e1_mth_hr,
       TO_CHAR(e1.hiredate,'D') AS e1_dow_hr,
       e2.ename AS e2,
       TO_CHAR(e2.hiredate,'MONTH') AS e2_mth_hr,
       TO_CHAR(e2.hiredate,'D') AS e2_dow_hr
  FROM emp e1, emp e2
 WHERE e1.empno != e2.empno AND
       TO_CHAR(e1.hiredate,'MONTH') = TO_CHAR(e2.hiredate,'MONTH') AND
       TO_CHAR(e1.hiredate,'D') = TO_CHAR(e2.hiredate,'D')
 ORDER BY 1;
```

|e1   | e1_mth_hr | e1_dow_hr |  e2   | e2_mth_hr | e2_dow_hr|
|:----:|:---------:|:---------:|:-----:|:---------:|:--------:|
|FORD  | DECEMBER  | 1         | SCOTT | DECEMBER  | 1|
|FORD  | DECEMBER  | 1         | JAMES | DECEMBER  | 1|
|JAMES | DECEMBER  | 1         | SCOTT | DECEMBER  | 1|
|JAMES | DECEMBER  | 1         | FORD  | DECEMBER  | 1|
|SCOTT | DECEMBER  | 1         | FORD  | DECEMBER  | 1|
|SCOTT | DECEMBER  | 1         | JAMES | DECEMBER  | 1|

At this point, the `HIREDATEs` are correctly matched, but there are six rows in the result set rather than the three in the “Problem” section of this recipe. The reason for the extra rows is the filter on `EMPNO`. By using “not equals,” **you do not filter out the reciprocals**. For example, the first row matches `FORD` and `SCOTT`, and the second last row matches `SCOTT` and `FORD`. The six rows in the result set are technically accurate but **redundant**. To remove the redundancy, use “less than” (the HIREDATEs are removed to bring the intermediate queries closer to the final result set):

```SQL
SELECT e1.ename, e1.hiredate AS e1_hd,
       e2.ename AS e2_hd, e2.hiredate AS e2_hd
  FROM emp e1, emp e2
 WHERE e1.empno < e2.empno AND
       TO_CHAR(e1.hiredate,'MONTH') = TO_CHAR(e2.hiredate,'MONTH') AND
       TO_CHAR(e1.hiredate,'D') = TO_CHAR(e2.hiredate,'D')
 ORDER BY 1;
```

|ename |   e1_hd    | e2_hd |   e2_hd|
|:----:|:----------:|:-----:|:---------:|
|JAMES | 2006-12-03 | FORD  | 2006-12-03|
|SCOTT | 2007-12-09 | FORD  | 2006-12-03|
|SCOTT | 2007-12-09 | JAMES | 2006-12-03|



```SQL
SELECT e1.ename || ' was hired on the same month and weekday as ' || e2.ename AS msg
  FROM emp e1, emp e2
 WHERE e1.empno < e2.empno AND
       TO_CHAR(e1.hiredate,'MONTH') = TO_CHAR(e2.hiredate,'MONTH') AND
       TO_CHAR(e1.hiredate,'D') = TO_CHAR(e2.hiredate,'D')
 ORDER BY 1;
```
