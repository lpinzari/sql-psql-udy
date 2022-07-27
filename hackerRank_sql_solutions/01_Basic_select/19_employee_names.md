# Employee names

[Problem](https://www.hackerrank.com/challenges/name-of-employees/problem?isFullScreen=true)

Write a query that prints a list of employee **names** (i.e.: the name attribute) from the **Employee** table in alphabetical order.

## Input Format

The **Employee** table containing employee data for a company is described as follows:

|Column|Type|
|:----:|:---:|
|employee_id|Integer|
|name|String|
|months|Integer|
|salary|Integer|


where employee_id is an employee's ID number, name is their name, months is the total number of months they've been working for the company, and salary is their monthly salary.

```SQL
SELECT name
  FROM employee
 ORDER BY name;
```
