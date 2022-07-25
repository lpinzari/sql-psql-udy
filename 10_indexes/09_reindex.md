# REINDEX

In practice, an index **can become corrupted and no longer contains valid data due to hardware failures or software bugs**. To recover the index, you can use the **REINDEX** statement:

```SQL
REINDEX [ ( VERBOSE ) ] { INDEX | TABLE | SCHEMA | DATABASE | SYSTEM } name;
```

In this syntax, the `VERBOSE` keyword is optional. When included, the statement displays a progress report when each index is reindexed.

To recreate a single index, you specify the index name after `REINDEX INDEX` clause as follows:

```SQL
REINDEX INDEX index_name;
```

To recreate **all the indexes of a table**, you use the `TABLE` keyword and specify the name of the table:

```SQL
REINDEX TABLE table_name;   
```

If you want to recreate **all indices in a schema**, you use the `SCHEMA` keyword followed by the schema name:

```SQL
REINDEX SCHEMA schema_name;
```

To recreate **all indices in a specific database**, you specify the database name after the `REINDEX DATABASE` clause:

```SQL
REINDEX DATABASE database_name;
```

The following statement recreates all indices on system catalogs in a specific database:

```SQL
REINDEX SYSTEM database_name;
```

## REINDEX vs. DROP INDEX & CREATE INDEX

The `REINDEX` statement rebuilds the index contents from the scratch, which has the similar effect as `drop` and `recreate` of the index. However, the locking mechanisms between them are different.

The `REINDEX` statement:

- Locks writes but not reads of the table to which the index belongs.
- Takes an exclusive lock on the index that is being processed, which blocks reads that attempt to use the index.

The `DROP INDEX & CREATE INDEX` statements:

- First, the `DROP INDEX` locks both writes and reads of the table to which the index belongs by acquiring an exclusive lock on the table.
- Then, the subsequent `CREATE INDEX` statement locks out writes but not reads from the index’s parent table. However, reads might be expensive during the creation of the index.
