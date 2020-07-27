# coding: utf-8

User.create!(name: "Admin",
             email: "sample@email.com",
             password: "password",
             password_confirmation: "password",
             admin: true)

User.create!(name: "Superior1",
             email: "sample-a@email.com",
             password: "password",
             password_confirmation: "password",
             superior: true)

User.create!(name: "Superior2",
             email: "sample-b@email.com",
             password: "password",
             password_confirmation: "password",
             superior: true)

5.times do |n|
  name = "User#{n+1}"
  email = "sample-#{n+1}@email.com"
  password = "password"
  User.create!(name: name,
               email: email,
               password: password,
               password_confirmation: password)
end