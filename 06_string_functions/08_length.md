# LENGTH Function PostgreSQL

The following illustrates the syntax of the length function:

```SQL
LENGTH(string);
```
The length function accepts a string as a parameter. A string can be any of the following data types:

- character or char
- character varying or varchar
- text

The **length** function **returns the number of characters in the string**.

## PostgreSQL length function examples

See the following example of using the length function:

```SQL
SELECT LENGTH ('PostgreSQL Tutorial'); -- 19
```

Notice that a string can hold an empty string, which is not a null value.

```SQL
SELECT LENGTH (''); -- 0
```

It returns zero. However, a string that holds a space character:

```SQL
SELECT LENGTH (' '); -- 1
```

It returns 1.

If you pass a `NULL` value to the length function, it returns a `NULL` value.

```SQL
SELECT LENGTH (NULL); -- NULL
```

The following query gets the full names of customers in the customer table and uses the length function to get the number of characters in their names.

```SQL
SELECT first_name || ' ' || last_name AS name,
       LENGTH (first_name || ' ' || last_name) len
  FROM customer
 ORDER BY len
 LIMIT 3;
```

**Results**

|name   | len|
|:-------:|:----:|
|Jim Rea  |   7|
|Gary Coy |   8|
|Kim Cruz |   8|

Sometimes, you may want to measure the length of a number instead of a string. In this case, you use `type cast` to **convert the number into a string** and use the length function as the following example:

```SQL
SELECT LENGTH (CAST(12345 AS TEXT)); --- 5
```

We often use the **length** function with other string functions such as `replace`, `substring`, `etc`., to **manipulate string more efficiently**. The following statement gets the user name and domain from the an email address using `substring`, `strpos`, and `length` functions.

```SQL
SELECT SUBSTRING ('info@postgresqltutorial.com', 1,
                  STRPOS('info@postgresqltutorial.com','@') - 1
                ) AS user_name,
       SUBSTRING ('info@postgresqltutorial.com',
                  STRPOS('info@postgresqltutorial.com','@') + 1,
                  LENGTH ('info@postgresqltutorial.com')
                ) AS domain_name;
```

**Results**

|user_name |      domain_name|
|:---------:|:-----------------------:|
| info      | postgresqltutorial.com|

## Measure strings in bytes and bits

To get the number of bytes in a string, you use the **octet_length** function as follows:

```SQL
OCTET_LENGTH(string);
```
See the following example:

```SQL
SELECT
	OCTET_LENGTH ('A'); -- 1 byte
```

It returns 1 byte.

```SQL
SELECT
	OCTET_LENGTH ('€'); -- 3 bytes
```

It returns 3 bytes. However, with the length function, it returns just 1.

To measure the number of bits of a string, you use the **bit_length** function as follows:  

```SQL
BIT_LENGTH(string);
```

See the following examples of using the bit_length function.

```SQL
SELECT BIT_LENGTH ('A'); -- 8 bits
SELECT BIT_LENGTH ('€'); -- 24 bits
```
