--
-- PostgreSQL database dump
--

BEGIN;
-- Dumped by pg_dump version 11.4


ALTER TABLE IF EXISTS sections DROP CONSTRAINT IF EXISTS sections_fkey_teacher;
ALTER TABLE IF EXISTS sections DROP CONSTRAINT IF EXISTS sections_fkey_course;
ALTER TABLE IF EXISTS enrolls DROP CONSTRAINT IF EXISTS enrolls_fkey_student;
ALTER TABLE IF EXISTS enrolls DROP CONSTRAINT IF EXISTS enrolls_fkey_section;
ALTER TABLE IF EXISTS enrolls DROP CONSTRAINT IF EXISTS enrolls_fkey_course;
ALTER TABLE IF EXISTS teachers DROP CONSTRAINT IF EXISTS teachers_pkey;
ALTER TABLE IF EXISTS students DROP CONSTRAINT IF EXISTS students_pkey;
ALTER TABLE IF EXISTS sections DROP CONSTRAINT IF EXISTS sections_pkey;
ALTER TABLE IF EXISTS enrolls DROP CONSTRAINT IF EXISTS enrolls_pkey;
ALTER TABLE IF EXISTS courses DROP CONSTRAINT IF EXISTS courses_pkey;
DROP TABLE IF EXISTS teachers;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS sections;
DROP TABLE IF EXISTS enrolls;
DROP TABLE IF EXISTS courses;
SET default_with_oids = false;

--
-- Name: courses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE courses (
    course_id smallint NOT NULL,
    course_name character(20),
    department character(16),
    num_credits smallint
);


--
-- Name: enrolls; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE enrolls (
    course_id smallint NOT NULL,
    section_id smallint NOT NULL,
    student_id smallint NOT NULL,
    grade smallint
);


--
-- Name: sections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE sections (
    course_id smallint NOT NULL,
    section_id smallint NOT NULL,
    teacher_id smallint,
    num_students smallint
);


--
-- Name: students; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE students (
    student_id smallint NOT NULL,
    student_name character(18),
    address character(20),
    city character(10),
    state character(2),
    zip character(5),
    gender character(1)
);


--
-- Name: teachers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE teachers (
    teacher_id smallint NOT NULL,
    teacher_name character(18),
    phone character(10),
    salary numeric(10,2)
);


--
-- Name: courses courses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE courses
    ADD CONSTRAINT courses_pkey PRIMARY KEY (course_id);


--
-- Name: enrolls enrolls_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE enrolls
    ADD CONSTRAINT enrolls_pkey PRIMARY KEY (course_id, section_id, student_id);


--
-- Name: sections sections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE sections
    ADD CONSTRAINT sections_pkey PRIMARY KEY (course_id, section_id);


--
-- Name: students students_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE students
    ADD CONSTRAINT students_pkey PRIMARY KEY (student_id);


--
-- Name: teachers teachers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE teachers
    ADD CONSTRAINT teachers_pkey PRIMARY KEY (teacher_id);


--
-- Name: enrolls enrolls_fkey_course; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE enrolls
    ADD CONSTRAINT enrolls_fkey_course FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE;


--
-- Name: enrolls enrolls_fkey_section; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE enrolls
    ADD CONSTRAINT enrolls_fkey_section FOREIGN KEY (course_id, section_id) REFERENCES sections(course_id, section_id) ON DELETE CASCADE;


--
-- Name: enrolls enrolls_fkey_student; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE enrolls
    ADD CONSTRAINT enrolls_fkey_student FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE;


--
-- Name: sections sections_fkey_course; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE sections
    ADD CONSTRAINT sections_fkey_course FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE;


--
-- Name: sections sections_fkey_teacher; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE sections
    ADD CONSTRAINT sections_fkey_teacher FOREIGN KEY (teacher_id) REFERENCES teachers(teacher_id) ON DELETE SET NULL;


--
COMMIT;
--

