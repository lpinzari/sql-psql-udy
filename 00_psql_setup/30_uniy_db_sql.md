# uniy backup: Exporting & Importing tables as csv files

In the previous lesson we learned how to export a table to a csv file. In this lesson we show how to **import a csv file** into an existing table. We'll use the **COPY FROM** command.

## NOTES

1. In CSV format, all characters are significant. A quoted value surrounded by white space, or any characters other than DELIMITER, will include those characters. This can cause errors if you import data from a system that pads CSV lines with white space out to some fixed width. If such a situation arises **you might need to preprocess the CSV file to remove the trailing white space, before importing the data into PostgreSQL**.

2. CSV format will both recognize and produce CSV files with quoted values containing embedded carriage returns and line feeds. Thus the files are not strictly one line per table row like text-format files.

3. Many programs produce strange and occasionally perverse CSV files, so the file format is more a convention than a standard. Thus you might encounter some files that cannot be imported using this mechanism, and COPY might produce files that other programs cannot process.

4. The values in each record are separated by the DELIMITER character. If the value contains the delimiter character, the QUOTE character, the NULL string, a carriage return, or line feed character, then the whole value is prefixed and suffixed by the QUOTE character, and any occurrence within the value of a QUOTE character or the ESCAPE character is preceded by the escape character. You can also use FORCE_QUOTE to force quotes when outputting non-NULL values in specific columns.

5. The CSV format **has no standard way to distinguish a** `NULL` **value** from an **empty string**. PostgreSQL's COPY handles this by **quoting**.
  - A `NULL` is output as the NULL parameter string and **is not quoted**,
  - while a `non-NULL` value matching the NULL parameter string **is quoted** (`""`).

For example, with the default settings, a NULL is written as an unquoted empty string, while an empty string data value is written with double quotes (""). Reading values follows similar rules. You can use `FORCE_NOT_NULL` to prevent NULL input comparisons for specific columns. You can also use `FORCE_NULL` to convert quoted null string data values to NULL.


**FORCE_NOT_NULL**

Do not match the specified columns' values against the null string. In the default case where the `null string is empty`, **this means that empty values will be read as zero-length strings rather than** `nulls`, even when they are not quoted. This option is allowed only in **COPY FROM**, and only when using CSV format.

**FORCE_NULL**

Match the specified columns' values against the null string, even if it has been quoted, and if a match is found set the value to NULL. In the default case where the null string is empty, **this converts a quoted empty string** into `NULL`. This option is allowed only in COPY FROM, and only when using CSV format.

## Import a CSV file into a table using COPY statement

```console
(base) ludo /~  $  psql uniy
psql (11.4)
Type "help" for help.

uniy=#
```

We logged in as `superuser`.

```console
uniy=# SELECT * FROM enrolls;
 course_id | section_id | student_id | grade
-----------+------------+------------+-------
       730 |          1 |        148 |     3
       450 |          2 |        210 |     3
       730 |          1 |        210 |     1
       290 |          1 |        298 |     3
       480 |          2 |        298 |     3
       730 |          1 |        348 |     2
       290 |          1 |        349 |     4
       480 |          1 |        410 |     2
       450 |          1 |        473 |     2
       730 |          1 |        473 |     3
       480 |          2 |        473 |     0
       290 |          1 |        548 |     2
       730 |          1 |        558 |     3
       730 |          1 |        649 |     4
       480 |          1 |        649 |     4
       450 |          1 |        654 |     4
       450 |          2 |        548 |
(17 rows)
```

Let's delete all the records in the **enrolls** table.

```console
uniy=# TRUNCATE TABLE enrolls;
TRUNCATE TABLE
uniy=# SELECT * FROM enrolls;
 course_id | section_id | student_id | grade
-----------+------------+------------+-------
(0 rows)
```

Now, let's import the `enrolls_db.csv` file into the **enrolls** table.


