# REGEXP_MATCHES Function PostgreSQL

The PostgreSQL `REGEXP_MATCHES()` function **matches a regular expression against a string and returns matched substrings**.

The following illustrates the syntax of the PostgreSQL `REGEXP_MATCHES()` function:

```SQL
REGEXP_MATCHES(source_string, pattern [, flags])
```

## Arguments

The **REGEXP_MATCHES()** function accepts three arguments:

1. **source**: The source is a string that you want to extract substrings that match a regular expression.

2. **pattern**: The pattern is a [POSIX](https://en.wikibooks.org/wiki/Regular_Expressions/POSIX_Basic_Regular_Expressions) regular expression for matching.

3. **flags**: The flags argument is one or more characters that control the behavior of the function. For example, `i` allows you to **match case-insensitively**.

## Return Value

The `REGEXP_MATCHES()` function returns a set of text, even if the result array only contains a single element.

## Examples

Suppose, you have a social networking’s post as follows:

```SQL
'Learning #PostgreSQL #REGEXP_MATCHES'
```

The following statement allows you to extract **the hashtags such as** `PostgreSQL` and `REGEXP_MATCHES`:

```SQL
SELECT
    REGEXP_MATCHES('Learning #PostgreSQL #REGEXP_MATCHES',
         '#([A-Za-z0-9_]+)', 'g');
```

In this example, the following regular expression matches any word that starts with the hash character (`#`) and is followed by any alphanumeric characters `A-Za-z0-9` or underscore (`_`).

```console
#([A-Za-z0-9_]+)
```
The `g` flag argument is for the global search.

The following is the result:

|regexp_matches|
|-----------------|
| {PostgreSQL}|
| {REGEX_MATCHES}|

The result set has two rows, each is an `array`, which **indicates that there are two matches**.

Noted that the `REGEXP_MATCHES()` returns each **row as an array**, rather than a string. **Because if you use groups to capture parts of the text**, the array will contain the groups as shown in the following example:

```SQL
SELECT REGEXP_MATCHES('ABC', '^(A)(..)$', 'g');
```

The result is:

|regexp_matches|
|:--------------:|
| {A,BC}|

See the following `film` table from the `dvdrental` sample database:

```console
dvdrental=# \d film
                                              Table "public.film"
      Column      |            Type             | Collation | Nullable |                Default
------------------+-----------------------------+-----------+----------+---------------------------------------
 film_id          | integer                     |           | not null | nextval('film_film_id_seq'::regclass)
 title            | character varying(255)      |           | not null |
 description      | text                        |           |          |
 release_year     | year                        |           |          |
 language_id      | smallint                    |           | not null |
 rental_duration  | smallint                    |           | not null | 3
 rental_rate      | numeric(4,2)                |           | not null | 4.99
 length           | smallint                    |           |          |
 replacement_cost | numeric(5,2)                |           | not null | 19.99
 rating           | mpaa_rating                 |           |          | 'G'::mpaa_rating
 last_update      | timestamp without time zone |           | not null | now()
 special_features | text[]                      |           |          |
 fulltext         | tsvector                    |           | not null |
```

The following statement uses the `REGEXP_MATCHES()` function to **get films whose descriptions contain the word** `Cat` or `Dog`:

```SQL
SELECT film_id,
       title ,
       description,
       REGEXP_MATCHES(description, 'Cat | Dog ') cat_or_dog
  FROM film
 ORDER BY title
 LIMIT 3;
```

**Results**

|film_id |      title      |                                              description                                             | cat_or_dog|
|:---------:|:----------------:|:-------------------------------------------------------------------------------------------------------:|:-----------:|
|11 | Alamo Videotape | A Boring Epistle of a Butler And a Cat who must Fight a Pastry Chef in A MySQL Convention             | {"Cat "}|
|15 | Alien Center    | A Brilliant Drama of a Cat And a Mad Scientist who must Battle a Feminist in A MySQL Convention       | {"Cat "}|
|17 | Alone Trip      | A Fast-Paced Character Study of a Composer And a Dog who must Outgun a Boat in An Abandoned Fun House | {" Dog "}|
