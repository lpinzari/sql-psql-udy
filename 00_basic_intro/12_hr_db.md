# HR sample database

The HR database contains the HR information for a fictitious (and very small) business company.

![hr database](./images/13_hr.png)

The picture above shows a summary of each table's columns in query diagram form. Note that, once again, one or more columns in each table have a small picture of a **key beside the column name**, identifying **visually the columns that act as keys for that table**.

### jobs

The **jobs** table stores the job data including job title and salary. It's **columns** are as follows:

- **job_id**: A `SERIAL` containing a **unique** integer number for each job.
- **job_title**: A `VARCHAR (35)` containing this job's title.
- **min_salary**: A `NUMERIC (8,2)` containing this job's minimum monthly salary.
- **max_salary**: A `NUMERIC (8,2)` containing this job's maximum monthly salary.

Because it contains a unique value for each record, the **job_id** column is designated as the **key** for this table.

**NOTE**: The word `SERIAL` is a PostgreSQL's `pseudo-type` that indicates an `auto-increment` column. Every time we insert a record in the table, the DBMS generates automatically the next integer in the sequence. Don't worry if you don't understand yet the mechanism behind the `SERIAL` type, we'll discuss about this concept later in the course. For now, it suffice to know that **the system will automatically generate a unique, sequential number, and will enforce a unique value constraint**.

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

## HR table records

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

### regions

|region_id | region_name|
|:---------|:----------:|
|1         |Europe|
|2         |Americas|
|3         |Asia|
|4         |Middle East and Africa|

### countries

|country_id | country_name | region_id |
|:----------|:------------:|----------:|
|AR|Argentina|2|
|AU|Australia|3|
|BE|Belgium|1|
|BR|Brazil|2|
|CA|Canada|2|
|CH|Switzerland|1|
|CN|China|3|
|DE|Germany|1|
|DK|Denmark|1|
|EG|Egypt|4|
|FR|France|1|
|HK|HongKong|3|
|IL|Israel|4|
|IN|India|3|
|IT|Italy|1|
|JP|Japan|3|
|KW|Kuwait|4|
|MX|Mexico|2|
|NG|Nigeria|4|
|NL|Netherlands|1|
|SG|Singapore|3|
|UK|United Kingdom|1|
|US|United States of America|2|
|ZM|Zambia|4|
|ZW|Zimbabwe|4|

### locations

|location_id|street_address|postal_code|city|state_province|country_id|
|:----------|:------------:|:---------:|:--:|:------------:|---------:|
|1400|2014 Jabberwocky Rd|26192|Southlake|Texas|US|
|1500|2011 Interiors Blvd|99236|South San Francisco|California|US|
|1700|2004 Charade Rd|98199|Seattle|Washington|US|
|1800|147 Spadina Ave|M5V 2L7|Toronto|Ontario|CA|
|2400|8204 Arthur St||London||UK|
|2500|Magdalen Centre, The Oxford Science Park|OX99ZB|Oxford|Oxford|UK|
|2700|Schwanthalerstr. 7031|80925|Munich|Bavaria|DE|

### jobs

|job_id|job_title|min_salary|max_salary|
|:-----|:-------:|:--------:|:--------:|
|1|Public Accountant|4200.00|9000.00|
|2|Accounting Manager|8200.00|16000.00|
|3|Administrator Assistant|3000.00|6000.00|
|4|President|20000.00|40000.00|
|5|Administration Vice President|15000.00|30000.00|
|6|Accountant|4200.00|9000.00|
|7|Finance Manager|8200.00|16000.00|
|8|human Resources Representative|4000.00|9000.00|
|9|Programmer|4000.00|10000.00|
|10|Marketing Manager|9000.00|15000.00|
|11|Marketing Representative|4000.00|9000.00|
|12|Public Relations Representative|4500.00|10500.00|
|13|Purchasing Clerk|2500.00|5500.00|
|14|Purchasing Manager|8000.00|15000.00|
|15|Sales Manager|10000.00|20000.00|
|16|Sales Representative|6000.00|12000.00|
|17|Shipping Clerk|2500.00|5500.00|
|18|Stock Clerk|2000.00|5000.00|
|19|Stock Manager|5500.00|8500.00|

### departments

|department_id|department_name|location_id|
|:------------|:-------------:|----------:|
|1|Administration|1700|
|2|Marketing|1800|
|3|Purchasing|1700|
|4|Human Resources|2400|
|5|Shipping|1500|
|6|IT|1400|
|7|Public Relations|2700|
|8|Sales|2500|
|9|Executive|1700|
|10|Finance|1700|
|11|Accounting|1700|

