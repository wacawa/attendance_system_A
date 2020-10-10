# cording: utf-8

User.create!(name: "user0",
             email: "sample@email.com",
             password: "password",
             password_confirmation: "password",
             )

49.times do |n|
  name = "user#{n+1}"
  email = "sample#{n+1}@email.com"
  password = "password"
  User.create!(name: name,
               email: email,
               password: password,
               password_confirmation: password
               )
end
