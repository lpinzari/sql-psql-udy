--
-- PostgreSQL database dump
--

BEGIN;
-- Dumped by pg_dump version 11.4


--
-- Data for Name: courses; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO courses (course_id, course_name, department, num_credits) VALUES (450, 'Western Civilization', 'History         ', 3);
INSERT INTO courses (course_id, course_name, department, num_credits) VALUES (730, 'Calculus IV         ', 'Math            ', 4);
INSERT INTO courses (course_id, course_name, department, num_credits) VALUES (290, 'English Composition ', 'English         ', 3);
INSERT INTO courses (course_id, course_name, department, num_credits) VALUES (480, 'Compiler Writing    ', 'Computer Science', 3);
INSERT INTO courses (course_id, course_name, department, num_credits) VALUES (550, 'Art History         ', 'History         ', 3);


--
-- Data for Name: teachers; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO teachers (teacher_id, teacher_name, phone, salary) VALUES (303, 'Dr. Horn          ', '257-3049  ', 27540.00);
INSERT INTO teachers (teacher_id, teacher_name, phone, salary) VALUES (290, 'Dr. Lowe          ', '257-2390  ', 31450.00);
INSERT INTO teachers (teacher_id, teacher_name, phone, salary) VALUES (430, 'Dr. Engle         ', '256-4621  ', 38200.00);
INSERT INTO teachers (teacher_id, teacher_name, phone, salary) VALUES (180, 'Dr. Cooke         ', '257-8088  ', 29560.00);
INSERT INTO teachers (teacher_id, teacher_name, phone, salary) VALUES (560, 'Dr. Olsen         ', '257-8086  ', 31778.00);
INSERT INTO teachers (teacher_id, teacher_name, phone, salary) VALUES (784, 'Dr. Scango        ', '257-3046  ', 32098.00);
INSERT INTO teachers (teacher_id, teacher_name, phone, salary) VALUES (213, 'Dr. Wright        ', '257-3393  ', 35000.00);


--
-- Data for Name: sections; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO sections (course_id, section_id, teacher_id, num_students) VALUES (450, 1, 303, 2);
INSERT INTO sections (course_id, section_id, teacher_id, num_students) VALUES (730, 1, 290, 6);
INSERT INTO sections (course_id, section_id, teacher_id, num_students) VALUES (290, 1, 430, 3);
INSERT INTO sections (course_id, section_id, teacher_id, num_students) VALUES (480, 1, 180, 3);
INSERT INTO sections (course_id, section_id, teacher_id, num_students) VALUES (450, 2, 560, 2);
INSERT INTO sections (course_id, section_id, teacher_id, num_students) VALUES (480, 2, 784, 2);


--
-- Data for Name: students; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO students (student_id, student_name, address, city, state, zip, gender) VALUES (148, 'Susan Powell      ', '534 East River Dr.  ', 'Haverford ', 'PA', '19041', 'F');
INSERT INTO students (student_id, student_name, address, city, state, zip, gender) VALUES (210, 'Bob Dawson        ', '120 South Jefferson ', 'Newport   ', 'RI', '02891', 'M');
INSERT INTO students (student_id, student_name, address, city, state, zip, gender) VALUES (298, 'Howard Mansfield  ', '290 Wynkoop Drive   ', 'Vienna    ', 'VA', '22180', 'M');
INSERT INTO students (student_id, student_name, address, city, state, zip, gender) VALUES (348, 'Susan Pugh        ', '534 East Hampton Dr.', 'Hartford  ', 'CT', '06107', 'F');
INSERT INTO students (student_id, student_name, address, city, state, zip, gender) VALUES (349, 'Joe Adams         ', '473 Emmerson Street ', 'Newark    ', 'DE', '19702', 'M');
INSERT INTO students (student_id, student_name, address, city, state, zip, gender) VALUES (354, 'Janet Ladd        ', '441 10th Street     ', 'Pennsburg ', 'PA', '18073', 'F');
INSERT INTO students (student_id, student_name, address, city, state, zip, gender) VALUES (410, 'Bill Jones        ', '120 South Harrison  ', 'Newport   ', 'CA', '92660', 'M');
INSERT INTO students (student_id, student_name, address, city, state, zip, gender) VALUES (473, 'Carol Dean        ', '983 Park Avenue     ', 'Boston    ', 'MA', '02169', 'F');
INSERT INTO students (student_id, student_name, address, city, state, zip, gender) VALUES (548, 'Allen Thomas      ', '238 West Ox Road    ', 'Chicago   ', 'IL', '60624', 'M');
INSERT INTO students (student_id, student_name, address, city, state, zip, gender) VALUES (558, 'Val Shipp         ', '238 Westport Road   ', 'Chicago   ', 'IL', '60556', 'F');
INSERT INTO students (student_id, student_name, address, city, state, zip, gender) VALUES (649, 'John Anderson     ', '473 Emmory Street   ', 'New York  ', 'NY', '10008', 'M');
INSERT INTO students (student_id, student_name, address, city, state, zip, gender) VALUES (654, 'Janet Thomas      ', '441 6th Street      ', 'Erie      ', 'PA', '16510', 'F');


--
-- Data for Name: enrolls; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO enrolls (course_id, section_id, student_id, grade) VALUES (730, 1, 148, 3);
INSERT INTO enrolls (course_id, section_id, student_id, grade) VALUES (450, 2, 210, 3);
INSERT INTO enrolls (course_id, section_id, student_id, grade) VALUES (730, 1, 210, 1);
INSERT INTO enrolls (course_id, section_id, student_id, grade) VALUES (290, 1, 298, 3);
INSERT INTO enrolls (course_id, section_id, student_id, grade) VALUES (480, 2, 298, 3);
INSERT INTO enrolls (course_id, section_id, student_id, grade) VALUES (730, 1, 348, 2);
INSERT INTO enrolls (course_id, section_id, student_id, grade) VALUES (290, 1, 349, 4);
INSERT INTO enrolls (course_id, section_id, student_id, grade) VALUES (480, 1, 410, 2);
INSERT INTO enrolls (course_id, section_id, student_id, grade) VALUES (450, 1, 473, 2);
INSERT INTO enrolls (course_id, section_id, student_id, grade) VALUES (730, 1, 473, 3);
INSERT INTO enrolls (course_id, section_id, student_id, grade) VALUES (480, 2, 473, 0);
INSERT INTO enrolls (course_id, section_id, student_id, grade) VALUES (290, 1, 548, 2);
INSERT INTO enrolls (course_id, section_id, student_id, grade) VALUES (730, 1, 558, 3);
INSERT INTO enrolls (course_id, section_id, student_id, grade) VALUES (730, 1, 649, 4);
INSERT INTO enrolls (course_id, section_id, student_id, grade) VALUES (480, 1, 649, 4);
INSERT INTO enrolls (course_id, section_id, student_id, grade) VALUES (450, 1, 654, 4);
INSERT INTO enrolls (course_id, section_id, student_id, grade) VALUES (450, 2, 548, NULL);


--
COMMIT;
--

