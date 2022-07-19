# CONCAT_WS Function PostgreSQL

Besides the `CONCAT` function, PostgreSQL also provides you with the **CONCAT_WS** function that **concatenates strings into one separated by a particular** `separator`. By the way, `WS` stands for **with separator**.

Like the CONCAT function, the **CONCAT_WS** function is also variadic and **ignored NULL values**.

The following illustrates the syntax of the **CONCAT_WS** function.

```SQL
CONCAT_WS(separator,str_1,str_2,...);
```

The `separator` is a **string that separates all arguments in the result string**.

The `str_1`, `str_2`, `etc`., are strings or any arguments that can be converted into strings.

The **CONCAT_WS** function returns **a combined string that is the combination** of `str_1`, `str_2`, `etc`., **separated by the** `separator`.

## PostgreSQL CONCAT_WS function example

The following statement concatenates the last name and first name and separates them by a comma and a space:

```SQL
SELECT CONCAT_WS (', ', last_name, first_name) AS full_name
  FROM customer
 ORDER BY last_name
 LIMIT 3;
```

**Results**

|full_name|
|:---------------:|
|Abney, Rafael|
|Adam, Nathaniel|
|Adams, Kathleen|
