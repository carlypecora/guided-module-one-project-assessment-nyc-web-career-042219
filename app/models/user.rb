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
        counter = 1
        users.each do |user| 
            puts "#{counter}. #{user.full_name}"
            counter += 1
        end
    end

    def self.create_new_user(fullname_input)
        first_name = fullname_input.split[0]
        last_name = fullname_input.split[1]
        user = User.create(first_name: first_name, last_name: last_name)
        user.save
        user
    end

    def self.welcome_and_create_new_user
        puts "Welcome new user, please enter your first and last name."
        fullname_input = gets.chomp
        user = User.create_new_user(fullname_input)
        user.save
        user
    end

    def fellow_users_on_commute(train_input)
        Commute.all.select do |commute|
            commute.train == train_input
        end.each { |commute| puts commute.user.full_name }
    end

end
