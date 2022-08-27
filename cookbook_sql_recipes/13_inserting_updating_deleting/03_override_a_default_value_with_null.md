# Overriding a Default Value with NULL

You are inserting into a column having a default value, and you want to override that default value by setting the column to `NULL`.

## Problem

Consider the following table:

```SQL
CREATE TABLE d (
  id INTEGER DEFAULT 0,
  foo VARCHAR(10)
);
```
You want to insert a row with a `NULL` value for `ID`.

## Solution

You can explicitly specify `NULL` in your values list:

```SQL
INSERT INTO d
       (id, foo)
VALUES (NULL,'Brighten');
```

|id|foo|
|:--:|:--:|
||Brighten|

## Discussion

Not everyone realizes that you can explicitly specify `NULL` in the values list of an `INSERT` statement. Typically, when you do not want to specify a value for a column, you leave that column out of your column and values lists:

```SQL
INSERT INTO d
       (foo)
VALUES ('Brighten');
```

|id|foo|
|:--:|:--:|
|0|Brighten|

Here, no value for `ID` is specified. Many would expect the column to taken on the null value, but, alas, a default value was specified at table creation time, so the result of the preceding `INSERT` is that `ID` takes on the value `zero` (the default). By specifying `NULL` as the value for a column, you can set the column to `NULL` despite any default value (excepting where a constraint has been specifically applied to prevent `NULLs`).
