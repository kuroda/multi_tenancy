class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :set_tenant_id

  private def set_tenant_id
    tenant = Tenant.all.sample
    ActiveRecord::Base.connection.execute("SET session.tenant_id = '#{tenant.id}'")
  end
end
