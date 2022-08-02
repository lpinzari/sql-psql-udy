# Draw the Triangle 1

P(R) represents a pattern drawn by Julia in R rows. The following pattern represents P(5):

```console
* * * * *
* * * *
* * *
* *
*
```

Write a query to print the pattern P(20).

## SOLUTION

```SQL
WITH RECURSIVE rnum(n)
    AS (SELECT 20
            UNION ALL
            SELECT n-1
            FROM rnum
            WHERE n > 1)
SELECT REPEAT('* ', n)
FROM rnum; 
```
