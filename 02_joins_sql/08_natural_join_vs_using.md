# NATURAL JOIN VS INNER JOIN USING

In the previous lesson we introduced the `NATUAL JOIN` operator as a way to join tables **on the basis of equal values of attributes with the same name**.

From the practical point of view, the `NATURAL JOIN` is not used very often. This is because most current database systems do not take advantage of attributes names in order to combine relations and thus use the `EQUI-JOIN` or `INNER JOIN`, rather than the `NATURAL JOIN` operator.

In spite of the advantage of an increased compactness, the natural join is not normally available on commercial systems. One reason is that a query that uses a natural join can introduce risks to the applications, because its behaviour can change significantly as a result of small variations on the schema. Another reason is that the natural join makes it necessary to analyze completely the schema of the tables involved in order to understand the join condition. This is a disadvantage when writing and when reading the query, because in both situations it is necessary to do a careful comparison of the schemas of the joined tables in order to be sure of the behaviour of the query.

At the same time, we presented the natural join first because it allows the simple discussion of important issues, which can then be extended to the equi-join. For example, we refer to natural joins in the discussion of some issues related to normalization.

In this lesson we introduce the formal definition of the `NATURAL JOIN` for PostgreSQL and illustrates the main differences with another popular clause used in the `INNER JOIN`, the `USING` clause.

## PostgreSQL NATURAL JOIN explained by examples

A natural join is a join that creates an implicit join based on the same column names in the joined tables.

The following shows the syntax of the PostgreSQL natural join:

```SQL
SELECT select_list
FROM T1
NATURAL [INNER, LEFT, RIGHT] JOIN T2;
```

A natural join can be an `inner join`, `left join`, or `right join`. If you do not specify a join explicitly e.g., `INNER JOIN`, `LEFT JOIN`, `RIGHT JOIN`, PostgreSQL will use the `INNER JOIN` **by default**.

If you use the asterisk (*) in the select list, the result will contain the following columns:

- All the common columns, which are the columns from both tables that have the same name.
- Every column from both tables, which is not a common column.

## Hr database Example

We will use the `employees` and `departments` tables from the `Hr` sample database to demonstrate how the `NATURAL JOIN` clause works.


**EMPLOYEES** table:

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

 Indexes:
    "employees_pkey" PRIMARY KEY, btree (employee_id)
Foreign-key constraints:
    "employees_fkey_department" FOREIGN KEY (department_id) REFERENCES departments(department_id) ON UPDATE CASCADE ON DELETE CASCADE
```

The `employees` table references the `departments` table using the `department_id` foreign key.

**Departments** Table:

```console
hr=# \d departments
                                             Table "public.departments"
     Column      |         Type          | Collation | Nullable |                      Default
-----------------+-----------------------+-----------+----------+----------------------------------------------------
 department_id   | integer               |           | not null | nextval('departments_department_id_seq'::regclass)
 department_name | character varying(30) |           | not null |
 location_id     | integer               |           |          |
Indexes:
    "departments_pkey" PRIMARY KEY, btree (department_id)
Foreign-key constraints:
    "departments_fkey_location" FOREIGN KEY (location_id) REFERENCES locations(location_id) ON UPDATE CASCADE ON DELETE CASCADE
Referenced by:
    TABLE "employees" CONSTRAINT "employees_fkey_department" FOREIGN KEY (department_id) REFERENCES departments(department_id) ON UPDATE CASCADE ON DELETE CASCADE
```

The `department_id` column in the `employees` table is the **foreign key column** that links the `employees` to the `departments` table. The `department_id` is the common column that we will use to perform the natural join.

Each employee belongs to one and only one department while each department can have more than one employee. The relationship between the `departments` and `employees` is `one-to-many`.

To get the information of the `department id` **1**,**2**, and **3**, you use the following statement.

**SQL**
```SQL
SELECT department_id,
       department_name
  FROM departments
 WHERE department_id IN (1, 2, 3);
```

**RESULTS**

|department_id | department_name|
|:------------:|:---------------:|
|            1 | Administration|
|            2 | Marketing|
|            3 | Purchasing|


To get the information of `employees` who work in the `department id` **1**, **2** and **3**, you use the following query:

**SQL**
```SQL
SELECT first_name,
       last_name,
       department_id
  FROM employees
 WHERE department_id IN (1,2,3)
 ORDER BY department_id;
