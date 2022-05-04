# SELECT & FROM

By far the most used SQL's verbs is **SELECT**. Since the most common operation performed on a database is to examine its data, it should not be surprising that the SQL statement that performs this task is the workhorse of the language. In any real database, of course, other SQL statements should have to be used first to create the database's tables and fill them with records. For most SQL users, however, this task will already have been performed, and so we begin with SELECT.

The general form is:

```console
SELECT what_to_select
FROM which_table;
```

The SELECT statement is one of the most complex statements in PostgreSQL. It has many clauses that you can use to form a flexible query.

The `SELECT` statement has the following **clauses**:

- Select distinct rows using `DISTINCT` operator.
- Sort rows using `ORDER BY` clause.
- Filter rows using `WHERE` clause.
- Select a subset of rows from a table using `LIMIT` or `FETCH` clause.
- Group rows into groups using `GROUP BY` clause.
- Filter groups using `HAVING` clause.
- Join with other tables using joins such as `INNER JOIN`, `LEFT JOIN`, `FULL OUTER JOIN`, `CROSS JOIN` clauses.
- Perform set operations using `UNION`, `INTERSECT`, and `EXCEPT`.

In this lesson, you are going to focus on the `SELECT` and `FROM` clauses.

```console
SELECT what_to_select
FROM which_table;
```

## Selecting Specific Columns in a Table

To see the values of certain columns for all of a table's records, you must give both the names of those columns and the name of the table. The general form is

```console
SELECT <column names>
  FROM <table>;
```

where `<column names>` is replaced by the names of the desired columns, separated by commas, and `<table>` is replaced by the name of a table that contains those columns.

**Note**: **Throughout this notes, words flanked by < and > represent placeholders for a type of thing and replaced by specific instances of those things in actual SQL queries.**

In general, if you specify a column that is not defined for that table, you will get some kind of error message depending on exactly what system you are using. Otherwise, the results of your query, a list of the desired values, will appear.

The basic steps are:

1. `<column names>`: First, specify a select list that can be a column or a list of columns in a table from which you want to retrieve data. If you specify a list of columns, you need to place a comma (`,`) between two columns to separate them. If you want to select data from all the columns of the table, you can use an asterisk (`*`) shorthand instead of specifying **all the column names**. The select list may also contain expressions or literal values.
2. `<table>`: Second, specify the name of the table from which you want to query data after the FROM keyword.

The `FROM` clause is optional. **If you do not query data from any table**, you can omit the `FROM` clause in the `SELECT` statement.

```console
postgres=# SELECT 'Hello World !' AS welcome;
    welcome
---------------
 Hello World !
(1 row)
```

In the last example we used the `AS` keyword to name the column result. You'll learn about column aliases in the next lessons.

The following example uses the SELECT statement with an expression. It omits the FROM clause:

```console
postgres=# SELECT 5*3 AS five_times_three;
 five_times_three
------------------
               15
(1 row)
```

PostgreSQL evaluates the `FROM` clause before the `SELECT` clause in the `SELECT` statement:

- **FROM** `->` **SELECT**

> Note that the SQL keywords are case-insensitive. It means that SELECT is equivalent to select or Select. By convention, we will use all the SQL keywords in uppercase to make the queries easier to read.

**To show these result visually**, the query diagram contains a representation of the table being queried with a **check mark next to each column selected by the query**.

## Example Parch & Posey

First, we are going to generate a list of all of the **orders** that Parch and Posey has ever received.

Parch and Posey records their orders in a table called **orders**. That table contains all the columns you see here.

```console
parch_posey=> \d orders
                              Table "public.orders"
      Column      |            Type             | Collation | Nullable | Default
------------------+-----------------------------+-----------+----------+---------
 id               | integer                     |           | not null |
 account_id       | integer                     |           |          |
 occurred_at      | timestamp without time zone |           |          |
 standard_qty     | integer                     |           |          |
 gloss_qty        | integer                     |           |          |
 poster_qty       | integer                     |           |          |
 total            | integer                     |           |          |
 standard_amt_usd | numeric(10,2)               |           |          |
 gloss_amt_usd    | numeric(10,2)               |           |          |
 poster_amt_usd   | numeric(10,2)               |           |          |
 total_amt_usd    | numeric(10,2)               |           |          |
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
```

