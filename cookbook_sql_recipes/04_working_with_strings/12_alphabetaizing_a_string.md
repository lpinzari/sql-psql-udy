# Alphabetizing a String

You want **alphabetize the individual characters within strings** in your tables.

## Problem

Consider the following result set:

```SQL
SELECT ename
  FROM emp
 ORDER BY ename;
```

|ename|
|:------:|
|ADAMS|
|ALLEN|
|BLAKE|
|CLARK|
|FORD|
|JAMES|
|JONES|
|KING|
|MARTIN|
|MILLER|
|SCOTT|
|SMITH|
|TURNER|
|WARD|

**(14 rows)**

You would like the result to be:

|old_name | new_name|
|:-------:|:--------:|
|ADAMS    | AADMS|
|ALLEN    | AELLN|
|BLAKE    | ABEKL|
|CLARK    | ACKLR|
|FORD     | DFOR|
|JAMES    | AEJMS|
|JONES    | EJNOS|
|KING     | GIKN|
|MARTIN   | AIMNRT|
|MILLER   | EILLMR|
|SCOTT    | COSTT|
|SMITH    | HIMST|
|TURNER   | ENRRTU|
|WARD     | ADRW|


## Solution

PostgreSQL has now added `STRING_AGG` to order characters within a string.

```SQL
SELECT ename AS old_name,
       STRING_AGG(c,'' ORDER BY c) AS new_name
  FROM (
         SELECT a.ename,
                SUBSTR(a.ename,iter.pos,1) AS c
           FROM emp a,
                (SELECT id AS pos
                   FROM t10) iter
          WHERE iter.pos <= length(a.ename)
          ORDER BY 1,2
        ) x
 GROUP BY ename;
```

**CTE**

```SQL
WITH x AS (
  SELECT a.ename,
         SUBSTR(a.ename,iter.pos,1) AS c
    FROM emp a,
         (SELECT id AS pos
            FROM t10) iter
   WHERE iter.pos <= LENGTH(a.ename)
   ORDER BY 1,2
)
SELECT ename AS old_name,
       STRING_AGG(c,'' ORDER BY c) AS new_name
  FROM x
 GROUP BY ename;
```

Using the **genrate_series** function:

```SQL
WITH max_length AS (
  SELECT MAX(LENGTH(e.ename)) m
    FROM emp e
),
x AS (
  SELECT a.ename,
         SUBSTR(a.ename,iter.pos,1) AS c
    FROM emp a,
         (SELECT generate_series(1,(SELECT * FROM max_length)) AS pos) iter
   WHERE iter.pos <= LENGTH(a.ename)
   ORDER BY 1,2
)
SELECT ename AS old_name,
       STRING_AGG(c,'' ORDER BY c) AS new_name
  FROM x
 GROUP BY ename;
```

## Discussion

The first and most important step in this solution is to walk the string.

Use a Cartesian product to generate the number of rows needed to walk through the string.

```SQL
SELECT a.ename, iter.pos,
  FROM emp a,
       (SELECT id AS pos
          FROM t10) iter
  WHERE iter.pos <= LENGTH(a.ename)
  ORDER BY a.ename,iter.pos;
```

