# Using SQL to generate Random Sampling record INSERT statements

You want to create `dynamic SQL statements`, to populate your tables for testing purposes.


## Problem

You want to accomplish the following task:

1. Generate a table with `5` random records from the `emp` table using a `uniform sampling with replacement` and `uniform sampling without replacemnt`.
2. Generate a sql script to populate an empty table `emp_2` with random records taken from table `emp`. The sampling method is `uniform sampling without replacement`.

The table `emp_2` has the following structure:

```SQL
CREATE TABLE emp_2 (
  empno INTEGER PRIMARY KEY,
  ename VARCHAR(10),
  hiredate DATE
);
```

The script should be something like this:

```console
inserts
-----------------------------------------
INSERT INTO emp_2(empno,ename,hiredate)+
VALUES                                 +
(7499, ALLEN, 2006-01-20),             +
(7566, JONES, 2006-04-02),             +
(7698, BLAKE, 2006-05-01),             +
(7788, SCOTT, 2007-12-09),             +
(7839, KING, 2006-11-17);
(1 row)
```

## Solution


**Problem 1**

- **Sampling 5 records with replacement**:

```SQL
WITH samples AS (
  SELECT  t.id
        , t.rw_nm * FLOOR(RANDOM() * 14) + 1 AS rw_nm
    FROM (SELECT *
            FROM GENERATE_SERIES(1,5) AS id, (SELECT 1 AS rw_nm) x ) t
),
emp_rnk AS (
  SELECT *
        , ROW_NUMBER() OVER(ORDER BY empno) AS rw_nm
    FROM emp
)
SELECT er.*
  FROM emp_rnk er
 INNER JOIN samples USING(rw_nm);
```

- **Sampling 5 records without replacement**:

```SQL
WITH emp_rnk AS (
  SELECT *
        , ROW_NUMBER() OVER(ORDER BY empno) AS rw_nm
        , RANDOM() AS rnd
    FROM emp
)
SELECT *
  FROM emp_rnk
 ORDER BY rnd
 LIMIT 5;
```

Equivalent to:

```SQL
SELECT *
  FROM emp
 ORDER BY RANDOM()
 LIMIT 5;
```



### Problem 2

```SQL
WITH sample AS (
  SELECT *
    FROM emp
   ORDER BY RANDOM()
   LIMIT 5
),
sample_data AS (
  SELECT empno,
        chr(10) || '(' || s.empno || ', ' || s.ename || ', ' || s.hiredate::VARCHAR || ')' AS data
    FROM sample s
)
SELECT 'INSERT INTO emp_2(empno,ename,hiredate)' || chr(10) ||
       'VALUES' || STRING_AGG(sd.data,','ORDER BY sd.empno) || ';' AS inserts
  FROM sample_data sd;
```



## Discussion

```SQL
SELECT RANDOM();
```

The `RANDOM()` function generates a random value in the range 0.0 <= x < 1.0.

```console
random
-------------------
0.102957483381033
(1 row)
```

To create a random integer number between two values (inclusive range) `[a,b]`, you can use the following formula:

```SQL
SELECT FLOOR(RANDOM() * (b-a+1) ) + a;
```
Where `a` is the smallest number and `b` is the largest number that you want to generate a random number for.

The number of records in the `emp` table is:

```SQL
SELECT COUNT(*) FROM emp;
```

```console
count
-------
   14
(1 row)
```

The generation of a random number value in the range `1 - 14` can be accomplished with the following sql statement:

```SQL
SELECT FLOOR(RANDOM() * (14 - 1 + 1)) + 1;
```

It's equivalent to:

```SQL
SELECT FLOOR(RANDOM() * 14) + 1 AS rnd;
```

The expression `RANDOM() * 14` generate a random number between (0.0 and 13.9999), the function `FLOOR` round to the smallest integer value. Therefore, the result `FLOOR(RANDOM()*14)` returns an integer value between (0 - 13). Lastly, we add `1` to the result.

Next, generate five random numbers between `1-14`.

```SQL
SELECT *
  FROM GENERATE_SERIES(1,5) AS id, (SELECT 1 AS rw_nm) x;
```

