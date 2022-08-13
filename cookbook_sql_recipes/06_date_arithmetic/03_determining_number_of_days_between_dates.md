# Determining the Number of Days Between Two Dates

You want to **find the difference between two dates** and **represent the result in days**.

## Problem

For example, you want to find the difference in days between the `HIREDATEs` of employee `ALLEN` and employee `WARD`.

```SQL
SELECT ename, hiredate
  FROM emp
 WHERE ename = 'ALLEN' OR ename = 'WARD'
 ORDER BY hiredate;
```

|ename |  hiredate|
|:----:|:---------:|
|ALLEN | 2006-01-20|
|WARD  | 2006-02-22|

The number of days is therefore:

|days|
|:----:|
|  33|


## Solution


```SQL
WITH w AS (
  SELECT hiredate AS ward_hd
    FROM emp
   WHERE ename = 'WARD'
),
a AS (
  SELECT hiredate AS allen_hd
    FROM emp
   WHERE ename = 'ALLEN'
)
SELECT ward_hd  - allen_hd  AS days
  FROM w,a;
```

**TIMESTAMP** format solution:

```SQL
WITH w AS (
  SELECT hiredate AS ward_hd
    FROM emp
   WHERE ename = 'WARD'
),
a AS (
  SELECT hiredate AS allen_hd
    FROM emp
   WHERE ename = 'ALLEN'
)
SELECT DATE_PART('day',ward_hd :: TIMESTAMP - allen_hd :: TIMESTAMP) AS days
  FROM w,a;
```


## DISCUSSION

**CTE** `w` and `a` return the `HIREDATEs` for employees `WARD` and `ALLEN`, respectively. For example:


```SQL
WITH w AS (
  SELECT hiredate AS ward_hd
    FROM emp
   WHERE ename = 'WARD'
),
a AS (
  SELECT hiredate AS allen_hd
    FROM emp
   WHERE ename = 'ALLEN'
)
SELECT *
  FROM w,a;
```

|ward_hd   |  allen_hd|
|:---------:|:----------:|
|2006-02-22 | 2006-01-20|

You’ll notice a Cartesian product is created, because there is no join specified between X and Y. In this case, the lack of a join is harmless as the cardinalities for X and Y are both 1; thus, the result set will ultimately have one row (obviously, because 1 × 1 = 1).

```SQL
WITH w AS (
  SELECT hiredate AS ward_hd
    FROM emp
   WHERE ename = 'WARD'
),
a AS (
  SELECT hiredate AS allen_hd
    FROM emp
   WHERE ename = 'ALLEN'
)
SELECT ward_hd  - allen_hd  AS days,
       pg_typeof(ward_hd - allen_hd)
  FROM w,a;
```

|days | pg_typeof|
|:---:|:--------:|
|  33 | integer|

To get the difference in days, simply subtract one of the two values returned from the other.

```SQL
WITH w AS (
  SELECT hiredate AS ward_hd
    FROM emp
   WHERE ename = 'WARD'
),
a AS (
  SELECT hiredate AS allen_hd
    FROM emp
   WHERE ename = 'ALLEN'
)
SELECT ward_hd :: TIMESTAMP  - allen_hd :: TIMESTAMP  AS days,
       pg_typeof(ward_hd :: TIMESTAMP - allen_hd :: TIMESTAMP)
  FROM w,a;
```

|days   | pg_typeof|
|:------:|:--------:|
|33 days | interval|

In PostgreSQL, if you subtract one datetime value (TIMESTAMP data type) from another, you will get an `INTERVAL` value.


```SQL
WITH w AS (
  SELECT hiredate AS ward_hd
    FROM emp
   WHERE ename = 'WARD'
),
a AS (
  SELECT hiredate AS allen_hd
    FROM emp
   WHERE ename = 'ALLEN'
)
SELECT DATE_PART('day',ward_hd :: TIMESTAMP - allen_hd :: TIMESTAMP) AS days,
       pg_typeof(DATE_PART('day',ward_hd :: TIMESTAMP - allen_hd :: TIMESTAMP))
  FROM w,a;
```

|days |    pg_typeof|
|:---:|:---------------:|
|  33 | double precision|

So you can use `DATE_PART` function to extact the number of days, but it returns **the number of full days between the dates**.
