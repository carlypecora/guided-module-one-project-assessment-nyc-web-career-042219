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
        # binding.pry
        user = User.create(first_name: first_name, last_name: last_name)
        user.save
        user
    end

    def self.welcome_and_create_new_user
        puts
        puts "Welcome new user, please enter your first and last name."
        puts
        fullname_input = gets.chomp
        user = User.create_new_user(fullname_input)
        user.save
        user
    end

    def self.welcome_back(user_obj)
        if user_obj.commutes.length > 0
            trains = user_obj.commutes.map { |commute| commute.train.line }.join(" or ")
            puts "Welcome back, #{user_obj.first_name}! Will you be taking the #{trains}? (Y/N)"
            puts
            response = gets.chomp
            if response == "N" || response == "No" || response == "n" || response == "no" || response == "NO"
            return
            end
        user_obj
        end
    end

    def fellow_users_on_commute(train_obj)
        array = Commute.all.select do |commute|
            commute.train == train_obj && commute.user != self
        end
        string = array.map { |commute| commute.user.full_name }.join(", ")
        puts string
    end

end
