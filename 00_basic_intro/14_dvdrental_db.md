# DVDRENTAL sample database

The DVD rental database represents the business processes of a DVD rental store.

![dvdrental erd](./images/16_dvdrental.png)

## PostgreSQL Sample Database Tables

There are 15 tables in the DVD Rental database. The following table shows the table names in alphabetical order and the number of records.

| Table  | Rows |
|:-------|:----:|
|actor|200|
|address|603|
|category|16|
|city|600|
|country|109|
|customer|599|
|film|1000|
|film_actor|5462|
|film_category|1000|
|inventory|4581|
|language|6|
|payment|14596|
|rental|16044|
|staff|2|
|store|2|

We'll describe the tables following the order of the **parent relationships** graph.

![dvdrental3 erd](./images/22_dvdrental.png)

<hr>

![dvdrental2 erd](./images/21_dvdrental.png)

The picture above illustrates the `referenced_by` **relationship** between tables, or **parent** **relationship** graph :smile:. Over each table there is a number inside a circle shape indicating the longest path linking the first anchestor tables to this table. The length of a path is the number of archs linking the **first anchestor tables** to the numbered circle table.

For instance, the `category`, `language`, `actor` and `country` tables do not have a foreign key and therefore are not referenced by any table. It follows that the four tables do not have a parent table or anchestor. Thus, the number of archs is `zero` and they are the **first anchestor tables**.

Similarly, the longest path of the `store` table has length `4`, (`country` **->**`city`**->**`address`**->**`staff`**->**`store`).

The blach asterisck on the left of each column table represents the primary key. On the other hand, the red star represents a foreign key.

- `0` - **category**: lists the categories that can be assigned to a film.
- `0` - **language**: is a lookup table listing the possible languages that films can have for thier language.
- `0` - **actor**: lists information for all actors. The actor `table` is joined to the `film` table by means of the `film_actor` table.
- `0` - **country**: contains a list of countries.
- `1` - **film**: is a list of all films potentially in stock in the stores. The actual in-stock copies of each film are represented in the `inventory` table. The `film` table refers to the `language` table and is referenced by `film_category`, `film_actor` and `inventory`.
- `1` - **city**: is a list of cities. The `city` table is reffered to by a foreign key in the `address` table and refers to the `country` table using a foreign key.
- `2` - **film_category**: is used to support a *many-to-many* relationship between `films` and `categories`. For each category applied to a film, there will be one row in the `film_category` table listing the category and film. The `film_category` table refers to the `film` and `category` tables using foreign keys.
- `2` - **film_actor**: is used to support a *many-to-many* relationship between `films` and `actors`. For each actor in a given film, there will be one row in the `film_actor` table liating the actor and film.
- `2` - **address**: contains address information for customers, staff and stores. The `address` foreign key appears as a foreign key in the `customer`, `staff` and `store` tables.
- `4` - **store**: lists all stores in the system. All inventory is assigned to specific stores, and staff and customers are assigned a 'home store'.
- `4` - **customer**: contains a list of all customers. The `customer` table is referred to in the `payment` and `rental` tables and refers to the `address` and `store` tables.
- `4` - **staff**: lists all staff memebers, including informnation for email address, login information and picture. The `staff` table refers to the `store` and `address` tables using foreign keys, and is referred to by the `rental`, `payment` and `store`.
- `5` - **rental**: contains one row for each rental of each inventory item with information about who rented what item, when it was rented and when it was returned. The `rental` table refers to the `inventory`, `customer` and `staff` tables and is referred to by the `payment` table.
- `6` - **payment**: records each payment made by a customer, with information such as the amount and the rental being paid for (when applicable). The `payment` table refers to the `customer`, `rental` and `staff` tables.

## DVDRENTAL TABLES

**----------------------------------  Level 0  ------------------------------------**

### category

The category table lists the categories that can be assigned to a film. It's **columns** are as follows:

- **category_id**: A `SERIAL` containing a **unique** integer number for each category.
- **name**: A `VARCHAR (25)` containing the name of this category.
- **last_update**:A `TIMESTAMP` containing the time when the row was created or most recently updated.

The category table lists the categories that can be assigned to a film. Because it contains a unique value for each record, the **category_id** column is designated as the **key** for this table. It's basically a **surrogate primary key** used to uniquely identify each category.

### language

The language table is a lookup table listing the possible languages that films can have for thier language and their original language values. It's **columns** are as follows:

- **language_id**: A `SERIAL` containing a **unique** integer number for each language.
- **name**: A `VARCHAR (25)` containing the English name of the language.
- **last_update**: A `TIMESTAMP` containing the time when the row was created or most recently updated.

Because it contains a unique value for each record, the **language_id** column is designated as the **key** for this table. It's basically a **surrogate primary key** used to uniquely identify each language.

### actor

The actor table lists information for all actors. The actor `table` is joined to the `film` table by means of the `film_actor` table. It's **columns** are as follows:

- **actor_id**: A `SERIAL` containing a **unique** integer number for each actor.
- **first_name**: A `VARCHAR (45)` containing the first name of the actor.
- **last_name**: A `VARCHAR (45)` containing the last name of the actor.
- **last_update**: A `TIMESTAMP` containing the time when the row was created or most recently updated.

Because it contains a unique value for each record, the **actor_id** column is designated as the **key** for this table. It's basically a **surrogate primary key** used to uniquely identify each actor.

### country

The country table contains a list of countries. It's **columns** are as follows:

- **country_id**: A `SERIAL` containing a **unique** integer number for each country.
- **country**: A `VARCHAR (45)` containing the name of the country.
- **last_update**: A `TIMESTAMP` containing the time when the row was created or most recently updated.