- `id`: Each order has an UNIQUE id or PRIMARY KEY, so it can be referenced
- `occurred_at`: a timestamp to indicate when that order was placed.

It also contains quantity sold for each type of paper sold and the total:

- `standard_qty`
- `gloss_qty`
- `poster_qty`
- `total`

It also contains the revenue:

- `standard_amt_usd`
- `gloss_amt_usd`
- `poster_amt_usd`
- `total_amt_usd`

In order to generate the list of all orders, we'll write a SELECT statement.

Think of a SELECT statement as filling out a form to get a set of results you are trying to get.

The form has a set of questions, like:

1. What data you want to pull from?
2. Which elements of that data set from the data base do you want to pull?

These questions are structured in the same order every time. Some of them are **mandatory** and other are optional.

When writing out the SELECT statement, each of these questions is represented by a single word like **SELECT** or **FROM**. These words are called **CLAUSES**.

```console
SELECT
  FROM
```

### FROM

The **FROM** clause: Tells the query **What data to use**.

```console
SELECT
  FROM orders
```

Here, we're looking at the **orders** table.

### SELECT

The **SELECT** clause tells the query **which columns to read from the table**.


```console
SELECT id, occurred_at
  FROM orders;
```

![select 1](./images/10_select.png)

Let’s examine the SELECT statement in more detail:

- First, specify a select list that can be a column or a list of columns in a table from which you want to retrieve data. If you specify a list of columns, you need to place a comma (,) between two columns to separate them. If you want to select data from all the columns of the table, you can use an asterisk (`*`) shorthand instead of specifying all the column names. The select list may also contain expressions or literal values.
- Second, specify the name of the table from which you want to query data after the FROM keyword.

```console
SELECT id,
       occurred_at
  FROM orders
 LIMIT 3;
```

Let's run the command in the `psql` prompt and limit the output results to the first three rows:

```console
parch_posey=> SELECT id,
parch_posey->        occurred_at
parch_posey->   FROM orders
parch_posey->  LIMIT 3;
 id |     occurred_at
----+---------------------
  1 | 2015-10-06 17:31:14
  2 | 2015-11-05 03:34:33
  3 | 2015-12-04 04:21:55
(3 rows)
```

### DVDRENTAL example: Selecting specific columns from a table

We will use the following `customer` table from the `dvdrental` sample database.

```console
dvdrental=# \d customer
                                             Table "public.customer"
   Column    |            Type             | Collation | Nullable |                    Default
-------------+-----------------------------+-----------+----------+-----------------------------------------------
 customer_id | integer                     |           | not null | nextval('customer_customer_id_seq'::regclass)
 store_id    | smallint                    |           | not null |
 first_name  | character varying(45)       |           | not null |
 last_name   | character varying(45)       |           | not null |
 email       | character varying(50)       |           |          |
 address_id  | smallint                    |           | not null |
 activebool  | boolean                     |           | not null | true
 create_date | date                        |           | not null | ('now'::text)::date
 last_update | timestamp without time zone |           |          | now()
 active      | integer                     |           |          |
Indexes:
    "customer_pkey" PRIMARY KEY, btree (customer_id)
```

1. **Problem** - Using PostgreSQL SELECT statement to query data from one column example

This example uses the `SELECT` statement to find the `first names` of all customers from the customer table:

**Query**
```console
dvdrental=# SELECT first_name
dvdrental-#   FROM customer
dvdrental-#  LIMIT 10;
```

**Output**
```console
 first_name
------------
 Jared
 Mary
 Patricia
 Linda
 Barbara
 Elizabeth
 Jennifer
 Maria
 Susan
 Margaret
(10 rows)
```

