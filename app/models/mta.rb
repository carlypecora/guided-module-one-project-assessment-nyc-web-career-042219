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
	puts 
end

def get_firstname_input
	puts "What is your first name?"
	puts 
	firstname_input = gets.chomp
	firstname_input.capitalize
end

def verify_user(firstname_input)
	check = User.find_all_by_first_name(firstname_input)
	if check.length == 1
		verify_single_user(check)
	elsif check.length > 1
		verfiy_multiple_users(check)
	else
		User.welcome_and_create_new_user
	end
end

def verify_single_user(check)
	puts 
	check
	response = gets.chomp
	if response == "N" || response == "n" || response == "no" || response == "No"
		User.welcome_and_create_new_user
	else
		User.welcome_back(check[0])
		check[0]
	end
end

def verfiy_multiple_users(check)
	puts
	puts "Which number are you? (#)"
	puts 
	puts "Or if you don't see yourself, enter N"
	puts 
	check
	user_input = gets.chomp
	if user_input == "N"
		User.welcome_and_create_new_user
	else
		User.welcome_back(check[user_input.to_i - 1])
		check[user_input.to_i - 1]
	end
end

def get_commute_input
	puts
	puts "What train line are you taking after class?"
	puts 
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



 # do you want to let your friends know of the service status
	# #{other_user} also usually takes the #{train}

# do you want to save your neighborhood
	# do you want to see who else lives in your neighborhood

 # MAIN MENU
 # train info
	# do want to see what trains don't have good service
	# do you want to see what trains do have good service
# your commute info
	 # do you want to see your most common commute?
		 # list top commutes



def test
	welcome
	firstname_input = get_firstname_input
	user_obj = verify_user(firstname_input)
	commute_input = get_commute_input
	train_obj = Train.return_train_obj(commute_input)
	commute_obj = Commute.find_or_create_by(user: user_obj, train: train_obj)
	match_commute_input_to_line(commute_input)
	puts "Who else is on your train"
	user_obj.fellow_users_on_commute(train_obj)
end



