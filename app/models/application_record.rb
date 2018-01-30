class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  class << self
    attr_accessor :access_level
    attr_accessor :tenant
  end
end
