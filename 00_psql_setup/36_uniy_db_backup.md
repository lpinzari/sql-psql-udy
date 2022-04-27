# How to backup all databases

To back up all databases, you can run the individual  `pg_dump` command above sequentially, or parallel if you want to speed up the backup process.

- First, from the psql, use the command  `\list` to list all available databases in your cluster
- Second, back up each individual database using the  `pg_dump` program as described in the above section.

Besides the  `pg_dump` program, PostgreSQL also provides you with the `pg_dumpall` tool that allows you to backup all databases at once. However, it is not recommended to use this tool because of the following reasons:

- The  `pg_dumpall` program exports all databases, one after another, into a single script file, which prevents you from performing the parallel restore. If you back up all databases this way, the restore process will take more time.
- The processing of dumping all databases takes longer than each individual one so you do not know which dump of each database relates to a specific point in time.

If you have a good reason to use the `pg_dumpall` to backup all databases, the following is the command:

```console
pg_dumpall -U postgres > /Users/ludovicopinzari/pgbackup/all.sql
```
The options of the  `pg_dumpall` program are similar to the options of the `pg_dump` program. This command omits the `-W` option to avoid typing the password for each individual database.

## How to backup database object definitions
Sometimes, you want to backup only database object definitions, not the data This is helpful in the testing phase, which you do not want to move test data to the live system.

To back up objects in all databases, including roles, tablespaces, databases, schemas, tables, indexes, triggers, functions, constraints, views, ownerships, and privileges, you use the following command:

```console
pg_dumpall --schema-only > /Users/ludovicopinzari/pgbackup/definitiononly.sql
```

## Further Reading

- [pg_dump](https://www.postgresql.org/docs/current/app-pgdump.html)
