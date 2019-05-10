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

require 'rainbow'


def get_status_alert
	data = Net::HTTP.get(URI.parse('http://web.mta.info/status/serviceStatus.txt'))
	Crack::XML.parse(data)["service"]["subway"]["line"]
end

def welcome
	puts
	# puts Rainbow("Welcome to the MTAlert App!").yellow
	puts Rainbow("\nWelcome to the MTAlert App!").yellow.bright
	puts Rainbow("Welcome to the MTAlert App!").yellow.bright
	puts Rainbow("Welcome to the MTAlert App!").yellow.bright
	# puts Rainbow("Welcome to the MTAlert App!").blue
	puts Rainbow("Welcome to the MTAlert App!").blue.bright
	puts Rainbow("Welcome to the MTAlert App!").blue.bright
	# puts Rainbow("Welcome to the MTAlert App!").yellow
	puts Rainbow("Welcome to the MTAlert App!").yellow.bright
	puts Rainbow("Welcome to the MTAlert App!").black.bright
	puts Rainbow("Welcome to the MTAlert App!").yellow.bright
	puts
end

def get_firstname_input
	puts Rainbow("What is your first name?").bright
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
		User.welcome_and_create_new_user(firstname_input)
	end
end

def verify_single_user(check)
	puts
	check
	response = gets.chomp.downcase
	if response == "n" || response == "no"
		User.welcome_and_create_new_user(check.first.first_name)
	elsif response == "y" || response == "yes"
		User.welcome_back(check[0])
		check[0]
	else
		puts
		puts Rainbow("Invalid input. Please try again.").red
		puts
		puts Rainbow("#{check.first.full_name}? (Y/N)").bright
		verify_single_user(check)
	end
end

def verfiy_multiple_users(check)
	puts
	puts Rainbow("Which number are you? (#)").bright
	puts
	puts Rainbow("Or if you don't see yourself, enter N").bright
	puts
	check
	user_input = gets.chomp.downcase
	if user_input == "n" || user_input == "no"
		User.welcome_and_create_new_user(check.first.first_name)
	elsif user_input.to_i.to_s == user_input
		User.welcome_back(check[user_input.to_i - 1])
		check[user_input.to_i - 1]
	else
		puts
		puts Rainbow("Invalid input. Please try again.").red
		puts
		check.each_with_index{ |user, index| puts "#{index + 1}. #{user.full_name}" }
		verfiy_multiple_users(check)
	end
end

def get_commute_input
	puts
	puts Rainbow("What train line are you taking after class?").bright
	puts
	commute_input = gets.chomp
	commute_input.upcase
end

def match_commute_input_to_line(commute_input, user_obj)
	match = get_status_alert.find do |line|
		line["name"].include?(commute_input)
	end
	if match.nil?
		puts
		puts Rainbow("Invalid input. Please try again.").red
		train = Train.find_by(line: commute_input)
        Commute.where(train: train).destroy_all
        Train.where(line: commute_input).destroy_all
		new_commute_input = get_commute_input
		match_commute_input_to_line(new_commute_input, user_obj)
		train_obj = Train.return_train_obj(new_commute_input)
		new_com = Commute.find_or_create_by(user: user_obj, train: train_obj)
		# binding.pry
		train_obj.reload
		user_obj.reload
		new_com.reload
		get_friend_interest(user_obj)
		user_obj.fellow_users_on_commute(train_obj)
		user_obj.view_profile?
	end
	status = match["status"]
	message = match["text"]
	if message.nil?
		puts
		puts Rainbow("#{status}").green.bright
	else
		puts
		puts Rainbow("#{status}").red.bright
		puts
		puts Nokogiri::HTML(message).text
	end
end

def get_friend_interest(user_obj)
	puts
	puts Rainbow("Would you like to know who else takes your train? (Y/N)").bright
	puts
	friend_input = gets.chomp.downcase
	if friend_input == "y" || friend_input == "yes"
		return
	elsif friend_input == "n" || friend_input == "no"
		puts
		puts Rainbow("Okay.").bright
		puts
		user_obj.view_profile?
	else
		puts
		puts Rainbow("Invalid error. Please try again.").red
		get_friend_interest(user_obj)
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
	match_commute_input_to_line(commute_input, user_obj)
	get_friend_interest(user_obj)
	user_obj.fellow_users_on_commute(train_obj)
	user_obj.view_profile?
end
