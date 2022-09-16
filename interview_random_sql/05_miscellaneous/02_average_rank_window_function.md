# Average and rank with a window function

Say we have a table `employees` with data on employee salary and department in the following format:

```console
hr-# \d employees
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

The records in this table are:

```SQL
SELECT department_id
     , employee_id
     , first_name
     , last_name
     , salary
  FROM employees
 ORDER BY department_id, salary DESC;
```

```console
department_id | employee_id | first_name  |  last_name  |  salary
---------------+-------------+-------------+-------------+----------
            1 |         200 | Jennifer    | Whalen      |  4400.00
            2 |         201 | Michael     | Hartstein   | 13000.00
            2 |         202 | Pat         | Fay         |  6000.00
            3 |         114 | Den         | Raphaely    | 11000.00
            3 |         115 | Alexander   | Khoo        |  3100.00
            3 |         116 | Shelli      | Baida       |  2900.00
            3 |         117 | Sigal       | Tobias      |  2800.00
            3 |         118 | Guy         | Himuro      |  2600.00
            3 |         119 | Karen       | Colmenares  |  2500.00
            4 |         203 | Susan       | Mavris      |  6500.00
            5 |         121 | Adam        | Fripp       |  8200.00
            5 |         120 | Matthew     | Weiss       |  8000.00
            5 |         122 | Payam       | Kaufling    |  7900.00
            5 |         123 | Shanta      | Vollman     |  6500.00
            5 |         192 | Sarah       | Bell        |  4000.00
            5 |         193 | Britney     | Everett     |  3900.00
            5 |         126 | Irene       | Mikkilineni |  2700.00
            6 |         103 | Alexander   | Hunold      |  9000.00
            6 |         104 | Bruce       | Ernst       |  6000.00
            6 |         106 | Valli       | Pataballa   |  4800.00
            6 |         105 | David       | Austin      |  4800.00
            6 |         107 | Diana       | Lorentz     |  4200.00
            7 |         204 | Hermann     | Baer        | 10000.00
            8 |         145 | John        | Russell     | 14000.00
            8 |         146 | Karen       | Partners    | 13500.00
            8 |         176 | Jonathon    | Taylor      |  8600.00
            8 |         177 | Jack        | Livingston  |  8400.00
            8 |         178 | Kimberely   | Grant       |  7000.00
            8 |         179 | Charles     | Johnson     |  6200.00
            9 |         100 | Steven      | King        | 24000.00
            9 |         102 | Lex         | De Haan     | 17000.00
            9 |         101 | Neena       | Kochhar     | 17000.00
           10 |         108 | Nancy       | Greenberg   | 12000.00
           10 |         109 | Daniel      | Faviet      |  9000.00
           10 |         110 | John        | Chen        |  8200.00
           10 |         112 | Jose Manuel | Urman       |  7800.00
           10 |         111 | Ismael      | Sciarra     |  7700.00
           10 |         113 | Luis        | Popp        |  6900.00
           11 |         205 | Shelley     | Higgins     | 12000.00
           11 |         206 | William     | Gietz       |  8300.00