```

| first_name | last_name  | department_id|
|:----------:|:----------:|:------------:|
| Jennifer   | Whalen     |             1|
| Michael    | Hartstein  |             2|
| Pat        | Fay        |             2|
| Sigal      | Tobias     |             3|
| Den        | Raphaely   |             3|
| Karen      | Colmenares |             3|
| Guy        | Himuro     |             3|
| Alexander  | Khoo       |             3|
| Shelli     | Baida      |             3|


Notice that both `employees` and `departments` tables **have the same column name** `department_id`, therefore we can use the `NATURAL JOIN` and we had to qualify the `department_id` column using the syntax *table_name.column_name*,
as follow:


**SQL**
```SQL
SELECT first_name,
       last_name,
       employees.department_id,
       department_name
  FROM employees
  NATURAL JOIN departments;
```
For each row in the employees table, the statement checks if the value of the `department_id` column equals the value of the `department_id` column in the departments table.

If the condition `employees.department_id = departments.department_id` is satisfied, the combined row that includes data from rows in both employees and departments tables are included in the result set.

**Results**

| first_name  |  last_name  | department_id | department_name|
|:-----------:|:-----------:|:-------------:|:---------------:|
| Jennifer    | Whalen      |             1 | Administration|
| Pat         | Fay         |             2 | Marketing|
| Michael     | Hartstein   |             2 | Marketing|
| Karen       | Colmenares  |             3 | Purchasing|
| Guy         | Himuro      |             3 | Purchasing|
| Sigal       | Tobias      |             3 | Purchasing|
| Shelli      | Baida       |             3 | Purchasing|
| Alexander   | Khoo        |             3 | Purchasing|
| Den         | Raphaely    |             3 | Purchasing|
| Susan       | Mavris      |             4 | Human Resources|
| Britney     | Everett     |             5 | Shipping|
| Sarah       | Bell        |             5 | Shipping|
| Irene       | Mikkilineni |             5 | Shipping|
| Shanta      | Vollman     |             5 | Shipping|
| Payam       | Kaufling    |             5 | Shipping|
| Adam        | Fripp       |             5 | Shipping|
| Matthew     | Weiss       |             5 | Shipping|
| Diana       | Lorentz     |             6 | IT|
| Valli       | Pataballa   |             6 | IT|
| David       | Austin      |             6 | IT|
| Bruce       | Ernst       |             6 | IT|
| Alexander   | Hunold      |             6 | IT|
| Hermann     | Baer        |             7 | Public Relations|
| Charles     | Johnson     |             8 | Sales|
| Kimberely   | Grant       |             8 | Sales|
| Jack        | Livingston  |             8 | Sales|
| Jonathon    | Taylor      |             8 | Sales|
| Karen       | Partners    |             8 | Sales|
| John        | Russell     |             8 | Sales|
| Lex         | De Haan     |             9 | Executive|
| Neena       | Kochhar     |             9 | Executive|
| Steven      | King        |             9 | Executive|
| Luis        | Popp        |            10 | Finance|
| Jose Manuel | Urman       |            10 | Finance|
| Ismael      | Sciarra     |            10 | Finance|
| John        | Chen        |            10 | Finance|
| Daniel      | Faviet      |            10 | Finance|
| Nancy       | Greenberg   |            10 | Finance|
| William     | Gietz       |            11 | Accounting|
| Shelley     | Higgins     |            11 | Accounting |

The convenience of the `NATURAL JOIN` is that it does not require you to specify the join clause because it **uses an implicit join clause based on the common column**.

However, **you should avoid using the** `NATURAL JOIN` **whenever possible because sometimes it may cause an unexpected result**.

## Natural JOIN vs INNER JOIN (USING)

For example, See the following `city` and `country` tables from the `dvd_rental` sample database:

**City** Table:

```console
dvdrental=# \d city
                                           Table "public.city"
   Column    |            Type             | Collation | Nullable |                Default
-------------+-----------------------------+-----------+----------+---------------------------------------
 city_id     | integer                     |           | not null | nextval('city_city_id_seq'::regclass)
 city        | character varying(50)       |           | not null |
 country_id  | smallint                    |           | not null |
 last_update | timestamp without time zone |           | not null | now()
Indexes:
    "city_pkey" PRIMARY KEY, btree (city_id)
    "idx_fk_country_id" btree (country_id)
Foreign-key constraints:
    "fk_city" FOREIGN KEY (country_id) REFERENCES country(country_id)
Referenced by:
    TABLE "address" CONSTRAINT "fk_address_city" FOREIGN KEY (city_id) REFERENCES city(city_id)
