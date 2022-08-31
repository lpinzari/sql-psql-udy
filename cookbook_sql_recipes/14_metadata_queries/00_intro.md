# Meta Data Queries

Although only partly specified by the standard, each relational dbms manages its own **data dictionary** (or rather the `description of the tables present in the database`) using a **relational schema**.

The database therefore contains **two types of table**:
- those that contain the `data` and
- those that contain the **metadata**.

The second group of tables constitutes the `catalogue` **of the database**.

This characteristic of relational system implementations is known as reflexivity. A dbms typically manages the catalogue by using structures similar to those in which the database instance is stored.

Thus, an object-oriented database, such as PostgreSql, for example, will have a data dictionary that is defined on an object model. In this way, the database can use the same functions for the internal organization of metadata as are used for the management of the database instance.

The definition and modification commands of the database schema could, in theory, be replaced by manipulation commands that operate directly on the tables of the data dictionary, making superfluous the introduction of special commands for the definition of the schema. This is not done, however, for two reasons. The first is the absence of a standardization of the dictionary, which differs greatly from one product to the next. The second is the necessity of ensuring that the commands for the manipulation of schemas are clear and immediately recognizable, and furthermore syntactically distinguishable from the commands that modify the database instance.

The SQL-2 standard for the data dictionary is based on a two-tier description.

The first level is that of `DEFINITION_SCHEMA`, made up of a collection of tables that contain the descriptions of all the structures in the database. The collection of tables appearing in the standard, however, is not used by any implementation, since the tables provide a description of only those aspects of a database covered by sql-2. What is left out, in particular, is all the information concerning the storage structures, which, even if not present in the standard, form a fundamental part of a schema. The tables of the standard, therefore, form a template to which the systems are advised (but not obliged) to conform.

The second component of the standard is the **INFORMATION_SCHEMA**. This consists of a collection of views on the `DEFINITION_SCHEMA`. These views fully constitute part of the standard and form an interface for the data dictionary, which must be offered by the systems that want to be compatible with the standard.

A full description of the `INFORMATION_SCHEMA` is given [here](https://cloud.google.com/spanner/docs/information-schema-pg).

Another great resource is the official manual documentation:

- [information schema](https://www.postgresql.org/docs/current/information-schema.html)
- [System Views](https://www.postgresql.org/docs/current/views-overview.html)
- [dictionary](https://www.postgresql.org/docs/11/catalogs-overview.html)

This chapter presents recipes that allow you to find information about a given schema. For example, you may want to know what tables you’ve created or which foreign keys are not indexed.

**information_schema tables are available only through SQL interfaces**.
