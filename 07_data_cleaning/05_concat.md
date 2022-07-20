# CONCAT Examples

1. Each company in the accounts table wants to create an email address for each `primary_poc`. The email address should be the first name of the `primary_poc` . last name **primary_poc @** `company name` **.com**.

|primary_poc|
|:--------------:|
|Tamara Tuma|
|Sung Shields|
|Jodee Lupo|
|Serafina Banda|
|Angeles Crusoe|


```SQL
WITH t1 AS (
 SELECT LEFT(primary_poc,STRPOS(primary_poc, ' ') -1 ) first_name,  
        RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name, name
   FROM accounts)

SELECT first_name,
       last_name,
       CONCAT(first_name, '.', last_name, '@', name, '.com')
FROM t1;
```

The `LEFT` function extract the characters of the string `first_name` beginning from the left except (`-1`) the first space character. Similarly, the `RIGHT` function extract the remaining characters.

Here's the partial output:

|first_name |  last_name   |                        concat|
|:---------:|:------------:|:-----------------------------------------------------:|
|Tamara     | Tuma         | Tamara.Tuma@Walmart.com|
|Sung       | Shields      | Sung.Shields@Exxon Mobil.com|
|Jodee      | Lupo         | Jodee.Lupo@Apple.com|
|Serafina   | Banda        | Serafina.Banda@Berkshire Hathaway.com|
|Angeles    | Crusoe       | Angeles.Crusoe@McKesson.com|
|Savanna    | Gayman       | Savanna.Gayman@UnitedHealth Group.com|

2. You may have noticed that in the previous solution some of the company names include spaces, which will certainly not work in an email address. See if you can create an email address that will work by removing all of the spaces in the account name, but otherwise your solution should be just as in question 1. Some helpful documentation is [here](https://www.postgresql.org/docs/8.1/functions-string.html).

|name|
|:------------------:|
|Walmart|
|**Exxon Mobil**|
|Apple|
|**Berkshire Hathaway**|
|McKesson|


```SQL
WITH t1 AS (
 SELECT LEFT(primary_poc,STRPOS(primary_poc, ' ') -1 ) first_name,  
        RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name, name
   FROM accounts)

SELECT first_name,
       last_name,
       CONCAT(first_name, '.', last_name, '@', REPLACE(name, ' ', ''), '.com')
FROM  t1;
```

Here's the partial output:

|first_name |  last_name   |                      concat|
|:---------:|:------------:|:--------------------------------------------------:|
|Tamara     | Tuma         | Tamara.Tuma@Walmart.com|
|Sung       | Shields      | Sung.Shields@ExxonMobil.com|
|Jodee      | Lupo         | Jodee.Lupo@Apple.com|
|Serafina   | Banda        | Serafina.Banda@BerkshireHathaway.com|
|Angeles    | Crusoe       | Angeles.Crusoe@McKesson.com|
|Savanna    | Gayman       | Savanna.Gayman@UnitedHealthGroup.com|
|Anabel     | Haskell      | Anabel.Haskell@CVSHealth.com|


3. We would also like to create an `initial password`, which they will change after their first log in. The first password will be the `first letter` of the **primary_poc's first name (lowercase)**, then the `last letter` of their **first name (lowercase)**, the `first letter` of their **last name (lowercase)**, the `last letter` of their **last name (lowercase)**, the number of letters in their first name, the number of letters in their last name, and then the name of the company they are working with, **all capitalized with no spaces**.

```SQL
WITH t1 AS (
 SELECT LEFT(primary_poc,STRPOS(primary_poc, ' ') -1 ) first_name,  
        RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name, name
   FROM accounts)

SELECT first_name,
       last_name,
       CONCAT(first_name, '.', last_name, '@', name, '.com'),
       LEFT(LOWER(first_name), 1) || RIGHT(LOWER(first_name), 1) || LEFT(LOWER(last_name), 1) || RIGHT(LOWER(last_name), 1) || LENGTH(first_name) || LENGTH(last_name) || REPLACE(UPPER(name), ' ', '') AS password
FROM t1;
```

Here's the partial output:

|first_name |  last_name   |                        concat                        |                password|
|:-----------:|:-------------:|:------------------------------------------------------:|:---------------------------------------:|
|Tamara | Tuma  | Tamara.Tuma@Walmart.com  | tata64WALMART|
|Sung   | Shields   | Sung.Shields@Exxon Mobil.com | sgss47EXXONMOBIL|
|Jodee  | Lupo     | Jodee.Lupo@Apple.com         | jelo54APPLE|
