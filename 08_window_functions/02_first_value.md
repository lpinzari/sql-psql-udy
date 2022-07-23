## FIRST_VALUE() function

The **FIRST_VALUE()** is a window function that **returns the first value in an ordered set of values**.

The following illustrates the syntax of the `FIRST_VALUE()` function:

```SQL
FIRST_VALUE(expression) OVER (
    partition_clause
    order_clause
    frame_clause
)
```
In this syntax:

### expression

The **return value of the expression from the first row in a partition** or result set.

### OVER

The `OVER` clause consists of three clauses: `partition_clause`, `order_clause`, and `frame_clause`.

### partition_clause

The `partition_clause` clause has the following syntax:


```SQL
PARTITION BY expr1, expr2, ...
```

The `PARTITION BY` clause **divides the rows of the result sets into partitions** to which the `FIRST_VALUE()` **function applies**.

If you skip the `PARTITION BY` clause, the function treats the whole result set as a `single partition`.

### order_clause

The `order_clause` clause **sorts the rows in partitions to which the** `FIRST_VALUE()` **function applies**. The `ORDER BY` clause has the following syntax:

```SQL
ORDER BY expr1 [ASC | DESC], expr2, ...
```

### frame_clause

The `frame_clause` defines the **subset (or frame) of the current partition**. Check it out the window function tutorial for the detailed information of the frame clause.

## PostgreSQL FIRST_VALUE() function examples

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


## Using PostgreSQL FIRST_VALUE() function over a result set example

The following statement uses the `FIRST_VALUE()` function to return all products and also the product which has the **lowest price**:

```SQL
SELECT product_id,
       product_name,
       group_id,
       price,
       FIRST_VALUE(product_name)
       OVER(ORDER BY price) lowest_price
  FROM products;
```

**Results**

|product_id |    product_name    | group_id |  price  | lowest_price|
|:---------:|:------------------:|:---------:|:------:|:-----------:|
|        10 | **Kindle Fire**        |        3 |  **150.00** | **Kindle Fire**|
|        11 | Samsung Galaxy Tab |        3 |  200.00 | Kindle Fire|
|         1 | Microsoft Lumia    |        1 |  200.00 | Kindle Fire|
|         2 | HTC One            |        1 |  400.00 | Kindle Fire|
|         3 | Nexus              |        1 |  500.00 | Kindle Fire|
|         9 | iPad               |        3 |  700.00 | Kindle Fire|
|         7 | Sony VAIO          |        2 |  700.00 | Kindle Fire|
|         6 | Lenovo Thinkpad    |        2 |  700.00 | Kindle Fire|
|         8 | Dell Vostro        |        2 |  800.00 | Kindle Fire|
|         4 | iPhone             |        1 |  900.00 | Kindle Fire|
|         5 | HP Elite           |        2 | 1200.00 | Kindle Fire|

In this example:

- Since we skipped the `PARTITION BY` clause in the `FIRST_VALUE()` function, the function treated the whole result set as a single partition.
- The `ORDER BY` clause sorted products by prices from low to high.
- The `FIRST_VALUE()` function is applied to the whole result set and picked the value in the `product_name` column of the first row.

The following statement finds the employee who has the `lowest salary` in the company:

```SQL
SELECT first_name,
       last_name,
       salary,
       FIRST_VALUE (first_name)
       OVER (ORDER BY salary
       ) lowest_salary
  FROM employees e;
```

Here is the partial output:

**Results**

|first_name  |  last_name  |  salary  | lowest_salary|
|:----------:|:-----------:|:--------:|:-------------:|
|Karen       | Colmenares  |  2500.00 | Karen|
|Guy         | Himuro      |  2600.00 | Karen|
|Irene       | Mikkilineni |  2700.00 | Karen|
|Sigal       | Tobias      |  2800.00 | Karen|
|Shelli      | Baida       |  2900.00 | Karen|
|Alexander   | Khoo        |  3100.00 | Karen|
|Britney     | Everett     |  3900.00 | Karen|
|Sarah       | Bell        |  4000.00 | Karen|
|Diana       | Lorentz     |  4200.00 | Karen|
|Jennifer    | Whalen      |  4400.00 | Karen|
|David       | Austin      |  4800.00 | Karen|

In this example, the `ORDER BY` clause sorted the employees by salary and the `FIRST_VALUE()` selected the first name of the employee who has the **lowest salary**.

