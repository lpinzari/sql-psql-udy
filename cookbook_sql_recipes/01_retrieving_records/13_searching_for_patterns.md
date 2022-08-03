# Searching for Patterns Problem

You want to **return rows that match a particular substring or pattern**. Consider the following query and result set:

```SQL
SELECT ename, job
  FROM emp
 WHERE deptno in (10,20);
```

**Output**

|ename  |    job|
|:-----:|:----------:|
|SMITH  | CLERK|
|JONES  | MANAGER|
|CLARK  | MANAGER|
|SCOTT  | ANALYST|
|KING   | PRESIDENT|
|ADAMS  | CLERK|
|FORD   | ANALYST|
|MILLER | CLERK|

**(8 rows)**

Of the employees in departments `10` and `20`, you want to return only those that have either an “**I**” `somewhere in their name` or a `job title` **ending** with “**ER**”:

|ename  |    job|
|:-----:|:----------:|
|SM**I**TH  | CLERK|
|JONES  | MANAG**ER**|
|CLARK  | MANAG**ER**|
|K**I**NG   | PRESIDENT|
|M**I**LLER | CLERK|

**(5 rows)**

## Solution

Use the [LIKE](https://github.com/lpinzari/sql-psql-udy/blob/master/01_basic_sql/15_like.md) operator in conjunction with the SQL wildcard operator (`%`):

```SQL
SELECT ename, job
  FROM emp
 WHERE deptno in (10,20)
   AND (ename like '%I%' or job like '%ER');
```

## Discussion

When used in a **LIKE** `pattern-match operation`, the percent (`%`) operator **matches any sequence of characters**. Most SQL implementations also provide the underscore (“`_`”) operator to match a single character. By enclosing the search pattern “I” with `%` operators, any string that contains an “I” (at any position) will be returned. If you do not enclose the search pattern with `%`, then where you place the operator will affect the results of the query. For example, to find job titles that end in “ER,” prefix the %