|ename  | pos|
|:-----:|:---:|
|ADAMS  |   1|
|ADAMS  |   2|
|ADAMS  |   3|
|ADAMS  |   4|
|ADAMS  |   5|
|ALLEN  |   1|
|ALLEN  |   2|
|ALLEN  |   3|
|ALLEN  |   4|
|ALLEN  |   5|
|BLAKE  |   1|
|BLAKE  |   2|
|BLAKE  |   3|
|BLAKE  |   4|
|BLAKE  |   5|
|CLARK  |   1|
|CLARK  |   2|
|CLARK  |   3|
|CLARK  |   4|
|CLARK  |   5|
|FORD   |   1|
|FORD   |   2|
|FORD   |   3|
|FORD   |   4|
|JAMES  |   1|
|JAMES  |   2|
|JAMES  |   3|
|JAMES  |   4|
|JAMES  |   5|
|JONES  |   1|
|JONES  |   2|
|JONES  |   3|
|JONES  |   4|
|JONES  |   5|
|KING   |   1|
|KING   |   2|
|KING   |   3|
|KING   |   4|
|MARTIN |   1|
|MARTIN |   2|
|MARTIN |   3|
|MARTIN |   4|
|MARTIN |   5|
|MARTIN |   6|
|MILLER |   1|
|MILLER |   2|
|MILLER |   3|
|MILLER |   4|
|MILLER |   5|
|MILLER |   6|
|SCOTT  |   1|
|SCOTT  |   2|
|SCOTT  |   3|
|SCOTT  |   4|
|SCOTT  |   5|
|SMITH  |   1|
|SMITH  |   2|
|SMITH  |   3|
|SMITH  |   4|
|SMITH  |   5|
|TURNER |   1|
|TURNER |   2|
|TURNER |   3|
|TURNER |   4|
|TURNER |   5|
|TURNER |   6|
|WARD   |   1|
|WARD   |   2|
|WARD   |   3|
|WARD   |   4|

**(70 rows)**

```SQL
SELECT a.ename,
       SUBSTR(a.ename,iter.pos,1) AS c,
       iter.pos
  FROM emp a,
       (SELECT id AS pos
          FROM t10) iter
 WHERE iter.pos <= length(a.ename)
 ORDER BY 1,3;
```

The partial output is:

|ename  | c | pos|
|:-----:|:--:|:----:|
|ADAMS  | A |   1|
|ADAMS  | D |   2|
|ADAMS  | A |   3|
|ADAMS  | M |   4|
|ADAMS  | S |   5|
|ALLEN  | A |   1|
|ALLEN  | L |   2|
|ALLEN  | L |   3|
|ALLEN  | E |   4|
|ALLEN  | N |   5|
|BLAKE  | B |   1|
|BLAKE  | L |   2|
|BLAKE  | A |   3|
|BLAKE  | K |   4|
|BLAKE  | E |   5|
|....|....|....|

Let's sort the result by characters:

```SQL
SELECT a.ename,
       SUBSTR(a.ename,iter.pos,1) AS c,
       iter.pos
  FROM emp a,
       (SELECT id AS pos
          FROM t10) iter
 WHERE iter.pos <= length(a.ename)
 ORDER BY 1,2;
```

|ename  | c | pos|
|:-----:|:--:|:----:|
|ADAMS  | A |   3|
|ADAMS  | A |   1|
|ADAMS  | D |   2|
|ADAMS  | M |   4|
|ADAMS  | S |   5|
|ALLEN  | A |   1|
|ALLEN  | E |   4|
|ALLEN  | L |   3|
|ALLEN  | L |   2|
|ALLEN  | N |   5|
|BLAKE  | A |   3|
|BLAKE  | B |   1|
|BLAKE  | E |   5|
|BLAKE  | K |   4|
|BLAKE  | L |   2|

The final step is to `GROUP BY` **ename** and use the `STRING_AGG` function to concatenate the single characters in column `c` sorted in alphabetical order.

```SQL
SELECT ename AS old_name,
       STRING_AGG(c,'' ORDER BY c) AS new_name
  FROM (
         SELECT a.ename,
                SUBSTR(a.ename,iter.pos,1) AS c
           FROM emp a,
                (SELECT id AS pos
                   FROM t10) iter
          WHERE iter.pos <= length(a.ename)
          ORDER BY 1,2
        ) x
 GROUP BY ename;
```

|old_name | new_name|
|:-------:|:-------:|
|ADAMS    | AADMS|
|ALLEN    | AELLN|
|BLAKE    | ABEKL|
|CLARK    | ACKLR|
|FORD     | DFOR|
|JAMES    | AEJMS|
|JONES    | EJNOS|
|KING     | GIKN|
|MARTIN   | AIMNRT|
|MILLER   | EILLMR|
|SCOTT    | COSTT|
|SMITH    | HIMST|
|TURNER   | ENRRTU|
|WARD     | ADRW|
