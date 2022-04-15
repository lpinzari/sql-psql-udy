# PostgreSQL - INSERT MULTIPLE ROWS

In this lesson, you will learn **how to use a single** PostgreSQL `INSERT` statement **to insert multiple rows into a table**.

In the previous lessons the `INSTERT` satement has been used multiple times to insert records into a table.

For example, to add two new records into the `teachers` table, you could type:

```console
INSERT INTO teachers
       (teacher_id, teacher_name, phone, salary)
VALUES (303, 'Dr. Horn', '257-3049', 27540.00);
INSERT INTO teachers
       (teacher_id, teacher_name, phone, salary)
VALUES (290, 'Dr. Lowe', '257-2390', DEFAULT)
```

Or a less verbose syntax:

```console
INSERT INTO teachers VALUES (303, 'Dr. Horn', '257-3049', 27540.00);
INSERT INTO teachers VALUES (290, 'Dr. Lowe', '257-2390', 31450.00);
```

A better way to insert multiple rows into a table is to use a single `INSERT` statement.

To insert multiple rows into a table using a single INSERT statement, you use the following syntax:

```console
INSERT INTO table_name
       (column_list)
VALUES
       (value_list_1),
       (value_list_2),
       ...
       (value_list_n);
```

In this syntax:

1. First, specify the name of the table that you want to insert data after the `INSERT INTO` keywords.
2. Second, list the required columns or all columns of the table in parentheses that follow the table name.
3. Third, supply a comma-separated list of rows after the `VALUES` keyword.

To insert multiple rows and return the inserted rows, you add the RETURNING clause as follows:

```console
INSERT INTO table_name
       (column_list)
VALUES
       (value_list_1),
       (value_list_2),
       ...
       (value_list_n)
RETURNING * | output_expression;
```

For example, the two `INSERT` statements could be typed:

```console
INSERT INTO teachers
       (teacher_id, teacher_name, phone, salary)
VALUES
       (303, 'Dr. Horn', '257-3049', 27540.00),
       (290, 'Dr. Lowe', '257-2390', DEFAULT);
```

Let's execute the command in the prompt:

```console
uniy=> INSERT INTO teachers
uniy->        (teacher_id, teacher_name, phone, salary)
uniy-> VALUES
uniy->        (303, 'Dr. Horn', '257-3049', 27540),
uniy->        (290, 'Dr. Lowe', '257-2390', DEFAULT);
INSERT 0 2
```
Let's list all the records in the table.

```console
uniy=> SELECT *
uniy->   FROM teachers;
 teacher_id |    teacher_name    |   phone    |  salary
------------+--------------------+------------+----------
        303 | Dr. Horn           | 257-3049   | 27540.00
        290 | Dr. Lowe           | 257-2390   |
(2 rows)
```

Let's delete all records in the `teachers` table.

```console
uniy=> DELETE FROM teachers
uniy->       WHERE teacher_id IS NOT NULL;
DELETE 2
```

**Now, we have almost all the instruments to create** the `.sql` file to create and populate the tables in the `uniy` database.

In the next lessons we'll introduce few more concepts:

- **Adding Records** Using `SELECT`
- `DELETE` statement
- `UPDATE` statement
- `DROP TABLE`

Finally, we'll populate the `uniy` database.
