# Walking a String Problem
You want to traverse a string to return each character as a row, but SQL lacks a loop operation. For example, you want to display the `ENAME` “**KING**” from table `EMP` as **four rows**, where each row contains just characters from KING.

## Solution

Use a Cartesian product to generate the number of rows needed to return each character of a string on its own line. Then use your DBMS’s built-in string parsing function to extract the characters you are interested in (SQL Server users will use SUBSTRING instead of `SUBSTR` and DATALENGTH instead of `LENGTH`):

```SQL
SELECT SUBSTR(e.ename,iter.pos,1) AS c
  FROM (SELECT ename from emp where ename = 'KING') e,
       (SELECT id AS pos FROM t10) iter
 WHERE iter.pos <= LENGTH(e.ename);
```

**Output**

|c|
|:--:|
|K|
|I|
|N|
|G|

Using the **genrate_series** function.

```SQL
WITH max_length AS (
  SELECT MAX(LENGTH(e.ename)) m
    FROM emp e
)
SELECT SUBSTR(e.ename,iter.pos,1) AS c
  FROM (SELECT ename from emp where ename = 'KING') e,
       (SELECT generate_series(1,(SELECT * FROM max_length)) AS pos) iter
 WHERE iter.pos <= LENGTH(e.ename);
```


Using `PlPgsql` and a temporary table.

```SQL
CREATE TABLE chrs (ch CHAR(1));

do $$
declare
  name text;
  n int;
begin
   name := (SELECT ename FROM emp WHERE ename = 'KING');
   n := LENGTH(name);
   for iter in 1..n loop
       INSERT INTO chrs VALUES(SUBSTR(name,iter,1));
   end loop;
end;$$;
```

## Discussion

The key to iterating through a string’s characters is to **join against a table that has enough rows to produce the required number of iterations**. This example uses table `T10`, which contains **10 rows** (it has one column, `ID`, holding the values `1` through `10`). The maximum number of rows that can be returned from this query is `10`.

The following example shows the Cartesian product between `E` and `ITER` (i.e., between the specific name and the 10 rows from T10) without parsing `ENAME`:


```SQL
SELECT ename,
       iter.pos
  FROM (SELECT ename FROM emp WHERE ename = 'KING') e,
       (SELECT id AS pos FROM t10) iter;
```

|ename | pos|
|:----:|:---:|
|KING  |   1|
|KING  |   2|
|KING  |   3|
|KING  |   4|
|KING  |   5|
|KING  |   6|
|KING  |   7|
|KING  |   8|
|KING  |   9|
|KING  |  10|

**(10 rows)**

The cardinality of inline view `E` is **1**, and the cardinality of inline view `ITER` is **10**. The `Cartesian product` is then **10** rows. Generating such a product is the first step in mimicking a loop in SQL.

> Note: It is common practice to refer to table T10 as a “pivot” table.


The solution uses a `WHERE` clause to **break out of the loop after four rows have been returned**. To restrict the result set to the same number of rows as there are characters in the name, that `WHERE` clause specifies `ITER.POS <= LENGTH(E. ENAME)` as the condition:

```SQL
SELECT ename,
       iter.pos
  FROM (SELECT ename FROM emp WHERE ename = 'KING') e,
       (SELECT id AS pos FROM t10) iter
 WHERE iter.pos <= LENGTH(e.ename);
```

|ename | pos|
|:----:|:---:|
|KING  |   1|
|KING  |   2|
|KING  |   3|
|KING  |   4|

Now that you have one row for each character in `E.ENAME`, you can use `ITER.POS` as a parameter to `SUBSTR`, **allowing you to navigate through the characters in the string**.

`ITER.POS` increments with each row, and thus each row can be made to return a successive character from `E.ENAME`.

```SQL
SELECT SUBSTR(e.ename,iter.pos,1) AS c
  FROM (SELECT ename from emp where ename = 'KING') e,
       (SELECT id AS pos FROM t10) iter
 WHERE iter.pos <= LENGTH(e.ename);
```

**Output**

|c|
|:--:|
|K|
|I|
|N|
|G|

This is how the solution example works.

Depending on what you are trying to accomplish, you may or may not need to generate a row for every single character in a string. The following query is an example of walking `E.ENAME` and exposing different portions (more than a single character) of the string:


```SQL
SELECT SUBSTR(e.ename,iter.pos) a,
       SUBSTR(e.ename,length(e.ename)-iter.pos+1) b
  FROM (SELECT ename FROM emp WHERE ename = 'KING') e,
       (SELECT id AS pos FROM t10) iter
 WHERE iter.pos <= LENGTH(e.ename);
```

|a   |  b|
|:---:|:-----:|
|KING | G|
|ING  | NG|
|NG   | ING|
|G    | KING|


## Generate series

This solution does not use the pivot table `t10` but generates a sequence of numbers using the `generate_series` function provided by PostgreSQL.

```SQL
WITH max_length AS (
  SELECT MAX(LENGTH(e.ename)) m
    FROM emp e
)
SELECT generate_series(1,(SELECT * FROM max_length)) AS pos;
```

|pos|
|:---:|
|  1|
|  2|
|  3|
|  4|
|  5|
|  6|

The maximum length of `ename` in table `emp` is 6. Thus, the `generate_series` function will generate a table with a single integer column named `pos` to iterate over the string `ename`. 

## PLpgsql Solution

```SQL
do $$
declare
  name text;
  n int;
begin
   name := (SELECT ename FROM emp WHERE ename = 'KING');
   n := LENGTH(name);
   for iter in 1..n loop
       raise notice '%', SUBSTR(name,iter,1);
   end loop;
end;$$;
```

```console
cookbook=> do $$
cookbook$> declare
cookbook$>   name text;
cookbook$>   n int;
cookbook$> begin
cookbook$>    name := (SELECT ename FROM emp WHERE ename = 'KING');
cookbook$>    n := LENGTH(name);
cookbook$>    for iter in 1..n loop
cookbook$>        raise notice '%', SUBSTR(name,iter,1);
cookbook$>    end loop;
cookbook$> end;$$;
NOTICE:  K
NOTICE:  I
NOTICE:  N
NOTICE:  G
DO
```


```SQL
CREATE TABLE chrs (ch CHAR(1));
```

```SQL
do $$
declare
  name text;
  n int;
begin
   name := (SELECT ename FROM emp WHERE ename = 'KING');
   n := LENGTH(name);
   for iter in 1..n loop
       INSERT INTO chrs VALUES(SUBSTR(name,iter,1));
   end loop;
end;$$;
```
```SQL
SELECT * FROM chrs;
```

| ch  |
|:--:|
| K|
| I|
| N|
| G|