Once again, notice that we added a semicolon (`;`) at the end of the `SELECT` statement. The semicolon is not a part of the SQL statement. It is used to signal PostgreSQL the end of an SQL statement. The semicolon is also used to separate two SQL statements. Sometimes I can be a little bit annoying :smile:

2. **Problem**:  Using PostgreSQL SELECT statement to query data from multiple columns example

Suppose you just want to know the `first name`, `last name` and `email` of **customers**, you can specify these column names in the SELECT clause as shown in the following query:

**Query**

```console
dvdrental=# SELECT
dvdrental-#    first_name,
dvdrental-#    last_name,
dvdrental-#    email
dvdrental-# FROM
dvdrental-#    customer
dvdrental-# LIMIT 11;
```

**Output**

```console
 first_name | last_name |                email
------------+-----------+-------------------------------------
 Jared      | Ely       | jared.ely@sakilacustomer.org
 Mary       | Smith     | mary.smith@sakilacustomer.org
 Patricia   | Johnson   | patricia.johnson@sakilacustomer.org
 Linda      | Williams  | linda.williams@sakilacustomer.org
 Barbara    | Jones     | barbara.jones@sakilacustomer.org
 Elizabeth  | Brown     | elizabeth.brown@sakilacustomer.org
 Jennifer   | Davis     | jennifer.davis@sakilacustomer.org
 Maria      | Miller    | maria.miller@sakilacustomer.org
 Susan      | Wilson    | susan.wilson@sakilacustomer.org
 Margaret   | Moore     | margaret.moore@sakilacustomer.org
 Dorothy    | Taylor    | dorothy.taylor@sakilacustomer.org
(11 rows)
```



### uniY Example: Selecting specific columns from a table

1. **Problem**:
List the names of all `courses`, their `departments`, and the `number of credits` for each.

```console
uniy=# \d courses
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

**SQL**

```console
uniy=# SELECT course_name, department, num_credits
uniy-#   FROM courses;
```

**Output**

```console
course_name      |    department    | num_credits
----------------------+------------------+-------------
Western Civilization | History          |           3
Calculus IV          | Math             |           4
English Composition  | English          |           3
Compiler Writing     | Computer Science |           3
Art History          | History          |           3
(5 rows)
```

2. **Problem**:
List the names, hometowns, and home states of all students.

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
Indexes:
    "students_pkey" PRIMARY KEY, btree (student_id)
Referenced by:
    TABLE "enrolls" CONSTRAINT "enrolls_fkey_student" FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE
```

**SQL**:

```console
uniy=# SELECT student_name, city, state
uniy-#   FROM students;
```

**Output**

```console
uniy=# SELECT student_name, city, state
uniy-#   FROM students;
    student_name    |    city    | state
--------------------+------------+-------
 Susan Powell       | Haverford  | PA
 Bob Dawson         | Newport    | RI
 Howard Mansfield   | Vienna     | VA
 Susan Pugh         | Hartford   | CT
 Joe Adams          | Newark     | DE
 Janet Ladd         | Pennsburg  | PA
 Bill Jones         | Newport    | CA
 Carol Dean         | Boston     | MA
 Allen Thomas       | Chicago    | IL
 Val Shipp          | Chicago    | IL
 John Anderson      | New York   | NY
 Janet Thomas       | Erie       | PA
(12 rows)
```

### HR example: Selecting specific columns from a Table

**Problem**:

Select data from the employee id, first name, last name, and hire date of all rows in the **employees** table:

```console
hr=# \d employees
                                            Table "public.employees"
    Column     |          Type          | Collation | Nullable |                    Default
---------------+------------------------+-----------+----------+------------------------------------------------
 employee_id   | integer                |           | not null | nextval('employees_employee_id_seq'::regclass)
 first_name    | character varying(20)  |           |          |
 last_name     | character varying(25)  |           | not null |
 email         | character varying(100) |           | not null |
 phone_number  | character varying(20)  |           |          |
 hire_date     | date                   |           | not null |
 job_id        | integer                |           | not null |
 salary        | numeric(8,2)           |           | not null |
 manager_id    | integer                |           |          |
 department_id | integer                |           |          |
```

