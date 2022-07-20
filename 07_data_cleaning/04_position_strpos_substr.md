# POSITION - STRPOS - SUBSTR

1. Use the `accounts` table to create first and last name columns that hold the first and last names for the `primary_poc`.

```console
parch_posey=# SELECT primary_poc FROM accounts LIMIT 5;
```

|  primary_poc|
|:--------------:|
| Tamara Tuma|
| Sung Shields|
| Jodee Lupo|
| Serafina Banda|
| Angeles Crusoe|

```SQL
SELECT LEFT(primary_poc, STRPOS(primary_poc, ' ') -1 ) first_name,
       RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name
  FROM accounts;
```

**Results**

|first_name |  last_name|
|:---------:|:-------------:|
|Tamara     | Tuma|
|Sung       | Shields|
|Jodee      | Lupo|
|Serafina   | Banda|
|Angeles    | Crusoe|
