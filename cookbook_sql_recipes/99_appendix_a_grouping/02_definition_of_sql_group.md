# Definition of an SQL Group

In mathematics, a group is defined, for the most part, as `(G, •, e)`, where
- `G` is a set,
- `•` is a binary operation in `G`, and
- `e` is a member of `G`.

We will use this definition as the foundation for what a SQL group is. A SQL group will be defined as `(G, e)`, where
- `G` is **a result set of a single or self-contained query that uses** `GROUP BY`,
- `e` is a member of G, and the following axioms are satisfied:

- For each `e` in `G`, `e` **is distinct** and represents one or more instances of e.
- For each `e` in `G`, the aggregate function `COUNT` **returns a value > 0**.

> Note: The result set is included in the definition of a SQL group to rein‐ force the fact that we are defining what groups are when working with queries only. Thus, it would be accurate to replace e in each axiom with the word row because the rows in the result set are technically the groups.

Because these properties are fundamental to what we consider a group, it is important that we prove they are true (and we will proceed to do so through the use of some example SQL queries).

## Groups are nonempty

By its very definition, **a group must have at least one member (or row)**.

If we accept this as a truth, then it can be said that **a group cannot be created from an empty table**. To prove that proposition `true`, simply try to prove it is false. The following example creates an empty table and then attempts to create groups via three different queries against that empty table:

```SQL
CREATE TABLE fruits (name varchar(10));
```
```SQL
SELECT name
  FROM fruits
 GROUP BY name;
```

```console
name
------
(0 rows)
```

```SQL
SELECT COUNT(*) AS cnt
  FROM fruits
 GROUP BY name;
```

```console
cnt
-----
(0 rows)
```

```SQL
SELECT name,
       COUNT(*) AS cnt
  FROM fruits
 GROUP BY name;
```

```console
name | cnt
------+-----
(0 rows)
```

As you can see from these queries, it is impossible to create what SQL considers a group from an empty table.

## Groups are distinct

Now let’s prove that the groups created via queries with a `GROUP BY` clause are **distinct**. The following example inserts five rows into table `FRUITS` and then creates groups from those rows:

```SQL
INSERT INTO fruits VALUES ('Oranges');
INSERT INTO fruits VALUES ('Oranges');
INSERT INTO fruits VALUES ('Oranges');
INSERT INTO fruits VALUES ('Apple');
INSERT INTO fruits VALUES ('Peach');
```

```SQL
SELECT * FROM fruits;
```

|name|
|:-------:|
|Oranges|
|Oranges|
|Oranges|
|Apple|
|Peach|

```SQL
SELECT name
  FROM fruits
 GROUP BY name;
```

|name|
|:-------:|
|Oranges|
|Peach|
|Apple|

```SQL
SELECT name,
       COUNT(*) AS cnt
  FROM fruits
 GROUP BY name;
```

|name   | cnt|
|:------:|:--:|
|Oranges |   3|
|Peach   |   1|
|Apple   |   1|

The first query shows that “`Oranges`” occurs three times in table `FRUITS`. However, the second and third queries (using `GROUP BY`) return only one instance of “`Oranges`.” Taken together, these queries prove that the rows in the result set (e in G, from our definition) are **distinct**, and each value of `NAME` represents one or more instances of itself in table `FRUITS`.

:warning:
Knowing that groups are distinct is important because it means, typically, **you would not use the** `DISTINCT` **keyword in your** `SELECT` list **when using a** `GROUP BY` in your queries.

> Note: We don’t pretend GROUP BY and DISTINCT are the same. They represent two completely different concepts. We do state that the items listed in the GROUP BY clause will be distinct in the result set and that using DISTINCT as well as GROUP BY is redundant.

## COUNT is never zero

The queries and results in the preceding section also prove the final axiom that the aggregate function `COUNT` **will never return zero when used in a query with** `GROUP BY` on **a nonempty table**.

It should not be surprising that you cannot return a count of zero for a group. We have already proved that a group cannot be created from an empty table; thus, a group must have at least one row. If at least one row exists, then the count will always be at least one.

>Note: Remember, we are talking about using COUNT with GROUP BY, not COUNT by itself. A query using COUNT without a GROUP BY on an empty table will, of course, return zero.
