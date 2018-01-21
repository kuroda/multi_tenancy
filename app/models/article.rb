class Article < ApplicationRecord
  belongs_to :tenant
  belongs_to :user

  before_validation do
    self.tenant = user&.tenant
  end
end
