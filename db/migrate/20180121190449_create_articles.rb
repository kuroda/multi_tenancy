class CreateArticles < ActiveRecord::Migration[5.1]
  include MigrationHelpers

  def up
    create_table :articles do |t|
      t.references :tenant, null: false
      t.references :user, null: false
      t.string :title, null: false
      t.text :body

      t.timestamps
    end

    add_foreign_key :articles, :tenants
    add_foreign_key :articles, :users

    create_policy_on("articles")
  end

  def down
    drop_policy_on("articles")

    drop_table :articles
  end
end
