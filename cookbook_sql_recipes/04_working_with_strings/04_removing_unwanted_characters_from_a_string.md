# Removing Unwanted Characters from a String Problem

You want **to remove specific characters from your data**.

A scenario where this may occur is in dealing with `badly formatted numeric data`, especially **currency data**, where `commas` have been used to separate zeros, and **currency markers** are mixed in the column with the quantity.

Another scenario is that you want to export data from your database as a CSV file, but there is a `text field containing commas`, which will be read as separators when the CSV file is accessed. Consider this result set:

```SQL
SELECT ename,
       sal
  FROM emp;
```

|ename  | sal|
|:-----:|:---:|
|SMITH  |  800|
|ALLEN  | 1600|
|WARD   | 1250|
|JONES  | 2975|
|MARTIN | 1250|
|BLAKE  | 2850|
|CLARK  | 2450|
|SCOTT  | 3000|
|KING   | 5000|
|TURNER | 1500|
|ADAMS  | 1100|
|JAMES  |  950|
|FORD   | 3000|
|MILLER | 1300|

**(14 rows)**

You want to **remove all zeros** and **vowels** as shown by the following values in columns `STRIPPED1` and `STRIPPED2`:

|ename  | stripped1 | sal  | stripped2|
|:-----:|:---------:|:----:|:----------:|
|SM**I**TH  | SMTH      |  800 | 8|
|**A**LL**E**N  | LLN       | 1600 | 16|
|W**A**RD   | WRD       | 1250 | 125|
|J**O**N**E**S  | JNS       | 2975 | 2975|
|M**A**RT**I**N | MRTN      | 1250 | 125|
|BL**A**K**E**  | BLK       | 2850 | 285|
|CL**A**RK  | CLRK      | 2450 | 245|
|SC**O**TT  | SCTT      | 3000 | 3|
|K**I**NG   | KNG       | 5000 | 5|
|T**U**RN**E**R | TRNR      | 1500 | 15|
|**A**D**A**MS  | DMS       | 1100 | 11|
|J**A**M**E**S  | JMS       |  950 | 95|
|F**O**RD   | FRD       | 3000 | 3|
|M**I**LL**E**R | MLLR      | 1300 | 13|

## Solution

Each DBMS provides functions for removing unwanted characters from a string. The functions [REPLACE](https://github.com/lpinzari/sql-psql-udy/blob/master/06_string_functions/15_replace.md) and [TRANSLATE](https://www.postgresqltutorial.com/postgresql-string-functions/postgresql-translate/) are most useful for this problem.

**DB2, Oracle, PostgreSQL, and SQL Server**

Use the built-in functions `TRANSLATE` and `REPLACE` to remove unwanted characters and strings:

```SQL
SELECT ename,
       REPLACE(TRANSLATE(ename,'AEIOU','aaaa'),'a','') AS stripped1,
       sal,
       REPLACE(CAST(sal as char(4)),'0','') AS stripped2
  FROM emp;
```

- **TRANSLATE**:
  - `A` -> `a`
  - `E` -> `a`
  - `I` -> `a`
  - `O` -> `a`
  - `U` -> `a`
- **REPLACE**:
  - `a` -> '' (empty character).

```SQL
SELECT ename,
       REPLACE(
       REPLACE(
       REPLACE(
       REPLACE(
       REPLACE(ename,'A',''),'E',''),'I',''),'O',''),'U','')
       AS stripped1,
       sal,
       REPLACE(CAST(sal as char(4)),'0','') AS stripped2
 FROM emp;
```
