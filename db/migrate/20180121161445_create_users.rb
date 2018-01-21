class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.references :tenant, null: false
      t.string :name, null: false

      t.timestamps
    end

    add_foreign_key :users, :tenants
  end
end
