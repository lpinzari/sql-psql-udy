# Email Response Time


Say we have a table emails that includes emails sent to and from `ludo@g.com`:

```SQL
CREATE TABLE emails (
  id INTEGER,
  subject TEXT,
  e_from TEXT,
  e_to TEXT,
  daytime TIMESTAMP
);

INSERT INTO emails
       (id, subject, e_from, e_to, daytime)
VALUES (1, 'Meeting', 'ludo@g.com', 'alex@g.com','2022-01-02 12:45:03'),
       (2, 'Conference', 'mark@g.com', 'alex@g.com', '2022-01-02 16:30:01'),
       (3, 'Meeting', 'alex@g.com', 'ludo@g.com', '2022-01-02 16:35:04'),
       (4, 'Gym', 'jenn@g.com', 'ludo@g.com', '2022-01-03 08:12:45'),
       (5, 'Meeting', 'ludo@g.com', 'alex@g.com', '2022-01-03 14:02:01'),
       (6, 'Meeting', 'alex@g.com', 'ludo@g.com', '2022-01-03 15:01:05'),
       (7, 'Meeting', 'ludo@g.com', 'alex@g.com', '2022-01-03 16:01:05'),
       (8, 'Gym', 'ludo@g.com', 'jenn@g.com', '2022-01-04 18:01:05'),
       (9, 'Meeting', 'mark@g.com', 'ludo@g.com', '2022-01-05 18:01:05'),
       (10, 'Meeting', 'ludo@g.com', 'mark@g.com', '2022-01-06 18:01:05');
```

```console
id |  subject   |   e_from   |    e_to    |       daytime
---+------------+------------+------------+---------------------
 1 | Meeting    | ludo@g.com | alex@g.com | 2022-01-02 12:45:03
 2 | Conference | mark@g.com | alex@g.com | 2022-01-02 16:30:01
 3 | Meeting    | alex@g.com | ludo@g.com | 2022-01-02 16:35:04
 4 | Gym        | jenn@g.com | ludo@g.com | 2022-01-03 08:12:45
 5 | Meeting    | ludo@g.com | alex@g.com | 2022-01-03 14:02:01
 6 | Meeting    | alex@g.com | ludo@g.com | 2022-01-03 15:01:05
 7 | Meeting    | ludo@g.com | alex@g.com | 2022-01-03 16:01:05
 8 | Gym        | ludo@g.com | jenn@g.com | 2022-01-04 18:01:05
 9 | Meeting    | mark@g.com | ludo@g.com | 2022-01-05 18:01:05
10 | Meeting    | ludo@g.com | mark@g.com | 2022-01-06 18:01:05
(10 rows)
```

## Problem

Task: Write a query to get the `response time per email` (id) sent to `ludo@g.com`. How long does it takes to ludovico to send an email back? **Do not include ids that did not receive a response from** `ludo@g.com`.

Assume each email thread has a `unique subject`. Keep in mind a thread may have multiple responses back-and-forth between `ludo@g.com` and `another email address`. We want to return only the first response time.

```console
id |  time_response
---+-----------------
 3 | 1286.95 minutes
 4 | 2028.33 minutes
 6 | 60.00 minutes
 9 | 1440.00 minutes
(4 rows)
```

For example, the email id `3`, subject `Meeting` from `alex` to `ludo` received the first response from `ludo` with email id `5`.

```console
id |  subject   |   e_from   |    e_to    |       daytime
---+------------+------------+------------+---------------------
 3 | Meeting    | alex@g.com | ludo@g.com | 2022-01-02 16:35:04
 5 | Meeting    | ludo@g.com | alex@g.com | 2022-01-03 14:02:01 <-- first response
 6 | Meeting    | alex@g.com | ludo@g.com | 2022-01-03 15:01:05
 7 | Meeting    | ludo@g.com | alex@g.com | 2022-01-03 16:01:05
(10 rows)
```

The time response is `21 hours 26 minutes 57 seconds` or `1286.95 minutes`.

## Solution

