# uniy backup: Exporting & Importing tables as csv files

In the previous lesson we finalized the implementation of the **uniy-db.sql** file and executed the script to reinitalized the database.

Now, suppose that we added, deleted or updated records in the `uniy` sample database and want to save the current state of the database.

Clearly, it would be insane to edit the `uniy-db.sql` file to reflect the records stored in the database tables. A possible solution is to export all the tables in separate `csv` files.

## Export PostgreSQL Table to CSV file

We will use the `uniy` sample database created in the previous lesson.

### Export data from a table to CSV using COPY TO statement

The easiest way to export data of a table to a `CSV` file is to use [COPY TO](https://www.postgresql.org/docs/14/sql-copy.html) statement.

The general form is:

- **COPY** `table_name` **TO** `path` **DELIMITER** `character` **CSV** **HEADER**;


For example, if you want to export the data of the students table to a CSV file named `students_db.csv` in the `/Users/yourusername/` folder, you can use the following statement:

- **COPY** `students` **TO** `'/Users/yourusername/students_db.csv'` **DELIMITER** `','` **CSV** **HEADER**;

The **DELIMITER** parameter specifies the character that separates columns within each row (line) of the file. The default is a tab character in text format, a comma (`,`) in **CSV** format. This must be a single one-byte character. Therefore, the values in each record are separated by the **DELIMITER** character `,`.

The **HEADER** specifies that the file contains a header line with the names of each column in the file. On output, the first line contains the column names from the table, and on input, the first line is ignored. This option is allowed only when using CSV format.

You must have select privilege on the table whose values are read by `COPY TO`. We login as a superuser to export the query on our local machine.

```console
(base) ludo /~  $  
```
We'll use the absolute path `'/Users/ludovicopinzari/'` to export the tables of the uniy sample database. Note that relative paths are not allowed by the `COPY` command.

```console
(base) ludo /Sql_udacity  $  psql uniy
psql (11.4)
Type "help" for help.

uniy=#
```

We logged as `superuser` with all pivileges. (see: `=#`).

```console
uniy=# \dt
          List of relations
 Schema |   Name   | Type  |  Owner
--------+----------+-------+----------
 public | courses  | table | usertest
 public | enrolls  | table | usertest
 public | sections | table | usertest
 public | students | table | usertest
 public | teachers | table | usertest
(5 rows)
```

**students** table:

```console
uniy=# SELECT * FROM students;
 student_id |    student_name    |       address        |    city    | state |  zip  | gender
------------+--------------------+----------------------+------------+-------+-------+--------
        148 | Susan Powell       | 534 East River Dr.   | Haverford  | PA    | 19041 | F
        210 | Bob Dawson         | 120 South Jefferson  | Newport    | RI    | 02891 | M
        298 | Howard Mansfield   | 290 Wynkoop Drive    | Vienna     | VA    | 22180 | M
        348 | Susan Pugh         | 534 East Hampton Dr. | Hartford   | CT    | 06107 | F
        349 | Joe Adams          | 473 Emmerson Street  | Newark     | DE    | 19702 | M
        354 | Janet Ladd         | 441 10th Street      | Pennsburg  | PA    | 18073 | F
        410 | Bill Jones         | 120 South Harrison   | Newport    | CA    | 92660 | M
        473 | Carol Dean         | 983 Park Avenue      | Boston     | MA    | 02169 | F
        548 | Allen Thomas       | 238 West Ox Road     | Chicago    | IL    | 60624 | M
        558 | Val Shipp          | 238 Westport Road    | Chicago    | IL    | 60556 | F
        649 | John Anderson      | 473 Emmory Street    | New York   | NY    | 10008 | M
        654 | Janet Thomas       | 441 6th Street       | Erie       | PA    | 16510 | F
(12 rows)
```

Let's export the `students` table.

```console
uniy=# COPY students TO '/Users/ludovicopinzari/students_db.csv' DELIMITER ',' CSV HEADER;
COPY 12
```

The output of the command shows that the `students_db.csv` file contains 12 rows. Let's check the content of the `students_db.csv` file.

```console
(base) ludo /~  $  cat students_db.csv
student_id,student_name,address,city,state,zip,gender
148,Susan Powell      ,534 East River Dr.  ,Haverford ,PA,19041,F
210,Bob Dawson        ,120 South Jefferson ,Newport   ,RI,02891,M
298,Howard Mansfield  ,290 Wynkoop Drive   ,Vienna    ,VA,22180,M
348,Susan Pugh        ,534 East Hampton Dr.,Hartford  ,CT,06107,F
349,Joe Adams         ,473 Emmerson Street ,Newark    ,DE,19702,M
354,Janet Ladd        ,441 10th Street     ,Pennsburg ,PA,18073,F
410,Bill Jones        ,120 South Harrison  ,Newport   ,CA,92660,M
473,Carol Dean        ,983 Park Avenue     ,Boston    ,MA,02169,F
548,Allen Thomas      ,238 West Ox Road    ,Chicago   ,IL,60624,M
558,Val Shipp         ,238 Westport Road   ,Chicago   ,IL,60556,F
649,John Anderson     ,473 Emmory Street   ,New York  ,NY,10008,M
654,Janet Thomas      ,441 6th Street      ,Erie      ,PA,16510,F
```

We see that the first line of the file contains the name of the columns in the **students** table separated by the `,` symbol. The remaining 12 lines contain the information of the 12 records in the **students** table.

**courses** table

```console
uniy=# SELECT * FROM courses;
 course_id |     course_name      |    department    | num_credits
-----------+----------------------+------------------+-------------
       450 | Western Civilization | History          |           3
       730 | Calculus IV          | Math             |           4
       290 | English Composition  | English          |           3
       480 | Compiler Writing     | Computer Science |           3
       550 | Art History          | History          |           3
(5 rows)
```

Let's export the `courses` table.

```console
uniy=# COPY courses TO '/Users/ludovicopinzari/courses_db.csv' DELIMITER ',' CSV HEADER;
COPY 5
```
The output of the command shows that the `courses_db.csv` file contains 5 rows. Let's check the content of the `students_db.csv` file.

```console
(base) ludo /~  $  cat courses_db.csv
course_id,course_name,department,num_credits
450,Western Civilization,History         ,3
730,Calculus IV         ,Math            ,4
290,English Composition ,English         ,3
480,Compiler Writing    ,Computer Science,3
550,Art History         ,History         ,3
```

**teachers** table

```console
uniy=# SELECT * FROM teachers;
 teacher_id |    teacher_name    |   phone    |  salary
------------+--------------------+------------+----------
        303 | Dr. Horn           | 257-3049   | 27540.00
        290 | Dr. Lowe           | 257-2390   | 31450.00
        430 | Dr. Engle          | 256-4621   | 38200.00
        180 | Dr. Cooke          | 257-8088   | 29560.00
        560 | Dr. Olsen          | 257-8086   | 31778.00
        784 | Dr. Scango         | 257-3046   | 32098.00
        213 | Dr. Wright         | 257-3393   | 35000.00
(7 rows)
```

Let's export the `teachers` table.

```console
uniy=# COPY teachers TO '/Users/ludovicopinzari/teachers_db.csv' DELIMITER ',' CSV HEADER;
COPY 7
```

The output of the command shows that the `teachers_db.csv` file contains 7 rows. Let's check the content of the `teachers_db.csv` file.


```console
(base) ludo /~  $  cat teachers_db.csv
teacher_id,teacher_name,phone,salary
303,Dr. Horn          ,257-3049  ,27540.00
290,Dr. Lowe          ,257-2390  ,31450.00
430,Dr. Engle         ,256-4621  ,38200.00
180,Dr. Cooke         ,257-8088  ,29560.00
560,Dr. Olsen         ,257-8086  ,31778.00
784,Dr. Scango        ,257-3046  ,32098.00
213,Dr. Wright        ,257-3393  ,35000.00
```

**sections** table

```console
uniy=# SELECT * FROM sections;
 course_id | section_id | teacher_id | num_students
-----------+------------+------------+--------------
       450 |          1 |        303 |            2
       730 |          1 |        290 |            6
       290 |          1 |        430 |            3
       480 |          1 |        180 |            3
       450 |          2 |        560 |            2
       480 |          2 |        784 |            2
(6 rows)
```

Let's export the `sections` table.

```console
uniy=# COPY sections TO '/Users/ludovicopinzari/sections_db.csv' DELIMITER ',' CSV HEADER;
COPY 6
```

The output of the command shows that the `sections_db.csv` file contains 6 rows. Let's check the content of the `sections_db.csv` file.

```console
(base) ludo /~  $  cat sections_db.csv
course_id,section_id,teacher_id,num_students
450,1,303,2
730,1,290,6
290,1,430,3
480,1,180,3
450,2,560,2
480,2,784,2
```

**enrolls** table.

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
Let's export the `enrolls` table.

```console
uniy=# COPY enrolls TO '/Users/ludovicopinzari/enrolls_db.csv' DELIMITER ',' CSV HEADER;
COPY 17
```

The output of the command shows that the `enrolls_db.csv` file contains 17 rows. Let's check the content of the `enrolls_db.csv` file.


```console
(base) ludo /Sql_udacity  $  cat enrolls_db.csv
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