**SQL**

```console
hr=# SELECT
hr-#     employee_id,
hr-#     first_name,
hr-#     last_name,
hr-#     hire_date
hr-# FROM
hr-#     employees;
```

**Output**

```console
 employee_id | first_name  |  last_name  | hire_date
-------------+-------------+-------------+------------
         100 | Steven      | King        | 1987-06-17
         101 | Neena       | Kochhar     | 1989-09-21
         102 | Lex         | De Haan     | 1993-01-13
         103 | Alexander   | Hunold      | 1990-01-03
         104 | Bruce       | Ernst       | 1991-05-21
         105 | David       | Austin      | 1997-06-25
         106 | Valli       | Pataballa   | 1998-02-05
         107 | Diana       | Lorentz     | 1999-02-07
         108 | Nancy       | Greenberg   | 1994-08-17
         109 | Daniel      | Faviet      | 1994-08-16
         110 | John        | Chen        | 1997-09-28
         111 | Ismael      | Sciarra     | 1997-09-30
         112 | Jose Manuel | Urman       | 1998-03-07
         113 | Luis        | Popp        | 1999-12-07
         114 | Den         | Raphaely    | 1994-12-07
         115 | Alexander   | Khoo        | 1995-05-18
         116 | Shelli      | Baida       | 1997-12-24
         117 | Sigal       | Tobias      | 1997-07-24
         118 | Guy         | Himuro      | 1998-11-15
         119 | Karen       | Colmenares  | 1999-08-10
         120 | Matthew     | Weiss       | 1996-07-18
         121 | Adam        | Fripp       | 1997-04-10
         122 | Payam       | Kaufling    | 1995-05-01
         123 | Shanta      | Vollman     | 1997-10-10
         126 | Irene       | Mikkilineni | 1998-09-28
         145 | John        | Russell     | 1996-10-01
         146 | Karen       | Partners    | 1997-01-05
         176 | Jonathon    | Taylor      | 1998-03-24
         177 | Jack        | Livingston  | 1998-04-23
         178 | Kimberely   | Grant       | 1999-05-24
         179 | Charles     | Johnson     | 2000-01-04
         192 | Sarah       | Bell        | 1996-02-04
         193 | Britney     | Everett     | 1997-03-03
         200 | Jennifer    | Whalen      | 1987-09-17
         201 | Michael     | Hartstein   | 1996-02-17
         202 | Pat         | Fay         | 1997-08-17
         203 | Susan       | Mavris      | 1994-06-07
         204 | Hermann     | Baer        | 1994-06-07
         205 | Shelley     | Higgins     | 1994-06-07
         206 | William     | Gietz       | 1994-06-07
(40 rows)
```



## Selecting all columns in a table

It is often useful to see the value of every field for every record in a table. One way to do this is by listing the names of every column in that table, similar to the example we have just seen. Because this is just a frequent operation, however, SQL provides a shorthand way to list all values in a table.

Instead of actually listing all column names, you can type an asterisk `*` instead. The general form is:

```console
SELECT *
  FROM <table>;
```

where `<table>` is replaced by the name of a table. Unsurprisingly, the query diagram for this shows the table with a check by every column name.

#### Example

```console
SELECT *
  FROM orders;
```

![select 2](./images/11_select.png)



PostgreSQL evaluates the FROM clause before the SELECT clause in the SELECT statement.

> Note that the SQL keywords are case-insensitive. It means that SELECT is equivalent to select or Select. By convention, **we will use all the SQL keywords in uppercase to make the queries easier to read**.

Notice that we added a semicolon (`;`) **at the end of the** `SELECT` statement. The **semicolon is not a part of the SQL statement**.

- **It is used to signal PostgreSQL the end of an SQL statement**.
- **The semicolon is also used to separate two SQL statements**.

**Both the SELECT and FROM clauses are mandatory to query a database**.

## Export PostgreSQL query to a csv

