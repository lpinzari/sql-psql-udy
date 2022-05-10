# Why would we want to split data into separate tables ?

To understand what joins are and why they are helpful let's think about at the following scenario. Suppose that we decided to model the orders and customers of a company with two tables named `accounts` and `orders`.

**accounts**

|id|name       |website     |address|city|state|zip|country|
|:--:|:-------:|:----------:|:-----:|:--:|:---:|:--:|:----:|
|**1001**|company_1|www.webA.com|add_1  |c1|s1|z1|c1|
|**1011**|company_2|www.webB.com|add_2  |c2|s2|z2|c2|
|1022|company_3|www.webC.com|add_3  |c3|s3|z3|c3|

The table accounts keeps the information of a customer such as the name, website, address and etc.

**orders**

|id  | account_id| time|
|:--:|:---------:|:---:|
|1|`1001`|time1|
|2|`1001`|time2|
|3|`1011`|time3|
|4|`1011`|time4|

On the other hand, the orders table keeps only information about the time an order has been placed. Keep in mind that this is a toy example.

You'll notice that none of the **orders** say the name of the customer indicated in the `name` column of the accounts table. Instead, the table refers to the name of the customers by numerical values in the `account_id` column that acts as a foreign key.

- Why isn't the customer's name in the orders table?

There are a few reasons that someone might have made the decision to separate orders from the information about the customers placing those orders.

There are several reasons why relational databases are like this. Let's focus on two of the most important ones.

1. First, **orders** and **accounts** are `different types` of `objects`, and will be easier to organize if kept separate.

2. Second, this multi-table structure allows queries to execute more quickly.

Let's look at each of those points more closely.

The accounts and orders tables store fundamentally different types of objects. Maybe we only want one account per company or customer and want to be up-to-date with the latest information.

Let's say we want to update the website name of account_id with the `www.WebE.com`.

**accounts**

|id|name       |website     |address|city|state|zip|country|
|:--:|:-------:|:----------:|:-----:|:--:|:---:|:--:|:----:|
|1001|name_1|www.webA.com|add_1  |c1|s1|z1|c1|
|1011|name_2|www.webB.com|add_2  |c2|s2|z2|c2|
|1022|name_3|`www.webD.com`|add_3  |c3|s3|z3|c3|

On the other hand the records of orders are likely to stay the same once they are entered, and once they're filled.

A given customer might have multiple orders and rather than change a past order, he adds a three new orders.

**orders**

|id  | account_id| time|
|:--:|:---------:|:---:|
|1|1001|time1|
|2|1001|time2|
|3|1011|time3|
|4|1011|time4|
|`5`|`1011`|`Now`|
|`6`|`1011`|`Now`|
|`7`|`1011`|`Now`|

Because these objects operate differently, it makes sense for them to live in different tables. The table **orders** is more likely to have `INSERT INTO` statements and the **accounts** table is more likely to have `UPDATE` statements. Moreover, the DBMS will execute more `INSERT INTO` statements than `UPDATE` statements.


Another reason accounts and orders might be stored separately has to do with the speed at which databases can modify data. When you run a query, its execution speed depends on the amount of data you are asking the database to read and the number and type of calculations you are asking it to make. Let's consider the following database instance.

**accounts**

|id|name       |website     |address|city|state|zip|country|
|:--:|:-------:|:----------:|:-----:|:--:|:---:|:--:|:----:|
|1001|name_1|www.webA.com|add_1  |c1|s1|z1|c1|
|1011|name_2|www.webB.com|add_2  |c2|s2|z2|c2|


**orders**

|id  | account_id| time|
|:--:|:---------:|:---:|
|1|1001|time1|
|2|1001|time2|
|3|1011|time3|
|4|1011|time4|
|5|1011|time5|

Imagine a world, where the account names and address are added into the orders table.
For simplicity, let's drop the last record in  the account table.

**orders**

|id  | account_id| time|name       |website     |address|city|state|zip|country|
|:--:|:---------:|:---:|:-------:|:----------:|:-----:|:--:|:---:|:--:|:----:|
|1|1001|time1|`name_1`|`www.webA.com`|`add_1`  |`c1`|`s1`|`z1`|`c1`|
|2|1001|time2|`name_1`|`www.webA.com`|`add_1`  |`c1`|`s1`|`z1`|`c1`|
|3|1011|time3|**name_2**|**www.webB.com**|**add_2**  |**c2**|**s2**|**z2**|**c2**|
|4|1011|time4|**name_2**|**www.webB.com**|**add_2**|**c2**|**s2**|**z2**|**c2**|
|5|1011|time5|`name_1`|`www.webA.com`|`add_1`  |`c1`|`s1`|`z1`|`c1`|


This means, the table would have 7 additional columns and records with redundant information and **larger data storage overhead**.

Let's say, a customer changes their address, city, state, zip and country. If an address changes, we need to update all the records with duplicate information instead of just one update in the other table.

In this world, the the five address columns need to be updated retroactively for every single order. This means five updates times the orders that they have made.

By contrast, keeping account details in a separate table makes this only a total of five updates. The larger the data set, the more that this matters.

There are more reasons for this kind of structures but for now, what you really need to know is how to connect tables together with the join operator.

Later in the course I'll talk about the idea behind Database design and Database Normalization.

## Database Normalization

When creating a database, it is really important to think about how data will be stored. This is known as normalization, and it is a huge part of most SQL classes. If you are in charge of setting up a new database, it is important to have a thorough understanding of database normalization.

There are essentially three ideas that are aimed at database normalization:

- Are the tables storing logical groupings of the data?
- Can I make changes in a single location, rather than in many tables for the same information?
- Can I access and manipulate data quickly and efficiently?

This is discussed in detail [here](https://www.itprotoday.com/sql-server/sql-design-why-you-need-database-normalization).

However, most analysts are working with a database that was already set up with the necessary properties in place. As analysts of data, you don't really need to think too much about data normalization. You just need to be able to pull the data from the database, so you can start making insights. This will be our focus in this lesson.
