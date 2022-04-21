# Destroy and Create uniY Schema in sql script

In lessons [11](./11_create_uniy_tables.md) and [24](./24_drop_uniy_tables.md), we introduced the `CREATE TABLE` and `DROP TABLE` statements to create and destroy the tables in the uniY sample database.

In this lesson we'll implement those operations in a simple script named `uniy_db.sql`.

## uniY sample database script

In the previous lessons we executed the sql statements directly in the `psql` prompt. In this lesson, we'll execute the same commands by external file `uniy-db.sql`. Note that the extension `.sql` serves only to indicate the text file includes SQL statements, the file could be named `uniy-db.txt` or whatever. However, when editing your file in the text ediotor is better to have the right extension in order to highlight the keywords of the SQL language. 

In the `uniy-db.sql` file a **single line comment** in PostgreSql is indicated with the symbol `--`.

```console
-- This is a single line comment
```

A multi line comment in PostgrSql starts with `/*` and ends with `*/` symbols.

```console
/*
This is
a multi
line
comment
*/
```

### uniy_db.sql

```console
/*
-----------------------------------
   database: uniy
   dbms: postgres (PostgreSQL) 11.4
   author: Ludovico Pinzari
-----------------------------------
*/

-- ********************************
-- DESTROY the uniy database schema
-- ********************************

DROP TABLE IF EXISTS
           students,
           courses,
           teachers,
           sections,
           enrolls
CASCADE;

-- ********************************
-- CREATE the uniy database schema
-- ********************************


/*
------------------------------------
Level 0: students, courses, teachers
------------------------------------
*/


--
-- Table structure for students
--

CREATE TABLE students (
  student_id SMALLINT PRIMARY KEY,
  student_name CHAR (18),
  address CHAR (20),
  city CHAR (10),
  state CHAR (2),
  zip CHAR (5),
  gender CHAR (1)
);

--
-- Table structure for courses
--

CREATE TABLE courses (
  course_id SMALLINT PRIMARY KEY,
  course_name CHAR (20),
  department CHAR (16),
  num_credits SMALLINT
);

--
-- Table structure for teachers
--

CREATE TABLE teachers (
  teacher_id SMALLINT PRIMARY KEY,
  teacher_name CHAR (18),
  phone CHAR (10),
  salary NUMERIC (10,2)
);

/*
------------------------------------
Level 1: sections
------------------------------------
*/

--
-- Table structure for sections
--

CREATE TABLE sections (
  course_id SMALLINT,
  section_id SMALLINT,
  teacher_id SMALLINT,
  num_students SMALLINT,
  PRIMARY KEY (course_id, section_id),
  CONSTRAINT sections_fkey_course
     FOREIGN KEY (course_id)
     REFERENCES courses (course_id)
     ON DELETE CASCADE,
  CONSTRAINT sections_fkey_teacher
     FOREIGN KEY (teacher_id)
     REFERENCES teachers (teacher_id)
     ON DELETE SET NULL
);

/*
------------------------------------
Level 2: enrolls
------------------------------------
*/

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

## Execute the uniy-db.sql

Let's execute the `uniy-db.sql` script.

1. **List files of your current working directory**

```console
(base) ludo /~  $  ls uniy-db.sql
uniy-db.sql
```

2. **login in the uniy database**

```console
(base) ludo /~  $  psql uniy -U usertest
psql (11.4)
Type "help" for help.
```

3. **Execute psql commands from external file**

```console
uniy=> \i uniy-db.sql
psql:uniy-db.sql:19: NOTICE:  table "students" does not exist, skipping
psql:uniy-db.sql:19: NOTICE:  table "courses" does not exist, skipping
psql:uniy-db.sql:19: NOTICE:  table "teachers" does not exist, skipping
psql:uniy-db.sql:19: NOTICE:  table "sections" does not exist, skipping
psql:uniy-db.sql:19: NOTICE:  table "enrolls" does not exist, skipping
DROP TABLE
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE TABLE
```
Since we destroyed all the tables in the `uniy` database in the previous lesson, the `DROP TABLE` statement is *skipped*.
Let's list all the tables in the `uniy` sample database.

```console
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
