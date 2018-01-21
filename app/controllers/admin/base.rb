class Admin::Base < ActionController::Base
  protect_from_forgery with: :exception

  before_action :set_access_level
  before_action :set_tenant_id

  private def set_access_level
    statement = "SET session.access_level = 'admin'"
    ActiveRecord::Base.connection.execute(statement)
  end

  private def set_tenant_id
    statement = "SET session.tenant_id = ''"
    ActiveRecord::Base.connection.execute(statement)
  end
end
