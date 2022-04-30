# Create HR tables

In the previous lessons we stressed the importance of the **primary** and **foreign** **keys constraints** to maintain **the self and referential integrity of data in a database when inserting and deleting rows or updating row's values**.

You can define constraints to enforce `business rules` on data in your tables. Business rules specify conditions and relationships that must always be true, or must always be false. Because each company defines its own policies about things like salaries, employee numbers, inventory tracking, and so on, **you can specify a different set of rules** for each database table.

When an **integrity constraint** applies to a table, **all data in the table must conform to the corresponding** `rule`. When you issue a SQL statement that modifies data in the table, the DBMS ensures that the new data satisfies the integrity constraint, without any checking within your program.

Before the creation of any table in the database **you must comprehend the ERD of your database in order to decide which table should be created first**, and **the column constraints** on your data values.

## HR ERD

![hr database](../00_basic_intro/images/13_hr.png)

Below is a summary of the relationships in the **HR** sample database tables.

| tables  | referenced_by    | references                 |
|:-------:|:----------------:|:--------------------------:|
|jobs |        employees   |                            |
|regions  |countries|                            |
|countries |locations         |**regions**|
|locations |departments          |**countries**|
|departments|employees|**locations**|
|employees|dependents,employees|**employees**,**departments**,**jobs**|
|dependents||**employees**|

The **jobs** and **regions** tables do not have foreign key constraints.

### jobs

```console
CREATE TABLE jobs (
	job_id SERIAL PRIMARY KEY,
	job_title VARCHAR (35) NOT NULL,
	min_salary NUMERIC (8, 2),
	max_salary NUMERIC (8, 2)
);
```

In the jobs table definition, the column `job_title` has a `NOT NULL` constraint. In database theory, `NULL` represents **unknown** or **information missing**. NULL is not the same as an empty string or the number zero.

In this table, a job always requires (from the very beginning) a title and you can enforce this rule with a `NOT NULL` integrity constraint. If a column has a `NOT NULL` constraint, any attempt to insert or update NULL in the column will result in an error.

As for the primary key constraint we see that the column `job_id` is a `SERIAL` type. Therefore, **the system will automatically generate a unique, sequential number, and will enforce a unique value constraint**.

### regions

```console
CREATE TABLE regions (
	region_id SERIAL PRIMARY KEY,
	region_name VARCHAR (25)
);
```

## Tables with Foreign key constraints

In the `hr` sample database the `countries`, `locations`, `departments`, `employees` and `dependents` tables have foreign key constraints.

### countries

In the `countries` **TABLE** the **FOREIGN KEY**, `region_id` **REFERENCES** a record in the `regions`  parent table using the primary key (`region_id`).

**(** **regions**, `countries`**)**

The relationship between the **regions** and `countries` tables can be stated as follow:

- **referenced by**: A region can have zero or many countries. A record in the **regions** table is **referenced by**  `zero or more` records in the `countries` table.
- **references**: A country belongs to `one and only one` region. A record in the `country` table **must references** a record in the **regions** table.

Let's name the foreign key **CONSTRAINT** `countries_fkey_region`:

```console
CREATE TABLE countries (
	country_id CHARACTER (2) PRIMARY KEY,
	country_name VARCHAR (40),
	region_id INTEGER NOT NULL,
  CONSTRAINT countries_fkey_region
     FOREIGN KEY (region_id)
     REFERENCES regions (region_id)
     ON UPDATE CASCADE
     ON DELETE CASCADE
);
```

In the countries table definition, the foreign key column `region_id` has a `NOT NULL` integrity constraint. When `NULL` values are not allowed in a foreign key, **each row in the child table must explicitly reference a value in the parent** primary key because nulls are not allowed in the foreign key. Therefore, the values in the foreign key column `region_id` **must match a value** in primary key of referenced table.

Now, it's clear how to implement a `one and only one` relationship in the `CREATE TABLE` statement.

We notice the `CASCADE` option for the `ON UPDATE` and `ON DELETE` actions. This means that whenever we update the primary key `region_id` in the parent table, the updating is executed to the corresponding records of the child table. Similarly, a deletion of a regions table record implies a deletion of all records in the countries table that reference the deleted record in the regions table.

### locations

In the `locations` **TABLE** the **FOREIGN KEY**, `country_id` **REFERENCES** a record in the `countries`  parent table using the primary key (`country_id`).

**(** **countries**, `locations`**)**

The relationship between the **countries** and `locations` tables can be stated as follow:

- **referenced by**: A country can have zero or many locations. A record in the **countries** table is **referenced by**  `zero or more` records in the `locations` table.
- **references**: A location belongs to `one and only one` country. A record in the `locations` table **must references** a record in the **countries** table.

Let's name the foreign key **CONSTRAINT** `locations_fkey_country`:

```console
CREATE TABLE locations (
	location_id SERIAL PRIMARY KEY,
	street_address VARCHAR (40),
	postal_code VARCHAR (12),
	city VARCHAR (30) NOT NULL,
	state_province VARCHAR (25),
	country_id CHARACTER (2) NOT NULL,
  CONSTRAINT locations_fkey_country
     FOREIGN KEY (country_id)
     REFERENCES countries (country_id)
     ON UPDATE CASCADE
     ON DELETE CASCADE
);
```

