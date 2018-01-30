class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :set_access_level
  before_action :set_tenant_id

  private def set_access_level
    ApplicationRecord.access_level = "tenant"
  end

  private def set_tenant_id
    ApplicationRecord.tenant = current_tenant
  end

  private def current_tenant
    @current_tenant ||= Tenant.all.sample
  end
  helper_method :current_tenant
end
