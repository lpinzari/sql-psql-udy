# NTILE() Function

The `SQL NTILE()` is a window function that allows you to **break the result set into a specified number of approximately equal groups, or buckets**. It `assigns each group a bucket number starting from one`. For each row in a group, the NTILE() function assigns a **bucket number representing the group to which the row belongs**.

The syntax of the `NTILE()` function is as follows:

```SQL
NTILE(buckets) OVER (
	PARTITION BY expr1, expr2,...
	ORDER BY expr1 [ASC|DESC], expr2 ...
)
```

Let’s examine the syntax in detail:

### buckets

The **number of buckets**, which is a literal positive integer number or an expression that evaluates to `a positive integer number`.

### PARTITION BY

The `PARITITION BY` clause divides the result set returned from the `FROM` clause into partitions to which the `NTILE()` function is applied.

### ORDER BY

The `ORDER BY` clause specifies the order of rows in each partition to which the `NTILE()` is applied.

Notice that **if the number of rows is not divisible by buckets**, the `NTILE()` function results **in groups of two sizes with the difference by one**.

The `larger groups` always come before the `smaller group` in the order specified by the `ORDER BY` clause.

In case the total of **rows is divisible by buckets**, the rows are **divided evenly among groups**.

The following statement creates a new table named `t` that stores `10 integers` from one to ten:

```SQL
CREATE TABLE t (
   col INT NOT NULL
);

INSERT INTO t(col)
VALUES(1),(2),(3),(4),(5),(6),(7),(8),(9),(10);

SELECT * FROM t;
```

**Results**

|col|
|:---:|
|  1|
|  2|
|  3|
|  4|
|  5|
|  6|
|  7|
|  8|
|  9|
| 10|

If you use the `NTILE()` function to **divide ten rows into three groups**, you will have the `first group` with **four rows** and `other two groups` with **three rows**.

```SQL
SELECT col,
       NTILE (3)
       OVER (ORDER BY col
       ) buckets
  FROM t;
```

**Results**

|col | buckets|
|:--:|:-------:|
|  1 |       **1**|
|  2 |       **1**|
|  3 |       **1**|
|  4 |       **1**|
|  5 |       2|
|  6 |       2|
|  7 |       2|
|  8 |       3|
|  9 |       3|
| 10 |       3|

As clearly shown in the output, the first group has four rows while the other groups have three rows.

The following statement uses **two** instead of three buckets:

```SQL
SELECT col,
       NTILE (2)
       OVER (ORDER BY col
       ) buckets
  FROM t;
```

**Results**

|col | buckets|
|:---:|:------:|
|  1 |       1|
|  2 |       1|
|  3 |       1|
|  4 |       1|
|  5 |       1|
|  6 |       2|
|  7 |       2|
|  8 |       2|
|  9 |       2|
| 10 |       2|

Now, we have two groups which have the same number of rows.

## SQL NTILE() function examples

See the following `employees` table from the `hr` sample database:

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

## Using SQL NTILE() function over the result set example

The following statement uses the `NTILE()` function to **divide the employees into five buckets based on their salaries**:

```SQL
SELECT first_name,
       last_name,
       salary,
       NTILE(5)
       OVER (ORDER BY salary DESC
       ) salary_group
  FROM employees;
```

**Results**

