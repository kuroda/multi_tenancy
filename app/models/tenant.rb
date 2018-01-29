class Tenant < ApplicationRecord
  has_many :storage_properties, dependent: :destroy
  has_many :users, dependent: :destroy
  has_many :articles
end
