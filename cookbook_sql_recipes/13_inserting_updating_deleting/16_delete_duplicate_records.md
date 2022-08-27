# Deleting Duplicate Records


You want to delete duplicate records from a table.

## Problem

Consider the following table:

```SQL
CREATE TABLE dupes (
  id INTEGER PRIMARY KEY,
  name VARCHAR(10)
);

INSERT INTO dupes
       (id, name)
VALUES (1, 'NAPOLEON'),
       (2, 'DYNAMITE'),
       (3, 'DYNAMITE'),
       (4, 'SHE SELLS'),
       (5, 'SEA SHELLS'),
       (6, 'SEA SHELLS'),
       (7, 'SEA SHELLS');

SELECT * FROM dupes ORDER BY 1;
```

|id |    name|
|:--:|:------:|
| **1** | **NAPOLEON**|
| **2** | **DYNAMITE**|
| 3 | DYNAMITE|
| **4** | **SHE SELLS**|
| **5** | **SEA SHELLS**|
| 6 | SEA SHELLS|
| 7 | SEA SHELLS|

For each group of duplicate names, such as `SEA SHELLS`, you want to arbitrarily retain one ID and delete the rest. In the case of `SEA SHELLS`, you don’t care whether you delete lines 5 and 6, or lines 5 and 7, or lines 6 and 7, but in the end you want just one record for `SEA SHELLS`. Let's say, we want to keep only the records with the smallest `ID`.

|id |    name|
|:-:|:-------:|
| 1 | NAPOLEON|
| 2 | DYNAMITE|
| 4 | SHE SELLS|
| 5 | SEA SHELLS|

## Solution

Use a subquery with an aggregate function such as `MIN` to arbitrarily choose the `ID` to retain (in this case only the `NAME` with the smallest value for `ID` is not deleted):

```SQL
DELETE FROM dupes
      WHERE id NOT IN (SELECT MIN(d.id)
                         FROM dupes d
                        GROUP BY d.name);
```

## Discussion

The first thing to do when deleting duplicates is to define exactly what it means for two rows to be considered “duplicates” of each other. For my example in this recipe, the definition of “duplicate” is that two records contain the same value in their `NAME` column. Having that definition in place, you can look to some other column to discriminate among each set of duplicates, to identify those records to retain.

It's best this discriminating column (or columns) is a `primary key`. We used the `ID` column, which is a good choice **because no two records have the same** `ID`.

The key to the solution is that you `group by` **the values that are duplicated** (by `NAME` in this case), and then `use an aggregate function` **to pick off just one key value to retain**.

The subquery in the “Solution” example will return the `smallest ID` for each `NAME`, which represents the row you will not delete:

```SQL
SELECT name, MIN(id) AS min_id
  FROM dupes
 GROUP BY name
 ORDER BY min_id;
```

|name    | min_id|
|:---------:|:-----:|
|NAPOLEON   |      1|
|DYNAMITE   |      2|
|SHE SELLS  |      4|
|SEA SHELLS |      5|

The `DELETE` then deletes any `ID` in the table that is not returned by the subquery (in this case IDs `3`, `6`, and `7`).
