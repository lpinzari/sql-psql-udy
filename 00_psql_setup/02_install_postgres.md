# Install PostgreSQL database

Before we can create a Postgres database, we need to install the Postgres software.

- `http://postgresql.org/download`

To do this, we can go to the Postgres website and select the appropriate installer for our machine. **You'll install everything except for PG admin 4**. You can install this if you'd like, but we won't be using it in this course.

# Installing with Homebrew

```console
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```

Now, if you're on Mac, you can also install Postgres with Homebrew and that's what I'll be doing. If you don't have Homebrew you can install it with this command. **Homebrew is like a package manager for Mac**. With Homebrew we will be able to install Postgres. All right, Homebrew is installed.

```console
$ clear
$ brew install postgresql
```

Let's clear this up and install Postgres. We'll do that with brew install, Postgres.

```console
$ pg_ctl -D /usr/local/var/postgres
$ rm -r /usr/local/var/postgres
```

Now it's time to initialize our database. We'll do that with "initdb" and then the location of Postgres. In this case, user slash local slash var slash Postgres. And we'll put in the dash D option because this is a location. Now you may get an error here and that's because we need to remove what's currently in that directory. So, I'm going to do user, local, var, Postgres.

```console
$ pg_ctl -D /usr/local/var/postgres
```

Clear this up, do "initdb" again with that location, user, local, var, Postgres. And it's initializing.

```console
$ pg_ctl -D /usr/local/var/postgres start
```

From here, we can start up the Postgres server. We'll write "pg_ctl" dash D, the location of Postgres and then we'll say start. Awesome! Our server has started. **Let's clear this up and activate the Post sequel shell**.

```console
$ postgres -V
postgres (PostgreSQL) 11.4
```

Finally, let’s make sure Postgres is installed and running. Let’s check what version is running.
