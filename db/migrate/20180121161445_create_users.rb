class CreateUsers < ActiveRecord::Migration[5.1]
  include MigrationHelpers

  def up
    create_table :users do |t|
      t.references :tenant, null: false
      t.string :name, null: false

      t.timestamps
    end

    add_foreign_key :users, :tenants

    execute(%Q{
      CREATE POLICY tenant_users ON users
        FOR SELECT
        TO mt
        USING (users.tenant_id::TEXT = current_setting('session.tenant_id'));
      ALTER TABLE users ENABLE ROW LEVEL SECURITY;
    })
  end

  def down
    execute(%Q{
      DROP POLICY tenant_users ON users
    })

    drop_table :users
  end
end
