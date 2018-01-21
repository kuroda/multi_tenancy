class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :set_tenant_id

  private def set_tenant_id
    statement = "SET session.tenant_id = '#{current_tenant&.id}'"
    ActiveRecord::Base.connection.execute(statement)
  end

  private def current_tenant
    @current_tenant ||= Tenant.all.sample
  end
  helper_method :current_tenant
end
