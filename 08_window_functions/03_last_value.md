## LAST_VALUE() function

The `LAST_VALUE()` is a window function that **returns the last value in an ordered set of values**.

The following illustrates the syntax of the `LAST_VALUE()` function:

```SQL
LAST_VALUE(expression) OVER (
    partition_clause
    order_clause
    frame_clause
)
```

In this syntax:

### expression

The **returned value of the function which can be a column or an expression** that results in a single value.

### OVER

The `OVER` clause consists of three clauses: `partition_clause`, `order_clause`, and `frame_clause`.

### partition_clause

The syntax of the `partition_clause` clause is as follows:

```SQL
PARTITION BY expr1, expr2, ...
```

The `PARTITION BY` clause **divides the rows of the result sets into partitions to which the** `LAST_VALUE()` **function applies**. Because the `PARTITION BY` clause is optional, if you omit it, the function treats the whole result set as a `single partition`.

### order_clause

The `order_clause` clause specified the order of rows in partitions to which the `LAST_VALUE()` function applies. The syntax of the `ORDER BY` clause is as follows:

```SQL
ORDER BY expr1 [ASC | DESC], expr2, ...
```

### frame_clause

The `frame_clause` defines the **subset (or frame) of the partition being evaluated**. For the detailed information on the frame clause, check it out the window function tutorial.

## SQL LAST_VALUE() function examples

We will use the `products` table created in the window function tutorial for the demonstration:

![window func](./images/01_window.png)

The data of the products table is as follows:

|product_id |    product_name    |  price  | group_id|
|:---------:|:------------------:|:-------:|:-------:|
|         1 | Microsoft Lumia    |  200.00 |        1|
|         2 | HTC One            |  400.00 |        1|
|         3 | Nexus              |  500.00 |        1|
|         4 | iPhone             |  900.00 |        1|
|         5 | HP Elite           | 1200.00 |        2|
|         6 | Lenovo Thinkpad    |  700.00 |        2|
|         7 | Sony VAIO          |  700.00 |        2|
|         8 | Dell Vostro        |  800.00 |        2|
|         9 | iPad               |  700.00 |        3|
|        10 | Kindle Fire        |  150.00 |        3|
|        11 | Samsung Galaxy Tab |  200.00 |        3|


We will use the `employees` and `departments` tables from the `hr` sample database to demonstrate the `FIRST_VALUE()` function:

![window func](./images/04_first.png)

## Using PostgreSQL LAST_VALUE() function over a result set example

The following example uses the `LAST_VALUE()` function to return all products together with the product that has the **highest price**:

```SQL
SELECT product_id,
       product_name,
       price,
       LAST_VALUE(product_name)
       OVER(ORDER BY price
            RANGE BETWEEN
            UNBOUNDED PRECEDING AND
            UNBOUNDED FOLLOWING
       ) highest_price
 FROM products;
```

**Results**

|product_id |    product_name    |  price  | highest_price|
|:---------:|:------------------:|:-------:|:------------:|
|        10 | Kindle Fire        |  150.00 | HP Elite|
|        11 | Samsung Galaxy Tab |  200.00 | HP Elite|
|         1 | Microsoft Lumia    |  200.00 | HP Elite|
|         2 | HTC One            |  400.00 | HP Elite|
|         3 | Nexus              |  500.00 | HP Elite|
|         9 | iPad               |  700.00 | HP Elite|
|         7 | Sony VAIO          |  700.00 | HP Elite|
|         6 | Lenovo Thinkpad    |  700.00 | HP Elite|
|         8 | Dell Vostro        |  800.00 | HP Elite|
|         4 | iPhone             |  900.00 | HP Elite|
|         5 | **HP Elite**           | **1200.00** | **HP Elite**|

In this example:

- We skipped the `PARTITION BY` clause in the `LAST_VALUE()` function, therefore, the `LAST_VALUE()` function treated the whole result set as a single partition.
- The `ORDER BY` clause sorted products by prices from low to high.
- The `LAST_VALUE()` picked the product name of the last row in the result set.

The following statement finds employees who have the **highest salary** in the company:

```SQL
SELECT first_name,
       last_name,
       salary,
       LAST_VALUE (first_name)
       OVER (ORDER BY salary
             RANGE BETWEEN
             UNBOUNDED PRECEDING AND
             UNBOUNDED FOLLOWING
       ) highest_salary
 FROM employees;
```

**Results**

|first_name  |  last_name  |  salary  | highest_salary|
|:----------:|:-----------:|:--------:|:-------------:|
|Karen       | Colmenares  |  2500.00 | Steven|
|Guy         | Himuro      |  2600.00 | Steven|
|Irene       | Mikkilineni |  2700.00 | Steven|
|Sigal       | Tobias      |  2800.00 | Steven|
|Shelli      | Baida       |  2900.00 | Steven|
|Alexander   | Khoo        |  3100.00 | Steven|
|Britney     | Everett     |  3900.00 | Steven|
|Sarah       | Bell        |  4000.00 | Steven|
| ...|...|...| Steven|
|Steven      | King        | 24000.00 | Steven|

