# CONCAT FUNCTION PostgreSQL

To **concatenate two or more strings into one**, you use the string concatenation operator **||** as the following example:

```SQL
SELECT
   'Concatenation' || ' ' || 'Operator' AS result_string;
```

**Results**

|result_string|
|:----------------------:|
| Concatenation Operator|

The following statement concatenates a string with a `NULL` value:

```SQL
SELECT
   'Concat with ' || NULL AS result_string;
```

**Results**

|result_string|
|:-------------:|
||

It returns a `NULL` value.

Since version 9.1, PostgreSQL introduced a built-in string function named **CONCAT** to concatenate two or more strings into one.

The following illustrates the syntax of the **CONCAT** function:

```SQL
CONCAT(str_1, str_2, ...)
```

The **CONCAT** function accepts a list of arguments. **The argument needs to be convertible to a string**. A string in this context means any of the following data types: `char`, `varchar`, or `text`.

The `CONCAT` function is **variadic**. It means that the **CONCAT** function accepts an array as the argument. In this case, you need to mark the array with the `VARIADIC` keyword. The `CONCAT` function treats each array element as an argument.

Unlike the concatenation operator `||`, the **CONCAT function ignores**  `NULL` arguments. We will see it in detail in the following section.

## PostgreSQL CONCAT function examples

The following `SELECT` statement uses the **CONCAT** function to **concatenate two strings into one**:

```SQL
SELECT CONCAT ('CONCAT',' ', 'function');
```

**Results**

|concat|
|:----------------:|
|CONCAT function|

The following statement concatenates values in the `first_name` and `last_name` columns of the **customer** table in the `dvdrental` sample database.

```SQL
SELECT CONCAT  (first_name, ' ', last_name) AS "Full name"
  FROM customer;
```

Here's the partial output:

|Full name|
|:---------------------:|
|Jared Ely|
|Mary Smith|
|Patricia Johnson|
|Linda Williams|
|Barbara Jones|
|Elizabeth Brown|
|Jennifer Davis|
|Maria Miller|

In the following example, we use **CONCAT** function to **concatenate a string with a** `NULL` **value**.

```SQL
SELECT CONCAT('Concat with ',NULL) AS result_string;
```

**Results**

|result_string|
|:-------------:|
| Concat with|

As you see, unlike the string concatenation operator `||`, the **CONCAT** `function ignores the NULL arguments`.

The following statement concatenates strings with a number returned from the `LENGTH` function.

```SQL
SELECT first_name,
       CONCAT ('Your first name has ', LENGTH (first_name),' characters')
  FROM customer
 LIMIT 3;
```

**Results**

|first_name |              concat|
|:----------:|:---------------------------------:|
| Jared      | Your first name has 5 characters|
| Mary       | Your first name has 4 characters|
| Patricia   | Your first name has 8 characters|
