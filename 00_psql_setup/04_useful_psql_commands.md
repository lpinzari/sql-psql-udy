# Useful psql Commands

You’ve installed PostgreSQL. Now what? I assume you’ve been given a task that uses psql and you want to learn the absolute minimum to get the job done.

This is both a brief tutorial and a quick reference for the absolute least you need to know about psql. I assume you’re familiar with the command line and have a rough idea about what database administration tasks, but aren’t familiar with how to use psql to do the basics.

The PostgreSQL [documentation](https://www.postgresql.org/docs/manuals/) is incredibly well written and thorough, but frankly, I didn’t know where to start reading. This is my answer to that problem.

Many administrative tasks can or should be done on your local machine, even though if database lives on the cloud. You can do some of them through a visual user interface, but that’s not covered here. Knowing how to perform these operations on the command line means you can script them, and scripting means you can automate tests, check errors, and do data entry on the command line.

This section isn’t a full cheat sheet for psql. It covers the most common operations and shows them roughly in sequence, as you’d use them in a typical work session.

[1. Starting and quitting the psql interactive terminal](#1-starting-and-quitting-the-pasql-interactive-terminal)
[1.1 Command-line prompts on the operating system](#11-command-line-prompts-on-the-operating-system)
[1.2 Using psql](#12-using-psql)
[1.3 Quitting psql](#13-quitting-psql)



## 1. Starting and quitting the psql interactive terminal

Before using this section, you’ll need:

- The user name and password for your PostgreSQL database
- The IP address of your remote instance

### 1.1 Command line prompts on the operating system

The `$` starting a command line in the examples below represents your operating system prompt. Prompts are configurable so it may well not look like this. On Windows it might look like `C:\Program Files\PostgreSQL>` but Windows prompts are also configurable.

```console
$ psql -U sampleuser -h localhost
```

By default the `-h` option value is `localhost`. If your connection is on your local computer you can omit the `-h` option.

A line starting with # represents a comment. Same for everything to the right of a #. If you accidentally type it or copy and paste it in, don’t worry. Nothing will happen.

```console
# This worked to connect to Postgres on DigitalOcean
# -U is the username (it will appear in the \l command)
# -h is the name of the machine where the server is running.
# -p is the port where the database listens to connections. Default is 5432.
# -d is the name of the database to connect to. I think DO generated this for me, or maybe PostgreSQL.
# Password when asked is csizllepewdypieiib
$ psql -U doadmin -h production-sfo-test1-do-user-4866002-0.db.ondigitalocean.com -p 25060 -d mydb

# Open a database in a remote location.
$ psql -U sampleuser -h production-sfo-test1-do-user-4866002-0.db.ondigitalocean.com -p 21334
```

### 1.2 Using psql

You’ll use psql (aka the [PostgreSQL interactive terminal](https://www.postgresql.org/docs/current/app-psql.html)) most of all because it’s used to create databases and tables, show information about tables, and even to enter information (records) into the database.

### 1.3 Quitting psql
Before we learn anything else, here’s how to quit psql and return to the operating system prompt. You type backslash, the letter q, and then you press the Enter or return key.

```console
# Press enter after typing \q
# Remember this is backslash, not forward slash
postgres=# \q
This takes you back out to the operating system prompt.
```
