require 'rubygems'
require 'bundler/setup'
require 'dotenv'

require './tidsreg_service.rb'

Dotenv.load

service = TidsregService.new(ENV['TIDSREG_USERNAME'], ENV['TIDSREG_PASSWORD'])

# d = Date.today - (ENV['TIDSREG_WEEKS'].to_i * 7)
# now = Date.today

d = Date.strptime('01-05-2015', '%d-%m-%Y')
now = Date.strptime('01-05-2016', '%d-%m-%Y')

result = {}
while(d < now)
  result.merge!(service.hours(d, 7))
  d += 7
end

puts "date\t\tproject\tholly.\tIntern\t1st sd\tVac.\tSick"

total_project = 0
total_hollyday = 0
total_internal_time = 0
total_childs_first_sickday = 0
total_vacation = 0
total_sick = 0
total_total = 0

result.keys.sort.each{|date|
  d = result[date]

  project = d[:project]
  total_project += project

  hollyday = d[:hollyday]
  total_hollyday += hollyday

  internal_time = d[:internal_time]
  total_internal_time = internal_time

  childs_first_sickday = d[:childs_first_sickday]
  total_childs_first_sickday += childs_first_sickday

  vacation = d[:vacation]
  total_vacation += vacation

  sick = d[:sick]
  total_sick += sick

  total = project + hollyday + internal_time + childs_first_sickday + vacation + sick
  total_total += total

  puts sprintf("%s\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t|\t%.2f", date, project, hollyday, internal_time, childs_first_sickday, vacation, sick, total)
}

c = result.keys.count

puts "------------------------------------[ AVG ]--------------------------------------------------"
puts sprintf("\t\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t|\t%.2f", total_project/c, total_hollyday/c, total_internal_time/c, total_childs_first_sickday/c, total_vacation/c, total_sick/c, total_total/c)
puts "------------------------------------[TOTAL]--------------------------------------------------"
puts sprintf("\t\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t|\t%.2f", total_project, total_hollyday, total_internal_time, total_childs_first_sickday, total_vacation, total_sick, total_total)

