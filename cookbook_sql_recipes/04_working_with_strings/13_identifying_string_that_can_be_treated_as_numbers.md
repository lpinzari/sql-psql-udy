# Identifying Strings That Can Be Treated as Numbers

You have a column that is defined to hold character data. Unfortunately, the rows contain **mixed numeric and character data**. Consider view `v`:

```SQL
CREATE VIEW v AS
    SELECT REPLACE(mixed,' ','') AS mixed
      FROM (
             SELECT substr(ename,1,2) ||
                    CAST(deptno AS CHAR(4)) ||
                    SUBSTR(ename,3,2) AS mixed
               FROM emp
              WHERE deptno = 10

             UNION ALL

             SELECT CAST(empno AS CHAR(4)) AS mixed
               FROM emp
              WHERE deptno = 20

             UNION ALL

             SELECT ename AS mixed
               FROM emp
              WHERE deptno = 30
            ) x;
```

```SQL
SELECT * FROM v;
```

|mixed|
|:------:|
|CL`10`AR|
|KI`10`NG|
|MI`10`LL|
|`7369`|
|`7566`|
|`7788`|
|`7876`|
|`7902`|
|ALLEN|
|WARD|
|MARTIN|
|BLAKE|
|TURNER|
|JAMES|

You want to return rows that are **numbers only**, or that **contain at least one number**. If the numbers are mixed with character data, **you want to remove the characters and return only the numbers**.

For the sample data shown previously, you want the following result set:

|mixed|
|:----:|
|   10|
|   10|
|   10|
| 7369|
| 7566|
| 7788|
| 7876|
| 7902|

# Solution

**PostgreSQL**:

Use functions `TRANSLATE`, `REPLACE`, and `STRPOS` to **isolate the numeric characters in each row**. The calls to CAST are not necessary in view V.

Use the function `REPLACE` to remove extraneous whitespace due to casting to the fixed-length `CHAR`.

If you decide you would like to keep the explicit type conversion calls in the view definition, it is suggested you cast to `VARCHAR`:

```SQL
SELECT CAST(CASE WHEN REPLACE(TRANSLATE(mixed,'0123456789','999999999'),'9','') IS NOT NULL
                 THEN REPLACE(TRANSLATE(mixed,
                                        REPLACE(TRANSLATE(mixed,'0123456789','999999999'),'9',''),
                                        RPAD('#',LENGTH(mixed),'#')),
                              '#','')
                 ELSE mixed
                 END
             AS integer
           ) AS mixed
  FROM v
 WHERE STRPOS(TRANSLATE(mixed,'0123456789',
                              '9999999999'),'9') > 0;
```


### Solution 2

```SQL
SELECT CAST(STRING_AGG(c,'' ORDER BY pos) AS INTEGER) AS MIXED1
  FROM (
          SELECT v.mixed, iter.pos, SUBSTR(v.mixed,iter.pos,1) AS c
            FROM v,
                 ( SELECT id pos FROM t10 ) iter
           WHERE iter.pos <= length(v.mixed)
                 AND ascii(SUBSTR(v.mixed,iter.pos,1)) BETWEEN 48 AND 57
        ) y GROUP BY mixed
 ORDER BY 1;
```

## Discussion

The `TRANSLATE` function is useful here as it allows you to easily isolate and identify numbers and characters. The trick is to convert all numbers to a single character; this way, rather than searching for different numbers, you search for only one character.

**DB2, Oracle, and PostgreSQL**

The syntax differs slightly among these DBMSs, but the technique is the same. We’ll use the solution for PostgreSQL for the discussion.
The real work is done by functions `TRANSLATE` and `REPLACE`. Getting the final result set requires several function calls, each listed here in one query:

```SQL
SELECT mixed AS original,
       TRANSLATE(mixed,'0123456789','999999999') AS mixed1,
       REPLACE(TRANSLATE(mixed,'0123456789','999999999'),'9','') AS mixed2,
       TRANSLATE(mixed,REPLACE(TRANSLATE(mixed,'0123456789','999999999'),'9',''),RPAD('#',LENGTH(mixed),'#')) AS mixed3,
       REPLACE(TRANSLATE(mixed,REPLACE(TRANSLATE(mixed,'0123456789','999999999'),'9',''),RPAD('#',LENGTH(mixed),'#')),'#','') AS mixed4
  FROM v;
```

