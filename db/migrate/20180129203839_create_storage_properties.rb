class CreateStorageProperties < ActiveRecord::Migration[5.1]
  include MigrationHelpers

  def change
    create_table :storage_properties do |t|
      t.references :tenant, null: false
      t.string :table_name, null: false
      t.integer :size, null: false, default: 0

      t.timestamps
    end

    add_index :storage_properties, [ :tenant_id, :table_name ], unique: true
    add_foreign_key :storage_properties, :tenants

    add_policies("storage_properties")
  end
end
