# Converting Whole Numbers to Binary

You want to convert a **whole number** to its **binary representation** on an PostgreSql system.

## Problem

For example, you would like to return `all the salaries` in table `EMP` in binary string representation as part of the following result set:

|ename  | sal  |  bit_string|
|:------:|:----:|----------:|
|SMITH  |  800 | 1100100000|
|ALLEN  | 1600 | 11001000000|
|WARD   | 1250 | 10011100010|
|JONES  | 2975 | 101110011111|
|MARTIN | 1250 | 10011100010|
|BLAKE  | 2850 | 101100100010|
|CLARK  | 2450 | 100110010010|
|SCOTT  | 3000 | 101110111000|
|KING   | 5000 | 1001110001000|
|TURNER | 1500 | 10111011100|
|ADAMS  | 1100 | 10001001100|
|JAMES  |  950 | 1110110110|
|FORD   | 3000 | 101110111000|
|MILLER | 1300 | 10100010100|

## Solution


```SQL
SELECT ename,
       sal,
       SUBSTRING((sal::BIT(16))::VARCHAR(16),POSITION('1' IN (sal::BIT(16))::VARCHAR(16)),LENGTH((sal::BIT(16))::VARCHAR(16))) AS bit_string
  FROM emp;  
```

## Discussion


```SQL
SELECT ename,
       sal,
       (sal::BIT(16))::VARCHAR(16) AS bit_16,
       POSITION('1' IN (sal::BIT(16))::VARCHAR(16)) AS pos_1,
       SUBSTRING((sal::BIT(16))::VARCHAR(16),POSITION('1' IN (sal::BIT(16))::VARCHAR(16)),LENGTH((sal::BIT(16))::VARCHAR(16))) AS bit_string
  FROM emp;  
```

The first call is a casting operation of the `sal` numeric column data type to a `BIT` data type. We assume that numbers in the `sal` column can be represented using `16` bits.

- `sal::BIT(16)`

Next we cast the result to a `VARCHAR(16)`:

- `(sal::BIT(16))::VARCHAR(16)`

Next, remove the first zero's digit from the 16 characters strings. In order to to do that, apply the `POSITION` function to find the position of the first `1` character and apply the `SUBSTRING` function to return the final string.
