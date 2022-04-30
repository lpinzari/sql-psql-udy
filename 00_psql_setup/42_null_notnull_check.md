# PostgreSQL: CHECK

In this lesson, you will learn about the PostgreSQL **CHECK** constraints and how to use them to **constrain values in columns of a table based** on a `boolean expression`.

A **CHECK** constraint is a kind of constraint that allows you to specify if values in a column must meet a `specific requirement`.

The **CHECK** constraint uses a `Boolean expression` to evaluate the values **before they are** `inserted` or `updated` to the column.

If the values pass the check, PostgreSQL will insert or update these values to the column. Otherwise, PostgreSQL will reject the changes and issue a constraint violation error.

A CHECK constraint requires that a condition be `true` or unknown for every row of the table. If a statement causes the condition to evaluate to false, then the statement is rolled back. The condition of a `CHECK` constraint has these limitations:

- The condition must be a boolean expression that can be evaluated using the values in the row being inserted or updated.

- The condition cannot contain subqueries or sequences.

- The condition cannot contain a user-defined function.

## CHECK

Typically, you use the `CHECK` constraint at the time of creating the table using the `CREATE TABLE` statement.

The following statement defines an `employees` table.

```console
DROP TABLE IF EXISTS employees;
CREATE TABLE employees (
	id SERIAL PRIMARY KEY,
	first_name VARCHAR (50),
	last_name VARCHAR (50),
	birth_date DATE CHECK (birth_date > '1900-01-01'),
	joined_date DATE CHECK (joined_date > birth_date),
	salary numeric CHECK(salary > 0)
);
```

The  `employees` table has three **CHECK** constraints:

1. `birth_date DATE CHECK (birth_date > '1900-01-01'),`:
  - First, the birth date ( `birth_date`) of the employee must be greater than `01/01/1900`. If you try to insert a birth date before `01/01/1900`, you will receive an error message.
2. `joined_date DATE CHECK (joined_date > birth_date)`:
  - Second, the joined date ( `joined_date`) must be greater than the birth date ( `birth_date`). This check will prevent from updating invalid dates in terms of their semantic meanings.
3. `salary numeric CHECK(salary > 0)`:
  - Third, the salary must be greater than zero, which is obvious.

Let’s try to `insert` a new row into the employees table:

```console
INSERT INTO employees (first_name, last_name, birth_date, joined_date, salary)
VALUES ('John', 'Doe', '1972-01-01', '2015-07-01', - 100000);
```
The statement attempted to insert a negative `salary` into the `salary` column. However, PostgreSQL returned the following error message:

```console
[Err] ERROR:  new row for relation "employees" violates check constraint "employees_salary_check"
DETAIL:  Failing row contains (1, John, Doe, 1972-01-01, 2015-07-01, -100000).
```

violation of the "`employees_salary_check`" constraints (-100000 < 0).

The insert failed because of the `CHECK` constraint on the salary column that accepts only positive values.

By default, PostgreSQL gives the `CHECK` constraint a name using the following pattern:

- `{table}_{column}_check`

For example, the constraint on the salary column has the following constraint name:

- `employees_salary_check`

However, if you want to assign a `CHECK` constraint a *specific name*, you can specify it after the `CONSTRAINT` expression as follows:

- `column_name data_type CONSTRAINT constraint_name CHECK(...)`

See the following example:

```console
...
salary numeric CONSTRAINT positive_salary CHECK(salary > 0)
...
```

## Define PostgreSQL CHECK constraints for existing tables

To add `CHECK` constraints to existing tables, you use the `ALTER TABLE` statement. Suppose, you have an existing table in the database named `prices_list`.

```console
CREATE TABLE prices_list (
	id serial PRIMARY KEY,
	product_id INT NOT NULL,
	price NUMERIC NOT NULL,
	discount NUMERIC NOT NULL,
	valid_from DATE NOT NULL,
	valid_to DATE NOT NULL
);
```

Now, you can use `ALTER TABLE` statement to add the `CHECK` constraints to the prices_list table.
- The price and discount must be greater than zero and
- the discount is less than the price.

Notice that we use a Boolean expression that contains the AND operators.

```console
ALTER TABLE prices_list
ADD CONSTRAINT price_discount_check
CHECK (
	price > 0
	AND discount >= 0
	AND price > discount
);
```

The valid to date ( `valid_to`) must be greater than or equal to valid from date ( `valid_from`).

```console
ALTER TABLE prices_list
ADD CONSTRAINT valid_range_check
CHECK (valid_to >= valid_from);
```

The `CHECK` constraints are very useful to place additional logic **to restrict values that the columns can accept at the database layer**. By using the CHECK constraint, you can make sure that data is updated to the database correctly.

### uniY database: the enrolls table

```console
CREATE TABLE enrolls (
  course_id SMALLINT,
  section_id SMALLINT,
  student_id SMALLINT,
  grade SMALLINT,
  PRIMARY KEY (course_id, section_id, student_id),
  CONSTRAINT enrolls_fkey_student
     FOREIGN KEY (student_id)
     REFERENCES students (student_id)
     ON DELETE CASCADE,
  CONSTRAINT enrolls_fkey_course
     FOREIGN KEY (course_id)
     REFERENCES courses (course_id)
     ON DELETE CASCADE,
  CONSTRAINT enrolls_fkey_section
     FOREIGN KEY (course_id, section_id)
     REFERENCES sections (course_id, section_id)
     ON DELETE CASCADE,
  CONSTRAINT enrolls_fkey_section_check
     CHECK ((course_id IS NULL AND section_id IS NULL)) OR
            (course_id NOT NULL AND section_id NOT NULL)
);
```



## Introduction to NULL

In database theory, `NULL` represents `unknown` or **information missing**. NULL is not the same as an empty string or the number zero.

Suppose that you need to insert an `email_address` of a contact into a table. You can request his or her email address. However, if you don’t know whether the contact has an email address or not, you can insert `NULL` into the `email_address` column. In this case, `NULL` **indicates that the** `email_address` **is not known at the time of recording**.

`NULL` is very special. **It does not equal anything, even itself**.

The expression `NULL = NULL` **returns** `NULL` because it makes sense that two unknown values should not be equal.

To check if a value is `NULL` or not, you use the **IS NULL** `boolean operator`. For example, the following expression returns true if the value in the email address is NULL.

```console
email_address IS NULL
```

The **IS NOT NULL** operator negates the result of the **IS NULL** operator.
