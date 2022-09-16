# Get the ID with the highest value

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
SELECT employee_id
     , first_name
     , last_name
     , salary
  FROM employees
 ORDER BY salary DESC;
```

```console
employee_id | first_name  |  last_name  |  salary
-------------+-------------+-------------+----------
        100 | Steven      | King        | 24000.00
        101 | Neena       | Kochhar     | 17000.00 <---
        102 | Lex         | De Haan     | 17000.00 <---
        145 | John        | Russell     | 14000.00
        146 | Karen       | Partners    | 13500.00
        201 | Michael     | Hartstein   | 13000.00
        205 | Shelley     | Higgins     | 12000.00
        108 | Nancy       | Greenberg   | 12000.00
        114 | Den         | Raphaely    | 11000.00
        204 | Hermann     | Baer        | 10000.00
        103 | Alexander   | Hunold      |  9000.00
        109 | Daniel      | Faviet      |  9000.00
        176 | Jonathon    | Taylor      |  8600.00
        177 | Jack        | Livingston  |  8400.00
        206 | William     | Gietz       |  8300.00
        110 | John        | Chen        |  8200.00
        121 | Adam        | Fripp       |  8200.00
        120 | Matthew     | Weiss       |  8000.00
        122 | Payam       | Kaufling    |  7900.00
        112 | Jose Manuel | Urman       |  7800.00
        111 | Ismael      | Sciarra     |  7700.00
        178 | Kimberely   | Grant       |  7000.00
        113 | Luis        | Popp        |  6900.00
        203 | Susan       | Mavris      |  6500.00
        123 | Shanta      | Vollman     |  6500.00
        179 | Charles     | Johnson     |  6200.00
        104 | Bruce       | Ernst       |  6000.00
        202 | Pat         | Fay         |  6000.00
        105 | David       | Austin      |  4800.00
        106 | Valli       | Pataballa   |  4800.00
        200 | Jennifer    | Whalen      |  4400.00
        107 | Diana       | Lorentz     |  4200.00
        192 | Sarah       | Bell        |  4000.00
        193 | Britney     | Everett     |  3900.00
        115 | Alexander   | Khoo        |  3100.00
        116 | Shelli      | Baida       |  2900.00
        117 | Sigal       | Tobias      |  2800.00
        126 | Irene       | Mikkilineni |  2700.00
        118 | Guy         | Himuro      |  2600.00
        119 | Karen       | Colmenares  |  2500.00
(40 rows)
```

## Problem

Write a query to get the employee_id with the second highest salary. Make sure your solution can handle ties!

```console
employee_id
-------------
        101
        102
(2 rows)
```


## Solution

```SQL
WITH secondSal AS (
  SELECT DISTINCT salary AS sal2
    FROM employees
   ORDER BY salary DESC
  OFFSET 1
  FETCH FIRST 1 ROWS ONLY
)
SELECT employee_id
  FROM employees
 WHERE salary = (SELECT sal2 FROM secondSal);
```

- **Solution 2 Using JOIN**:


```SQL
WITH secondSal AS (
  SELECT DISTINCT salary AS sal2
    FROM employees
   ORDER BY salary DESC
  OFFSET 1
  FETCH FIRST 1 ROWS ONLY
)
SELECT employee_id
  FROM employees e
  JOIN secondSal s
    ON e.salary = s.sal2;
```

- **Solution 3 Using DENSE RANK**:

```SQL
WITH rank_sal AS (
  SELECT  DENSE_RANK() OVER(ORDER BY salary DESC) AS rk_sal
        , employee_id
    FROM employees
)
SELECT employee_id
  FROM rank_sal
 WHERE rk_sal = 2;
```

## Discussion


First we find the second highest salary.

```SQL
WITH secondSal AS (
  SELECT DISTINCT salary AS sal2
    FROM employees
   ORDER BY salary DESC
  OFFSET 1
  FETCH FIRST 1 ROWS ONLY
)
SELECT *
  FROM secondSal;
```

```console
sal2
----------
17000.00
(1 row)
```

Next, select all rows with the second salary:

```SQL
WITH secondSal AS (
  SELECT DISTINCT salary AS sal2
    FROM employees
   ORDER BY salary DESC
  OFFSET 1
  FETCH FIRST 1 ROWS ONLY
)
SELECT employee_id
  FROM employees
 WHERE salary = (SELECT sal2 FROM secondSal);
```

- **Solution 2 Using JOIN**:


```SQL
WITH secondSal AS (
  SELECT DISTINCT salary AS sal2
    FROM employees
   ORDER BY salary DESC
  OFFSET 1
  FETCH FIRST 1 ROWS ONLY
)
SELECT employee_id
  FROM employees e
  JOIN secondSal s
    ON e.salary = s.sal2;
```

- **Solution 3 Using RANK**:

```SQL
WITH rank_sal AS (
  SELECT  DENSE_RANK() OVER(ORDER BY salary DESC) AS rk_sal
        , employee_id
    FROM employees
)
SELECT employee_id
  FROM rank_sal
 WHERE rk_sal = 2;
```

The `DENSE_RANK()` assigns a rank to every row in each partition of a result set. Different from the `RANK()` function, the `DENSE_RANK()` **function always returns consecutive rank values**.

For each partition, the `DENSE_RANK()` function returns the same rank for the rows which have the same values.
