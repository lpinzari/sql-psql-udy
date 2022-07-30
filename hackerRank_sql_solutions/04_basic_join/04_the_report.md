# The Report

[Problem](https://www.hackerrank.com/challenges/the-report/problem?isFullScreen=true)

You are given two tables: **Students** and **Grades**. Students contains three columns `ID`, `Name` and `Marks`.

|Column|Type|
|:----:|:--:|
|ID|Integer|
|NAME|String|
|MARKS|Integer|


Grades contains the following data:

|Grade|Min_Mark|Max_Mark|
|:---:|:------:|:----:|
|1|0|9|
|2|10|19|
|3|20|29|
|4|30|39|
|5|40|49|
|6|50|59|
|7|60|69|
|8|70|79|
|9|80|89|
|10|90|99|

Ketty gives Eve a task to generate a report containing three columns: `Name`, `Grade` and `Mark`.

Ketty doesn't want the NAMES of those students who received a grade lower than 8. The report must be in **descending order by grade** -- i.e. higher grades are entered first. If there is more than one student with the same grade (`8-10`) assigned to them, order those particular students by their `name alphabetically`.

Finally, **if the grade is lower than 8**, use "`NULL`" as their name and list them by their grades in descending order. If there is more than one student with the same grade (`1-7`) assigned to them, order those particular students by **their marks in ascending order**.

Write a query to help Eve.

## Sample Input

|ID|Name|Marks|
|:----:|:---:|:---:|
|1|Julia|88|
|2|Samantha|68|
|3|Maria|99|
|4|Scarlet|78|
|5|Ashley|63|
|6|Jane|81|

## Sample Output

```console
Maria 10 99
Jane 9 81
Julia 9 88
Scarlet 8 78
---------------
NULL 7 63
NULL 7 68
```

**Note**: Print "`NULL`"  as the name if the grade is less than 8.


## Solution 


```SQL
SELECT CASE
         WHEN G.grade > 7 THEN S.name
         ELSE NULL
       end AS names,
       G.grade,
       S.marks
  FROM students S
  JOIN grades G ON S.marks BETWEEN G.min_mark AND G.max_mark
 ORDER BY G.grade DESC,
          names ASC,
          S.marks ASC;
```