```console
id | rw_nm
---+-------
 1 |     1
 2 |     1
 3 |     1
 4 |     1
 5 |     1
```

```SQL
SELECT  t.id
      , t.rw_nm * FLOOR(RANDOM() * 14) + 1 AS rw_nm
  FROM (SELECT *
          FROM GENERATE_SERIES(1,5) AS id, (SELECT 1 AS rw_nm) x ) t;
```

```console
id | rw_nm
---+-------
 1 |     2
 2 |     3
 3 |     9
 4 |     1
 5 |    11
(5 rows)
```

If we execute the query again, the `RANDOM()` function will generate other 5 random numbers in the range `1-14`.

```console
id | rw_nm
---+-------
 1 |     1
 2 |     9
 3 |    11
 4 |    10
 5 |     7
(5 rows)
```

```SQL
SELECT *
      , ROW_NUMBER() OVER(ORDER BY empno) AS rw_nm
  FROM emp;  
```

```console
empno | ename  |    job    | mgr  |  hiredate  | sal  | comm | deptno | rw_nm
------+--------+-----------+------+------------+------+------+--------+-------
 7369 | SMITH  | CLERK     | 7902 | 2015-12-17 |  800 |      |     20 |     1
 7499 | ALLEN  | SALESMAN  | 7698 | 2006-01-20 | 1600 |  300 |     30 |     2
 7521 | WARD   | SALESMAN  | 7698 | 2006-02-22 | 1250 |  500 |     30 |     3
 7566 | JONES  | MANAGER   | 7839 | 2006-04-02 | 2975 |      |     20 |     4
 7654 | MARTIN | SALESMAN  | 7698 | 2006-09-28 | 1250 | 1400 |     30 |     5
 7698 | BLAKE  | MANAGER   | 7839 | 2006-05-01 | 2850 |      |     30 |     6
 7782 | CLARK  | MANAGER   | 7839 | 2006-06-09 | 2450 |      |     10 |     7
 7788 | SCOTT  | ANALYST   | 7566 | 2007-12-09 | 3000 |      |     20 |     8
 7839 | KING   | PRESIDENT |      | 2006-11-17 | 5000 |      |     10 |     9
 7844 | TURNER | SALESMAN  | 7698 | 2006-09-08 | 1500 |    0 |     30 |    10
 7876 | ADAMS  | CLERK     | 7788 | 2008-01-12 | 1100 |      |     20 |    11
 7900 | JAMES  | CLERK     | 7698 | 2006-12-03 |  950 |      |     30 |    12
 7902 | FORD   | ANALYST   | 7566 | 2006-12-03 | 3000 |      |     20 |    13
 7934 | MILLER | CLERK     | 7782 | 2007-01-23 | 1300 |      |     10 |    14
```

The final step is to wrap the two queries in two CTEs and join the results using the `rw_nm` column.

```SQL
WITH samples AS (
  SELECT  t.id
        , t.rw_nm * FLOOR(RANDOM() * 14) + 1 AS rw_nm
    FROM (SELECT *
            FROM GENERATE_SERIES(1,5) AS id, (SELECT 1 AS rw_nm) x ) t
),
emp_rnk AS (
  SELECT *
        , ROW_NUMBER() OVER(ORDER BY empno) AS rw_nm
    FROM emp
)
SELECT er.*
  FROM emp_rnk er
 INNER JOIN samples USING(rw_nm);
```

```console
empno | ename  |   job    | mgr  |  hiredate  | sal  | comm | deptno | rw_nm
------+--------+----------+------+------------+------+------+--------+-------
 7369 | SMITH  | CLERK    | 7902 | 2015-12-17 |  800 |      |     20 |     1
 7654 | MARTIN | SALESMAN | 7698 | 2006-09-28 | 1250 | 1400 |     30 |     5
 7698 | BLAKE  | MANAGER  | 7839 | 2006-05-01 | 2850 |      |     30 |     6
 7782 | CLARK  | MANAGER  | 7839 | 2006-06-09 | 2450 |      |     10 |     7
 7844 | TURNER | SALESMAN | 7698 | 2006-09-08 | 1500 |    0 |     30 |    10
(5 rows)
```

Executing the query again:

```console
empno | ename  |   job    | mgr  |  hiredate  | sal  | comm | deptno | rw_nm
-------+--------+----------+------+------------+------+------+--------+-------
 7654 | MARTIN | SALESMAN | 7698 | 2006-09-28 | 1250 | 1400 |     30 |     5
 7698 | BLAKE  | MANAGER  | 7839 | 2006-05-01 | 2850 |      |     30 |     6
 7876 | ADAMS  | CLERK    | 7788 | 2008-01-12 | 1100 |      |     20 |    11
 7876 | ADAMS  | CLERK    | 7788 | 2008-01-12 | 1100 |      |     20 |    11
 7900 | JAMES  | CLERK    | 7698 | 2006-12-03 |  950 |      |     30 |    12
(5 rows)
```

We observe there is a duplicate. The sampling method performed in this case is `sampling with replacement`. If we want to **sample the rows without replacement**  a possible solution is to use the `ORDER BY RANDOM()`.


```SQL
WITH emp_rnk AS (
  SELECT *
        , ROW_NUMBER() OVER(ORDER BY empno) AS rw_nm
    FROM emp
)
SELECT *
  FROM emp_rnk
 ORDER BY RANDOM()
 LIMIT 5;
```

```console
empno | ename |    job    | mgr  |  hiredate  | sal  | comm | deptno | rw_nm
-------+-------+-----------+------+------------+------+------+--------+-------
 7788 | SCOTT | ANALYST   | 7566 | 2007-12-09 | 3000 |      |     20 |     8
 7566 | JONES | MANAGER   | 7839 | 2006-04-02 | 2975 |      |     20 |     4
 7900 | JAMES | CLERK     | 7698 | 2006-12-03 |  950 |      |     30 |    12
 7839 | KING  | PRESIDENT |      | 2006-11-17 | 5000 |      |     10 |     9
 7782 | CLARK | MANAGER   | 7839 | 2006-06-09 | 2450 |      |     10 |     7
(5 rows)
```

Executing the query again:


```console
empno | ename |   job   | mgr  |  hiredate  | sal  | comm | deptno | rw_nm
-------+-------+---------+------+------------+------+------+--------+-------
 7902 | FORD  | ANALYST | 7566 | 2006-12-03 | 3000 |      |     20 |    13
 7900 | JAMES | CLERK   | 7698 | 2006-12-03 |  950 |      |     30 |    12
 7698 | BLAKE | MANAGER | 7839 | 2006-05-01 | 2850 |      |     30 |     6
 7782 | CLARK | MANAGER | 7839 | 2006-06-09 | 2450 |      |     10 |     7
 7369 | SMITH | CLERK   | 7902 | 2015-12-17 |  800 |      |     20 |     1
(5 rows)
```

What's happening behind the scene ?


Basically the `ORDER BY RANDOM()` generates a uniform random number in the range `[0.0 1)` for each row in the table and then sort the table in descending order of random values.

The `ORDER BY RANDOM()` is equivalent to:

```SQL
WITH emp_rnk AS (
  SELECT *
        , ROW_NUMBER() OVER(ORDER BY empno) AS rw_nm
        , RANDOM() AS rnd
    FROM emp
)
SELECT *
  FROM emp_rnk
 ORDER BY rnd
 LIMIT 5;
```

```console
empno | ename  |    job    | mgr  |  hiredate  | sal  | comm | deptno | rw_nm |         rnd
-------+--------+-----------+------+------------+------+------+--------+-------+----------------------
 7566 | JONES  | MANAGER   | 7839 | 2006-04-02 | 2975 |      |     20 |     4 | 0.000870254822075367
 7839 | KING   | PRESIDENT |      | 2006-11-17 | 5000 |      |     10 |     9 |   0.0580185051076114
 7788 | SCOTT  | ANALYST   | 7566 | 2007-12-09 | 3000 |      |     20 |     8 |    0.133837159723043
 7654 | MARTIN | SALESMAN  | 7698 | 2006-09-28 | 1250 | 1400 |     30 |     5 |    0.166226443834603
 7934 | MILLER | CLERK     | 7782 | 2007-01-23 | 1300 |      |     10 |    14 |    0.174267940688878
(5 rows)
```

