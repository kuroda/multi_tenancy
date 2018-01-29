class CreateArticles < ActiveRecord::Migration[5.1]
  include MigrationHelpers

  def up
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

  def down
    remove_policies("articles")

    drop_table :articles
  end
end
