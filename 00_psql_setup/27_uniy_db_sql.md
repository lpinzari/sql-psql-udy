# UniY - uniy-db.sql: DESTROY, CREATE and Populate Database

In the previous lesson we introduced the concept of `TRANSACTION` to organise a set of operations into a **single unit of work** and **keeping the integrity of data** by **concurrent sessions**.

In this lesson we complete the implementation of the `uniy-db.sql` file including the `INSERT INTO` statement to populate the tables in the database.

## uniy-db.sql

In chapter [25](./25_uniy_db_sql.md) we imoplemented the `DESTROY` and `CREATE` tasks to delete and create all the tables in the `uniy` sample database. Now, it's time to populate those tables and organise all these statements into a single file.

![uniY tables3](../00_basic_intro/images/07_uniY.png)

![uniY table4](./images/11_hierarchy.png)


| tables  | referenced_by    | references                 |
|:-------:|:----------------:|:--------------------------:|
|students |        enrolls   |                            |
|courses  | enrolls, sections|                            |
|teachers | sections         |                            |
|sections | enrolls          | **courses**,**teachers**           |
|enrolls  |                  | **students**, **courses**, **sections**|

We start the population of the tables in the uniy sample database with the following order:

1. **students**
2. **courses**
3. **teachers**
4. **sections**
5. **enrolls**

## students table

```console
uniy=# \d students
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
```

Let's populate the **students** table:

```console
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
```

Let's execute the `INSERT INTO` statement in the `psql` prompt:

```console
uniy=# INSERT INTO students
uniy-#        (student_id, student_name, address, city, state, zip, gender)
uniy-# VALUES
uniy-#        (148, 'Susan Powell'    , '534 East River Dr.'  , 'Haverford', 'PA', '19041','F'),
uniy-#        (210, 'Bob Dawson'      , '120 South Jefferson' , 'Newport'  , 'RI', '02891','M'),
uniy-#        (298, 'Howard Mansfield', '290 Wynkoop Drive'   , 'Vienna'   , 'VA', '22180','M'),
uniy-#        (348, 'Susan Pugh'      , '534 East Hampton Dr.', 'Hartford' , 'CT', '06107','F'),
uniy-#        (349, 'Joe Adams'       , '473 Emmerson Street' , 'Newark'   , 'DE', '19702','M'),
uniy-#        (354, 'Janet Ladd'      , '441 10th Street'     , 'Pennsburg', 'PA', '18073','F'),
uniy-#        (410, 'Bill Jones'      , '120 South Harrison'  , 'Newport'  , 'CA', '92660','M'),
uniy-#        (473, 'Carol Dean'      , '983 Park Avenue'     , 'Boston'   , 'MA', '02169','F'),
uniy-#        (548, 'Allen Thomas'    , '238 West Ox Road'    , 'Chicago'  , 'IL', '60624','M'),
uniy-#        (558, 'Val Shipp'       , '238 Westport Road'   , 'Chicago'  , 'IL', '60556','F'),
uniy-#        (649, 'John Anderson'   , '473 Emmory Street'   , 'New York' , 'NY', '10008','M'),
uniy-#        (654, 'Janet Thomas'    , '441 6th Street'      , 'Erie'     , 'PA', '16510','F');
INSERT 0 12
uniy=#
```

**students** table:

|student_id |student_name  |address |city| state | zip  | gender|
|:----------|:------------:|:--------:|:---:|:----:|:----:|:-----:|
|148        | Susan Powell | 534 East River Dr.| Haverford | PA | 19041 | F|
|210        | Bob Dawson   | 120 South Jefferson | Newport | RI | 02891 | M|
|298        | Howard Mansfield | 290 Wynkoop Drive | Vienna | VA| 22180 | M|
|348        | Susan Pugh | 534 East Hampton Dr. | Hartford | CT | 06107 | F|
|349        | Joe Adams  | 473 Emmerson Street  | Newark   | DE | 19702 | M|
|354        | Janet Ladd | 441 10th Street | Pennsburg  | PA    | 18073 | F|
|410        | Bill Jones | 120 South Harrison | Newport | CA    | 92660 | M|
|473        | Carol Dean | 983 Park Avenue | Boston     | MA    | 02169 | F|
|548        | Allen Thomas| 238 West Ox Road | Chicago  | IL    | 60624 | M|
|558        | Val Shipp   | 238 Westport Road| Chicago  | IL    | 60556 | F|
|649        | John Anderson| 473 Emmory Street | New York| NY   | 10008 | M|
|654        | Janet Thomas | 441 6th Street  | Erie     | PA    | 16510 | F|

