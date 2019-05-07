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
		# another method
	if check.length == 1
		puts "Is this you? (Y/N)"
		check
	elsif check.length > 1
		# another method
		puts "Which number are you? (#)"
		check
	else
		# reference user method create_new_user
		puts "Welcome new user, please enter your first and last name."
		fullname_input = gets.chomp
		User.create_new_user(fullname_input)
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
	verify_user(firstname_input)
	commute_input = get_commute_input	
	match_commute_input_to_line(commute_input)
end



