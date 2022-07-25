# DESTROY INDEX

Sometimes, you may want to remove an existing index from the database system. To do it, you use the **DROP INDEX** statement as follows:

```SQL
DROP INDEX  [ CONCURRENTLY]
[ IF EXISTS ]  index_name
[ CASCADE | RESTRICT ];
```

In this syntax:

### index_name

You specify the name of the index that you want to remove after the `DROP INDEX` clause.

### IF EXISTS

Attempting to remove a non-existent index will result in an error. To avoid this, you can use the `IF EXISTS` option. In case you remove a non-existent index with `IF EXISTS`, PostgreSQL issues a notice instead.

### CASCADE

If the index has dependent objects, you use the `CASCADE` option to automatically drop these objects and all objects that depends on those objects.

### RESTRICT

The `RESTRICT` option instructs PostgreSQL to refuse to drop the index if any objects depend on it. The DROP INDEX uses `RESTRICT` by default.

Note that you can drop multiple indexes at a time by separating the indexes by commas (,):

```SQL
DROP INDEX index_name, index_name2,... ;
```

### CONCURRENTLY

When you execute the `DROP INDEX` statement, PostgreSQL acquires an exclusive lock on the table and block other accesses until the index removal completes.

To force the command waits until the conflicting transaction completes before removing the index, you can use the `CONCURRENTLY` option.

The `DROP INDEX CONCURRENTLY` has some limitations:

- First, the `CASCADE` option is not supported
- Second, executing in a transaction block is also not supported

## PostgreSQL DROP INDEX example

We will use the `actor` table from the `dvdrental` sample database for the demonstration.

```console
dvdrental=# \d actor
                                            Table "public.actor"
   Column    |            Type             | Collation | Nullable |                 Default
-------------+-----------------------------+-----------+----------+-----------------------------------------
 actor_id    | integer                     |           | not null | nextval('actor_actor_id_seq'::regclass)
 first_name  | character varying(45)       |           | not null |
 last_name   | character varying(45)       |           | not null |
 last_update | timestamp without time zone |           | not null | now()
Indexes:
    "actor_pkey" PRIMARY KEY, btree (actor_id)
    "idx_actor_last_name" btree (last_name)
Referenced by:
    TABLE "film_actor" CONSTRAINT "film_actor_actor_id_fkey" FOREIGN KEY (actor_id) REFERENCES actor(actor_id) ON UPDATE CASCADE ON DELETE RESTRICT
Triggers:
    last_updated BEFORE UPDATE ON actor FOR EACH ROW EXECUTE PROCEDURE last_updated()
```

The following statement creates an index for the `first_name` column of the `actor` table:

```SQL
CREATE INDEX idx_actor_first_name
          ON actor (first_name);
```

Sometimes, the `query optimizer` does not use the index. For example, the following statement finds the `actor` with the name `John`:

```SQL
SELECT * FROM actor
WHERE first_name = 'John';
```

The query did not use the `idx_actor_first_name` index defined earlier as explained in the following `EXPLAIN` statement:

```SQL
EXPLAIN SELECT *
FROM actor
WHERE first_name = 'John';
```

```console
QUERY PLAN
------------------------------------------------------
Seq Scan on actor  (cost=0.00..4.50 rows=1 width=25)
Filter: ((first_name)::text = 'John'::text)
```

This is because the query optimizer thinks that **it is more optimal to just scan the whole table to locate the row**. Hence, the `idx_actor_first_name` is not useful in this case and we need to remove it:

```SQL
DROP INDEX idx_actor_first_name;
```

The statement removed the index as expected.
