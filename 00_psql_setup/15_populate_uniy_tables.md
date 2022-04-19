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

## INSERT - Foreign Key Constraint

We **must** `INSERT` **the records in all the parent tables first and then populate the remaining childs tables**.

![uniY table4](../00_basic_intro/images/08_uniY.png)

For example, the Uniy sample database shows that the **sections** table is the child of the **courses** and **teachers** tables.

The records in the **teachers** table are listed below:

|teacher_id |    teacher_name    |   phone    |  salary|
|:----------|:------------------:|:----------:|--------:|
|430        | Dr. Engle          | 256-4621   | 38200.00|
|213        | Dr. Wright         | 257-3393   | 35000.00|
|303        | Dr. Horn           | 257-3049   | 29605.50|
|290        | Dr. Lowe           | 257-2390   | 33808.75|
|180        | Dr. Cooke          | 257-8088   | 31777.00|
|560        | Dr. Olsen          | 257-8086   | 34161.35|
|784        | Dr. Scango         | 257-3046   | 34505.35|

And the **courses** table has no records.

If we try to insert a record in a child table for which there is no correspondent key(s) in the parent(s) table(s) then the DBMS will show a message that tells the user a constraint violation of the foreign key.

```console
uniy=> INSERT INTO sections
uniy->        (course_id, section_id, teacher_id, num_students)
uniy-> VALUES
uniy->        (1, 303, 450, 2),
uniy->        (1, 290, 730, 6),
uniy->        (1, 430, 290, 3),
uniy->        (1, 180, 480, 3),
uniy->        (2, 560, 450, 2),
uniy->        (2, 784, 480, 2);
ERROR:  insert or update on table "sections" violates foreign key constraint "sections_fkey_course"
DETAIL:  Key (course_id)=(1) is not present in table "courses".
```

## Summary

**Now, we have almost all the instruments to create** the `.sql` file to create and populate the tables in the `uniy` database.

In the next lessons we'll introduce a few more concepts:

- **Adding Records** Using `SELECT`
- `UPDATE` statement and (forign key cascade effect)
- `DELETE` statement and (foreign key cascade effect)
- `DROP TABLE` statement and (foreign key cascade effect)
- **Transactions**

Finally, we'll populate the `uniy` database.