### employees

|employee_id|first_name|last_name|email|phone_number|hire_date|job_id|salary|manager_id|department_id|
|:----------|:--------:|:-------:|:---:|:----------:|:---------:|:----:|:----:|:--------:|----------:|
|100|Steven|King|steven.king@sqltutorial.org|515.123.4567|1987-06-17|4|24000.00||9|
|101|Neena|Kochhar|neena.kochhar@sqltutorial.org|515.123.4568|1989-09-21|5|17000.00|100|9|
|102|Lex|De Haan|lex.dehaan@sqltutorial.org|515.123.4569|1993-01-13|5|17000.00|100|9|
|103|Alexander|Hunold|alexander.hunold@sqltutorial.org|590.423.4567|1990-01-03|9|9000.00|102|6|
|104|Bruce|Ernst|bruce.ernst@sqltutorial.org|590.423.4568|1991-05-21|9|6000.00|103|6|
|105|David|Austin|david.austin@sqltutorial.org|590.423.4569|1997-06-25|9|4800.00|103|6|
|106|Valli|Pataballa|valli.pataballa@sqltutorial.org|590.423.4560|1998-02-05|9|4800.00|103|6|
|107|Diana|Lorentz|diana.lorentz@sqltutorial.org|590.423.5567|1999-02-07|9|4200.00|103|6|
|108|Nancy|Greenberg|nancy.greenberg@sqltutorial.org|515.124.4569|1994-08-17|7|12000.00|101|10|
|109|Daniel|Faviet|daniel.faviet@sqltutorial.org|515.124.4169|1994-08-16|6|9000.00|108|10|
|110|John|Chen|john.chen@sqltutorial.org|515.124.4269|1997-09-28|6|8200.00|108|10|
|111|Ismael|Sciarra|ismael.sciarra@sqltutorial.org|515.124.4369|1997-09-30|6|7700.00|108|10|
|112|Jose Manuel|Urman|josemanuel.urman@sqltutorial.org|515.124.4469|1998-03-07|6|7800.00|108|10|
|113|Luis|Popp|luis.popp@sqltutorial.org|515.124.4567|1999-12-07|6|6900.00|108|10|
|114|Den|Raphaely|den.raphaely@sqltutorial.org|515.127.4561|1994-12-07|14|11000.00|100|3|
|115|Alexander|Khoo|alexander.khoo@sqltutorial.org|515.127.4562|1995-05-18|13|3100.00|114|3|
|116|Shelli|Baida|shelli.baida@sqltutorial.org|515.127.4563|1997-12-24|13|2900.00|114|3|
|117|Sigal|Tobias|sigal.tobias@sqltutorial.org|515.127.4564|1997-07-24|13|2800.00|114|3|
|118|Guy|Himuro|guy.himuro@sqltutorial.org|515.127.4565|1998-11-15|13|2600.00|114|3|
|119|Karen|Colmenares|karen.colmenares@sqltutorial.org|515.127.4566|1999-08-10|13|2500.00|114|3|
|120|Matthew|Weiss|matthew.weiss@sqltutorial.org|650.123.1234|1996-07-18|19|8000.00|100|5|
|121|Adam|Fripp|adam.fripp@sqltutorial.org|650.123.2234|1997-04-10|19|8200.00|100|5|
|122|Payam|Kaufling|payam.kaufling@sqltutorial.org|650.123.3234|1995-05-01|19|7900.00|100|5|
|123|Shanta|Vollman|shanta.vollman@sqltutorial.org|650.123.4234|1997-10-10|19|6500.00|100|5|
|126|Irene|Mikkilineni|irene.mikkilineni@sqltutorial.org|650.124.1224|1998-09-28|18|2700.00|120|5|
|145|John|Russell|john.russell@sqltutorial.org||1996-10-01|15|14000.00|100|8|
|146|Karen|Partners|karen.partners@sqltutorial.org||1997-01-05|15|13500.00|100|8|
|176|Jonathon|Taylor|jonathon.taylor@sqltutorial.org||1998-03-24|16|8600.00|100|8|
|177|Jack|Livingston|jack.livingston@sqltutorial.org||1998-04-23|16|8400.00|100|8|
|178|Kimberely|Grant|kimberely.grant@sqltutorial.org||1999-05-24|16|7000.00|100|8|
|179|Charles|Johnson|charles.johnson@sqltutorial.org||2000-01-04|16|6200.00|100|8|
|192|Sarah|Bell|sarah.bell@sqltutorial.org|650.501.1876|1996-02-04|17|4000.00|123|5|
|193|Britney|Everett|britney.everett@sqltutorial.org|650.501.2876|1997-03-03|17|3900.00|123|5|
|200|Jennifer|Whalen|jennifer.whalen@sqltutorial.org|515.123.4444|1987-09-17|3|4400.00|101|1|
|201|Michael|Hartstein|michael.hartstein@sqltutorial.org|515.123.5555|1996-02-17|10|13000.00|100|2|
|202|Pat|Fay|pat.fay@sqltutorial.org|603.123.6666|1997-08-17|11|6000.00|201|2|
|203|Susan|Mavris|susan.mavris@sqltutorial.org|515.123.7777|1994-06-07|8|6500.00|101|4|
|204|Hermann|Baer|hermann.baer@sqltutorial.org|515.123.8888|1994-06-07|12|10000.00|101|7|
|205|Shelley|Higgins|shelley.higgins@sqltutorial.org|515.123.8080|1994-06-07|2|12000.00|101|11|
|206|William|Gietz|william.gietz@sqltutorial.org|515.123.8181|1994-06-07|1|8300.00|205|11|

