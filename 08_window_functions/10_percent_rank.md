# PERCENT_RANK Function

The `PERCENT_RANK()` is a window function that calculates** the percentile ranking of rows in a result set**.

The syntax of the `PERCENT_RANK()` function is as follows:

```SQL
PERCENT_RANK()  
    OVER (
        PARTITION BY expr1, expr2,...
        ORDER BY expr1 [ASC|DESC], expr2 ...
    )
```

The `PERCENT_RANK()` function returns a percentile ranking number which ranges from zero to one.

For a specific row, `PERCENT_RANK()` uses the following formula to calculate the percentile rank:

```console
(rank - 1) / (total_rows - 1)
```

In this formula, `rank` is the **rank of the row**. `total_rows` is **the number of rows that are being evaluated**.

Based on this formula, the `PERCENT_RANK()` function always returns zero for the first row the result set.

The `PARTITION BY` clause divides the rows into partitions and the `ORDER BY` clause specifies the logical order of rows for each partition. The `PERCENT_RANK()` function is calculated for each ordered partition independently.

The `PARTITION BY` clause is optional. If you omit the `PARTITION BY` clause, the function treats the whole result set as a single partition.

## SQL PERCENT_RANK() function examples

We will use the `employees` and `departments` tables from the `hr` sample database for the demonstration.

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

## Using SQL PERCENT_RANK() over the query result set example

The following query finds the **percentile ranks of employees by their salaries**:

```SQL
SELECT first_name,
       last_name,
       salary,
       ROUND(CAST (PERCENT_RANK()
             OVER (ORDER BY salary) AS numeric)
       ,2) percentile_rank
  FROM employees;
```

In this example, we omitted the `PARTITION BY` clause so the function treated the whole employees in the result set as a single partition. Notice that we used the `ROUND()` function to round the percentile rankings to two decimal places.

**ResultS**

|first_name  |  last_name  |  salary  | percentile_rank|
|:----------:|:-----------:|:--------:|:---------------:|
|Karen       | Colmenares  |  2500.00 |            0.00|
|Guy         | Himuro      |  2600.00 |            0.03|
|Irene       | Mikkilineni |  2700.00 |            0.05|
|Sigal       | Tobias      |  2800.00 |            0.08|
|Shelli      | Baida       |  2900.00 |            0.10|
|Alexander   | Khoo        |  3100.00 |            0.13|
|Britney     | Everett     |  3900.00 |            0.15|
|Sarah       | Bell        |  4000.00 |            0.18|
|Diana       | Lorentz     |  4200.00 |            0.21|
|Jennifer    | Whalen      |  4400.00 |            0.23|
|David       | Austin      |  4800.00 |            0.26|
|Valli       | Pataballa   |  4800.00 |            0.26|
|Pat         | Fay         |  6000.00 |            0.31|
|Bruce       | Ernst       |  6000.00 |            0.31|
|Charles     | Johnson     |  6200.00 |            0.36|
|Susan       | Mavris      |  6500.00 |            0.38|
|Shanta      | Vollman     |  6500.00 |            0.38|
|Luis        | Popp        |  6900.00 |            0.44|
|Kimberely   | Grant       |  7000.00 |            0.46|
|Ismael      | Sciarra     |  7700.00 |            0.49|
|Jose Manuel | Urman       |  7800.00 |            0.51|
|Payam       | Kaufling    |  7900.00 |            0.54|
|Matthew     | Weiss       |  8000.00 |            0.56|
|Adam        | Fripp       |  8200.00 |            0.59|
|John        | Chen        |  8200.00 |            0.59|
|William     | Gietz       |  8300.00 |            0.64|
|Jack        | Livingston  |  8400.00 |            0.67|
|Jonathon    | Taylor      |  8600.00 |            0.69|
|Daniel      | Faviet      |  9000.00 |            0.72|
|Alexander   | Hunold      |  9000.00 |            0.72|
|Hermann     | Baer        | 10000.00 |            0.77|
|Den         | Raphaely    | 11000.00 |            0.79|
|Nancy       | Greenberg   | 12000.00 |            0.82|
|Shelley     | Higgins     | 12000.00 |            0.82|
|Michael     | Hartstein   | 13000.00 |            0.87|
|Karen       | Partners    | 13500.00 |            0.90|
|John        | Russell     | 14000.00 |            0.92|
|Neena       | Kochhar     | 17000.00 |            0.95|
|Lex         | De Haan     | 17000.00 |            0.95|
|Steven      | King        | 24000.00 |            1.00|

