# RANK Function

The `RANK()` function is a window function that **assigns a rank to each row in the partition of a result set**.

The rank of a row **is determined by one plus the number of ranks that come before it**.

The syntax of the `RANK()` function is as follows:

```SQL
RANK() OVER (
	PARTITION BY <expr1>[{,<expr2>...}]
	ORDER BY <expr1> [ASC|DESC], [{,<expr2>...}]
)
```

In this syntax:

- First, the `PARTITION BY` clause distributes the rows in the result set into partitions by one or more criteria.
- Second, the `ORDER BY` clause sorts the rows in each a partition.
- The `RANK()` function is operated on the rows of each partition and reinitialized when crossing each partition boundary.

**The same column values receive the same ranks**.

When `multiple rows share the same rank`, the rank of **the next row is not consecutive**. This is similar to Olympic medaling in that if two athletes share the gold medal, there is no silver medal.

The following statements create a new table name `t` and insert some sample data:

```SQL
CREATE TABLE t (
  col CHAR
);

INSERT INTO t(col)
VALUES('A'),('B'),('B'),('C'),('D'),('D'),('E');

SELECT *
  FROM t;
```

**Results**

|col|
|:---:|
|A|
|B|
|B|
|C|
|D|
|D|
|E|

The following statement uses the `RANK()` function to assign ranks to the rows of the result set:

```SQL
SELECT col,
       RANK()
       OVER (ORDER BY col
       ) myrank
  FROM t;
```

**Results**

|col | myrank|
|:---:|:-----:|
|A   |      1|
|B   |      2|
|B   |      2|
|C   |      4|
|D   |      5|
|D   |      5|
|E   |      7|

As clearly shown in the output, the second and third rows share the same rank because they have the same value. The fourth row gets the rank `4` **because the** `RANK()` **function skips the rank** `3`.

Note that if you want to have **consecutive ranks**, you can use the `DENSE_RANK()` function.

## SQL RANK() function examples

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

## Using SQL RANK() function over the result set example

The following statement ranks employees by their salaries:

```SQL
SELECT first_name,
       last_name,
       salary,
       RANK()
       OVER (ORDER BY salary) salary_rank
  FROM employees;
```

**Results**

|first_name  |  last_name  |  salary  | salary_rank|
|:----------:|:-----------:|:--------:|:-----------:|
|Karen       | Colmenares  |  2500.00 |           1|
|Guy         | Himuro      |  2600.00 |           2|
|Irene       | Mikkilineni |  2700.00 |           3|
|Sigal       | Tobias      |  2800.00 |           4|
|Shelli      | Baida       |  2900.00 |           5|
|Alexander   | Khoo        |  3100.00 |           6|
|Britney     | Everett     |  3900.00 |           7|
|Sarah       | Bell        |  4000.00 |           8|
|Diana       | Lorentz     |  4200.00 |           9|
|Jennifer    | Whalen      |  4400.00 |          10|
|David       | Austin      |  4800.00 |          11|
|Valli       | Pataballa   |  4800.00 |          11|
|Pat         | Fay         |  6000.00 |          13|
|Bruce       | Ernst       |  6000.00 |          13|
|Charles     | Johnson     |  6200.00 |          15|
|Susan       | Mavris      |  6500.00 |          16|
|Shanta      | Vollman     |  6500.00 |          16|
|Luis        | Popp        |  6900.00 |          18|
|Kimberely   | Grant       |  7000.00 |          19|
|Ismael      | Sciarra     |  7700.00 |          20|
|Jose Manuel | Urman       |  7800.00 |          21|
|Payam       | Kaufling    |  7900.00 |          22|
|Matthew     | Weiss       |  8000.00 |          23|
|Adam        | Fripp       |  8200.00 |          24|
|John        | Chen        |  8200.00 |          24|
|William     | Gietz       |  8300.00 |          26|
|Jack        | Livingston  |  8400.00 |          27|
|Jonathon    | Taylor      |  8600.00 |          28|
|Daniel      | Faviet      |  9000.00 |          29|
|Alexander   | Hunold      |  9000.00 |          29|
|Hermann     | Baer        | 10000.00 |          31|
|Den         | Raphaely    | 11000.00 |          32|
|Nancy       | Greenberg   | 12000.00 |          33|
|Shelley     | Higgins     | 12000.00 |          33|
|Michael     | Hartstein   | 13000.00 |          35|
|Karen       | Partners    | 13500.00 |          36|
|John        | Russell     | 14000.00 |          37|
|Neena       | Kochhar     | 17000.00 |          38|
|Lex         | De Haan     | 17000.00 |          38|
|Steven      | King        | 24000.00 |          40|

In this example, we omitted the `PARTITION BY` clause so the whole result set was treated as a single partition.

