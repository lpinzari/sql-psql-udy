# uniy backup: Exporting & Importing tables as csv files

In the previous lesson we finalized the implementation of the **uniy-db.sql** file and executed the script to reinitalized the database.

Now, suppose that we added, deleted or updated records in the `uniy` sample database and want to save the current state of the database.

Clearly, it would be insane to edit the `uniy-db.sql` file to reflect the records stored in the database tables. A possible solution is to export all the tables in separate `csv` files.