The `ORDER BY` clause sorted the salaries of employees and the `PERCENT_RANK()` function calculated the percentile ranking of employees by salaries in ascending order.

Let’s analyze some rows in the output.

- Karen has the lowest salary which is not greater than anyone so her percentile ranking is zero. On the other hand, Steven has the highest salary which is higher than anyone, therefore, his percentile ranking is 1 or 100%.
- Nancy and Shelley have the percentile ranking of 82% which means their salary is higher than 82% all other employees.

## Using SQL PERCENT_RANK() over partition example

The following statement returns the percentile ranking of employees **by their salaries per department**:

```SQL
SELECT first_name,
       last_name,
       salary,
       department_name,
       ROUND(CAST (PERCENT_RANK()
             OVER (PARTITION BY e.department_id
                   ORDER BY salary) AS numeric)
       ,2) percentile_rank
  FROM employees e
 INNER JOIN departments d
    ON d.department_id = e.department_id;
```

**Results**

|first_name  |  last_name  |  salary  | department_name  | percentile_rank|
|:----------:|:-----------:|:--------:|:----------------:|:---------------:|
|Jennifer    | Whalen      |  4400.00 | Administration   |            0.00|
|Pat         | Fay         |  6000.00 | Marketing        |            0.00|
|Michael     | Hartstein   | 13000.00 | Marketing        |            1.00|
|Karen       | Colmenares  |  2500.00 | Purchasing       |            0.00|
|Guy         | Himuro      |  2600.00 | Purchasing       |            0.20|
|Sigal       | Tobias      |  2800.00 | Purchasing       |            0.40|
|Shelli      | Baida       |  2900.00 | Purchasing       |            0.60|
|Alexander   | Khoo        |  3100.00 | Purchasing       |            0.80|
|Den         | Raphaely    | 11000.00 | Purchasing       |            1.00|
|Susan       | Mavris      |  6500.00 | Human Resources  |            0.00|
|Irene       | Mikkilineni |  2700.00 | Shipping         |            0.00|
|Britney     | Everett     |  3900.00 | Shipping         |            0.17|
|Sarah       | Bell        |  4000.00 | Shipping         |            0.33|
|Shanta      | Vollman     |  6500.00 | Shipping         |            0.50|
|Payam       | Kaufling    |  7900.00 | Shipping         |            0.67|
|Matthew     | Weiss       |  8000.00 | Shipping         |            0.83|
|Adam        | Fripp       |  8200.00 | Shipping         |            1.00|
|Diana       | Lorentz     |  4200.00 | IT               |            0.00|
|Valli       | Pataballa   |  4800.00 | IT               |            0.25|
|David       | Austin      |  4800.00 | IT               |            0.25|
|Bruce       | Ernst       |  6000.00 | IT               |            0.75|
|Alexander   | Hunold      |  9000.00 | IT               |            1.00|
|Hermann     | Baer        | 10000.00 | Public Relations |            0.00|
|Charles     | Johnson     |  6200.00 | Sales            |            0.00|
|Kimberely   | Grant       |  7000.00 | Sales            |            0.20|
|Jack        | Livingston  |  8400.00 | Sales            |            0.40|
|Jonathon    | Taylor      |  8600.00 | Sales            |            0.60|
|Karen       | Partners    | 13500.00 | Sales            |            0.80|
|John        | Russell     | 14000.00 | Sales            |            1.00|
|Neena       | Kochhar     | 17000.00 | Executive        |            0.00|
|Lex         | De Haan     | 17000.00 | Executive        |            0.00|
|Steven      | King        | 24000.00 | Executive        |            1.00|
|Luis        | Popp        |  6900.00 | Finance          |            0.00|
|Ismael      | Sciarra     |  7700.00 | Finance          |            0.20|
|Jose Manuel | Urman       |  7800.00 | Finance          |            0.40|
|John        | Chen        |  8200.00 | Finance          |            0.60|
|Daniel      | Faviet      |  9000.00 | Finance          |            0.80|
|Nancy       | Greenberg   | 12000.00 | Finance          |            1.00|
|William     | Gietz       |  8300.00 | Accounting       |            0.00|
|Shelley     | Higgins     | 12000.00 | Accounting       |            1.00|

In this example, we divided the employees by department names. The `PERCENT_RANK()` then applied to each partition.

As clearly shown in the output, the percentile ranking was reset whenever the department changed.
