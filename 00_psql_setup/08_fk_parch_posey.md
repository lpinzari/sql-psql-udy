# Parch & Posey Foreign Keys

In this lesson, we add the **foreign keys** to the `P&P's` database tables using the **foreign key constraints**.

![p&p erd](../01_basic_sql/images/03_erd_parchposey.png)

The ERD (Entity Relationship Diagram) shows that the P&P's database has 4 tables, (**accounts**, **web_events**, **sales_reps** and **orders**), with a **foreign key constraint**.

```console
parch_posey=# `\dt
           List of relations
 Schema |    Name    | Type  |  Owner
--------+------------+-------+----------
 public | accounts   | table | usertest
 public | orders     | table | usertest
 public | region     | table | usertest
 public | sales_reps | table | usertest
 public | web_events | table | usertest
(5 rows)
```

## accounts table

The child table `accounts`
```console
parch_posey-# \d accounts
                    Table "public.accounts"
    Column    |     Type      | Collation | Nullable | Default
--------------+---------------+-----------+----------+---------
 id           | integer       |           | not null |
 name         | bpchar        |           |          |
 website      | bpchar        |           |          |
 lat          | numeric(11,8) |           |          |
 long         | numeric(11,8) |           |          |
 primary_poc  | bpchar        |           |          |
 sales_rep_id | integer       |           |          |
Indexes:
    "accounts_pkey" PRIMARY KEY, btree (id)
```
The parent table `sales_reps`
```console
parch_posey-# \d sales_reps
              Table "public.sales_reps"
  Column   |  Type   | Collation | Nullable | Default
-----------+---------+-----------+----------+---------
 id        | integer |           | not null |
 name      | bpchar  |           |          |
 region_id | integer |           |          |
Indexes:
    "sales_reps_pkey" PRIMARY KEY, btree (id)
```

In the `accounts` **TABLE** the **FOREIGN KEY**, `sales_rep_id` **REFERENCES** a record in the `sales_reps`  parent table using the primary key (`id`). Let's name the foreign key **CONSTRAINT** `accounts_fkey_sales_rep`:

```console
parch_posey=# ALTER TABLE accounts
parch_posey-# ADD CONSTRAINT accounts_fkey_sales_rep
parch_posey-# FOREIGN KEY (sales_rep_id)
parch_posey-# REFERENCES sales_reps(id)
parch_posey-# ON DELETE CASCADE;
ALTER TABLE
```

Let's use the describe table command to check the primary and foreign keys in the accounts table.

```console
parch_posey=# \d accounts
                    Table "public.accounts"
    Column    |     Type      | Collation | Nullable | Default
--------------+---------------+-----------+----------+---------
 id           | integer       |           | not null |
 name         | bpchar        |           |          |
 website      | bpchar        |           |          |
 lat          | numeric(11,8) |           |          |
 long         | numeric(11,8) |           |          |
 primary_poc  | bpchar        |           |          |
 sales_rep_id | integer       |           |          |
Indexes:
    "accounts_pkey" PRIMARY KEY, btree (id)
Foreign-key constraints:
    "accounts_fkey_sales_rep" FOREIGN KEY (sales_rep_id) REFERENCES sales_reps(id) ON DELETE CASCADE
```

Now, let's execute the describe table command on the parent table `sales_reps`.

```console
parch_posey=# \d sales_reps
              Table "public.sales_reps"
  Column   |  Type   | Collation | Nullable | Default
-----------+---------+-----------+----------+---------
 id        | integer |           | not null |
 name      | bpchar  |           |          |
 region_id | integer |           |          |
Indexes:
    "sales_reps_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "accounts" CONSTRAINT "accounts_fkey_sales_rep" FOREIGN KEY (sales_rep_id) REFERENCES sales_reps(id) ON DELETE CASCADE
```


## web_events table

The child table `web_events`

```console
parch_posey=# \d web_events
                         Table "public.web_events"
   Column    |            Type             | Collation | Nullable | Default
-------------+-----------------------------+-----------+----------+---------
 id          | integer                     |           | not null |
 account_id  | integer                     |           |          |
 occurred_at | timestamp without time zone |           |          |
 channel     | bpchar                      |           |          |
Indexes:
    "web_events_pkey" PRIMARY KEY, btree (id)
```

The parent table `accounts`

```console
parch_posey=# \d accounts
                    Table "public.accounts"
    Column    |     Type      | Collation | Nullable | Default
