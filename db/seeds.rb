# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
#
#  use this for creating pubnub channel name for existing user
User.all.each {|u| p u.send(:generate_channel_name)  }

industry_list =   [
    'Health and Beauty',
    'Technology',
    'Startups',
    'Internet',
    'Food',
    'Restaurants',
    'Automobile'
]

industry_list.each do |name|
  Category.create( name: name )
end