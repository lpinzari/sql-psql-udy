# LEAD Function

SQL `LEAD()` is a window function **that provides access to a row at a specified physical offset which follows the current row**.

For example, by using the `LEAD()` function, from the `current row`, **you can access data of the next row**, or **the second row that follows the current row**, or **the third row that follows the current row**, and `so on`.

The `LEAD()` function can be very useful for **calculating the difference between the value of the current row and the value of the following row**.

The syntax of the `LEAD()` function is as follows:

```SQL
LEAD(return_value [,offset[, default ]]) OVER (
    PARTITION BY expr1, expr2,...
	ORDER BY expr1 [ASC | DESC], expr2,...
)
```

### return_value

The return value of the following row offsetting from the current row.

### offset

The **number of rows forwards from the current row from which to access data**. The offset must be a **non-negative integer**. If you don’t specify offset, **it defaults to 1**.

### default

The function returns `default` if the `offset` goes beyond the scope of the partition. If you do not specify default, `NULL` is returned.

### PARTITION BY clause

The `PARTITION BY` clause divides rows of the result set into partitions to which the `LEAD()` function applies. If you do not specify the `PARTITION BY` clause, the whole result set is treated as a single partition.

### ORDER BY clause

The `ORDER BY` clause sorts the rows in each partition to which the `LEAD()` function applies.

## SQL LEAD() function examples

We will use the `employees` table from the `hr` sample database for the demonstration purposes.

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

Let’s set up a new table for the demonstration.

First, create a new table named `sales`:

```SQL
CREATE TABLE sales(
  year SMALLINT CHECK(year > 0),
  group_id INT NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  PRIMARY KEY(year,group_id)
);
```

Second, insert some rows into the sales table:

```SQL
INSERT INTO
       sales(year, group_id, amount)
VALUES
  (2018,1,1474),
  (2018,2,1787),
  (2018,3,1760),
  (2019,1,1915),
  (2019,2,1911),
  (2019,3,1118),
  (2020,1,1646),
  (2020,2,1975),
  (2020,3,1516);
```

Third, query data from the sales table:

```SQL
SELECT * FROM sales;
```

**Results**

|year | group_id | amount|
|:---:|:--------:|:------:|
|2018 |        1 | 1474.00|
|2018 |        2 | 1787.00|
|2018 |        3 | 1760.00|
|2019 |        1 | 1915.00|
|2019 |        2 | 1911.00|
|2019 |        3 | 1118.00|
|2020 |        1 | 1646.00|
|2020 |        2 | 1975.00|
|2020 |        3 | 1516.00|

## Using SQL LEAD() function over result set example

The following statement returns, for each employee in the company, **the hire date of the employee hired just after**:

```SQL
SELECT first_name,
       last_name,
       hire_date,
       LEAD(hire_date, 1)
       OVER (ORDER BY hire_date
       ) AS next_hired
  FROM employees;
```

Here's the partial output.

**Results**

|first_name  |  last_name  | hire_date  | next_hired|
|:----------:|:-----------:|:----------:|:---------:|
|Steven      | King        | 1987-06-17 | **1987-09-17**|
|Jennifer    | Whalen      | **1987-09-17** | 1989-09-21|
|Neena       | Kochhar     | 1989-09-21 | 1990-01-03|
|Alexander   | Hunold      | 1990-01-03 | 1991-05-21|
|Bruce       | Ernst       | 1991-05-21 | 1993-01-13|
|Lex         | De Haan     | 1993-01-13 | 1994-06-07|
|William     | Gietz       | 1994-06-07 | 1994-06-07|
|Susan       | Mavris      | 1994-06-07 | 1994-06-07|

In this example, we omitted the `PARTITION BY` clause, therefore, the whole result was treated as a single partition. The `ORDER BY` clause sorted employees by hire dates in ascending order. The `LEAD()` function applied to each row in the result set.

The following query returns the **total sales amount by year**:

```SQL
SELECT year,
       SUM(amount)
 FROM sales
GROUP BY year
ORDER BY year;
```

**Results**

|year |   sum|
|:---:|:-------:|
|2018 | 5021.00|
|2019 | 4944.00|
|2020 | 5137.00|

This example uses the `LEAD()` function to **return the sales amount of the current year and the next year**:

```SQL
WITH cte AS (
     SELECT year,
            SUM(amount) amount
       FROM sales
      GROUP BY year
      ORDER BY year
)

SELECT year,
       amount,
       LEAD(amount,1)
       OVER (ORDER BY year
       ) next_year_sales
  FROM cte;
```

**Results**

|year | amount  | next_year_sales|
|:---:|:-------:|:--------------:|
|2018 | 5021.00 |         4944.00|
|2019 | 4944.00 |         5137.00|
|2020 | 5137.00 |            NULL|