(40 rows)
```

## Problem

Write a query that returns the same table, but with a new column that has average salary per `department_id`. We would expect a table in the form:

```console
department_id | employee_id | first_name  |  last_name  |  salary  | sal_avg
---------------+-------------+-------------+-------------+----------+----------
            1 |         200 | Jennifer    | Whalen      |  4400.00 |  4400.00
            2 |         201 | Michael     | Hartstein   | 13000.00 |  9500.00
            2 |         202 | Pat         | Fay         |  6000.00 |  9500.00
            3 |         114 | Den         | Raphaely    | 11000.00 |  4150.00
            3 |         115 | Alexander   | Khoo        |  3100.00 |  4150.00
            3 |         116 | Shelli      | Baida       |  2900.00 |  4150.00
            3 |         117 | Sigal       | Tobias      |  2800.00 |  4150.00
            3 |         118 | Guy         | Himuro      |  2600.00 |  4150.00
            3 |         119 | Karen       | Colmenares  |  2500.00 |  4150.00
            4 |         203 | Susan       | Mavris      |  6500.00 |  6500.00
            5 |         121 | Adam        | Fripp       |  8200.00 |  5885.71
            5 |         120 | Matthew     | Weiss       |  8000.00 |  5885.71
            5 |         122 | Payam       | Kaufling    |  7900.00 |  5885.71
            5 |         123 | Shanta      | Vollman     |  6500.00 |  5885.71
            5 |         192 | Sarah       | Bell        |  4000.00 |  5885.71
            5 |         193 | Britney     | Everett     |  3900.00 |  5885.71
            5 |         126 | Irene       | Mikkilineni |  2700.00 |  5885.71
            6 |         103 | Alexander   | Hunold      |  9000.00 |  5760.00
            6 |         104 | Bruce       | Ernst       |  6000.00 |  5760.00
            6 |         106 | Valli       | Pataballa   |  4800.00 |  5760.00
            6 |         105 | David       | Austin      |  4800.00 |  5760.00
            6 |         107 | Diana       | Lorentz     |  4200.00 |  5760.00
            7 |         204 | Hermann     | Baer        | 10000.00 | 10000.00
            8 |         145 | John        | Russell     | 14000.00 |  9616.67
            8 |         146 | Karen       | Partners    | 13500.00 |  9616.67
            8 |         176 | Jonathon    | Taylor      |  8600.00 |  9616.67
            8 |         177 | Jack        | Livingston  |  8400.00 |  9616.67
            8 |         178 | Kimberely   | Grant       |  7000.00 |  9616.67
            8 |         179 | Charles     | Johnson     |  6200.00 |  9616.67
            9 |         100 | Steven      | King        | 24000.00 | 19333.33
            9 |         102 | Lex         | De Haan     | 17000.00 | 19333.33
            9 |         101 | Neena       | Kochhar     | 17000.00 | 19333.33
           10 |         108 | Nancy       | Greenberg   | 12000.00 |  8600.00
           10 |         109 | Daniel      | Faviet      |  9000.00 |  8600.00
           10 |         110 | John        | Chen        |  8200.00 |  8600.00
           10 |         112 | Jose Manuel | Urman       |  7800.00 |  8600.00
           10 |         111 | Ismael      | Sciarra     |  7700.00 |  8600.00
           10 |         113 | Luis        | Popp        |  6900.00 |  8600.00
           11 |         205 | Shelley     | Higgins     | 12000.00 | 10150.00
           11 |         206 | William     | Gietz       |  8300.00 | 10150.00
