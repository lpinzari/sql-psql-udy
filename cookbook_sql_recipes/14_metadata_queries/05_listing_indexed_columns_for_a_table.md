# Listing Indexed Columns for a Table

You want list indexes, their columns, and the column position (if available) in the index for a given table.

## Problem

List all the above mentioned information about the `film` and `actor` tables in the `dvdrental` database.

## Solution

```console
pg_indexes
```

```SQL
SELECT tablename,
       indexname,
       tablespace,
       indexdef
  FROM pg_indexes
 WHERE tablename IN ('film','actor')
 ORDER BY tablename;
```

```console
tablename |      indexname      | tablespace |                                 indexdef
-----------+---------------------+------------+--------------------------------------------------------------------------
actor     | actor_pkey          |            | CREATE UNIQUE INDEX actor_pkey ON public.actor USING btree (actor_id)
actor     | idx_actor_last_name |            | CREATE INDEX idx_actor_last_name ON public.actor USING btree (last_name)
film      | film_pkey           |            | CREATE UNIQUE INDEX film_pkey ON public.film USING btree (film_id)
film      | film_fulltext_idx   |            | CREATE INDEX film_fulltext_idx ON public.film USING gist (fulltext)
film      | idx_fk_language_id  |            | CREATE INDEX idx_fk_language_id ON public.film USING btree (language_id)
film      | idx_title           |            | CREATE INDEX idx_title ON public.film USING btree (title)
```

## Discussion

The view [pg_index](https://www.postgresql.org/docs/current/view-pg-indexes.html) provides access to useful information about each index in the database.

When it comes to queries, it’s important to know what columns are/aren’t indexed. Indexes can provide good performance for queries against columns that are frequently used in filters and that are fairly selective. Indexes are also useful when joining between tables. By knowing what columns are indexed, you are already one step ahead of performance problems if they should occur. Additionally, you might want to find information about the indexes themselves: how many levels deep they are, how many distinct keys there are, how many leaf blocks there are, and so forth. Such information is also available from the views/tables queried in this recipe’s solutions.
