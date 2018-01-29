module StorageCalculator
  extend ActiveSupport::Concern

  included do
    before_save :set_storage_size

    private def set_storage_size
      total = 0
      self.class.columns.each do |column|
        case column.sql_type
        when "bigint"
          total += 8
        when "integer"
          total += 4
        when "timestamp without time zone"
          total += 8
        when "character varying"
          total += self[column.name].size
        else
        end
      end

      self.storage_size = total
    end
  end
end
