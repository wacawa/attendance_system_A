# cording: utf-8

cardid = Faker::Lorem.characters(number: 8)
User.create!(name: "管理者",
             email: "sample@email.com",
             password: "password",
             password_confirmation: "password",
             employee_id: 0,
             card_id: cardid,
             admin: true,
             )

3.times do |n|
  name = Faker::Name.name
  email = "su#{n+1}@email.com"
  password = "password"
  empid = n+1
  cardid = Faker::Lorem.characters(number: 8)
  User.create!(name: name,
               email: email,
               password: password,
               password_confirmation: password,
               employee_id: empid,
               card_id: cardid,
               superior: true,
               superior_name: "上長#{n+1}",
               )
end

2.times do |n|
  name = Faker::Name.name
  email = "sample#{n+1}@email.com"
  password = "password"
  empid = n+4
  cardid = Faker::Lorem.characters(number: 8)
  User.create!(name: name,
               email: email,
               password: password,
               password_confirmation: password,
               employee_id: empid,
               card_id: cardid
               )
end
