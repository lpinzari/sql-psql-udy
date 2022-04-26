# Restore uniy sample database schema and data

In the previous lesson we use the `pg_dump` command to backup the schema and data of the `uniy` sample database. In this lesson, we'll restore the schema and data of the `uniy` sample database in two steps.

## Restore uniy schema

```console
(base) ludo /~  $  ls pgbackup/uniy_db_backup.sql
pgbackup/uniy_db_backup.sql
```
1. **login in the uniy database**


```console
(base) ludo /~  $  psql uniy -U usertest
psql (11.4)
Type "help" for help.

uniy=>
```

2. **Execute psql commands from external file**

```console
uniy=> \ir ./pgbackup/uniy_db_schema_backup.sql
BEGIN
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
DROP TABLE
DROP TABLE
DROP TABLE
DROP TABLE
DROP TABLE
SET
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
COMMIT
```

3. **List the tables**

```console
uniy=> \dt
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

4. **Describe tables**

**students**

```console
uniy=> \d students
                    Table "public.students"
    Column    |     Type      | Collation | Nullable | Default
--------------+---------------+-----------+----------+---------
 student_id   | smallint      |           | not null |
 student_name | character(18) |           |          |
 address      | character(20) |           |          |
 city         | character(10) |           |          |
 state        | character(2)  |           |          |
 zip          | character(5)  |           |          |
 gender       | character(1)  |           |          |
Indexes:
    "students_pkey" PRIMARY KEY, btree (student_id)
Referenced by:
    TABLE "enrolls" CONSTRAINT "enrolls_fkey_student" FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE
```

**courses**
```console
uniy=> \d courses
                    Table "public.courses"
   Column    |     Type      | Collation | Nullable | Default
-------------+---------------+-----------+----------+---------
 course_id   | smallint      |           | not null |
 course_name | character(20) |           |          |
 department  | character(16) |           |          |
 num_credits | smallint      |           |          |
Indexes:
    "courses_pkey" PRIMARY KEY, btree (course_id)
Referenced by:
    TABLE "enrolls" CONSTRAINT "enrolls_fkey_course" FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE
    TABLE "sections" CONSTRAINT "sections_fkey_course" FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE
```

**teachers**

```console
uniy=> \d teachers
                    Table "public.teachers"
    Column    |     Type      | Collation | Nullable | Default
--------------+---------------+-----------+----------+---------
 teacher_id   | smallint      |           | not null |
 teacher_name | character(18) |           |          |
 phone        | character(10) |           |          |
 salary       | numeric(10,2) |           |          |
Indexes:
    "teachers_pkey" PRIMARY KEY, btree (teacher_id)
Referenced by:
    TABLE "sections" CONSTRAINT "sections_fkey_teacher" FOREIGN KEY (teacher_id) REFERENCES teachers(teacher_id) ON DELETE SET NULL
```

**sections**

```console
uniy=> \d sections
                 Table "public.sections"
    Column    |   Type   | Collation | Nullable | Default
--------------+----------+-----------+----------+---------
 course_id    | smallint |           | not null |
 section_id   | smallint |           | not null |
 teacher_id   | smallint |           |          |
 num_students | smallint |           |          |
Indexes:
    "sections_pkey" PRIMARY KEY, btree (course_id, section_id)
Foreign-key constraints:
    "sections_fkey_course" FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE
    "sections_fkey_teacher" FOREIGN KEY (teacher_id) REFERENCES teachers(teacher_id) ON DELETE SET NULL
Referenced by:
    TABLE "enrolls" CONSTRAINT "enrolls_fkey_section" FOREIGN KEY (course_id, section_id) REFERENCES sections(course_id, section_id) ON DELETE CASCADE
```

**enrolls**

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

## Restore uniy data

1. **Execute psql commands from external file**

```console
uniy=> \ir ./pgbackup/uniy_db_data_backup.sql
BEGIN
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
COMMIT
```

2. **Describe tables records**

**students**

```console
uniy=> SELECT * FROM students;
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

**courses**

```console
uniy=> SELECT * FROM courses;
 course_id |     course_name      |    department    | num_credits
-----------+----------------------+------------------+-------------
       450 | Western Civilization | History          |           3
       730 | Calculus IV          | Math             |           4
       290 | English Composition  | English          |           3
       480 | Compiler Writing     | Computer Science |           3
       550 | Art History          | History          |           3
(5 rows)
```

**teachers**

```console
uniy=> SELECT * FROM teachers;
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

**sections**

```console
uniy=> SELECT * FROM sections;
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

**enrolls**

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
