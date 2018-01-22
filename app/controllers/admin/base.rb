class Admin::Base < ActionController::Base
  protect_from_forgery with: :exception

  before_action :set_access_level
  before_action :set_tenant_id

  private def set_access_level
    ApplicationRecord.access_level = "admin"
  end

  private def set_tenant_id
    ApplicationRecord.tenant = nil
  end
end
