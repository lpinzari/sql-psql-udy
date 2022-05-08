# NOT in a WHERE clause

To negate the result of any Boolean expression, you use the NOT operator. The following illustrates how to use the `NOT` operator:

```console
NOT [Boolean_expression]
```

The following table shows the result of the NOT operator.

|    |NOT |
|:--:|:--:|
|TRUE|FALSE|
|FALSE|TRUE|
|NULL|NULL|

## Using NOT

SQL's final boolean operator is `NOT`. Unlike `AND` and `OR`, `NOT` isn't used to combine conditions in a `WHERE` clause. Instead, it negates a specified condition.

This operator helps you to form flexible conditions in the WHERE clause with `LIKE`, `IN`, `BETWEEN` and `EXISTS`.

### UniY NOT in a WHERE clause examples

We’ll use the `students` table in the `uniy` sample database for the demonstration.

**Problem**: List the names and states of all students who are not from Illinois.

- **table**: students
- **columns**: student_name, state
- **condition**: students not from Illinois state.

**Table**
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
```

**SQL**
```SQL
SELECT student_name,
       state
  FROM students
 WHERE NOT (state = 'IL');  
```

**Results**

|student_name    | state|
|:--------------:|:----:|
|Susan Powell       | PA|
|Bob Dawson         | RI|
|Howard Mansfield   | VA|
|Susan Pugh         | CT|
|Joe Adams          | DE|
|Janet Ladd         | PA|
|Bill Jones         | CA|
|Carol Dean         | MA|
|John Anderson      | NY|
|Janet Thomas       | PA|


**Query**
```console
uniy=# SELECT student_name,
uniy-#        state
uniy-#   FROM students
uniy-#  WHERE NOT (state = 'IL');
```

**Output**
```console
    student_name    | state
--------------------+-------
 Susan Powell       | PA
 Bob Dawson         | RI
 Howard Mansfield   | VA
 Susan Pugh         | CT
 Joe Adams          | DE
 Janet Ladd         | PA
 Bill Jones         | CA
 Carol Dean         | MA
 John Anderson      | NY
 Janet Thomas       | PA
(10 rows)
```

### HR NOT in a WHERE clause example

We’ll use the `employees` table to help better you understand the `NOT` operator.

**Table**
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
```

The following statement retrieves all employees who work in the department id 5.

**SQL 1**
```SQL
SELECT employee_id,
	     first_name,
	     last_name,
	     salary
  FROM employees
 WHERE department_id = 5
 ORDER BY salary;
```

**Results 1**

|employee_id | first_name |  last_name  | salary|
|:----------:|:----------:|:-----------:|:-----:|
|126 | Irene      | Mikkilineni | **2700.00**|
|193 | Britney    | Everett     | **3900.00**|
|192 | Sarah      | Bell        | **4000.00**|
|123 | Shanta     | Vollman     | 6500.00|
|122 | Payam      | Kaufling    | 7900.00|
|120 | Matthew    | Weiss       | 8000.00|
|121 | Adam       | Fripp       | 8200.00|


To get the employees who work in the department id 5 and with a salary not greater than 5000.

**SQL 2**
```SQL
SELECT employee_id,
	     first_name,
	     last_name,
	     salary
  FROM employees
 WHERE department_id = 5 AND
       NOT salary > 5000
 ORDER BY salary;
```

**Results 2**

|employee_id | first_name |  last_name  | salary|
|:----------:|:----------:|:-----------:|:-----:|
|126 | Irene      | Mikkilineni | 2700.00|
|193 | Britney    | Everett     | 3900.00|
|192 | Sarah      | Bell        | 4000.00|



**Query 1**
```console
hr=# SELECT employee_id,
hr-#        first_name,
hr-#        last_name,
hr-#        salary
hr-#   FROM employees
hr-#  WHERE department_id = 5
hr-#  ORDER BY salary;
```

**Output 1**
```console
 employee_id | first_name |  last_name  | salary
-------------+------------+-------------+---------
         126 | Irene      | Mikkilineni | 2700.00
         193 | Britney    | Everett     | 3900.00
         192 | Sarah      | Bell        | 4000.00
         123 | Shanta     | Vollman     | 6500.00
         122 | Payam      | Kaufling    | 7900.00
         120 | Matthew    | Weiss       | 8000.00
         121 | Adam       | Fripp       | 8200.00
(7 rows)
```

**Query 2**
```console
hr=# SELECT employee_id,
hr-#        first_name,
hr-#        last_name,
hr-#        salary
hr-#   FROM employees
hr-#  WHERE department_id = 5 AND
hr-#        NOT salary > 5000
hr-#  ORDER BY salary;
```

**Output 2**
```console
 employee_id | first_name |  last_name  | salary
-------------+------------+-------------+---------
         126 | Irene      | Mikkilineni | 2700.00
         193 | Britney    | Everett     | 3900.00
         192 | Sarah      | Bell        | 4000.00
(3 rows)
```
