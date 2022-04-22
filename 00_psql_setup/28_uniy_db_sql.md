# UniY database - sql script

In the previoius lesson [27](./28_uniy_db_sql.md), we illustrated how to populate the tables in the uniy sample database. In this lesson we complete the implementation of the **uniy-db.sql** file.

## uniy-db.sql

```console
/*
-----------------------------------
   database: uniy
   dbms: postgres (PostgreSQL) 11.4
   author: Ludovico Pinzari
-----------------------------------
*/

-- START A TRANSACTION
BEGIN;

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

-- ********************************
-- POPULATE the uniy database tables
-- ********************************

/*
------------------------------------
Level 0: students, courses, teachers
------------------------------------
*/

--
-- Table students
--

INSERT INTO students
       (student_id, student_name, address, city, state, zip, gender)
VALUES
       (148, 'Susan Powell'    , '534 East River Dr.'  , 'Haverford', 'PA', '19041','F'),
       (210, 'Bob Dawson'      , '120 South Jefferson' , 'Newport'  , 'RI', '02891','M'),
       (298, 'Howard Mansfield', '290 Wynkoop Drive'   , 'Vienna'   , 'VA', '22180','M'),
       (348, 'Susan Pugh'      , '534 East Hampton Dr.', 'Hartford' , 'CT', '06107','F'),
       (349, 'Joe Adams'       , '473 Emmerson Street' , 'Newark'   , 'DE', '19702','M'),
       (354, 'Janet Ladd'      , '441 10th Street'     , 'Pennsburg', 'PA', '18073','F'),
       (410, 'Bill Jones'      , '120 South Harrison'  , 'Newport'  , 'CA', '92660','M'),
       (473, 'Carol Dean'      , '983 Park Avenue'     , 'Boston'   , 'MA', '02169','F'),
       (548, 'Allen Thomas'    , '238 West Ox Road'    , 'Chicago'  , 'IL', '60624','M'),
       (558, 'Val Shipp'       , '238 Westport Road'   , 'Chicago'  , 'IL', '60556','F'),
       (649, 'John Anderson'   , '473 Emmory Street'   , 'New York' , 'NY', '10008','M'),
       (654, 'Janet Thomas'    , '441 6th Street'      , 'Erie'     , 'PA', '16510','F');


--
-- Table courses
--

INSERT INTO courses
       (course_id, course_name, department, num_credits)
VALUES
       (450, 'Western Civilization', 'History'         , 3),
       (730, 'Calculus IV'         , 'Math'            , 4),
       (290, 'English Composition' , 'English'         , 3),
       (480, 'Compiler Writing'    , 'Computer Science', 3),
       (550, 'Art History'         , 'History'         , 3);

--
-- Table teachers
--

INSERT INTO teachers
       (teacher_id, teacher_name, phone, salary)
VALUES
       (303, 'Dr. Horn'  ,'257-3049', 27540.00),
       (290, 'Dr. Lowe'  ,'257-2390', 31450.00),
       (430, 'Dr. Engle' ,'256-4621', 38200.00),
       (180, 'Dr. Cooke' ,'257-8088', 29560.00),
       (560, 'Dr. Olsen' ,'257-8086', 31778.00),
       (784, 'Dr. Scango','257-3046', 32098.00),
       (213, 'Dr. Wright','257-3393', 35000.00);

/*
------------------------------------
Level 1: sections
------------------------------------
*/

--
-- Table sections
--

INSERT INTO sections
       (course_id, section_id, teacher_id, num_students)
VALUES
       (450, 1, 303, 2),
       (730, 1, 290, 6),
       (290, 1, 430, 3),
       (480, 1, 180, 3),
       (450, 2, 560, 2),
       (480, 2, 784, 2);

/*
------------------------------------
Level 2: enrolls
------------------------------------
*/

INSERT INTO enrolls
       (course_id, section_id, student_id, grade)
VALUES
       (730, 1, 148, 3),
       (450, 2, 210, 3),
       (730, 1, 210, 1),
       (290, 1, 298, 3),
       (480, 2, 298, 3),
       (730, 1, 348, 2),
       (290, 1, 349, 4),
       (480, 1, 410, 2),
       (450, 1, 473, 2),
       (730, 1, 473, 3),
       (480, 2, 473, 0),
       (290, 1, 548, 2),
       (730, 1, 558, 3),
       (730, 1, 649, 4),
       (480, 1, 649, 4),
       (450, 1, 654, 4),
       (450, 2, 548, DEFAULT);


-- COMMIT A TRANSACTION
COMMIT;
```