## courses table

```console
uniy=# \d courses
                    Table "public.courses"
   Column    |     Type      | Collation | Nullable | Default
-------------+---------------+-----------+----------+---------
 course_id   | smallint      |           | not null |
 course_name | character(20) |           |          |
 department  | character(16) |           |          |
 num_credits | smallint      |           |          |
```

Let's populate the **courses** table:

```console
INSERT INTO courses
       (course_id, course_name, department, num_credits)
VALUES
       (450, 'Western Civilization', 'History'         , 3),
       (730, 'Calculus IV'         , 'Math'            , 4),
       (290, 'English Composition' , 'English'         , 3),
       (480, 'Compiler Writing'    , 'Computer Science', 3),
       (550, 'Art History'         , 'History'         , 3);
```

Let's execute the `INSERT INTO` statement in the `psql` prompt:

```console
uniy=# INSERT INTO courses
uniy-#        (course_id, course_name, department, num_credits)
uniy-# VALUES
uniy-#        (450, 'Western Civilization', 'History'         , 3),
uniy-#        (730, 'Calculus IV'         , 'Math'            , 4),
uniy-#        (290, 'English Composition' , 'English'         , 3),
uniy-#        (480, 'Compiler Writing'    , 'Computer Science', 3),
uniy-#        (550, 'Art History'         , 'History'         , 3);
INSERT 0 5
```

**courses** table.

|course_id |     course_name      |    department    | num_credits|
|:---------|:--------------------:|:----------------:|:----------:|
|450       | Western Civilization | History          |           3|
|730       | Calculus IV          | Math             |           4|
|290       | English Composition  | English          |           3|
|480       | Compiler Writing     | Computer Science |           3|
|550       | Art History          | History          |           3|

## teachers table

```console
uniy=# \d teachers
                    Table "public.teachers"
    Column    |     Type      | Collation | Nullable | Default
--------------+---------------+-----------+----------+---------
 teacher_id   | smallint      |           | not null |
 teacher_name | character(18) |           |          |
 phone        | character(10) |           |          |
 salary       | numeric(10,2) |           |          |
```

Let's populate the **teachers** table:

```console
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
```

Let's execute the `INSERT INTO` statement in the `psql` prompt:

```console
uniy=# INSERT INTO teachers
uniy-#        (teacher_id, teacher_name, phone, salary)
uniy-# VALUES
uniy-#        (303, 'Dr. Horn'  ,'257-3049', 27540.00),
uniy-#        (290, 'Dr. Lowe'  ,'257-2390', 31450.00),
uniy-#        (430, 'Dr. Engle' ,'256-4621', 38200.00),
uniy-#        (180, 'Dr. Cooke' ,'257-8088', 29560.00),
uniy-#        (560, 'Dr. Olsen' ,'257-8086', 31778.00),
uniy-#        (784, 'Dr. Scango','257-3046', 32098.00),
uniy-#        (213, 'Dr. Wright','257-3393', 35000.00);
INSERT 0 7
```

**teachers** table:

|teacher_id |    teacher_name    |   phone    |  salary|
|:----------|:------------------:|:----------:|--------:|
|303        | Dr. Horn           | 257-3049   | 27540.00|
|290        | Dr. Lowe           | 257-2390   | 31450.00|
|430        | Dr. Engle          | 256-4621   | 38200.00|
|180        | Dr. Cooke          | 257-8088   | 29560.00|
|560        | Dr. Olsen          | 257-8086   | 31778.00|
|784        | Dr. Scango         | 257-3046   | 32098.00|
|213        | Dr. Wright         | 257-3393   | 35000.00|