```console
(base) ludo /~  $ pwd
/Users/ludovicopinzari
(base) ludo /~  $  cat enrolls_db.csv
course_id,section_id,student_id,grade
730,1,148,3
450,2,210,3
730,1,210,1
290,1,298,3
480,2,298,3
730,1,348,2
290,1,349,4
480,1,410,2
450,1,473,2
730,1,473,3
480,2,473,0
290,1,548,2
730,1,558,3
730,1,649,4
480,1,649,4
450,1,654,4
450,2,548,
```

To import this CSV file into the **enrolls** table, you use COPY statement as follows:

```console
COPY enrolls(course_id, section_id, grade)
FROM '/Users/ludovicopinzari/enrolls_db.csv'
DELIMITER ','
CSV HEADER;
```

Let’s dive into the `COPY` statement in more detail.

1. First, you specify the **table with column names** after the `COPY` keyword. **The order of the columns must be the same as the ones in the** `CSV` file. In case the CSV file contains all columns of the table, you don’t need to specify them explicitly, for example:

```console
COPY enrolls
FROM '/Users/ludovicopinzari/enrolls_db.csv'
DELIMITER ','
CSV HEADER;
```

2. Second, you put the **CSV file path after** the `FROM` keyword. Because CSV file format is used, you need to specify `DELIMITER` as well as `CSV` clauses.

3. Third, specify the `HEADER` keyword to indicate that the CSV file contains a header. When the COPY command imports data, it ignores the header of the file.

Notice that the file must be read directly by the PostgreSQL server, not by the client application. Therefore, it must be accessible by the PostgreSQL server machine. Also, **you need to have** `superuser` **access in order to execute the** `COPY` **statement successfully**.

```console
uniy=# COPY enrolls
uniy-# FROM '/Users/ludovicopinzari/Documents/Udacity/Sql_udacity/enrolls_db.csv'
uniy-# DELIMITER ','
uniy-# CSV HEADER;
COPY 17
```

It means that 17 rows have been copied. Let’s check the **enrolls** table.

```console
uniy=# SELECT * FROM enrolls;
 course_id | section_id | student_id | grade
-----------+------------+------------+-------
       730 |          1 |        148 |     3
       450 |          2 |        210 |     3
       730 |          1 |        210 |     1
       290 |          1 |        298 |     3
       480 |          2 |        298 |     3
       730 |          1 |        348 |     2
       290 |          1 |        349 |     4
       480 |          1 |        410 |     2
       450 |          1 |        473 |     2
       730 |          1 |        473 |     3
       480 |          2 |        473 |     0
       290 |          1 |        548 |     2
       730 |          1 |        558 |     3
       730 |          1 |        649 |     4
       480 |          1 |        649 |     4
       450 |          1 |        654 |     4
       450 |          2 |        548 |
(17 rows)
```

Let's check if the `NULL` value has been included:

```console
uniy=# SELECT *
uniy-#   FROM enrolls
uniy-#  WHERE grade IS NULL;
 course_id | section_id | student_id | grade
-----------+------------+------------+-------
       450 |          2 |        548 |
(1 row)
```

### usertest: Import a CSV file into a table using COPY statement

AS we mentioned earlier, the `COPY FROM` command can only be executed by a `superuser`. However, we can use the `\COPY FROM` command to execute the same command as a *default user*.

```console
(base) ludo /~  $  psql uniy -U usertest
psql (11.4)
Type "help" for help.

uniy=>
```

We logged in as a default user `usertest`.

```console
uniy=> SELECT * FROM enrolls;
 course_id | section_id | student_id | grade
-----------+------------+------------+-------
       730 |          1 |        148 |     3
       450 |          2 |        210 |     3
       730 |          1 |        210 |     1
       290 |          1 |        298 |     3
       480 |          2 |        298 |     3
       730 |          1 |        348 |     2
       290 |          1 |        349 |     4
       480 |          1 |        410 |     2
       450 |          1 |        473 |     2
       730 |          1 |        473 |     3
       480 |          2 |        473 |     0
       290 |          1 |        548 |     2
       730 |          1 |        558 |     3
       730 |          1 |        649 |     4
       480 |          1 |        649 |     4
       450 |          1 |        654 |     4
       450 |          2 |        548 |
(17 rows)
```