|original | mixed1 | mixed2 | mixed3 | mixed4|
|:-------:|:------:|:------:|:------:|:-------:|
|CL10AR   | CL99AR | CLAR   | ##10## | 10|
|KI10NG   | KI99NG | KING   | ##10## | 10|
|MI10LL   | MI99LL | MILL   | ##10## | 10|
|7369     | 999    |        | 7369   | 7369|
|7566     | 9999   |        | 7566   | 7566|
|7788     | 9999   |        | 7788   | 7788|
|7876     | 9999   |        | 7876   | 7876|
|7902     | 999    |        | 7902   | 7902|
|ALLEN    | ALLEN  | ALLEN  | #####  ||
|WARD     | WARD   | WARD   | ####   ||
|MARTIN   | MARTIN | MARTIN | ###### ||
|BLAKE    | BLAKE  | BLAKE  | #####  ||
|TURNER   | TURNER | TURNER | ###### ||
|JAMES    | JAMES  | JAMES  | #####  ||

- `TRANSLATE(mixed,'0123456789','999999999')`

The first step to extracting the numbers is to use the function TRANSLATE to convert any number to a 9 (you can use any digit; 9 is arbitrary); this is represented by the values in `MIXED1`.

- `REPLACE(mixed1,'9','')`

Now that all numbers are `9s`, they can be treated as a single unit. The next step is to **remove all of the numbers by using the function** `REPLACE`. Because all digits are now 9, REPLACE simply looks for any 9s and removes them. This is represented by the values in `MIXED2`.

- `TRANSLATE(mixed,mixed2,RPAD('#',LENGTH(mixed),'#'))`

The next step, `MIXED3`, uses values that are returned by MIXED2. These values are then compared to the values in ORIG, `mixed`. If any characters from `MIXED2` are found in `ORIG`, they are converted to the `#` character by `TRANSLATE`. The result set from MIXED3 shows that the letters, not the numbers, have now been singled out and converted to a single character. Now that all nonnumeric characters are represented by #s, they can be treated as a single unit.

- `REPLACE(mixed3,'#','')`

The next step, MIXED4, uses REPLACE to find and remove any # characters in each row;what’s left are numbers only.

```SQL
SELECT CAST(mixed4 AS INTEGER)
  FROM v
 WHERE STRPOS(mixed1,'9') > 0;
```
The final step is to cast the numeric characters as numbers. Now that you’ve gone through the steps, you can see how the `WHERE` clause works. The results from `MIXED1` are passed to `STRPOS`, and if a 9 is found (the position in the string where the first 9 is located), the result must be greater than 0.

|original | mixed1 | mixed2 | mixed3 | mixed4|
|:-------:|:------:|:------:|:------:|:-------:|
|CL10AR   | CL99AR | CLAR   | ##10## | 10|
|KI10NG   | KI99NG | KING   | ##10## | 10|
|MI10LL   | MI99LL | MILL   | ##10## | 10|
|7369     | 999    |        | 7369   | 7369|
|7566     | 9999   |        | 7566   | 7566|
|7788     | 9999   |        | 7788   | 7788|
|7876     | 9999   |        | 7876   | 7876|
|7902     | 999    |        | 7902   | 7902|

For rows that return a value greater than zero, it means there’s at least one number in that row and it should be kept.

## Solution 2

```SQL
SELECT CAST(STRING_AGG(c,'' ORDER BY pos) AS INTEGER) AS MIXED1
  FROM (
          SELECT v.mixed, iter.pos, SUBSTR(v.mixed,iter.pos,1) AS c
            FROM v,
                 ( SELECT id pos FROM t10 ) iter
           WHERE iter.pos <= length(v.mixed)
                 AND ascii(SUBSTR(v.mixed,iter.pos,1)) BETWEEN 48 AND 57
        ) y GROUP BY mixed
 ORDER BY 1;
```

The first step is to walk each string, evaluate each character, and determine whether it’s a number:

```SQL
SELECT v.mixed, iter.pos, SUBSTR(v.mixed,iter.pos,1) AS c
  FROM v,
       ( SELECT id pos FROM t10 ) iter
 WHERE iter.pos <= LENGTH(v.mixed)
 ORDER BY 1,2;
```

