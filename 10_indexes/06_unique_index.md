# UNIQUE Index

The PostgreSQL `UNIQUE` index **enforces the uniqueness of values in one or multiple columns**. To create a `UNIQUE` index, you can use the following syntax:

```SQL
CREATE UNIQUE INDEX index_name
ON table_name(column_name, [...]);
```

Note that only `B-tree` **indexes can be declared as unique indexes**.

When you define an `UNIQUE` index for a column, **the column cannot store multiple rows with the same values**.

If you define a `UNIQUE` index for two or more columns, the combined values in these columns cannot be duplicated in multiple rows.

PostgreSQL treats `NULL` as **distinct value**, therefore, **you can have multiple** `NULL` **values in a column with a** `UNIQUE` index.

When you **define a primary key or a unique constraint for a table**, PostgreSQL automatically creates a corresponding `UNIQUE` index.

## PostgreSQL UNIQUE index examples

The following statement creates a table called `employees`:

```SQL
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE
);
```

In this statement, the `employee_id` is the **primary key column and email column has a unique constraint**, therefore, PostgreSQL created two `UNIQUE` indexes, one for each column.

To show indexes of the `employees` table, you use the following statement:

```SQL
SELECT tablename,
       indexname,
       indexdef
  FROM pg_indexes
 WHERE tablename = 'employees';
```

```console
tablename |      indexname      |                                     indexdef
-----------+---------------------+----------------------------------------------------------------------------------
employees | employees_pkey      | CREATE UNIQUE INDEX employees_pkey ON public.employees USING btree (employee_id)
employees | employees_email_key | CREATE UNIQUE INDEX employees_email_key ON public.employees USING btree (email)
```

## PostgreSQL UNIQUE index – single column example

The following statement adds the `mobile_phone` column to the `employees` table:

```SQL
ALTER TABLE employees
ADD mobile_phone VARCHAR(20);
```

To ensure that the `mobile phone numbers` are distinct for all employees, you define a `UNIQUE` index for the `mobile_phone` column as follows:

```SQL
CREATE UNIQUE INDEX idx_employees_mobile_phone
ON employees(mobile_phone);
```

Let’s take a test.

First, insert a new row into the `employees` table:

```SQL
INSERT INTO employees(first_name, last_name, email, mobile_phone)
VALUES ('John','Doe','john.doe@postgresqltutorial.com', '(408)-555-1234');
```

Second, attempt to insert another row with the same phone number:

```SQL
INSERT INTO employees(first_name, last_name, email, mobile_phone)
VALUES ('Mary','Jane','mary.jane@postgresqltutorial.com', '(408)-555-1234');
```

PostgreSQL issues the following error due to the duplicate mobile phone number:

```console
ERROR:  duplicate key value violates unique constraint "idx_employees_mobile_phone"
DETAIL:  Key (mobile_phone)=((408)-555-1234) already exists.
```

## PostgreSQL UNIQUE index – multiple columns example

The following statement adds two new columns called `work_phone` and `extension` to the employees table:

```SQL
ALTER TABLE employees
ADD work_phone VARCHAR(20),
ADD extension VARCHAR(5);
```

Multiple employees can share the `same work phone number`. However, **they cannot have the same extension number**. To enforce this rule, you can define a `UNIQUE` index on both `work_phone` and `extension` columns:

```SQL
CREATE UNIQUE INDEX idx_employees_workphone
ON employees(work_phone, extension);
```

```SQL
SELECT tablename,
       indexname,
       indexdef
  FROM pg_indexes
 WHERE tablename = 'employees';
```

```console
tablename |         indexname          |                                              indexdef
-----------+----------------------------+-----------------------------------------------------------------------------------------------------
employees | employees_pkey             | CREATE UNIQUE INDEX employees_pkey ON public.employees USING btree (employee_id)
employees | employees_email_key        | CREATE UNIQUE INDEX employees_email_key ON public.employees USING btree (email)
employees | idx_employees_mobile_phone | CREATE UNIQUE INDEX idx_employees_mobile_phone ON public.employees USING btree (mobile_phone)
employees | idx_employees_workphone    | CREATE UNIQUE INDEX idx_employees_workphone ON public.employees USING btree (work_phone, extension)
(4 rows)
```

To test this index, first insert a row into the `employees` table:

```SQL
INSERT INTO employees(first_name, last_name, work_phone, extension)
VALUES('Lily', 'Bush', '(408)-333-1234','1212');
```

Second, insert another employee with the same work `phone number` but a different `extension`:

```SQL
INSERT INTO employees(first_name, last_name, work_phone, extension)
VALUES('Joan', 'Doe', '(408)-333-1234','1211');
```

The statement works because the combination of values in the `work_phone` and `extension` column are unique.

```console
dvdrental=# SELECT * FROM employees;
 employee_id | first_name | last_name |              email              |  mobile_phone  |   work_phone   | extension
-------------+------------+-----------+---------------------------------+----------------+----------------+-----------
           1 | John       | Doe       | john.doe@postgresqltutorial.com | (408)-555-1234 | NULL           | NULL
           3 | Lily       | Bush      | NULL                            | NULL           | (408)-333-1234 | 1212
           4 | Joan       | Doe       | NULL                            | NULL           | (408)-333-1234 | 1211
```

Third, attempt to insert a row with the same values in both `work_phone` and `extension` columns that already exist in the `employees` table:

```SQL
INSERT INTO employees(first_name, last_name, work_phone, extension)
VALUES('Tommy', 'Stark', '(408)-333-1234','1211');
```

PostgreSQL issued the following error:

```console
ERROR:  duplicate key value violates unique constraint "idx_employees_workphone"
DETAIL:  Key (work_phone, extension)=((408)-333-1234, 1211) already exists.
```
