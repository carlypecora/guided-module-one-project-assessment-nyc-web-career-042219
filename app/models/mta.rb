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

def get_status_alert
	data = Net::HTTP.get(URI.parse('http://web.mta.info/status/serviceStatus.txt'))
	Crack::XML.parse(data)["service"]["subway"]["line"]
end

def welcome
	puts "Welcome to your MTA commute."
	puts "What train line are you taking after class?"
end

def get_commute_input
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
		status
	else
		puts Nokogiri::HTML(message).text
		status
end
end	

def test
	welcome
	commute_input = get_commute_input	
	match_commute_input_to_line(commute_input)
end



