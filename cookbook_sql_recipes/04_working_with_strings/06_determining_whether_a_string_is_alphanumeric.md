# Determining Whether a String Is Alphanumeric Problem

You want to return rows from a table only when a column of interest contains no characters other than **numbers** and **letters**. Consider the following view V:

```SQL
CREATE VIEW v AS
    SELECT ename as data
      FROM emp
     WHERE deptno = 10

    UNION ALL

    SELECT ename || ', $' || CAST(sal AS CHAR(4)) || '.00' AS data
      FROM emp
     WHERE deptno = 20

    UNION ALL

    SELECT ename || CAST(deptno AS CHAR(4)) AS data
      FROM emp
     WHERE deptno = 30;
```

```SQL
SELECT * FROM v;
```
The view V represents your table, and it returns the following:

|data|
|:---------------:|
|CLARK|
|KING|
|MILLER|
|SMITH, $800.00|
|JONES, $2975.00|
|SCOTT, $3000.00|
|ADAMS, $1100.00|
|FORD, $3000.00|
|ALLEN30|
|WARD30|
|MARTIN30|
|BLAKE30|
|TURNER30|
|JAMES30|

However, from the view’s data you want to return only the following records:

|data|
|:--------:|
|CLARK|
|KING|
|MILLER|
|ALLEN30|
|WARD30|
|MARTIN30|
|BLAKE30|
|TURNER30|
|JAMES30|


In short, you want to omit those rows containing data other than `letters and digits` such as `ALLEN30`.

## Solution

It may seem intuitive at first to solve the problem by searching for all the possible non-alphanumeric characters that can be found in a string, but, on the contrary, you will find it easier to do the exact opposite: **find all the alphanumeric characters**.

By doing so, you can treat all the alphanumeric characters as one by converting them to one single character. The reason you want to do this is so the alphanumeric characters can be manipulated together, as a whole. Once you’ve generated a copy of the string in which all alphanumeric characters are represented by a single character of your choosing, it is easy to isolate the alphanumeric characters from any other characters.

Use the function `TRANSLATE` to convert all alphanumeric characters to a single character; then identify any rows that have characters other than the converted alphanumeric character. The CAST function calls in view V are not needed for Oracle and PsotgreSQL. Take extra care when working with casts to CHAR as they are fixed length (padded). If you decide to cast, cast to VARCHAR or VARCHAR2:

```SQL
SELECT data
  FROM v
 WHERE TRANSLATE(LOWER(data),
                       '0123456789abcdefghijklmnopqrstuvwxyz',
                        RPAD('a',36,'a')) =
                        RPAD('a',length(data),'a');
```

Use a regular expression to easily find rows that contain non-alphanumeric data:

```SQL
SELECT data
  FROM V
 WHERE NOT (data ~ '[^0-9a-zA-Z]') ;
```


## DISCUSSION

The key to these solutions is being able to reference multiple characters concurrently. By using the function `TRANSLATE`, you can easily manipulate all numbers or all characters without having to “iterate” and inspect each character one by one.

Only 9 of the 14 rows from view V are alphanumeric. To find the rows that are alphanumeric only, simply use the function `TRANSLATE`. In this example, `TRANSLATE` converts characters `0–9` and `a–z` to “`a`”. Once the conversion is done, the converted row is then compared with a string of all “`a`” **with the same length** (**as the row**).

If `the length is the same`, then you know **all the characters are alphanumeric and nothing else**.

By using the TRANSLATE function, you convert all numbers and letters into a distinct character (we chose “a”). Once the data is converted, all strings that are indeed alphanumeric can be identified as a string comprising only a single character (in this case, “a”). This can be seen by running TRANSLATE by itself:

```SQL
SELECT data,
       TRANSLATE(LOWER(data),
                      '0123456789abcdefghijklmnopqrstuvwxyz',
                       RPAD('a',36,'a'))
  FROM v;
```

|data       |    translate|
|:--------------:|:----------------:|
|CLARK           | aaaaa|
|KING            | aaaa|
|MILLER          | aaaaaa|
|SMITH, $800.00  | aaaaa, $aaa.aa|
|JONES, $2975.00 | aaaaa, $aaaa.aa|
|SCOTT, $3000.00 | aaaaa, $aaaa.aa|
|ADAMS, $1100.00 | aaaaa, $aaaa.aa|
|FORD, $3000.00  | aaaa, $aaaa.aa|
|ALLEN30         | aaaaaaa|
|WARD30          | aaaaaa|
|MARTIN30        | aaaaaaaa|
|BLAKE30         | aaaaaaa|
|TURNER30        | aaaaaaaa|
|JAMES30         | aaaaaaa|

The alphanumeric values are converted, but the string lengths have not been modi‐ fied. Because the lengths are the same, the rows to keep are the ones for which the call to TRANSLATE returns all “a"s. You keep those rows, rejecting the others, by comparing each original string’s length with the length of its corresponding string of “`a`"s:

```SQL
SELECT data,
       TRANSLATE(LOWER(data),
                      '0123456789abcdefghijklmnopqrstuvwxyz',
                       RPAD('a',36,'a')) AS translated,
       RPAD('a',length(data),'a') AS fixed
  FROM v;
```

