# Average

One more powerful piece of information is the average of a column's values. To answer questions like these, SQL provides the `AVG` aggregate.

The PostgreSQL **AVG()** function accepts a list of values and returns the average.

The following illustrates the syntax of the **AVG()** function:

```SQL
AVG([DISTINCT | ALL ] expression)
```

The **AVG()** function can accept a clause which is either `DISTINCT` or `ALL`.

The `DISTINCT` clause instructs the function to **ignore the duplicate values** while the `ALL` clause causes the function to **consider all the duplicate values**.

For example, the average `DISTINCT` of `1`, `1`, `2`, and `3` is `(1 + 2 + 3 ) / 3 = 2`, while the average `ALL` of `1`, `1`, `2`, and `3` is `(1 + 1 + 2 + 3) /4 = 1.75`.

The `AVG()` **function ignores NULL values**. For example, the average of `2`, `4`, and `NULL` is `(2 + 4) /2 = 3`.

Let’s take a look at some examples of using the `AVG` function.

We will use the following  `payment` and `customer` tables in the `dvdrental` sample database for demonstration:

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
```

**customer**

```console
dvdrental=# \d customer
                                             Table "public.customer"
   Column    |            Type             | Collation | Nullable |                    Default
-------------+-----------------------------+-----------+----------+-----------------------------------------------
 customer_id | integer                     |           | not null | nextval('customer_customer_id_seq'::regclass)
 store_id    | smallint                    |           | not null |
 first_name  | character varying(45)       |           | not null |
 last_name   | character varying(45)       |           | not null |
 email       | character varying(50)       |           |          |
 address_id  | smallint                    |           | not null |
 activebool  | boolean                     |           | not null | true
 create_date | date                        |           | not null | ('now'::text)::date
 last_update | timestamp without time zone |           |          | now()
 active      | integer                     |           |          |
 ```

## PostgreSQL AVG() function examples

If you want to know the `average amount` that customers paid, you can apply the `AVG` function on the  amount column as the following query:

**SQL**
```SQL
SELECT AVG(amount)::numeric(10,2)
  FROM payment;
```

**Results**

| avg|
|:----:|
| 4.20|

## PostgreSQL AVG() function with DISTINCT operator

To calculate the `average value of distinct values` in a set, you use the distinct option as follows:

```SQL
AVG(DISTINCT column)
```

The following query returns `the average payment made by customers`. Because we use `DISTINCT`, PostgreSQL only **takes unique amounts and calculates the average**.

**SQL**

```SQL
SELECT AVG(DISTINCT amount)::numeric(10,2)
  FROM payment;
```

**Results**

| avg|
|:----:|
| 6.14|

Notice that the result is different from the first example that does not use the `DISTINCT` option.

## PostgreSQL AVG() function with GROUP BY clause

To calculate the average value of a group, you use the `AVG` function with `GROUP BY` clause. First, the `GROUP BY` clause divides rows of the table into groups, the `AVG` function is then applied to each group.

The following example uses the `AVG()` function with `GROUP BY` clause to calculate the average amount paid by each customer:

**SQL**
```SQL
SELECT customer_id, first_name, last_name,
       AVG (amount)::NUMERIC(10,2)
  FROM payment
 INNER JOIN customer USING(customer_id)
 GROUP BY customer_id
 ORDER BY customer_id
 LIMIT 10;
```

**Results**

| customer_id | first_name | last_name | avg|
|:-----------:|:----------:|:---------:|:-----:|
|           1 | Mary       | Smith     | 3.82|
|           2 | Patricia   | Johnson   | 4.76|
|           3 | Linda      | Williams  | 5.45|
|           4 | Barbara    | Jones     | 3.72|
|           5 | Elizabeth  | Brown     | 3.85|
|           6 | Jennifer   | Davis     | 3.39|
|           7 | Maria      | Miller    | 4.67|
|           8 | Susan      | Wilson    | 3.73|
|           9 | Margaret   | Moore     | 3.94|
|          10 | Dorothy    | Taylor    | 3.95|

In the query, we joined the `payment` table with the customer table using inner join. We used `GROUP BY` clause to group customers into groups and applied the `AVG()` function to calculate the average per group.

## PostgreSQL AVG() function with HAVING clause

You can use the `AVG` function in the `HAVING` clause to filter the group based on a certain condition. For example, for all customers, you can get the customers who paid **the average payment bigger than 5 USD**. The following query helps you to do so:

**SQL**

```SQL
SELECT customer_id, first_name, last_name,
       AVG (amount)::NUMERIC(10,2)
  FROM payment
 INNER JOIN customer USING(customer_id)
 GROUP BY customer_id
 HAVING AVG (amount) > 5
 ORDER BY customer_id
 LIMIT 10;
```
**Results**

| customer_id | first_name | last_name | avg|
|:-----------:|:-----------:|:--------:|:-----:|
|           3 | Linda      | Williams  | 5.45|
|          19 | Ruth       | Martinez  | 5.49|
|         137 | Rhonda     | Kennedy   | 5.04|
|         181 | Ana        | Bradley   | 5.08|
|         187 | Brittany   | Riley     | 5.62|
|         209 | Tonya      | Chapman   | 5.09|
|         259 | Lena       | Jensen    | 5.16|
|         272 | Kay        | Caldwell  | 5.07|
|         285 | Miriam     | Mckinney  | 5.12|
|         293 | Mae        | Fletcher  | 5.13|

This query is similar to the one above with an additional `HAVING` clause. We used `AVG` function in the `HAVING` clause to filter the groups that have an average amount less than or equal to 5.

## PostgreSQL AVG() function and NULL

Let’s see the behavior of the `AVG()` function when its input has `NULL`.

First, create a table named `t1`.

```console
dvdrental=# CREATE TABLE t1 (
dvdrental(#        id serial PRIMARY KEY,
dvdrental(#        amount INTEGER
dvdrental(# );
CREATE TABLE
```
Second, insert some sample data:

```console
dvdrental=# INSERT INTO t1 (amount)
dvdrental-# VALUES (10),
dvdrental-#        (NULL),
dvdrental-#        (30);
INSERT 0 3
```
The data of the t1 table is as follows:

**t1**

|id | amount|
|:-:|:-----:|
| 1 |     10|
| 2 |   NULL|
| 3 |     30|

Third, use the `AVG()` function to calculate average values in the amount column.


**SQL**

```SQL
SELECT AVG(amount)::NUMERIC(10,2)
  FROM t1;
```

**Results**

|  avg|
|:-----:|
| 20.00|

It returns 20, meaning that the `AVG()` function ignores `NULL` values.

## PostgreSQL AVG() with COALESCE() function

If you want to treat the `NULL` value as zero for calculating the average, you can use `AVG()` function together with the `COAELESCE()` function:

**SQL**

```SQL
SELECT AVG(COALESCE(amount,0))::NUMERIC(10,2)
  FROM t1;
```

**Results**

|  avg|
|:-----:|
| 13.33|

## SQL AVG with a subquery

We can apply `AVG` function **multiple times in a single SQL statement to calculate the average value of a set of average values**.

We'll use the `employees` table in the `hr` sample database.

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

For example, we can use the `AVG` function to calculate the average salary of employees in each department, and apply the `AVG` function one more time to calculate the average salary of departments.

The following query illustrates the idea:

**SQL**

```SQL
SELECT AVG(employee_sal_avg)
  FROM (
       SELECT AVG(salary) employee_sal_avg
         FROM employees
        GROUP BY department_id) t ;
```

**Results**

|          avg|
|:---------------------:|
| 8535.9740259740259437|
