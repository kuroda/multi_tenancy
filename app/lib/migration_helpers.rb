module MigrationHelpers
  using StringExtension

  def execute_query(query)
    execute(query.squash)
  end

  def create_policies_on(table_name, references = [])
    check_expressions = references.map do |ref|
      %Q{
        (SELECT EXISTS (
          SELECT true FROM #{ref[:table_name]}
          WHERE #{ref[:table_name]}.id = #{table_name}.#{ref[:foreign_key]}
          AND #{ref[:table_name]}.tenant_id::text = current_setting('session.tenant_id')
        ))
      }
    end

    admin_policy_statement = %Q{
      CREATE POLICY admin_policy ON #{table_name}
        FOR ALL
        TO CURRENT_USER
        USING (current_setting('session.access_level') = 'admin')
    }

    if check_expressions.present?
      admin_policy_statement += "WITH CHECK ("
      admin_policy_statement += check_expressions.join(" AND ")
      admin_policy_statement += ")"
    end

    execute_query(admin_policy_statement)

    tenant_policy_statement = %Q{
      CREATE POLICY tenant_policy ON #{table_name}
        FOR ALL
        TO CURRENT_USER
        USING (
          current_setting('session.access_level') = 'tenant' AND
          current_setting('session.tenant_id') = #{table_name}.tenant_id::text
        )
    }

    if check_expressions.present?
      tenant_policy_statement += "WITH CHECK ("
      tenant_policy_statement += check_expressions.join(" AND ")
      tenant_policy_statement += ")"
    end

    execute_query(tenant_policy_statement)

    execute_query(%Q{
      ALTER TABLE #{table_name} ENABLE ROW LEVEL SECURITY
    })

    execute_query(%Q{
      ALTER TABLE #{table_name} FORCE ROW LEVEL SECURITY
    })
  end

  def drop_policies_on(table_name)
    execute_query(%Q{
      DROP POLICY admin_policy ON #{table_name};
      DROP POLICY tenant_policy ON #{table_name};
    })
  end
end