Let's delete all the records in the **enrolls** table.

```console
uniy=> TRUNCATE TABLE enrolls;
TRUNCATE TABLE
uniy=> SELECT * FROM enrolls;
 course_id | section_id | student_id | grade
-----------+------------+------------+-------
(0 rows)
```

To import the CSV file, `enrolls_db.csv` into the **enrolls** table, you use COPY statement as follows:

```console
\COPY enrolls(course_id, section_id, grade)
FROM '/Users/ludovicopinzari/enrolls_db.csv'
DELIMITER ','
CSV HEADER;
```

Let's execute the command in the `psql` prompt.

```console
uniy=> \COPY enrolls FROM '/Users/ludovicopinzari/enrolls_db.csv' DELIMITER ',' CSV HEADER;
COPY 17
```

Let's check the `enrolls` table.

```console
uniy=> SELECT * FROM enrolls;
 course_id | section_id | student_id | grade
-----------+------------+------------+-------
       730 |          1 |        148 |     3
       450 |          2 |        210 |     3
       730 |          1 |        210 |     1
       290 |          1 |        298 |     3
       480 |          2 |        298 |     3
       730 |          1 |        348 |     2
       290 |          1 |        349 |     4
       480 |          1 |        410 |     2
       450 |          1 |        473 |     2
       730 |          1 |        473 |     3
       480 |          2 |        473 |     0
       290 |          1 |        548 |     2
       730 |          1 |        558 |     3
       730 |          1 |        649 |     4
       480 |          1 |        649 |     4
       450 |          1 |        654 |     4
       450 |          2 |        548 |
(17 rows)
```

### Partial import of a CSV file into an empty table

In the previous section we illustrate how to import a `csv` file into a table using the `\COPY FROM` command. The command included all the columns of the table. In this lesson we show how to **import only a subset of the columns in the table**. In order to do that we export a subset of columns from the `enrolls` table to a file named `enrolls_partial_db.csv`. The `csv` file includes the **primary keys** columns. Next, we import the `csv` file into the `enrolls` table.

```console
uniy=> \d enrolls
                 Table "public.enrolls"
   Column   |   Type   | Collation | Nullable | Default
------------+----------+-----------+----------+---------
 course_id  | smallint |           | not null |
 section_id | smallint |           | not null |
 student_id | smallint |           | not null |
 grade      | smallint |           |          |
Indexes:
    "enrolls_pkey" PRIMARY KEY, btree (course_id, section_id, student_id)
Foreign-key constraints:
    "enrolls_fkey_course" FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE
    "enrolls_fkey_section" FOREIGN KEY (course_id, section_id) REFERENCES sections(course_id, section_id) ON DELETE CASCADE
    "enrolls_fkey_student" FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE
```

We see that the columns `course_id`,`section_id` and `student_id` form the **primary key** of the enrolls table. The structure of the table indicates that the PRIMARY KEY is not automatically generated and therefore we need to import the raw values of the PRIMARY KEY into the table. We'll show another example later that doesn't need to import the PRIMARY KEY from a CSV file.

```console
uniy=> \COPY enrolls(course_id, section_id, student_id) TO '/Users/ludovicopinzari/enrolls_partial_db.csv' DELIMITER ',' CSV HEADER;
COPY 17
```

Let's read the `enrolls_partial_db.csv` from the command line.

```console
(base) ludo /~  $  cat enrolls_partial_db.csv
course_id,section_id,student_id
730,1,148
450,2,210
730,1,210
290,1,298
480,2,298
730,1,348
290,1,349
480,1,410
450,1,473
730,1,473
480,2,473
290,1,548
730,1,558
730,1,649
480,1,649
450,1,654
450,2,548
```

Now, we delete all records in the `enrolls` table.

```console
uniy=> TRUNCATE TABLE enrolls;
TRUNCATE TABLE
uniy=> SELECT * FROM enrolls;
 course_id | section_id | student_id | grade
-----------+------------+------------+-------
(0 rows)
```

Now, the `enrolls` table doesn't have records and it's `empty`. Let's import the `enrolls_partial_db.csv` file into the `enrolls` table.

