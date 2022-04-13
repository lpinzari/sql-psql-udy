# UniY sample database

The **UniY** database contains the registration information for a fictitious (and very small) university.

![uniY tables](./images/06_uniY.png)

The picture above shows a summary of each table's columns in query diagram form. Note that, once again, one or more columns in each table have a small picture of a **key beside the column name**, identifying **visually the columns that act as keys for that table**.

### students

The table in this database with the most columns is called **students**. It contains information on all students currently enrolled at this university. Its **columns** are as follows:

- **student_id**: A `SMALLINT` containing a **unique number** for each student.
- **student_name**: A `CHAR (18)` containing a student's name.
- **address**: A `CHAR (20)` containing this student's street address.
- **city**: A `CHAR (10)` containing the name of this student's home city.
- **state**: A `CHAR (2)` containing the two-letter postal abbreviation of this student's home state.
- **zip**: A `CHAR (5)` containing this student's home zip code.
- **gender**: A `CHAR (1)` containing an `M` if this student is male, and an `F` if the student is female.

Because it contains a unique value for each record, the **student_id** column is designated as the **key** for this table.

### teachers

Another table in the database is called **teachers**. This table describes the teachers currently active at this university. Its **columns** are as follows:

- **teacher_id**: A `SMALLINT` containing a **unique number** for each teacher.
- **teacher_name**: A `CHAR (18)` containing a teacher's name.
- **phone**: A `CHAR (10)` containing this teacher's phone number.
- **salary**: A `NUMERIC (10,2)` containing this teacher's annual salary.

Again, because of the column's unique values, **teacher_id** is the **key** for this table.

### courses

A third member of this database is the **courses** table. **courses** lists information on the courses offered by the university this term and has the following **columns**:

- **course_id**: A `SMALLINT` containing a **unique number** for each course.
- **course_name**: A `CHAR (20)` containing the name of a course.
- **department**: A `CHAR (16)` indicating which department offers this course.
- **num_credits**: A `SMALLINT` indicating the number of credits this course is worth.

Because course numbers are unique, the **course_id** column serves as this tables's **key**.

### sections

Another of the database's table is called **sections**. Many university courses are divided into two or more sections, and this table describes each section of each course. Its **columns** are as follows:

- **course_id**: A `SMALLINT` identifying the course of which this is a section. `Values in this column are drawn from the column of the same name in the` **courses** `table`.
- **section_id**: A `SMALLINT` identifying a specific section of a particular course.
- **teacher_id**: A `SMALLINT` identifying the instructor of this section. `Values in this column are drawn from the column of the same name in the` **teaches** table.
- **num_students**: A `SMALLINT` indicating how many students are enrolled in the course.

No single column in this table can act as its key. Each record describes only one section, but **section numbers are not unique**;

several different courses may have a `section 1`. Also, the **same course may have several sections**, so course number alone is not sufficient to uniquely identify a record in the table. But **taken together**, a course number (`course_id`) and a section number (`section_id`) do provide a **unique** reference for each record in this table. Therefore, the **key** for a record in **sections** consists of the values in both that record's **course_id** and **section_id** fields.

### enrolls

The final table in this example database is the **enrolls** table. It contains a record with each student's grade for every section of every course in which that student is enrolled. Because its purpose is to tie together information in other tables, its contents may appear somewhat unusual at first sight. Don't worry- the usefulness of the **enrolls** table will become clear before the end of the course. The **columns** in this table are as follows:

- **course_id**: A `SMALLINT` identifying a course. `Values in this column are drawn from the column of the same name in the` **courses** table.
- **section_id**: A `SMALLINT` identifying a particular section of this course. `Values in this column are the same as those in the` **section_id** `column in the` **sections** `table`.
- **student_id**: A `SMALLINT` identifying a `particular student from the list in the` **students** `table`.
- **grade**: A `SMALLINT` indicating the student's grade in this section. a traditional four point scale is used, so a value of 4 represents an A, 3 a B, and so on.

Once again, no single column contains enough information to act as the key for this table. To uniquely identify a record, values from no less than three columns are required: **course_id**, **section_id** and **student_id**. Taken together, the values in these three columns comprise the **unique key** for each record in **enrolls** table.

![uniY tables2](./images/06_uniY.png)

The picture of the database shown in the figure above is a useful summary of the information stored in this simple database and of the relationships between various parts of that information.

![uniY tables3](./images/07_uniY.png)

One addition has been made to the version of the first figure: **Lines now connect certain columns in the tables**. These lines show graphically which columns contain the same kinds of information, such as **student_id's**, and thus can be **used to navigate through the data**. This idea is explained more fully in the chapter ...

For now, these lines can be safely ignored.
