ApplicationRecord.access_level = "tenant"

tenant1 = Tenant.order(:id).first
tenant2 = Tenant.order(:id).second

ApplicationRecord.tenant = tenant1

user1 = tenant1.users.first

puts user1.articles.count

ApplicationRecord.tenant = tenant2

user2 = tenant2.users.first
article = user2.articles.first

begin
  article.update_column(:user_id, user1.id)
rescue ActiveRecord::StatementInvalid => e
  puts e.to_s
end

puts user2.articles.count

ApplicationRecord.tenant = tenant1

puts user1.articles.count
