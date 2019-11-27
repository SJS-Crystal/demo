User.create(full_name: "Example User", phone: "0964991298", email: "user@soccer.vn",
  password: "admin123", password_confirmation: "admin123", role: 2, activated: true, activated_at: Time.zone.now)
User.create!({full_name: "Example User", email: "admin@soccer.vn",
 password: "admin123", password_confirmation: "admin123", phone: "0964991298", role: 0,
              activated: true, activated_at: Time.zone.now})
User.create!({full_name: "Owner User", email: "owner@soccer.vn",
 password: "admin123", password_confirmation: "admin123", phone: "0962991298", role: 1,
              activated: true, activated_at: Time.zone.now})

99.times do |n|
  name  = Faker::Name.name
  user_id = 1
  description = Faker::Lorem.sentence
  address = Faker::Address.street_address
  start_time = DateTime.strptime("05:30 +07:00", "%H:%M %z")
  end_time = DateTime.strptime("23:59 +07:00", "%H:%M %z")

  Pitch.create!(
    name: name,
    user_id: user_id,
    description: description,
    country: Faker::Address.country,
    address: address,
    phone: Faker::PhoneNumber.phone_number,
    city:Faker::Address.city,
    district: Faker::Address.state,
    start_time: start_time,
    end_time: end_time,
    limit: 2
  )
end

5.times do |n|
  name  = Faker::Name.name
  description = Faker::Name.name
  address = Faker::Address.street_address
  Pitch.create!({user_id: 2,
           name: name,
           description: description,
           country: "vn",
           city: "Da nang",
           phone: "5555555555",
           district: "Hai chau",
           address: address,
           limit: 2})
end
SubpitchType.create!({name:  "SubpitchType 1",
           description: "Day la mot ta 1"})

pitches = Pitch.order(created_at: :desc).take(3)
pitches.each{|pitch|
  5.times do |n|
    name = Faker::Name.name
    desc = Faker::Lorem.sentence
    price = 1000000
    size = "5 người"
    pitch.subpitches.create!({
      subpitch_type_id: 1,
      name: name,
      description: desc,
      price_per_hour: price,
      currency: "VND",
      size: size,
      status: Faker::Number.between(from: 0, to: 1)
    })
  end
}

subpitches = Subpitch.all
subpitches.each{|subpitch|

  5.times do |x|
    user_id= Faker::Number.between(from: 1, to: 30)
    start_time = Faker::Time.between(from: "06:00:00", to: "18:00:00")
    end_time = start_time + 1.hour
    message= Faker::Lorem.sentence
    status= Faker::Number.between(from: 0, to: 2)
    total_price= 30000

    subpitch.bookings.create!({
      user_id: user_id,
      start_time: start_time,
      end_time: end_time,
      message: message,
      status: status,
      total_price: total_price
    })
  end

}

50.times do |n|
  name = "Subpitch _ #{n}"
  Subpitch.create!({name: name, description: "mo ta 1",status: 0,pitch_id: 1,price_per_hour: 30000, currency: "Dong", size: "5 nguoi", subpitch_type_id: 1, created_at: Time.now, updated_at: Time.now})
end


10.times do |n|
  name = "Subpitch _ #{n}"
  Subpitch.create!({name: name, description: "mo ta 1",status: 0,pitch_id: 100,price_per_hour: 30000, currency: "Dong", size: "5 nguoi", subpitch_type_id: 1, created_at: Time.now, updated_at: Time.now})
end


50.times do |n|
  Booking.create!({user_id: 1, subpitch_id: 2, start_time: Time.now, end_time: Time.now, message: "hello moi nguoi", status: 0, total_price: 50000})
end

10.times do |n|
  Booking.create!({user_id: 2, subpitch_id: 51, start_time: Time.now, end_time: Time.now, message: "hello moi nguoi", status: 0, total_price: 50000})
end