|data       |   translated    |      fixed|
|:--------------:|:----------------:|:----------------:|
|**CLARK**           | **aaaaa**           | **aaaaa**|
|**KING**            | **aaaa**            | **aaaa**|
|**MILLER**          | **aaaaaa**          | **aaaaaa**|
|SMITH, $800.00  | aaaaa, $aaa.aa  | aaaaaaaaaaaaaa|
|JONES, $2975.00 | aaaaa, $aaaa.aa | aaaaaaaaaaaaaaa|
|SCOTT, $3000.00 | aaaaa, $aaaa.aa | aaaaaaaaaaaaaaa|
|ADAMS, $1100.00 | aaaaa, $aaaa.aa | aaaaaaaaaaaaaaa|
|FORD, $3000.00  | aaaa, $aaaa.aa  | aaaaaaaaaaaaaa|
|**ALLEN30**         | **aaaaaaa**         | **aaaaaaa**|
|**WARD30**          | **aaaaaa**          | **aaaaaa**|
|**MARTIN30**        | **aaaaaaaa**        | **aaaaaaaa**|
|**BLAKE30**         | **aaaaaaa**         | **aaaaaaa**|
|**TURNER30**        | **aaaaaaaa**        | **aaaaaaaa**|
|**JAMES30**         | **aaaaaaa**         | **aaaaaaa**|

The last step is to keep only the strings where `TRANSLATED` equals `FIXED`.

```SQL
SELECT data
  FROM v
 WHERE TRANSLATE(LOWER(data),
                       '0123456789abcdefghijklmnopqrstuvwxyz',
                        RPAD('a',36,'a')) =
                        RPAD('a',length(data),'a');
```

|data|
|:--------:|
|CLARK|
|KING|
|MILLER|
|ALLEN30|
|WARD30|
|MARTIN30|
|BLAKE30|
|TURNER30|
|JAMES30|


### Regular Expressions solution

```SQL
SELECT data
  FROM V
 WHERE NOT (data ~ '[^0-9a-zA-Z]') ;
```

The expression in the WHERE clause:

- `NOT (data ~ '[^0-9a-zA-Z]')`

causes rows that have only numbers or characters to be returned. The value ranges in the brackets, `“0-9a-zA-Z”`, represent all possible numbers and letters. The character `^` is for negation, so the expression can be stated as “**not numbers or letters.**” Thus, the following expressions:

```SQL
SELECT 'SMITH, $800.00' ~ '[^0-9a-zA-Z]',
       'JONES, $2975.00' ~ '[^0-9a-zA-Z]',
       'SCOTT, $3000.00' ~ '[^0-9a-zA-Z]',
       'ADAMS, $1100.00' ~ '[^0-9a-zA-Z]',
       'FORD, $3000.00' ~ '[^0-9a-zA-Z]';
```

Returns `TRUE`, `t`.

|?column? | ?column? | ?column? | ?column? | ?column?|
|:--------:|:-------:|:--------:|:--------:|:---------:|
|t        | t        | t        | t        | t|

If we remove the characters `,`,` `,`$` and `.`.

```SQL
SELECT 'SMITH80000' ~ '[^0-9a-zA-Z]',
       'JONES297500' ~ '[^0-9a-zA-Z]',
       'SCOTT300000' ~ '[^0-9a-zA-Z]',
       'ADAMS110000' ~ '[^0-9a-zA-Z]',
       'FORD300000' ~ '[^0-9a-zA-Z]';
```

It returns `FALSE`,`f`.

|?column? | ?column? | ?column? | ?column? | ?column?|
|:-------:|:--------:|:--------:|:--------:|:--------:|
|f        | f        | f        | f        | f|

Thus, if we negate the result:

```SQL
SELECT NOT ('SMITH, $800.00' ~ '[^0-9a-zA-Z]'),
       NOT ('JONES, $2975.00' ~ '[^0-9a-zA-Z]'),
       NOT ('SCOTT, $3000.00' ~ '[^0-9a-zA-Z]'),
       NOT ('ADAMS, $1100.00' ~ '[^0-9a-zA-Z]'),
       NOT ('FORD, $3000.00' ~ '[^0-9a-zA-Z]');
```

|?column? | ?column? | ?column? | ?column? | ?column?|
|:-------:|:--------:|:--------:|:--------:|:---------:|
|f        | f        | f        | f        | f|


```SQL
SELECT NOT ('SMITH80000' ~ '[^0-9a-zA-Z]'),
       NOT ('JONES297500' ~ '[^0-9a-zA-Z]'),
       NOT ('SCOTT300000' ~ '[^0-9a-zA-Z]'),
       NOT ('ADAMS110000' ~ '[^0-9a-zA-Z]'),
       NOT ('FORD300000' ~ '[^0-9a-zA-Z]');
```
|?column? | ?column? | ?column? | ?column? | ?column?|
|:-------:|:--------:|:--------:|:--------:|:--------:|
|t        | t        | t        | t        | t|


the whole expression can be stated as “**return rows where anything other than numbers and letters is false.**”

```SQL
SELECT data,
       NOT (data ~ '[^0-9a-zA-Z]') AS alphanumeric
  FROM v;
```

|data       | alphanumeric|
|:--------------:|:-------------:|
|**CLARK**           | **t**|
|**KING**            | **t**|
|**MILLER**          | **t**|
|SMITH, $800.00  | f|
|JONES, $2975.00 | f|
|SCOTT, $3000.00 | f|
|ADAMS, $1100.00 | f|
|FORD, $3000.00  | f|
|**ALLEN30**         | **t**|
|**WARD30**          | **t**|
|**MARTIN30**        | **t**|
|**BLAKE30**         | **t**|
|**TURNER30**        | **t**|
|**JAMES30**         | **t**|

It follows that:

```SQL
SELECT data
  FROM V
 WHERE NOT (data ~ '[^0-9a-zA-Z]') ;
```
|data|
|:--------:|
|CLARK|
|KING|
|MILLER|
|ALLEN30|
|WARD30|
|MARTIN30|
|BLAKE30|
|TURNER30|
|JAMES30|
