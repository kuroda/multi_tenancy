class Tenant < ApplicationRecord
  has_many :storage_properties, dependent: :destroy
  has_many :users, dependent: :destroy
  has_many :articles

  before_validation do
    self.name_for_index = name&.downcase
  end

  validates :name_for_index, format: { with: %r(\A[a-z][a-z0-9]{2,}\z) }
end
