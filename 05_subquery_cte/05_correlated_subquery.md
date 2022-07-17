# Correlated Subquery

In the examples shown so far, the subquery is first evaluated and then the table resulting from that evaluation is used as input to the main query. SQL also allows **subqueries to be evaluated multiple times, once for each record accessed by the main query**. Such subqueries are called **correlated subqueries**.

In this lesson, you will learn about the SQL correlated subquery which is a **subquery that uses values from the outer query**.

## Introduction to SQL correlated subquery

Let’s start with an example.

See the following `employees` table in the `hr` sample database:

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
    "employees_fkey_job" FOREIGN KEY (job_id) REFERENCES jobs(job_id) ON UPDATE CASCADE ON DELETE CASCADE
    "employees_fkey_manager" FOREIGN KEY (manager_id) REFERENCES employees(employee_id) ON UPDATE CASCADE ON DELETE CASCADE
Referenced by:
    TABLE "dependents" CONSTRAINT "dependents_fkey_employee" FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON UPDATE CASCADE ON DELETE CASCADE
    TABLE "employees" CONSTRAINT "employees_fkey_manager" FOREIGN KEY (manager_id) REFERENCES employees(employee_id) ON UPDATE CASCADE ON DELETE CASCADE
```

The following query finds `employees whose salary is greater than the average salary of all employees`:

```SQL
SELECT employee_id,
       first_name,
       last_name,
       salary
  FROM employees
 WHERE salary > (SELECT AVG(salary)
                   FROM employees);
```

**Results**

|employee_id | first_name | last_name  |  salary|
|:----------:|:----------:|:----------:|:-------:|
|        100 | Steven     | King       | 24000.00|
|        101 | Neena      | Kochhar    | 17000.00|
|        102 | Lex        | De Haan    | 17000.00|
|        103 | Alexander  | Hunold     |  9000.00|
|        108 | Nancy      | Greenberg  | 12000.00|
|        109 | Daniel     | Faviet     |  9000.00|
|        110 | John       | Chen       |  8200.00|
|        114 | Den        | Raphaely   | 11000.00|
|        121 | Adam       | Fripp      |  8200.00|
|        145 | John       | Russell    | 14000.00|
|        146 | Karen      | Partners   | 13500.00|
|        176 | Jonathon   | Taylor     |  8600.00|
|        177 | Jack       | Livingston |  8400.00|
|        201 | Michael    | Hartstein  | 13000.00|
|        204 | Hermann    | Baer       | 10000.00|
|        205 | Shelley    | Higgins    | 12000.00|
|        206 | William    | Gietz      |  8300.00|

In this example, the subquery is used in the `WHERE` clause. There are some points that you can see from this query:

1. First, you can execute the **subquery that returns the average salary of all employees independently**.

```SQL
SELECT AVG(salary)
  FROM employees;
```

**Results**

|avg|
|:-------------------:|
|8060.0000000000000000|

2. Second, the **database system needs to evaluate the subquery only once**.

3. Third, the outer query **makes use of the result returned from the subquery. The outer query depends on the subquery for its value**. However, **the subquery does not depend on the outer query**. Sometimes, we call this subquery is a `plain subquery`.

Unlike a plain subquery, a **correlated subquery** is a **subquery that uses the values from the outer query**. Also, a correlated subquery `may be evaluated once for each row selected by the outer query`. Because of this, a query that uses a correlated subquery may be slow.

A correlated subquery is also known as a `repeating subquery` or a `synchronized subquery`.

## SQL correlated subquery examples

Let’s see few more examples of the correlated subqueries to understand them better.

## SQL correlated subquery in the WHERE clause example

**Problem**: `finds all employees whose salary is higher than the average salary of the employees in their departments`.

First let's find the average salary of the employees in each department.

```SQL
SELECT department_id,
       ROUND(AVG(salary),2) avg_salary
  FROM employees
 GROUP BY department_id
 ORDER BY department_id;
```

**Results**

|department_id | avg_salary|
|:------------:|:---------:|
|            1 |    4400.00|
|            2 |    9500.00|
|            3 |    4150.00|
|            4 |    6500.00|
|            5 |    5885.71|
|            6 |    5760.00|
|            7 |   10000.00|
|            8 |    9616.67|
|            9 |   19333.33|
|           10 |    8600.00|
|           11 |   10150.00|

Suppose we want to list all employees in department_id `10` whose salary is higher than the average salary of the department.

```SQL
SELECT employee_id,
       first_name,
       last_name,
       salary
  FROM employees
 WHERE department_id = 10 AND
       salary > (SELECT AVG(salary)
                   FROM employees
                  WHERE department_id = 10);
