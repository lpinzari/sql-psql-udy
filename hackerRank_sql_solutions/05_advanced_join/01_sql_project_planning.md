# Project Planning

You are given a table, Projects, containing three columns: `Task_ID`, `Start_Date` and `End_Date`.

It is guaranteed that the difference between the `End_Date` and the `Start_Date` is **equal to 1 day for each row in the table**.

|Column|Type|
|:----:|:--:|
|Task_ID |Integer|
|Start_Date|Date|
|End_Date|Date|

If the `End_Date` of the tasks are **consecutive**, then **they are part of the same project**.

Samantha is interested in finding the **total number of different projects completed**.

Write a query to **output** the `start` and `end dates` of projects listed by the **number of days it took to complete the project in ascending order**. If there is more than one project that have the same number of completion days, then `order` by the **start date of the project**.

## Sample Input

|Task_ID|Start_Date|End_Date|
|:-----:|:--------:|:-------:|
|1|**2015-10-01**|2015-10-02|
|2|2015-10-02|2015-10-03|
|3|2015-10-03|2015-10-04|
|4|**2015-10-13**|2015-10-14|
|5|2015-10-14|2015-10-15|
|6|**2015-10-28**|2015-10-29|
|7|**2015-10-30**|2015-10-31|

## Sample Output

```console
2015-10-28 2015-10-29
2015-10-30 2015-10-31
2015-10-13 2015-10-15
2015-10-01 2015-10-04
```

## Explanation

The example describes following four projects:

- **Project 1**: Tasks 1, 2 and 3 are completed on consecutive days, so these are part of the project. Thus start date of project is 2015-10-01 and end date is 2015-10-04, so it took 3 days to complete the project.
- **Project 2**: Tasks 4 and 5 are completed on consecutive days, so these are part of the project. Thus, the start date of project is 2015-10-13 and end date is 2015-10-15, so it took 2 days to complete the project.
- **Project 3**: Only task 6 is part of the project. Thus, the start date of project is 2015-10-28 and end date is 2015-10-29, so it took 1 day to complete the project.
- **Project 4**: Only task 7 is part of the project. Thus, the start date of project is 2015-10-30 and end date is 2015-10-31, so it took 1 day to complete the project.


## Solution

If the `End_Date` of the tasks are **consecutive**, then **they are part of the same project** and the difference between the `End_Date` and the `Start_Date` is **equal to 1 day for each row in the table**. Thus, tasks of the same project cannot have the same `Start_Date` and `End_Date`.


```console
 START                              START             START     START
    01   02   03   04    05  ......     13   14   15  ..  28   29   30   31
-----|----|----|----|----|--------------|----|----|-------|----|----|----|
    (S)    E
1    *----*
          S    E
2         *----*
               S   (E)
3              *----*
                                       (S)   E
4                                       *----*
                                             S   (E)
5                                            *----*
                                                         (S)  (E)
6                                                         *----*
                                                                   (S)  (E)
7                                                                   *----*
```

This picture shows that the beginning date of each Project is not overlapping with the ending date of the previous project, meaning that all rows in the project table with Start_Date values not in the End_Date column ae the rows belonging to the Beginning date projects.

Similarly, the End_Date values in projects table that are not in the Start_Date column are the rows of the last task completed and, therefore, the End_Date of the project.

**starting date of the projects**

```SQL
SELECT Start_Date as Proj_Start_Date
  FROM Projects
 WHERE Start_Date NOT IN (SELECT End_Date FROM Projects);
```

```console
2015-10-01
2015-10-11
2015-10-15
2015-10-17
2015-10-19
2015-10-21
2015-10-25
2015-11-01
2015-11-04
2015-11-11
2015-11-17
```

There are 11 projects.


**ending dates of the projects**

```SQL
SELECT End_Date as Proj_End_Date
  FROM Projects
 WHERE End_Date NOT IN (SELECT Start_Date FROM Projects);
```

```console
2015-10-05
2015-10-13
2015-10-16
2015-10-18
2015-10-20
2015-10-22
2015-10-31
2015-11-02
2015-11-08
2015-11-13
2015-11-18
```

**combine the results**

```SQL
SELECT s.Proj_Start_Date, e.Proj_End_Date
  FROM (SELECT Start_Date as Proj_Start_Date
         FROM Projects
        WHERE Start_Date NOT IN (SELECT End_Date FROM Projects)) s,
       (SELECT End_Date as Proj_End_Date
          FROM Projects
         WHERE End_Date NOT IN (SELECT Start_Date FROM Projects)) e
  WHERE s.Proj_Start_Date < e.Proj_End_Date
  ORDER BY s.Proj_Start_Date, e.Proj_End_Date;
```

