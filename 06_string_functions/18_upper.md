# UPPER Function PostgreSQL

To **convert a string into upper case**, you use PostgreSQL `UPPER` function. The following illustrates the syntax of the UPPER function.

```SQL
UPPER(string_expression)
```
Like the `LOWER` function, the `UPPER` function accepts a string expression or string-convertible expression and convert it to a upper case format. In case the argument is not a string, you must use the `CAST` function to explicitly convert it.

The following statement uses the `CONCAT` function and `UPPER` function to return the full name of staff in the upper case:

```SQL
SELECT CONCAT ( UPPER (first_name), UPPER (last_name)) as full_name
  FROM staff;
```

**Output**

|full_name|
|:-----------:|
|MIKEHILLYER|
|JONSTEPHENS|
