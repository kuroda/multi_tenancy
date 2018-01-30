class CreateTenants < ActiveRecord::Migration[5.1]
  def change
    create_table :tenants do |t|
      t.string :name, null: false
      t.string :name_for_index, null: false
      t.integer :storage_size, null: false, default: 0

      t.timestamps
    end

    add_index :tenants, :name_for_index, unique: true
  end
end