```

**Country** Table:

```console
dvdrental=# \d country
                                             Table "public.country"
   Column    |            Type             | Collation | Nullable |                   Default
-------------+-----------------------------+-----------+----------+---------------------------------------------
 country_id  | integer                     |           | not null | nextval('country_country_id_seq'::regclass)
 country     | character varying(50)       |           | not null |
 last_update | timestamp without time zone |           | not null | now()
Indexes:
    "country_pkey" PRIMARY KEY, btree (country_id)
Referenced by:
    TABLE "city" CONSTRAINT "fk_city" FOREIGN KEY (country_id) REFERENCES country(country_id)
```

Both tables have the same country_id column so you can use the NATURAL JOIN to join these tables as follows:

```SQL
SELECT *
  FROM city
NATURAL JOIN country;
```

**Results**

| country_id | last_update | city_id | city | country|
|:-----------:|:----------:|:-------:|:----:|:-------:|

**0 Rows**

The query returns an `empty result set`.

The reason is that…

**Both tables also have another common column called** `last_update`, which cannot be used for the join. However, the NATURAL JOIN clause just uses the `last_update` column.

A solution to this problem is the use of the **USING** clause in the `INNER JOIN`.

**SQL**
```SQL
SELECT *
  FROM city
 INNER JOIN country USING(country_id);
```

## INNER JOIN (USING clause)

The **USING** clause **specifies which columns to test for equality when two tables are joined**. It can be used instead of an ON clause in the JOIN operations that have an explicit join clause.

The **columns listed in the** `USING` clause must be `present in both of the two tables being joined`. The `USING` clause will be transformed to an `ON` clause that checks for equality between the named columns in the two tables.

When a `USING` clause is specified, an asterisk (*) in the select list of the query will be expanded to the following list of columns (in this order):

- All the columns in the `USING` clause
- All the columns of the first (left) table that are not specified in the `USING` clause
- All the columns of the second (right) table that are not specified in the `USING` clause.

![uny erd](../00_basic_intro/images/11_uniy_erd.png)

### Problem 1

1. **Problem**: Which teachers teach which courses? (List the teachers by name and course_id)


- **Tables**: teachers, sections
- **Columns**: teacher_name, course_id
- **Condition**: `teachers.teacher_id = sections.teacher_id`
- **Sorting**: teacher_name, course_id

```console
uniy=# \d sections
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

**Query Diagram Join**  

![join diagram](./images/10_diagram.png)

**SQL**
```SQL
SELECT teacher_name,
       course_id
  FROM teachers INNER JOIN sections
    ON teachers.teacher_id = sections.teacher_id
 ORDER BY teacher_name, course_id;
```

**Results**

|teacher_name    | course_id|
|:--------------:|:---------:|
|Dr. Cooke          |       480|
|Dr. Engle          |       290|
|Dr. Horn           |       450|
|Dr. Lowe           |       730|
|Dr. Olsen          |       450|
|Dr. Scango         |       480|

**Query**

```console
uniy=# SELECT teacher_name,
uniy-#        course_id
uniy-#   FROM teachers INNER JOIN sections
uniy-#     ON teachers.teacher_id = sections.teacher_id
uniy-#  ORDER BY teacher_name, course_id;
```

**Output**
```console
    teacher_name    | course_id
--------------------+-----------
 Dr. Cooke          |       480
 Dr. Engle          |       290
 Dr. Horn           |       450
 Dr. Lowe           |       730
 Dr. Olsen          |       450
 Dr. Scango         |       480
(6 rows)
```


Let's now execute the `INNER JOIN` with the **USING** clause:

```SQL
SELECT *
  FROM teachers INNER JOIN sections
 USING(teacher_id)
 ORDER BY teacher_name, course_id;
```

**Results**

|teacher_id |teacher_name|phone|salary| course_id | section_id | num_students|
|:----------:|:----------:|:---:|:---:|:----------:|:----------:|:-----------:|
|180 | Dr. Cooke | 257-8088 | 29560.00 |  480 |  1 | 3|
|430 | Dr. Engle          | 256-4621   | 38200.00 |       290 |          1 |    3|
|303 | Dr. Horn           | 257-3049   | 27540.00 |       450 |          1 |    2|
|290 | Dr. Lowe           | 257-2390   | 31450.00 |       730 |          1 |    6|
|560 | Dr. Olsen          | 257-8086   | 31778.00 |       450 |          2 |    2|
|784 | Dr. Scango         | 257-3046   | 32098.00 |       480 |          2 |    2|
