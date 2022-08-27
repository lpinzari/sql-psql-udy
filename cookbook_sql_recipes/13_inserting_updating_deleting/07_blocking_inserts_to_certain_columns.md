# Blocking Inserts to Certain Columns Problem

You want to prevent users, or an errant software application, from inserting values into certain table columns. For example, you want to allow a program to insert into `EMP`, but only into the `EMPNO`, `ENAME`, and `JOB` columns.

## Solution

**Create a view** on the table exposing only those columns you want to expose. Then `force all inserts to go through that view.`


For example, to create a view exposing the three columns in `EMP`:

```SQL
CREATE VIEW new_emps AS
    SELECT empno, ename, job
      FROM emp;
```

**Grant access to this view to those users and programs allowed to populate only the three fields in the view**.

Do not grant those users insert access to the `EMP` table. Users may then create new `EMP` records by inserting into the `NEW_EMPS` view, but they will not be able to provide values for columns other than the three that are specified in the view definition.

## Discussion

When you insert into a simple view such as in the solution, your database server will translate that insert into the underlying table. For example, the following insert:

```SQL
INSERT INTO new_emps
       (empno, ename, job)
VALUES (1, 'Jonathan', 'Editoe');
```

will be translated behind the scenes into:

```SQL
INSERT INTO emp
       (empno, ename, job)
VALUES (1, 'Jonathan', 'Editoe');
```
   