Because it contains a unique value for each record, the **country_id** column is designated as the **key** for this table. It's basically a **surrogate primary key** used to uniquely identify each country.

**----------------------------------  Level 1  ------------------------------------**

### film

The film table is a list of all films potentially in stock in the stores. The actual in-stock copies of each film are represented in the `inventory` table. The `film` table refers to the `language` table and is referenced by `film_category`, `film_actor` and `inventory`. It's **columns** are as follows:

- **film_id**: A `SERIAL` containing a **unique** integer number for each film.
- **title**: A `VARCHAR (255)` containing the title of the film.
- **description**: A `TEXT` containing a short descriotion of plot summary of the film.
- **release_year**: A `year` containing the year in which the movie was released.
- **language_id**: A `SMALLINT` identifying the language of this film. `Values in this column are drawn from the column of the same name in the` **language** `table`.
- **rental_duration**: A `SMALLINT` indicating the lenght of the rental period, in days.
- **rental_rate**: A `NUMERIC (4,2)` indicating the cost to rent the film for the period specified in the rental duration column.
- **length**: A `SMALLINT` indicating the duration of the film, in minutes.
- **replacement_cost**: A `NUMERIC (5,2)` indicating the amount charged to the customer if the film is not returned or is returned in a damage state.
- **rating**: A `ENUM` type named `mpaa_rating` indicating the rating assigned to the film. Can be one of `G`,`PG`,`PG-13`,`R` or `NC-17`.
- **last_update**: A `TIMESTAMP` containing the time when the row was created or most recently updated.
- **sepcial_features**: A `TEXT []`, (text array), lists which common special features are included in the DVD. Can be zero or more of: `Trailers`, `Commentaries`, `Deleted Scenes`, `Behind the Scenes`.
- **last_update**: A `TIMESTAMP` containing the time when the row was created or most recently updated.
- **fulltext**: A `tsvector` containing the words in the text columns and their position in the concatenated string - `title` + `description`.

Because it contains a unique value for each record, the **country_id** column is designated as the **key** for this table. It's basically a **surrogate primary key** used to uniquely identify each country. The **language_id** column is a **foreign key** pointing to the `language` table, the language of the film.

### city

The table city is a list of cities. The `city` table is reffered to by a foreign key in the `address` table and refers to the `country` table using a foreign key. It's **columns** are as follows:

- **city_id**: A `SERIAL` containing a **unique** integer number for each city.
- **city**: A `VARCHAR (50)` containing the name of the city.
- **country_id**: A `SMALLINT` identifying the country that the city belongs to. `Values in this column are drawn from the column of the same name in the` **country** `table`.
- **last_update**: A `TIMESTAMP` containing the time when the row was created or most recently updated.

Because it contains a unique value for each record, the **city_id** column is designated as the **key** for this table. It's basically a **surrogate primary key** used to uniquely identify each country. The **country_id** column is a **foreign key** pointing to the `country` table, the country of the city.

**----------------------------------  Level 2  ------------------------------------**

### film_category

The film_category table is used to support a *many-to-many* relationship between `films` and `categories`. It's a bridge table. For each category applied to a film, there will be one row in the `film_category` table listing the category and film. The `film_category` table refers to the `film` and `category` tables using foreign keys. It's **columns** are as follows:

- **film_id**: A `SMALLINT` identifying the film associated to the categories in the category table linked to the film_category table.
- **category_id** A `SMALLINT` identifying the category applied to the films in the film table linked to the film_category table.
- **last_update**: A `TIMESTAMP` containing the time when the row was created or most recently updated.

The **film_id** and **category_id** form the **primary key** of this table. The **film_id** is a **foreign key** identifying the film. The **category_id** is a **foreign key** identifying the category.  

### film_actor

The film_actor table is used to support a *many-to-many* relationship between `films` and `actors`. For each actor in a given film, there will be one row in the `film_actor` table liating the actor and film. It's **columns** are as follows:

- **actor_id**: A `SMALLINT` identifying the actor associated to the films in the film table linked to the film_actor table.
- **film_id**: A `SMALLINT` identifying the film associated to the actors in the actor table linked to the film_actor table.
- **last_update**: A `TIMESTAMP` containing the time when the row was created or most recently updated.

The **film_id** and **actor_id** form the **primary key** of this table. The **film_id** is a **foreign key** identifying the film. The **actor_id** is a **foreign key** identifying the actor.

## address

The address table contains address information for customers, staff and stores. The `address` foreign key appears as a foreign key in the `customer`, `staff` and `store` tables. It's **columns** are as follows:

- **address_id**: A `SERIAL` containing a **unique** integer number for each address.
- **address**: A `VARCHAR (50)` containing the first line of an address.
- **address2**: A `VARCHAR (50)` containing an optional second line of an address.
- **district**: A `VARCHAR (20)` containing the region of an address, this may be a state, province, prefecture, etc.
- **city_id**: A `SMALLINT` identifying the city of the address. `Values in this column are drawn from the column of the same name in the` **city** `table`.
- **postal_code**: A `VARCHAR (10)` containing the postal code or ZIP code of the address (where applicable).
- **phone**: A `VARCHAR (20)` containing the telephone number for the address.
- **last_update**: A `TIMESTAMP` containing the time when the row was created or most recently updated.

Because it contains a unique value for each record, the **address_id** column is designated as the **key** for this table. It's basically a **surrogate primary key** used to uniquely identify each country. The **city_id** column is a **foreign key** pointing to the `city` table, the city of the address.