(40 rows)
```

### Problem 2

Write a query that adds a column with the rank of each employee based on their salary within their department, where the employee with the highest salary gets the rank of 1. We would expect a table in the form:

```console
department_id | employee_id | first_name  |  last_name  |  salary  | dense_rank
--------------+-------------+-------------+-------------+----------+------------
            1 |         200 | Jennifer    | Whalen      |  4400.00 |          1
            --------------------------------------------------------------------
            2 |         201 | Michael     | Hartstein   | 13000.00 |          1
            2 |         202 | Pat         | Fay         |  6000.00 |          2
            --------------------------------------------------------------------
            3 |         114 | Den         | Raphaely    | 11000.00 |          1
            3 |         115 | Alexander   | Khoo        |  3100.00 |          2
            3 |         116 | Shelli      | Baida       |  2900.00 |          3
            3 |         117 | Sigal       | Tobias      |  2800.00 |          4
            3 |         118 | Guy         | Himuro      |  2600.00 |          5
            3 |         119 | Karen       | Colmenares  |  2500.00 |          6
            --------------------------------------------------------------------
            4 |         203 | Susan       | Mavris      |  6500.00 |          1
            --------------------------------------------------------------------
            5 |         121 | Adam        | Fripp       |  8200.00 |          1
            5 |         120 | Matthew     | Weiss       |  8000.00 |          2
            5 |         122 | Payam       | Kaufling    |  7900.00 |          3
            5 |         123 | Shanta      | Vollman     |  6500.00 |          4
            5 |         192 | Sarah       | Bell        |  4000.00 |          5
            5 |         193 | Britney     | Everett     |  3900.00 |          6
            5 |         126 | Irene       | Mikkilineni |  2700.00 |          7
            -------------------------------------------------------------------
            6 |         103 | Alexander   | Hunold      |  9000.00 |          1
            6 |         104 | Bruce       | Ernst       |  6000.00 |          2
            6 |         106 | Valli       | Pataballa   |  4800.00 |          3
            6 |         105 | David       | Austin      |  4800.00 |          3
            6 |         107 | Diana       | Lorentz     |  4200.00 |          4
            -------------------------------------------------------------------
            7 |         204 | Hermann     | Baer        | 10000.00 |          1
            --------------------------------------------------------------------
            8 |         145 | John        | Russell     | 14000.00 |          1
            8 |         146 | Karen       | Partners    | 13500.00 |          2
            8 |         176 | Jonathon    | Taylor      |  8600.00 |          3
            8 |         177 | Jack        | Livingston  |  8400.00 |          4
            8 |         178 | Kimberely   | Grant       |  7000.00 |          5
            8 |         179 | Charles     | Johnson     |  6200.00 |          6
            --------------------------------------------------------------------
            9 |         100 | Steven      | King        | 24000.00 |          1
            9 |         102 | Lex         | De Haan     | 17000.00 |          2
            9 |         101 | Neena       | Kochhar     | 17000.00 |          2
            --------------------------------------------------------------------
           10 |         108 | Nancy       | Greenberg   | 12000.00 |          1
           10 |         109 | Daniel      | Faviet      |  9000.00 |          2
           10 |         110 | John        | Chen        |  8200.00 |          3
           10 |         112 | Jose Manuel | Urman       |  7800.00 |          4
           10 |         111 | Ismael      | Sciarra     |  7700.00 |          5
           10 |         113 | Luis        | Popp        |  6900.00 |          6
           ---------------------------------------------------------------------
           11 |         205 | Shelley     | Higgins     | 12000.00 |          1
           11 |         206 | William     | Gietz       |  8300.00 |          2
(40 rows)
```

## Solution

```SQL
SELECT department_id
     , employee_id
     , first_name
     , last_name
     , salary
     , ROUND(AVG(salary) OVER (PARTITION BY department_id),2) AS sal_avg
  FROM employees
 ORDER BY department_id, salary DESC;
```

### Problem 2

```SQL
SELECT department_id
     , employee_id
     , first_name
     , last_name
     , salary
     , DENSE_RANK() OVER (PARTITION BY department_id
                              ORDER BY salary DESC)
  FROM employees
 ORDER BY department_id, salary DESC;
```

## Discussion Problem 2

The use of the `RANK()` function is not correct:


```SQL
SELECT department_id
     , employee_id
     , first_name
     , last_name
     , salary
     , RANK() OVER (PARTITION BY department_id
                        ORDER BY salary DESC)
  FROM employees
 WHERE department_id = 6
 ORDER BY department_id, salary DESC;
```

```console
department_id | employee_id | first_name | last_name | salary  | rank
--------------+-------------+------------+-----------+---------+------
            6 |         103 | Alexander  | Hunold    | 9000.00 |    1
            6 |         104 | Bruce      | Ernst     | 6000.00 |    2
            6 |         105 | David      | Austin    | 4800.00 |    3
            6 |         106 | Valli      | Pataballa | 4800.00 |    3
            6 |         107 | Diana      | Lorentz   | 4200.00 |    5 ? <--- 4
(5 rows)
```

```SQL
SELECT department_id
     , employee_id
     , first_name
     , last_name
     , salary
     , DENSE_RANK() OVER (PARTITION BY department_id
                        ORDER BY salary DESC)
  FROM employees
 WHERE department_id = 6
 ORDER BY department_id, salary DESC;
```

```console
department_id | employee_id | first_name | last_name | salary  | dense_rank
--------------+-------------+------------+-----------+---------+------------
            6 |         103 | Alexander  | Hunold    | 9000.00 |          1
            6 |         104 | Bruce      | Ernst     | 6000.00 |          2
            6 |         105 | David      | Austin    | 4800.00 |          3
            6 |         106 | Valli      | Pataballa | 4800.00 |          3
            6 |         107 | Diana      | Lorentz   | 4200.00 |          4
(5 rows)
```
