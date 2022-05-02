# Backup a Database

In the previous lessons, we learned how to implement a `sql` script to destroy and create the database schema, and to populate the tables in the database. Moreover, we learned how to export a table to a csv file and import new records from a csv file.

In this lesson, you will learn a very powerful and convenient way to **backup the PostgreSQL databases** using the `pg_dump` and `pg_dumpall` tools.

## PostgreSQL Backup - pg_dump and pg_dumpall

Backing up databases is one of the most critical tasks in database administration. Before backing up the databases, you should consider the following type of backups:

- Full / partial databases
- Both data and structures, or only structures
- Point-in-time recovery
- Restore performance

PostgreSQL comes with `pg_dump` and `pg_dumpall` tools that help you backup databases easily and effectively.

### pg_dump

- **pg_dump**: extract a PostgreSQL database into a script file or other archive file

**pg_dump** is a utility for backing up a PostgreSQL database. It makes consistent backups even if the database is being used concurrently.

- `pg_dump` does not block other users accessing the database (readers or writers).
- `pg_dump` only dumps a single database.

To back up an entire cluster, or to back up global objects that are common to all databases in a cluster (such as roles and tablespaces), use `pg_dumpall`.

Dumps can be output in **script** or **archive file** formats.

- **Script** dumps are plain-text files containing the SQL commands required to reconstruct the database to the state it was in at the time it was saved.

We discussed how to implement a sql script from scratch and how to restore a database from such a script by feeding it to `psql`. Now, it's time to create an sql script using the `pg_dump` utility.

It's worth noting that **script files can be used to reconstruct the database even on other machines and other architectures**; with some modifications, even on other SQL database products.

