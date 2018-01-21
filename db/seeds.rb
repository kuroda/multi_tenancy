%w(alpha bravo charlie).each do |name|
  t = Tenant.create!(name: name)

  3.times do |n|
    User.create!(tenant: t, name: "#{name}-#{n}")
  end
end
