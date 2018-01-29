class StorageProperty < ApplicationRecord
  belongs_to :tenant

  after_save do
    tenant.update_column(
      :storage_size,
      self.class.where(tenant: tenant).sum(:size)
    )
  end
end
