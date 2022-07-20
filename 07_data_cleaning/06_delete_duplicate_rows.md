## How To Delete Duplicate Rows in PostgreSQL

First, **create a new table** named `basket` that stores fruits:

```SQL
CREATE TABLE basket(
    id SERIAL PRIMARY KEY,
    fruit VARCHAR(50) NOT NULL
);
```

Second, **insert** some fruits into the `basket` table.

```SQL
INSERT INTO basket(fruit) values('apple');
INSERT INTO basket(fruit) values('apple');

INSERT INTO basket(fruit) values('orange');
INSERT INTO basket(fruit) values('orange');
INSERT INTO basket(fruit) values('orange');

INSERT INTO basket(fruit) values('banana');
```

Third, query data from the `basket` table:

```SQL
SELECT id, fruit
  FROM basket;
```


|id | fruit|
|---:|:------:|
| 1 | apple|
| 2 | apple|
| 3 | orange|
| 4 | orange|
| 5 | orange|
| 6 | banana|

As you can see, we have some duplicate rows such as `2 apples` and `3 oranges` in the `basket` table.

## Finding duplicate rows

If the table has few rows, you can see which ones are duplicate immediately. However, it is not the case with the big table.

The find the duplicate rows, you use the following statement:

```SQL
SELECT fruit,
       COUNT( fruit )
  FROM basket
 GROUP BY fruit
HAVING COUNT( fruit )> 1
 ORDER BY fruit;
```

**Output**

|fruit  | count|
|:-----:|:------:|
|apple  |     2|
|orange |     3|

## Deleting duplicate rows using DELETE USING statement

The following statement uses the `DELETE USING` statement to **remove duplicate rows**:

```SQL
DELETE FROM basket a
      USING basket b
 WHERE a.id < b.id AND
       a.fruit = b.fruit;
```

Here is the execution:

```console
parch_posey=# DELETE FROM basket a
parch_posey-#       USING basket b
parch_posey-#  WHERE a.id < b.id AND
parch_posey-#        a.fruit = b.fruit;
DELETE 3
```

In this example, we joined the basket table to itself and checked if two different rows (`a.id < b.id`) have the same value in the fruit column (`a.fruit = b.fruit`).

Let’s query the basket table again to verify whether the duplicate rows were deleted:

```SQL
SELECT id, fruit
  FROM basket;
```

**Output**

|id | fruit|
|:--:|:------:|
| 2 | apple|
| 5 | orange|
| 6 | banana|

As you can see, the statement removed the duplicate rows with lowest ids and keep the one with the highest id.

If you want to keep the duplicate rows with the lowest id, you use just need to flip the operator in the `WHERE` clause:

```SQL
DELETE FROM basket a
      USING basket b
 WHERE a.id > b.id AND
       a.fruit = b.fruit;
```

**Output**

|id | fruit|
|:--:|:------:|
| 1 | apple|
| 3 | orange|
| 6 | banana|

Perfect! the duplicate rows with the lowest ids are retained.

## Deleting duplicate rows using an immediate table

To delete rows using an `immediate table`, you use the following steps:

1. **Create a new table** with the `same structure` as the one whose duplicate rows should be removed.
2. **Insert distinct rows** from the `source table` to the immediate table.
3. **Drop the source table**.
4. **Rename the immediate table** to the name of the `source table`.

The following illustrates the steps of removing duplicate rows from the `basket` table:

```SQL
-- step 1
CREATE TABLE basket_temp (LIKE basket);

-- step 2
INSERT INTO basket_temp(fruit, id)
SELECT DISTINCT ON (fruit) fruit,
                    id
  FROM basket;

-- step 3
DROP TABLE basket;

-- step 4
ALTER TABLE basket_temp
RENAME TO basket;                  
```

PostgreSQL provides the `DISTINCT ON` (expression) **to keep the “first” row of each group of duplicates**.
