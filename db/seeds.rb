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
    'Automobile'
]

Category.destroy_all

industry_list.each do |name|
  Category.create( name: name )
end