```console
2015-10-01 2015-10-05 <-----
2015-10-01 2015-10-13
2015-10-01 2015-10-16
2015-10-01 2015-10-18
2015-10-01 2015-10-20
2015-10-01 2015-10-22
2015-10-01 2015-10-31
2015-10-01 2015-11-02
2015-10-01 2015-11-08
2015-10-01 2015-11-13
2015-10-01 2015-11-18
--------------------------
2015-10-11 2015-10-13 <------
2015-10-11 2015-10-16
2015-10-11 2015-10-18
2015-10-11 2015-10-20
2015-10-11 2015-10-22
2015-10-11 2015-10-31
2015-10-11 2015-11-02
2015-10-11 2015-11-08
2015-10-11 2015-11-13
2015-10-11 2015-11-18
--------------------------
2015-10-15 2015-10-16 <------
2015-10-15 2015-10-18
2015-10-15 2015-10-20
2015-10-15 2015-10-22
2015-10-15 2015-10-31
2015-10-15 2015-11-02
2015-10-15 2015-11-08
2015-10-15 2015-11-13
2015-10-15 2015-11-18
----------------------------
2015-10-17 2015-10-18 <------
2015-10-17 2015-10-20
2015-10-17 2015-10-22
2015-10-17 2015-10-31
2015-10-17 2015-11-02
2015-10-17 2015-11-08
2015-10-17 2015-11-13
2015-10-17 2015-11-18
----------------------------
2015-10-19 2015-10-20 <--------
2015-10-19 2015-10-22
2015-10-19 2015-10-31
2015-10-19 2015-11-02
2015-10-19 2015-11-08
2015-10-19 2015-11-13
2015-10-19 2015-11-18
---------------------------
2015-10-21 2015-10-22 <----------
2015-10-21 2015-10-31
2015-10-21 2015-11-02
2015-10-21 2015-11-08
2015-10-21 2015-11-13
2015-10-21 2015-11-18
--------------------------
2015-10-25 2015-10-31 <----------
2015-10-25 2015-11-02
2015-10-25 2015-11-08
2015-10-25 2015-11-13
2015-10-25 2015-11-18
--------------------------
2015-11-01 2015-11-02 <------------
2015-11-01 2015-11-08
2015-11-01 2015-11-13
2015-11-01 2015-11-18
--------------------------
2015-11-04 2015-11-08 <------------
2015-11-04 2015-11-13
2015-11-04 2015-11-18
--------------------------
2015-11-11 2015-11-13 <------------
2015-11-11 2015-11-18
--------------------------
2015-11-17 2015-11-18 <-------------
```

Filter the first row of each group.

```SQL
SELECT s.Proj_Start_Date,
       min(e.Proj_End_Date) as Real_Proj_End_Date
  FROM (SELECT Start_Date as Proj_Start_Date
         FROM Projects
        WHERE Start_Date NOT IN (SELECT End_Date FROM Projects)) s,
       (SELECT End_Date as Proj_End_Date
          FROM Projects
         WHERE End_Date NOT IN (SELECT Start_Date FROM Projects)) e
  WHERE s.Proj_Start_Date < e.Proj_End_Date
  GROUP BY s.Proj_Start_Date;
  ORDER BY s.Proj_Start_Date;
```

```console
2015-10-01 2015-10-05
2015-10-11 2015-10-13
2015-10-15 2015-10-16
2015-10-17 2015-10-18
2015-10-19 2015-10-20
2015-10-21 2015-10-22
2015-10-25 2015-10-31
2015-11-01 2015-11-02
2015-11-04 2015-11-08
2015-11-11 2015-11-13
2015-11-17 2015-11-18
```


projects listed by the **number of days it took to complete the project in ascending order**. If there is more than one project that have the same number of completion days, then `order` by the **start date of the project**.

```SQL
SELECT s.Proj_Start_Date,
       min(e.Proj_End_Date) as Real_Proj_End_Date
  FROM (SELECT Start_Date as Proj_Start_Date
         FROM Projects
        WHERE Start_Date NOT IN (SELECT End_Date FROM Projects)) s,
       (SELECT End_Date as Proj_End_Date
          FROM Projects
         WHERE End_Date NOT IN (SELECT Start_Date FROM Projects)) e
  WHERE s.Proj_Start_Date < e.Proj_End_Date
  GROUP BY s.Proj_Start_Date
  ORDER BY DATEDIFF(min(e.Proj_End_Date), s.Proj_Start_Date) ASC, s.Proj_Start_Date ASC;
```

```console
2015-10-15 2015-10-16
2015-10-17 2015-10-18
2015-10-19 2015-10-20
2015-10-21 2015-10-22
2015-11-01 2015-11-02
2015-11-17 2015-11-18
2015-10-11 2015-10-13
2015-11-11 2015-11-13
2015-10-01 2015-10-05
2015-11-04 2015-11-08
2015-10-25 2015-10-31
```
