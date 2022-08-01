# Placements

You are given `three` tables:

1. Students,
2. Friends and
3. Packages.

- Students contains two columns: `ID` and `Name`.
- Friends contains two columns: `ID` and `Friend_ID` (ID of the ONLY best friend).
- Packages contains two columns: `ID` and `Salary` (offered salary in $ thousands per month).


**Students**

|Column|Type|
|:----:|:--:|
|ID|Integer|
|Name|String|


**Friends**

|Column|Type|
|:----:|:--:|
|ID|Integer|
|Friend_ID|Integer|

**Packages**

|Column|Type|
|:----:|:--:|
|ID|Integer|
|Salary|Float|



Write a query to output the `names of those students` whose **best friends got offered a higher salary than them**. Names must be **ordered by the salary amount** offered to the best friends. It is guaranteed that no two students got same salary offer.

## Sample Input

**Students**

|ID|Name|
|:-:|:--:|
|1|Ashley|
|2|Samantha|
|3|Julia|
|4|Scarlet|

**Friends**

|ID|Friend_ID|
|:-:|:------:|
|1|2|
|2|3|
|3|4|
|4|1|

**Packages**

|ID|Salary|
|:--:|:--:|
|1|15.20|
|2|10.06|
|3|11.55|
|4|12.12|

## Sample Output

```console
Samantha
Julia
Scarlet
```
## Explanation

See the following table:

|ID|1|2|3|4|
|:-:|:-:|:-:|:-:|:-:|
|Name|Ashley|Samantha|Julia|Scarlet|
|Salary|15.20|10.06|11.55|12.12|
|Friend_ID|2|3|4|1|
|Friend_Salary|10.06|11.55|12.12|15.20|

Now,

- Samantha's best friend got offered a higher salary than her at 11.55
- Julia's best friend got offered a higher salary than her at 12.12
- Scarlet's best friend got offered a higher salary than her at 15.2
- Ashley's best friend did NOT get offered a higher salary than her

The name output, when ordered by the salary offered to their friends, will be:

```console
Samantha
Julia
Scarlet
```

## Solution

```SQL
SELECT s.name, friend_id, salary
  FROM students s
 INNER JOIN friends f USING(id)
 INNER JOIN packages p USING(id);
```

```console
Samantha 14 15.5
Julia 15 15.6
Britney 18 16.7
Kristeen 19 18.8
Dyana 20 31.5
Jenny 5 45
Christene 6 47
```
```SQL
SELECT s.name, p.salary, fp.id, fp.salary
  FROM students s
 INNER JOIN friends f USING(id)
 INNER JOIN packages p USING(id)
 INNER JOIN Packages fp
    ON f.friend_id = fp.id;
```
```console
Priyanka 11.1 1 15.5 <----- 15.1 > 11.1
Paige 12.1 2 15.6 <------- 15.6 > 12.1
Jane 13.1 3 16.7 <----- 16.7 > 13.1
Belvet 14.1 4 18.8 <-----
Jenny 45 5 31.5
Christene 47 6 45
Meera 46 7 47 <---
Priya 39 8 46 <---
Scarlet 15.1 9 39 <----
Salma 17.1 10 11.1
Amanda 21.1 11 12.1
Maria 31.1 12 13.1
Stuart 13.15 13 14.1 <---
Samantha 15.5 14 15.1
Julia 15.6 15 17.1 <----
Aamina 33.33 16 21.1
Amina 22.16 17 31.1 <---
Britney 16.7 18 13.15
Kristeen 18.8 19 33.33 <---
Dyana 31.5 20 22.16
```

```SQL
SELECT s.name
  FROM students s
 INNER JOIN friends f USING(id)
 INNER JOIN packages p USING(id)
 INNER JOIN Packages fp
    ON f.friend_id = fp.id
 WHERE fp.Salary > p.Salary
 ORDER BY fp.Salary;
```

```console
Stuart
Priyanka
Paige
Jane
Julia
Belvet
Amina
Kristeen
Scarlet
Priya
Meera 
```
