# Create HR database schema

In lesson [40](./40_create_hr_tables), we defined the tables structure of the `hr` sample database. In this lesson, we implement the table structure definition of the `hr` sample databse schema in the `hr-schema.sql` file.

In order to do that, we need to

1. DROP the existing tables in the `hr` database.
2. include the `CREATE TABLE` statements within the primary and foreign key constraints.

Keep in mind, the statement order is important. Therefore, kepp an eye on the **referenced by** relationships between tables or **parent relationships graph**.

![hr database2](../00_basic_intro/images/14_hr.png)

The graph in the picture above illustrates the parenthood hierarchy between tables.

- Level 0: `jobs`, `regions`. (no parent tables)
- Level 1: `countries`. (1 parent table)
- Level 2: `locations`. (1 grand parent table)
- Level 3: `departments`.
- Level 4: `employees`.
- Level 5: `dependents`.

Therefore, we can drop the tables in reverse order and create tables starting from level 0 and ending to level 5.

In the next section, we execute the `CREATE TABLE` statements first in the `psql` prompt to practice again with the PostgreSQL commands. Next, we test the `DROP TABLE` statements in the `psql` prompt and lastly include all the statements in the sql script.

## hr-schema.sql

We start with the tables indicated in level 0.

```console
postgres=> \c hr
You are now connected to database "hr" as user "usertest".
```

### jobs

```console
hr=> CREATE TABLE jobs (
hr(>   job_id SERIAL PRIMARY KEY,
hr(>   job_title VARCHAR (35) NOT NULL,
hr(>   min_salary NUMERIC (8, 2),
hr(>   max_salary NUMERIC (8, 2)
hr(> );
CREATE TABLE
```

Let's see the table structure definition.

```console
hr=> \d jobs
                                       Table "public.jobs"
   Column   |         Type          | Collation | Nullable |               Default
------------+-----------------------+-----------+----------+--------------------------------------
 job_id     | integer               |           | not null | nextval('jobs_job_id_seq'::regclass)
 job_title  | character varying(35) |           | not null |
 min_salary | numeric(8,2)          |           |          |
 max_salary | numeric(8,2)          |           |          |
Indexes:
    "jobs_pkey" PRIMARY KEY, btree (job_id)
```

### regions

```console
hr=> CREATE TABLE regions (
hr(>   region_id SERIAL PRIMARY KEY,
hr(>   region_name VARCHAR (25)
hr(> );
CREATE TABLE
```

Let's see the table structure definition.

```console
hr=> \d regions
                                         Table "public.regions"
   Column    |         Type          | Collation | Nullable |                  Default
-------------+-----------------------+-----------+----------+--------------------------------------------
 region_id   | integer               |           | not null | nextval('regions_region_id_seq'::regclass)
 region_name | character varying(25) |           |          |
Indexes:
    "regions_pkey" PRIMARY KEY, btree (region_id)
```

**Level 1**

### countries

```console
hr=> CREATE TABLE countries (
hr(>   country_id CHARACTER (2) PRIMARY KEY,
hr(>   country_name VARCHAR (40),
hr(>   region_id INTEGER NOT NULL,
hr(>   CONSTRAINT countries_fkey_region
hr(>      FOREIGN KEY (region_id)
hr(>      REFERENCES regions (region_id)
hr(>      ON UPDATE CASCADE
hr(>      ON DELETE CASCADE
hr(> );
CREATE TABLE
```

Let's see the table structure definition.

```console
hr=> \d countries
                       Table "public.countries"
    Column    |         Type          | Collation | Nullable | Default
--------------+-----------------------+-----------+----------+---------
 country_id   | character(2)          |           | not null |
 country_name | character varying(40) |           |          |
 region_id    | integer               |           | not null |
Indexes:
    "countries_pkey" PRIMARY KEY, btree (country_id)
Foreign-key constraints:
    "countries_fkey_region" FOREIGN KEY (region_id) REFERENCES regions(region_id) ON UPDATE CASCADE ON DELETE CASCADE
```

`parent table`.

```console
hr=> \d regions
                                         Table "public.regions"
   Column    |         Type          | Collation | Nullable |                  Default
-------------+-----------------------+-----------+----------+--------------------------------------------
 region_id   | integer               |           | not null | nextval('regions_region_id_seq'::regclass)
 region_name | character varying(25) |           |          |
Indexes:
    "regions_pkey" PRIMARY KEY, btree (region_id)
Referenced by:
    TABLE "countries" CONSTRAINT "countries_fkey_region" FOREIGN KEY (region_id) REFERENCES regions(region_id) ON UPDATE CASCADE ON DELETE CASCADE
```

**Level 2**

### locations

