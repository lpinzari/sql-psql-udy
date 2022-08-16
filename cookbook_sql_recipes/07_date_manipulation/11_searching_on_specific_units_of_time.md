# Searching on Specific Units of Time

You want to search for **dates that match a given**
- `month`, `day of the week`, or some `other unit of time`.


## Problem

For example, you want to **find all employees hired in**
- `February` or `December`, as well as employees hired
-  on a `Thursday`.

Sort the result by hiredate.

```SQL
SELECT hiredate, ename,
       RTRIM(TO_CHAR(hiredate,'MONTH')) AS month,
       RTRIM(TO_CHAR(hiredate,'DAY')) AS dow
  FROM emp
 ORDER BY hiredate;
```

```console
hiredate  | ename  |   month   |    dow
------------+--------+-----------+-----------
2006-01-20 | ALLEN  | JANUARY   | FRIDAY
2006-02-22 | WARD   | FEBRUARY  | WEDNESDAY    <----- FEBRUARY
2006-04-02 | JONES  | APRIL     | SUNDAY
2006-05-01 | BLAKE  | MAY       | MONDAY
2006-06-09 | CLARK  | JUNE      | FRIDAY
2006-09-08 | TURNER | SEPTEMBER | FRIDAY
2006-09-28 | MARTIN | SEPTEMBER | THURSDAY     <------ THURSDAY
2006-11-17 | KING   | NOVEMBER  | FRIDAY
2006-12-03 | FORD   | DECEMBER  | SUNDAY       <------ DECEMBER
2006-12-03 | JAMES  | DECEMBER  | SUNDAY       <------ DECEMBER
2007-01-23 | MILLER | JANUARY   | TUESDAY
2007-12-09 | SCOTT  | DECEMBER  | SUNDAY       <------ DECEMBER
2008-01-12 | ADAMS  | JANUARY   | SATURDAY
2015-12-17 | SMITH  | DECEMBER  | THURSDAY     <------ DECEMBER
```

|ename|
|:------:|
|WARD|
|MARTIN|
|JAMES|
|FORD|
|SCOTT|
|SMITH|


## Solution

Use the functions supplied by your RDBMS to find month and weekday names for dates. This particular recipe can be useful in various places. Consider, if you wanted to search HIREDATEs but wanted to ignore the year by extracting the month (or any other part of the HIREDATE you are interested in), you can do so. The example solu‐ tions to this problem search by month and weekday name. By studying the date for‐ matting functions provided by your RDBMS, you can easily modify these solutions to search by year, quarter, combination of year and quarter, month and year combina‐ tion, etc.


Use the function `TO_CHAR` to find the names of the month and weekday an employee was hired. Use the function `RTRIM` to remove trailing whitespaces:

```SQL
SELECT ename
  FROM emp
 WHERE RTRIM(TO_CHAR(hiredate,'MONTH')) IN ('FEBRUARY','DECEMBER') OR
       RTRIM(TO_CHAR(hiredate,'DAY')) = 'THURSDAY'
 ORDER BY hiredate;
```
