class CreateUsers < ActiveRecord::Migration[5.1]
  include MigrationHelpers

  def up
    create_table :users do |t|
      t.references :tenant, null: false
      t.string :name, null: false

      t.timestamps
    end

    add_foreign_key :users, :tenants

    add_policies("users")
  end

  def down
    remove_policies("users")

    drop_table :users
  end
end