### departments

In the `departments` **TABLE** the **FOREIGN KEY**, `location_id` **REFERENCES** a record in the `locations`  parent table using the primary key (`location_id`).

**(** **locations**, `departments`**)**

The relationship between the **locations** and `departments` tables can be stated as follow:

- **referenced by**: A location can have zero or many departments. A record in the **locations** table is **referenced by**  `zero or more` records in the `departments` table.
- **references**: A department may have a location. A record in the `departments` table **can references** `zero or one` record in the **locations** table.

```console
CREATE TABLE departments (
	department_id SERIAL PRIMARY KEY,
	department_name VARCHAR (30) NOT NULL,
	location_id INTEGER,
  CONSTRAINT departments_fkey_location
     FOREIGN KEY (location_id)
     REFERENCES locations (location_id)
     ON UPDATE CASCADE
     ON DELETE CASCADE
);
```

In the departments table definition the foreign key column `location_id` has no constraints. **This model allows** `nulls` **in the foreign key**. Now, it's clear how to implement a `zero or one` relationship between the child and parent record. Maybe, the company decides to create a new department but still does not know the location.


### employees

1. In the `employees` **TABLE** the **FOREIGN KEY**, `job_id` **REFERENCES** a record in the `jobs` parent table using the primary key (`job_id`).
2. In the `employees` **TABLE** the **FOREIGN KEY**, `department_id` **REFERENCES** a record in the `departments`  parent table using the primary key (`department_id`).
3. In the `employees` **TABLE** the **FOREIGN KEY**, `manager_id` **REFERENCES** a record in the `employees`  parent table using the primary key (`employee_id`).

1. **(** **jobs**, `employees`**)**

The relationship between the **jobs** and `employees` tables can be stated as follow:

- **referenced by**: A job can have zero or many employees. A record in the **jobs** table is **referenced by**  `zero or more` records in the `employees` table.
- **references**: An employee in a company `has one and only one` job. A record in the `employees` table **must references** a record in the **jobs** table.

2. **(** **departments**, `employees`**)**

The relationship between the **departments** and `employees` tables can be stated as follow:

- **referenced by**: A department can have zero or many employees. A record in the **departments** table is **referenced by**  `zero or more` records in the `employees` table.
- **references**: An employee can be assigned to `zero or one` department. A record in the `employees` table **references** `zero or one` record in the **departments** table.

3. **(** **employees**, `employees`**)**

The relationship between the **employees** and `employees` tables (Recursive relationship) can be stated as follow:

- **referenced by**: An employee can be a manager of `zero or more` employees. A record in the **employees** table is **referenced by** `zero or more` records in the **employees** table.
- **references**: An employee reports to `zero or one employee`. A record in the **employees** table **references** `zero or one` record in the **employees** table.


```console
CREATE TABLE employees (
	employee_id SERIAL PRIMARY KEY,
	first_name VARCHAR (20),
	last_name VARCHAR (25) NOT NULL,
	email VARCHAR (100) NOT NULL,
	phone_number VARCHAR (20),
	hire_date DATE NOT NULL,
	job_id INTEGER NOT NULL,
	salary NUMERIC (8, 2) NOT NULL,
	manager_id INTEGER,
	department_id INTEGER,
  CONSTRAINT employees_fkey_job
     FOREIGN KEY (job_id)
     REFERENCES jobs (job_id)
     ON UPDATE CASCADE
     ON DELETE CASCADE,
  CONSTRAINT employees_fkey_department
     FOREIGN KEY (department_id)
     REFERENCES departments (department_id)
     ON UPDATE CASCADE
     ON DELETE CASCADE,
  CONSTRAINT employees_fkey_manager
     FOREIGN KEY (manager_id)
     REFERENCES employees (employee_id)
     ON UPDATE CASCADE
     ON DELETE CASCADE
);
```

In the employees table definition there are three foreign keys:

- `job_id` INTEGER **NOT NULL**
- `department_id` INTEGER
- `manager_id` INTEGER

The column `job_id` is the only foreign key with a `NOT NULL` constraint. In fact an employee has `one and only one job` in the company. On the other hand, an employee may or may not have a manager or a department. In other words, we allow `NULL` values in the `department_id` and `manager_id` columns.

### dependents

In the `dependents` **TABLE** the **FOREIGN KEY**, `employee_id` **REFERENCES** a record in the `employees`  parent table using the primary key (`employee_id`).

**(** **employees**, `dependents`**)**

The relationship between the **employees** and `dependents` tables can be stated as follow:

- **referenced by**: An employee can have zero or many depenendents. A record in the **employees** table is **referenced by**  `zero or more` records in the `dependents` table.
- **references**: A dependent must have an employee. A record in the `dependents` table **must references** `one and only one` record in the **employees** table.

```console
CREATE TABLE dependents (
	dependent_id SERIAL PRIMARY KEY,
	first_name VARCHAR (50) NOT NULL,
	last_name VARCHAR (50) NOT NULL,
	relationship VARCHAR (25) NOT NULL,
	employee_id INTEGER NOT NULL,
	CONSTRAINT dependents_fkey_employee
		 FOREIGN KEY (employee_id)
		 REFERENCES employees (employee_id)
		 ON UPDATE CASCADE
		 ON DELETE CASCADE
);
```
