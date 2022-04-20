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
