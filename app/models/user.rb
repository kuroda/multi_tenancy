class User < ApplicationRecord
  include StorageCalculator

  belongs_to :tenant
  has_many :articles
end
