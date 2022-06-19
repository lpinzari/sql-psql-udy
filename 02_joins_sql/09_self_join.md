# SELF JOIN

In the previous lesson we introduced the notion of table alias as a way to assign a table in the `FROM` clause a temporary name. The use of a table `alias` is required in the case a table appears more than once in a query. This situation occurs often in queries that compare rows within a table or  joining records in a table that represents a hierarchical data. This type of join is known as **Self JOIN**.

A **Self Join** is a join that joins a table with itself. A self join uses other joins such as `INNER JOIN` or `LEFT JOIN`. Because a `self join` references the same table twice, we have to use the table aliases.

>Note that referencing the same table more than once in a query without using table aliases cause an error.

Each time an alias is introduced, we declare a variable of type table, which possesses as a value the contents of the table for which it is an alias. The aliases definitions in a `self join` is similar to the creation of two different tables, each containing the same contents.

The following statement illustrates how to join a table to itself.

```SQL
SELECT column1,
       column2,
       column3,
       ...
  FROM table1 a
 INNER JOIN table1 b
    ON b.column1 = a.column2;
```

In this statement joins the table1 to itself using an INNER JOIN clause. A and B are the table aliases of the table1. The B.column1 = A.column2 is the join condition.

Let’s take few examples of using the self-join technique.

## INTRO TO PostgreSQL Self-Join example

For this example we use the `employees` table in the `hr` sample database.

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

The `manager_id` column **specifies the manager of an employee**. The following statement joins the employees table to itself to query the information of who reports to whom.

**SQL**
```SQL
SELECT e.first_name || ' ' || e.last_name AS employee,
       m.first_name || ' ' || m.last_name AS manager
  FROM employees e
 INNER JOIN employees m
    ON m.employee_id = e.manager_id
 ORDER BY manager;
```

**Results**

|employee      |      manager|
|:-------------:|:-------------------:|
|Valli Pataballa   | Alexander Hunold|
|Diana Lorentz     | Alexander Hunold|
|Bruce Ernst       | Alexander Hunold|
|David Austin      | Alexander Hunold|
|Guy Himuro        | Den Raphaely|
|Karen Colmenares  | Den Raphaely|
|Alexander Khoo    | Den Raphaely|
|Shelli Baida      | Den Raphaely|
|Sigal Tobias      | Den Raphaely|
|Alexander Hunold  | Lex De Haan|
|Irene Mikkilineni | Matthew Weiss|
|Pat Fay           | Michael Hartstein|
|Luis Popp         | Nancy Greenberg|
|Daniel Faviet     | Nancy Greenberg|
|Jose Manuel Urman | Nancy Greenberg|
|John Chen         | Nancy Greenberg|
|Ismael Sciarra    | Nancy Greenberg|
|Nancy Greenberg   | Neena Kochhar|
|Jennifer Whalen   | Neena Kochhar|
|Susan Mavris      | Neena Kochhar|
|Hermann Baer      | Neena Kochhar|
|Shelley Higgins   | Neena Kochhar|
|Britney Everett   | Shanta Vollman|
|Sarah Bell        | Shanta Vollman|
|William Gietz     | Shelley Higgins|
|Matthew Weiss     | Steven King|
|Lex De Haan       | Steven King|
|Den Raphaely      | Steven King|
|Neena Kochhar     | Steven King|
|Adam Fripp        | Steven King|
|Payam Kaufling    | Steven King|
|Shanta Vollman    | Steven King|
|John Russell      | Steven King|
|Karen Partners    | Steven King|
|Jonathon Taylor   | Steven King|
|Jack Livingston   | Steven King|
|Kimberely Grant   | Steven King|
|Charles Johnson   | Steven King|
|Michael Hartstein | Steven King|

**Query**

```console
hr=# SELECT e.first_name || ' ' || e.last_name AS employee,
hr-#        m.first_name || ' ' || m.last_name AS manager
hr-#   FROM employees e
hr-#  INNER JOIN employees m
hr-#     ON m.employee_id = e.manager_id
hr-#  ORDER BY manager;
     employee      |      manager
-------------------+-------------------
 Valli Pataballa   | Alexander Hunold
 Diana Lorentz     | Alexander Hunold
 Bruce Ernst       | Alexander Hunold
 David Austin      | Alexander Hunold
 Guy Himuro        | Den Raphaely
 Karen Colmenares  | Den Raphaely
 Alexander Khoo    | Den Raphaely
 Shelli Baida      | Den Raphaely
 Sigal Tobias      | Den Raphaely
 Alexander Hunold  | Lex De Haan
 Irene Mikkilineni | Matthew Weiss
 Pat Fay           | Michael Hartstein
 Luis Popp         | Nancy Greenberg
 Daniel Faviet     | Nancy Greenberg
 Jose Manuel Urman | Nancy Greenberg
 John Chen         | Nancy Greenberg
 Ismael Sciarra    | Nancy Greenberg
 Nancy Greenberg   | Neena Kochhar
 Jennifer Whalen   | Neena Kochhar
 Susan Mavris      | Neena Kochhar
 Hermann Baer      | Neena Kochhar
 Shelley Higgins   | Neena Kochhar
 Britney Everett   | Shanta Vollman
 Sarah Bell        | Shanta Vollman
 William Gietz     | Shelley Higgins
 Matthew Weiss     | Steven King
 Lex De Haan       | Steven King
 Den Raphaely      | Steven King
 Neena Kochhar     | Steven King
 Adam Fripp        | Steven King
 Payam Kaufling    | Steven King
 Shanta Vollman    | Steven King
 John Russell      | Steven King
 Karen Partners    | Steven King
 Jonathon Taylor   | Steven King
 Jack Livingston   | Steven King
 Kimberely Grant   | Steven King
 Charles Johnson   | Steven King
 Michael Hartstein | Steven King
(39 rows)
```

