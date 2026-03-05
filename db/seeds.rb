Notification.delete_all
Review.delete_all
Attendance.delete_all
EventSponsor.delete_all
Ticket.delete_all
Event.delete_all
Sponsor.delete_all
Venue.delete_all
Category.delete_all
User.delete_all

# --- Users ---
u1 = User.create!(name: 'Иван', email: 'ivan@example.com')
u2 = User.create!(name: 'Иван2', email: 'ivan2@example.com')
u3 = User.create!(name: 'Иван3', email: 'ivan3@example.com')

# --- Categories ---
c1 = Category.create!(title: 'Music')
c2 = Category.create!(title: 'Tech')
c3 = Category.create!(title: 'Sport')

# --- Venues ---
v1 = Venue.create!(name: 'Олимпийский', city: 'Москва', address: 'Олимпийский проспект, 16', capacity: 35000)
v2 = Venue.create!(name: 'Ледовый дворец', city: 'Санкт-Петербург', address: 'проспект Пятилеток, 1', capacity: 12300)
v3 = Venue.create!(name: 'Event-Hall', city: 'Воронеж', address: 'ул. Ленина, 44', capacity: 500)
v4 = Venue.create!(name: 'Пустая площадка', city: 'Казань', address: 'ул. Баумана, 10', capacity: 1000)

# --- Sponsors ---
s1 = Sponsor.create!(name: 'Сбер', email: 'sponsor@sber.ru')
s2 = Sponsor.create!(name: 'Яндекс', email: 'sponsor@yandex.ru')
s3 = Sponsor.create!(name: 'VK', email: 'sponsor@vk.com')

# --- Events ---
e1 = Event.create!(
  title: 'Рок Фестиваль',
  location: 'Москва',
  from_date: 2.days.from_now,
  to_date: 2.days.from_now + 3.hours,
  owner: u1,
  category: c1,
  venue: v1
)

e2 = Event.create!(
  title: 'Tech Conference',
  location: 'Санкт-Петербург',
  from_date: 4.days.from_now,
  to_date: 4.days.from_now + 2.hours,
  owner: u2,
  category: c2,
  venue: v2
)

e3 = Event.create!(
  title: 'Марафон',
  location: 'Воронеж',
  from_date: 10.days.from_now,
  to_date: 10.days.from_now + 2.5.hours,
  owner: u1,
  category: c3,
  venue: v3
)

e4 = Event.create!(
  title: 'Джаз вечер',
  location: 'Москва',
  from_date: 3.days.from_now,
  to_date: 3.days.from_now + 2.hours,
  owner: u3,
  category: c1
)

e5 = Event.create!(
  title: 'Без категории',
  location: 'Воронеж',
  from_date: 15.days.from_now,
  to_date: 15.days.from_now + 4.hours,
  owner: u2,
  category: nil
)

# --- Tickets ---
Ticket.create!(event: e1, price: 1500, status: 'booked', user: u1)
Ticket.create!(event: e1, price: 1500, status: 'booked', user: u2)
Ticket.create!(event: e1, price: 1500, status: 'available', user: nil)

Ticket.create!(event: e2, price: 2500, status: 'booked', user: u1)
Ticket.create!(event: e2, price: 2500, status: 'available', user: nil)
Ticket.create!(event: e2, price: 3000, status: 'available', user: nil)

Ticket.create!(event: e3, price: 4000, status: 'booked', user: u2)
Ticket.create!(event: e3, price: 4500, status: 'cancelled', user: nil)
Ticket.create!(event: e3, price: 4000, status: 'available', user: nil)
Ticket.create!(event: e3, price: 5000, status: 'available', user: nil)

# --- Event Sponsors ---
EventSponsor.create!(event: e1, sponsor: s1, amount: 500_000)
EventSponsor.create!(event: e1, sponsor: s2, amount: 300_000)
EventSponsor.create!(event: e2, sponsor: s2, amount: 200_000)
EventSponsor.create!(event: e2, sponsor: s3, amount: 150_000)
EventSponsor.create!(event: e3, sponsor: s1, amount: 1_000_000)

# --- Attendances ---
Attendance.create!(user: u1, event: e1, checked_in_at: Time.current)
Attendance.create!(user: u2, event: e1, checked_in_at: Time.current)
Attendance.create!(user: u1, event: e2, checked_in_at: Time.current)
Attendance.create!(user: u3, event: e3, checked_in_at: nil)

Review.create!(user: u1, event: e1, review_text: 'Отличный фестиваль!', rating: 5, status: 'published')
Review.create!(user: u2, event: e1, review_text: 'Хорошо, но шумно', rating: 4, status: 'published')
Review.create!(user: u1, event: e2, review_text: 'Полезная конференция', rating: 5, status: 'pending')

Notification.create!(user: u1, message: 'билет подтверждён', notification_type: 'ticket_confirmed', read: true)
Notification.create!(user: u1, message: 'билет подтверждён', notification_type: 'ticket_confirmed', read: false)
Notification.create!(user: u2, message: 'новый отзыв', notification_type: 'new_review', read: false)
Notification.create!(user: u3, message: 'мероприятие отменено', notification_type: 'event_cancelled', read: false)

puts "Seeded: #{User.count} users, #{Category.count} categories, #{Venue.count} venues, " \
     "#{Sponsor.count} sponsors, #{Event.count} events, #{Ticket.count} tickets, " \
     "#{EventSponsor.count} event_sponsors, #{Attendance.count} attendances, " \
     "#{Review.count} reviews, #{Notification.count} notifications"
