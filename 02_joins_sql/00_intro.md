# Introduction

In this chapter you will learn how to combine data from multiple tables together.

Up to this point, we've only been working with one table at a time. But the real power of SQL comes from working with data across multiple tables at once.

The term **Relational Database** refers to the fact that tables within it relate to one another. They **contain common identifiers that allow information from multiple tables to be easily combined**.

Every query we have seen so far retrieves data from only a single table, with the only exception of the subquery examples given in the previous chapter.

If all of a database's information were contained in one large table, these these types of queries would be all that was required. Practically, though, **storing all the information in just one table would require maintaining several duplicate copies of the same values**.

For instance, keeping all of a company's data, from purchasing transactions to employee job satisfaction, to inventory in a single table or even Excel dataset does not make a ton of sense. The table would hold a ton of information and it'd be hard to determine a row call and structure for so many different types of data.

In real systems, therefore, all but the very simplest databases divide their information among several different tables. Databases give us the flexibility to keep things organized neatly in their own tables, so that they're **easy to find and work with** while also allowing us to **combine tables as needed** to solve problems that require several types of data.

Both in real databases and in our simple example databases, then, many interesting questions cannot be answered by retrieving data from only a single table. Instead, we must form queries that simultaneously access two or more tables.

Any query that extracts data from more than one table must perform a **join**. As its name suggests, a **join means that some or all of the specified tables'contents are joined together in the results of the query**.


In this chapter, we are going to take a look at how to leverage SQL to link tables together. You are about to see why SQL is one of the most popular environment for working with data as we learn how to write what are known as **joints**.