--------------+---------------+-----------+----------+---------
 id           | integer       |           | not null |
 name         | bpchar        |           |          |
 website      | bpchar        |           |          |
 lat          | numeric(11,8) |           |          |
 long         | numeric(11,8) |           |          |
 primary_poc  | bpchar        |           |          |
 sales_rep_id | integer       |           |          |
Indexes:
    "accounts_pkey" PRIMARY KEY, btree (id)
Foreign-key constraints:
    "accounts_fkey_sales_rep" FOREIGN KEY (sales_rep_id) REFERENCES sales_reps(id) ON DELETE CASCADE
```

In the `web_events` **TABLE** the **FOREIGN KEY**, `account_id` **REFERENCES** a record in the `accounts` table using the primary key (`id`). Let's name the foreign key **CONSTRAINT** `web_events_fkey_account`

```console
parch_posey=# ALTER TABLE web_events
parch_posey-# ADD CONSTRAINT web_events_fkey_account
parch_posey-# FOREIGN KEY (account_id)
parch_posey-# REFERENCES accounts(id)
parch_posey-# ON DELETE CASCADE;
ALTER TABLE
parch_posey=#
```

Let's check it out.

```console
parch_posey=# \d web_events
                         Table "public.web_events"
   Column    |            Type             | Collation | Nullable | Default
-------------+-----------------------------+-----------+----------+---------
 id          | integer                     |           | not null |
 account_id  | integer                     |           |          |
 occurred_at | timestamp without time zone |           |          |
 channel     | bpchar                      |           |          |
Indexes:
    "web_events_pkey" PRIMARY KEY, btree (id)
Foreign-key constraints:
    "web_events_fkey_account" FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE

parch_posey=#
```

The parent table

```console
parch_posey=# \d accounts
                    Table "public.accounts"
    Column    |     Type      | Collation | Nullable | Default
--------------+---------------+-----------+----------+---------
 id           | integer       |           | not null |
 name         | bpchar        |           |          |
 website      | bpchar        |           |          |
 lat          | numeric(11,8) |           |          |
 long         | numeric(11,8) |           |          |
 primary_poc  | bpchar        |           |          |
 sales_rep_id | integer       |           |          |
Indexes:
    "accounts_pkey" PRIMARY KEY, btree (id)
Foreign-key constraints:
    "accounts_fkey_sales_rep" FOREIGN KEY (sales_rep_id) REFERENCES sales_reps(id) ON DELETE CASCADE
Referenced by:
    TABLE "web_events" CONSTRAINT "web_events_fkey_account" FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE
```


## sales_reps table

The child table `sales_reps`

```console
parch_posey=# \d sales_reps
              Table "public.sales_reps"
  Column   |  Type   | Collation | Nullable | Default
-----------+---------+-----------+----------+---------
 id        | integer |           | not null |
 name      | bpchar  |           |          |
 region_id | integer |           |          |
Indexes:
    "sales_reps_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "accounts" CONSTRAINT "accounts_fkey_sales_rep" FOREIGN KEY (sales_rep_id) REFERENCES sales_reps(id) ON DELETE CASCADE
```

The parent table `region`

```console
parch_posey=# \d region
               Table "public.region"
 Column |  Type   | Collation | Nullable | Default
--------+---------+-----------+----------+---------
 id     | integer |           | not null |
 name   | bpchar  |           |          |
Indexes:
    "region_pkey" PRIMARY KEY, btree (id)
```

In the `sales_reps` **TABLE** the **FOREIGN KEY**, `region_id` **REFERENCES** a record in the `region` table using the primary key (`id`). Let's name this foreign key **CONSTRAINT** `sales_reps_fkey_region`.

```console
parch_posey=# ALTER TABLE sales_reps
parch_posey-# ADD CONSTRAINT sales_reps_fkey_region
parch_posey-# FOREIGN KEY (region_id)
parch_posey-# REFERENCES region(id)
parch_posey-# ON DELETE CASCADE;
ALTER TABLE
```
Let's check it out.

```console
parch_posey=# \d sales_reps
              Table "public.sales_reps"
  Column   |  Type   | Collation | Nullable | Default
-----------+---------+-----------+----------+---------
 id        | integer |           | not null |
 name      | bpchar  |           |          |
 region_id | integer |           |          |
Indexes:
    "sales_reps_pkey" PRIMARY KEY, btree (id)
Foreign-key constraints:
    "sales_reps_fkey_region" FOREIGN KEY (region_id) REFERENCES region(id) ON DELETE CASCADE