## sections table

```console
uniy=# \d sections
                 Table "public.sections"
    Column    |   Type   | Collation | Nullable | Default
--------------+----------+-----------+----------+---------
 course_id    | smallint |           | not null |
 section_id   | smallint |           | not null |
 teacher_id   | smallint |           |          |
 num_students | smallint |           |          |
```

Let's populate the **sections** table:

```console
INSERT INTO sections
       (course_id, section_id, teacher_id, num_students)
VALUES
       (450, 1, 303, 2),
       (730, 1, 290, 6),
       (290, 1, 430, 3),
       (480, 1, 180, 3),
       (450, 2, 560, 2),
       (480, 2, 784, 2);
```

Let's execute the `INSERT INTO` statement in the `psql` prompt:

```console
uniy=# INSERT INTO sections
uniy-#        (course_id, section_id, teacher_id, num_students)
uniy-# VALUES
uniy-#        (450, 1, 303, 2),
uniy-#        (730, 1, 290, 6),
uniy-#        (290, 1, 430, 3),
uniy-#        (480, 1, 180, 3),
uniy-#        (450, 2, 560, 2),
uniy-#        (480, 2, 784, 2);
INSERT 0 6
```

**sections** table:

|course_id | section_id | teacher_id | num_students|
|:---------|:----------:|:----------:|:-----------:|
|450       |          1 |        303 |            2|
|730       |          1 |        290 |            6|
|290       |          1 |        430 |            3|
|480       |          1 |        180 |            3|
|450       |          2 |        560 |            2|
|480       |          2 |        784 |            2|

## enrolls table

```console
uniy=# \d enrolls
                 Table "public.enrolls"
   Column   |   Type   | Collation | Nullable | Default
------------+----------+-----------+----------+---------
 course_id  | smallint |           | not null |
 section_id | smallint |           | not null |
 student_id | smallint |           | not null |
 grade      | smallint |           |          |
```

Let's populate the **enrolls** table:

```console
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
```

Let's execute the `INSERT INTO` statement in the `psql` prompt:

```console
uniy=# INSERT INTO enrolls
uniy-#        (course_id, section_id, student_id, grade)
uniy-# VALUES
uniy-#        (730, 1, 148, 3),
uniy-#        (450, 2, 210, 3),
uniy-#        (730, 1, 210, 1),
uniy-#        (290, 1, 298, 3),
uniy-#        (480, 2, 298, 3),
uniy-#        (730, 1, 348, 2),
uniy-#        (290, 1, 349, 4),
uniy-#        (480, 1, 410, 2),
uniy-#        (450, 1, 473, 2),
uniy-#        (730, 1, 473, 3),
uniy-#        (480, 2, 473, 0),
uniy-#        (290, 1, 548, 2),
uniy-#        (730, 1, 558, 3),
uniy-#        (730, 1, 649, 4),
uniy-#        (480, 1, 649, 4),
uniy-#        (450, 1, 654, 4),
uniy-#        (450, 2, 548, DEFAULT);
INSERT 0 17
```

**enrolls** table:

|course_id | section_id | student_id | grade|
|:---------|:----------:|:----------:|:----:|
|730       |          1 |        148 |     3|
|450       |          2 |        210 |     3|
|730       |          1 |        210 |     1|
|290       |          1 |        298 |     3|
|480       |          2 |        298 |     3|
|730       |          1 |        348 |     2|
|290       |          1 |        349 |     4|
|480       |          1 |        410 |     2|
|450       |          1 |        473 |     2|
|730       |          1 |        473 |     3|
|480       |          2 |        473 |     0|
|290       |          1 |        548 |     2|
|730       |          1 |        558 |     3|
|730       |          1 |        649 |     4|
|480       |          1 |        649 |     4|
|450       |          1 |        654 |     4|
|450       |          2 |        548 |      |