```console
hr=> CREATE TABLE locations (
hr(>   location_id SERIAL PRIMARY KEY,
hr(>   street_address VARCHAR (40),
hr(>   postal_code VARCHAR (12),
hr(>   city VARCHAR (30) NOT NULL,
hr(>   state_province VARCHAR (25),
hr(>   country_id CHARACTER (2) NOT NULL,
hr(>   CONSTRAINT locations_fkey_country
hr(>      FOREIGN KEY (country_id)
hr(>      REFERENCES countries (country_id)
hr(>      ON UPDATE CASCADE
hr(>      ON DELETE CASCADE
hr(> );
CREATE TABLE
```

Let's see the table structure definition.

```console
hr=> \d locations
                                            Table "public.locations"
     Column     |         Type          | Collation | Nullable |                    Default
----------------+-----------------------+-----------+----------+------------------------------------------------
 location_id    | integer               |           | not null | nextval('locations_location_id_seq'::regclass)
 street_address | character varying(40) |           |          |
 postal_code    | character varying(12) |           |          |
 city           | character varying(30) |           | not null |
 state_province | character varying(25) |           |          |
 country_id     | character(2)          |           | not null |
Indexes:
    "locations_pkey" PRIMARY KEY, btree (location_id)
Foreign-key constraints:
    "locations_fkey_country" FOREIGN KEY (country_id) REFERENCES countries(country_id) ON UPDATE CASCADE ON DELETE CASCADE
```

`parent table`:

```console
hr=> \d countries
                       Table "public.countries"
    Column    |         Type          | Collation | Nullable | Default
--------------+-----------------------+-----------+----------+---------
 country_id   | character(2)          |           | not null |
 country_name | character varying(40) |           |          |
 region_id    | integer               |           | not null |
Indexes:
    "countries_pkey" PRIMARY KEY, btree (country_id)
Foreign-key constraints:
    "countries_fkey_region" FOREIGN KEY (region_id) REFERENCES regions(region_id) ON UPDATE CASCADE ON DELETE CASCADE
Referenced by:
    TABLE "locations" CONSTRAINT "locations_fkey_country" FOREIGN KEY (country_id) REFERENCES countries(country_id) ON UPDATE CASCADE ON DELETE CASCADE
```

**Level 3**

### departments

```console
hr=> CREATE TABLE departments (
hr(>   department_id SERIAL PRIMARY KEY,
hr(>   department_name VARCHAR (30) NOT NULL,
hr(>   location_id INTEGER,
hr(>   CONSTRAINT departments_fkey_location
hr(>      FOREIGN KEY (location_id)
hr(>      REFERENCES locations (location_id)
hr(>      ON UPDATE CASCADE
hr(>      ON DELETE CASCADE
hr(> );
CREATE TABLE
```

Let's see the table structure definition.

```console
hr=> \d departments
                                             Table "public.departments"
     Column      |         Type          | Collation | Nullable |                      Default
-----------------+-----------------------+-----------+----------+----------------------------------------------------
 department_id   | integer               |           | not null | nextval('departments_department_id_seq'::regclass)
 department_name | character varying(30) |           | not null |
 location_id     | integer               |           |          |
Indexes:
    "departments_pkey" PRIMARY KEY, btree (department_id)
Foreign-key constraints:
    "departments_fkey_location" FOREIGN KEY (location_id) REFERENCES locations(location_id) ON UPDATE CASCADE ON DELETE CASCADE
```

`parent table`;

```console
hr=> \d locations
                                            Table "public.locations"
     Column     |         Type          | Collation | Nullable |                    Default
----------------+-----------------------+-----------+----------+------------------------------------------------
 location_id    | integer               |           | not null | nextval('locations_location_id_seq'::regclass)
 street_address | character varying(40) |           |          |
 postal_code    | character varying(12) |           |          |
 city           | character varying(30) |           | not null |
 state_province | character varying(25) |           |          |
 country_id     | character(2)          |           | not null |
Indexes:
    "locations_pkey" PRIMARY KEY, btree (location_id)
Foreign-key constraints:
    "locations_fkey_country" FOREIGN KEY (country_id) REFERENCES countries(country_id) ON UPDATE CASCADE ON DELETE CASCADE
Referenced by:
    TABLE "departments" CONSTRAINT "departments_fkey_location" FOREIGN KEY (location_id) REFERENCES locations(location_id) ON UPDATE CASCADE ON DELETE CASCADE
```

**Level 4**

### employees