In this example, the `ORDER BY` clause sorted employees by salary and the `LAST_VALUE()` selected the first name of the employee who has the highest salary.

The frame clause is as follows:

```SQL
RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
```

It means the frame starts at the first row (`UNBOUNDED PRECEDING`) and ends at the last row (`UNBOUNDED FOLLOWING`) of the result set.

## Using PostgreSQL LAST_VALUE() over a partition example

The following example uses the `LAST_VALUE()` function to **return all products together** `with the most expensive product per product group`:

```SQL
SELECT product_id,
       product_name,
       group_id,
       price,
       LAST_VALUE(product_name)
       OVER(PARTITION BY group_id
            ORDER BY price
            RANGE BETWEEN
            UNBOUNDED PRECEDING AND
            UNBOUNDED FOLLOWING
       ) highest_price
 FROM products;
```

**Results**

|product_id |    product_name    | group_id |  price  | highest_price|
|:---------:|:------------------:|:--------:|:-------:|:------------:|
|         1 | Microsoft Lumia    |        1 |  200.00 | iPhone|
|         2 | HTC One            |        1 |  400.00 | iPhone|
|         3 | Nexus              |        1 |  500.00 | iPhone|
|         4 | **iPhone**             |        **1** |  **900.00** | **iPhone**|
|         7 | Sony VAIO          |        2 |  700.00 | HP Elite|
|         6 | Lenovo Thinkpad    |        2 |  700.00 | HP Elite|
|         8 | Dell Vostro        |        2 |  800.00 | HP Elite|
|         5 | **HP Elite**           |        **2** | **1200.00** | **HP Elite**|
|        10 | Kindle Fire        |        3 |  150.00 | iPad|
|        11 | Samsung Galaxy Tab |        3 |  200.00 | iPad|
|         9 | iPad               |        3 |  700.00 | iPad|

The following statement finds employees who have the **highest salary in each department**.

```SQL
SELECT first_name,
       last_name,
       department_name,
       salary,
       LAST_VALUE (CONCAT(first_name,' ',last_name))
       OVER (PARTITION BY department_name
             ORDER BY salary
             RANGE BETWEEN
             UNBOUNDED PRECEDING AND
             UNBOUNDED FOLLOWING
       ) highest_salary
 FROM employees e
INNER JOIN departments d
      ON d.department_id = e.department_id;
```

**Results**

|first_name  |  last_name  | department_name  |  salary  |  highest_salary|
|:----------:|:-----------:|:----------------:|:--------:|:--------------:|
|William     | Gietz       | Accounting       |  8300.00 | Shelley Higgins|
|Shelley     | Higgins     | Accounting       | 12000.00 | Shelley Higgins|
|Jennifer    | Whalen      | Administration   |  4400.00 | Jennifer Whalen|
|Lex         | De Haan     | Executive        | 17000.00 | Steven King|
|Neena       | Kochhar     | Executive        | 17000.00 | Steven King|
|Steven      | King        | Executive        | 24000.00 | Steven King|
|Luis        | Popp        | Finance          |  6900.00 | Nancy Greenberg|
|Ismael      | Sciarra     | Finance          |  7700.00 | Nancy Greenberg|
|Jose Manuel | Urman       | Finance          |  7800.00 | Nancy Greenberg|
|John        | Chen        | Finance          |  8200.00 | Nancy Greenberg|
|Daniel      | Faviet      | Finance          |  9000.00 | Nancy Greenberg|
|Nancy       | Greenberg   | Finance          | 12000.00 | Nancy Greenberg|
|Susan       | Mavris      | Human Resources  |  6500.00 | Susan Mavris|
|Diana       | Lorentz     | IT               |  4200.00 | Alexander Hunold|
|David       | Austin      | IT               |  4800.00 | Alexander Hunold|
|Valli       | Pataballa   | IT               |  4800.00 | Alexander Hunold|
|Bruce       | Ernst       | IT               |  6000.00 | Alexander Hunold|
|Alexander   | Hunold      | IT               |  9000.00 | Alexander Hunold|

Let’s examine the query in more detail:

- First, the `PARTITION BY` clause divided the employees by departments.
- Then, the `ORDER BY` clause sorted employees in each department by their salary in ascending order.
- Finally, the `LAST_VALUE()` is applied to sorted rows in each partition. Because the frame starts at the first row and ends at the last row of each partition, the `LAST_VALUE()` selected the employee who has the highest salary.
