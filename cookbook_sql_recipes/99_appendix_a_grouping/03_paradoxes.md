# Paradoxes

 In its `GROUP BY` clause, a query may have a wide range of values such as constants, expressions, or, most commonly, columns from a table.

 We pay a price for this flexibility, because `NULL` is a **valid “value” in SQL**. `NULLs` present problems because they are effectively ignored by aggregate functions.

 With that said,

 - `if a table consists of a single row and its value is NULL, what would the aggregate function COUNT return when used in a GROUP BY query`?

 By our very definition, when using `GROUP BY` and the aggregate function `COUNT`, a `value >= 1` must be returned.

 - What happens, then, in the case of **values ignored by functions such as** `COUNT`?
 - and what does this mean to our definition of a `GROUP`?

 Consider the following example, which reveals the `NULL` **group paradox** (using the function `COALESCE` when necessary for readability):

 ```SQL
 SELECT *
   FROM fruits;
```

|name|
|:-----:|
|Oranges|
|Oranges|
|Oranges|
|Apple|
|Peach|

```SQL
INSERT INTO fruits VALUES (NULL);
INSERT INTO fruits VALUES (NULL);
INSERT INTO fruits VALUES (NULL);
INSERT INTO fruits VALUES (NULL);
INSERT INTO fruits VALUES (NULL);
```  

```SQL
SELECT COALESCE(name,'NULL') as name
  FROM fruits;
```

|name|
|:-----:|
|Oranges|
|Oranges|
|Oranges|
|Apple|
|Peach|
|NULL|
|NULL|
|NULL|
|NULL|
|NULL|

```SQL
SELECT name,
       COUNT(name) AS cnt
  FROM fruits
 GROUP BY name;
```

```SQL
SELECT COALESCE(name,'NULL') AS name,
       COUNT(name) AS cnt
  FROM fruits
 GROUP BY name;
```

|name   | cnt|
|:------:|:--:|
|NULL    |   0|
|Oranges |   3|
|Peach   |   1|
|Apple   |   1|

It would seem that the presence of `NULL` values in our table introduces a contradiction, or paradox, to our definition of a `SQL` group. Fortunately, this contradiction is not a real cause for concern, because the paradox has more to do with the implementation of aggregate functions than our definition. Consider the final query in the preceding set; a general problem statement for that query would be:

- Count the number of times each name occurs in table FRUITS or count the number of members in each group.

>Note: While NULL certainly has properties that differentiate it from other values, it is nevertheless a value and can in fact be a group.

How, then, can we write the query to return a `count` of **5** instead of `0`, **thus returning the information we are looking for while conforming to our definition of a group?** The following example shows a workaround to deal with the `NULL` **group paradox**:

```SQL
SELECT name,
       COUNT(name) AS count_name,
       COUNT(*) AS cnt_all
  FROM fruits
 GROUP BY name;   
```

|name   | count_name | cnt_all|
|:-----:|:-----------:|:------:|
|NULL    |          0 |       5|
|Oranges |          3 |       3|
|Peach   |          1 |       1|
|Apple   |          1 |       1|

The workaround is to use `COUNT(*)` rather than `COUNT(NAME)` to avoid the **NULL group paradox**.

**Aggregate functions will ignore** `NULL` values if any exist in the column passed to them. Thus, **to avoid a zero** when using `COUNT`, do not pass the column name; instead, **pass in an asterisk** `(*)`.

The `*` **causes the** `COUNT` **function to count rows rather than the actual column values**, so `whether the actual values are NULL or not NULL is irrelevant`.

One more paradox has to do with the axiom that each group in a result set (for each `e` in `G`) is **distinct**.

Because of the nature of SQL result sets and tables, which are more accurately defined as `multisets` or “`bags`,” not sets (**because duplicate rows are allowed**), **it is possible to return a result set with duplicate groups**.

Consider the following queries:

```SQL
SELECT COALESCE(name,'NULL') AS name,
       COUNT(*) AS cnt
  FROM fruits
 GROUP BY name
UNION ALL
SELECT COALESCE(name,'NULL') AS name,
       COUNT(*) AS cnt
  FROM fruits
 GROUP BY name;
```

|name   | cnt|
|:------:|:---:|
|NULL    |   5|
|Oranges |   3|
|Peach   |   1|
|Apple   |   1|
|NULL    |   5|
|Oranges |   3|
|Peach   |   1|
|Apple   |   1|

```SQL
SELECT x.*
  FROM (SELECT COALESCE(name,'NULL') AS name,
               COUNT(*) AS cnt
          FROM fruits
         GROUP BY name
        ) x,
        (SELECT deptno
           FROM dept) y
  ORDER BY name;
```

|name   | cnt|
|:------:|:--:|
|Apple   |   1|
|Apple   |   1|
|Apple   |   1|
|Apple   |   1|
|NULL    |   5|
|NULL    |   5|
|NULL    |   5|
|NULL    |   5|
|Oranges |   3|
|Oranges |   3|
|Oranges |   3|
|Oranges |   3|
|Peach   |   1|
|Peach   |   1|
|Peach   |   1|
|Peach   |   1|

As you can see in these queries, the groups are in fact repeated in the final results. Fortunately, this is not much to worry about because it represents only a partial paradox.

The first property of a group states that for `(G, e)`, `G` is a **result set from a single or self-contained query that uses** `GROUP BY`. Simply put, the result set from any `GROUP BY` query itself conforms to our definition of a group.

It is only when you combine the result sets from two `GROUP BY` queries to create a `multiset` that groups may repeat. The first query in the preceding example uses `UNION ALL`, **which is not a set operation but a multiset operation**, and invokes `GROUP BY` twice, effectively executing two queries.

>Note: If you use UNION, which is a set operation, you will not see repeating groups.

The second query in the preceding set uses a **Cartesian product**, which only works if you materialize the group first and then perform the Cartesian. Thus, the `GROUP BY` query when self-contained conforms to our definition. Neither of the two examples takes anything away from the definition of a SQL group. They are shown for com‐ pleteness, and so that you can be aware that almost anything is possible in SQL.
