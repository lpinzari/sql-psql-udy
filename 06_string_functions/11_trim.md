# TRIM Function PostgreSQL

The `TRIM()` function **removes the longest string that contains a specific character from a string**. By default, the `TRIM()` function remove spaces `(‘ ‘)` if you don’t specify explicitly which character that you want to remove.

With the `TRIM()` function, **you can remove the longest string containing a character from the start, end, or both the start and end of a string**. Note that a string can be any of the following data types: `char`, `varchar`, and `text`.

The `TRIM()` function is **very useful when we want to remove the unwanted characters from a string in the database**. We often use it for **data cleansing**.

The following illustrates the syntax of the `TRIM()` function.

```SQL
TRIM([LEADING | TRAILING | BOTH] [characters] FROM string)
```

For example, if you want to `remove spaces` from the **beginning of a string**, you use the following syntax:

```SQL
TRIM(LEADING FROM string)
```

The following syntax of the **TRIM()** function `removes all spaces` from **the end of a string**.

```SQL
TRIM(TRAILING FROM string)
```

And to remove all spaces at the beginning and ending of a string, you use the following syntax:

```SQL
TRIM(BOTH FROM string)
```

Or just simply:

```SQL
TRIM(string)
```

## PostgreSQL TRIM function examples

See the following examples of removing `leading`, `trailing`, and `both` leading and trailing spaces from strings.

```SQL
SELECT TRIM (LEADING  FROM '  PostgreSQL TRIM'),
       TRIM (TRAILING FROM 'PostgreSQL TRIM   '),
       TRIM ('  PostgreSQL TRIM  ');
```

**Results**

|ltrim      |      rtrim      |      btrim|
|:----------------:|:-----------------:|:----------------:|
|PostgreSQL TRIM | PostgreSQL TRIM | PostgreSQL TRIM|

The following statement updates the `first_name` and `last_name` columns of the `customer` table in the `dvdrental` sample database with the values that do not have leading and trailing spaces. It uses the **TRIM()** function to remove both leading and trailing spaces from the `first_name` and `last_name` columns.

```SQL
UPDATE customer
SET first_name = TRIM (first_name),
    last_name = TRIM (last_name);
```

The following statement **removes** `leading zero` (**0**) **from a number**. Because the  `TRIM()` function only accepts a string as the argument, we have to use **type cast** to **convert the number into a string before passing it to the** `TRIM()` function.

```SQL
SELECT TRIM (LEADING '0' FROM CAST (0009100 AS TEXT)); -- 9100
```

## PostgreSQL LTRIM, RTRIM, and BTRIM functions

PostgreSQL provides you with `LTRIM`, `RTRIM()` and `BTRIM` functions that are the **shorter version** of the `TRIM()` function.

- The **LTRIM()** function **removes all characters**, spaces by default, from **the beginning of a string**.
- The **RTRIM()** function **removes all characters**, spaces by default, from **the end of a string**.
- The **BTRIM** function is the **combination of the** `LTRIM()` and `RTRIM()` functions.

The syntax of `LTRIM()` and `RTRIM()` function are as follows:

```SQL
LTRIM(string, [character]);
RTRIM(string, [character]);
BTRIM(string, [character]);
```

This is equivalent to the following syntax of the `TRIM()` function:

```SQL
TRIM(LEADING character FROM string); -- LTRIM(string,character)
TRIM(TRAILING character FROM string); -- RTRIM(string,character)
TRIM(BOTH character FROM string); -- BTRIM(string,character)
```

Let’s take a look at the following examples of using the `LTRIM()`, `RTRIM()` , and `BTRIM()` functions to remove the character `e` from the `enterprise` string:

```SQL
SELECT LTRIM('enterprise', 'e'),
       RTRIM('enterprise', 'e'),
       BTRIM('enterprise', 'e');
```

**Results**

|ltrim   |   rtrim   |  btrim|
|:------:|:----------:|:---------:|
|nterprise | enterpris | nterpris|

## Removing whitespace characters from a string

Sometimes, your string may contain `whitespace` characters such as `space`, `tab`, `line break`, `etc`., that **you want to remove**.

However, the `TRIM()` function **only allows you to remove leading and trailing spaces**, `not all other whitespace characters`. You can call the `TRIM()` function multiple times but it is not efficient.

One way to remove the leading and trailing whitespace characters from a string is to use **REGEXP_REPLACE()** function.

For example, the following statement removes a `space` and a `tab` character **from the end** of the enterprise string with `1 space` and `1 tab characters` at the end of the string.

```SQL
SELECT REGEXP_REPLACE('enterprise 	', '\s+$', '');
```

The `\s+$` pattern is explained as follows:

- `\s` : regular expression class shorthand for **whitespace**.
- `+` means **1 or more consecutive matches**.
- `$`  means the **end of the string**.

You use the `\s+` regular expression if you **want to remove leading whitespace characters**.
