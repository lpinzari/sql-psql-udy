# MAX

PostgreSQL  `MAX` function is an aggregate function that returns the maximum value in a set of values. The MAX function is useful in many cases. For example, you can use the `MAX` function to **find the employees who have the highest salary or to find the most expensive products**, etc.

The syntax of the MAX function is as follows:

```SQL
MAX(expression);
```

The `MAX` **function ignores** `NULL` values.

Unlike the `SUM`, `COUNT`, and `AVG` functions, the `DISTINCT` option **is not applicable to the** `MAX` function.

Let’s take a look at some examples of using the `MAX` function.

## PostgreSQL MAX function examples

Let’s examine the `payment` table in the `dvdrental` sample database.

```console
dvdrental=# \d payment
                                             Table "public.payment"
    Column    |            Type             | Collation | Nullable |                   Default
--------------+-----------------------------+-----------+----------+---------------------------------------------
 payment_id   | integer                     |           | not null | nextval('payment_payment_id_seq'::regclass)
 customer_id  | smallint                    |           | not null |
 staff_id     | smallint                    |           | not null |
 rental_id    | integer                     |           | not null |
 amount       | numeric(5,2)                |           | not null |
 payment_date | timestamp without time zone |           | not null |
Indexes:
    "payment_pkey" PRIMARY KEY, btree (payment_id)
    "idx_fk_customer_id" btree (customer_id)
    "idx_fk_rental_id" btree (rental_id)
    "idx_fk_staff_id" btree (staff_id)
Foreign-key constraints:
    "payment_customer_id_fkey" FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON UPDATE CASCADE ON DELETE RESTRICT
    "payment_rental_id_fkey" FOREIGN KEY (rental_id) REFERENCES rental(rental_id) ON UPDATE CASCADE ON DELETE SET NULL
    "payment_staff_id_fkey" FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ON UPDATE CASCADE ON DELETE RESTRICT
```

The following query uses the `MAX()` function to find the highest amount paid by customers in the payment table:

**SQL**
```SQL
SELECT MAX(amount) AS max_payment
  FROM payment;
```

**Results**

|max_payment|
|:-----------:|
|      11.99|


```console
dvdrental=# SELECT MAX(amount) AS max_payment
dvdrental-#   FROM payment;
 max_payment
-------------
       11.99
(1 row)
```

## PostgreSQL MAX function in subquery

To **get other information together with the highest payment**, you use a `subquery` as follows:

**SQL**
```SQL
SELECT *
  FROM payment
 WHERE amount = (
    SELECT MAX (amount)
      FROM payment
);
```

First, the subquery uses the MAX() function to return the highest payment and then the outer query selects all rows whose amounts are equal the highest payment returned from the subquery.

The output of the query is as follows:

**Results**

|payment_id | customer_id | staff_id | rental_id | amount |        payment_date|
|:---------:|:-----------:|:--------:|:---------:|:------:|:-------------------------:|
|     20403 |         362 |        1 |     14759 |  **11.99** | 2007-03-21 21:57:24.996577|
|     22650 |         204 |        2 |     15415 |  **11.99** | 2007-03-22 22:17:22.996577|
|     23757 |         116 |        2 |     14763 |  **11.99** | 2007-03-21 22:02:26.996577|
|     24553 |         195 |        2 |     16040 |  **11.99** | 2007-03-23 20:47:59.996577|
|     24866 |         237 |        2 |     11479 |  **11.99** | 2007-03-02 20:46:39.996577|
|     28799 |         591 |        2 |      4383 |  **11.99** | 2007-04-07 19:14:17.996577|
|     28814 |         592 |        1 |      3973 |  **11.99** | 2007-04-06 21:26:57.996577|
|     29136 |          13 |        2 |      8831 |  **11.99** | 2007-04-29 21:06:07.996577|



**Query**

```console
dvdrental=# SELECT *
dvdrental-#   FROM payment
dvdrental-#  WHERE amount = (
dvdrental(#     SELECT MAX (amount)
dvdrental(#       FROM payment
dvdrental(# );
```

**Output**
```console
 payment_id | customer_id | staff_id | rental_id | amount |        payment_date
------------+-------------+----------+-----------+--------+----------------------------
      20403 |         362 |        1 |     14759 |  11.99 | 2007-03-21 21:57:24.996577
      22650 |         204 |        2 |     15415 |  11.99 | 2007-03-22 22:17:22.996577
      23757 |         116 |        2 |     14763 |  11.99 | 2007-03-21 22:02:26.996577
      24553 |         195 |        2 |     16040 |  11.99 | 2007-03-23 20:47:59.996577
      24866 |         237 |        2 |     11479 |  11.99 | 2007-03-02 20:46:39.996577
      28799 |         591 |        2 |      4383 |  11.99 | 2007-04-07 19:14:17.996577
      28814 |         592 |        1 |      3973 |  11.99 | 2007-04-06 21:26:57.996577
      29136 |          13 |        2 |      8831 |  11.99 | 2007-04-29 21:06:07.996577
(8 rows)
```

## PostgreSQL MAX function with GROUP BY clause

You can combine the `MAX` function with the `GROUP BY` clause to get the maximum value for each group. For example, **the following query gets the highest payment paid by each customer**.

**SQL**
```SQL
SELECT customer_id, MAX (amount)
  FROM payment
 GROUP BY customer_id
 LIMIT 10;
```

**Results**

|customer_id |  max|
|:----------:|:------:|
|          1 |  9.99|
|          2 | 10.99|
|          3 | 10.99|
|          4 |  8.99|
|          5 |  9.99|
|          6 |  7.99|
|          7 |  8.99|
|          8 |  9.99|
|          9 |  7.99|
|         10 |  8.99|


