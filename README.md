# multi_tenancy

## 概要

PostgreSQL の Row Level Security (RLS) を利用したマルチテナント Rails アプリケーションのサンプルです。

このアプリケーションでは、各テナントが複数のユーザーを抱え、それぞれのユーザーが複数の記事（articles）を持っています。

あるテナントのユーザーとしてこのアプリケーションにログインした場合、別のテナントのユーザーや記事は参照できません。
また、そのユーザーは同じテナントの別のユーザーの記事を参照できますが、挿入・更新・削除はできません。

このようなアクセス制限をアプリケーション側に委ねると、情報漏えいや情報喪失を招くバグが混入しやすくなります。
しかし、データベース側で制限をすれば、その種のバグが起こりえなくなります。

なお、PostgreSQL ではマルチテナントシステムの構築に [Citus](https://www.citusdata.com/product/community) という拡張機能がしばしば使われますが、このサンプルでは使用していません。Citus の主目的はシステムの「スケーラビリティ」の向上です。Citus は「シャーディング」という技法により巨大なデータベースを複数の PostgreSQL インスタンスに分散させます。

Citusの採用にはさまざまな利点がありますが、アプリケーションの開発者は「シャーディング」の仕組みをよく理解してプログラミングをしないと、思わぬエラーやパフォーマンスの低下を引き起こします。

作ろうとしている Web アプリケーションの規模がシャーディングを利用するほどに巨大にならないことがわかっているならば、このサンプルのように PostgreSQL の標準機能だけを用いてマルチテナントシステムを構築できます。

## 動作環境

* Ubuntu Server 16.04
* PostgreSQL 10
* Ruby 2.4
* Ruby on Rails 5.1.4

## マイグレーションヘルパーメソッド `create_policies_on`

### `users` テーブルのマイグレーションスクリプト

```
  def up
    create_table :users do |t|
      t.references :tenant, null: false
      t.string :name, null: false

      t.timestamps
    end

    add_foreign_key :users, :tenants

    create_policies_on("users")
  end
```

### `articles` テーブルのマイグレーションスクリプト

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

    create_policies_on(
      "articles",
      [
        { table_name: "users", foreign_key: "user_id" }
      ]
    )
  end
```

## Row Level Security について

Row Level Security （以下、「RLS」と呼ぶ）は、2016 年 1 月にリリースされた PostgreSQL 9.5 で導入された機能です。
日本語では「行単位セキュリティ」と訳されることもあります。

従来の `GRANT` 文ではテーブル単位でのアクセス制御しかできませんでしたが、RLS を利用すれば行単位でのアクセス制御が可能となります。

`CREATE POLICY` 文によってセキュリティポリシーを定義することにより RLS が設定されます。次の例では `alice` ユーザーに対して `articles` テーブルの一部に対する参照を許可しています。

```
CREATE POLICY alice_policy ON articles
  FOR SELECT
  TO alice
  USING (user_id = (SELECT id FROM users WHERE name = 'alice'))
```

行への参照が許可される条件は `USING` 節の中に記述されます。上の例では、副問い合わせを用いて `users` テーブルから `name` 列の値が `'alice'` である行の `id` 列の値を取得し、それと `user_id` 列の値が一致する `articles` テーブルの行への参照を許しています。

ただし、初期状態では RLS は無効になっています。`ALTER TABLE` 文を用いてテーブル単位で有効にする必要があります。

```
ALTER TABLE articles ENABLE ROW LEVEL SECURITY
```

いま `users` テーブルに次のような行が保存されているとします。

```
id | name
---+-----
1  | alice
2  | bob
3  | charlie
```

そして、 `articles` テーブルに次のような行が保存されているとします。

```
id | user_id | title
---+---------|------
1  | 1       | W
2  | 1       | X
3  | 2       | Y
4  | 3       | Z
```

以上のような状態で、`alice` ユーザーが次のようなクエリを発行したとします。

```
SELECT title FROM articles
```

すると、RLS が無効であれば 4 個の行が検索されることになりますが、RLS が有効となっていれば 2 個しか検索されません。

## `current_setting` 関数

この Rails アプリケーションでは、マルチテナントシステムにおけるセキュリティを高めるために PostgreSQL の `current_setting` 関数を利用しています。

PostgreSQL では `SET` 文を用いてカスタム変数に値をセットできます。次の例では、変数 `foo.bar` に `'X'` という文字列をセットしています。カスタム変数名には必ずドットを含む必要があります。

```
SET foo.bar = 'X'
```

カスタム変数の値は `current_setting` 関数を用いて取得できます。

```
current_setting('foo.bar')
```

この関数は `CREATE POLICY` 文の `USING` 節の中でも使えます。次の例をご覧ください。

```
CREATE POLICY tenant_policy ON articles
  FOR SELECT
  TO CURRENT_USER
  USING (tenant_id::text = current_setting('session.current_tenant_id'))
```

ここでは `articles` テーブルに `tenant_id` という整数型の列があると仮定しています。

以上のような状態で、あるユーザーが次のようなクエリを発行したとします。

```
SET session.current_tenant_id = '1';
SELECT title FROM articles;
```

すると、このユーザーには `tenant_id` の値が 1 である行だけが見えることになります。

## `WITH CHECK` 節

`CREATE POLICY` 文に `WITH CHECK` 節を加えると、行の挿入・更新時にレコードがある条件を満たすかどうかが確認されます。条件を満たさない `INSERT` 文や `UPDATE` 文が発行されると、エラーとなります。

次の例をご覧ください。

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

上記のようにセキュリティポリシーが設定されると、`articles` テーブルに対する行の挿入・更新時に `users` テーブルで次のふたつの条件を満たす行の有無が調べられ、なければエラーとなります。

* `id` 列の値と *k* が等しい。
* `tenant_id` 列の値を文字列に変換すると、カスタム変数 `session.current_tenant_id` の値に等しくなる。

ただし、*k* は `articles` テーブルに挿入・更新される行の `user_id` 列の値とします。

## RLS の利用上の注意

`SUPERUSER` および `BYPASSRLS` 属性を持つロールに対して RLS は常に無効です。また、テーブルのオーナーに対して、RLS はデフォルトで無効ですが、次のように `ALTER TABLE` 文を用いて有効化できます。

```
ALTER TABLE articles FORCE ROW LEVEL SECURITY
```
