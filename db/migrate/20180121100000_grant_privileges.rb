class GrantPrivileges < ActiveRecord::Migration[5.1]
  include MigrationHelpers

  def change
    execute_query(%Q{
      ALTER USER mt WITH PASSWORD 'mt'
    })

    execute_query(%Q{
      GRANT CONNECT
      ON DATABASE mt_development
      TO mt
    })

    execute_query(%Q{
      GRANT SELECT, INSERT, UPDATE, DELETE
      ON ALL TABLES IN SCHEMA public
      TO mt
    })
  end
end
