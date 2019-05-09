
require 'pry'

class User < ActiveRecord::Base
    has_many :commutes
    has_many :trains, through: :commutes

    def full_name
        "#{self.first_name} #{self.last_name}"
    end

    def self.find_all_by_first_name(name)
        users = self.where(first_name: name)
        str = ""
        counter = 1
        users.each do |user| 
            str += "#{counter}. #{user.full_name}\n"
            counter += 1
        end
        if counter == 2
            puts
            puts "#{users[0].full_name}? (Y/N)"
        else
            puts
            puts str
        end
        users
    end

    def self.create_new_user(fullname_input)
        first_name = fullname_input.split[0].capitalize
        last_name = fullname_input.split[1].capitalize
        user = User.create(first_name: first_name, last_name: last_name)
        user.save
        user
    end

    def self.welcome_and_create_new_user(first_name)
        puts "Welcome #{first_name}, please enter your last name."
        puts
        lastname_input = gets.chomp.capitalize
        user = User.create(first_name: first_name, last_name: lastname_input)
        user.save
        user
    end

    def self.verify_train_selection(user_obj, trains_string, response, trains)
        if !trains_string.include?(response)
            puts
            puts "Invalid input. Please try again."
            train = Train.find_by(line: response)
            binding.pry
            Commute.destroy_all(train: train)
            self.reload
            get_train_selection(trains_string)
            selecting_saved_commute(user_obj, trains)
        else
            selecting_saved_commute(user_obj, trains)
        end
    end

    def self.selecting_saved_commute(user_obj, trains)
        match_commute_input_to_line(trains[0])
        get_friend_interest(user_obj)
        user_obj.fellow_users_on_commute(Train.find_by(line: trains[0]))
        user_obj.view_profile?
        # exit
    end

    def self.get_train_selection(trains_string)
        puts
        puts "The #{trains_string}?"
        puts
        response = gets.chomp.upcase
    end

    def self.welcome_back(user_obj)
        if user_obj.commutes.length > 0
            trains = user_obj.commutes.map { |commute| commute.train.line }
            trains_string = trains.join(" or ")
            puts
            puts "Welcome back, #{user_obj.first_name}! Will you be taking the #{trains_string}? (Y/N)"
            puts
            response = gets.chomp.downcase
            if response == "n" || response == "no"
                return
            elsif trains.length == 1 && response == "y" || response == "yes"
                selecting_saved_commute(user_obj, trains)
            elsif trains.length > 1 && response == "y" || response == "yes"
                response = get_train_selection(trains_string)
                verify_train_selection(user_obj, trains_string, response, trains)
            else
                puts
                puts "Invalid input. Please try again."
                self.welcome_back(user_obj)
            end
        end
    end

    def fellow_users_on_commute(train_obj)
        array = Commute.all.select do |commute|
            commute.train == train_obj && commute.user != self
        end
        if array.length > 0
            string = array.map { |commute| commute.user.full_name }.join(", ")
            puts
            puts string
            puts
            return
            # exit
        else
            puts
            puts "No one else is taking this train."
            puts
            view_profile?
            # puts "Thanks for using MTA commute! Stand clear of the closing doors please."
            # exit
        end
    end

    def view_profile?
         puts "Would you like to view your user profile? (Y/N)"
         puts
         profile_input = gets.chomp.downcase
         profile_selection(profile_input)
         view_profile?
         exit
    end

    def profile_options
        options_arr = [
            "View your info.",
            "Update user name.",
            "Update your commmute trains.",
            # "Delete one of your commute trains.", "Add a commute train."
            "View friends on a commute."
        ]
        options_arr.each_with_index { |option, index| puts "#{index + 1}. #{option}"}
        options_arr
    end

    def update_first_name
        puts "Would you like to update your first name? (Y/N)"
        input = gets.chomp.downcase
        if input == "y" || input == "yes"
            puts "Please enter your new first name."
            new_first_name = gets.chomp.capitalize
            self.update(first_name: "#{new_first_name}" )
        elsif input =="n" || input == "no"
            return
        else 
            puts "Invalid input. Please try again."
            update_first_name
        end  
    end

    def update_last_name
        puts "Would you like to update your last name? (Y/N)"
        input = gets.chomp.downcase
        if input == "y" || input == "yes"
            puts "Please enter your new last name."
            new_last_name = gets.chomp.capitalize
            self.update(last_name: "#{new_last_name}" )
        elsif input =="n" || input == "no"
            return
        else 
            puts "Invalid input. Please try again."
            update_last_name
        end
    end

    def delete_commute_train
        puts "Would you like to delete a train commute? (Y/N)"
        puts
        input = gets.chomp.downcase
        if input == "y" || input == "yes"
            puts 
            puts "Which commute would you like to delete? (#)"
            counter = 1
            self.commutes.each do |commute|
                puts "#{counter}. #{commute.train.line}"
                counter += 1
            end
            commute_number = gets.chomp
            self.commutes[commute_number.to_i - 1].destroy
            self.reload
            return
        elsif input == "n" || input == "no"
            return
        else
            puts "Invalid input. Please try again."
            delete_commute_train
        end
    end

    def add_commute_train
        puts "Would you like to add a train commmute? (Y/N)"
        second_input = gets.chomp.downcase
        if second_input == "y" || second_input == "yes"
            puts
            puts "Which train would you like to add to your commute?"
            puts
            train_input = gets.chomp.upcase
            match = get_status_alert.find do |line| 
                line["name"].include?(train_input)
            end
            if !match.nil?
                train_obj = Train.find_or_create_by(line: train_input)
                Commute.find_or_create_by(user: self, train: train_obj)
                self.reload
            elsif match.nil?
                puts"Invalid input. Please try again."
                add_commute_train
            end
        elsif second_input == "n" || second_input == "no"
            return
        else
            puts "Invalid input. Please try again."
            puts
            add_commute_train
        end
    end


    def profile_function(option_number, options_arr)
        if option_number == "1"
            puts
            puts "Your full name:"
            puts "#{self.full_name}"
            puts
            puts "Here are the trains you've taken:"
            self.trains.each { |train| puts "#{train.line}"}
            puts
            return
        elsif option_number == "2"
            update_first_name
            update_last_name
        elsif option_number == "3"
            delete_commute_train
            add_commute_train           
        elsif option_number == "4"
            puts
            self.commutes.each do |commute|
                puts "These are your friends that take the #{commute.train.line}:"
                puts
                if commute.train.users.length == 1
                    puts "No one else takes the #{commute.train.line}."
                    puts
                else 
                    commute.train.users.each do |user| 
                    if user != self 
                        puts "#{user.full_name}"
                        puts
                    end
                end
            end
        end
        else
            puts "Invalid input. Please try again."
            new_option_number = gets.chomp
            profile_function(new_option_number, options_arr)
        end
    end

    def profile_selection(profile_input)
        if profile_input == "y" || profile_input == "yes"
            puts
            puts "Great, #{self.first_name}. What would you like to do? (#)"
            options_arr = profile_options
            option_number = gets.chomp
            profile_function(option_number, options_arr)
            puts
            # exit
        elsif profile_input == "n" || profile_input == "no"
            puts
            puts "Okay, thanks for using the MTAlert App.\nCarly & Jess remind you to stand clear of the closing doors, please!"
            puts
            exit
        else
            puts
            puts "Invalid input. Please try again"
            puts
            return
        end
    end

end