### dependents

|dependent_id|first_name|last_name|relationship|employee_id|
|:-----------|:--------:|:-------:|:----------:|----------:|
|1|Penelope|Gietz|Child|206|
|2|Nick|Higgins|Child|205|
|3|Ed|Whalen|Child|200|
|4|Jennifer|King|Child|100|
|5|Johnny|Kochhar|Child|101|
|6|Bette|De Haan|Child|102|
|7|Grace|Faviet|Child|109|
|8|Matthew|Chen|Child|110|
|9|Joe|Sciarra|Child|111|
|10|Christian|Urman|Child|112|
|11|Zero|Popp|Child|113|
|12|Karl|Greenberg|Child|108|
|13|Uma|Mavris|Child|203|
|14|Vivien|Hunold|Child|103|
|15|Cuba|Ernst|Child|104|
|16|Fred|Austin|Child|105|
|17|Helen|Pataballa|Child|106|
|18|Dan|Lorentz|Child|107|
|19|Bob|Hartstein|Child|201|
|20|Lucille|Fay|Child|202|
|21|Kirsten|Baer|Child|204|
|22|Elvis|Khoo|Child|115|
|23|Sandra|Baida|Child|116|
|24|Cameron|Tobias|Child|117|
|25|Kevin|Himuro|Child|118|
|26|Rip|Colmenares|Child|119|
|27|Julia|Raphaely|Child|114|
|28|Woody|Russell|Child|145|
|29|Alec|Partners|Child|146|
|30|Sandra|Taylor|Child|176|

## Recursive Relationship in ERD

In the `uniy` sample database lesson we learned how the table's **primary** and **foreign** **keys** are used to **create relationships** between **tables**.

The `table` that **contains** the **foreign key** is called the referencing table or `child` **table**.

And the `table` **referenced by** the **foreign key** is called the referenced table or `parent` **table**.

What happen if the **child** `table`, (the table that contains the foreign key), **references its primary key** ?

For example, in the table **employees** of the `HR` sample database the values in the  column `manager_id` references the values in the table's primary key column `employee_id`.

This is clear if we look at the records of the **employees** table.

|employee_id|first_name|last_name|email|phone_number|hire_date|job_id|salary|manager_id|department_id|
|:----------|:--------:|:-------:|:---:|:----------:|:---------:|:----:|:----:|:--------:|----------:|
|100|Steven|King|steven.king@sqltutorial.org|515.123.4567|1987-06-17|4|24000.00||9|
|101|Neena|Kochhar|neena.kochhar@sqltutorial.org|515.123.4568|1989-09-21|5|17000.00|100|9|
|102|Lex|De Haan|lex.dehaan@sqltutorial.org|515.123.4569|1993-01-13|5|17000.00|100|9|
|103|Alexander|Hunold|alexander.hunold@sqltutorial.org|590.423.4567|1990-01-03|9|9000.00|102|6|
|104|Bruce|Ernst|bruce.ernst@sqltutorial.org|590.423.4568|1991-05-21|9|6000.00|103|6|

For example, the employee `Bruce Ernst`, record:

