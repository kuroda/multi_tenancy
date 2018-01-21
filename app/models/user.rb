class User < ApplicationRecord
  belongs_to :tenant
  has_many :articles
end
