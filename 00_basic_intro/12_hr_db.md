# HR sample database

The HR database contains the HR information for a fictitious (and very small) business company.

![hr database](./images/13_hr.png)

The picture above shows a summary of each table's columns in query diagram form. Note that, once again, one or more columns in each table have a small picture of a **key beside the column name**, identifying **visually the columns that act as keys for that table**.

The following table shows the table names and the number of records.

| Table  | Rows |
|:-------|:----:|
|employees|40|
|dependents|30|
|departments|11|
|jobs|11|
|locations|7|
|countries|25|
|regions|4|

### jobs

The **jobs** table stores the job data including job title and salary. It's **columns** are as follows:

- **job_id**: A `SERIAL` containing a **unique** integer number for each job.
- **job_title**: A `VARCHAR (35)` containing this job's title.
- **min_salary**: A `NUMERIC (8,2)` containing this job's minimum monthly salary.
- **max_salary**: A `NUMERIC (8,2)` containing this job's maximum monthly salary.

Because it contains a unique value for each record, the **job_id** column is designated as the **key** for this table.

**NOTE**: The word `SERIAL` is a PostgreSQL's `pseudo-type` that indicates an `auto-increment` column. Every time we insert a record in the table, the DBMS generates automatically the next integer in the sequence. Don't worry if you don't understand yet the mechanism behind the `SERIAL` type, we'll discuss about this concept later in the course.

### regions

Another table in this database is the **regions** table. The **regions** table stores the data of regions such as Asia, Europe, America, the Middle East and Africa. The `countries` are grouped into regions. It's **columns** are as follows:

- **region_id**: A `SERIAL` containing a **unique** integer number for each region.
- **region_name**: A `VARCHAR (25)` containing a region's name.

Because it contains a unique value for each record, the **region_id** column is designated as the **key** for this table.

### countries

A third table in this database is the **countries** table. The **countries** table stores the data of countries where the company is doing business. It's **columns** are as follows:

- **country_id**: A `CHAR (2)` containing a **unique** two letters word for each country.
- **country_name**: A `VARCHAR (40)` containing a country's name.
- **region_id**: A `INTEGER` identifying the region of this country. `Values in this column are drawn from the column of the same name in the` **region** `table`.

Because it contains a unique value for each record, the **country_id** column is designated as the **key** for this table.

### locations

A fourth table in this database is the **locations** table. The **locations** table stores the location of the `departments` of the company. It's **columns** are as follows:

- **location_id**: A `SERIAL` containing a **unique** integer number for each location.
- **street_address**: A `VARCHAR (40)` containing this location's address.
- **postal_code**: A `VARCHAR (12)` containing this location's postal code.
- **city**: A `VARCHAR (30)` containing this location's city.
- **state_province**: A `VARCHAR (25)` containing this location's state province.
- **country_id**: A `CHAR (2)` identifying the country of this location. `Values in this column are drawn from the column of the same name in the` **countries** table.

Because it contains a unique value for each record, the **location_id** column is designated as the **key** for this table.

### departments

A fifth table in this database is the **departments** table. The **departments** table stores the department data. It's **columns** are as follows:

- **department_id**: A `SERIAL` containing a **unique** integer number for each department.
- **department_name**: A `VARCHAR (30)` containing a department's name.
- **location_id**: A `INTEGER` identifying the location of this department. `Values in this column are drawn from the column of the same name in the` **locations** table.

Because it contains a unique value for each record, the **department_id** column is designated as the **key** for this table.

### dependents

Another table in this database is the **dependents** table. The **dependents** table stores the employee's dependents data. It's **columns** are follows:

- **dependent_id**: A `SERIAL` containing a **unique** integer number for each dependent.
- **first_name**: A `VARCHAR (50)` containing a dependent's first name.
- **last_name**: A `VARCHAR (50)` containing a dependent's last name.
- **relationsship**: A `VARCHAR (25)` containing the employee's relationship of this dependent.
- **employee_id**: A `INTEGER` identifying the employee of this dependent. `Values in this column are drawn from the column of the same name in the` **employees** table.

Because it contains a unique value for each record, the **dependent_id** column is designated as the **key** for this table.

### employees

The final table in this database is the **employees** table. The **employees** table stores the data of employees. It's **columns** are as follows:

- **employee_id**: A `SERIAL` containing a **unique** integer number for each employee.
- **first_name**: A `VARCHAR (20)` containing an employee's first name.
- **last_name**: A `VARCHAR (25)` containing an employee's last name.
- **email**: A `VARCHAR (100)` containing this employee's email.
- **phone_number**: A `VARCHAR (20)` containing this employee's phone number.
- **hire_date**: A `DATE` containing this employee's hiring date.
- **job_id**: A `INTEGER` identifying the job of this employee . `Values in this column are drawn from the column of the same name of the` **jobs** table.
- **salary**: A `NUMERIC (8,2)` containing this employee's salary.
- **manager_id**: A `INTEGER` identifying this employee's manager. `Values in this column are drawn from the column employee_id in the` **employees** table.
- **department_id**: A `INTEGER` containing this employee's department. `Values in this column are drawn from the column of the same name in the` **departments** table.

Because it contains a unique value for each record, the **employee_id** column is designated as the **key** for this table.
