# cording: utf-8

User.create!(name: "zero",
             email: "sample@email.com",
             password: "password",
             password_confirmation: "password",
             admin: true,
             superior: true
             )

24.times do |n|
  name = Faker::Name.name
  email = "sample#{n+1}@email.com"
  password = "password"
  User.create!(name: name,
               email: email,
               password: password,
               password_confirmation: password,
               superior: true
               )
end

24.times do |n|
  name = Faker::Name.name
  email = "sample#{n+26}@email.com"
  password = "password"
  User.create!(name: name,
               email: email,
               password: password,
               password_confirmation: password
               )
end