It's like shuffling a deck of card and pick the first 5 cards from the top of the deck.
In terms of computational effort we have to execute the `RANDOM` function as many times as the number of records in the table and it may not be as efficient as the `sampling` with replacement. However, the `sampling with replacement` approximately behaves as the `sampling without replacement` for large sample population.

If we ran the query without the `LIMIT` clause, the output table is the entire population.

```SQL
WITH emp_rnk AS (
  SELECT *
        , ROW_NUMBER() OVER(ORDER BY empno) AS rw_nm
        , RANDOM() AS rnd
    FROM emp
)
SELECT *
  FROM emp_rnk
 ORDER BY rnd;
```

```console
empno | ename  |    job    | mgr  |  hiredate  | sal  | comm | deptno | rw_nm |        rnd
-------+--------+-----------+------+------------+------+------+--------+-------+--------------------
 7934 | MILLER | CLERK     | 7782 | 2007-01-23 | 1300 |      |     10 |    14 | 0.0152153079397976
 7788 | SCOTT  | ANALYST   | 7566 | 2007-12-09 | 3000 |      |     20 |     8 | 0.0435709408484399
 7902 | FORD   | ANALYST   | 7566 | 2006-12-03 | 3000 |      |     20 |    13 | 0.0465461630374193
 7521 | WARD   | SALESMAN  | 7698 | 2006-02-22 | 1250 |  500 |     30 |     3 | 0.0768986749462783
 7654 | MARTIN | SALESMAN  | 7698 | 2006-09-28 | 1250 | 1400 |     30 |     5 |    0.1196253541857
 7499 | ALLEN  | SALESMAN  | 7698 | 2006-01-20 | 1600 |  300 |     30 |     2 |  0.138268266804516
 7900 | JAMES  | CLERK     | 7698 | 2006-12-03 |  950 |      |     30 |    12 |  0.205794923007488
 7782 | CLARK  | MANAGER   | 7839 | 2006-06-09 | 2450 |      |     10 |     7 |  0.438338866923004
 7698 | BLAKE  | MANAGER   | 7839 | 2006-05-01 | 2850 |      |     30 |     6 |  0.596383099444211
 7369 | SMITH  | CLERK     | 7902 | 2015-12-17 |  800 |      |     20 |     1 |  0.627175696659833
 7844 | TURNER | SALESMAN  | 7698 | 2006-09-08 | 1500 |    0 |     30 |    10 |  0.651212165132165
 7876 | ADAMS  | CLERK     | 7788 | 2008-01-12 | 1100 |      |     20 |    11 |  0.656082555651665
 7839 | KING   | PRESIDENT |      | 2006-11-17 | 5000 |      |     10 |     9 |  0.739599391818047
 7566 | JONES  | MANAGER   | 7839 | 2006-04-02 | 2975 |      |     20 |     4 |  0.973754359409213
```

## Problem 2

First we generate the population sampling table.

```SQL
WITH sample AS (
  SELECT *
    FROM emp
   ORDER BY RANDOM()
   LIMIT 5
)

SELECT *
  FROM sample;
```

Next, generate an insert script for the following columns: `empno, ename, hiredate`.

```SQL
WITH sample AS (
  SELECT *
    FROM emp
   ORDER BY RANDOM()
   LIMIT 5
),
sample_data AS (
  SELECT empno,
        chr(10) || '(' || s.empno || ', ' || s.ename || ', ' || s.hiredate::VARCHAR || ')' AS data
    FROM sample s
)
SELECT 'INSERT INTO emp_2(empno,ename,hiredate)' || chr(10) ||
       'VALUES' || STRING_AGG(sd.data,','ORDER BY sd.empno) || ';' AS inserts
  FROM sample_data sd;
```

```console
inserts
-----------------------------------------
INSERT INTO emp_2(empno,ename,hiredate)+
VALUES                                 +
(7499, ALLEN, 2006-01-20),             +
(7566, JONES, 2006-04-02),             +
(7698, BLAKE, 2006-05-01),             +
(7788, SCOTT, 2007-12-09),             +
(7839, KING, 2006-11-17);
(1 row)
```
