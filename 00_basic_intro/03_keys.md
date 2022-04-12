# Keys

If records in a table are not ordered,

- How are we to locate specific ones?
- And how can we distinguish one record from another?

The answer lies in specifying one or more columns in each table that define the **key** for that table's records.

The information in the **key** field or fields **must be unique** for each record.

- For example, in the *sales* database just described, the table containing information about each *salesperson* might designate the column containing the person's name as its key. Since it's possible that two members of the sales force have the same name, however, it would probably be better to store some other value in each salesperson record that's guaranteed to be unique for each member of the sales force. One obvious possibility for this value, at least in the US, is the salesperson's **Social Security number**.

- For some tables, **none of the information to be stored might provide an appropriate key**. In these cases, it is necessary to define a **column** containing some kind of **unique identification (typically a number)** to serve as the key.

- For other tables, the contents of **two or more columns taken together** can provide the value necessary to **uniquely identify each record**. In tables like these, a record's key consists of its values in both of those columns.

Keys are not always required for accessing information. Depending on the question asked, it might or might not be necessary to refer to each record's key value. In spite of this, the ability to uniquely identify each record in a table is an integral part of the relational model for handling data, and **every table must always define a key for its records**.

Correctly selecting keys for the tables in a database is not an easy task. In fact, choosing keys is only one aspect of the much larger problem of **designing a relational database**.

The **designer**, who might also be the **database administrator (DBA)** responsible for this system, must first determine how the data should be organised into tables. The best organisation will depend on exactly how that data is to be accessed.

The **DBA** (or whoever the designer is) must determine:

- the number of columns in each table,
- what the names and allowable contents of those columns should be,
- and many other specifics about the database ...

Luckily, accessing the data through SQL doesn't require any specialized knowledge about how a relational database should be defined. All a software developer or user needs to understand is how the tables in the database look to them.
