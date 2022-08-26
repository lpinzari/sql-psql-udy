# Searching for Mixed Alphanumeric Strings

You have a `column` with **mixed alphanumeric data**. You want to return those rows that have both `alphabetical` and `numeric` characters; in other words,

- if a string has `only` **number** `or` only **letters**, **do not return it**. The return values should have a `mix` of **both letters and numbers**.

## Problem

Consider the following data:

```SQL
WITH v (strings) AS (
  SELECT 'ClassSummary'
  UNION ALL
  SELECT '3453430278'
  UNION ALL
  SELECT 'findRow 55'
  UNION ALL
  SELECT '1010 switch'
  UNION ALL
  SELECT '333'
  UNION ALL
  SELECT 'threes'
)
SELECT * FROM v;
```

|strings|
|:------------:|
|ClassSummary|
|3453430278|
|findRow 55|
|1010 switch|
|333|
|threes|

The final result set should contain only those rows that have both letters and numbers:

|strings|
|:------------:|
|findRow 55|
|1010 switch|

## Solution

Use the built-in function `TRANSLATE` to convert each occurrence of a letter or digit into a specific character. Then keep only those strings that have at least one occur‐ rence of both.

```SQL
WITH v (strings) AS (
  SELECT 'ClassSummary'
  UNION ALL
  SELECT '3453430278'
  UNION ALL
  SELECT 'findRow 55'
  UNION ALL
  SELECT '1010 switch'
  UNION ALL
  SELECT '333'
  UNION ALL
  SELECT 'threes'
),
t AS (
SELECT strings,
       TRANSLATE(strings, 'abcdefghijklmnopqrstuvwxyz0123456789',
                 RPAD('#',26,'#') || RPAD('*',10,'*')) AS translated
  FROM v
)
SELECT strings
  FROM t
 WHERE POSITION('#' IN translated) > 0 AND POSITION('*' IN translated) > 0;
```

## Discussion

The `TRANSLATE` function makes this problem extremely easy to solve. The first step is to use `TRANSLATE` to identify all letters and all digits by pound (`#`) and asterisk (`*`) characters, respectively.

The intermediate results are as follows:

```SQL
WITH v (strings) AS (
  SELECT 'ClassSummary'
  UNION ALL
  SELECT '3453430278'
  UNION ALL
  SELECT 'findRow 55'
  UNION ALL
  SELECT '1010 switch'
  UNION ALL
  SELECT '333'
  UNION ALL
  SELECT 'threes'
)
SELECT strings,
       TRANSLATE(strings, 'abcdefghijklmnopqrstuvwxyz0123456789',
                 RPAD('#',26,'#') || RPAD('*',10,'*')) AS translated
  FROM v;
```

|strings    |  translated|
|:-----------:|:-----------:|
|ClassSummary | C####S######|
|3453430278   | **********|
|findRow 55   | ####R## **|
|1010 switch  | **** ######|
|333          | ***|
|threes       | ######|


The expression in the `TRANSLATE` function is basically equivalent to:

```SQL
TRANSLATE(strings, 'abcdefghijklmnopqrstuvwxyz0123456789',
                   '##########################**********') AS translated
```

The long string is basically equivalent to:

```console
SELECT RPAD('#',26,'#') || RPAD('*',10,'*');

rpad
------------------------------------
##########################**********
```

At this point, it is only a matter of keeping those rows that have at least one instance each of `#` and `*`.

Use the function `POSITION` to determine whether `#` and `*` are in a string. If those two characters are, in fact, present, then the value returned will be greater than zero. The final strings to return, along with their translated values, are shown next for clarity:


```SQL
WITH v (strings) AS (
  SELECT 'ClassSummary'
  UNION ALL
  SELECT '3453430278'
  UNION ALL
  SELECT 'findRow 55'
  UNION ALL
  SELECT '1010 switch'
  UNION ALL
  SELECT '333'
  UNION ALL
  SELECT 'threes'
),
t AS (
SELECT strings,
       TRANSLATE(strings, 'abcdefghijklmnopqrstuvwxyz0123456789',
                 RPAD('#',26,'#') || RPAD('*',10,'*')) AS translated
  FROM v
)
SELECT strings
  FROM t
 WHERE POSITION('#' IN translated) > 0 AND POSITION('*' IN translated) > 0;
```

|strings|
|:-----------:|
|findRow 55|
|1010 switch|