- (**104**, `Bruce`, `Ernst`,...,**103**,6) -> `manager_id`: **103**

has a supervisor named `Alexander Hunold`, record:

- (**103**, `Alexander`,`Hunold`,...,**102**,6) -> `manager_id`: **102**

And the supervisor of Alexander Hunold is `Lex De Haan`, record:

- (**102**, `Lex`,`De Haan`,...,**100**,9) -> `manager_id`: **100**

And the supervisor of Lex De Haan is `Steven King`, record:

- (**100**, `Steven`, `King`,...,**...**,) -> `manager_id`: **NULL**

Lastly, Steven King **does not have a supervisor**.

Recalling the concept of foreign key given in the previous lesson: A foreign key refers to one record in another table. In this example, there is more than a single relationship. **The table employees recursively refers to itself three times**.

- `104` **->** `103` **->** `102` **->** `100`

In this example, the right arrow **->** indicates the relationship between the child record and the parent record. Specifically, the **->** indicates the relationship **reports to**.  

Therefore,

1. the employee `104` **reports to** the employee `103`, manager (supervisor).
2. the employee `103` **reports to** the employee `102`, manager (supervisor).
3. the employee `102` **reports to** the employee `100`, manager (supervisor).
4. the employee `100` does not reports to any manager, he is the CEO :smile:.

- `104` **<-** `103` **<-** `102` **<-** `100`

On the other way around, the left arrow **<-** indicates the relationship between the parent record and the child record. Specifically, the **<-** indicates the relationship **manages**.

Therefore,

1. the employee `100` **manages** the employee `102`, subordinate.
2. the employee `102` **manages** the employee `103`, subordinate.
3. the employee `103` **manages** the employee `104`.
4. the employee `104` does not manage any employee, he is not a supervisor.

Here the same entity type participates more than once in a relationship type with a different role for each instance.

For example, the record with column `employee_id`: `103` participates in two relationships:
1. the employee **103** **reports to** the employee `102`:
  - `103` is the **subordinate** of the employee `102`.
2. the employee **103** **manages** the employee `104`
  - `103` is the **supervisor** of the employee `104`.

Thus, all the employees, (`104`,`103`,`102`), have one supervisor except the CEO, (`100`), **Steven King**. In this case, the foreign key **may references** another record in the same table. The employee record `100` **does not references any record**, (in SQL is a `NULL` value, don't worry if you don't understand right now.. it will be clear in the later lessons). Therefore, an employee **may** or **may not** have a boss or supervisor. It follows that

- a record can references **zero or one** record.

Similarly, an employee can be the boss or supervisor of **zero or many** employees. For example, the employee `104` does not manage any employee and therefore is not referenced by any record. On the other hand, the employee `100` manages **14** employees.

It follows, that

- a record may be referenced by **zero or many** records.


|employee_id|first_name|last_name|email|phone_number|hire_date|job_id|salary|manager_id|department_id|
|:----------|:--------:|:-------:|:---:|:----------:|:---------:|:----:|:----:|:--------:|----------:|
|**100**|Steven|King|steven.king@sqltutorial.org|515.123.4567|1987-06-17|4|24000.00||9|
|101|Neena|Kochhar|neena.kochhar@sqltutorial.org|515.123.4568|1989-09-21|5|17000.00|**100**|9|
|102|Lex|De Haan|lex.dehaan@sqltutorial.org|515.123.4569|1993-01-13|5|17000.00|100|9|
|114|Den|Raphaely|den.raphaely@sqltutorial.org|515.127.4561|1994-12-07|14|11000.00|**100**|3|
|120|Matthew|Weiss|matthew.weiss@sqltutorial.org|650.123.1234|1996-07-18|19|8000.00|**100**|5|
|121|Adam|Fripp|adam.fripp@sqltutorial.org|650.123.2234|1997-04-10|19|8200.00|**100**|5|
|122|Payam|Kaufling|payam.kaufling@sqltutorial.org|650.123.3234|1995-05-01|19|7900.00|**100**|5|
|123|Shanta|Vollman|shanta.vollman@sqltutorial.org|650.123.4234|1997-10-10|19|6500.00|**100**|5|
|145|John|Russell|john.russell@sqltutorial.org||1996-10-01|15|14000.00|**100**|8|
|146|Karen|Partners|karen.partners@sqltutorial.org||1997-01-05|15|13500.00|**100**|8|
|176|Jonathon|Taylor|jonathon.taylor@sqltutorial.org||1998-03-24|16|8600.00|**100**|8|
|177|Jack|Livingston|jack.livingston@sqltutorial.org||1998-04-23|16|8400.00|**100**|8|
|178|Kimberely|Grant|kimberely.grant@sqltutorial.org||1999-05-24|16|7000.00|**100**|8|
|179|Charles|Johnson|charles.johnson@sqltutorial.org||2000-01-04|16|6200.00|**100**|8|
|201|Michael|Hartstein|michael.hartstein@sqltutorial.org|515.123.5555|1996-02-17|10|13000.00|**100**|2|

