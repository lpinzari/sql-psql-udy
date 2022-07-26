# CREATE TRIGGER

To **create a new trigger** in PostgreSQL, you follow these steps:

- First, create a trigger function using **CREATE FUNCTION** statement.
- Second, **bind the trigger function to a table** by using **CREATE TRIGGER** statement.

## Create trigger function syntax

A trigger function is similar to a regular `user-defined` function. However, a trigger function does not take any arguments and has a return value with the type trigger.

The following illustrates the syntax of **creating trigger function**:

```SQL
CREATE FUNCTION trigger_function()
   RETURNS TRIGGER
   LANGUAGE PLPGSQL
AS $$
BEGIN
   -- trigger logic
END;
$$
```

Notice that you can create a trigger function using any languages supported by PostgreSQL. In this tutorial, we will use `PL/pgSQL`.

A trigger function receives data about its calling environment through a special structure called `TriggerData` which contains a set of `local variables`.

For example, `OLD` and `NEW` represent the **states of the row in the table before or after the triggering event**.

PostgreSQL also provides other `local variables` preceded by `TG_` such as `TG_WHEN`, and `TG_TABLE_NAME`.

Once you define a trigger function, you can bind it to one or more trigger events such as `INSERT`, `UPDATE`, and `DELETE`.

## Introduction to PostgreSQL CREATE TRIGGER statement

The `CREATE TRIGGER` statement creates a new trigger. The following illustrates the basic syntax of the `CREATE TRIGGER` statement:

```SQL
CREATE TRIGGER trigger_name
   {BEFORE | AFTER} { event }
   ON table_name
   [FOR [EACH] { ROW | STATEMENT }]
       EXECUTE PROCEDURE trigger_function
```

In this syntax:

- First, specify the `name` of the trigger after the `TRIGGER` keywords.

- Second, specify the **timing** that cause the trigger to fire. It can be `BEFORE` or `AFTER` **an event occurs**.

- Third, specify the **event** that invokes the trigger. The event can be `INSERT` , `DELETE`, `UPDATE` or `TRUNCATE`.

- Fourth, specify the `name of the table` associated with the trigger after the `ON` keyword.

- Fifth, specify the `type of triggers` which can be:
  - `Row-level trigger` that is specified by the `FOR EACH ROW` clause.
  - `Statement-level` trigger that is specified by the `FOR EACH STATEMENT` clause.

A `row-level trigger` is **fired for each row** while a `statement-level trigger` **is fired for each transaction**.

Suppose a table has 100 rows and two triggers that will be fired when a `DELETE` event occurs.

If the `DELETE` statement deletes 100 rows, the `row-level trigger` will fire `100` times, once for each deleted row. On the other hand, a `statement-level trigger` will be fired for `one time` regardless of how many rows are deleted.

- Finally, specify the `name of the trigger function` after the `EXECUTE PROCEDURE` keywords.

## PostgreSQL CREATE TRIGGER example

The following statement create a new table called `employees`:

```SQL
DROP TABLE IF EXISTS employees;

CREATE TABLE employees(
   id INT GENERATED ALWAYS AS IDENTITY,
   first_name VARCHAR(40) NOT NULL,
   last_name VARCHAR(40) NOT NULL,
   PRIMARY KEY(id)
);
```

Suppose that when `the name` of an employee **changes**, you want to log the changes in a separate table called `employee_audits`:

```SQL
CREATE TABLE employee_audits (
   id INT GENERATED ALWAYS AS IDENTITY,
   employee_id INT NOT NULL,
   last_name VARCHAR(40) NOT NULL,
   changed_on TIMESTAMP(6) NOT NULL
);
```

First, create a new function called `log_last_name_changes`:

```SQL
CREATE OR REPLACE FUNCTION log_last_name_changes()
  RETURNS TRIGGER
  LANGUAGE PLPGSQL
  AS
$$
BEGIN
  IF NEW.last_name <> OLD.last_name THEN
     INSERT INTO employee_audits(employee_id,last_name,changed_on)
     VALUES(OLD.id,OLD.last_name,now());
  END IF;

  RETURN NEW;
END;
$$;
```

The function `inserts` the **old** `last name` into the `employee_audits` table including employee `id`, `last name`, and the `time of change` if the last name of an employee changes.

The `OLD` represents **the row before update** while the `NEW` represents **the new row that will be updated**. The `OLD.last_name` returns the last name before the update and the `NEW.last_name` returns the new last name.

Second, **bind the trigger function to the** `employees` table. The trigger name is `last_name_changes`. Before the value of the `last_name` column is updated, the trigger function is automatically invoked to log the changes.

```SQL
CREATE TRIGGER last_name_changes
  BEFORE UPDATE
  ON employees
  FOR EACH ROW
  EXECUTE PROCEDURE log_last_name_changes();
```

Third, insert some rows into the employees table:

```SQL
INSERT INTO employees (first_name, last_name)
VALUES ('John', 'Doe');

INSERT INTO employees (first_name, last_name)
VALUES ('Lily', 'Bush');
```

Fourth, examine the contents of the `employees` table:

```SQL
SELECT * FROM employees;
```

**Results**

|id | first_name | last_name|
|:--:|:----------:|:--------:|
| 1 | John       | Doe|
| 2 | Lily       | Bush|

Suppose that `Lily Bush` changes her last name to `Lily Brown`.

Fifth, update `Lily’s last name` to the new one:

```SQL
UPDATE employees
SET last_name = 'Brown'
WHERE ID = 2;
```
Seventh, check if the last name of `Lily` has been updated:

```SQL
SELECT * FROM employees;
```

|id | first_name | last_name|
|:-:|:----------:|:--------:|
| 1 | John       | Doe|
| 2 | Lily       | Brown|

As you can see from the output, **Lily’s last name has been updated**.

Eighth, verify the contents of the `employee_audits` table:

```SQL
SELECT * FROM employee_audits;
```

|id | employee_id | last_name |         changed_on|
|:--:|:-----------:|:---------:|:------------------------:|
| 1 |           2 | Bush      | 2022-07-26 20:25:19.158971|

The change was logged in the `employee_audits` table by the trigger.
