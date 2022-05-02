/*
-----------------------------------
   database: hr
   dbms: postgres (PostgreSQL) 11.4
   author: Ludovico Pinzari
-----------------------------------
*/

-- START A TRANSACTION
BEGIN;


-- ********************************
-- DESTROY the hr database schema
-- ********************************

DROP TABLE IF EXISTS
           dependents,
           employees,
           departments,
           locations,
           countries,
           regions,
           jobs
CASCADE;


-- ********************************
-- CREATE the hr database schema
-- ********************************

/*
------------------------------------
Level 0: jobs, regions
------------------------------------
*/

--
-- Table structure for jobs
--

CREATE TABLE jobs (
	job_id SERIAL PRIMARY KEY,
	job_title VARCHAR (35) NOT NULL,
	min_salary NUMERIC (8, 2),
	max_salary NUMERIC (8, 2)
);

--
-- Table structure for regions
--

CREATE TABLE regions (
	region_id SERIAL PRIMARY KEY,
	region_name VARCHAR (25)
);


/*
------------------------------------
Level 1: countries
------------------------------------
*/

--
-- Table structure for countries
--

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


/*
------------------------------------
Level 2: locations
------------------------------------
*/

--
-- Table structure for locations
--

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


/*
------------------------------------
Level 3: departments
------------------------------------
*/

--
-- Table structure for departments
--

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

/*
------------------------------------
Level 4: employees
------------------------------------
*/

--
-- Table structure for employees
--

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

/*
------------------------------------
Level 5: dependents
------------------------------------
*/

--
-- Table structure for dependents
--

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

-- COMMIT A TRANSACTION
COMMIT;
