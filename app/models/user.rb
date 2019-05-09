# == Schema Information
#
# Table name: users
#
#  id           :integer          not null, primary key
#  first_name   :string
#  last_name    :string
#  neighborhood :string
#
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
        lastname_input = gets.chomp
        user = User.create(first_name: first_name, last_name: lastname_input)
        user.save
        user
    end

    def self.verify_train_selection(user_obj, trains_string, response, trains)
        if !trains_string.include? response
            puts
            puts "Invalid input. Please try again."
            get_train_selection(trains_string)
            selecting_saved_commute(user_obj, trains)
        else
            selecting_saved_commute(user_obj, trains)
        end
    end

    def self.selecting_saved_commute(user_obj, trains)
        match_commute_input_to_line(trains[0])
        get_friend_interest
        user_obj.fellow_users_on_commute(Train.find_by(line: trains[0]))
        exit
    end

    def self.get_train_selection(trains_string)
        puts
        puts "The #{trains_string}?"
        puts
        response = gets.chomp
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
            exit
        else
            puts
            puts "No one else is taking this train."
            puts
            puts "Thanks for using MTA commute! Stand clear of the closing doors please."
            exit
        end
    end

    def view_profile?
         puts "Would you like to view your user profile? (Y/N)"
         profile_input = gets.chomp.downcase
         profile_input
    end

    def profile_response(profile_input)
        if profile_input == "y" || profile_input == "yes"
            puts "Great, #{user_obj.first_name}. What would you like to do?"
        else
           puts "Carly & Jess remind you to stand clear of the closing doors, please!"
        end
    end

end
