# Extracting the nth Delimited Substring

You want to **extract a specified, delimited substring from a string**.

## Problem

Consider the following view `v`, which generates source data for this problem:

```SQL
CREATE VIEW v AS
    SELECT 'mo,larry,curly' AS name
     UNION ALL
    SELECT 'tina,gina,jaunita,regina,leena' AS name;
```
Output from the view is as follows:

```SQL
SELECT * FROM v;
```

|name|
|:------------------------------:|
|mo,**larry**,curly|
|tina,**gina**,jaunita,regina,leena|

You would like to extract the second name in each row, so the final result set would be as follows:

|name|
|:-----:|
|larry|
|gina|

## Solution

The key to solving this problem is to return each name as an individual row while preserving the order in which the name exists in the list. Exactly how you do these things depends on which DBMS you are using.

**PostgreSQL**

Use the function `SPLIT_PART` to help return each individual name as a row:

```SQL
SELECT name
  FROM (
         SELECT iter.pos, split_part(src.name,',',iter.pos) AS name
           FROM (SELECT id AS pos FROM t10) iter,
                (SELECT CAST(name AS TEXT) AS name FROM v) src
          WHERE iter.pos <=
                LENGTH(src.name) - LENGTH(REPLACE(src.name,',','')) + 1
       ) x
WHERE pos = 2;
```

**CTE**

```SQL
WITH x AS (
  SELECT iter.pos, SPLIT_PART(src.name,',',iter.pos) AS name
    FROM (SELECT id AS pos FROM t10) iter,
         (SELECT CAST(name AS TEXT) AS name FROM v) src
   WHERE iter.pos <=
         LENGTH(src.name) - LENGTH(REPLACE(src.name,',','')) + 1
)
SELECT name
  FROM x
 WHERE pos = 2;
```

## Discussion

The cartesian product:

```SQL
SELECT iter.pos, src.name,
       LENGTH(src.name) len_name,
       REPLACE(src.name,',','') As replaced,
       LENGTH(REPLACE(src.name,',','')) AS len_replaced,
       LENGTH(src.name) - LENGTH(REPLACE(src.name,',','')) + 1 AS expr
  FROM (SELECT id AS pos FROM t10) iter,
       (SELECT CAST(name AS TEXT) AS name
          FROM v) src
 ORDER BY src.name;
```

|pos |              name              | len_name |          replaced          | len_replaced | expr|
|:----:|:--------------------------------:|:----------:|:----------------------------:|:--------------:|:------:|
|1 | mo,larry,curly | 14| molarrycurly | 12 |    3|
|  2 | mo,larry,curly                 |       14 | molarrycurly               |           12 |    3|
|  3 | mo,larry,curly                 |       14 | molarrycurly               |           12 |    3|
|  4 | mo,larry,curly                 |       14 | molarrycurly               |           12 |    3|
|  5 | mo,larry,curly                 |       14 | molarrycurly               |           12 |    3|
|  6 | mo,larry,curly                 |       14 | molarrycurly               |           12 |    3|
|  7 | mo,larry,curly                 |       14 | molarrycurly               |           12 |    3|
|  8 | mo,larry,curly                 |       14 | molarrycurly               |           12 |    3|
|  9 | mo,larry,curly                 |       14 | molarrycurly               |           12 |    3|
| 10 | mo,larry,curly                 |       14 | molarrycurly               |           12 |    3|
|  8 | tina,gina,jaunita,regina,leena |       30 | tinaginajaunitareginaleena |           26 |    5|
|  1 | tina,gina,jaunita,regina,leena |       30 | tinaginajaunitareginaleena |           26 |    5|
|  6 | tina,gina,jaunita,regina,leena |       30 | tinaginajaunitareginaleena |           26 |    5|
|  2 | tina,gina,jaunita,regina,leena |       30 | tinaginajaunitareginaleena |           26 |    5|
| 10 | tina,gina,jaunita,regina,leena |       30 | tinaginajaunitareginaleena |           26 |    5|
|  3 | tina,gina,jaunita,regina,leena |       30 | tinaginajaunitareginaleena |           26 |    5|
|  7 | tina,gina,jaunita,regina,leena |       30 | tinaginajaunitareginaleena |           26 |    5|
|  4 | tina,gina,jaunita,regina,leena |       30 | tinaginajaunitareginaleena |           26 |    5|
|  9 | tina,gina,jaunita,regina,leena |       30 | tinaginajaunitareginaleena |           26 |    5|
|  5 | tina,gina,jaunita,regina,leena |       30 | tinaginajaunitareginaleena |           26 |    5|


The number of rows returned is determined by how many values are in each string.

```SQL
SELECT *
  FROM (SELECT id AS pos FROM t10) iter,
       (SELECT CAST(name AS TEXT) AS name
          FROM v) src
 WHERE iter.pos <=
       LENGTH(src.name) - LENGTH(REPLACE(src.name,',','')) + 1
 ORDER BY name, pos;
```

To find the number of values in each string, find the number of delimiters in each string and add one.

|pos |              name|
|:--:|:-------------------------------:|
|  1 | mo,larry,curly|
|  2 | mo,larry,curly|
|  3 | mo,larry,curly|
|  1 | tina,gina,jaunita,regina,leena|
|  2 | tina,gina,jaunita,regina,leena|
|  3 | tina,gina,jaunita,regina,leena|
|  4 | tina,gina,jaunita,regina,leena|
|  5 | tina,gina,jaunita,regina,leena|

The function `SPLIT_PART` uses the values in `POS` to find the `nth` occurrence of the delimiter and parse the string into values:

```SQL
SELECT pos, name, split_part(src.name,',',iter.pos)
  FROM (SELECT id AS pos FROM t10) iter,
       (SELECT CAST(name AS TEXT) AS name
          FROM v) src
 WHERE iter.pos <=
       LENGTH(src.name) - LENGTH(REPLACE(src.name,',','')) + 1
 ORDER BY name, pos;
```

|pos |              name              | split_part|
|:---:|:-----------------------------:|:-----------:|
|  1 | **mo**,larry,curly                 | mo|
|  2 | mo,**larry**,curly                 | larry|
|  3 | mo,larry,**curly**                 | curly|
|  1 | **tina**,gina,jaunita,regina,leena | tina|
|  2 | tina,**gina**,jaunita,regina,leena | gina|
|  3 | tina,gina,**jaunita**,regina,leena | jaunita|
|  4 | tina,gina,jaunita,**regina**,leena | regina|
|  5 | tina,gina,jaunita,regina,**leena** | leena|

We’ve shown NAME twice so you can see how SPLIT_PART parses each string using POS. Once each string is parsed, the final step is to keep the rows where POS equals the nth substring you are interested in, in this case, 2.

```SQL
SELECT name
  FROM (
         SELECT iter.pos, split_part(src.name,',',iter.pos) AS name
           FROM (SELECT id AS pos FROM t10) iter,
                (SELECT CAST(name AS TEXT) AS name FROM v) src
          WHERE iter.pos <=
                LENGTH(src.name) - LENGTH(REPLACE(src.name,',','')) + 1;
       ) x
WHERE pos = 2;
```

|name|
|:-----:|
|larry|
|gina|
