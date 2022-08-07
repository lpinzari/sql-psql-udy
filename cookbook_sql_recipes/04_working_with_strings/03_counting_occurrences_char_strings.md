# Counting the Occurrences of a Character in a String Problem

You want to count the **number of times a character or substring occurs within a given string**. Consider the following string:

- `10,CLARK,MANAGER`

You want to determine how many `commas` are in the string.

## Solution

**Subtract the length of the string without the commas** from the original length of the string to determine the `number of commas in the string`. Each DBMS provides functions for obtaining the length of a string and removing characters from a string. In most cases, these functions are `LENGTH` and `REPLACE`, respectively (SQL Server users will use the built-in function LEN rather than LENGTH):

```SQL
SELECT (LENGTH('10,CLARK,MANAGER')-
        LENGTH(REPLACE('10,CLARK,MANAGER',',','')) ) / length(',')
        AS cnt
  FROM t1;
```

## Discussion

You arrive at the solution by using simple subtraction.

```SQL
SELECT LENGTH('10,CLARK,MANAGER')
  FROM t1;
```

|length|
|:-----:|
|    16|

The call to `LENGTH` on line 1 returns the original size of the string,

```SQL
SELECT LENGTH(REPLACE('10,CLARK,MANAGER',',',''))
  FROM t1;
```

|length|
|:-----:|
|    14|

and the first call to `LENGTH` on line 2 returns the size of the string without the commas, which are removed by REPLACE.

```SQL
SELECT (LENGTH('10,CLARK,MANAGER')-
        LENGTH(REPLACE('10,CLARK,MANAGER',',','')) )
        AS d
  FROM t1;
```

|d|
|:--:|
|2|

By subtracting the two lengths, you obtain the difference in terms of characters, which is the number of commas in the string.

```SQL
SELECT (LENGTH('10,CLARK,MANAGER')-
        LENGTH(REPLACE('10,CLARK,MANAGER',',','')) ) / length(',')
        AS cnt
  FROM t1;
```

|cnt|
|:---:|
|  2|

The last operation divides the difference by the length of your search string (in this case is `1`). **This division is necessary if the string you are looking for has a length greater than 1**.

In the following example, counting the occurrence of “`LL`” in the string “HE**LL**O HE**LL**O” without dividing will return an incorrect result:

```SQL
SELECT (LENGTH('HELLO HELLO') -
        LENGTH(REPLACE('HELLO HELLO','LL','')) ) / length('LL') AS correct_cnt,
       (LENGTH('HELLO HELLO') -
        LENGTH(REPLACE('HELLO HELLO','LL','')) ) AS incorrect_cnt
  FROM t1;
```

|correct_cnt | incorrect_cnt|
|:----------:|:------------:|
|          2 |             4|