**Query**

```console
dvdrental=# SELECT customer_id, MAX (amount)
dvdrental-#   FROM payment
dvdrental-#  GROUP BY customer_id
dvdrental-#  LIMIT 10;
```
**Output**

```console
 customer_id |  max
-------------+-------
           1 |  9.99
           2 | 10.99
           3 | 10.99
           4 |  8.99
           5 |  9.99
           6 |  7.99
           7 |  8.99
           8 |  9.99
           9 |  7.99
          10 |  8.99
(10 rows)
```

### example 2

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

For example, we can use the MAX function to find the highest salary of employee in each department in the `hr` sample database, as follows:

**SQL**
```SQL
SELECT department_id, MAX(salary)
  FROM employees
 GROUP BY department_id
 ORDER BY MAX(salary);
```

**Results**

|department_id |   max|
|:------------:|:---------:|
|            1 |  4400.00|
|            4 |  6500.00|
|            5 |  8200.00|
|            6 |  9000.00|
|            7 | 10000.00|
|            3 | 11000.00|
|           11 | 12000.00|
|           10 | 12000.00|
|            2 | 13000.00|
|            8 | 14000.00|
|            9 | 24000.00|


To include the department names in the result, we join the `employees` table with the `departments` table as follows:

**SQL**
```SQL
SELECT d.department_id, d.department_name, MAX(salary) AS max_salary
  FROM employees e
 INNER JOIN departments d USING(department_id)
 GROUP BY d.department_id, d.department_name
 ORDER BY max_salary;
```

**Results**

|department_id | department_name  | max_salary|
|:-------------:|:---------------:|:----------:|
|            1 | Administration   |    4400.00|
|            4 | Human Resources  |    6500.00|
|            5 | Shipping         |    8200.00|
|            6 | IT               |    9000.00|
|            7 | Public Relations |   10000.00|
|            3 | Purchasing       |   11000.00|
|           11 | Accounting       |   12000.00|
|           10 | Finance          |   12000.00|
|            2 | Marketing        |   13000.00|
|            8 | Sales            |   14000.00|
|            9 | Executive        |   24000.00|



```console
hr=# SELECT d.department_id, d.department_name, MAX(salary) AS max_salary
hr-#   FROM employees e
hr-#  INNER JOIN departments d USING(department_id)
hr-#  GROUP BY d.department_id, d.department_name
hr-#  ORDER BY MAX(salary);
 department_id | department_name  | max_salary
---------------+------------------+------------
             1 | Administration   |    4400.00
             4 | Human Resources  |    6500.00
             5 | Shipping         |    8200.00
             6 | IT               |    9000.00
             7 | Public Relations |   10000.00
             3 | Purchasing       |   11000.00
            11 | Accounting       |   12000.00
            10 | Finance          |   12000.00
             2 | Marketing        |   13000.00
             8 | Sales            |   14000.00
             9 | Executive        |   24000.00
(11 rows)
```

## PostgreSQL MAX function with HAVING clause

If you use the  `MAX()` function in a `HAVING` clause, you can apply a filter for a group.

For example, the following query **selects only the highest payment paid by each customer and the payments are greater than  8.99**.

**SQL**
```SQL
SELECT customer_id, MAX (amount) AS max_amount
  FROM payment
 GROUP BY customer_id
 HAVING MAX(amount) > 8.99
 LIMIT 10;
```

**Results**

|customer_id | max_amount|
|:----------:|:----------:|
|          1 |       9.99|
|          2 |      10.99|
|          3 |      10.99|
|          5 |       9.99|
|          8 |       9.99|
|         11 |       9.99|
|         12 |      10.99|
|         13 |      11.99|
|         19 |       9.99|
|         21 |      10.99|


**Query**

```console
dvdrental=# SELECT customer_id, MAX (amount) AS max_amount
dvdrental-#   FROM payment
dvdrental-#  GROUP BY customer_id
dvdrental-#  HAVING MAX(amount) > 8.99
dvdrental-#  LIMIT 10;
```

**Output**

```console
 customer_id | max_amount
-------------+------------
           1 |       9.99
           2 |      10.99
           3 |      10.99
           5 |       9.99
           8 |       9.99
          11 |       9.99
          12 |      10.99
          13 |      11.99
          19 |       9.99
          21 |      10.99
(10 rows)
```

### Example 2

For example, to get the department that has employee whose highest salary is greater than `12000`, you use the `MAX` function in the `HAVING` clause as follows:

**SQL**
```SQL
SELECT d.department_id, d.department_name, MAX(salary) As max_salary
  FROM employees
 INNER JOIN departments d USING(department_id)
 GROUP BY d.department_id, d.department_name
 HAVING MAX(salary) > 12000
 ORDER BY max_salary;
```

**Results**

|department_id | department_name | max_salary|
|:------------:|:---------------:|:-----------:|
|            2 | Marketing       |   13000.00|
|            8 | Sales           |   14000.00|
|            9 | Executive       |   24000.00|


```console
hr=# SELECT d.department_id, d.department_name, MAX(salary) As max_salary
hr-#   FROM employees
hr-#  INNER JOIN departments d USING(department_id)
hr-#  GROUP BY d.department_id, d.department_name
hr-#  HAVING MAX(salary) > 12000
hr-#  ORDER BY max_salary;
 department_id | department_name | max_salary
---------------+-----------------+------------
             2 | Marketing       |   13000.00
             8 | Sales           |   14000.00
             9 | Executive       |   24000.00
(3 rows)
```