```console
(base) ludo /~  $  psql parch_posey
psql (11.4)
Type "help" for help.

parch_posey=# COPY (SELECT * FROM orders LIMIT 3) TO '/Users/ludovicopinzari/orders_query.csv' DELIMITER ',' CSV HEADER;
COPY 3
parch_posey=# \q
```

You must login as a superuser to export the query on your local machine. the command is:

- `COPY (SELECT * FROM orders LIMIT 3) TO '/Users/ludovicopinzari/orders_query.csv' DELIMITER ',' CSV HEADER;`

We saved the file in the current directory.

```console
(base) ludo /~  $  cat orders_query.csv
id,account_id,occurred_at,standard_qty,gloss_qty,poster_qty,total,standard_amt_usd,gloss_amt_usd,poster_amt_usd,total_amt_usd
1,1001,2015-10-06 17:31:14,123,22,24,169,613.77,164.78,194.88,973.43
2,1001,2015-11-05 03:34:33,190,41,57,288,948.10,307.09,462.84,1718.03
3,1001,2015-12-04 04:21:55,85,47,0,132,424.15,352.03,0.00,776.18
```

We can also open the file with Excel or a text editor.

### DVDRENTAL example: query data from all columns of a table

The following query uses the SELECT statement to select data from all columns of the `customer` table:

**Query**
```console
dvdrental=# SELECT *
dvdrental-#   FROM customer
dvdrental-#  LIMIT 10;
```

**Output**
```console
 customer_id | store_id | first_name | last_name |                email                | address_id | activebool | create_date |       last_update       | active
-------------+----------+------------+-----------+-------------------------------------+------------+------------+-------------+-------------------------+--------
         524 |        1 | Jared      | Ely       | jared.ely@sakilacustomer.org        |        530 | t          | 2006-02-14  | 2013-05-26 14:49:45.738 |      1
           1 |        1 | Mary       | Smith     | mary.smith@sakilacustomer.org       |          5 | t          | 2006-02-14  | 2013-05-26 14:49:45.738 |      1
           2 |        1 | Patricia   | Johnson   | patricia.johnson@sakilacustomer.org |          6 | t          | 2006-02-14  | 2013-05-26 14:49:45.738 |      1
           3 |        1 | Linda      | Williams  | linda.williams@sakilacustomer.org   |          7 | t          | 2006-02-14  | 2013-05-26 14:49:45.738 |      1
           4 |        2 | Barbara    | Jones     | barbara.jones@sakilacustomer.org    |          8 | t          | 2006-02-14  | 2013-05-26 14:49:45.738 |      1
           5 |        1 | Elizabeth  | Brown     | elizabeth.brown@sakilacustomer.org  |          9 | t          | 2006-02-14  | 2013-05-26 14:49:45.738 |      1
           6 |        2 | Jennifer   | Davis     | jennifer.davis@sakilacustomer.org   |         10 | t          | 2006-02-14  | 2013-05-26 14:49:45.738 |      1
           7 |        1 | Maria      | Miller    | maria.miller@sakilacustomer.org     |         11 | t          | 2006-02-14  | 2013-05-26 14:49:45.738 |      1
           8 |        2 | Susan      | Wilson    | susan.wilson@sakilacustomer.org     |         12 | t          | 2006-02-14  | 2013-05-26 14:49:45.738 |      1
           9 |        2 | Margaret   | Moore     | margaret.moore@sakilacustomer.org   |         13 | t          | 2006-02-14  | 2013-05-26 14:49:45.738 |      1
(10 rows)
```

In this example, we used an asterisk (`*`) in the `SELECT` clause, which is a shorthand for all columns. Instead of listing all columns in the `SELECT` clause, we just used the asterisk (`*`) to save some typing.

However, **it is not a good practice to use the asterisk** (`*`) in the `SELECT` statement when **you embed SQL statements in the application code** like `Python`, `Java`, `Node.js`, or `PHP` due to the following reasons:

