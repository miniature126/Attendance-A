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
             employee_number: 0001,
             uid: "j01",
             superior: true)

User.create!(name: "Superior2",
             email: "superior-2@email.com",
             password: "password",
             password_confirmation: "password",
             employee_number: 0002,
             uid: "j02",
             superior: true)

5.times do |n|
  name = "User#{n+1}"
  email = "sample-#{n+1}@email.com"
  employee_number = 0002 + (n + 1)
  uid = "s0#{n+1}"
  password = "password"
  User.create!(name: name,
               email: email,
               password: password,
               password_confirmation: password,
               employee_number: employee_number,
               uid: uid)
end