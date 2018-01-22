class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  class << self
    def access_level=(level)
      statement = "SET session.access_level = '#{level}'"
      self.connection.execute(statement)
    end

    def tenant=(tenant)
      statement = "SET session.tenant_id = '#{tenant&.id}'"
      self.connection.execute(statement)
    end
  end
end
