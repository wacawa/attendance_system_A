# encoding: utf-8

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
  Faker::Config.locale = :ja
  name = Gimei.name.kanji
  email = "su#{n}@email.com"
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
               superior_name: "上長#{n}",
               )
end

50.times do |n|
  name = Gimei.name.kanji
  email = "sample#{n}@email.com"
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