```console
hr=> CREATE TABLE employees (
hr(>   employee_id SERIAL PRIMARY KEY,
hr(>   first_name VARCHAR (20),
hr(>   last_name VARCHAR (25) NOT NULL,
hr(>   email VARCHAR (100) NOT NULL,
hr(>   phone_number VARCHAR (20),
hr(>   hire_date DATE NOT NULL,
hr(>   job_id INTEGER NOT NULL,
hr(>   salary NUMERIC (8, 2) NOT NULL,
hr(>   manager_id INTEGER,
hr(>   department_id INTEGER,
hr(>   CONSTRAINT employees_fkey_job
hr(>      FOREIGN KEY (job_id)
hr(>      REFERENCES jobs (job_id)
hr(>      ON UPDATE CASCADE
hr(>      ON DELETE CASCADE,
hr(>   CONSTRAINT employees_fkey_department
hr(>      FOREIGN KEY (department_id)
hr(>      REFERENCES departments (department_id)
hr(>      ON UPDATE CASCADE
hr(>      ON DELETE CASCADE,
hr(>   CONSTRAINT employees_fkey_manager
hr(>      FOREIGN KEY (manager_id)
hr(>      REFERENCES employees (employee_id)
hr(>      ON UPDATE CASCADE
hr(>      ON DELETE CASCADE
hr(> );
CREATE TABLE
```

Let's see the table structure definition.

```console
hr=> \d employees
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
    TABLE "employees" CONSTRAINT "employees_fkey_manager" FOREIGN KEY (manager_id) REFERENCES employees(employee_id) ON UPDATE CASCADE ON DELETE CASCADE
```

As we can see, the output of the `\d employees` shows that the `employees_fkey_manager` appears in the `Foreign-key constraints` and `Referenced by` sections.

Let's see the `departments` parent table:

```console
hr=> \d departments
                                             Table "public.departments"
     Column      |         Type          | Collation | Nullable |                      Default
-----------------+-----------------------+-----------+----------+----------------------------------------------------
 department_id   | integer               |           | not null | nextval('departments_department_id_seq'::regclass)
 department_name | character varying(30) |           | not null |
 location_id     | integer               |           |          |
Indexes:
    "departments_pkey" PRIMARY KEY, btree (department_id)
Foreign-key constraints:
    "departments_fkey_location" FOREIGN KEY (location_id) REFERENCES locations(location_id) ON UPDATE CASCADE ON DELETE CASCADE
Referenced by:
    TABLE "employees" CONSTRAINT "employees_fkey_department" FOREIGN KEY (department_id) REFERENCES departments(department_id) ON UPDATE CASCADE ON DELETE CASCADE
```

Let's see the `jobs` parent table:

```console
hr=> \d jobs
                                       Table "public.jobs"
   Column   |         Type          | Collation | Nullable |               Default
------------+-----------------------+-----------+----------+--------------------------------------
 job_id     | integer               |           | not null | nextval('jobs_job_id_seq'::regclass)
 job_title  | character varying(35) |           | not null |
 min_salary | numeric(8,2)          |           |          |
 max_salary | numeric(8,2)          |           |          |
Indexes:
    "jobs_pkey" PRIMARY KEY, btree (job_id)
Referenced by:
    TABLE "employees" CONSTRAINT "employees_fkey_job" FOREIGN KEY (job_id) REFERENCES jobs(job_id) ON UPDATE CASCADE ON DELETE CASCADE
```

**Level 5**

### dependents

```console
hr=> CREATE TABLE dependents (
hr(>   dependent_id SERIAL PRIMARY KEY,
hr(>   first_name VARCHAR (50) NOT NULL,
hr(>   last_name VARCHAR (50) NOT NULL,
hr(>   relationship VARCHAR (25) NOT NULL,
hr(>   employee_id INTEGER NOT NULL,
hr(>   CONSTRAINT dependents_fkey_employee
hr(>      FOREIGN KEY (employee_id)
hr(>      REFERENCES employees (employee_id)
hr(>      ON UPDATE CASCADE
hr(>      ON DELETE CASCADE
hr(> );
CREATE TABLE
```
Let's see the table structure definition.

```console
hr=> \d dependents
                                           Table "public.dependents"
    Column    |         Type          | Collation | Nullable |                     Default
--------------+-----------------------+-----------+----------+--------------------------------------------------
 dependent_id | integer               |           | not null | nextval('dependents_dependent_id_seq'::regclass)
 first_name   | character varying(50) |           | not null |
 last_name    | character varying(50) |           | not null |
 relationship | character varying(25) |           | not null |
 employee_id  | integer               |           | not null |
Indexes:
    "dependents_pkey" PRIMARY KEY, btree (dependent_id)
Foreign-key constraints:
    "dependents_fkey_employee" FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON UPDATE CASCADE ON DELETE CASCADE
```
`parent table`:

```console
hr=> \d employees
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