```console
uniy=> \COPY enrolls(course_id, section_id, student_id) FROM '/Users/ludovicopinzari/Documents/Udacity/Sql_udacity/enrolls_partial_db.csv' DELIMITER ',' CSV HEADER;
COPY 17
uniy=> SELECT * FROM enrolls;
 course_id | section_id | student_id | grade
-----------+------------+------------+-------
       730 |          1 |        148 |
       450 |          2 |        210 |
       730 |          1 |        210 |
       290 |          1 |        298 |
       480 |          2 |        298 |
       730 |          1 |        348 |
       290 |          1 |        349 |
       480 |          1 |        410 |
       450 |          1 |        473 |
       730 |          1 |        473 |
       480 |          2 |        473 |
       290 |          1 |        548 |
       730 |          1 |        558 |
       730 |          1 |        649 |
       480 |          1 |        649 |
       450 |          1 |        654 |
       450 |          2 |        548 |
(17 rows)
```

The output shows that the DBMS imported the PRIMARY KEY's column values into the `enrolls` table and set the remaining column values to the DEFAULT values. In this case the `grade` column DEFAULT value is `NULL`.

### Import of a CSV file into a no-empty table

In the previous section we imported a `csv` file into an empty table, a table with no records. In this lesson we import new records in a populated table. In order to do that we delete all records in the `enrolls` table and insert brand new records in the empty table. Next, we import the backup `enrolls_db.csv` file into the `enrolls` table.

Let's delete all records in the `enrolls` table.

```console
uniy=> TRUNCATE TABLE enrolls;
TRUNCATE TABLE
```

Let's insert new records in the `enrolls` table. In order to do that we must be sure that all the records satisfy the table constraints and do not have duplicates in the `enrolls_db.csv` file. You can check lesson [11](../00_basic_intro/11_uniY_db.md) to analyse the uniy sample database. I can tell you right now that student_id `354` is not enrolled in any course so it does not appear in any record of the `enrolls_db.csv` file. Therefore, we can insert `354` to the enrolls table without issues.

```console
uniy=> INSERT INTO enrolls
uniy->        (course_id, section_id, student_id, grade)
uniy-> VALUES
uniy->        (450, 1, 354, 4),
uniy->        (730, 1, 354, 4),
uniy->        (480, 2, 354, 4)
uniy-> RETURNING *;
 course_id | section_id | student_id | grade
-----------+------------+------------+-------
       450 |          1 |        354 |     4
       730 |          1 |        354 |     4
       480 |          2 |        354 |     4
(3 rows)

INSERT 0 3
```

The `INSERT INTO` statement inserted three new records in the `enrolls` table successfully. Now, let's import the `enrolls_db.csv` file into the `enrolls` table.

```console
uniy=> \COPY enrolls FROM '/Users/ludovicopinzari/Documents/Udacity/Sql_udacity/enrolls_db.csv' DELIMITER ',' CSV HEADER;
COPY 17
```

The `\COPY FROM` command inserted 17 records in the `enrolls` table. Let's check the `enrolls` table records.

```console
uniy=> SELECT * FROM enrolls;
 course_id | section_id | student_id | grade
-----------+------------+------------+-------
       450 |          1 |        354 |     4
       730 |          1 |        354 |     4
       480 |          2 |        354 |     4
       730 |          1 |        148 |     3
       450 |          2 |        210 |     3
       730 |          1 |        210 |     1
       290 |          1 |        298 |     3
       480 |          2 |        298 |     3
       730 |          1 |        348 |     2
       290 |          1 |        349 |     4
       480 |          1 |        410 |     2
       450 |          1 |        473 |     2
       730 |          1 |        473 |     3
       480 |          2 |        473 |     0
       290 |          1 |        548 |     2
       730 |          1 |        558 |     3
       730 |          1 |        649 |     4
       480 |          1 |        649 |     4
       450 |          1 |        654 |     4
       450 |          2 |        548 |
(20 rows)
```

The output shows that the imported records have been `appended` to the exisitng records of the `enrolls` table.
