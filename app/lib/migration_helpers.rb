module MigrationHelpers
  def execute_query(query)
    execute(query.gsub(/\s+/, ' ').strip)
  end

  def valid_text_to_date(text)
    return false unless text =~ /\A\d{1,4}\-\d{1,2}\-\d{1,2}\Z/
    Date.parse(text)
  rescue ArgumentError
    false
  end

  def create_policy_on(table_name)
    execute_query(%Q{
      CREATE POLICY tenant_policy ON #{table_name}
        FOR ALL
        TO mt
        USING (#{table_name}.tenant_id::TEXT = current_setting('session.tenant_id'))
    })

    execute_query(%Q{
      ALTER TABLE users ENABLE ROW LEVEL SECURITY
    })
  end

  def drop_policy_on(table_name)
    execute_query(%Q{
      DROP POLICY tenant_policy ON #{table_name};
    })
  end
end
