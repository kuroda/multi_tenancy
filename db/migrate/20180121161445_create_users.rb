class CreateUsers < ActiveRecord::Migration[5.1]
  include MigrationHelpers

  def up
    create_table :users do |t|
      t.references :tenant, null: false
      t.string :name, null: false

      t.timestamps
    end

    add_foreign_key :users, :tenants

    create_policies_on("users")
  end

  def down
    drop_policies_on("users")

    drop_table :users
  end
end