- **Database performance**. Suppose you have a table with many columns and a lot of data, the SELECT statement with the asterisk (*) shorthand will select data from all the columns of the table, which may not be necessary to the application.
- **Application performance**. Retrieving unnecessary data from the database increases the traffic between the database server and application server. In consequence, your applications may be slower to respond and less scalable.

Because of these reasons, **it is a good practice to explicitly specify the column names** in the `SELECT` clause whenever possible to get only necessary data from the database.

And you should only use the asterisk (`*`) shorthand for the ad-hoc queries that examine data from the database.

2. **Using PostgreSQL SELECT statement with expressions example**

The following example uses the `SELECT` statement to return `full names` and `emails` of all **customers**:

**Query**
```console
dvdrental=# SELECT
dvdrental-#    first_name || ' ' || last_name AS full_name,
dvdrental-#    email
dvdrental-#   FROM customer
dvdrental-#  LIMIT 11;
```

**Output**
```console
    full_name     |                email
------------------+-------------------------------------
 Jared Ely        | jared.ely@sakilacustomer.org
 Mary Smith       | mary.smith@sakilacustomer.org
 Patricia Johnson | patricia.johnson@sakilacustomer.org
 Linda Williams   | linda.williams@sakilacustomer.org
 Barbara Jones    | barbara.jones@sakilacustomer.org
 Elizabeth Brown  | elizabeth.brown@sakilacustomer.org
 Jennifer Davis   | jennifer.davis@sakilacustomer.org
 Maria Miller     | maria.miller@sakilacustomer.org
 Susan Wilson     | susan.wilson@sakilacustomer.org
 Margaret Moore   | margaret.moore@sakilacustomer.org
 Dorothy Taylor   | dorothy.taylor@sakilacustomer.org
(11 rows)
```

In this example, we used the concatenation operator `||` to concatenate the first name, space, and last name of every customer. You'll learn about the string concatenation in the next lessons.

### Uniy example: selecting all columns in a table

**Problem**:
List all values in the `courses` table.

```console
uniy=# \d courses
                    Table "public.courses"
   Column    |     Type      | Collation | Nullable | Default
-------------+---------------+-----------+----------+---------
 course_id   | smallint      |           | not null |
 course_name | character(20) |           |          |
 department  | character(16) |           |          |
 num_credits | smallint      |           |          |
Indexes:
    "courses_pkey" PRIMARY KEY, btree (course_id)
```

**Query**

```console
uniy=# SELECT *
uniy-#   FROM courses;
```

**Output**

```console
 course_id |     course_name      |    department    | num_credits
-----------+----------------------+------------------+-------------
       450 | Western Civilization | History          |           3
       730 | Calculus IV          | Math             |           4
       290 | English Composition  | English          |           3
       480 | Compiler Writing     | Computer Science |           3
       550 | Art History          | History          |           3
(5 rows)
```

**Problem**
List all values in the `teachers` table.

```console
uniy=# \d teachers
                    Table "public.teachers"
    Column    |     Type      | Collation | Nullable | Default
--------------+---------------+-----------+----------+---------
 teacher_id   | smallint      |           | not null |
 teacher_name | character(18) |           |          |
 phone        | character(10) |           |          |
 salary       | numeric(10,2) |           |          |
Indexes:
    "teachers_pkey" PRIMARY KEY, btree (teacher_id)
```

**Query**

```console
uniy=# SELECT *
uniy-#   FROM teachers;
```

**Output**

```console
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

## Summary

Here you were introduced to the SQL command that will be used in every query you write: `SELECT` ... `FROM` ....

- **SELECT** indicates which column(s) you want to be given the data for.

- **FROM** specifies from which table(s) you want to select the columns. Notice the columns need to exist in this table.

If you want to be provided with the data from all columns in the table, you use "`*`", like so:

- `SELECT * FROM orders`

Note that using SELECT does not create a new table with these columns in the database, it just provides the data to you as the results, or output, of this command.

You will use this SQL SELECT statement in every query in this course, but you will be learning a few additional statements and operators that can be used along with them to ask more advanced questions of your data.

## Further resources

- [SELECT](https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-select/) on  tutorial page.
