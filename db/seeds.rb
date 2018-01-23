ApplicationRecord.access_level = "admin"
ApplicationRecord.tenant = nil

%w(alpha bravo charlie).each do |name|
  t = Tenant.create!(name: name)

  3.times do |n|
    u = User.create!(tenant: t, name: "#{name}-#{n}")

    2.times do |m|
      Article.create!(user: u, title: "#{name} #{n}-#{m}", body: "", pages: 10)
    end
  end
end
