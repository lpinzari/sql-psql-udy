# How to generate an INSERT sql script from existing data in a table.


First, create the header of the `INSERT` statement of table `logins`.

```SQL
WITH head AS (
  SELECT 'INSERT INTO logins (id, user_id, day)' || E'\n' || 'VALUES' || E'\n' AS query
)
SELECT *
  FROM head;
```

```console
query
---------------------------------------
INSERT INTO logins (id, user_id, day)+
VALUES                               +

(1 row)
```

Next, generate the rows with the values to be included in the `INSERT` statement.

```SQL
WITH head AS (
  SELECT 'INSERT INTO logins (id, user_id, day)' || E'\n' || 'VALUES' || E'\n' AS query
), -- WE know that table logins has 1000 records
vals AS (
  SELECT  id
         , '(' || id || ',' || user_id || ',' || day || ')' ||
          CASE WHEN id = 1000
               THEN ';'
               ELSE ','
          END AS query
    FROM  logins
)
SELECT query
  FROM vals;
```

```console
query
-------------------------------------
(1,100,2022-08-13 02:01:23.197028),
(2,35,2022-06-25 02:01:23.197028),
(3,86,2022-01-01 02:01:23.197028),
(4,44,2022-04-04 02:01:23.197028),
(5,39,2021-09-01 02:01:23.197028),
(6,27,2022-08-13 02:01:23.197028),
(7,7,2022-03-01 02:01:23.197028),
(8,40,2022-05-13 02:01:23.197028),
(9,19,2022-04-19 02:01:23.197028),
(10,87,2021-11-14 02:01:23.197028),
             .....
(998,47,2022-08-23 02:01:23.197028),
(999,17,2022-03-09 02:01:23.197028),
(1000,46,2022-03-18 02:01:23.197028);
```

Use the `STRING_AGG` function of PostgeSQL.


```SQL
WITH head AS (
  SELECT 'INSERT INTO logins (id, user_id, day)' || E'\n' || 'VALUES' || E'\n' AS query
), -- WE know that table logins has 1000 records
vals AS (
  SELECT  id
         , '(' || id || ',' || user_id || ',' || day || ')' ||
          CASE WHEN id = 1000
               THEN ';'
               ELSE ','
          END AS query
    FROM  logins
)
SELECT STRING_AGG(query,E'\n' ORDER BY id) AS query
  FROM vals;
```

```console
query
---------------------------------------
(1,100,2022-08-13 02:01:23.197028),  +
(2,35,2022-06-25 02:01:23.197028),   +
(3,86,2022-01-01 02:01:23.197028),   +
(4,44,2022-04-04 02:01:23.197028),   +
(5,39,2021-09-01 02:01:23.197028),   +
(6,27,2022-08-13 02:01:23.197028),   +
(7,7,2022-03-01 02:01:23.197028),    +
(8,40,2022-05-13 02:01:23.197028),   +
(9,19,2022-04-19 02:01:23.197028),   +
(10,87,2021-11-14 02:01:23.197028),  +
               .....                 +
(998,47,2022-08-23 02:01:23.197028), +
(999,17,2022-03-09 02:01:23.197028), +
(1000,46,2022-03-18 02:01:23.197028);
```

Lastly, include the header.

```SQL
WITH head AS (
  SELECT 'INSERT INTO logins (id, user_id, day)' || E'\n' || 'VALUES' || E'\n' AS query
), -- WE know that table logins has 1000 records
vals AS (
  SELECT  id
         , '(' || id || ',' || user_id || ',' || day || ')' ||
          CASE WHEN id = 1000
               THEN ';'
               ELSE ','
          END AS query
    FROM  logins
),
q_vals AS (
  SELECT STRING_AGG(query,E'\n' ORDER BY id) AS query
    FROM vals
)
SELECT h.query || qv.query AS query
  FROM head h, q_vals qv;
```

```console
query
---------------------------------------
INSERT INTO logins (id, user_id, day)+
VALUES                               +
(1,100,2022-08-13 02:01:23.197028),  +
(2,35,2022-06-25 02:01:23.197028),   +
(3,86,2022-01-01 02:01:23.197028),   +
(4,44,2022-04-04 02:01:23.197028),   +
(5,39,2021-09-01 02:01:23.197028),   +
(6,27,2022-08-13 02:01:23.197028),   +
(7,7,2022-03-01 02:01:23.197028),    +
(8,40,2022-05-13 02:01:23.197028),   +
(9,19,2022-04-19 02:01:23.197028),   +
(10,87,2021-11-14 02:01:23.197028),  +
               .....                 +
(998,47,2022-08-23 02:01:23.197028), +
(999,17,2022-03-09 02:01:23.197028), +
(1000,46,2022-03-18 02:01:23.197028);
```

Finally, create a `VIEW` table to be exported.

```SQL
CREATE VIEW populate_logins AS (
  WITH head AS (
    SELECT 'INSERT INTO logins (id, user_id, day)' || E'\n' || 'VALUES' || E'\n' AS query
  ), -- WE know that table logins has 1000 records
  vals AS (
    SELECT  id
           , '(' || id || ',' || user_id || ',' || day || ')' ||
            CASE WHEN id = 1000
                 THEN ';'
                 ELSE ','
            END AS query
      FROM  logins
  ),
  q_vals AS (
    SELECT STRING_AGG(query,E'\n' ORDER BY id) AS query
      FROM vals
  )
  SELECT h.query || qv.query AS query
    FROM head h, q_vals qv
);

SELECT *
  FROM populate_logins;  
```

```console
query
---------------------------------------
INSERT INTO logins (id, user_id, day)+
VALUES                               +
(1,100,2022-08-13 02:01:23.197028),  +
(2,35,2022-06-25 02:01:23.197028),   +
(3,86,2022-01-01 02:01:23.197028),   +
(4,44,2022-04-04 02:01:23.197028),   +
(5,39,2021-09-01 02:01:23.197028),   +
(6,27,2022-08-13 02:01:23.197028),   +
(7,7,2022-03-01 02:01:23.197028),    +
(8,40,2022-05-13 02:01:23.197028),   +
(9,19,2022-04-19 02:01:23.197028),   +
(10,87,2021-11-14 02:01:23.197028),  +
               .....                 +
(998,47,2022-08-23 02:01:23.197028), +
(999,17,2022-03-09 02:01:23.197028), +
(1000,46,2022-03-18 02:01:23.197028);
```

The last step is to export the view table as a script file.

```console
COPY (SELECT query FROM populate_logins) TO '/your_path/insert_logins.sql' DELIMITER ',' QUOTE ' ' CSV;
```

Check the content of the file:

```console
(base) ludo $  ls insert_logins.sql
insert_logins.sql
```

```console
(base) ludo $  cat insert_logins.sql
 INSERT  INTO  logins  (id,  user_id,  day)
VALUES
(1,100,2022-08-13  02:01:23.197028),
(2,35,2022-06-25  02:01:23.197028),
(3,86,2022-01-01  02:01:23.197028),
(4,44,2022-04-04  02:01:23.197028),
(5,39,2021-09-01  02:01:23.197028),
(6,27,2022-08-13  02:01:23.197028),
(7,7,2022-03-01  02:01:23.197028),
(8,40,2022-05-13  02:01:23.197028),
(9,19,2022-04-19  02:01:23.197028),
(10,87,2021-11-14  02:01:23.197028),
              ....
(997,91,2022-01-11  02:01:23.197028),
(998,47,2022-08-23  02:01:23.197028),
(999,17,2022-03-09  02:01:23.197028),
(1000,46,2022-03-18  02:01:23.197028);
```
