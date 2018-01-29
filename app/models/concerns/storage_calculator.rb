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
        when "character varying", "text"
          total += self[column.name].size
        else
          raise "Unsupported column type: #{column.sql_type}"
        end
      end

      self.storage_size = total
    end

    after_save :update_storage_property
    after_destroy :update_storage_property

    private def update_storage_property
      prop = StorageProperty.find_or_initialize_by(
        tenant: self.tenant,
        table_name: self.class.table_name
      )

      prop.size = self.class.where(tenant: tenant).sum(:storage_size)
      prop.save!
    end
  end
end