In this example:

- First, the `CTE` returns the sales summarized by year.
- Then, the outer query uses the `LEAD()` function to return the sales of the following year for each row.

The following example uses two common table expressions to **return the sales variance between the current year and the next**:

```SQL
WITH cte AS (
     SELECT year,
            SUM(amount) amount
       FROM sales
      GROUP BY year
      ORDER BY year
), cte2 AS (
     SELECT year,
            amount,
            LEAD(amount,1)
            OVER (ORDER BY year
            ) next_year_sales
       FROM cte
)


SELECT year,
       amount,
       next_year_sales,
       (next_year_sales - amount) variance
  FROM cte2;
```

**Results**

|year | amount  | next_year_sales | variance|
|:---:|:-------:|:---------------:|:--------:|
|2018 | 5021.00 |         4944.00 |   -77.00|
|2019 | 4944.00 |         5137.00 |   193.00|
|2020 | 5137.00 |            NULL |     NULL|

## Using SQL LEAD() function over partition example

The following statement provides, for each employee, **the hire date of the employee in the same department which was hired just after**:

```SQL
SELECT first_name,
       last_name,
       department_name,
       hire_date,
       LEAD(hire_date, 1)
       OVER (PARTITION by department_name
             ORDER BY hire_date
       ) AS next_hire_date
  FROM employees e
 INNER JOIN departments d
    ON d.department_id = e.department_id;
```

Here's the partial output.

**Results**

|first_name  |  last_name  | department_name  | hire_date  | next_hire_date|
|:----------:|:-----------:|:----------------:|:----------:|:--------------:|
|William     | Gietz       | Accounting       | 1994-06-07 | 1994-06-07|
|Shelley     | Higgins     | Accounting       | 1994-06-07 | NULL|
|Jennifer    | Whalen      | Administration   | 1987-09-17 | NULL|
|Steven      | King        | Executive        | 1987-06-17 | 1989-09-21|
|Neena       | Kochhar     | Executive        | 1989-09-21 | 1993-01-13|
|Lex         | De Haan     | Executive        | 1993-01-13 | NULL|
|Daniel      | Faviet      | Finance          | 1994-08-16 | 1994-08-17|
|Nancy       | Greenberg   | Finance          | 1994-08-17 | 1997-09-28|
|John        | Chen        | Finance          | 1997-09-28 | 1997-09-30|
|Ismael      | Sciarra     | Finance          | 1997-09-30 | 1998-03-07|
|Jose Manuel | Urman       | Finance          | 1998-03-07 | 1999-12-07|
|Luis        | Popp        | Finance          | 1999-12-07 | NULL|
|Susan       | Mavris      | Human Resources  | 1994-06-07 | NULL|
|Alexander   | Hunold      | IT               | 1990-01-03 | 1991-05-21|
|Bruce       | Ernst       | IT               | 1991-05-21 | 1997-06-25|
|David       | Austin      | IT               | 1997-06-25 | 1998-02-05|
|Valli       | Pataballa   | IT               | 1998-02-05 | 1999-02-07|
|Diana       | Lorentz     | IT               | 1999-02-07 | NULL|
|Michael     | Hartstein   | Marketing        | 1996-02-17 | 1997-08-17|

In this example, we used the `PARTITION BY` clause to divide the employees by departments into partitions and used the `ORDER BY` clause to sort the employees in each department by hire dates in ascending order. The `LEAD()` function was applied to each sorted partitions independently to get the next hire dates of the employees in each department.

The following statement uses the `LEAD()` function **to compare the sales of the current year with sales of the next year for each product group**:

```SQL
SELECT year,
       amount,
       group_id,
       LEAD(amount,1)
       OVER (PARTITION BY group_id
             ORDER BY year
       ) next_year_sales
  FROM sales;
```

**Results**

|year | amount  | group_id | next_year_sales|
|:---:|:-------:|:--------:|:--------------:|
|2018 | 1474.00 |        1 |         1915.00|
|2019 | 1915.00 |        1 |         1646.00|
|2020 | 1646.00 |        1 |            NULL|
|2018 | 1787.00 |        2 |         1911.00|
|2019 | 1911.00 |        2 |         1975.00|
|2020 | 1975.00 |        2 |            NULL|
|2018 | 1760.00 |        3 |         1118.00|
|2019 | 1118.00 |        3 |         1516.00|
|2020 | 1516.00 |        3 |            NULL|

In this example:

- The `PARTITION BY` clause distributes rows into product groups (or partitions) specified by group id.
- The `ORDER BY` clause sorts rows in each product group by years in ascending order.
- The `LEAD()` function returns the sales of the next year from the current year for each product group.