|first_name  |  last_name  |  salary  | salary_group|
|:----------:|:-----------:|:--------:|:-----------:|
|Steven      | King        | 24000.00 |            1|
|Neena       | Kochhar     | 17000.00 |            1|
|Lex         | De Haan     | 17000.00 |            1|
|John        | Russell     | 14000.00 |            1|
|Karen       | Partners    | 13500.00 |            1|
|Michael     | Hartstein   | 13000.00 |            1|
|Shelley     | Higgins     | 12000.00 |            1|
|Nancy       | Greenberg   | 12000.00 |            1|
|Den         | Raphaely    | 11000.00 |            2|
|Hermann     | Baer        | 10000.00 |            2|
|Alexander   | Hunold      |  9000.00 |            2|
|Daniel      | Faviet      |  9000.00 |            2|
|Jonathon    | Taylor      |  8600.00 |            2|
|Jack        | Livingston  |  8400.00 |            2|
|William     | Gietz       |  8300.00 |            2|
|John        | Chen        |  8200.00 |            2|
|Adam        | Fripp       |  8200.00 |            3|
|Matthew     | Weiss       |  8000.00 |            3|
|Payam       | Kaufling    |  7900.00 |            3|
|Jose Manuel | Urman       |  7800.00 |            3|
|Ismael      | Sciarra     |  7700.00 |            3|
|Kimberely   | Grant       |  7000.00 |            3|
|Luis        | Popp        |  6900.00 |            3|
|Susan       | Mavris      |  6500.00 |            3|
|Shanta      | Vollman     |  6500.00 |            4|
|Charles     | Johnson     |  6200.00 |            4|
|Bruce       | Ernst       |  6000.00 |            4|
|Pat         | Fay         |  6000.00 |            4|
|David       | Austin      |  4800.00 |            4|
|Valli       | Pataballa   |  4800.00 |            4|
|Jennifer    | Whalen      |  4400.00 |            4|
|Diana       | Lorentz     |  4200.00 |            4|
|Sarah       | Bell        |  4000.00 |            5|
|Britney     | Everett     |  3900.00 |            5|
|Alexander   | Khoo        |  3100.00 |            5|
|Shelli      | Baida       |  2900.00 |            5|
|Sigal       | Tobias      |  2800.00 |            5|
|Irene       | Mikkilineni |  2700.00 |            5|
|Guy         | Himuro      |  2600.00 |            5|
|Karen       | Colmenares  |  2500.00 |            5|

## Using SQL NTILE() function over partition example

The following statement breaks the employees **in each department into two groups**:

```SQL
SELECT first_name,
       last_name,
       department_name,
       salary,
       NTILE(2)
       OVER (PARTITION BY department_name
             ORDER BY salary
       ) salary_group
  FROM employees e
 INNER JOIN departments d
    ON d.department_id = e.department_id;
```

Here's the partial output:

|first_name  |  last_name  | department_name  |  salary  | salary_group|
|:----------:|:-----------:|:----------------:|:---------:|:----------:|
|William     | Gietz       | Accounting       |  8300.00 |            1|
|Shelley     | Higgins     | Accounting       | 12000.00 |            2|
|Jennifer    | Whalen      | Administration   |  4400.00 |            1|
|Lex         | De Haan     | Executive        | 17000.00 |            1|
|Neena       | Kochhar     | Executive        | 17000.00 |            1|
|Steven      | King        | Executive        | 24000.00 |            2|
|Luis        | Popp        | Finance          |  6900.00 |            1|
|Ismael      | Sciarra     | Finance          |  7700.00 |            1|
|Jose Manuel | Urman       | Finance          |  7800.00 |            1|
|John        | Chen        | Finance          |  8200.00 |            2|
|Daniel      | Faviet      | Finance          |  9000.00 |            2|
|Nancy       | Greenberg   | Finance          | 12000.00 |            2|
|Susan       | Mavris      | Human Resources  |  6500.00 |            1|
|Diana       | Lorentz     | IT               |  4200.00 |            1|
|David       | Austin      | IT               |  4800.00 |            1|
|Valli       | Pataballa   | IT               |  4800.00 |            1|
|Bruce       | Ernst       | IT               |  6000.00 |            2|
|Alexander   | Hunold      | IT               |  9000.00 |            2|

In this example:

- First, the `PARTITION BY` clause divided the employees by department names into partitions.
- Then, the `ORDER BY` clause sorted the employees in each partition by salary.
- Finally, the `NTILE()` function assigned each row in each partition a bucket number. It reset the bucket number whenever the department changes.