The president `Steven King` does not have any manager. In the employees table, the `manager_id` of the row that contains the president is `NULL`.

Because the inner join clause only includes the rows that have matching rows in the other table, therefore the president did not show up in the result set of the query above.

To include the president in the result set, we use the `LEFT JOIN` clause instead of the `INNER JOIN` clause. The following query lists the vice-presidents and the president of the company.

**SQL**
```SQL
SELECT e.first_name || ' ' || e.last_name As employee,
       m.first_name || ' ' || m.last_name AS manager
  FROM employees e
  LEFT JOIN employees m
    ON m.employee_id = e.manager_id
 WHERE m.manager_id IS NULL;
```

**Results**


|employee      |   manager|
|:-------------:|:-------------:|
|Steven King       | NULL|
|Neena Kochhar     | Steven King|
|Lex De Haan       | Steven King|
|Den Raphaely      | Steven King|
|Matthew Weiss     | Steven King|
|Adam Fripp        | Steven King|
|Payam Kaufling    | Steven King|
|Shanta Vollman    | Steven King|
|John Russell      | Steven King|
|Karen Partners    | Steven King|
|Jonathon Taylor   | Steven King|
|Jack Livingston   | Steven King|
|Kimberely Grant   | Steven King|
|Charles Johnson   | Steven King|
|Michael Hartstein | Steven King|


**Query**

```console
hr=# SELECT e.first_name || ' ' || e.last_name As employee,
hr-#        m.first_name || ' ' || m.last_name AS manager
hr-#   FROM employees e
hr-#   LEFT JOIN employees m
hr-#     ON m.employee_id = e.manager_id
hr-#  WHERE m.manager_id IS NULL;
     employee      |   manager
-------------------+-------------
 Steven King       | NULL
 Neena Kochhar     | Steven King
 Lex De Haan       | Steven King
 Den Raphaely      | Steven King
 Matthew Weiss     | Steven King
 Adam Fripp        | Steven King
 Payam Kaufling    | Steven King
 Shanta Vollman    | Steven King
 John Russell      | Steven King
 Karen Partners    | Steven King
 Jonathon Taylor   | Steven King
 Jack Livingston   | Steven King
 Kimberely Grant   | Steven King
 Charles Johnson   | Steven King
 Michael Hartstein | Steven King
(15 rows)
```

## Comparing rows with the same table

For this example we use the `film` table in the `dvdrental` sample database.


```console
dvdrental=# \d film
                                              Table "public.film"
      Column      |            Type             | Collation | Nullable |                Default
------------------+-----------------------------+-----------+----------+---------------------------------------
 film_id          | integer                     |           | not null | nextval('film_film_id_seq'::regclass)
 title            | character varying(255)      |           | not null |
 description      | text                        |           |          |
 release_year     | year                        |           |          |
 language_id      | smallint                    |           | not null |
 rental_duration  | smallint                    |           | not null | 3
 rental_rate      | numeric(4,2)                |           | not null | 4.99
 length           | smallint                    |           |          |
 replacement_cost | numeric(5,2)                |           | not null | 19.99
 rating           | mpaa_rating                 |           |          | 'G'::mpaa_rating
 last_update      | timestamp without time zone |           | not null | now()
 special_features | text[]                      |           |          |
 fulltext         | tsvector                    |           | not null |
```

The following query finds all pair of films that have the same length,


**SQL**
```SQL
SELECT f1.title, f2.title, f1.length
  FROM film f1
 INNER JOIN film f2
    ON f1.film_id != f2.film_id AND
       f1.length = f2.length
 LIMIT 10;
```

**Results**

|title       |         title          | length|
|:-----------:|:----------------------:|:--------:|
|Chamber Italian  | Affair Prejudice       |    117|
|Chamber Italian  | Graffiti Love          |    117|
|Chamber Italian  | Magic Mallrats         |    117|
|Chamber Italian  | Resurrection Silverado |    117|
|Grosse Wonderful | Doors President        |     49|
|Grosse Wonderful | Heavenly Gun           |     49|
|Grosse Wonderful | Hook Chariots          |     49|
|Grosse Wonderful | Hurricane Affair       |     49|
|Airport Pollock  | Go Purple              |     54|
|Airport Pollock  | Juggler Hardly         |     54|


**Query**

```console
dvdrental=# SELECT f1.title, f2.title, f1.length
dvdrental-#   FROM film f1
dvdrental-#  INNER JOIN film f2
dvdrental-#     ON f1.film_id != f2.film_id AND
dvdrental-#        f1.length = f2.length
dvdrental-#  LIMIT 10;
      title       |         title          | length
------------------+------------------------+--------
 Chamber Italian  | Affair Prejudice       |    117
 Chamber Italian  | Graffiti Love          |    117
 Chamber Italian  | Magic Mallrats         |    117
 Chamber Italian  | Resurrection Silverado |    117
 Grosse Wonderful | Doors President        |     49
 Grosse Wonderful | Heavenly Gun           |     49
 Grosse Wonderful | Hook Chariots          |     49
 Grosse Wonderful | Hurricane Affair       |     49
 Airport Pollock  | Go Purple              |     54
 Airport Pollock  | Juggler Hardly         |     54
(10 rows)
```
