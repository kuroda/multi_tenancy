# multi_tenancy

This is a tentative English translation from the original [README](README.ja.md) written in Japanese.

## Overview

This is a sample of multi-tenant Rails application using PostgreSQL's Row Level Security (RLS).

In this application, each tenant has multiple users and each user has multiple articles.

If you log in to this application as a user of a certain tenant, users and articles of another tenant can not be referenced.
In addition, the user can refer to another user's articles of the same tenant, but can not insert, update, or delete them.

Leaving such access restrictions to the application side makes it easier for bugs that introduce information leakage and losses to get mixed in.
However, if you restrict on the database side, that kind of bug will not occur.

Developers often uses an extension called [Citus] (https://www.citusdata.com/product/community) to build a multi-tenant system based on PostgreSQL, but we do not use it in this sample. The main purpose of Citus is to improve the "scalability" of the system. Citus distributes the huge database to multiple PostgreSQL instances using the technique "sharding".

There are various advantages to Citus's adoption, but application developers should understand the mechanism of "sharding" well in order not to cause unexpected errors and performance degradation.

If you know that the size of the Web application you are trying to create is not huge enough to use sharding, you can build a multi-tenant system using only PostgreSQL's standard functionalities as we did in this sample.

## Environment

* Ubuntu Server 16.04
* PostgreSQL 10
* Ruby 2.4
* Ruby on Rails 5.1.4

## Migration helper method `add_policies`

### Migration script for the table `users`

```
  def up
    create_table :users do |t|
      t.references :tenant, null: false
      t.string :name, null: false

      t.timestamps
    end

    add_foreign_key :users, :tenants

    add_policies("users")
  end
```

### Migration script for the table `articles`

```
    create_table :articles do |t|
      t.references :tenant, null: false
      t.references :user, null: false
      t.string :title, null: false
      t.text :body
      t.integer :pages, null: false, default: 0

      t.timestamps
    end

    add_foreign_key :articles, :tenants
    add_foreign_key :articles, :users

    add_policies(
      "articles",
      [
        { table_name: "users", foreign_key: "user_id" }
      ]
    )
  end
```

## About Row Level Security

Row Level Security (hereinafter referred to as "RLS") was introduced in PostgreSQL 9.5 released in January 2016.

In the conventional `GRANT` statement, only access control on a table basis was possible, but access control on a row basis is possible by using RLS.

RLS is set by defining a security policy with the `CREATE POLICY` statement. The following example allows the user `alice` to refer to a part of the `articles` table.

```
CREATE POLICY alice_policy ON articles
  FOR SELECT
  TO alice
  USING (user_id = (SELECT id FROM users WHERE name = 'alice'))
```

Conditions for which reference to rows is permitted are described in the `USING` clause. In the above example, we allow references to rows of the `articles` table whose `user_id` matches the ID of the user `alice`.

Note that RLS is disabled in the initial state. It must be enabled on a per-table basis using the `ALTER TABLE` statement.

```
ALTER TABLE articles ENABLE ROW LEVEL SECURITY
```

Suppose that we have these records in the table `users`.

```
id | name
---+-----
1  | alice
2  | bob
3  | charlie
```

And suppose that we have these records in the table `articles`.

```
id | user_id | title
---+---------|------
1  | 1       | W
2  | 1       | X
3  | 2       | Y
4  | 3       | Z
```

Suppose that the user `alice` issues the following query in the above state.

```
SELECT title FROM articles
```

Then, if RLS is disabled, 4 rows will be retrieved, but if RLS is enabled, only 2 are retrieved.

## `current_setting` function

In this Rails application, we use PostgreSQL `current_setting` function to improve security in multi-tenant system.

PostgreSQL allows you to set values for custom variables using the `SET` statement. In the following example, the variable `foo.bar` is set to the string `'X'`. A custom variable name must include a dot.

```
SET foo.bar = 'X'
```

We can get the values of custom variables using `current_setting` function.

```
current_setting('foo.bar')
```

This function can also be used in the `USING` clause of the` CREATE POLICY` statement. See the example below.

```
CREATE POLICY tenant_policy ON articles
  FOR SELECT
  TO CURRENT_USER
  USING (tenant_id::text = current_setting('session.current_tenant_id'))
```

Here we assume that there is an integer type column called `tenant_id` in the` articles` table.

Suppose that a user issues the following query in the above state.

```
SET session.current_tenant_id = '1';
SELECT title FROM articles;
```

Then, for this user, only lines with `tenant_id` value of 1 will be visible.

## `WITH CHECK` clause

If you add the `WITH CHECK` clause to the` CREATE POLICY` statement, it will be checked whether the record satisfies certain conditions when inserting or updating the line. If an `INSERT` statement or `UPDATE` statement that does not satisfy the condition is issued, an error occurs.

See the example below.

```
CREATE POLICY tenant_policy ON articles
  FOR SELECT, INSERT, UPDATE, DELETE
  TO CURRENT_USER
  USING (tenant_id::text = current_setting('session.current_tenant_id'))
  WITH CHECK (
    SELECT EXISTS (
      SELECT id FROM users
      WHERE id = articles.user_id
      AND tenant_id::text = current_setting('session.current_tenant_id')
    )
  )
```

When the security policy is set as described above, the presence or absence of a row satisfying the following two conditions is checked in the `users` table when inserting / updating a row in the `articles` table, otherwise an error occurs.

* The value of the `id` column is equal to *k*.
* Converting the value of the `tenant_id` column to a string, it is equal to the value of the custom variable `session.current_tenant_id`.

The *k* is the value of the `user_id` column of the row to be inserted or updated in the` articles` table.

## Notes on using RLS

For roles with `SUPERUSER` and `BYPASSRLS` attributes, RLS is always disabled. Also, for table owners, RLS is disabled by default, but you can enable it using the `ALTER TABLE` statement as follows.

```
ALTER TABLE articles FORCE ROW LEVEL SECURITY
```
