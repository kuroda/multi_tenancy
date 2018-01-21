module MigrationHelpers
  def execute_query(query)
    execute(query.gsub(/\s+/, ' ').strip)
  end

  def create_policy_on(table_name)
    username = ENV["DB_USERNAME"] || raise

    execute_query(%Q{
      CREATE POLICY admin_policy ON #{table_name}
        FOR ALL
        TO #{username}
        USING (current_setting('session.access_level') = 'admin')
    })

    execute_query(%Q{
      CREATE POLICY tenant_policy ON #{table_name}
        FOR ALL
        TO #{username}
        USING (
          current_setting('session.access_level') = 'tenant' AND
          current_setting('session.tenant_id') = #{table_name}.tenant_id::TEXT
        )
    })

    execute_query(%Q{
      ALTER TABLE #{table_name} ENABLE ROW LEVEL SECURITY
    })
  end

  def drop_policy_on(table_name)
    execute_query(%Q{
      DROP POLICY admin_policy ON #{table_name};
      DROP POLICY tenant_policy ON #{table_name};
    })
  end
end
