ApplicationRecord.access_level = "tenant"

tenant = Tenant.order(:id).first!

puts tenant.storage_size

tenant.storage_properties.each do |prop|
  p [ prop.table_name, prop.size ]
end

ApplicationRecord.tenant = tenant

tenant.users.each do |u|
  p [ u.id, u.storage_size ]
end

user1 = tenant.users.first!
user2 = tenant.users.second!

user1.name = "foobar"
user1.save!

puts user1.storage_size

tenant.reload
puts tenant.storage_size

user3 = tenant.users.create!(name: "dummy")

tenant.reload

tenant.storage_properties.each do |prop|
  p [ prop.table_name, prop.size ]
end

puts tenant.storage_size

user3.destroy

tenant.reload

tenant.storage_properties.each do |prop|
  p [ prop.table_name, prop.size ]
end

puts tenant.storage_size
