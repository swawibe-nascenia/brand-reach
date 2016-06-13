# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

# global environment set
# set :environment, 'staging'
#
# every :day, :at => '12:00 am' do
#    runner 'Campaign.fetch_all_insights', :environment => 'staging'
#    runner 'FacebookAccount.fetch_all_insights', :environment => 'staging'
# end
#
# every 5.minutes do
#   runner 'Campaign.stop_expire_campaigns', :environment => 'staging'
# end


set :environment, 'production'

every :day, :at => '12:00 am' do
  runner 'Campaign.fetch_all_insights', :environment => 'production'
  runner 'FacebookAccount.fetch_all_insights', :environment => 'production'
end

every 30.minutes do
  runner 'Campaign.stop_expire_campaigns', :environment => 'production'
end