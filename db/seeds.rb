# coding: utf-8

User.create!(name: "Admin",
             email: "admin@email.com",
             password: "password",
             password_confirmation: "password",
             admin: true)

User.create!(name: "Superior1",
             email: "superior-1@email.com",
             password: "password",
             password_confirmation: "password",
             superior: true)

User.create!(name: "Superior2",
             email: "superior-2@email.com",
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