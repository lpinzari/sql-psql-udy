# Separating Numeric and Character Data Problem

You have **numeric data stored with character data together in one column**. This could easily happen if you inherit data where `units of measurement` or `currency` have been stored with their quantity (e.g., a column with `100 km`, `AUD$200`, or `40 pounds`, rather than either the column making the units clear or a separate column showing the units where necessary).

You want to separate the character data from the numeric data. Consider the following result set:

```SQL
CREATE TABLE temp AS
       SELECT ename || sal AS data FROM emp;

```

```console
cookbook=> \d temp;
              Table "public.temp"
 Column | Type | Collation | Nullable | Default
--------+------+-----------+----------+---------
 data   | text |           |          |
```


|  data|
|:----------:|
| SMITH800|
| ALLEN1600|
| WARD1250|
| JONES2975|
| MARTIN1250|
| BLAKE2850|
| CLARK2450|
| SCOTT3000|
| KING5000|
| TURNER1500|
| ADAMS1100|
| JAMES950|
| FORD3000|
| MILLER1300|

**(14 rows)**

You would like the result to be:

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

## Solution

Use the built-in functions `TRANSLATE` and `REPLACE` to isolate the character from the numeric data. Like other recipes in this chapter, the trick is to use `TRANSLATE` to **transform multiple characters into a single character you can reference**. This way you are no longer searching for multiple numbers or characters; rather, you are searching for just one character to represent all numbers or one character to represent all characters.

```SQL
SELECT REPLACE(
       TRANSLATE(data,'0123456789',
                      '0000000000'),
               '0','') AS ename,
       CAST(
       REPLACE(
       TRANSLATE(LOWER(data),'abcdefghijklmnopqrstuvwxyz',
                              RPAD('z',26,'z'))
                ,'z','')
            AS INTEGER) AS sal
  FROM temp;
```

```SQL
SELECT REPLACE(
       TRANSLATE(x.data,'0123456789',
                        '0000000000'),
               '0','') AS ename,
       CAST(
       REPLACE(
       TRANSLATE(LOWER(x.data),'abcdefghijklmnopqrstuvwxyz',
                                RPAD('z',26,'z'))
               ,'z','')
            AS INTEGER) AS sal
  FROM (SELECT ename || sal AS data FROM emp) x
```

## Discussion

The syntax is a bit different for each DBMS, but the technique is the same. The key to solving this problem is to isolate the numeric and character data. You can use TRANSLATE and REPLACE to do this. To extract the numeric data, first isolate all character data using TRANSLATE:

```SQL
SELECT TRANSLATE(LOWER(data),'abcdefghijklmnopqrstuvwxyz',
                              RPAD('z',26,'z'))
  FROM temp;
```

|translate|
|:----------:|
|zzzzz800|
|zzzzz1600|
|zzzz1250|
|zzzzz2975|
|zzzzzz1250|
|zzzzz2850|
|zzzzz2450|
|zzzzz3000|
|zzzz5000|
|zzzzzz1500|
|zzzzz1100|
|zzzzz950|
|zzzz3000|
|zzzzzz1300|

- `RPAD('z',26,'z')`: 'zzzzzzzzzzzzzzzz'.

By using `TRANSLATE` you convert every nonnumeric character into a lowercase Z. The next step is to remove all instances of lowercase Z from each record using `REPLACE`, leaving only numerical characters that can then be cast to a number:

```SQL
SELECT data,
       CAST(
       REPLACE(
       TRANSLATE(LOWER(data),'abcdefghijklmnopqrstuvwxyz',
                              RPAD('z',26,'z'))
               ,'z','') AS INTEGER) AS sal
  FROM temp;
```

|data    | sal|
|:---------:|:----:|
|SMITH800   |  800|
|ALLEN1600  | 1600|
|WARD1250   | 1250|
|JONES2975  | 2975|
|MARTIN1250 | 1250|
|BLAKE2850  | 2850|
|CLARK2450  | 2450|
|SCOTT3000  | 3000|
|KING5000   | 5000|
|TURNER1500 | 1500|
|ADAMS1100  | 1100|
|JAMES950   |  950|
|FORD3000   | 3000|
|MILLER1300 | 1300|

To extract the nonnumeric characters, isolate the numeric characters using `TRANSLATE`:

```SQL
SELECT data,
       TRANSLATE(data,'0123456789',
                      '0000000000') AS ename
  FROM temp;
```

|data    |   ename|
|:---------:|:-----------:|
|SMITH800   | SMITH000|
|ALLEN1600  | ALLEN0000|
|WARD1250   | WARD0000|
|JONES2975  | JONES0000|
|MARTIN1250 | MARTIN0000|
|BLAKE2850  | BLAKE0000|
|CLARK2450  | CLARK0000|
|SCOTT3000  | SCOTT0000|
|KING5000   | KING0000|
|TURNER1500 | TURNER0000|
|ADAMS1100  | ADAMS0000|
|JAMES950   | JAMES000|
|FORD3000   | FORD0000|
|MILLER1300 | MILLER0000|

By using `TRANSLATE`, you convert every numeric character into a zero. The next step is to remove all instances of zero from each record using `REPLACE`, leaving only nonnumeric characters:

```SQL
SELECT data,
       REPLACE(
       TRANSLATE(data,'0123456789',
                      '0000000000'),'0','') AS ename
  FROM temp;
```

|data    | ename|
|:---------:|:------:|
|SMITH800   | SMITH|
|ALLEN1600  | ALLEN|
|WARD1250   | WARD|
|JONES2975  | JONES|
|MARTIN1250 | MARTIN|
|BLAKE2850  | BLAKE|
|CLARK2450  | CLARK|
|SCOTT3000  | SCOTT|
|KING5000   | KING|
|TURNER1500 | TURNER|
|ADAMS1100  | ADAMS|
|JAMES950   | JAMES|
|FORD3000   | FORD|
|MILLER1300 | MILLER|

Put the two techniques together and you have your solution.