Referenced by:
    TABLE "accounts" CONSTRAINT "accounts_fkey_sales_rep" FOREIGN KEY (sales_rep_id) REFERENCES sales_reps(id) ON DELETE CASCADE
```

The parent table `region`

```console
parch_posey=# \d region
               Table "public.region"
 Column |  Type   | Collation | Nullable | Default
--------+---------+-----------+----------+---------
 id     | integer |           | not null |
 name   | bpchar  |           |          |
Indexes:
    "region_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "sales_reps" CONSTRAINT "sales_reps_fkey_region" FOREIGN KEY (region_id) REFERENCES region(id) ON DELETE CASCADE
```

## orders table

The child table `orders`

```console
parch_posey=# \d orders
                              Table "public.orders"
      Column      |            Type             | Collation | Nullable | Default
------------------+-----------------------------+-----------+----------+---------
 id               | integer                     |           | not null |
 account_id       | integer                     |           |          |
 occurred_at      | timestamp without time zone |           |          |
 standard_qty     | integer                     |           |          |
 gloss_qty        | integer                     |           |          |
 poster_qty       | integer                     |           |          |
 total            | integer                     |           |          |
 standard_amt_usd | numeric(10,2)               |           |          |
 gloss_amt_usd    | numeric(10,2)               |           |          |
 poster_amt_usd   | numeric(10,2)               |           |          |
 total_amt_usd    | numeric(10,2)               |           |          |
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
```

The parent table `accounts`

```console
parch_posey=# \d accounts
                    Table "public.accounts"
    Column    |     Type      | Collation | Nullable | Default
--------------+---------------+-----------+----------+---------
 id           | integer       |           | not null |
 name         | bpchar        |           |          |
 website      | bpchar        |           |          |
 lat          | numeric(11,8) |           |          |
 long         | numeric(11,8) |           |          |
 primary_poc  | bpchar        |           |          |
 sales_rep_id | integer       |           |          |
Indexes:
    "accounts_pkey" PRIMARY KEY, btree (id)
Foreign-key constraints:
    "accounts_fkey_sales_rep" FOREIGN KEY (sales_rep_id) REFERENCES sales_reps(id) ON DELETE CASCADE
Referenced by:
    TABLE "web_events" CONSTRAINT "web_events_fkey_account" FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE
```

In the `orders` **TABLE** the **FOREIGN KEY**, `account_id` **REFERENCES** a record in the `accounts` table using the primary key (`id`). Let's name the foreign **CONSTRAINT** `orders_fkey_account`.

```console
parch_posey=# ALTER TABLE orders
parch_posey-# ADD CONSTRAINT orders_fkey_account
parch_posey-# FOREIGN KEY (account_id)
parch_posey-# REFERENCES accounts(id)
parch_posey-# ON DELETE CASCADE;
ALTER TABLE
```
Let's check it out.

```console
parch_posey=# \d orders
                              Table "public.orders"
      Column      |            Type             | Collation | Nullable | Default
------------------+-----------------------------+-----------+----------+---------
 id               | integer                     |           | not null |
 account_id       | integer                     |           |          |
 occurred_at      | timestamp without time zone |           |          |
 standard_qty     | integer                     |           |          |
 gloss_qty        | integer                     |           |          |
 poster_qty       | integer                     |           |          |
 total            | integer                     |           |          |
 standard_amt_usd | numeric(10,2)               |           |          |
 gloss_amt_usd    | numeric(10,2)               |           |          |
 poster_amt_usd   | numeric(10,2)               |           |          |
 total_amt_usd    | numeric(10,2)               |           |          |
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
Foreign-key constraints:
    "orders_fkey_account" FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE
```

The parent table `accounts`

```console
parch_posey=# \d accounts
                    Table "public.accounts"
    Column    |     Type      | Collation | Nullable | Default
--------------+---------------+-----------+----------+---------
 id           | integer       |           | not null |
 name         | bpchar        |           |          |
 website      | bpchar        |           |          |
 lat          | numeric(11,8) |           |          |
 long         | numeric(11,8) |           |          |
 primary_poc  | bpchar        |           |          |
 sales_rep_id | integer       |           |          |
Indexes:
    "accounts_pkey" PRIMARY KEY, btree (id)
Foreign-key constraints:
    "accounts_fkey_sales_rep" FOREIGN KEY (sales_rep_id) REFERENCES sales_reps(id) ON DELETE CASCADE
Referenced by:
    TABLE "orders" CONSTRAINT "orders_fkey_account" FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE
    TABLE "web_events" CONSTRAINT "web_events_fkey_account" FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE
```