## Using FIRST_VALUE() function over a partition example

This statement uses the `FIRST_VALUE()` function to return all products grouped by the product group. And for each product group, it returns the product with the `lowest price`:

```SQL
SELECT product_id,
       product_name,
       group_id,
       price,
       FIRST_VALUE(product_name)
       OVER( PARTITION BY group_id
             ORDER BY price
             RANGE BETWEEN
                   UNBOUNDED PRECEDING AND
                   UNBOUNDED FOLLOWING
       ) lowest_price
  FROM products;
```

**Results**

|product_id |    product_name    | group_id |  price  |  lowest_price|
|:---------:|:------------------:|:--------:|:-------:|:--------------:|
|         1 | **Microsoft Lumia**    |        **1** |  **200.00** | **Microsoft Lumia**|
|         2 | HTC One            |        1 |  400.00 | Microsoft Lumia|
|         3 | Nexus              |        1 |  500.00 | Microsoft Lumia|
|         4 | iPhone             |        1 |  900.00 | Microsoft Lumia|
|         7 | **Sony VAIO**          |        **2** |  **700.00** | **Sony VAIO**|
|         6 | Lenovo Thinkpad    |        2 |  700.00 | Sony VAIO|
|         8 | Dell Vostro        |        2 |  800.00 | Sony VAIO|
|         5 | HP Elite           |        2 | 1200.00 | Sony VAIO|
|        10 | **Kindle Fire**        |        **3** |  **150.00** | **Kindle Fire**|
|        11 | Samsung Galaxy Tab |        3 |  200.00 | Kindle Fire|
|         9 | iPad               |        3 |  700.00 | Kindle Fire|

In this example:

- The `PARTITION BY` clause distributed products by product group.
- The `ORDER BY` clause sorted products in each product group (partition) by prices from low to high.
- The `RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING` clause defined the frame in each partition, **starting from the first row and ending at the last row**.
- The `FIRST_VALUE()` function is applied to each partition separately.

The following statement returns the employees who have the lowest salary in each department.

```SQL
SELECT first_name,
       last_name,
       department_name,
       salary,
       FIRST_VALUE (CONCAT(first_name,' ',last_name))
       OVER (PARTITION BY department_name
             ORDER BY salary
       ) lowest_salary
  FROM employees e
 INNER JOIN departments d
 ON d.department_id = e.department_id;
```

**Results**

|first_name  |  last_name  | department_name  |  salary  |   lowest_salary|
|:----------:|:-----------:|:----------------:|:--------:|:------------------:|
|William     | Gietz       | Accounting       |  8300.00 | William Gietz|
|Shelley     | Higgins     | Accounting       | 12000.00 | William Gietz|
|Jennifer    | Whalen      | Administration   |  4400.00 | Jennifer Whalen|
|Lex         | De Haan     | Executive        | 17000.00 | Lex De Haan|
|Neena       | Kochhar     | Executive        | 17000.00 | Lex De Haan|
|Steven      | King        | Executive        | 24000.00 | Lex De Haan|
|Luis        | Popp        | Finance          |  6900.00 | Luis Popp|
|Ismael      | Sciarra     | Finance          |  7700.00 | Luis Popp|
|Jose Manuel | Urman       | Finance          |  7800.00 | Luis Popp|
|John        | Chen        | Finance          |  8200.00 | Luis Popp|
|Daniel      | Faviet      | Finance          |  9000.00 | Luis Popp|
|Nancy       | Greenberg   | Finance          | 12000.00 | Luis Popp|
|Susan       | Mavris      | Human Resources  |  6500.00 | Susan Mavris|
|Diana       | Lorentz     | IT               |  4200.00 | Diana Lorentz|
|David       | Austin      | IT               |  4800.00 | Diana Lorentz|
|Valli       | Pataballa   | IT               |  4800.00 | Diana Lorentz|
|Bruce       | Ernst       | IT               |  6000.00 | Diana Lorentz|
|Alexander   | Hunold      | IT               |  9000.00 | Diana Lorentz|

In this example:

- First, the `PARTITION BY` clause divided the employees by departments.
- Then, the `ORDER BY` clause sorted employees in each department by their salary from low to high.
- Finally, the `FIRST_VALUE()` is applied to sorted rows in each partition. It selected the employee who has the lowest salary per department.
