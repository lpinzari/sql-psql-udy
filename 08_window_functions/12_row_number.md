# ROW_NUMBER Function

The `ROW_NUMBER()` is a window function that **assigns a sequential integer number to each row in the query’s result set**.

The following illustrates the syntax of the `ROW_NUMBER()` function:

```SQL
ROW_NUMBER() OVER (
    [PARTITION BY expr1, expr2,...]
    ORDER BY expr1 [ASC | DESC], expr2,...
)
```

In this syntax,

- First, the `PARTITION BY` clause divides the result set returned from the FROM clause into partitions. The `PARTITION BY` clause is optional. If you omit it, the whole result set is treated as a single partition.
- Then, the `ORDER BY` clause sorts the rows in each partition. Because the ROW_NUMBER() is an order sensitive function, the ORDER BY clause is required.
- Finally, each row **in each partition is assigned a sequential integer number called a row number**. The **row number is reset whenever the partition boundary is crossed**.

We will use the `employees` and `departments` table from the `hr` sample database for the demonstration.

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

**departments**

```console
hr=# \d departments
                                             Table "public.departments"
     Column      |         Type          | Collation | Nullable |                      Default
-----------------+-----------------------+-----------+----------+----------------------------------------------------
 department_id   | integer               |           | not null | nextval('departments_department_id_seq'::regclass)
 department_name | character varying(30) |           | not null |
 location_id     | integer               |           |          |
```

## Simple SQL ROW_NUMBER() example

The following statement finds the first name, last name, and salary of all employees. In addition, it uses the `ROW_NUMBER()` function to add sequential integer number to each row.

```SQL
SELECT ROW_NUMBER()
       OVER (ORDER BY salary
       ) row_num,
       first_name,
       last_name,
       salary
  FROM employees;
```

**Results**

|row_num | first_name  |  last_name  |  salary|
|:------:|:-----------:|:-----------:|:--------:|
|      1 | Karen       | Colmenares  |  2500.00|
|      2 | Guy         | Himuro      |  2600.00|
|      3 | Irene       | Mikkilineni |  2700.00|
|      4 | Sigal       | Tobias      |  2800.00|
|      5 | Shelli      | Baida       |  2900.00|
|      6 | Alexander   | Khoo        |  3100.00|
|      7 | Britney     | Everett     |  3900.00|
|      8 | Sarah       | Bell        |  4000.00|
|      9 | Diana       | Lorentz     |  4200.00|
|     10 | Jennifer    | Whalen      |  4400.00|
|     11 | David       | Austin      |  4800.00|
|     12 | Valli       | Pataballa   |  4800.00|
|     13 | Pat         | Fay         |  6000.00|
|     14 | Bruce       | Ernst       |  6000.00|
|     15 | Charles     | Johnson     |  6200.00|
|     16 | Susan       | Mavris      |  6500.00|
|     17 | Shanta      | Vollman     |  6500.00|
|     18 | Luis        | Popp        |  6900.00|
|     19 | Kimberely   | Grant       |  7000.00|
|     20 | Ismael      | Sciarra     |  7700.00|
|     21 | Jose Manuel | Urman       |  7800.00|
|     22 | Payam       | Kaufling    |  7900.00|
|     23 | Matthew     | Weiss       |  8000.00|
|     24 | Adam        | Fripp       |  8200.00|
|     25 | John        | Chen        |  8200.00|
|     26 | William     | Gietz       |  8300.00|
|     27 | Jack        | Livingston  |  8400.00|
|     28 | Jonathon    | Taylor      |  8600.00|
|     29 | Daniel      | Faviet      |  9000.00|
|     30 | Alexander   | Hunold      |  9000.00|
|     31 | Hermann     | Baer        | 10000.00|
|     32 | Den         | Raphaely    | 11000.00|
|     33 | Nancy       | Greenberg   | 12000.00|
|     34 | Shelley     | Higgins     | 12000.00|
|     35 | Michael     | Hartstein   | 13000.00|
|     36 | Karen       | Partners    | 13500.00|
|     37 | John        | Russell     | 14000.00|
|     38 | Neena       | Kochhar     | 17000.00|
|     39 | Lex         | De Haan     | 17000.00|
|     40 | Steven      | King        | 24000.00|

## Using SQL ROW_NUMBER() for pagination

The `ROW_NUMBER()` function can be used for **pagination**. For example, if you want to **display all employees on a table in an application by pages, which each page has ten records**.

- First, use the `ROW_NUMBER()` function to assign each row a sequential integer number.
- Second, `filter rows by requested page`. For example, the first page has the rows starting from one to 9, and the second page has the rows starting from 11 to 20, and so on.

The following statement returns the records of the second page, each page has ten records.

```SQL
-- pagination get page #2

SELECT *
  FROM (SELECT ROW_NUMBER()
               OVER (ORDER BY salary
               ) row_num,
               first_name,
               last_name,
               salary
          FROM employees
        ) t
 WHERE row_num > 10 AND row_num <=20;
```

**Results**

|row_num | first_name | last_name | salary|
|:------:|:-----------:|:--------:|:------:|
|     11 | David      | Austin    | 4800.00|
|     12 | Valli      | Pataballa | 4800.00|
|     13 | Pat        | Fay       | 6000.00|
|     14 | Bruce      | Ernst     | 6000.00|
|     15 | Charles    | Johnson   | 6200.00|
|     16 | Susan      | Mavris    | 6500.00|
|     17 | Shanta     | Vollman   | 6500.00|
|     18 | Luis       | Popp      | 6900.00|
|     19 | Kimberely  | Grant     | 7000.00|
|     20 | Ismael     | Sciarra   | 7700.00|

