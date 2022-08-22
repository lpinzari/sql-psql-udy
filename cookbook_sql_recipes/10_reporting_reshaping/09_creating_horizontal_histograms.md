# Creating Horizontal Histograms

You want to use SQL to generate **histograms that extend horizontally**.

## Problem

For example, you want to display the `number of employees` in **each department** as a `horizontal histogram` with **each employee represented by** an instance of `*`.

```SQL
SELECT deptno,
       COUNT(*) AS cnt
  FROM emp
 GROUP BY deptno
 ORDER BY deptno;
```

|deptno | cnt|
|:-----:|:--:|
|    10 |   3|
|    20 |   5|
|    30 |   6|

You want to return the following result set:

```console
deptno |  cnt
--------+--------
    10 | ***
    20 | *****
    30 | ******
```


## Solution

The key to this solution is to use the aggregate function `COUNT` and use `GROUP BY DEPTNO` to **determine the number of employees** in each `DEPTNO`. The value returned by `COUNT` is then passed to a string function that generates a series of `*` characters.

Use the `LPAD` function to generate the needed strings of `*` characters:

```SQL
SELECT deptno,
       LPAD('*',COUNT(*)::INTEGER,'*') AS cnt
  FROM emp
 GROUP BY deptno
 ORDER BY deptno;
```

## Discussion

The first step is to count the number of employees in each department:

```SQL
SELECT deptno,
       COUNT(*) AS cnt
  FROM emp
 GROUP BY deptno
 ORDER BY deptno;
```

|deptno | cnt|
|:-----:|:--:|
|    10 |   3|
|    20 |   5|
|    30 |   6|

The next step is to use the value returned by `COUNT` to control the number of `*` characters to return for each department. Simply pass `COUNT( * )` as an argument to the string function `LPAD` to return the desired number of `*`:

```SQL
SELECT deptno,
       LPAD('*',COUNT(*)::INTEGER,'*') AS cnt
  FROM emp
 GROUP BY deptno
 ORDER BY deptno;
```

This `CASTING`,(**::**) is necessary because PostgreSQL requires the numeric argument to `LPAD` to be an integer.
