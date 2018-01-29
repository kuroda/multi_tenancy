ApplicationRecord.access_level = "admin"

%w(alpha bravo charlie).each do |name|
  t = Tenant.create!(name: name)
  ApplicationRecord.tenant = t

  3.times do |n|
    u = User.create!(tenant: t, name: "#{name}-#{n}")

    2.times do |m|
      body = "The quick brown fox jumps over the lazy dog."
      Article.create!(user: u, title: "#{name} #{n}-#{m}", body: body, pages: 10)
    end
  end
end
