# cording: utf-8

cardid = Faker::Lorem.characters(number: 8)
User.create!(name: "zero",
             email: "sample@email.com",
             password: "password",
             password_confirmation: "password",
             employee_id: 0,
             card_id: cardid,
             admin: true,
             superior: true
             )

24.times do |n|
  name = Faker::Name.name
  email = "sample#{n+1}@email.com"
  password = "password"
  empid = n+1
  cardid = Faker::Lorem.characters(number: 8)
  User.create!(name: name,
               email: email,
               password: password,
               password_confirmation: password,
               employee_id: empid,
               card_id: cardid,
               superior: true
               )
end

24.times do |n|
  name = Faker::Name.name
  email = "sample#{n+26}@email.com"
  password = "password"
  empid = n+26
  cardid = Faker::Lorem.characters(number: 8)
  User.create!(name: name,
               email: email,
               password: password,
               password_confirmation: password,
               employee_id: empid,
               card_id: cardid
               )
end
