ApplicationRecord.access_level = "tenant"

tenant = Tenant.order(:id).first!

ApplicationRecord.tenant = tenant

user = tenant.users.first!

user.name = "xxxx"
user.save!

puts user.storage_size

tenant.reload

puts tenant.storage_size