```SQL
WITH response AS (
  SELECT e1.id
        ,MIN(e2.daytime) - MIN(e1.daytime) AS time_response
    FROM emails e1
    JOIN emails e2
      ON e2.subject = e1.subject -- Same subject
         AND e1.e_from = e2.e_to -- find a record where the sender is a receiver (of ludo)
         AND e1.e_to = e2.e_from -- find a record where the receiver ludo is a sender (e2)
         AND e1.daytime < e2.daytime -- filter only those records where ludo sent first
   WHERE e1.e_to = 'ludo@g.com'
   GROUP BY e1.id
)
SELECT id
      , ROUND( (EXTRACT(DAYS FROM time_response)*24*60 +
                EXTRACT(HOURS FROM time_response)*60 +
                EXTRACT(MINUTES FROM time_response) +
                EXTRACT(SECONDS FROM time_response)/60.0)::NUMERIC, 2) || ' minutes' AS time_response
  FROM response
 ORDER BY id;
```


## Discussion

```SQL
SELECT *
  FROM emails
 ORDER BY e_from, subject, e_to, daytime;
```

```console
id |  subject   |   e_from   |    e_to    |       daytime
---+------------+------------+------------+---------------------
 3 | Meeting    | alex@g.com | ludo@g.com | 2022-01-02 16:35:04
 6 | Meeting    | alex@g.com | ludo@g.com | 2022-01-03 15:01:05
 4 | Gym        | jenn@g.com | ludo@g.com | 2022-01-03 08:12:45
 ---------------------------------------------------------------
 8 | Gym        | ludo@g.com | jenn@g.com | 2022-01-04 18:01:05
 1 | Meeting    | ludo@g.com | alex@g.com | 2022-01-02 12:45:03
 5 | Meeting    | ludo@g.com | alex@g.com | 2022-01-03 14:02:01
 7 | Meeting    | ludo@g.com | alex@g.com | 2022-01-03 16:01:05
10 | Meeting    | ludo@g.com | mark@g.com | 2022-01-06 18:01:05
----------------------------------------------------------------
 2 | Conference | mark@g.com | alex@g.com | 2022-01-02 16:30:01
 9 | Meeting    | mark@g.com | ludo@g.com | 2022-01-05 18:01:05
(10 rows)
```

the output table shows that `ludo` sent emails to `jenn`,`alex` and `mark`. We have to check if these emails are first response email or not. In other words, Did `jenn`, `alex` or `mark` send an email to `ludo` earlier with the same subject?

```SQL
SELECT *
  FROM emails e1
  JOIN emails e2
    ON e2.subject = e1.subject -- Same subject
       AND e1.e_from = e2.e_to -- find a record where the sender is a receiver (of ludo)
       AND e1.e_to = e2.e_from -- find a record where the receiver ludo is a sender (e2)
       AND e1.daytime < e2.daytime -- filter only those records where ludo sent first
 WHERE e1.e_to = 'ludo@g.com'
 ORDER BY e1.e_from, e1.subject, e1.e_to, e1.daytime;
```

```console
id  | subject |   e_from   |    e_to    |       daytime       | id | subject |   e_from   |    e_to    |       daytime
----+---------+------------+------------+---------------------+----+---------+------------+------------+---------------------
 3 | Meeting | alex@g.com | ludo@g.com | 2022-01-02 16:35:04 |  5 | Meeting | ludo@g.com | alex@g.com | 2022-01-03 14:02:01 <----
 3 | Meeting | alex@g.com | ludo@g.com | 2022-01-02 16:35:04 |  7 | Meeting | ludo@g.com | alex@g.com | 2022-01-03 16:01:05
 6 | Meeting | alex@g.com | ludo@g.com | 2022-01-03 15:01:05 |  7 | Meeting | ludo@g.com | alex@g.com | 2022-01-03 16:01:05
 4 | Gym     | jenn@g.com | ludo@g.com | 2022-01-03 08:12:45 |  8 | Gym     | ludo@g.com | jenn@g.com | 2022-01-04 18:01:05 <----
 9 | Meeting | mark@g.com | ludo@g.com | 2022-01-05 18:01:05 | 10 | Meeting | ludo@g.com | mark@g.com | 2022-01-06 18:01:05 <----
(5 rows)
```

