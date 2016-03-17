# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
#

industry_list =   [
    'Health and Beauty',
    'Technology',
    'Startups',
    'Internet',
    'Food',
    'Restaurants',
    'Automobile',
    'Entertainment',
    'Finance'
]

industry_list.each do |name|
  Category.find_or_create_by( name: name )
end

contact_us_list =   [
    'Payment',
    'General Support',
    'Feedback',
    'Complaint'
]

contact_us_list.each do |name|
  ContactUsCategory.find_or_create_by( name: name )
end

super_admin = User.where(email: 'superadmin@brandreach.com').first

unless super_admin
  User.create(email: 'superadmin@thebrandreach.com', password: 'admin', password_confirmation: 'admin',
              user_type: User.user_types[:super_admin], status: User.statuses[:active], verified: true)
end