If you want to use the common table expression (CTE) instead of the subquery, here is the query:

```SQL
WITH t AS(
     SELECT ROW_NUMBER()
            OVER (ORDER BY salary
            ) row_num,
            first_name,
            last_name,
            salary
      FROM employees
)
SELECT *
  FROM t
 WHERE row_num > 10 AND
       row_num <=20;
```

## Using SQL ROW_NUMBER() for finding nth highest value per group

The following example shows you how to find the employees whose have the **highest salary in their departments**:

```SQL
-- find the highest salary per department
SELECT department_name,
       first_name,
       last_name,
       salary
  FROM (SELECT department_name,
               ROW_NUMBER()
               OVER (PARTITION BY department_name
                     ORDER BY salary DESC
               ) row_num,
               first_name,
               last_name,
               salary
          FROM employees e
         INNER JOIN departments d
            ON d.department_id = e.department_id
       ) t
WHERE row_num = 1;
```

In the **subquery**:

- First, the `PARTITION BY` clause distributes the employees by departments.
- Second, the `ORDER BY` clause sorts the employee in each department by salary in the descending order.
- Third, the `ROW_NUMBER()` assigns each row a sequential integer number. It resets the number when the department changes.

The following shows the result set of the **subquery**:

|department_name  | row_num | first_name  |  last_name  |  salary|
|:---------------:|:-------:|:-----------:|:-----------:|:-------:|
|**Accounting**       |       **1** | **Shelley**     | **Higgins**     | **12000.00**|
|Accounting       |       2 | William     | Gietz       |  8300.00|
|Administration   |       **1** | Jennifer    | Whalen      |  4400.00|
|Executive        |       **1** | Steven      | King        | 24000.00|
|Executive        |       2 | Neena       | Kochhar     | 17000.00|
|Executive        |       3 | Lex         | De Haan     | 17000.00|
|Finance          |       **1** | Nancy       | Greenberg   | 12000.00|
|Finance          |       2 | Daniel      | Faviet      |  9000.00|
|Finance          |       3 | John        | Chen        |  8200.00|
|Finance          |       4 | Jose Manuel | Urman       |  7800.00|
|Finance          |       5 | Ismael      | Sciarra     |  7700.00|
|Finance          |       6 | Luis        | Popp        |  6900.00|
|Human Resources  |       **1** | Susan       | Mavris      |  6500.00|
|IT               |       **1** | Alexander   | Hunold      |  9000.00|
|IT               |       2 | Bruce       | Ernst       |  6000.00|
|IT               |       3 | Valli       | Pataballa   |  4800.00|
|IT               |       4 | David       | Austin      |  4800.00|
|IT               |       5 | Diana       | Lorentz     |  4200.00|
|Marketing        |       **1** | Michael     | Hartstein   | 13000.00|
|Marketing        |       2 | Pat         | Fay         |  6000.00|
|Public Relations |       **1** | Hermann     | Baer        | 10000.00|
|Purchasing       |       **1** | Den         | Raphaely    | 11000.00|
|Purchasing       |       2 | Alexander   | Khoo        |  3100.00|
|Purchasing       |       3 | Shelli      | Baida       |  2900.00|
|Purchasing       |       4 | Sigal       | Tobias      |  2800.00|
|Purchasing       |       5 | Guy         | Himuro      |  2600.00|
|Purchasing       |       6 | Karen       | Colmenares  |  2500.00|
|Sales            |       **1** | John        | Russell     | 14000.00|
|Sales            |       2 | Karen       | Partners    | 13500.00|
|Sales            |       3 | Jonathon    | Taylor      |  8600.00|
|Sales            |       4 | Jack        | Livingston  |  8400.00|
|Sales            |       5 | Kimberely   | Grant       |  7000.00|
|Sales            |       6 | Charles     | Johnson     |  6200.00|
|Shipping         |       **1** | Adam        | Fripp       |  8200.00|
|Shipping         |       2 | Matthew     | Weiss       |  8000.00|
|Shipping         |       3 | Payam       | Kaufling    |  7900.00|
|Shipping         |       4 | Shanta      | Vollman     |  6500.00|
|Shipping         |       5 | Sarah       | Bell        |  4000.00|
|Shipping         |       6 | Britney     | Everett     |  3900.00|
|Shipping         |       7 | Irene       | Mikkilineni |  2700.00|

In the outer query, we selected only the employee rows which have the `row_num` with the value `1`.

Here is the output of the whole query:

**Results**

|department_name  | first_name | last_name |  salary|
|:---------------:|:----------:|:---------:|:--------:|
|Accounting       | Shelley    | Higgins   | 12000.00|
|Administration   | Jennifer   | Whalen    |  4400.00|
|Executive        | Steven     | King      | 24000.00|
|Finance          | Nancy      | Greenberg | 12000.00|
|Human Resources  | Susan      | Mavris    |  6500.00|
|IT               | Alexander  | Hunold    |  9000.00|
|Marketing        | Michael    | Hartstein | 13000.00|
|Public Relations | Hermann    | Baer      | 10000.00|
|Purchasing       | Den        | Raphaely  | 11000.00|
|Sales            | John       | Russell   | 14000.00|
|Shipping         | Adam       | Fripp     |  8200.00|

If you change the predicate in the WHERE clause from 1 to 2, 3, and so on, you will get the employees who have the second highest salary, third highest salary, and so on.
