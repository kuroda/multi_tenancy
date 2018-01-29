class Article < ApplicationRecord
  include StorageCalculator

  belongs_to :tenant
  belongs_to :user

  before_validation do
    self.tenant = user&.tenant
  end
end
