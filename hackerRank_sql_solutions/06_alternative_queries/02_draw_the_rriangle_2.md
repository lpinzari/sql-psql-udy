# Draw the Triangle 2

P(R) represents a pattern drawn by Julia in R rows. The following pattern represents P(5):

```console
*
* *
* * *
* * * *
* * * * *
```

Write a query to print the pattern P(20).


## SOLUTION

```SQL
WITH RECURSIVE rnum(n)
    AS (SELECT 1
            UNION ALL
            SELECT n+1
            FROM rnum
            WHERE n < 20)
SELECT REPEAT('* ', n)
FROM rnum;
```
