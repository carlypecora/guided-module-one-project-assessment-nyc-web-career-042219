#brew install and add to gem file and then bundle install
require 'protobuf'

#gem install (see link in slack) (also add to gem file with protobuf)
require 'google/transit/gtfs-realtime.pb'

#these you can just require in your file
require 'net/http'
require 'uri'
require 'json'
require 'pry'
require 'crack'
require 'crack/json'
require 'crack/xml'
require 'nokogiri'

require 'annotate'


def get_status_alert
	data = Net::HTTP.get(URI.parse('http://web.mta.info/status/serviceStatus.txt'))
	Crack::XML.parse(data)["service"]["subway"]["line"]
end

def welcome
	puts "Welcome to your MTA commute."
end

def get_firstname_input
	puts "What is your first name?"
	firstname_input = gets.chomp
	firstname_input.capitalize
end

def verify_user(firstname_input)
	check = User.find_all_by_first_name(firstname_input)
	if check.length == 1
		puts "Is this you? (Y/N)"
		check
		response = gets.chomp
		if response == "N" || response == "n" || response == "no" || response == "No"
			User.welcome_and_create_new_user
			#if response == y, it will just skip and go to the next one
		else
			check[0]
		end
	elsif check.length > 1
		# another method
		puts "Which number are you? (#)"
		check
		user_input = gets.chomp
		check[user_input.to_i - 1]
	else
		User.welcome_and_create_new_user
	end
end

def get_commute_input
	puts "What train line are you taking after class?"
	commute_input = gets.chomp
	commute_input.upcase
end


	


def match_commute_input_to_line(commute_input)
	match = get_status_alert.find do |line| 
		line["name"].include?(commute_input)
	end
	status = match["status"]
	message = match["text"]
	if message.nil?
		puts status
	else
		puts Nokogiri::HTML(message).text

	end
end	

def test
	welcome
	firstname_input = get_firstname_input
	user_obj = verify_user(firstname_input)
	commute_input = get_commute_input
	train_obj = Train.return_train_obj(commute_input)
	commute_obj = Commute.find_or_create_by(user: user_obj, train: train_obj)
	binding.pry
	match_commute_input_to_line(commute_input)
end



