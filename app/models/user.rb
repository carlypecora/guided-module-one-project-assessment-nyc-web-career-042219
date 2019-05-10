
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
            puts Rainbow("#{users[0].full_name}? (Y/N)").bright
        else
            puts
            puts str
        end
        users
    end

    # SPACING ISSUE HERE!!!!
    def self.create_new_user(fullname_input)
        first_name = fullname_input.split[0].capitalize
        last_name = fullname_input.split[1].capitalize
        user = User.create(first_name: first_name, last_name: last_name)
        user.save
        user
    end

    def self.welcome_and_create_new_user(first_name)
        puts
        puts Rainbow("Welcome #{first_name}, please enter your last name.").bright
        puts
        lastname_input = gets.chomp.capitalize
        user = User.create(first_name: first_name, last_name: lastname_input)
        user.save
        user
    end

    def self.verify_train_selection(user_obj, trains_string, response, trains)
        if !trains_string.include?(response)
            puts
            puts Rainbow("Invalid input. Please try again.").red
            train = Train.find_by(line: response)
            # binding.pry
            Commute.where(train: train).destroy_all
            user_obj.reload
            get_train_selection(trains_string)
            selecting_saved_commute(user_obj, trains)
        else
            selecting_saved_commute(user_obj, trains)
        end
    end

    def self.selecting_saved_commute(user_obj, trains)
        match_commute_input_to_line(trains[0], user_obj)
        get_friend_interest(user_obj)
        user_obj.fellow_users_on_commute(Train.find_by(line: trains[0]))
        user_obj.view_profile?
        # exit
    end

    def self.get_train_selection(trains_string)
        puts
        puts Rainbow("The #{trains_string}?").bright
        puts
        response = gets.chomp.upcase
    end

    def self.welcome_back(user_obj)
        if user_obj.commutes.length > 0
            trains = user_obj.commutes.map { |commute| commute.train.line }
            trains_string = trains.join(" or ")
            puts
            puts Rainbow("Welcome back, #{user_obj.first_name}! Will you be taking the #{trains_string}? (Y/N)").bright
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
                puts Rainbow("Invalid input. Please try again.").red
                self.welcome_back(user_obj)
            end
        end
    end

    def fellow_users_on_commute(train_obj)
        array = Commute.all.select do |commute|
            commute.train == train_obj && commute.user != self
        end
        if array.length > 0
            puts
            puts Rainbow(array.map { |commute| commute.user.full_name }.join(", ")).green
            puts
            puts
            return
        else
            puts
            puts Rainbow("No one else is taking this train.").red
            puts
            view_profile?
        end
    end

    def view_profile?
         puts Rainbow("Would you like to view your profile options? (Y/N)").bright
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
            "View friends on a commute."
        ]
        options_arr.each_with_index { |option, index| puts "#{index + 1}. #{option}"}
        puts
        options_arr
    end

    def update_first_name
        puts
        puts Rainbow("Would you like to update your first name? (Y/N)").bright
        puts
        input = gets.chomp.downcase
        if input == "y" || input == "yes"
            puts
            puts Rainbow("Please enter your new first name.").bright
            puts
            new_first_name = gets.chomp.capitalize
            self.update(first_name: "#{new_first_name}" )
        elsif input =="n" || input == "no"
            return
        else
            puts Rainbow("Invalid input. Please try again.").red
            update_first_name
        end
    end

    def update_last_name
        puts
        puts Rainbow("Would you like to update your last name? (Y/N)").bright
        puts
        input = gets.chomp.downcase
        if input == "y" || input == "yes"
            puts Rainbow("Please enter your new last name.").bright
            new_last_name = gets.chomp.capitalize
            self.update(last_name: "#{new_last_name}" )
        elsif input =="n" || input == "no"
            return
        else
            puts Rainbow("Invalid input. Please try again.").red
            update_last_name
        end
    end

    def delete_commute_train
        puts
        puts Rainbow("Would you like to delete a train commute? (Y/N)").bright
        puts
        input = gets.chomp.downcase
        if input == "y" || input == "yes"
            if self.commutes.length == 0
                # binding.pry
                puts
                puts Rainbow("You do not have any commutes to delete.").red
                puts
                return
            end
            puts
            puts Rainbow("Which commute would you like to delete? (#)").bright
            puts
            counter = 1
            self.commutes.each do |commute|
                puts "#{counter}. #{commute.train.line}"
                counter += 1
            end
            puts
            puts
            commute_number = gets.chomp
            range = self.commutes.length
            if (1..range).include?(commute_number.to_i)
                self.commutes[commute_number.to_i - 1].destroy
                self.reload
                self.commutes.each { |commute| commute.reload }
                return
            else
                puts
                puts Rainbow("Invalid input. Please try again.").red
                puts
                delete_commute_train
            end
            self.commutes[commute_number.to_i - 1].destroy
            self.reload
            return
        elsif input == "n" || input == "no"
            return
        else
            puts
            puts Rainbow("Invalid input. Please try again.").red
            puts
            delete_commute_train
        end
    end

    def add_commute_train
        puts
        puts Rainbow("Would you like to add a train commmute? (Y/N)").bright
        puts
        second_input = gets.chomp.downcase
        if second_input == "y" || second_input == "yes"
            puts
            puts Rainbow("Which train would you like to add to your commute?").bright
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
                puts Rainbow("Invalid input. Please try again.").red
                add_commute_train
            end
        elsif second_input == "n" || second_input == "no"
            return
        else
            puts Rainbow("Invalid input. Please try again.").red
            puts
            add_commute_train
        end
    end


    def profile_function(option_number, options_arr)
        if option_number == "1"
            puts
            puts Rainbow("Your full name:").bright
            puts "#{self.full_name}"
            puts
            puts Rainbow("Here are the trains you've taken:").bright
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
                puts Rainbow("These are your friends that take the #{commute.train.line}:").bright
                puts
                if commute.train.users.length == 1
                    puts Rainbow("No one else takes the #{commute.train.line}.").red
                    puts
                else
                    commute.train.users.each do |user|
                    if user != self
                        puts Rainbow("#{user.full_name}").green
                        puts
                    end
                end
            end
        end
        else
            puts Rainbow("Invalid input. Please try again.").red
            new_option_number = gets.chomp
            profile_function(new_option_number, options_arr)
        end
    end

    def profile_selection(profile_input)
        if profile_input == "y" || profile_input == "yes"
            puts
            puts Rainbow("Great, #{self.first_name}. What would you like to do? (#)").bright
            puts
            options_arr = profile_options
            option_number = gets.chomp
            profile_function(option_number, options_arr)
            puts
            # exit
        elsif profile_input == "n" || profile_input == "no"
            puts
            puts Rainbow("Okay, thanks for using the" + Rainbow(" MTA").blue + Rainbow("lert App").yellow.bright + ".").bright
            puts Rainbow("Carly & Jess remind you to stand clear of the closing doors, please!").cyan.bright
            puts
            puts
            puts
            exit
        else
            puts
            puts Rainbow("Invalid input. Please try again.").red
            puts
            return
        end
    end

end