- **Archive formats**: The alternative archive file formats must be used with [pg_restore](https://www.postgresql.org/docs/14/app-pgrestore.html) to rebuild the database.

They allow `pg_restore` to be selective about what is restored, or even to reorder the items prior to being restored. **The archive file formats are designed to be portable across architectures**.

When used with one of the archive file formats and combined with `pg_restore`, `pg_dump` provides a flexible archival and transfer mechanism.

- pg_dump can be used to backup an entire database, then pg_restore can be used to examine the archive and/or select which parts of the database are to be restored.

The most flexible output file formats are the “custom” format (-Fc) and the “directory” format (-Fd). They allow for selection and reordering of all archived items, support parallel restoration, and are compressed by default. The “directory” format is the only format that supports parallel dumps.

The general syntax is:

- `pg_dump [connection-option...] [option...] [dbname]`

For a discussion of the available options see the [documentation](https://www.postgresql.org/docs/14/app-pgdump.html). For now, we'll show the basic options to backup easily a database.

In the following section, you will learn step by step how to
- backup one database,
- all databases (not recommended), and
- only database objects.

For example, to backup the `uniy` sample database to the `uniy_db_backup.sql` file in the `/pgbackup` folder of  the `/Users/ludovicopinzari/` directory, we could type:

```console
$ pg_dump -U usertest -F p -O --no-tablespaces -c --if-exists --column-inserts uniy > /Users/ludovicopinzari/pgbackup/uniy_db_backup.sql
```


Let’s examine the options in more detail.

**Database connection parameters**

- **-U** `usertest`:  specifies the user to connect to the PostgreSQL database server. We used the `usertest` in this example but you could use the `postgres` or any other user with granted privileges.

**content and format of the output parameters**

- **F** : specifies the output file format that can be one of the following:
  - `c`: custom-format archive file format
  - `d`: directory-format archive
  - `t`: tar
  - `p`: plain-text SQL script file.

In this example, we use  **-F** `p` to specify the output file as a SQL script file.

- **-O** or **--no-owner**: skip restoration of object ownership in plain-text format. Do not output commands to set ownership of objects to match the original database.

- **--no-tablespace**: Do not output commands to select tablespaces. With this option, all objects will be created in whichever tablespace is the default during restore.

- **-c** or **--clean**: Output commands to clean (drop) database objects prior to outputting the commands for creating them.

- **--if-exists**: use `IF EXISTS` when dropping objects.

- **--column-inserts**: Dump data as `INSERT` commands (rather than COPY) with column names. This will make restoration very slow; **it is mainly useful for making dumps that can be loaded into non-PostgreSQL databases**. We'll see an example without this option later in this lesson.

- `uniy`: is the **name of the database** that you want to back up.

- `/Users/ludovicopinzari/pgbackup/uniy_db_backup.sql` is the **output backup file path**. Note the path must be an **absolute path**. If you simply type the name of the script file `uniy_db_backup.sql`, the file will be saved in the current working directory.

```console
pg_dump -U usertest -F p uniy > uniy_db_backup.sql
```

Please **follow the instructions below** to complete the editing of the backup sql script file.

## How to backup one database with a platform independent sql script

To backup one database, you can use the `pg_dump` tool. The `pg_dump` dumps out the content of all database objects into a single file.

Before executing the `pg_dump` command let's complete some tasks first.

We are going to create the `uniy` sample database using the `uniy_db.sql` file created in the previous lessons. Next, we'll use the `pg_dump` command to create a new sql script file named `uniy_db_backup.sql`.

```console
(base) ludo /~  $  ls uniy-db.sql
uniy-db.sql
```

The script is in the current working directory.

```console
(base) ludo /~  $  psql uniy -U usertest
psql (11.4)
Type "help" for help.

uniy=> \i uniy-db.sql
BEGIN
psql:uniy-db.sql:23: NOTICE:  table "students" does not exist, skipping
psql:uniy-db.sql:23: NOTICE:  table "courses" does not exist, skipping
psql:uniy-db.sql:23: NOTICE:  table "teachers" does not exist, skipping
psql:uniy-db.sql:23: NOTICE:  table "sections" does not exist, skipping
psql:uniy-db.sql:23: NOTICE:  table "enrolls" does not exist, skipping
DROP TABLE
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE TABLE
INSERT 0 12
INSERT 0 5
INSERT 0 7
INSERT 0 6
INSERT 0 17
COMMIT
```

Now the database state is restored again. Now, let's use the `pg_dump` command to create a new script file named `uniy_db_backup.sql`.

The command is

- **pg_dump** `[db_name]` **>** `[backup_script.sql]`
  Where
  - `[db_name]`: is the name of your database.
  - `[backup_script.sql]`: is the name of your sql script.

In the case of the `uniy` sample database the syntax is:

- **pg_dump** `uniy` **>** `uniy_db_backup.sql`

Let's execute the command in the command line. We first quit the connection session and then create the backup file in the current working directory.

```console
uniy=> \q
(base) ludo /~  $  pg_dump -U usertest -F p uniy > /Users/ludovicopinzari/pgbackup/uniy_db_backup.sql
(base) ludo /~  $  ls pgbackup/uniy_db_backup.sql
uniy_db_backup.sql
```

Note: The `pg_dump` utility comes with the PostgreSQL installation. However, if the `bin` folder is not part of your `PATH` variables, for a more details about the  environmental variables follow the link:[environmental variables](https://github.com/lpinzari/unix-shell-udy/blob/master/command_line_essentials/14_shell_environment_variables.md), then you have to navigate to the bin directory of your PostgreSQL installation. The path of the `bin` directory depends on your system. Please see the documentation [here](https://www.postgresql.org/docs/current/install-procedure.html#:~:text=All%20files%20will%20be%20installed,optional%20features%20that%20are%20built.).

Let's see the content of the `uniy_db_backup.sql` file.

```console
(base) ludo /~  $  cat pgbackup/uniy_db_backup.sql
--
-- PostgreSQL database dump
--

-- Dumped from database version 11.4
-- Dumped by pg_dump version 11.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';
SET default_with_oids = false;
```

There are a few important things to note related to the backup content. The first is that `pg_dump` places a bunch of `SET` statements at the very beginning of the backup; such SET statements are not mandatory for the backup, but for restoring from this backup's content. In other words, the first few lines of the backup are not related to the content of the backup, but to how to use such a backup.

An important line among those SET statements is the following one, which has been introduced in recent versions of PostgreSQL:

```console
SELECT pg_catalog.set_config('search_path', '', false);
```

Such lines remove the `search_path` variable, which is the list of schema names among those to search for an unqualified object. The effect of such a line is that every object that's created from the backup during a restore will not exploit any malicious code that could have tainted your environment and your `search_path`. The side effect of this, as will be shown later on, is that after restoration, the user will have an empty search path and will not be able to find any not fully qualified objects by their names.

If you want to remove the `SET default_tablespace = '';` use the following options: **--no-tablespace**.

For more information about `tablespace` please refer to this documentation link [tablespace](https://www.postgresql.org/docs/current/manage-ag-tablespaces.html).
Then it starts creating the tables in the database in alphabetical order.

As for the `SET default_with_oids = false`, if you plan to use the DB as it is, **you can safely remove this line** before restoring (you have to be really sure that they are not referred to). It will be left set to the default false. For more information about this option please check the documentation in the following link: [default_with_oids (boolean)](https://www.postgresql.org/docs/9.4/runtime-config-compatible.html#GUC-DEFAULT-WITH-OIDS).The use of OIDs in user tables is considered deprecated, so most installations should leave this variable disabled. This variable can be enabled for compatibility with old applications that do not follow this behavior.

**We can remove all the setting stuff if we want to make the script portable on different platform**. I just want plain sql statements.

```console
--
-- Name: courses; Type: TABLE; Schema: public; Owner: usertest
--

CREATE TABLE public.courses (
    course_id smallint NOT NULL,
    course_name character(20),
    department character(16),
    num_credits smallint
);


ALTER TABLE public.courses OWNER TO usertest;
```
For example, the `courses` table declaration includes only the column constraint `NOT NULL` for the `course_id`. It's worth noting that the `PRIMARY KEY` **CONSTRAINT** is not defined yet. The definition of the `PRIMARY KEY` constraint appears later in the file. Next, it assigns the creation of the table to `usertest`. I remind you that we created the database using the `usertest` profile. If **you do not want to output commands to set ownership of objects to match the original database** and to make a script that can be restored by any user, but will give that user ownership of all the objects, specify **-O**.

```console
--
-- Name: enrolls; Type: TABLE; Schema: public; Owner: usertest
--

CREATE TABLE public.enrolls (
    course_id smallint NOT NULL,
    section_id smallint NOT NULL,
    student_id smallint NOT NULL,
    grade smallint
);


ALTER TABLE public.enrolls OWNER TO usertest;
```

The second table in alpahbetical order is `enrolls`. The script does exactly the same here. All the columns of the primary key are set to `NOT NULL`.

```console
--
-- Data for Name: courses; Type: TABLE DATA; Schema: public; Owner: usertest
--

COPY public.courses (course_id, course_name, department, num_credits) FROM stdin;
450	Western Civilization	History         	3
730	Calculus IV         	Math            	4
290	English Composition 	English         	3
480	Compiler Writing    	Computer Science	3
550	Art History         	History         	3
\.
```

Then it populates the tables starting from the first in alphabetical order. It populates the tables with the `COPY FROM` command. The `COPY FROM` command is not supported by other DBMS. Therefore, this script is not portable to all the DBMS.

```console
--
-- Name: courses courses_pkey; Type: CONSTRAINT; Schema: public; Owner: usertest
--

ALTER TABLE ONLY public.courses
    ADD CONSTRAINT courses_pkey PRIMARY KEY (course_id);
```
Then it adds all the `PRIMARY KEY` constraints.

```console
--
-- Name: enrolls enrolls_fkey_course; Type: FK CONSTRAINT; Schema: public; Owner: usertest
--

ALTER TABLE ONLY public.enrolls
    ADD CONSTRAINT enrolls_fkey_course FOREIGN KEY (course_id) REFERENCES public.courses(course_id) ON DELETE CASCADE;


--
-- Name: enrolls enrolls_fkey_section; Type: FK CONSTRAINT; Schema: public; Owner: usertest
--

ALTER TABLE ONLY public.enrolls
    ADD CONSTRAINT enrolls_fkey_section FOREIGN KEY (course_id, section_id) REFERENCES public.sections(course_id, section_id) ON DELETE CASCADE;


--
-- Name: enrolls enrolls_fkey_student; Type: FK CONSTRAINT; Schema: public; Owner: usertest
--

ALTER TABLE ONLY public.enrolls
    ADD CONSTRAINT enrolls_fkey_student FOREIGN KEY (student_id) REFERENCES public.students(student_id) ON DELETE CASCADE;
```

Lastly, it adds the `FOREIGN KEY` **CONSTRAINTS** in the right order. Here the `ONLY` keyword indicates that the command should apply only to the specified table, and not any tables below the table in the inheritance hierarchy. For more information about tables inheritance follow the link: [table inheritance](https://www.postgresql.org/docs/current/ddl-inherit.html).


### --column-inserts

However, if we want to include the `INSERT INTO` statements we could type:

```console
pg_dump -U usertest -F p --column-inserts uniy > /Users/ludovicopinzari/pgbackup/uniy_db_backup.sql
```

We added `--column-inserts` option.

```console
--
-- Data for Name: courses; Type: TABLE DATA; Schema: public; Owner: usertest
--

INSERT INTO public.courses (course_id, course_name, department, num_credits) VALUES (450, 'Western Civilization', 'History         ', 3);
INSERT INTO public.courses (course_id, course_name, department, num_credits) VALUES (730, 'Calculus IV         ', 'Math            ', 4);
INSERT INTO public.courses (course_id, course_name, department, num_credits) VALUES (290, 'English Composition ', 'English         ', 3);
INSERT INTO public.courses (course_id, course_name, department, num_credits) VALUES (480, 'Compiler Writing    ', 'Computer Science', 3);
INSERT INTO public.courses (course_id, course_name, department, num_credits) VALUES (550, 'Art History         ', 'History         ', 3);
```

As you can see, the `--column-inserts` option **Dump data** as `INSERT` commands (rather than COPY).

It's worth noting that **we need to DROP all the tables** in the `uniy` sample database **before the execution of this script**. The `DROP TABLE` statements are missing in the script. If we want to clean all the database objects then an `option` to be used is:

### --clean --if-exists

- **-c** or (**--clean**): Output commands to clean (drop) database objects prior to outputting the commands for creating them. (Unless **--if-exists** is also specified, restore might generate some harmless error messages, if any objects were not present in the destination database.)

```console
pg_dump -U usertest -F p -c --if-exists --column-inserts uniy > /Users/ludovicopinzari/pgbackup/uniy_db_backup.sql
```

Let's see the output of this command.

```console
ALTER TABLE IF EXISTS ONLY public.sections DROP CONSTRAINT IF EXISTS sections_fkey_teacher;
ALTER TABLE IF EXISTS ONLY public.sections DROP CONSTRAINT IF EXISTS sections_fkey_course;
ALTER TABLE IF EXISTS ONLY public.enrolls DROP CONSTRAINT IF EXISTS enrolls_fkey_student;
ALTER TABLE IF EXISTS ONLY public.enrolls DROP CONSTRAINT IF EXISTS enrolls_fkey_section;
ALTER TABLE IF EXISTS ONLY public.enrolls DROP CONSTRAINT IF EXISTS enrolls_fkey_course;
ALTER TABLE IF EXISTS ONLY public.teachers DROP CONSTRAINT IF EXISTS teachers_pkey;
ALTER TABLE IF EXISTS ONLY public.students DROP CONSTRAINT IF EXISTS students_pkey;
ALTER TABLE IF EXISTS ONLY public.sections DROP CONSTRAINT IF EXISTS sections_pkey;
ALTER TABLE IF EXISTS ONLY public.enrolls DROP CONSTRAINT IF EXISTS enrolls_pkey;
ALTER TABLE IF EXISTS ONLY public.courses DROP CONSTRAINT IF EXISTS courses_pkey;
DROP TABLE IF EXISTS public.teachers;
DROP TABLE IF EXISTS public.students;
DROP TABLE IF EXISTS public.sections;
DROP TABLE IF EXISTS public.enrolls;
DROP TABLE IF EXISTS public.courses;
```

It's worth noting that the DBMS **drops first all the foreign keys constraints**. The only two tables with foreign keys are the `sections` and `enrolls` tables. The `sections` foreign key is removed first since the `enrolls` foreign key references the `sections` table. After removing the foreign key constraints, the script removes all the `primary key` constraints.

Lastly, it drops all the tables in the database.

### PostgreSQL: pg_dump without schema name

The `uniy_db_backup.sql` file adds the [schema](https://www.postgresqltutorial.com/postgresql-administration/postgresql-schema/) name `public` explicitly to the table name. Therefore, the world `public.` appears almost everywhere in the file.

PostgreSQL automatically creates a schema called public for every new database. Whatever object you create without specifying the schema name, PostgreSQL will place it into this public schema. Therefore, the following statements are equivalent:

```console
CREATE TABLE table_name (
  ...
);
```

and

```console
CREATE TABLE public.table_name (
  ...
);
```

Unfortunately, there is no command to switch it off. This can be a problem if we want to make the file portable to any platform. A possible solution is to name the database schema as the name of the dumped schema of the backup file. Another option is to use the powerful Unix command, **sed** to remove the world `public.` to all the sql statements in the `uniy_db_backup.sql` file.

I remind you that In PostgreSQL, a schema is a namespace that contains named database objects such as `tables`, `views`, `indexes`, `data types`, `functions`, `stored procedures` and `operators`.

So, How do we remove all the relevant `public.` strings in the file ?

In our database we have the following objects:

- TABLES
- FOREIGN KEY CONSTRAINS
- PRIMARY KEY CONSTRAINTS

It follows that the place where we need to remove the string `public.` are:

1. In the `clean` part of the database, when we drop all the tables constrains and the tables.

For example, in the `uniy` sample database in the first part of the `uniy_db_backup.sql` file, the lines that contain the `public.` string for the table `sections` to be removed are:

```console
ALTER TABLE IF EXISTS ONLY public.sections DROP CONSTRAINT IF EXISTS sections_fkey_teacher;
ALTER TABLE IF EXISTS ONLY public.sections DROP CONSTRAINT IF EXISTS sections_fkey_course;
....
DROP TABLE IF EXISTS public.sections;
```

It's clear that the string `ALTER TABLE IF EXISTS ONLY public.` might be replaced by the string `ALTER TABLE IF EXISTS `.

Similarly, the string `DROP TABLE IF EXISTS public.` might be replaced by the string `DROP TABLE IF EXISTS `

2. In the `create` part of the database, when we create all the tables in the database.

For example, in the `uniy` sample database in the `CREATE TABLE` part of the `uniy_db_backup.sql` file, the line that contains the `public.` string for the table `sections` to be removed is:

```console
CREATE TABLE public.sections
```

It's clear that the string `CREATE TABLE public.` might be replaced by the string `CREATE TABLE `.

3. In the `data` part of the database, when we insert records in the database tables.

For example, in the `uniy` sample database in the `INSERT INTO` part of the `uniy_db_backup.sql` file, the lines that contains the `public.` string for the table `sections` to be removed are:

```console
INSERT INTO public.sections (course_id, section_id, teacher_id, num_students) VALUES (450, 1, 303, 2);
INSERT INTO public.sections (course_id, section_id, teacher_id, num_students) VALUES (730, 1, 290, 6);
INSERT INTO public.sections (course_id, section_id, teacher_id, num_students) VALUES (290, 1, 430, 3);
INSERT INTO public.sections (course_id, section_id, teacher_id, num_students) VALUES (480, 1, 180, 3);
INSERT INTO public.sections (course_id, section_id, teacher_id, num_students) VALUES (450, 2, 560, 2);
INSERT INTO public.sections (course_id, section_id, teacher_id, num_students) VALUES (480, 2, 784, 2);
```

It's clear that the strings `INSERT INTO public.` might be replaced by the string `INSERT INTO `.

4. In the `constraint` part of the `uniy_db_backup` file, when we add  the **primary key** constraints to the database tables.

```console
ALTER TABLE ONLY public.sections
    ADD CONSTRAINT sections_pkey PRIMARY KEY (course_id, section_id);
```
It's clear that the strings `ALTER TABLE ONLY public.` might be replace by the string `ALTER TABLE `.

In the `constraint` part of the `uniy_db_backup` file, when we add  the **foreign key** constraints to the database tables.

```console
ALTER TABLE ONLY public.sections
    ADD CONSTRAINT sections_fkey_course FOREIGN KEY (course_id) REFERENCES public.courses(course_id) ON DELETE CASCADE;
...

ALTER TABLE ONLY public.sections
    ADD CONSTRAINT sections_fkey_teacher FOREIGN KEY (teacher_id) REFERENCES public.teachers(teacher_id) ON DELETE SET NULL;
```

It's clear that the strings `ALTER TABLE ONLY public.` might be replace by the string `ALTER TABLE `. And the string `REFERENCES public.` might be replaced by the string `REFERENCES `.

### Edit the file with the sed command

A useful command to replace string in a text file is the `sed` command. For more information about the `sed` command please follow the link [sed](https://www.theunixschool.com/2014/08/sed-examples-remove-delete-chars-from-line-file.html).

The syntax of sed command replacement is:

```console
$ sed 's/find/replace/g' file
```
This sed command finds the pattern and replaces with another pattern. When the replace is left empty, the pattern/element found gets deleted.

The `sed` command directs to the terminal output. If we want to modify the original file then we could type:

```console
$ sed 's/find/replace/g' file > tmpfile && mv tmpfile file
```

As we can see, we're omitting the `find` string and replacing with the string `replace` and saving into a temporary file `tmpfile`. Afterwards, we overwirite our original file, `file`, with the temporary file.

In the case we want to replace the string `public.`, the possible pattern might be:

```console
$ sed 's/initial_substring public./initial_sub_string /g' file > tmpfile && mv tmpfile file
```

As we can see, the command substitutes the final part of the string, replacing the `public.` substring with the space string ` `. The purpose of this replacement is to remove all the occurrences `public.table_name` with ` table_name`.

**Let's execute** the `sed` command to edit the `uniy_db_backup.sql` file.

```console
(base) ludo /pgbackup  $  ls
uniy_db_backup.sql
```

the current directory contains the `uniy_db_backup.sql` file.

1. `clean` part:

```console
(base) ludo /pgbackup  $  sed 's/ALTER TABLE IF EXISTS ONLY public./ALTER TABLE IF EXISTS /g' uniy_db_backup.sql > tmpfile.sql && mv tmpfile.sql uniy_db_backup.sql
```
For dropping the tables:

```console
(base) ludo /pgbackup  $  sed 's/DROP TABLE IF EXISTS public./DROP TABLE IF EXISTS /g' uniy_db_backup.sql > tmpfile.sql && mv tmpfile.sql uniy_db_backup.sql
```

2. `create` part:

```console
(base) ludo /pgbackup  $  sed 's/CREATE TABLE public./CREATE TABLE /g' uniy_db_backup.sql > tmpfile.sql && mv tmpfile.sql uniy_db_backup.sql
```

3. `data` part:

```console
(base) ludo /pgbackup  $  sed 's/INSERT INTO public./INSERT INTO /g' uniy_db_backup.sql > tmpfile.sql && mv tmpfile.sql uniy_db_backup.sql
```

4. `constraint` primary key and foreign key part:

```console
(base) ludo /pgbackup  $  sed 's/ALTER TABLE ONLY public./ALTER TABLE /g' uniy_db_backup.sql > tmpfile.sql && mv tmpfile.sql uniy_db_backup.sql
```
foreign key part

```console
(base) ludo /pgbackup  $  sed 's/REFERENCES public./REFERENCES /g' uniy_db_backup.sql > tmpfile.sql && mv tmpfile.sql uniy_db_backup.sql
```

### Last editing steps

To complete the editing we wnat to remove some words from the comments and include the `BEGIN;` and `COMMIT` commands. We want to wrap all the command in a TRANSACTION.

```console
(base) ludo /pgbackup  $  sed 's/Schema: public;//g' uniy_db_backup.sql > tmpfile.sql && mv tmpfile.sql uniy_db_backup.sql
```

Let's list all the lines containing the string ` public.` in the `uniy_db_backup` file.

```console
(base) ludo /pgbackup  $  grep -w " public." uniy_db_backup.sql
```

As we can see the string ` public.` doesn't appear in any line of the `uniy_db_backup` file.

One final touch, is the elimination of all the settings lines in the `uniy_db_backup.sql` file and the string `SELECT pg_catalog.set_config('search_path', '', false);`.

```console
(base) ludo /pgbackup  $  sed '8,17d' uniy_db_backup.sql > tmpfile && mv tmpfile uniy_db_backup.sql
```

Finally, let's add the command `BEGIN;` and `COMMIT`:

```console
(base) ludo /pgbackup  $  sed 's/-- Dumped from database version 11.4/BEGIN;/g' uniy_db_backup.sql > tmpfile.sql && mv tmpfile.sql uniy_db_backup.sql
(base) ludo /pgbackup  $  sed 's/-- PostgreSQL database dump complete/COMMIT;/g' uniy_db_backup.sql > tmpfile.sql && mv tmpfile.sql uniy_db_backup.sql
```

**THE BACKUP IS COMPLETED**

In the next section we recall all the steps from the beginning and output the `uniy_db_backup.sql` file.
