class GrantPrivileges < ActiveRecord::Migration[5.1]
  include MigrationHelpers

  def change
    execute(%Q{
      ALTER USER mt WITH PASSWORD mt;

      GRANT SELECT, INSERT, UPDATE, DELETE
        ON ALL TABLES IN SCHEMA public TO mt;
    })
  end
end