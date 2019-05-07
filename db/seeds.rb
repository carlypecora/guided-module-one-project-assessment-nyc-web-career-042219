require 'pry'
ActiveRecord::Base.logger = Logger.new(STDOUT)

jess = User.find_or_create_by(first_name: "Jessica", last_name: "Lin")
jess.update(neighborhood: "Flatbush")

carly = User.find_or_create_by(first_name: "Carly", last_name: "Pecora")
carly.update(neighborhood: "Williamsburg")

binding.pry