```SQL
SELECT e1.id
      , e2.daytime - e1.daytime AS time_response
  FROM emails e1
  JOIN emails e2
    ON e2.subject = e1.subject -- Same subject
       AND e1.e_from = e2.e_to -- find a record where the sender is a receiver (of ludo)
       AND e1.e_to = e2.e_from -- find a record where the receiver ludo is a sender (e2)
       AND e1.daytime < e2.daytime -- filter only those records where ludo sent first
 WHERE e1.e_to = 'ludo@g.com'
 ORDER BY e1.id;
```

```console
id | time_response
----+----------------
 3 | 21:26:57 <--
 3 | 23:26:01
 4 | 1 day 09:48:20 <--
 6 | 01:00:00 <--
 9 | 1 day <--
(5 rows)
```


The only record we care is the first response.


```SQL
SELECT e1.id
      , MIN(e2.daytime) - MIN(e1.daytime) AS time_response
  FROM emails e1
  JOIN emails e2
    ON e2.subject = e1.subject -- Same subject
       AND e1.e_from = e2.e_to -- find a record where the sender is a receiver (of ludo)
       AND e1.e_to = e2.e_from -- find a record where the receiver ludo is a sender (e2)
       AND e1.daytime < e2.daytime -- filter only those records where ludo sent first
 WHERE e1.e_to = 'ludo@g.com'
 GROUP BY e1.id
 ORDER BY e1.id;
```

```console
id | time_response
---+----------------
 3 | 21:26:57
 4 | 1 day 09:48:20
 6 | 01:00:00
 9 | 1 day
(4 rows)
```

```SQL
WITH response AS (
  SELECT e1.id
        ,MIN(e2.daytime) - MIN(e1.daytime) AS time_response
    FROM emails e1
    JOIN emails e2
      ON e2.subject = e1.subject -- Same subject
         AND e1.e_from = e2.e_to -- find a record where the sender is a receiver (of ludo)
         AND e1.e_to = e2.e_from -- find a record where the receiver ludo is a sender (e2)
         AND e1.daytime < e2.daytime -- filter only those records where ludo sent first
   WHERE e1.e_to = 'ludo@g.com'
   GROUP BY e1.id
)
SELECT id
      , EXTRACT(DAYS FROM time_response) || ' days ' ||
        EXTRACT(HOURS FROM time_response) || ' hours ' ||
        EXTRACT(MINUTES FROM time_response) || ' minutes ' ||
        EXTRACT(SECONDS FROM time_response) || ' seconds' AS time_response
  FROM response
 ORDER BY id;
```

```console
id |             time_response
---+---------------------------------------
 3 | 0 days 21 hours 26 minutes 57 seconds
 4 | 1 days 9 hours 48 minutes 20 seconds
 6 | 0 days 1 hours 0 minutes 0 seconds
 9 | 1 days 0 hours 0 minutes 0 seconds
(4 rows)
```

```SQL
WITH response AS (
  SELECT e1.id
        ,MIN(e2.daytime) - MIN(e1.daytime) AS time_response
    FROM emails e1
    JOIN emails e2
      ON e2.subject = e1.subject -- Same subject
         AND e1.e_from = e2.e_to -- find a record where the sender is a receiver (of ludo)
         AND e1.e_to = e2.e_from -- find a record where the receiver ludo is a sender (e2)
         AND e1.daytime < e2.daytime -- filter only those records where ludo sent first
   WHERE e1.e_to = 'ludo@g.com'
   GROUP BY e1.id
)
SELECT id
      , ROUND( (EXTRACT(DAYS FROM time_response)*24*60 +
                EXTRACT(HOURS FROM time_response)*60 +
                EXTRACT(MINUTES FROM time_response) +
                EXTRACT(SECONDS FROM time_response)/60.0)::NUMERIC, 2) || ' minutes' AS time_response
  FROM response
 ORDER BY id;
```

```console
id |  time_response
---+-----------------
 3 | 1286.95 minutes
 4 | 2028.33 minutes
 6 | 60.00 minutes
 9 | 1440.00 minutes
(4 rows)
```
