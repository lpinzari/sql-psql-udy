# Enforcing Referential Integrity with Constraints

Whenever two tables contain one or more common columns, PostgreSQL or any DBMS can enforce the relationship between the two tables through a **referential integrity constraint**. Define a PRIMARY or UNIQUE key constraint on the column in the parent table (the one that has the complete set of column values). Define a FOREIGN KEY constraint on the column in the child table (the one whose values must refer to existing values in the other table).

In the `hr` sample database, the tables foreign key constraints include only a single column. We discussed the case of **foreign keys** `composed of multiple columns` in the `uiny` sample database. Such a **composite foreign key** must reference a **composite primary key** of the exact structure, with the same number of columns and the same data types.

![uny erd](../00_basic_intro/images/11_uniy_erd.png)

For example, in the `enrolls` **TABLE** the **FOREIGN KEY**, (`course_id`, `section_id`) **REFERENCES** a record in the `sections` parent table using the primary key (`course_id, section_id`).


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
     ON DELETE CASCADE
);
```

In the `enrolls` table definition, the composite foreign key `(course_id, section_id)` allows key values that are all `NULL`. By default, the foreign key constraint enforces the **match none rule** for composite foreign keys. In case of a **match not null rule**, the table definition is:

```console
CREATE TABLE enrolls (
  course_id SMALLINT NOT NULL,
  section_id SMALLINT NOT NULL,
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
     ON DELETE CASCADE
);
```

## Defining Relationships Between Parent and Child Tables

Several relationships between parent and child tables can be determined by the other **types of constraints** defined on the `foreign key` in the child table.

### No Constraints on the Foreign Key

When no other constraints are defined on the foreign key, any number of rows in the child table can reference the same parent key value. **This model allows undetermined values (nulls) in the foreign key**.

This model establishes a `zero-or-one` relationship between the child and parent table. And a `zero-or-more` realtionship between the parent and child table. Sometimes, we say `one-to-many` relationship. Any number of rows in the child table can reference a row in the parent table.

### NOT NULL Constraint on the Foreign Key

When nulls are not allowed in a foreign key, **each row in the child table must explicitly reference a value in the parent key** because nulls are not allowed in the foreign key.

Any number of rows in the child table can reference the same parent key value, so this model establishes a `one-to-many` relationship between the parent and foreign keys.

However, each row in the child table must have a reference to a parent key value; the absence of a value (a null) in the foreign key is not allowed. It follows, that the model establish a `one and only one` relationship between the child and parent table.

### UNIQUE Constraint on the Foreign Key

When a `UNIQUE` constraint is defined on the foreign key, **only one row in the child table can reference a given parent key value**. This model allows `nulls` in the foreign key. The `UNIQUE` constraint on the foreign key column does not allow duplicate values and those values are drawn from the `UNIQUE` or primary column of the parent table. Therefore, a record in the child table references a record in the parent table and viceversa.

This model establish a `zero-to-one` relationship between the parent and child tables. And a `zero-to-one` relationship between the child and parent tables.

In general we establish a `one-to-one` relationship between the parent and foreign keys that allows undetermined values (nulls) in the foreign key.

For example, assume that the `employees` table had a column named `MEMBERNO`, referring to an employee membership number in the company insurance plan. Also, a table named `insuranses` has a primary key named MEMBERNO, and other columns of the table keep respective information relating to an employee insurance policy. The MEMBERNO in the employee table must be both a foreign key and a unique key.

To guarantee that each employee has a unique membership number (the UNIQUE key constraint).

### UNIQUE and NOT NULL Constraints on the Foreign Key

When both `UNIQUE` and `NOT NULL` constraints are defined on the foreign key, **only one row in the child table can reference a given parent key value**, and because NULL values are not allowed in the foreign key, **each row in the child table must explicitly reference a value in the parent key**.

This model establish a `zero-to-one` relationship between the parent and child tables. And a `one-only-one` relationship between the child and parent tables.

This model establishes a one-to-one relationship between the parent and foreign keys that does not allow undetermined values (nulls) in the foreign key. If you expand the previous example by adding a `NOT NULL` constraint on the `MEMBERNO` column of the employee table, in addition to guaranteeing that each employee has a unique membership number, you also ensure that no undetermined values (nulls) are allowed in the `MEMBERNO` column of the employee table.

### NULL and CHECK constraints

In the `composite foreign key`example, we presented two possible scenarios for the `enrolls` table:

1. `NO CONSTRAINTS ON` **THE FOREIGN KEY**.
2. `NOT NULL CONSTRAINT ON` **THE FOREIGN KEY**.

The first scenario allows missing values in the `course_id` and `section_id` columns. So, the possible cases are:

|course_id|section_id|
|:-------:|:--------:|
|NULL|NULL|
|NULL|val|
|val|NULL|
|val|val|

Where, `val` is a feasible value for the `course_id` and `section_id` columns. In this case, is an integer value.

The second scenario, does not allow missing values in the foreign key columns. It follows that the only case is:

|course_id|section_id|
|:-------:|:--------:|
|val|val|

What if we wanted the following scenario.

|course_id|section_id|
|:-------:|:--------:|
|NULL|NULL|
|val|val|

In this scenario, we want to enforce the **match full rule** for NULL values in composite foreign keys, which requires that all components of the key be `NULL` or all be `NON-NULL`. To enforce the **match full rule** we must define a **CHECK CONSTRAINT** that allows **only all nulls** `or` **only all non-nulls** in the composite foreign key.

```console
CHECK ((course_id IS NULL AND section_id IS NULL)) OR
       (course_id NOT NULL AND section_id NOT NULL)
```

In the next lesson, we introduce the syntax and use of the **CHECK CONSTRAINT**. We also recap the notio of `NULL`, `NOT NULL` and `UNIQUE` **CONSTRAINTS**.