The record with primary key's, `employee_id`, value **100** appears in the column `manager_id` of **14** records.

Every employee can have a supervisor except the CEO and there can be at most one boss for each employee. One employee may be the boss of more than one employee.

Supervisors and subordinates are called “Role Names”. Here the degree of the REPORTS_TO relationship is 1 i.e. a unary relationship.

- The minimum cardinality of the Supervisor entity is ZERO since the lowest level employee may not be a manager for anyone.
- The maximum cardinality of the Supervisor entity is N since an employee can manage many employees.
- Similarly, the Subordinate entity has a minimum cardinality of ZERO to account for the case where CEO can never be a subordinate.
- Its maximum cardinality is ONE since a subordinate employee can have at most one supervisor.

The **recursive relationship** of the **employees** table can be stated as follow:

- An employee can be a manager of `zero or more` employees: a record in the **employees** table is **referenced by** `zero or more` records in the **employees** table.
- An employee reports to `zero or one employee`: a record in the **employees** table **references** `zero or one` record in the **employees** table.

## HR Relationships

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

The `jobs` and `regions` tables are the only ones that do not reference any table.

![hr database2](./images/14_hr.png)

The picture above illustrates the `referenced_by` **relationship** between tables, or **parent** **relationship** graph :smile:

Let's describe all the **(** **parent**,`child`**)** **relationships** in the UniY sample database.

![hr database](./images/13_hr.png)

**(** **jobs**, `employees`**)**

The relationship between the **jobs** and `employees` tables can be stated as follow:

- **referenced by**: A job can have zero or many employees. A record in the **jobs** table is **referenced by**  `zero or more` records in the `employees` table.
- **references**: An employee in a company `has one and only one` job. A record in the `employees` table **must references** a record in the **jobs** table.

**(** **regions**, `countries`**)**

The relationship between the **regions** and `countries` tables can be stated as follow:

- **referenced by**: A region can have zero or many countries. A record in the **regions** table is **referenced by**  `zero or more` records in the `countries` table.
- **references**: A country belongs to `one and only one` region. A record in the `country` table **must references** a record in the **regions** table.

**(** **countries**, `locations`**)**

The relationship between the **countries** and `locations` tables can be stated as follow:

- **referenced by**: A country can have zero or many locations. A record in the **countries** table is **referenced by**  `zero or more` records in the `locations` table.
- **references**: A location belongs to `one and only one` country. A record in the `locations` table **must references** a record in the **countries** table.

**(** **locations**, `departments`**)**

The relationship between the **locations** and `departments` tables can be stated as follow:

- **referenced by**: A location can have zero or many departments. A record in the **locations** table is **referenced by**  `zero or more` records in the `departments` table.
- **references**: A department may have a location. A record in the `departments` table **can references** `zero or one` record in the **locations** table.

**(** **departments**, `employees`**)**

The relationship between the **departments** and `employees` tables can be stated as follow:

- **referenced by**: A department can have zero or many employees. A record in the **departments** table is **referenced by**  `zero or more` records in the `employees` table.
- **references**: An employee can be assigned to `zero or one` department. A record in the `employees` table **references** `zero or one` record in the **departments** table.

**(** **employees**, `dependents`**)**

The relationship between the **employees** and `dependents` tables can be stated as follow:

- **referenced by**: An employee can have zero or many dependents. A record in the **employees** table is **referenced by**  `zero or more` records in the `dependents` table.
- **references**: A dependent has `one and only one` employee. A record in the `dependents` table **must references** a record in the **employees** table.

**(** **employees**, `employees`**)**

The relationship between the **employees** and `employees` tables (Recursive relationship) can be stated as follow:

- **referenced by**: An employee can be a manager of `zero or more` employees. A record in the **employees** table is **referenced by** `zero or more` records in the **employees** table.
- **references**: An employee reports to `zero or one employee`. A record in the **employees** table **references** `zero or one` record in the **employees** table.
