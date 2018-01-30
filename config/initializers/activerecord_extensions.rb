module RowLevelSecurity
  def query(sql, name = nil)
    execute("SET session.access_level = '#{ApplicationRecord.access_level}'")
    execute("SET session.session.tenant_id = '#{ApplicationRecord.tenant&.id}'")
    super(sql, name)
  end

  def execute_and_clear(sql, name, binds, prepare: false, &proc)
    execute("SET session.access_level = '#{ApplicationRecord.access_level}'")
    execute("SET session.tenant_id = '#{ApplicationRecord.tenant&.id}'")
    super(sql, name, binds, prepare: prepare, &proc)
  end
end

class ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
  prepend RowLevelSecurity
end