|mixed  | pos | c|
|:-----:|:---:|:--:|
|7369   |   1 | 7|
|7369   |   2 | 3|
|7369   |   3 | 6|
|7369   |   4 | 9|
|7566   |   1 | 7|
|7566   |   2 | 5|
|7566   |   3 | 6|
|7566   |   4 | 6|
|7788   |   1 | 7|
|7788   |   2 | 7|
|7788   |   3 | 8|
|7788   |   4 | 8|
|7876   |   1 | 7|
|7876   |   2 | 8|
|7876   |   3 | 7|
|7876   |   4 | 6|
|7902   |   1 | 7|
|7902   |   2 | 9|
|7902   |   3 | 0|
|7902   |   4 | 2|
|ALLEN  |   1 | A|
|ALLEN  |   2 | L|
|ALLEN  |   3 | L|
|ALLEN  |   4 | E|
|ALLEN  |   5 | N|
|BLAKE  |   1 | B|
|BLAKE  |   2 | L|
|BLAKE  |   3 | A|
|BLAKE  |   4 | K|
|BLAKE  |   5 | E|
|CL10AR |   1 | C|
|CL10AR |   2 | L|
|CL10AR |   3 | 1|
|CL10AR |   4 | 0|
|CL10AR |   5 | A|
|CL10AR |   6 | R|
|JAMES  |   1 | J|
|JAMES  |   2 | A|
|JAMES  |   3 | M|
|JAMES  |   4 | E|
|JAMES  |   5 | S|
|KI10NG |   1 | K|
|KI10NG |   2 | I|
|KI10NG |   3 | 1|
|KI10NG |   4 | 0|
|KI10NG |   5 | N|
|KI10NG |   6 | G|
|MARTIN |   1 | M|
|MARTIN |   2 | A|
|MARTIN |   3 | R|
|MARTIN |   4 | T|
|MARTIN |   5 | I|
|MARTIN |   6 | N|
|MI10LL |   1 | M|
|MI10LL |   2 | I|
|MI10LL |   3 | 1|
|MI10LL |   4 | 0|
|MI10LL |   5 | L|
|MI10LL |   6 | L|
|TURNER |   1 | T|
|TURNER |   2 | U|
|TURNER |   3 | R|
|TURNER |   4 | N|
|TURNER |   5 | E|
|TURNER |   6 | R|
|WARD   |   1 | W|
|WARD   |   2 | A|
|WARD   |   3 | R|
|WARD   |   4 | D|

Now that each character in each string can be evaluated individually, the next step is to keep only the rows that have a number in the C column:

```SQL
SELECT v.mixed, iter.pos, SUBSTR(v.mixed,iter.pos,1) AS c
  FROM v,
       ( SELECT id pos FROM t10 ) iter
 WHERE iter.pos <= LENGTH(v.mixed)
       AND ascii(SUBSTR(v.mixed,iter.pos,1)) BETWEEN 48 AND 57
 ORDER BY 1,2;
```

|mixed  | pos | c|
|:-----:|:---:|:-:|
|7369   |   1 | 7|
|7369   |   2 | 3|
|7369   |   3 | 6|
|7369   |   4 | 9|
|7566   |   1 | 7|
|7566   |   2 | 5|
|7566   |   3 | 6|
|7566   |   4 | 6|
|7788   |   1 | 7|
|7788   |   2 | 7|
|7788   |   3 | 8|
|7788   |   4 | 8|
|7876   |   1 | 7|
|7876   |   2 | 8|
|7876   |   3 | 7|
|7876   |   4 | 6|
|7902   |   1 | 7|
|7902   |   2 | 9|
|7902   |   3 | 0|
|7902   |   4 | 2|
|CL10AR |   3 | 1|
|CL10AR |   4 | 0|
|KI10NG |   3 | 1|
|KI10NG |   4 | 0|
|MI10LL |   3 | 1|
|MI10LL |   4 | 0|

At this point, all the rows in column C are numbers.

```SQL
SELECT CAST(STRING_AGG(c,'' ORDER BY pos) AS INTEGER) AS MIXED1
  FROM (
          SELECT v.mixed, iter.pos, SUBSTR(v.mixed,iter.pos,1) AS c
            FROM v,
                 ( SELECT id pos FROM t10 ) iter
           WHERE iter.pos <= length(v.mixed)
                 AND ascii(SUBSTR(v.mixed,iter.pos,1)) BETWEEN 48 AND 57
        ) y GROUP BY mixed
 ORDER BY 1;
```

The next step is to use `STRING_AGG` to concatenate the numbers to form their respective whole number in `MIXED`. The final result is then cast as a number.

|mixed1|
|:----:|
|    10|
|    10|
|    10|
|  7369|
|  7566|
|  7788|
|  7876|
|  7902|