The `ORDER BY` clause sorted the rows in the result by salary. The `RANK()` function then is applied to each row in the result considering the order of employees by salary in descending order.

## Using SQL RANK() function over partition example

The following statement finds the employees who have the second highest salary in their departments:

```SQL
WITH payroll AS (
     SELECT first_name,
            last_name,
            department_id,
            salary,
            RANK()
            OVER (PARTITION BY department_id
                  ORDER BY salary) salary_rank
            FROM employees
)

SELECT first_name,
       last_name,
       department_name,
       salary
  FROM payroll p
 INNER JOIN departments d
    ON d.department_id = p.department_id
 WHERE salary_rank = 2;
```

In the **common table expression**, we find the salary ranks of employees by their departments:

- First, the `PARTITION BY` clause divided the employee records by their departments into partitions.
- Then, the `ORDER BY` clause sorted employees in each partition by salary.
- Finally, the `RANK()` function assigned ranks to employees per partition. The employees who have the same salary got the same rank.

The following picture illustrates the **result set of the common table expression**:

|first_name  |  last_name  | department_id |  salary  | salary_rank|
|:----------:|:-----------:|:-------------:|:--------:|:----------:|
|Jennifer    | Whalen      |             1 |  4400.00 |           1|
|Pat         | Fay         |             2 |  6000.00 |           1|
|Michael     | Hartstein   |             2 | 13000.00 |           2|
|Karen       | Colmenares  |             3 |  2500.00 |           1|
|Guy         | Himuro      |             3 |  2600.00 |           2|
|Sigal       | Tobias      |             3 |  2800.00 |           3|
|Shelli      | Baida       |             3 |  2900.00 |           4|
|Alexander   | Khoo        |             3 |  3100.00 |           5|
|Den         | Raphaely    |             3 | 11000.00 |           6|
|Susan       | Mavris      |             4 |  6500.00 |           1|
|Irene       | Mikkilineni |             5 |  2700.00 |           1|
|Britney     | Everett     |             5 |  3900.00 |           2|
|Sarah       | Bell        |             5 |  4000.00 |           3|
|Shanta      | Vollman     |             5 |  6500.00 |           4|
|Payam       | Kaufling    |             5 |  7900.00 |           5|
|Matthew     | Weiss       |             5 |  8000.00 |           6|
|Adam        | Fripp       |             5 |  8200.00 |           7|
|Diana       | Lorentz     |             6 |  4200.00 |           1|
|David       | Austin      |             6 |  4800.00 |           2|
|Valli       | Pataballa   |             6 |  4800.00 |           2|
|Bruce       | Ernst       |             6 |  6000.00 |           4|
|Alexander   | Hunold      |             6 |  9000.00 |           5|
|Hermann     | Baer        |             7 | 10000.00 |           1|
|Charles     | Johnson     |             8 |  6200.00 |           1|
|Kimberely   | Grant       |             8 |  7000.00 |           2|
|Jack        | Livingston  |             8 |  8400.00 |           3|
|Jonathon    | Taylor      |             8 |  8600.00 |           4|
|Karen       | Partners    |             8 | 13500.00 |           5|
|John        | Russell     |             8 | 14000.00 |           6|
|Lex         | De Haan     |             9 | 17000.00 |           1|
|Neena       | Kochhar     |             9 | 17000.00 |           1|
|Steven      | King        |             9 | 24000.00 |           3|
|Luis        | Popp        |            10 |  6900.00 |           1|
|Ismael      | Sciarra     |            10 |  7700.00 |           2|
|Jose Manuel | Urman       |            10 |  7800.00 |           3|
|John        | Chen        |            10 |  8200.00 |           4|
|Daniel      | Faviet      |            10 |  9000.00 |           5|
|Nancy       | Greenberg   |            10 | 12000.00 |           6|
|William     | Gietz       |            11 |  8300.00 |           1|
|Shelley     | Higgins     |            11 | 12000.00 |           2|

The outer query joined selected only employees whose salary rank is `2`. It also joined with the  departments table to return the department names in the final result set.

The following picture shows the output of the query:

**Results**

|first_name | last_name | department_name |  salary|
|:---------:|:---------:|:---------------:|:-------:|
|Michael    | Hartstein | Marketing       | 13000.00|
|Guy        | Himuro    | Purchasing      |  2600.00|
|Britney    | Everett   | Shipping        |  3900.00|
|David      | Austin    | IT              |  4800.00|
|Valli      | Pataballa | IT              |  4800.00|
|Kimberely  | Grant     | Sales           |  7000.00|
|Ismael     | Sciarra   | Finance         |  7700.00|
|Shelley    | Higgins   | Accounting      | 12000.00|