```

**Results**

|employee_id | first_name | last_name |  salary|
|:-----------:|:---------:|:---------:|:-------:|
|        108 | Nancy      | Greenberg | 12000.00|
|        109 | Daniel     | Faviet    |  9000.00|

Similarly, if we want to list all employees in department_id `11` whose salary is higher than the average salary of the department, we could try this query:

```SQL
SELECT employee_id,
       first_name,
       last_name,
       salary
  FROM employees
 WHERE department_id = 11 AND
       salary > (SELECT AVG(salary)
                   FROM employees
                  WHERE department_id = 11);
```

**Results**

|employee_id | first_name | last_name |  salary|
|:----------:|:----------:|:---------:|:-------:|
|        205 | Shelley    | Higgins   | 12000.00|

In the previous queries the dbms is comparing the salary of each employee to a single value. What if we wanted to compare the salary of each employee on the basis of the `department_id` value.

For each employee, the database system has to execute the correlated subquery once to calculate the average salary of the employees in the department of the current employee and then compare the salary of the current employee.

```SQL
SELECT employee_id,
       first_name,
       last_name,
       salary,
       department_id
  FROM employees e
 WHERE salary > (SELECT AVG(salary)
                   FROM employees
                  WHERE department_id = e.department_id)
 ORDER BY department_id,
          first_name,
          last_name;
```

Unlike the earlier examples, the paranthesized subquery here is not executed just once. Instead, **this subquery is executed once for each record in the employees table indicated in the outer query**.

For **each** execution, the value of the `department_id` field from a record in `employees` is compared with the value of `department_id` field from *every* record in `employees` table in the subquery (via the condition `department_id = e.department_id` in the subquery `WHERE` clause).

Next, the aggregate function `AVG` computes the average salary only for the records with the `department_id` equaled to the `department_id` of the record in the outer query.

Finally, the salary of the current employee is compared to the average salary.


**Results**

|employee_id | first_name | last_name |  salary  | department_id|
|:-----------:|:----------:|:--------:|:---------:|:--------------:|
|         201 | Michael    | Hartstein | 13000.00 |             2|
|         114 | Den        | Raphaely  | 11000.00 |             3|
|         121 | Adam       | Fripp     |  8200.00 |             5|
|         120 | Matthew    | Weiss     |  8000.00 |             5|
|         122 | Payam      | Kaufling  |  7900.00 |             5|
|         123 | Shanta     | Vollman   |  6500.00 |             5|
|         103 | Alexander  | Hunold    |  9000.00 |             6|
|         104 | Bruce      | Ernst     |  6000.00 |             6|
|         145 | John       | Russell   | 14000.00 |             8|
|         146 | Karen      | Partners  | 13500.00 |             8|
|         100 | Steven     | King      | 24000.00 |             9|
|         109 | Daniel     | Faviet    |  9000.00 |            10|
|         108 | Nancy      | Greenberg | 12000.00 |            10|
|         205 | Shelley    | Higgins   | 12000.00 |            11|

## SQL correlated subquery in the SELECT clause example

The following query returns the employees and the average salary of all employees in their departments:

```SQL
SELECT e.employee_id,
       e.first_name,
       e.last_name,
       d.department_name,
       e.salary,
       (SELECT ROUND(AVG(salary),0)
          FROM employees
         WHERE department_id = e.department_id) avg_salary_in_department
  FROM employees e
 INNER JOIN departments d ON d.department_id = e.department_id
 ORDER BY department_name,
          first_name,
          last_name;
```

**Results**

|employee_id | first_name  |  last_name  | department_name  |  salary | avg_salary_in_department|
|:------------:|:------------:|:------------:|:-----------------:|:----------:|:-------------------------:|
|205 | Shelley | Higgins | Accounting | 12000.00 | **10150**|
|206 | William | Gietz   | Accounting |  8300.00 | **10150**|
|200 | Jennifer | Whalen | Administration |  4400.00 | **4400**|
|...|...|...|...|...|...|

For each employee, the database system has to execute the correlated subquery once to calculate the average salary by the employee’s department.
