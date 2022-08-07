# Converting Delimited Data into a Multivalued IN-List


You have `delimited data` that you want to pass to the **IN-list iterator of** a `WHERE` clause.

## Problem

Consider the following string:

- `7654,7698,7782,7788`

You would like to use the string in a `WHERE` clause, but the following SQL fails because `EMPNO` is a numeric column:

```SQL
SELECT ename, sal, deptno
  FROM emp
 WHERE empno IN ( '7654,7698,7782,7788' );
```

```console
ERROR:  invalid input syntax for integer: "7654,7698,7782,7788"
LINE 3:  WHERE empno IN ( '7654,7698,7782,7788' );
                          ^
```

This SQL **fails** because, while `EMPNO` is a numeric column, the `IN` list is composed of a single string value. You want that string to be treated as a comma-delimited list of numeric values.

## Solution

On the surface it may seem that SQL should do the work of treating a delimited string as a list of delimited values for you, but that is not the case.

When a **comma embedded within quotes is encountered**, SQL can’t possibly know that signals a multivalued list. SQL must treat everything between the quotes as a single entity, as one string value.

You **must break the string up into individual** `EMPNO`s. The key to this solution is to **walk the string**, but not into individual characters.

You want to walk the string into valid `EMPNO` values.

## PostgreSQL

By walking the string passed to the IN-list, you can easily convert it to rows. The function [SPLIT_PART](https://github.com/lpinzari/sql-psql-udy/blob/master/06_string_functions/16_split_part.md) makes it easy to parse the string into individual numbers:

```SQL
SELECT ename, sal, deptno, empno
  FROM emp
 WHERE empno IN (
   SELECT CAST(empno AS INTEGER) AS empno
     FROM (
            SELECT SPLIT_PART(list.vals,',',iter.pos) AS empno
              FROM  (
                     SELECT id AS pos
                       FROM t10
                    ) iter,
                    (
                      SELECT ',' || '7654,7698,7782,7788' || ',' AS vals
                        FROM t1
                    ) list
              WHERE iter.pos <=
                    LENGTH(list.vals) - LENGTH(REPLACE(list.vals,',',''))
          ) z
     WHERE LENGTH(empno) > 0
 );
 ```

| ename  | sal  | deptno | empno|
|:-----:|:-----:|:-------:|:------:|
|MARTIN | 1250 |     30 |  7654|
|BLAKE  | 2850 |     30 |  7698|
|CLARK  | 2450 |     10 |  7782|
|SCOTT  | 3000 |     20 |  7788|


## CTE

```SQL
WITH iter_list AS (
  SELECT *
    FROM  (
           SELECT id AS pos
             FROM t10
          ) iter,
          (
            SELECT ',' || '7654,7698,7782,7788' || ',' AS vals
              FROM t1
          ) list
   WHERE iter.pos <=
         LENGTH(list.vals) - LENGTH(REPLACE(list.vals,',',''))
),
list_string AS (
  SELECT SPLIT_PART(vals,',',pos) AS empno
    FROM iter_list
),
list_int AS (
  SELECT CAST(empno AS INTEGER) AS empno
    FROM list_string
   WHERE LENGTH(empno) > 0
)

SELECT ename, sal, deptno, empno
  FROM emp
 WHERE empno IN ( SELECT * FROM list_int);
```

## PLpgsql

```SQL
CREATE TABLE list_ints(num integer);

do $$
declare
  list text := '7654,7698,7782,7788' || ',';
  val text;
  n integer := LENGTH(list) - LENGTH(REPLACE(list,',',''));
begin
  for iter in 1..n loop
      val := SPLIT_PART(list,',',iter);
      if LENGTH(val) > 0 then
        INSERT INTO list_ints VALUES(CAST(val As integer));
      end if;
  end loop;
end;$$;

SELECT ename, sal, deptno, empno
  FROM emp
 WHERE empno IN ( SELECT * FROM list_ints);
```

## Discussion

The first and most important step in this solution is to walk the string. Once you’ve accomplished that, all that’s left is to parse the string into individual numeric values using your DBMS’s provided functions.

```SQL
SELECT *
  FROM  (
         SELECT id AS pos
           FROM t10
        ) iter,
        (
          SELECT ',' || '7654,7698,7782,7788' || ',' AS vals
            FROM t1
        ) list;
```

Use a Cartesian product to generate the number of rows needed to walk through the list of values.

|pos |         vals|
|:--:|:--------------------:|
|  1 | ,7654,7698,7782,7788,|
|  2 | ,7654,7698,7782,7788,|
|  3 | ,7654,7698,7782,7788,|
|  4 | ,7654,7698,7782,7788,|
|  5 | ,7654,7698,7782,7788,|
|  6 | ,7654,7698,7782,7788,|
|  7 | ,7654,7698,7782,7788,|
|  8 | ,7654,7698,7782,7788,|
|  9 | ,7654,7698,7782,7788,|
| 10 | ,7654,7698,7782,7788,|

**(10 rows)**


```SQL
SELECT *
  FROM  (
         SELECT id AS pos
           FROM t10
        ) iter,
        (
          SELECT ',' || '7654,7698,7782,7788' || ',' AS vals
            FROM t1
        ) list
 WHERE iter.pos <=
       LENGTH(list.vals) - LENGTH(REPLACE(list.vals,',',''));
```

|pos |         vals|
|:---:|:-------------------:|
|  1 | ,7654,7698,7782,7788,|
|  2 | ,7654,7698,7782,7788,|
|  3 | ,7654,7698,7782,7788,|
|  4 | ,7654,7698,7782,7788,|
|  5 | ,7654,7698,7782,7788,|

To find the number of values in the string, subtract the size of the string without the delimiter from the size of the string with the delimiter.

```SQL
SELECT  iter.pos, list.vals,
        SPLIT_PART(list.vals,',',iter.pos) AS empno
  FROM  (
         SELECT id AS pos
           FROM t10
        ) iter,
        (
          SELECT ',' || '7654,7698,7782,7788' || ',' AS vals
            FROM t1
        ) list
  WHERE iter.pos <=
        LENGTH(list.vals) - LENGTH(REPLACE(list.vals,',',''));
```

The function `SPLIT_PART` does the work of parsing the string.

The string `,7654,7698,7782,7788,` is split on the comma delimiter `,` that results in 5 substrings `,`,`7654,`,`7698,`,`7782,` and `7788,`. Then It looks for the value that comes before the nth occurrence of the delimiter:

|pos |         vals          | empno|
|:--:|:---------------------:|:------:|
|  1 | ,7654,7698,7782,7788, ||
|  2 | ,7654,7698,7782,7788, | 7654|
|  3 | ,7654,7698,7782,7788, | 7698|
|  4 | ,7654,7698,7782,7788, | 7782|
|  5 | ,7654,7698,7782,7788, | 7788|

```SQL
SELECT CAST(empno AS INTEGER) AS empno
  FROM (
         SELECT SPLIT_PART(list.vals,',',iter.pos) AS empno
           FROM  (
                  SELECT id AS pos
                    FROM t10
                 ) iter,
                 (
                   SELECT ',' || '7654,7698,7782,7788' || ',' AS vals
                     FROM t1
                 ) list
           WHERE iter.pos <=
                 LENGTH(list.vals) - LENGTH(REPLACE(list.vals,',',''))
       ) z
  WHERE LENGTH(empno) > 0;
```

The final step is to cast the values (EMPNO) to a number and plug it into a subquery.

|empno|
|:-----:|
| 7654|
| 7698|
| 7782|
| 7788|
